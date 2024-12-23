# LuaJIT AWS Lambda Custom Runtime

## Project Overview

This project provides a custom runtime for running LuaJIT applications on AWS Lambda using container images. The runtime allows you to execute Lua code directly in the AWS Lambda serverless compute environment.

## Prerequisites

- AWS CLI
- Docker
- AWS Account

## Quick Start

### 1. Use as Base Image

```dockerfile
FROM alvdef/lambda-luajit-runtime:latest

# Add your custom packages and dependencies here
COPY your-handler.lua ${LAMBDA_TASK_ROOT}/handler.lua
```

### 2. Installing Lua Packages

The runtime supports installing Lua packages. Here's how to add common packages:

```dockerfile
# Install LuaRocks packages
RUN luarocks install <package-name>
```

### 3. Build Docker Image

```bash
docker build -t <your-ecr-repository-uri>:latest .
```

### 4. Authenticate Docker with ECR

```bash
aws ecr get-login-password --region <your-region> --profile <your-profile> | \
docker login --username AWS --password-stdin <your-ecr-repository-uri>
```

### 5. Push Image to ECR

```bash
docker push <your-ecr-repository-uri>:latest
```

### 6. Create/Update Lambda Function

Use the AWS Console or AWS CLI to create a new Lambda function using the pushed container image.

## Runtime Behavior

- Uses LuaJIT 2.1 as the runtime environment
- Supports standard Lambda invocation lifecycle
- Captures and reports stdout, stderr, and exit codes
- Includes ``lua-cjson`` lua package (for JSON processing)


## Handler Implementation

Your `handler.lua` must process the event data passed by the Lambda runtime. The runtime provides the event as a JSON string in the first command line argument (`arg[1]`). See the included `handler.lua` for a complete example that demonstrates:

```lua
-- Event data is available in arg[1]
local event = arg[1] or "{}"

-- Parse JSON event data
local event_data = cjson.decode(event)

-- Process and return JSON response
local response = { statusCode = 200, body = "Hello" }
print(cjson.encode(response))
```

## Customization

Modify the `handler.lua` file to implement your specific Lambda function logic. The handler receives the event data as a JSON string and should return a JSON-compatible string.