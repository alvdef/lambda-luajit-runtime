# Use Amazon Linux 2 as the base image
FROM public.ecr.aws/lambda/provided:al2

# Install build dependencies
RUN yum update -y && \
    yum install -y \
    gcc \
    wget \
    unzip \
    tar \
    make \
    git

# Install LuaJIT
WORKDIR /tmp
RUN git clone https://luajit.org/git/luajit.git \
    && cd luajit \
    && make \
    && make install PREFIX=/usr/local

# Set up LuaJIT environment variables
ENV LUA_PATH="/usr/local/share/luajit-2.1/?.lua;./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua"
ENV LUA_CPATH="/usr/local/lib/lua/5.1/?.so;./?.so"
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1


# Install LuaRocks for package management
WORKDIR /tmp
RUN wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz \
    && tar zxpf luarocks-3.9.2.tar.gz \
    && cd luarocks-3.9.2 \
    && ./configure --with-lua-include=/usr/local/include/luajit-2.1 \
    && make \
    && make install

# Install Lua CJSON (example of manual installation)
WORKDIR /tmp
RUN git clone https://github.com/openresty/lua-cjson.git \
    && cd lua-cjson \
    && make \
        LUA_INCLUDE_DIR=/usr/local/include/luajit-2.1 \
        CFLAGS="-I/usr/local/include/luajit-2.1" \
        LJLIB_FLAGS="-L/usr/local/lib" \
    && make install \
        LUA_INCLUDE_DIR=/usr/local/include/luajit-2.1 \
        LUA_LIB_DIR=/usr/local/lib/lua/5.1

COPY bootstrap /var/runtime/
RUN chmod +x /var/runtime/bootstrap

# Copy your Lambda function files
COPY handler.lua ${LAMBDA_TASK_ROOT}/

ENV ENTRYPOINT="/var/runtime/bootstrap"

RUN yum remove -y \
    wget \
    tar \
    git \
    && yum clean all \
    && rm -rf /var/cache/yum


# Label the image
LABEL maintainer="Álvaro de Francisco <alvdef@gmail.com>"
LABEL version="1.0"
LABEL description="LuaJIT runtime for AWS Lambda with pre-installed packages"

CMD [ "handler" ]