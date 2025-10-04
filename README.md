# n8n Kubernetes Deployment

This repository contains the necessary configurations to deploy n8n on Kubernetes using Argo CD.

## Prerequisites

- Kubernetes cluster
- Argo CD installed in your cluster
- kubectl configured to access your cluster
- Git repository access

## Project Structure

```
.
├── Dockerfile
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pvc.yaml
│   └── argocd-app.yaml
└── README.md
```

## Deployment

1. Update the Argo CD application manifest (`k8s/argocd-app.yaml`) with your repository URL:
   ```yaml
   source:
     repoURL: https://github.com/your-username/test-n8n.git
   ```

2. Apply the Argo CD application:
   ```bash
   kubectl apply -f k8s/argocd-app.yaml
   ```

3. Monitor the deployment in Argo CD UI or using:
   ```bash
   kubectl get applications -n argocd
   ```

## Configuration

The deployment includes:
- Persistent storage for n8n data
- Resource limits and requests
- Basic environment configuration

You can modify the following files to adjust the configuration:
- `k8s/deployment.yaml` - For deployment configuration
- `k8s/service.yaml` - For service configuration
- `k8s/pvc.yaml` - For storage configuration

## Accessing n8n

Once deployed, n8n will be available within the cluster at:
- Service URL: `http://n8n.n8n.svc.cluster.local`

To expose it externally, you'll need to configure an Ingress or use port-forwarding:
```bash
kubectl port-forward svc/n8n -n n8n 5678:80
```

Then access n8n at: `http://localhost:5678` 

## Building and pushing with Podman

Example commands (adjust image registry and hostnames):

```bash
# Build with community nodes at build time
podman build \
  --build-arg N8N_IMAGE_TAG=latest \
  --build-arg COMMUNITY_NODES="n8n-nodes-plaid@latest" \
  -t localhost/n8n:latest .

# Run locally (optional)
podman run --rm -it -p 5678:5678 localhost/n8n:latest

# Push to your registry (example for local registry)
podman push localhost/n8n:latest
```

## Kubernetes notes

- Create/update secrets in `k8s/secret.yaml` with your real credentials and encryption key.
- Apply resources via Argo CD (`k8s/argocd-app.yaml`).
- Update `k8s/ingress.yaml` host and TLS secret to match your domain and certificate setup.

## Postgres and persistence

- Postgres manifests are included in `k8s/postgres.yaml` with a PVC in `k8s/pvc-postgres.yaml`.
- n8n data folder is mounted via `k8s/pvc.yaml` to `/home/node/.n8n`.