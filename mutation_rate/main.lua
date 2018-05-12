local widget = require "widget"

total_sum = 1000 -- 총 합

population_num = 10 -- 한 세대에서 생성할 개체 수
mutation_rate = 0.2 -- 변이 확률

generation = 1 -- 세대 표시
max_generation = 100

population = {}

max_population = {}
max_population[0] = 0

function initial_population_generation()
    local rate = {}
    for i = 1, population_num, 1 do

        rate[1] = math.random(1, 1000)
        rate[2] = math.random(1, 1000)
        rate[3] = math.random(1, 1000)
        rate[4] = math.random(1, 1000)

        population[i] = {}

        population[i][1] = math.floor( total_sum / ( rate[1] + rate[2] + rate[3] + rate[4] ) * rate[1] )
        population[i][2] = math.floor( total_sum / ( rate[1] + rate[2] + rate[3] + rate[4] ) * rate[2] )
        population[i][3] = math.floor( total_sum / ( rate[1] + rate[2] + rate[3] + rate[4] ) * rate[3] )
        population[i][4] = total_sum - ( population[i][1] + population[i][2] + population[i][3] )

        table.sort( population[i], function ( a, b ) return a < b end )

    end
end

function evaluation()
    --print( "\n\ngeneration : " .. generation )

    for i = 1, population_num, 1 do
        population[i][0] = math.sqrt(population[i][1] * population[i][2] * population[i][3] * population[i][4])

    end

    table.sort( population, function( a, b ) return a[0] > b[0] end )

    for i = 1, population_num, 1 do
        --print( string.format("%s%2d %s %4d %4d %4d %4d %s %f", "No.", i, "value :", population[i][1], population[i][2], population[i][3], population[i][4], " value : ", population[i][0] ))
    end

    if population[1][0] > max_population[0] then
        max_population = population[1]
    end

    --print( string.format("%s%2d%s%4d %3d %3d %3d %s %f", "generation : ", generation, " best : ", max_population[1], max_population[2], max_population[3], max_population[4], "suit :", max_population[0] ) )
    if generation % 10 == 0 then print( string.format("%f", max_population[0] ) ) end
end

function selection_crossover_mutation()
    -- select parent
    local limit = 1
    for i = 1, population_num, 1 do
        if population[i][0] * 1.1 >= max_population[0] then
            limit = i
        end
    end

    if i == 1 then i = math.random( 1, population_num * 0.5 ) end

    local p1, p2

    --crossover
    for j = limit+1, population_num, 1 do
        while 1 do
            p1, p2 = population[ math.random(1, limit) ], population[ math.random(1, limit) ]

            if p1[0] ~= p2[0] then break end
        end

        population[j][1] = p1[1]
        population[j][2] = p2[2]
        population[j][3] = p1[3] > p2[3] and p1[3] or p2[3]
        if population[j][1] + population[j][2] + population[j][3] > total_sum then
            population[j][3] = total_sum - ( population[j][1] + population[j][2] ) * 0.6
        end
        population[j][4] = total_sum - ( population[j][1] + population[j][2] + population[j][3] )

    end


    --mutation
    for i = 1, population_num, 1 do
        local n = math.random()

        if n > mutation_rate then
            n = math.random(1, 3)

            change = math.floor( population[i][n] *  ( math.random(0, 1) and 1 or -1 ) * mutation_rate * 0.5 )

            population[i][n] = population[i][n] + change

            for j = n+1, 4, 1 do
                if j == 4 then population[i][j] = total_sum - ( population[i][1] + population[i][2] + population[i][3] ) end
                population[i][j] = population[i][j] - math.floor( change / ( 4 - n ) )
            end
        end
        table.sort( population[i], function ( a, b ) return a < b end )
    end
end

function onButton( e )
    if e.phase == "ended" then


        while generation ~= max_generation + 1 do
            if generation == 1 then
                initial_population_generation()
            else
                selection_crossover_mutation()
            end

            evaluation()
            generation = generation + 1
        end
    end
end

function main()
    button = widget.newButton(
    {
        x = display.contentWidth * 0.5,
        y = display.contentHeight * 0.5,
        id = "button",
        label = "generate!",
        onEvent = onButton,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.75 } }
    } )
end

main()
