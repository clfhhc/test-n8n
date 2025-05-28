# Local Kubernetes Cluster and Argo CD Setup Guide

This document guides you through setting up a local Kubernetes cluster using `kind` and installing Argo CD using the Operator Lifecycle Manager (OLM) with the Argo CD Operator.

## Prerequisites

*   **`kubectl`**: Ensure `kubectl` is installed and configured in your PATH.
*   **Homebrew (macOS)**: If you are on macOS and using Homebrew, ensure `brew` is in your PATH.
*   **Container Runtime**: A container runtime like Docker or Podman must be installed and running. `kind` will use this to create cluster nodes.
*   **`curl`**: Used to download installation scripts.

*(Note: Commands below assume `kubectl` and `brew` are in your system's PATH. If not, you may need to use their full paths, e.g., `/opt/homebrew/bin/kubectl` or `/opt/homebrew/bin/brew` if installed via Homebrew on macOS in the default location).*

## 1. Install `kind` (Local Kubernetes Cluster Tool)

*   **Goal:** Install `kind` to create a local Kubernetes cluster.
*   **Action (macOS with Homebrew):**
    ```bash
    brew install kind
    ```
    For other operating systems, refer to the [official kind installation guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).

## 2. Create Local Kubernetes Cluster

*   **Goal:** Create a Kubernetes cluster locally.
*   **Action:**
    ```bash
    kind create cluster --name n8n-cluster
    ```
    *(Note: `kind` will use your installed container runtime (Docker or Podman). Ensure it is running.)*
*   **Result:** A local Kubernetes cluster named `n8n-cluster` is created, and your `kubectl` context should be automatically set to `kind-n8n-cluster`. You can verify with `kubectl cluster-info --context kind-n8n-cluster`.

## 3. Install Operator Lifecycle Manager (OLM)

*   **Goal:** Install OLM to manage Kubernetes operators.
*   **Action:** Download and execute the OLM installation script (ensure `kubectl` is in your PATH for the script to run correctly). The version `v0.28.0` is used here as an example; you might want to check for a newer stable version.
    ```bash
    curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/install.sh | bash -s v0.28.0
    ```
    *(If the script has issues finding `kubectl`, ensure its location is in your `$PATH` before running the command.)*
*   **Result:** OLM is installed on the cluster, creating necessary CRDs and deployments (e.g., `olm-operator`, `catalog-operator` typically in the `olm` namespace).

## 4. Install Argo CD Operator

*   **Goal:** Install the Argo CD operator, which will manage Argo CD instances.
*   **Method:** Use an OLM subscription via a manifest from OperatorHub.io.
*   **Action:**
    ```bash
    kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
    ```
    This creates a `Subscription` resource (e.g., `my-argocd-operator`) in the `operators` namespace. OLM will then automatically detect this subscription and install the Argo CD operator.
*   **Verification:** Monitor the installation progress:
    ```bash
    kubectl get csv -n operators -w
    ```
*   **Result:** The Argo CD Operator is installed, and its phase becomes `Succeeded`. The operator version (e.g., `argocd-operator.v0.13.0`) may vary depending on the current OperatorHub manifest.

## 5. Deploy an Argo CD Instance

*   **Goal:** Create an Argo CD instance using the installed operator.
*   **Method:** Apply an `ArgoCD` custom resource.
*   **Actions:**
    1.  Create a namespace for the Argo CD instance (e.g., `argocd`):
        ```bash
        kubectl create namespace argocd
        ```
    2.  Create a manifest file named `argocd-instance.yaml` with the following content:
        ```yaml
        apiVersion: argoproj.io/v1beta1
        kind: ArgoCD
        metadata:
          name: example-argocd # You can choose a different name
          namespace: argocd     # Must match the namespace created above
        spec: {} # An empty spec uses operator defaults for a basic setup
        ```
    3.  Apply the manifest:
        ```bash
        kubectl apply -f argocd-instance.yaml
        ```
    4.  Monitor the deployment of Argo CD components (application-controller, redis, repo-server, server) in the `argocd` namespace:
        ```bash
        kubectl get pods -n argocd -w
        ```
*   **Result:** All Argo CD components are deployed and should reach a `Running` state in the `argocd` namespace.

## 6. Access Argo CD UI

*   **Goal:** Access the web UI of the deployed Argo CD instance.
*   **Actions:**
    1.  Port-forward the Argo CD server service. The service name is typically `<instance-name>-server` (e.g., `example-argocd-server` if you used `example-argocd` as the metadata.name in `argocd-instance.yaml`).
        ```bash
        kubectl port-forward svc/example-argocd-server -n argocd 8080:443
        ```
        *(This forwards local port 8080 to the service's HTTPS port 443. The service might also expose HTTP on port 80, in which case you could forward to `8080:80` and use `http://localhost:8080`.)*
    2.  The UI should then be accessible, typically at `https://localhost:8080` (if forwarding to HTTPS) or `http://localhost:8080` (if forwarding to HTTP).

## 7. Log In to Argo CD

*   **Goal:** Obtain credentials and log in to the Argo CD UI.
*   **Username:** `admin`
*   **Password Retrieval:** The Argo CD Operator stores the initial admin password in a secret named `<instance-name>-cluster` (e.g., `example-argocd-cluster`).
    Retrieve and decode it using:
    ```bash
    kubectl get secret -n argocd example-argocd-cluster -o go-template='''{{index .data "admin.password"}}''' | base64 -d; echo
    ```
    (Reference: [Argo CD Operator Docs - Secrets](https://argocd-operator.readthedocs.io/en/latest/usage/basics/#secrets))
*   **Result:** You should be able to log into the Argo CD UI using the `admin` username and the retrieved password.

## Final Outcome

After following these steps, you will have:
*   A local Kubernetes cluster running via `kind`.
*   Operator Lifecycle Manager (OLM) installed.
*   Argo CD Operator installed via OLM.
*   An instance of Argo CD running and accessible.

This setup is ready for deploying applications using GitOps principles. For the n8n project this repository is for, the next steps would involve:
1.  Ensuring the `repoURL` in `k8s/argocd-app.yaml` points to your Git repository.
2.  Applying this `k8s/argocd-app.yaml` to your cluster (e.g., in the `argocd` namespace) for Argo CD to manage the n8n deployment.
    ```bash
    kubectl apply -f k8s/argocd-app.yaml -n argocd
    ``` 