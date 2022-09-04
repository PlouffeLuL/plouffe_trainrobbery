local Auth = exports.plouffe_lib:Get("Auth")
local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")
local Inventory = exports.plouffe_lib:Get("Inventory")
local Lang = exports.plouffe_lib:Get("Lang")
local Groups = exports.plouffe_lib:Get("Groups")

local items = {}
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local NetworkGetEntityOwner = NetworkGetEntityOwner
local DeleteEntity = DeleteEntity
local GetEntityModel = GetEntityModel

local lastTrain = os.time() + (math.random(60 * 60, 60 * 60 * 4))

function Tr.Init()
    Tr.ValidateConfig()

    if GetResourceState("ooc_core") == "started" then
        items = exports.ox_inventory:Items()
    end

    local dicks = {}

    for k,v in pairs(Tr.Loots) do
        dicks[joaat(k)] = v
    end

    Tr.Loots = dicks

    Server.ready = true
end

function Tr:GetData()
    local retval = {}

    for k,v in pairs(self) do
        if type(v) ~= "function" then
            retval[k] = v
        end
    end

    return retval
end

function Tr.ValidateConfig()
    Tr.startItem = GetConvar("plouffe_trainrobbery:start_item", "")
    Tr.bombItem = GetConvar("plouffe_trainrobbery:bomb_item", "")
    Tr.untilLoot = tonumber(GetConvar("plouffe_trainrobbery:time_until_loot", "")) -- minutes
    Tr.PoliceGroups = json.decode(GetConvar("plouffe_trainrobbery:police_groups", ""))
    Tr.MinCops = tonumber(GetConvar("plouffe_trainrobbery:min_cops", ""))
    Tr.trainInterval = tonumber(GetConvar("plouffe_trainrobbery:train_interval", ""))
    Tr.trainSpeed = tonumber(GetConvar("plouffe_trainrobbery:train_speed", ""))

    if not Tr.startItem then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'start_item' convar. Refer to documentation")
        end
    elseif not Tr.bombItem then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'bomb_item' convar. Refer to documentation")
        end
    elseif not Tr.untilLoot then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'time_until_loot' convar. Refer to documentation")
        end
    elseif not Tr.MinCops then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'min_cops' convar. Refer to documentation")
        end
    elseif not Tr.PoliceGroups or type(Tr.PoliceGroups) ~= "table" then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'police_groups' convar. Refer to documentation")
        end
    elseif not Tr.trainInterval then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'train_interval' convar. Refer to documentation")
        end
    elseif not Tr.trainSpeed or Tr.trainSpeed > 40 or Tr.trainSpeed < 1 then
        while true do
            Wait(1000)
            print("^1 [ERROR] ^0 Invalid configuration, missing 'train_speed' convar. Refer to documentation")
        end
    end

    Tr.trainInterval *= (24 * 60)
    Tr.untilLoot *= 60
    Tr.trainSpeed += 0.0

    return true
end

function Tr.LoadPlayer()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    while not Server.ready do
        Wait(100)
    end

    if registred then
        local data = Tr:GetData()
        data.auth = key
        TriggerClientEvent("plouffe_trainrobbery:getConfig", playerId, data)
    else
        TriggerClientEvent("plouffe_trainrobbery:getConfig", playerId, nil)
    end
end

function Tr:ReleaseTrain()
    local entity = NetworkGetEntityFromNetworkId(self.activeTrain.locomotive)
    local owner = NetworkGetEntityOwner(entity)

    TriggerClientEvent("plouffe_trainrobbery:release_train", owner)

    Wait(2000)

    GlobalState.activeTrain = nil
    self.activeTrain = nil
    self.timeUntilLoot = nil
end

function Tr:SpawnTrain(playerId)
    local coords = vector3(727.43621826172, -2502.4897460938, 11.142425537109)
    local distance = 100

    if not playerId then
        for k,v in pairs (GetPlayers()) do
            local ped = GetPlayerPed(v)
            local pedCoords = GetEntityCoords(ped)
            local dstCheck = #(coords - pedCoords)

            if dstCheck < distance then
                playerId = v
                distance = dstCheck
            end
        end

        if not playerId then
            return
        end
    end

    self:DeleteTrain()

    Callback:ClientCallback(playerId, "plouffe_trainrobbery:spawnTrain", 30, function(trainData)
        if not trainData then
            return
        end

        local entity = NetworkGetEntityFromNetworkId(trainData.locomotive)

        Entity(entity).state:set("speed", tostring(Tr.trainSpeed), true)

        self.activeTrain_state = "active"
        self.activeTrain = trainData

        GlobalState.activeTrain_state = self.activeTrain_state
        GlobalState.activeTrain = self.activeTrain

        self.timeUntilLoot = self.untilLoot

        self:RobberyTimer()

    end, {coords = coords})
