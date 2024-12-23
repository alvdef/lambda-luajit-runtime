local json = require("cjson")

math.randomseed(os.time())

function montecarloPi(iterations)
    local insideCircle = 0
    local totalPoints = iterations or 1000000

    for i = 1, totalPoints do
        local x = math.random()
        local y = math.random()

        if x * x + y * y <= 1 then
            insideCircle = insideCircle + 1
        end
    end

    local estimatedPi = 4 * (insideCircle / totalPoints)
    return estimatedPi, totalPoints
end

-- Get event data from command line argument
local eventData = json.decode(arg[1])

-- Use iterations from event data if provided, otherwise use default
local iterations = eventData.iterations or nil
local estimatedPi, totalPoints = montecarloPi(iterations)

-- Prepare response
local response = {
    estimatedPi = estimatedPi,
    totalPoints = totalPoints,
    input = eventData
}

-- Print response as JSON
print(json.encode(response))