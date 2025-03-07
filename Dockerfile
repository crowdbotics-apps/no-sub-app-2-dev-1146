FROM alpine:latest

# Add the testing repo in case it's needed for additional dependencies
# For example, gdal can be installed by using gdal@testing
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install system dependencies
RUN apk add --no-cache --update \
  bash \
  gcc \
  build-base \
  musl-dev \
  postgresql-dev \
  python3 \
  python3-dev \
  py3-pip \
  curl \
# zlib, zlib-dev, and libjpeg-turbo are required by pillow
  zlib \
  zlib-dev \
  libjpeg-turbo \
  libjpeg-turbo-dev
RUN pip3 install --no-cache-dir -q pipenv

# Add our code
ADD ./ /opt/webapp/
WORKDIR /opt/webapp

# Install dependencies
RUN pipenv install --deploy --system

# Allow SECRET_KEY to be passed via arg so collectstatic can run during build time
ARG SECRET_KEY
RUN python3 manage.py collectstatic --no-input

# Run the image as a non-root user
RUN adduser -D myuser
USER myuser

# Run the web server on port $PORT
CMD waitress-serve --port=$PORT no_sub_app_2_dev_1146.wsgi:application
