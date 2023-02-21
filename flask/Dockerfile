# We will use python:3.10-alpine as the base image for building the Flask container
FROM python:3.10-alpine
#build argument, this add git short git commit hash
ARG GIT_COMMIT=unspecified
#labelling image
LABEL CREATOR=GKOVACS
# It specifies the working directory where the Docker container will run
WORKDIR /app
# Copying all the application files to the working directory
COPY requirements.txt /app
# Install all the dependencies required to run the Flask application
RUN pip install -r requirements.txt

COPY . /app

RUN sed -i "s/GIT_VERSION=.*/GIT_VERSION=${GIT_COMMIT}/" /app/app.py

ENTRYPOINT ["python3"]
CMD ["app.py"]

