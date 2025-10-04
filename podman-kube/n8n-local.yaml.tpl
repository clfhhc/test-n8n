apiVersion: v1
kind: Pod
metadata:
  name: n8n-local
  labels:
    app: n8n-local
spec:
  containers:
  - name: postgres
    image: docker.io/library/postgres:15-alpine
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "500m"
        memory: "1Gi"
    env:
    - name: POSTGRES_DB
      value: "${POSTGRES_DB}"
    - name: POSTGRES_USER
      value: "${POSTGRES_USER}"
    - name: POSTGRES_PASSWORD
      value: "${POSTGRES_PASSWORD}"
    ports:
    - containerPort: 5432
      hostPort: 5432
    volumeMounts:
    - name: pgdata
      mountPath: /var/lib/postgresql/data
  - name: n8n
    image: ${N8N_IMAGE}
    resources:
      requests:
        cpu: "250m"
        memory: "512Mi"
      limits:
        cpu: "1"
        memory: "1Gi"
    env:
    - name: N8N_HOST
      value: "${N8N_HOST}"
    - name: N8N_PROTOCOL
      value: "${N8N_PROTOCOL}"
    - name: WEBHOOK_URL
      value: "${WEBHOOK_URL}"
    - name: N8N_ENCRYPTION_KEY
      value: "${N8N_ENCRYPTION_KEY}"
    - name: DB_TYPE
      value: "postgresdb"
    - name: DB_POSTGRESDB_HOST
      value: "localhost"
    - name: DB_POSTGRESDB_PORT
      value: "5432"
    - name: DB_POSTGRESDB_DATABASE
      value: "${POSTGRES_DB}"
    - name: DB_POSTGRESDB_USER
      value: "${POSTGRES_USER}"
    - name: DB_POSTGRESDB_PASSWORD
      value: "${POSTGRES_PASSWORD}"
    - name: N8N_USER_FOLDER
      value: "/home/node/.n8n"
    ports:
    - containerPort: 5678
      hostPort: 5678
    volumeMounts:
    - name: n8n-user
      mountPath: /home/node/.n8n
  volumes:
  - name: pgdata
    hostPath:
      path: /tmp/n8n-podman/pg_data
      type: DirectoryOrCreate
  - name: n8n-user
    hostPath:
      path: /tmp/n8n-podman/n8n_data
      type: DirectoryOrCreate

