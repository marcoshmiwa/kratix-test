#!/bin/bash

set -euo pipefail

# Read the resource request
RESOURCE=$(cat /kratix/input/object.yaml)

# Extract minimal required values
RESOURCE_NAME=$(echo "$RESOURCE" | yq eval '.spec.name // "mongodb"' -)
NAMESPACE=$(echo "$RESOURCE" | yq eval '.metadata.namespace // "default"' -)

echo "Deploying simple MongoDB: $RESOURCE_NAME"

# Generate simple Deployment with hardcoded minimal values
cat > /kratix/output/mongodb-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${RESOURCE_NAME}
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${RESOURCE_NAME}
  template:
    metadata:
      labels:
        app: ${RESOURCE_NAME}
    spec:
      containers:
      - name: mongodb
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/mongodb:7.0
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_DATABASE
          value: "myapp"
EOF

# Generate simple Service
cat > /kratix/output/mongodb-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${RESOURCE_NAME}-service
  namespace: ${NAMESPACE}
spec:
  type: ClusterIP
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: ${RESOURCE_NAME}
EOF

echo "Simple MongoDB deployment completed!"
