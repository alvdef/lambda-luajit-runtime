# Use Amazon Linux 2 as the base image
FROM public.ecr.aws/lambda/provided:al2

# Install build dependencies
RUN yum update -y && \
    yum install -y \
    gcc \
    make \
    git

# Install LuaJIT
WORKDIR /tmp
RUN git clone https://luajit.org/git/luajit.git \
    && cd luajit \
    && make \
    && make install PREFIX=/usr/local

# Set up LuaJIT environment variables
ENV LUA_PATH="/usr/local/share/luajit-2.1/?.lua;./?.lua"
ENV LUA_CPATH="/usr/local/lib/lua/5.1/?.so;./?.so"
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1

COPY bootstrap /var/runtime/
RUN chmod +x /var/runtime/bootstrap

# Copy your Lambda function files
COPY handler.lua ${LAMBDA_TASK_ROOT}/

ENV ENTRYPOINT="/var/runtime/bootstrap"

CMD [ "handler" ]
