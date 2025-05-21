local json = require("cjson")
local http = require("socket.http")

math.randomseed(os.time())

-- Get event data from command line argument
local eventData = json.decode(arg[1])

-- Perform a simple HTTP request using luasocket
local response_body = {}
local res, code, response_headers = http.request{
    url = "http://httpbin.org/get",
    sink = ltn12.sink.table(response_body)
}

-- Prepare response
local response = {
    input = eventData,
    httpResponse = {
        status = code,
        body = table.concat(response_body)
    }
}

-- Print response as JSON
print(json.encode(response))