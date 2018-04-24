from datetime import date, datetime
import json

from astral import Astral
from flask import abort
import pytz

__all__ = ["handle"]


def handle(req: str) -> str:
    """
    Compute sunrise and sunset for the given city.
    """
    a = Astral()
    a.solar_depression = 'civil'

    params = json.loads(req)
    city_name = params["city"] or ""
    try:
        city = a[city_name]
    except KeyError:
        return json.dumps({"error": "unknown city"})

    tz = pytz.timezone(city.timezone)

    sun = city.sun(date=date.today(), local=False)
    result = {}
    for k, v in sun.items():
        if isinstance(v, datetime):
            result[k] = v.astimezone(tz).isoformat()
        else:
            result[k] = v
    return json.dumps(result)
