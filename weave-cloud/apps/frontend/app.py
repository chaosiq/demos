# -*- coding: utf-8 -*-
import cherrypy
from cherrypy.process.wspbus import states
from flask import Flask, render_template, request
from flask_opentracing import FlaskTracer
from jaeger_client import Config
import opentracing
from sqlalchemy import exc

from model import db, Star


__all__ = ["frontend_app"]

frontend_app = Flask(
    __name__, template_folder='templates', static_folder='static')


def create_tracer():
    """
    Create the Jeager tracer instance as late as possible to avoid certain
    race conditions.
    """
    cherrypy.log("Creating tracer")
    return Config(config={}, service_name="frontend").initialize_tracer()


tracer = FlaskTracer(create_tracer)


@frontend_app.route('/')
@tracer.trace("url_rule")
def index():
    try:
        stars = Star.query.filter().all()
    except exc.OperationalError:
        cherrypy.log("Connection to database lost, trying a new connection")

        # invalidate current pending query
        db.session.rollback()

        # will re-create a new connection pool
        stars = Star.query.filter().all()

    return render_template('index.html', stars=stars)


@frontend_app.route('/health')
@tracer.trace("url_rule")
def health():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"


@frontend_app.route('/live')
@tracer.trace("url_rule")
def live():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"
