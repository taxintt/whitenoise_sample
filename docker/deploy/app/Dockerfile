# syntax=docker/dockerfile:1
ARG PYTHON_VER=3.9
ARG APP_SRC=/usr/src
ARG APP_ENVFILE=/env/app-configuration.env:/env/infra-configuration.env

### Django app ###
FROM python:${PYTHON_VER}-slim-buster AS app-base
ARG PYTHON_VER
ARG APP_SRC

ENV PORT=${PORT}
ARG PORT

WORKDIR ${APP_SRC}

COPY requirements/deploy/requirements.txt ${APP_SRC}/
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && rm -rf /var/lib/apt/lists/*

CMD exec gunicorn --bind 0.0.0.0:$PORT\
    project.wsgi:application

COPY ./staticsite ${APP_SRC}/
COPY ./env /env

### collect static files ###
FROM app-base AS staticfiles
ARG APP_SRC
ARG APP_ENVFILE

ENV APP_SRC=${APP_SRC}
ENV APP_ENVFILE=${APP_ENVFILE}

RUN python manage.py collectstatic --no-input

### Web Application (Django + staticfiles)  ###
FROM app-base
ARG APP_SRC
ARG APP_ENVFILE

ENV APP_SRC=${APP_SRC}
ENV APP_ENVFILE=${APP_ENVFILE}

COPY --from=staticfiles ${APP_SRC}/static ${APP_SRC}/static
