FROM node:24-alpine

ARG N8N_VERSION=latest

# Set environment variables
ENV N8N_HOST=${N8N_HOST:-localhost}
ENV N8N_PORT=${N8N_PORT:-5678}
ENV N8N_PROTOCOL=${N8N_PROTOCOL:-http}
ENV N8N_USER_MANAGEMENT_DISABLED=${N8N_USER_MANAGEMENT_DISABLED:-false}
ENV N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE:-false}
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=${N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS:-true}
ENV N8N_DATA_FOLDER=${N8N_DATA_FOLDER:-/home/node/.n8n}
ENV TZ=${TZ:-UTC}

RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# Update everything and install needed dependencies
RUN apk add --update graphicsmagick tzdata

# # Set a custom user to not have n8n run as root
USER root

# Install n8n and the also temporary all the packages
# it needs to build it correctly.
RUN apk --update add --virtual build-dependencies python3 build-base ca-certificates && \
	npm install -g n8n@${N8N_VERSION} n8n-nodes-plaid && \
	apk del build-dependencies

WORKDIR /usr/src/app

# Expose the port
EXPOSE $N8N_PORT

CMD ["n8n", "start"]