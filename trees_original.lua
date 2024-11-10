-- ARCADIA HOLZIHOLZ
-- plants and hervests trees

-- HOW TO
-- Slot 1: Fuel
-- Slot 2: Saplings
-- Place Turtle 1 block above ground

-- VERSION
-- 1.0.0 Initial Release

-- Starting Space
SPACE_START = 6
-- Space between Trees
SPACE = 1

-- Field Size X (front)
FIELD_X = 16
-- Field Size Y (right) EVEN VALUES ONLY
FIELD_Y = 16

-- How long to sleep between Harvesting
SLEEP_TIME = 300 -- 5 minutes

-- Min Fuel needed to run
MIN_FUEL = FIELD_X * FIELD_Y * (SPACE * 2 + 10)
currentTree = 0
fuelOnStart = 0
function refuel()
    print("Need " .. MIN_FUEL .. "fuel")
    while (turtle.getFuelLevel() < MIN_FUEL) do
        print("Refueling " .. turtle.getFuelLevel() .. "/" .. MIN_FUEL)
        turtle.select(1)
        turtle.refuel(1)
        sleep(1)
    end
    fuelOnStart = turtle.getFuelLevel()
end

function checkSaplings()
    saplings = 0
    maxNeededSaplings = 999
    okayValue = 999
    while (saplings < okayValue) do
        saplings = turtle.getItemCount(2)
        maxNeededSaplings = 16 -- FIELD_X * FIELD_Y
        okayValue = maxNeededSaplings / 2
        print("Got " .. saplings .. "/" .. maxNeededSaplings .. " saplings (min: " .. okayValue .. ")")
        sleep(1)
    end
end

function move()
    currentTree = currentTree + 1
    forward(SPACE - 1)
    if (turtle.detect()) then
        print("Tree " .. currentTree .. " exists. Harvesting...")
        fell()
    end
    turtle.forward()
    --if (turtle.detectDown()) then
    --    print("Tree " .. currentTree .. " is a sapling. Ignoring")
    --end
    -- start check down
    local success, block = turtle.inspectDown()  -- Inspect the block below the turtle

    if success then
        if string.find(block.name, "minecraft:sapling") then
            print("Tree " .. currentTree .. " is a sapling. Ignoring.")
        elseif string.find(block.name, "minecraft:log") then
            print("Tree " .. currentTree .. " is wood. Triggering fell.")
            fell()  -- Call the fell function to cut the tree
        else
            print("Block below is not wood or sapling.")
        end
    else
        print("No block below to inspect.")
    end
    --- end check down
    if (turtle.detectDown() == false) then
        print("Tree " .. currentTree .. " is empty. Set sapling")
        plant()
    end
end

function plant()
    local item = turtle.getItemDetail(2)  -- Get the item details in slot 2
    if item and string.find(item.name, "sapling") then  -- Check if item exists and contains "sapling" in the name
        turtle.select(2)
        turtle.placeDown()
    else
        print("Slot 2 does not contain a sapling.")
    end
end

function fell()
    turtle.dig()
    turtle.forward()
    turtle.digDown()
    ups = 0
    while (turtle.detectUp()) do
        _, block = turtle.inspectUp()
        if (block.name == "minecraft:dirt") then
            break
        end
        turtle.digUp()
        turtle.up()
        ups = ups + 1
    end
    for i = ups, 1, -1 do
        turtle.down()
    end
    turtle.back()
    print("Harvested " .. (ups + 2) .. " logs")
end

function forward(count)
    for i = 1, count, 1 do
        turtle.select(3)
        if (turtle.detect()) then
            turtle.dig()
        end
        turtle.forward()
    end
end

function moveRow(y)
    evenRow = math.fmod(y, 2) == 0
    print("Switching Rows")
    forward(SPACE)
    if (evenRow) then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    forward(SPACE)
    if (evenRow) then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

function gotoStart()
    print("Goto start")
    forward(SPACE)
    turtle.turnRight()
    forward(SPACE * (FIELD_Y - 1))
    turtle.turnRight()
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
    turtle.suck(16)

    print("Getting saplings")
    turtle.up()
    turtle.select(2)
    turtle.suck(16)

    print("Returning")
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
end

function main()
    emptyInventory()
    if (turtle.getFuelLevel() > 0) then
        restockInventory()
    end
    refuel()
    checkSaplings()
    for y = 1, FIELD_Y, 1 do
        print("On Row " .. y)
        for x = 1, FIELD_X, 1 do
            move()
        end
        if (y ~= FIELD_Y) then
            moveRow(y)
        end
    end

    gotoStart()
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