ARG N8N_IMAGE_TAG=latest
FROM n8nio/n8n:${N8N_IMAGE_TAG}

# Optional: space-separated community nodes to install at build time
# Example: --build-arg COMMUNITY_NODES="n8n-nodes-plaid@latest"
ARG COMMUNITY_NODES=""

USER root

# Ensure n8n user folder exists and install community nodes into it
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_RUNNERS_ENABLED=true
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=true
ENV N8N_GIT_NODE_DISABLE_BARE_REPOS=true
RUN mkdir -p /home/node/.n8n && \
    (npm init -y --prefix /home/node/.n8n >/dev/null 2>&1 || true) && \
    for PKG in $COMMUNITY_NODES; do \
      if [ -n "$PKG" ]; then npm install --omit=dev --prefix /home/node/.n8n "$PKG"; fi; \
    done && \
    chown -R node:node /home/node/.n8n

# Expose editor/ui port
EXPOSE 5678

USER node