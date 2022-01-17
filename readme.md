### CodeBeans Laravel Docker
![CI](https://github.com/codebeans-io/laravel-docker/actions/workflows/release.yml/badge.svg)

This repo contains the Dockerfile to build a single Docker image for running your Laravel applications. This image can be used locally, or in production.

This image contains:
* NGINX reverse proxy
* PHP-FPM
* NodeJS

#### How to use

**Step 1: Pull the image**
First, we'll pull the public image from Dockerhub.
```bash
docker pull codebeans/laravel:latest
```

**Step 2: Run the image**
Next, we run a container on our local machine.
```bash
docker run -p 8000:80 codebeans/laravel:latest
```

You should now be able to access the app from `http://localhost:8000`

