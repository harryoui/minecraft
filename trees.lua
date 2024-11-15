-- Field Size X (front)
FIELD_X = 8
-- Field Size Y (right) EVEN VALUES ONLY
FIELD_Y = 8

-- How long to sleep between Harvesting
SLEEP_TIME = 60 -- 1 Minute

-- Instance variables
currentTree = 0
fuelOnStart = 0

function refuel_if_needed()
    if (turtle.getFuelLevel() < 5) then
        print("Refueling " .. turtle.getFuelLevel() .. "/80")
        turtle.select(1)
        turtle.refuel(1)
    end
end

function is_front_wood()
    local success, block = turtle.inspect()
    if success then
        return string.find(block.name, "minecraft:log") or string.find(block.name, "minecraft:leaves") 
    end
    return false
end

function forward(count)
    if count == nil then
        count = 1
    end
    for i = 1, count, 1 do
        turtle.select(3)
        if (is_front_wood()) then
            turtle.dig()
        end

        refuel_if_needed()
        turtle.forward()
    end
end

function plant()
    local item = turtle.getItemDetail(2)  -- Get the item details in slot 2
    if item and string.find(item.name, "sapling") then  -- Check if item exists and contains "sapling" in the name
        turtle.select(2)
        turtle.placeDown()
    else
        print("Slot 2 does not contain a sapling.")
        -- TODO: We should return home from here!
    end
end

function fell()
    -- Chop down the tree directly infront of the turtle
    -- Then return to the original place
    if (is_front_wood()) then
        turtle.dig()
    end
    refuel_if_needed()
    turtle.forward()
    turtle.digDown()
    ups = 0
    while (turtle.detectUp()) do
        _, block = turtle.inspectUp()
        if (block.name ~= "minecraft:log") then
            break
        end
        turtle.digUp()
        refuel_if_needed()
        turtle.up()
        ups = ups + 1
    end
    for i = ups, 1, -1 do
        refuel_if_needed()
        if (turtle.detectDown()) then
            turtle.digDown() -- Incase a tree grew
        end
        turtle.down()
    end
    refuel_if_needed()
    print("Harvested " .. (ups + 2) .. " logs")
end

function move()

    -- Check if there is a tree in front of the turtle
    if (turtle.detect()) then
        -- Move forward and fell the tree
        print("Tree " .. currentTree .. " exists. Harvesting...")
        fell()
    else
        -- Move the turtle forward
        turtle.forward()
    end

    -- Check the new block beneath us and perform action
    local success, block = turtle.inspectDown()  -- Inspect the block below the turtle
    if success then
        -- There is a block underneath us
        if string.find(block.name, "minecraft:sapling") then
            print("Tree " .. currentTree .. " is a sapling. Ignoring.")
        elseif string.find(block.name, "minecraft:log") then
            print("Tree " .. currentTree .. " is wood. Replacing with sapling.")
            turtle.digDown()
            plant()
        else
            print("Block below is not wood or sapling.")
            -- Leave untouched
        end
    else
        -- No block below to inspect
        print("Planting sapling for tree " .. currentTree .. ".")
        plant()
    end
end

function moveRow(y)
    evenRow = math.fmod(y, 2) == 0
    print("Switching Rows")
    forward()
    if (evenRow) then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    forward()
    if (evenRow) then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

function emptyInventory()
    print("Emptying entire inventory")
    for i = 1, 16, 1 do
        turtle.select(i)
        cnt = turtle.getItemCount(i)
        if (cnt > 1) then
            print("Dropping " .. cnt .. " Items")
        end
        -- Can only drop 16 items at a time
        local num_loops = math.ceil(cnt / 16)
        for x = 1, num_loops do
            print("Dropped " .. x .. "/" .. num_loops)
            turtle.dropDown()
        end
    end
end

function restockInventory()
    print("Getting fuel")
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.select(1)
    turtle.suck(64)

    print("Getting saplings")
    turtle.up()
    turtle.select(2)
    turtle.suck(64)

    print("Returning")
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
end

function return_to_start()
    print("Returning to start")
    forward()
    turtle.turnRight()
    forward(1 * (FIELD_Y - 1))
    turtle.turnRight()
end

function main()
    emptyInventory()
    restockInventory()
    refuel_if_needed()

    for y = 1, FIELD_Y, 1 do
        print("On Row " .. y)
        for x = 1, FIELD_X, 1 do
            move()
        end
        if (y ~= FIELD_Y) then
            moveRow(y)
        end
    end

    return_to_start()    
    emptyInventory()

    fuel = turtle.getFuelLevel()
    usedFuel = fuelOnStart - fuel
    print("Used " .. usedFuel .. " fuel (" .. fuelOnStart .. " -> " .. fuel .. ")")
end

while true do
    main()
    print("Sleeping for " .. SLEEP_TIME .. " seconds")
    os.sleep(SLEEP_TIME)
end