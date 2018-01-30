FROM python:3.6-alpine

LABEL maintainer="support@chaosiq.io"

ADD requirements.txt requirements.txt
RUN apk update && \
    apk add --virtual build-deps gcc python3-dev musl-dev && \
    apk add postgresql-dev && \
    pip install -U pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del build-deps && \
    rm -rf /tmp/* /root/.cache

ADD . .
EXPOSE 8080
ENTRYPOINT ["python3", "serve.py"]
