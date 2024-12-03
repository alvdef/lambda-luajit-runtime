math.randomseed(os.time())

function montecarloPi()
    local insideCircle = 0
    local totalPoints = 0
    local startTime = os.time()
    local duration = 1 * 60

    print("Iniciando cálculo de Montecarlo para estimar Pi durante 1 minutos...")

    while os.time() - startTime < duration do
        local x = math.random()
        local y = math.random()

        if x * x + y * y <= 1 then
            insideCircle = insideCircle + 1
        end

        totalPoints = totalPoints + 1
    end

    local estimatedPi = 4 * (insideCircle / totalPoints)
    return estimatedPi, totalPoints
end

local estimatedPi, totalPoints = montecarloPi()
print(string.format("Estimación de Pi: %.6f", estimatedPi))
print(string.format("Total de puntos generados: %d", totalPoints))
