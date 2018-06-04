# Open Security Summit Demo 2018

This basic system is made of two services talking over HTTP. This is as
dumb as can be.

The idea is indeed to keep it so simple that we can focus on learning about
Chaos Engineering.

## Run those two services

To get running, you need to
(please see https://docs.chaostoolkit.org/reference/usage/install/):

* install Python 3.5 or greater
* create a virtual environment: `$ python3 -m venv ~/.venv/opensecsummit`
* activate the virtual environment: `$ source ~/.venv/opensecsummit`
* install the dependencies via: `(opensecsummit) $ pip install -U -r requirements.txt`
* then run the services as follows:
  - `(opensecsummit) $ python3 apps/backend.py`
  - `(opensecsummit) $ python3 apps/public.py`

The `(opensecsummit)` indicates you are running in the context of the created
virtual environment and that your Python dependencies are resolved relative to
the `~/.venvs/opensecsummit` directory.

The public service runs on localhost on port 7090 and the backend service
on localhost on port 7091. When you contact the public service, it requests the
backend service and returns the content.