end

function Tr:RobberyTimer()
    CreateThread(function()
        local robberyTimer = 60 * 60 * 1
        while robberyTimer > 0 and GlobalState.activeTrain do
            Wait(1000 * 60)
            robberyTimer = robberyTimer - 1
        end

        if GlobalState.activeTrain then
            self:ReleaseTrain()
        end
    end)
end

function Tr:DeleteTrain()
    if not self.activeTrain then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(self.activeTrain.locomotive)
    DeleteEntity(entity)

    for k,v in pairs(self.activeTrain.carriage) do
        entity = NetworkGetEntityFromNetworkId(v)
        DeleteEntity(entity)
    end

    for k,v in pairs(self.activeTrain.props) do
        for x,y in pairs(v) do
            entity = NetworkGetEntityFromNetworkId(y)
            DeleteEntity(entity)
        end
    end

    GlobalState.activeTrain = nil
    self.activeTrain = nil
end

function Tr.ExplodeTrain(authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_trainrobbery:installed_anfo") then
        return
    end

    if not Tr.activeTrain then
        return
    end

    local itemCount = Inventory.Search(playerId, "count", Tr.bombItem, nil)

    if itemCount < 1 then
        return
    end

    Inventory.RemoveItem(playerId, Tr.bombItem, 1)

    local ped = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(ped)

    local train = NetworkGetEntityFromNetworkId(Tr.activeTrain.locomotive)
    local trainCoords = GetEntityCoords(train)

    local distance = #(pedCoords - trainCoords)

    if distance > 200 then
        return
    end

    Entity(train).state:set("explode", "true", true)

    Tr.activeTrain_state = "explode"

    GlobalState.activeTrain_state = "explode"

    CreateThread(function()
        while Tr.timeUntilLoot and Tr.timeUntilLoot > 0 do
            Wait(1000)
            Tr.timeUntilLoot = Tr.timeUntilLoot - 1
        end
    end)
end

function Tr.LootTrain(box, index, authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_trainrobbery:looting_box") then
        return
    end

    if not Tr.activeTrain_state or Tr.activeTrain_state ~= "explode" then
        return
    end

    local prop = Tr.activeTrain.props[index][box]

    if not prop then
        return
    end

    if Tr.timeUntilLoot and Tr.timeUntilLoot > 0 then
        return Utils:Notify(playerId, Lang.train_timeUntilLoot:format(math.ceil(Tr.timeUntilLoot / 60)))
    end

    Tr.activeTrain.props[index][box] = nil

    local propEntity = NetworkGetEntityFromNetworkId(prop)
    local model = GetEntityModel(propEntity)

    local item = Tr.Loots[model][math.random(1, #Tr.Loots[model])]

    if GetResourceState("ooc_core") == "started" then
        Inventory.AddItem(playerId, "blueprint", 1, {weapon = item.name, description = ("Sert a la fabrication de: %s"):format(items[item.name].label)})
    else
        Inventory.AddItem(playerId, item.name, 1)
    end

    if Utils:TableLen(Tr.activeTrain.props[index]) < 1 then
        Tr.activeTrain.props[index] = nil
    else
        Tr.activeTrain.props[index][box] = nil
    end

    DeleteEntity(propEntity)

    if Utils:TableLen(Tr.activeTrain.props) < 1 then
        Tr:ReleaseTrain()
    end
end

function Tr.RequestTrainSpawn(authkey)
    local playerId = source

    if not Auth:Validate(playerId,authkey) or not Auth:Events(playerId,"plouffe_trainrobbery:request_robbery") then
        return
    end

    local itemCount = Inventory.Search(playerId, "count", Tr.startItem, nil)

    if itemCount < 1 then
        return Utils:Notify(playerId, Lang.missing_something)
    end

    local time = os.time()
    local timeLeft = (lastTrain - time) / 60

    if timeLeft > 0 then
        return Utils:Notify(playerId, Lang.train_timeUntilNextTrain:format(math.ceil(timeLeft)))
    end

    local count = 0

    for k,v in pairs(Tr.PoliceGroups) do
        local cops = Groups:GetGroupPlayers(v)
        count += cops.len
    end

    if count < Tr.MinCops then
        return Utils:Notify(playerId, Lang.bank_notEnoughCop)
    end

    lastTrain = time + Tr.trainInterval

    Inventory.RemoveItem(playerId, Tr.startItem, 1)

    Tr:SpawnTrain(playerId)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "plouffe_trainrobbery" then
        Tr:DeleteTrain()
    end
end)

CreateThread(Tr.Init)