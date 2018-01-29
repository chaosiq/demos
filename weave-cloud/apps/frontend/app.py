# -*- coding: utf-8 -*-
import logging
import os

import cherrypy
from cherrypy.process.wspbus import states
import click
from flask import Flask, render_template, request
from flask_admin import Admin
from flask_admin.contrib.sqla import ModelView
from flask_opentracing import FlaskTracer
from jaeger_client import Config
import opentracing
from prometheus_flask_exporter import PrometheusMetrics
from requestlogger import ApacheFormatter, WSGILogger
import sqlalchemy

from model import db, Star


__version__ = "0.1.0"
app = Flask(__name__, template_folder='templates', static_folder='static')


@app.route('/')
def index():
    stars = Star.query.filter().all()
    return render_template('index.html', stars=stars)


@app.route('/health')
def health():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"


@app.route('/live')
def live():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"


def create_app():
    """
    Create the application and its dependencies.

    * create the tables in the ̀`cosmos` database
    * setup the admin panel
    * setup a Prometheus endpoint
    * setup Open Tracing support
    """
    cherrypy.log("Creating frontend application")
   
    pg_addr = os.environ.get("PG_ADDR", "localhost:5432")
    pg_user = os.environ.get("PG_USERNAME", "postgres")
    pg_pwd = os.environ.get("PG_PASSWORD", "password1")
    db_conn = "postgresql://{u}:{p}@{a}/cosmos".format(
        u=pg_user, p=pg_pwd, a=pg_addr
    )
    app.config["SQLALCHEMY_DATABASE_URI"] = db_conn
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["SECRET_KEY"] = "kaboom"

    # intialize our db and create the tables if they don't exist yet
    with app.app_context():
        try:
            db.init_app(app)
            db.create_all()
        except sqlalchemy.exc.OperationalError:
            cherrypy.log("Failed to connect to database", traceback=False)
       
    # expose metrics of ourselves to prometheus
    metrics = PrometheusMetrics(app)
    metrics.info(
        'app_info', 'Application info', version=__version__, app="frontend")

    # a simple admin dashboard for the application
    admin = Admin(app, name='cosmos', template_mode='bootstrap3')
    admin.add_view(ModelView(Star, db.session))

    # trace requests accross our system with Open Tracing
    jeager_logger = logging.getLogger('jaeger_tracing')
    jeager_logger.setLevel(logging.DEBUG)
    tracer = FlaskTracer(
        Config(
            config={
            },
            service_name="frontend"
        ).initialize_tracer(),
        True, app, ["url_rule"]
    )
  
    # this will log requests to stdout
    wsgiapp = WSGILogger(
        app.wsgi_app, [logging.StreamHandler()], ApacheFormatter(),
        propagate=False)

    cherrypy.tree.graft(wsgiapp, "/")

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
