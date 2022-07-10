local items = {}
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local NetworkGetEntityOwner = NetworkGetEntityOwner
local DeleteEntity = DeleteEntity
local GetEntityModel = GetEntityModel

local lastTrain = os.time() + (math.random(60 * 60, 60 * 60 * 4))
local trainInterval = 60 * 60 * 24
local minCops = 5

local function tlen(t)
	local retval = 0

	for k,v in pairs(t) do
		retval = retval + 1
	end

	return retval
end

function Tr.Init()
    items = exports.ox_inventory:Items()
    
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

function Tr:SpawnTrain(playerId)
    local coords = vector3(727.43621826172, -2502.4897460938, 11.142425537109)
    local distance = 100
    local playerId = playerId

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
        
        Entity(entity).state:set("speed", "40", true)
        
        self.activeTrain_state = "active"
        self.activeTrain = trainData
        
        GlobalState.activeTrain_state = self.activeTrain_state
        GlobalState.activeTrain = self.activeTrain 

        self.timeUntilLoot = 60 * 10

        self:RobberyTimer()

    end, {coords = coords})
end

function Tr:RobberyTimer()
    CreateThread(function()
        local robberyTimer = 60 * 60 * 1
        while robberyTimer > 0 and GlobalState.activeTrain do
            Wait(1000 * 60)
            robberyTimer = robberyTimer - 1
            -- print(GetEntityCoords(entity))
            -- print(DoesEntityExist(entity))
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

function Tr:ExplodeTrain(playerId)
    if not self.activeTrain then
        return
    end

    local itemCount = exports.ox_inventory:GetItem(playerId, "anfo_bomb", nil, true)
    
    if itemCount < 1 then
        return
    end
    
    exports.ox_inventory:RemoveItem(playerId, "anfo_bomb", 1)
    
    local ped = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(ped)
    
    local train = NetworkGetEntityFromNetworkId(self.activeTrain.locomotive)
    local trainCoords = GetEntityCoords(train)

    local distance = #(pedCoords - trainCoords)
    
    if distance > 200 then
        return
    end

    Entity(train).state:set("explode", "true", true)

    self.activeTrain_state = "explode"

    GlobalState.activeTrain_state = "explode"

    CreateThread(function()
        while self.timeUntilLoot and self.timeUntilLoot > 0 do
            Wait(1000)
            self.timeUntilLoot = self.timeUntilLoot - 1
        end
    end)
end

function Tr:LootTrain(playerId, index, box)
    if not self.activeTrain_state or self.activeTrain_state ~= "explode" then
        return
    end

    local prop = self.activeTrain.props[index][box]

    if not prop then
        return
    end

    if self.timeUntilLoot and self.timeUntilLoot > 0 then
        return Utils:Notify(playerId, ("Il reste %s minutes avant de pouvoir fouiller le train"):format(math.ceil(self.timeUntilLoot / 60)))
    end
    
    self.activeTrain.props[index][box] = nil

    local propEntity = NetworkGetEntityFromNetworkId(prop)
    local model = GetEntityModel(propEntity)

    local item = self.Loots[model][math.random(1, #self.Loots[model])]

    exports.ox_inventory:AddItem(playerId, "blueprint", 1, {weapon = item.name, description = ("Sert a la fabrication de: %s"):format(items[item.name].label)})

    if tlen(self.activeTrain.props[index]) < 1 then
        self.activeTrain.props[index] = nil
    else
        self.activeTrain.props[index][box] = nil
    end

    DeleteEntity(propEntity)

    if tlen(self.activeTrain.props) < 1 then
        self:ReleaseTrain()
        print("All looted")
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

function Tr:RequestTrainSpawn(playerId)
    local itemCount = exports.ox_inventory:GetItem(playerId, "train_tracker", nil, true)
    
    if itemCount < 1 then
        return
    end

    local time = os.time()
    local timeLeft = (lastTrain - time) / 60 

    -- if timeLeft > 0 then
    --     return Utils:Notify(playerId, ("Il reste %s minutes avant l'arriver possible d'un train"):format(math.ceil(timeLeft)))
    -- end
    
    -- local cops = exports.plouffe_society:GetPlayersPerJob("police")

    -- if not cops or tlen(cops) < minCops then
    --     return Utils:Notify(playerId,  ("Il n'y a pas asser de police en ville pour faire cela"):format(math.ceil(timeLeft)))
    -- end
    
    -- lastTrain = time + trainInterval

    exports.ox_inventory:RemoveItem(playerId, "train_tracker", 1)

    self:SpawnTrain(playerId)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "plouffe_trainrobbery" then
        Tr:DeleteTrain()
    end
end)

RegisterCommand("s_train", function(s,a,r)
    if not a[1] then
        return
    end

    local action =  a[1]:lower()

    if action == "spawn" then
        Tr:SpawnTrain()
    elseif action == "delete" then
        Tr:DeleteTrain()
    elseif action == "release" then
        Tr:ReleaseTrain()
    end
end, true)