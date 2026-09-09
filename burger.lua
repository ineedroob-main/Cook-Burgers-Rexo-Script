-- the cook burger script
-- by anabis66, v1.0.0

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "Rokburg v1.0",
    Icon = "utensils",
    Author = "Cook Burgers",
    Folder = "CookBurgersHelper",

    Size = UDim2.fromOffset(600, 450),
    MinSize = Vector2.new(500, 350),
    MaxSize = Vector2.new(800, 600),

    ToggleKey = Enum.KeyCode.RightShift,

    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = false,

    KeySystem = {
        Note = "Enter your Panda key to use Cook Burgers.",

        API = {
            {
                Type = "pandadevelopment",
                ServiceId = "c00k",
            },
        },
    },
})

local crateBreaker = false
local cardboardFarm = false
local plateSpam = false
local bellSpam = false
local bellInterval = 0.25
local currentSeat = nil
local spawningForklift = false

local function entities()
    return workspace:FindFirstChild("Entities")
end

local function items()
    local e = entities()
    return e and e:FindFirstChild("Items")
end

local function restaurant()
    return workspace:FindFirstChild("Restaurant")
end

local function character()
    return player.Character
end

local function humanoid()
    local c = character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
    local c = character()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- spamzz

local function getPlateRemote()
    local r = restaurant()
    local dispenser = r and r:FindFirstChild("PlateDispenser")
    local button = dispenser and dispenser:FindFirstChild("DispenserButton")
    local remote = button and button:FindFirstChild("ContextAction")

    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
end

local function getBell()
    local i = items()

    if not i then
        return
    end

    local children = i:GetChildren()

    if #children >= 5 then
        local bell = children[5]

        if bell then
            return bell
        end
    end

    return i:FindFirstChild("Bell")
end

local function getBellRemotes()
    local bell = getBell()

    if not bell then
        return
    end

    local contextAction = bell:FindFirstChild("ContextAction")

    local libs = ReplicatedStorage:FindFirstChild("Libs")
    local events = libs and libs:FindFirstChild("Events")
    local remote = events and events:FindFirstChild("RemoteEvent")

    if contextAction
        and contextAction:IsA("RemoteEvent")
        and remote
        and remote:IsA("RemoteEvent") then

        return contextAction, remote, bell
    end
end

-- cardboard

local function getTrash()
    local r = restaurant()
    local props = r and r:FindFirstChild("Props")
    local trash = props and props:FindFirstChild("Trash")

    if not trash then
        return
    end

    if trash:IsA("BasePart") then
        return trash
    end

    for _, v in ipairs(trash:GetDescendants()) do
        if v:IsA("BasePart") then
            return v
        end
    end
end

local function getOwnedCardboard()
    local i = items()

    if not i then
        return {}
    end

    local result = {}

    for _, v in ipairs(i:GetDescendants()) do
        if v.Name:match("^RemainingCardboard") then
            if v:IsA("BasePart") or v:IsA("Model") then
                table.insert(result, v)
            end
        end
    end

    return result
end

local function moveToTrash(obj, trash)
    if not obj or not obj.Parent or not trash then
        return
    end

    local target = trash.CFrame * CFrame.new(0, 2, 0)

    pcall(function()
        if obj:IsA("BasePart") then
            obj.CFrame = target

        elseif obj:IsA("Model") then
            obj:PivotTo(target)
        end
    end)
end

-- forklift

local function getForklift()
    local e = entities()
    local vehicles = e and e:FindFirstChild("Vehicles")

    if not vehicles then
        return
    end

    local forklift = vehicles:FindFirstChild("Forklift")

    if forklift and forklift.Parent then
        return forklift
    end
end

local function spawnForklift()
    if spawningForklift then
        return
    end

    spawningForklift = true

    local gameplay = workspace:FindFirstChild("Gameplay")
    local shop = gameplay and gameplay:FindFirstChild("Forklifts Shop")
    local panel = shop and shop:FindFirstChild("Forkilfts Panel")
    local button = panel and panel:FindFirstChild("ForkliftButton1")
    local remote = button and button:FindFirstChild("ContextAction")

    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer()
        end)
    end

    for _ = 1, 20 do
        task.wait(0.15)

        local forklift = getForklift()

        if forklift then
            spawningForklift = false
            return forklift
        end
    end

    spawningForklift = false
end

