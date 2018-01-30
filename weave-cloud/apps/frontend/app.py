# -*- coding: utf-8 -*-
import cherrypy
from cherrypy.process.wspbus import states
from flask import Blueprint, render_template, request
from flask_opentracing import FlaskTracer
from jaeger_client import Config
import opentracing

from model import Star


__all__ = ["blueprint"]

blueprint = Blueprint(
    "frontend", __name__, template_folder='templates', static_folder='static')


def create_tracer():
    """
    Create the Jeager tracer instance as late as possible to avoid certain
    race conditions.
    """
    cherrypy.log("Creating tracer")
    return Config(config={}, service_name="frontend").initialize_tracer()


tracer = FlaskTracer(create_tracer, False, blueprint, ["url_rule"])


@blueprint.route('/')
@tracer.trace()
def index():
    stars = Star.query.filter().all()
    return render_template('index.html', stars=stars)


@blueprint.route('/health')
@tracer.trace()
def health():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"


@blueprint.route('/live')
@tracer.trace()
def live():
    if cherrypy.engine.state != states.STARTED:
        raise cherrypy.HTTPError(503)
    return "OK"
