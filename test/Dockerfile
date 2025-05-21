FROM alvdef/lambda-luajit-runtime:latest

RUN luarocks install luasocket

# Add your custom packages and dependencies here
COPY handler.lua ${LAMBDA_TASK_ROOT}/handler.lua
