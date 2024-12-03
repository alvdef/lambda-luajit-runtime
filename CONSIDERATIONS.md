# LuaJIT AWS Lambda Custom Runtime - Implementation Guide

## Architecture Overview

The custom runtime is implemented through three primary components:
1. Dockerfile
2. Bootstrap script
3. Handler script

AWS Lambda uses a containerized, multi-stage execution model:

1. **Container Initialization**
   - Lambda creates a container based on your specified image
   - Mounts necessary volumes and sets up networking
   - Prepares the execution environment

2. **Runtime Initialization**
   - Looks for the `bootstrap` file as the entry point
   - Executes the bootstrap script with specific environment variables
   - Runs any global/static initialization code

3. **Event Processing**
   - Continuously polls for incoming events
   - Manages function invocations
   - Handles response and error reporting


### Dockerfile

#### Base Image
- Uses Amazon Linux 2 as the base (`public.ecr.aws/lambda/provided:al2`)
- Provides a minimal, Lambda-compatible environment

#### Build Steps
- Installs build dependencies (gcc, make, git)
- Compiles and installs LuaJIT from source
- Sets up LuaJIT environment variables
- Copies bootstrap script and sets execution permissions
- Sets default handler and entrypoint

### Runtime Interface Detailed Breakdown

#### Initialization Tasks

When Lambda starts your runtime, it sets critical environment variables:

- `_HANDLER`: Specifies the entry point (e.g., `handler.method`)
- `LAMBDA_TASK_ROOT`: Root directory of function code
- `AWS_LAMBDA_RUNTIME_API`: Endpoint for runtime API interactions


#### Event Processing API Interactions

The runtime interacts with Lambda through a RESTful API:

1. **Get Next Invocation**
   ```sh
   EVENT_DATA=$(curl -sS -LD "$HEADERS" "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
   ```
   - Blocks until an event is available
   - Returns event data and HTTP headers
   - Extracts request ID and trace information

2. **Trace Propagation**
   ```sh
   TRACE_ID=$(grep -Fi Lambda-Runtime-Trace-Id "$HEADERS" | tr -d '\r' | awk -F: '{print $2}' | xargs)
   export _X_AMZN_TRACE_ID="${TRACE_ID}"
   ```
   - Enables distributed tracing across services
   - Sets X-Ray trace context

3. **Response Reporting**
   ```sh
   # Successful response
   curl -sS -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response" \
        -d "$RESPONSE"

   # Error reporting
   log_invocation_error "Handler.ExecutionError" "{\"errorMessage\" : \"$RESPONSE\"}"
   ```
   - Sends function output back to Lambda
   - Reports any execution errors

### Bootstrap's Critical Responsibilities

#### Runtime Contract Enforcement
- Manage the entire invocation lifecycle
- Handle all communication with Lambda runtime API
- Ensure robust error reporting
- Manage resource allocation and cleanup

#### Event Processing Loop
The core of the bootstrap is an infinite processing loop:
1. Retrieve next event
2. Execute handler
3. Capture output
4. Report results
5. Repeat

### Performance and Scaling Considerations

- **Cold Start**: Initialization occurs once per container
- **Warm Starts**: Subsequent invocations reuse the same container
- Bootstrap acts as a lightweight process manager
- Minimal overhead between Lambda and custom runtime
