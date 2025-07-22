# Kratix MongoDB Promise

This repository contains a simple Kratix Promise and Pipeline to deploy MongoDB instances with minimal configuration.

## Structure

- `promise.yaml` - The Kratix Promise definition for MongoDB
- `pipeline/` - Contains the pipeline scripts
- `examples/` - Example resource requests

## Usage

1. Apply the Pipeline ConfigMap:
   ```bash
   kubectl apply -f pipeline-configmap.yaml
   ```

2. Apply the Promise to your Kratix platform:
   ```bash
   kubectl apply -f promise.yaml
   ```

3. Create a MongoDB instance:
   ```bash
   kubectl apply -f examples/mongodb-request.yaml
   ```

## Promise Features

- **Minimal Configuration**: Only requires a name
- **Fixed Settings**: 
  - MongoDB 7.0
  - No authentication
  - ClusterIP service
  - Basic "myapp" database
- **Simple Deployment**: Just a Deployment and Service
