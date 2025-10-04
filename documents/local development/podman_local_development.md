# n8n Local Development with Podman

This guide shows how to run n8n locally using Podman with Postgres for persistence and optional community nodes installed at build time.

## Prerequisites

- Podman installed and running
- openssl (for generating an encryption key)

## 1) Create network and volumes

```bash
podman network create n8n-net
podman volume create pg_data
podman volume create n8n_data
```

## 2) Run Postgres

```bash
podman run -d --name postgres --network n8n-net \
  -e POSTGRES_DB=n8n \
  -e POSTGRES_USER=n8n \
  -e POSTGRES_PASSWORD=n8npassword \
  -v pg_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  docker.io/library/postgres:15-alpine
```

## 3) Build n8n image (with optional community nodes)

```bash
podman build \
  --build-arg N8N_IMAGE_TAG=latest \
  --build-arg COMMUNITY_NODES="n8n-nodes-plaid@latest" \
  -t localhost/n8n:latest .
```

- To pin specific versions, replace @latest with a version tag.

## 4) Run n8n

```bash
export N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

podman run -d --name n8n --network n8n-net \
  -p 5678:5678 \
  -e N8N_HOST=0.0.0.0 \
  -e N8N_PROTOCOL=http \
  -e WEBHOOK_URL=http://localhost:5678/ \
  -e N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY" \
  -e DB_TYPE=postgresdb \
  -e DB_POSTGRESDB_HOST=postgres \
  -e DB_POSTGRESDB_PORT=5432 \
  -e DB_POSTGRESDB_DATABASE=n8n \
  -e DB_POSTGRESDB_USER=n8n \
  -e DB_POSTGRESDB_PASSWORD=n8npassword \
  -e N8N_USER_FOLDER=/home/node/.n8n \
  -v n8n_data:/home/node/.n8n \
  localhost/n8n:latest
```

## 5) Access n8n

- URL: http://localhost:5678
- Logs: `podman logs -f n8n`

## 6) Community nodes during development

- Preferred: rebuild image with `--build-arg COMMUNITY_NODES="pkg@version"` so nodes are pinned and reproducible.
- Quick test (not recommended for prod):
  ```bash
  podman exec -it n8n bash
  npm i --prefix /home/node/.n8n <pkg>
  ```
  Then restart container.

## 7) Cleanup

```bash
podman rm -f n8n postgres || true
podman volume rm n8n_data pg_data || true
podman network rm n8n-net || true
```
