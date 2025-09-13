#!/bin/bash

set -euo pipefail

KRATIX_VERSION="${KRATIX_VERSION:-v0.103.0}"
KRATIX_NAMESPACE="${KRATIX_NAMESPACE:-kratix-platform-system}"
CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.13.3}"

echo "🚀 Starting Kratix installation on k3s..."

check_k3s() {
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl not found. Please install kubectl first."
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ Cannot connect to Kubernetes cluster. Please ensure k3s is running."
        exit 1
    fi

    echo "✅ k3s cluster connection verified"
}

install_cert_manager() {
    echo "📦 Installing cert-manager..."

    if kubectl get namespace cert-manager &> /dev/null; then
        echo "✅ cert-manager namespace already exists"
    else
        kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
        echo "⏳ Waiting for cert-manager to be ready..."
        kubectl wait --for=condition=Available deployment/cert-manager -n cert-manager --timeout=300s
        kubectl wait --for=condition=Available deployment/cert-manager-cainjector -n cert-manager --timeout=300s
        kubectl wait --for=condition=Available deployment/cert-manager-webhook -n cert-manager --timeout=300s
    fi

    echo "✅ cert-manager is ready"
}

install_kratix() {
    echo "📦 Installing Kratix platform..."

    kubectl apply -f https://github.com/syntasso/kratix/releases/download/${KRATIX_VERSION}/kratix.yaml

    echo "⏳ Waiting for Kratix platform to be ready..."
    kubectl wait --for=condition=Available deployment/kratix-platform-controller-manager -n ${KRATIX_NAMESPACE} --timeout=300s

    echo "✅ Kratix platform is ready"
}

create_worker_cluster() {
    echo "🔧 Setting up worker cluster configuration..."

    cat <<EOF | kubectl apply -f -
apiVersion: platform.kratix.io/v1alpha1
kind: Destination
metadata:
  name: worker-1
  namespace: default
spec:
  strictMatchLabels: false
EOF

    echo "✅ Worker cluster configured"
}

install_promises() {
    echo "📋 Installing available Promises..."

    if [ -f "mongdb/promise.yaml" ]; then
        echo "Installing MongoDB Promise..."
        kubectl apply -f mongdb/promise.yaml

        if [ -f "mongdb/pipeline-configmap.yaml" ]; then
            kubectl apply -f mongdb/pipeline-configmap.yaml
        fi
    fi

    if [ -f "postgres/promise.yaml" ]; then
        echo "Installing PostgreSQL Promise..."
        kubectl apply -f postgres/promise.yaml
    fi

    echo "✅ Promises installed"
}

verify_installation() {
    echo "🔍 Verifying installation..."

    echo "Kratix Pods:"
    kubectl get pods -n ${KRATIX_NAMESPACE}

    echo -e "\nPromises:"
    kubectl get promises

    echo -e "\nDestinations:"
    kubectl get destinations

    echo "✅ Installation verification complete"
}

show_next_steps() {
    echo ""
    echo "🎉 Kratix installation completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Create resource requests using the examples in the examples/ directory"
    echo "2. Monitor resources: kubectl get all -n default"
    echo "3. Check Promise status: kubectl get promises"
    echo ""
    echo "Example MongoDB request:"
    echo "kubectl apply -f examples/mongodb-request.yaml"
    echo ""
    echo "Example PostgreSQL request:"
    echo "kubectl apply -f postgres/examples/request.yaml"
}

main() {
    check_k3s
    install_cert_manager
    install_kratix
    create_worker_cluster
    install_promises
    verify_installation
    show_next_steps
}

main "$@"