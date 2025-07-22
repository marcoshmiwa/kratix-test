# MongoDB Kratix Promise Deployment Guide

## Prerequisites

- Kratix platform installed and running
- kubectl configured to access your Kratix cluster

## Installation Steps

### 1. Deploy the Pipeline ConfigMap

First, apply the pipeline configuration:

```bash
kubectl apply -f pipeline-configmap.yaml
```

### 2. Deploy the Promise

Apply the MongoDB Promise to your Kratix platform:

```bash
kubectl apply -f promise.yaml
```

### 3. Verify the Promise Installation

Check if the Promise is installed correctly:

```bash
kubectl get promises
kubectl get crd mongodbs.example.promise.syntasso.io
```

## Usage

### Creating a MongoDB Instance

Use one of the example configurations to create a MongoDB instance:

#### Full-featured MongoDB with authentication:
```bash
kubectl apply -f examples/mongodb-request.yaml
```

#### Basic MongoDB without authentication:
```bash
kubectl apply -f examples/mongodb-basic.yaml
```

### Monitoring the Deployment

Check the status of your MongoDB request:

```bash
kubectl get mongodb
kubectl describe mongodb my-mongodb
```

Monitor the pipeline execution:

```bash
kubectl get pipelines
kubectl logs -l kratix.io/pipeline-name=mongodb-resource-configure
```

### Accessing MongoDB

Once deployed, you can access MongoDB using the generated service:

1. **With authentication enabled**: Get credentials from the secret:
   ```bash
   kubectl get secret my-mongodb-mongodb-secret -o yaml
   ```

2. **Connection string**: Use the connection string from the status:
   ```bash
   kubectl get mongodb my-mongodb -o jsonpath='{.status.connectionString}'
   ```

3. **Port forwarding for local access**:
   ```bash
   kubectl port-forward svc/my-mongodb-mongodb-service 27017:27017
   ```

## Configuration Options

The MongoDB Promise supports the following configuration options:

- `version`: MongoDB version (5.0, 6.0, 7.0)
- `storageSize`: Persistent storage size (e.g., "10Gi", "20Gi")
- `serviceType`: Kubernetes service type (ClusterIP, NodePort, LoadBalancer)
- `enableAuth`: Enable/disable MongoDB authentication
- `databaseName`: Initial database name
- `resources`: CPU and memory requests/limits

## Troubleshooting

### Check Pipeline Logs
```bash
kubectl logs -l kratix.io/pipeline-name=mongodb-resource-configure
```

### Check MongoDB Pod Status
```bash
kubectl get pods -l app=my-mongodb-mongodb
kubectl logs deployment/my-mongodb-mongodb
```

### Verify Persistent Volume
```bash
kubectl get pvc
kubectl describe pvc my-mongodb-mongodb-pvc
```

## Cleanup

To remove a MongoDB instance:

```bash
kubectl delete mongodb my-mongodb
```

To remove the Promise:

```bash
kubectl delete promise mongodb
kubectl delete configmap mongodb-pipeline-scripts
```
