ARG N8N_IMAGE_TAG=latest
FROM n8nio/n8n:${N8N_IMAGE_TAG}

# Optional: space-separated community nodes to install at build time
# Example: --build-arg COMMUNITY_NODES="n8n-nodes-plaid@latest"
ARG COMMUNITY_NODES=""

USER root

# Ensure n8n user folder exists and install community nodes into it
ENV N8N_USER_FOLDER=/home/node/.n8n
RUN mkdir -p /home/node/.n8n && \
    (npm init -y --prefix /home/node/.n8n >/dev/null 2>&1 || true) && \
    for PKG in $COMMUNITY_NODES; do \
      if [ -n "$PKG" ]; then npm install --omit=dev --prefix /home/node/.n8n "$PKG"; fi; \
    done && \
    chown -R node:node /home/node/.n8n

# Expose editor/ui port
EXPOSE 5678

USER node

# Start n8n
CMD ["n8n", "start"]