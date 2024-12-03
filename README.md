# LuaJIT AWS Lambda Custom Runtime

## Project Overview

This project provides a custom runtime for running LuaJIT applications on AWS Lambda using container images. The runtime allows you to execute Lua code directly in the AWS Lambda serverless compute environment.

## Prerequisites

- AWS CLI
- Docker
- AWS Account
- ECR Repository

## Quick Start

### 1. Build Docker Image

```bash
docker build -t <your-ecr-repository-uri>:latest .
```

### 2. Authenticate Docker with ECR

```bash
aws ecr get-login-password --region <your-region> --profile <your-profile> | \
docker login --username AWS --password-stdin <your-ecr-repository-uri>
```

### 3. Push Image to ECR

```bash
docker push <your-ecr-repository-uri>:latest
```

### 4. Create/Update Lambda Function

Use the AWS Console or AWS CLI to create a new Lambda function using the pushed container image.

## Runtime Behavior

- Expects a `handler.lua` file as the main execution point
- Uses LuaJIT 2.1 as the runtime environment
- Supports standard Lambda invocation lifecycle
- Captures and reports stdout, stderr, and exit codes

## Customization

Modify the `handler.lua` file to implement your specific Lambda function logic.
