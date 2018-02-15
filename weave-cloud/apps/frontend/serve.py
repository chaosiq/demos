# -*- coding: utf-8 -*-
import logging
import os
import sys

import cherrypy
import click
from flask import Flask
from flask_admin import Admin
from flask_admin.contrib.sqla import ModelView
from flask_opentracing import FlaskTracer
from jaeger_client import Config
import opentracing
from prometheus_flask_exporter import PrometheusMetrics
from requestlogger import ApacheFormatter, WSGILogger
import sqlalchemy

from app import frontend_app
from model import db, Star

__version__ = "0.1.0"


def setup_db():
    """
    Initialize our database.
    """
    pg_addr = os.environ.get("PG_ADDR", "localhost:5432")
    pg_user = os.environ.get("PG_USERNAME", "postgres")
    pg_pwd = os.environ.get("PG_PASSWORD", "password1")
    db_conn = "postgresql://{u}:{p}@{a}/cosmos".format(
        u=pg_user, p=pg_pwd, a=pg_addr
    )
    frontend_app.config["SQLALCHEMY_DATABASE_URI"] = db_conn
    frontend_app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    frontend_app.config["SECRET_KEY"] = "kaboom"

    # intialize our db and create the tables if they don't exist yet
    with frontend_app.app_context():
        try:
            db.init_app(frontend_app)
            db.create_all()
        except sqlalchemy.exc.OperationalError:
            cherrypy.log("Failed to connect to database", traceback=False)


def setup_metrics():
    """
    Setup Prometheus endpoint for monitoring purpose.
    """
    # expose metrics of ourselves to prometheus
    metrics = PrometheusMetrics(frontend_app)
    metrics.info(
        'blueprint_info', 'application info', version=__version__,
        app="frontend")


def setup_admin_dashboard():
    """
    Setup a simple adminis dashboard so you can manage entries in the
    database.
    """
    # a simple admin dashboard for the application
    admin = Admin(frontend_app, name='cosmos', template_mode='bootstrap3')
    admin.add_view(ModelView(Star, db.session))


def serve_blueprint():
    """
    Mount the application so it can served by the HTTP server.
    """
    # this will log requests to stdout
    wsgiapp = WSGILogger(
        frontend_app.wsgi_app, [logging.StreamHandler()], ApacheFormatter(),
        propagate=False)
    cherrypy.tree.graft(wsgiapp, "/")
    return wsgiapp


def setup_logger():
    """
    Enable logger for various libraries
    """
    logger = logging.getLogger('jaeger_tracing')
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    fmt = '[%(asctime)s] %(levelname)s %(module)s: %(message)s'
    fmt = logging.Formatter(fmt, datefmt='%d/%b/%Y:%H:%M:%S')
    handler.setFormatter(fmt)
    logger.addHandler(handler)


def create_app():
    """
    Create the application and its dependencies.

    * create the tables in the ̀`cosmos` database
    * setup the admin panel
    * setup a Prometheus endpoint
    * setup Open Tracing support
    """
    cherrypy.log("Creating frontend application")
    
    setup_logger()
    setup_db()
    setup_metrics()
    setup_admin_dashboard()
    wsgiapp = serve_blueprint()

    cherrypy.log("Frontend application created")

    return wsgiapp


@click.command()
@click.option('--host', default="0.0.0.0", help='Address to bind to.',
              show_default=True)
@click.option('--port', default=8080, help='Port to bind to.',
              show_default=True)
@click.option('--dev', is_flag=True, help='Run in dev mode.',
              show_default=True)
def run(host: str="0.0.0.0", port: int=8080, dev: bool=False):
    if not dev:
        cherrypy.config.update({"environment": "production"})
    cherrypy.config.update({
        "server.socket_host": host,
        "server.socket_port": port,
        "engine.autoreload.on": False,
        "log.screen": True,
        "tools.proxy.on": True,
        "tools.proxy.base": "https://app.cosmos.info",
    })

    cherrypy.engine.subscribe('start', create_app)
    cherrypy.log.error_log.propagate = False
    cherrypy.engine.signals.subscribe()
    cherrypy.engine.start()
    cherrypy.engine.block()


if __name__ == "__main__":
    run()
