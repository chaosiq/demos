# -*- coding: utf-8 -*-
import contextlib

import cherrypy
from cherrypy.process.wspbus import states
from flask import Flask, render_template, request
from flask_opentracing import FlaskTracer
from jaeger_client import Config, Span
import opentracing

from model import Star


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


@contextlib.contextmanager
def new_span(name: str, parent_span: Span=None):
    """
    Create a new nested span.
    """
    try:
        p = parent_span or tracer.get_span()
        s = tracer._tracer.start_span("query_stars", child_of=p)
        yield s
    finally:
        s.finish()


@frontend_app.route('/')
@tracer.trace("url_rule")
def index():
    with new_span("query_stars"):
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
