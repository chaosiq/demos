# -*- coding: utf-8 -*-
from flask_sqlalchemy import SQLAlchemy

__all__ = ["db", "Note"]

db = SQLAlchemy()


class Star(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    discovered_by = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(), nullable=False)
    link = db.Column(db.String(), nullable=False)
    img_link = db.Column(db.String())