local function getForkliftSeat()
    local forklift = getForklift()

    if not forklift then
        return
    end

    local body = forklift:FindFirstChild("Body")
    local seat = body and body:FindFirstChild("Seat")

    if seat and (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
        return seat
    end

    local chassis = forklift:FindFirstChild("Chassis")
    local vehicleSeat = chassis and chassis:FindFirstChild("VehicleSeat")

    if vehicleSeat
        and (vehicleSeat:IsA("Seat") or vehicleSeat:IsA("VehicleSeat")) then

        return vehicleSeat
    end

    for _, v in ipairs(forklift:GetDescendants()) do
        if v:IsA("VehicleSeat") or v:IsA("Seat") then
            return v
        end
    end
end

local function enterForklift()
    local h = humanoid()
    local r = root()

    if not h or not r then
        return
    end

    local forklift = getForklift()

    if not forklift then
        forklift = spawnForklift()
    end

    if not forklift then
        return
    end

    local seat = getForkliftSeat()

    if not seat then
        task.wait(0.5)
        seat = getForkliftSeat()
    end

    if not seat then
        return
    end

    if h.SeatPart == seat then
        currentSeat = seat
        return seat
    end

    for _ = 1, 4 do
        if not seat.Parent then
            seat = getForkliftSeat()

            if not seat then
                return
            end
        end

        pcall(function()
            r.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
        end)

        task.wait(0.2)

        pcall(function()
            seat:Sit(h)
        end)

        task.wait(0.3)

        if h.SeatPart == seat then
            currentSeat = seat
            return seat
        end
    end

    currentSeat = nil
end

local function getCrates()
    local e = entities()
    local vehicles = e and e:FindFirstChild("Vehicles")
    local cargo = vehicles and vehicles:FindFirstChild("Cargo")
    local crate = cargo and cargo:FindFirstChild("Crate")

    if not crate then
        return {}
    end

    local result = {}

    if crate:IsA("BasePart") and crate.Name == "CrateMainPart" then
        table.insert(result, crate)
    end

    for _, v in ipairs(crate:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "CrateMainPart" then
            table.insert(result, v)
        end
    end

    return result
end

local function hitCrate(crate)
    if not crate or not crate.Parent then
        return
    end

    local r = root()
    local h = humanoid()

    if not r or not h then
        return
    end

    if not currentSeat
        or not currentSeat.Parent
        or h.SeatPart ~= currentSeat then

        currentSeat = enterForklift()

        if not currentSeat then
            return
        end
    end

    if not crate.Parent then
        return
    end

    local cf = crate.CFrame

    pcall(function()
        r.CFrame = cf * CFrame.new(-2, -4, 0)
    end)

    task.wait(0.8)
end

--funi tab

local ActionsTab = Window:Tab({
    Title = "Fun",
    Icon = "zap",
})

ActionsTab:Section({
    Title = "Restaurant Actions",
})

ActionsTab:Toggle({
    Title = "Plate Spam",
    Desc = "Spams the plate dispenser",
    Value = false,

    Callback = function(value)
        plateSpam = value

        if value then
            task.spawn(function()
                while plateSpam do
                    local remote = getPlateRemote()

                    if remote then
                        pcall(function()
                            remote:FireServer()
                        end)
                    end

                    task.wait(0.15)
                end
            end)
        end
    end,
})

ActionsTab:Slider({
    Title = "Bell Interval",
    Desc = "Time between each bell interaction",

    Value = {
        Min = 0.05,
        Max = 2,
        Default = 0.25,
    },

    Step = 0.05,

    Callback = function(value)
        bellInterval = tonumber(value) or 0.25
    end,
})

ActionsTab:Toggle({
    Title = "Bell Spam",
    Desc = "Spams the selected bell",
    Value = false,

    Callback = function(value)
        bellSpam = value

        if value then
            task.spawn(function()
                while bellSpam do
                    local contextAction, remote, bell = getBellRemotes()

                    if contextAction and remote and bell then
                        pcall(function()
                            contextAction:FireServer()
                        end)

                        pcall(function()
                            remote:FireServer("interaction", {
                                Object = bell
                            })
                        end)
                    end

                    task.wait(bellInterval)
                end
            end)
        end
    end,
})

-- auto stuf

local AutomationTab = Window:Tab({
    Title = "Auto",
    Icon = "bot",
})

AutomationTab:Section({
    Title = "Cardboard",
})

AutomationTab:Toggle({
    Title = "Cardboard Farm",
    Desc = "Moves cardboard to trash (PATCHED)",
    Value = false,

    Callback = function(value)
        cardboardFarm = value

        if value then
            task.spawn(function()
                while cardboardFarm do
                    local trash = getTrash()

                    if trash then
                        local cardboard = getOwnedCardboard()

                        for _, obj in ipairs(cardboard) do
                            if not cardboardFarm then
                                break
                            end

                            if obj and obj.Parent then
                                moveToTrash(obj, trash)
                            end

                            task.wait(0.2)
                        end
                    end

                    task.wait(0.5)
                end
            end)
        end
    end,
})

AutomationTab:Section({
    Title = "Ratzooka Farming",
})

AutomationTab:Toggle({
    Title = "Crate Breaker",
    Desc = "Uses the forklift to break crates",
    Value = false,

    Callback = function(value)
        crateBreaker = value

        if value then
            task.spawn(function()
                while crateBreaker do
                    local crates = getCrates()

                    if #crates == 0 then
                        task.wait(1)
                        continue
                    end

                    local h = humanoid()

                    if not h then
                        task.wait(1)
                        continue
                    end

                    if not currentSeat
                        or not currentSeat.Parent
                        or h.SeatPart ~= currentSeat then

                        currentSeat = enterForklift()
                    end

                    if not currentSeat then
                        task.wait(1)
                        continue
                    end

                    for _, crate in ipairs(crates) do
                        if not crateBreaker then
                            break
                        end

                        if crate and crate.Parent then
                            pcall(function()
                                hitCrate(crate)
                            end)
                        end

                        task.wait(0.35)
                    end

                    task.wait(0.75)
                end
            end)
        end
    end,
})

-- tps and stuff

local TeleportsTab = Window:Tab({
    Title = "Teleports & Potions",
    Icon = "map-pin",
})

TeleportsTab:Section({
    Title = "Teleports",
})

TeleportsTab:Button({
    Title = "Restaurant",
    Desc = "Teleport to the restaurant",

    Callback = function()
        local r = root()

        local restaurantFolder = workspace:FindFirstChild("Restaurant")
        local tables = restaurantFolder and restaurantFolder:FindFirstChild("Tables")
        local frontSeats = tables and tables:FindFirstChild("FrontSeats")
        local part = frontSeats and frontSeats:FindFirstChild("Part")

        if r and part and part:IsA("BasePart") then
            r.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

TeleportsTab:Button({
    Title = "Sewer",
    Desc = "Teleport to the sewer",

    Callback = function()
        local r = root()

        local terrain = workspace:FindFirstChild("Terrain")
        local sewers = terrain and terrain:FindFirstChild("Sewers")
        local parts = sewers and sewers:FindFirstChild("Parts")

        if r and parts then
            local children = parts:GetChildren()
            local sewerPart = children[14]

            if sewerPart and sewerPart:IsA("BasePart") then
                r.CFrame = sewerPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end,
})

TeleportsTab:Button({
    Title = "SuperMarket",
    Desc = "Teleport to the supermarket",

    Callback = function()
        local r = root()

        local gameplay = workspace:FindFirstChild("Gameplay")
        local supermarket = gameplay and gameplay:FindFirstChild("Supermarket")
        local building = supermarket and supermarket:FindFirstChild("Building")
        local floor = building and building:FindFirstChild("Floor")
        local model = floor and floor:FindFirstChild("Model")
        local part = model and model:GetChildren()[98]

        if r and part and part:IsA("BasePart") then
            r.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

TeleportsTab:Button({
    Title = "Bank",
    Desc = "Teleport to the bank",

    Callback = function()
        local r = root()

        local gameplay = workspace:FindFirstChild("Gameplay")
        local bank = gameplay and gameplay:FindFirstChild("Bank")
        local folder = bank and bank:FindFirstChild("Folder")
        local part = folder and folder:GetChildren()[60]

        if r and part and part:IsA("BasePart") then
            r.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

TeleportsTab:Section({
    Title = "Potions",
})

TeleportsTab:Button({
    Title = "Become a Rat",
    Desc = "Become a rat",

    Callback = function()
        local i = items()
        local potion = i and i:FindFirstChild("Potion")
        local remote = potion and potion:FindFirstChild("ContextAction")

        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end,
})

TeleportsTab:Button({
    Title = "Become a Cat",
    Desc = "become cat :D (DOESNT WORK ALL THE TIME)",

    Callback = function()
        local i = items()
        local potion = i and i:FindFirstChild("CatPotion")
        local remote = potion and potion:FindFirstChild("ContextAction")

        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end,
})

TeleportsTab:Button({
    Title = "Teleport All Potions",
    Desc = "to you, other people cant see",

    Callback = function()
        local i = items()
        local r = root()

        if not i or not r then
            return
        end

        for _, potion in ipairs(i:GetChildren()) do
            if potion.Name == "Potion" or potion.Name == "CatPotion" then
                pcall(function()
                    if potion:IsA("BasePart") then
                        potion.CFrame = r.CFrame

                    elseif potion:IsA("Model") then
                        potion:PivotTo(r.CFrame)
                    end
                end)
            end
        end
    end,
})

-- misc

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "settings",
})

MiscTab:Button({
    Title = "Stop All Actions",
    Desc = "Stops every automation",

    Callback = function()
        plateSpam = false
        bellSpam = false
        cardboardFarm = false
        crateBreaker = false
        currentSeat = nil
        spawningForklift = false
    end,
})

MiscTab:Button({
    Title = "Destroy UI",
    Desc = "Closes the menu",

    Callback = function()
        plateSpam = false
        bellSpam = false
        cardboardFarm = false
        crateBreaker = false
        currentSeat = nil
        spawningForklift = false

        pcall(function()
            Window:Destroy()
        end)
    end,
})

MiscTab:Section({
    Title = "Discord",
})

MiscTab:Button({
    Title = "discord.gg/6jbrYXBuqT",
    Desc = "Click to copy the Discord invite",

    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/6jbrYXBuqT")
        end
    end,
})


player.CharacterAdded:Connect(function()
    currentSeat = nil
end)
