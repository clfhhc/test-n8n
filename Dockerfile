FROM n8nio/n8n:latest

# Set environment variables
ENV N8N_HOST=${N8N_HOST:-localhost}
ENV N8N_PORT=${N8N_PORT:-5678}
ENV N8N_PROTOCOL=${N8N_PROTOCOL:-http}
ENV N8N_USER_MANAGEMENT_DISABLED=${N8N_USER_MANAGEMENT_DISABLED:-false}
ENV N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE:-false}

# Install Plaid connector
RUN npm install n8n-nodes-plaid

# Expose the port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"] 