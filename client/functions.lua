local Utils = exports.plouffe_lib:Get("Utils")
local Callback = exports.plouffe_lib:Get("Callback")
local Interface = exports.plouffe_lib:Get("Interface")
local Lang = exports.plouffe_lib:Get("Lang")

local GetGameTimer = GetGameTimer
local Wait = Wait
local CreateThread = CreateThread

local DeleteMissionTrain = DeleteMissionTrain
local DeleteAllTrains = DeleteAllTrains
local SetMissionTrainAsNoLongerNeeded = SetMissionTrainAsNoLongerNeeded
local DeleteEntity = DeleteEntity
local CreateMissionTrain = CreateMissionTrain
local SetTrainSpeed = SetTrainSpeed
local SetTrainCruiseSpeed = SetTrainCruiseSpeed
local DoesEntityExist = DoesEntityExist
local GetTrainCarriage = GetTrainCarriage
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local AttachEntityToEntity = AttachEntityToEntity

local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId

local TaskTurnPedToFaceEntity = TaskTurnPedToFaceEntity

local AddExplosion = AddExplosion
local UseParticleFxAssetNextCall = UseParticleFxAssetNextCall
local StartNetworkedParticleFxLoopedOnEntity = StartNetworkedParticleFxLoopedOnEntity
local RemovePtfxAsset = RemovePtfxAsset
local StopParticleFxLooped = StopParticleFxLooped

local SetEntityAsNoLongerNeeded = SetEntityAsNoLongerNeeded
local SetEntityCleanupByEngine = SetEntityCleanupByEngine

local ptfxEffects = {}

local trainModels = {
	"freight",
    "freightcar",
    "freightcar2",
    "freightcont1",
    "freightcont2",
    "freightgrain",
    "freighttrailer",
    "metrotrain",
    "s_m_m_lsmetro_01",
    "tankercar"
}

local trainProps = {
    carriage_3 = {
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_01a",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_5 = {
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_6 = {
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 4.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 2.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, 0.8, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -1.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -3.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05a",
            coords = vector3(-0.5, -5.2, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    },
    carriage_7 = {
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        {
            model = "hei_prop_carrier_cargo_05b_s",
            coords = vector3(0.0, -4.3, -0.3),
            rotation = vector3(0.0, 0.0, 90.0)
        }
    }
}

function Tr:Start()
    self:ExportAllZones()
    self:RegisterEvents()

    Callback:RegisterClientCallback("plouffe_trainrobbery:spawnTrain", Tr.Train.SpawnTrain)

    if GetConvar("plouffe_trainrobbery:qtarget", "") == "true" then
        if GetResourceState("qtarget") ~= "missing" then
            local breakCount = 0

            while GetResourceState("qtarget") ~= "started" and breakCount < 30 do
                breakCount += 1
                Wait(1000)
            end

            if GetResourceState("qtarget") ~= "started" then
                return
            end

            local data = {
                joaat("hei_prop_carrier_cargo_01a"),
                joaat("hei_prop_carrier_cargo_05b_s"),
                joaat("hei_prop_carrier_cargo_05a")
            }

            exports.qtarget:AddTargetModel(data,{
                distance = 1.5,
                options = {
                    {
                        icon = 'fas fa-info',
                        label = Lang.bank_tryLoot,
                        action = Tr.TryLoot
                    }
                }
            })
        end
    end
end

function Tr:ExportAllZones()
    for k,v in pairs(self.Spawns) do
        exports.plouffe_lib:Register(v)
    end
end

function Tr:RegisterEvents()
    Utils:RegisterNetEvent("plouffe_trainrobbery:release_train", function()
        self:ReleaseTrain()
    end)

    AddEventHandler("plouffe_trainrobbery:onZone", function(params)
        self[params.fnc](self, params)
    end)

    AddEventHandler("plouffe_trainrobbery:open", Tr.TryLoot)

    AddStateBagChangeHandler("activeTrain" ,nil, function(bagName,key,value,reserved,replicated)
        if not value then
            return RemoveStateBagChangeHandler(self.trainStateBag)
        end

        self.trainStateBag = AddStateBagChangeHandler(nil ,("entity:%s"):format(value.locomotive), function(bagName,key,value,reserved,replicated)
            if key == "explode" and value == "true" then
                Tr.PtfxExplosion()
                RemoveStateBagChangeHandler(self.trainStateBag)
            end
        end)
    end)
end

function Tr.Train.SpawnTrain(cb,data)
    local time = GetGameTimer()
    local coords = data.coords

    for k,v in pairs(trainModels) do
        Utils:AssureModel(v)
    end

    local train = CreateMissionTrain(4, coords.x, coords.y, coords.z, true)

    while not DoesEntityExist(train) and GetGameTimer() - time < 1000 * 10 do
        Wait(100)
    end

    if not DoesEntityExist(train) then
        return cb(false)
    end

    Tr.Train:ChangeSpeed(Tr.trainSpeed, train)

    local data = {
        locomotive = NetworkGetNetworkIdFromEntity(train),
        carriage = {},
        props = {}
    }

    for i = 0, 9 do
        local carriage = GetTrainCarriage(train, i)

        if carriage ~= 0 then
            local init = GetGameTimer()

            while not DoesEntityExist(NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(carriage))) and GetGameTimer() - init < 2000 do
                Wait(0)
            end

            if DoesEntityExist(NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(carriage))) then
                local index = ("carriage_%s"):format(i)

                if trainProps[index] then
                    data.props[index] = {}

                    for k,v in pairs(trainProps[index]) do
                        Wait(250)

                        local init = GetGameTimer()
                        local entity = Utils:CreateProp(v.model,coords,0.0,true,false)

                        while not DoesEntityExist(NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(entity))) and GetGameTimer() - init < 2000 do
                            Wait(0)
                        end

                        if DoesEntityExist(NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(entity))) then
                            data.props[index][#data.props[index] + 1] = NetworkGetNetworkIdFromEntity(entity)
                            AttachEntityToEntity(entity, carriage, 0, v.coords.x, v.coords.y, v.coords.z, v.rotation.x, v.rotation.y, v.rotation.z, false, false, true, false, 2, true)
                        end
                    end
                end

                data.carriage[index] = NetworkGetNetworkIdFromEntity(carriage)
            end
        end
    end

    cb(data)
end

function Tr.Train:ChangeSpeed(speed, train)
    local train = train or NetworkGetEntityFromNetworkId(GlobalState.activeTrain.locomotive)

    speed = speed + 0.0

    SetTrainSpeed(train, speed)
    SetTrainCruiseSpeed(train, speed)
end

function Tr.PtfxExplosion()
    local train = NetworkGetEntityFromNetworkId(GlobalState.activeTrain.locomotive)

    if not DoesEntityExist(train) then
        return
    end

    local offsets = {
        vector3(0.0, 4.0, 3.0),
        vector3(0.0, 0.0, 3.0),
        vector3(0.0, -4.0, 3.0)
    }

    CreateThread(function()
        local speed = tonumber(Entity(train).state.speed) or 40

        while speed > 5 do
            speed = speed - 0.1
            SetTrainCruiseSpeed(train, speed)
            Wait(50)
        end

        while speed > 0 do
            speed = speed - 0.1
            SetTrainCruiseSpeed(train, speed)

            Wait(math.random(100,1000))
        end

        SetTrainCruiseSpeed(train, 0.0)
    end)

    Utils:AssureFxAsset("scr_ornate_heist")

    UseParticleFxAssetNextCall('scr_ornate_heist')
    local ptfx = StartNetworkedParticleFxLoopedOnEntity('scr_heist_ornate_thermal_burn', train, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false, 0)

    Utils:AssureFxAsset("core",true)

    local nextPtfx = 10

    for i = 1, 50 do
        local offset = offsets[math.random(1,#offsets)]
        local coords = GetOffsetFromEntityInWorldCoords(train, offset.x,offset.y,offset.z)

        AddExplosion(coords.x, coords.y, coords.z, 34, 1.0, true, false, true, true)

        if i == nextPtfx then
            nextPtfx = nextPtfx + 10
            UseParticleFxAssetNextCall('core')
            ptfxEffects[#ptfxEffects + 1] = StartNetworkedParticleFxLoopedOnEntity('exp_grd_bzgas_smoke', train, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, 2.0, false, false, false, 0)
        end

        Wait(100)
    end

    StopParticleFxLooped(ptfx, 0)
    RemovePtfxAsset("core")
end

function Tr.BlowupTrain()
    if not GlobalState.activeTrain then
        return
    end

    if Utils:GetItemCount(Tr.bombItem) < 1 then
        return Interface.Notifications.Show({
            style = "error",
            header = "Train robbery",
            message = Lang.missing_something
        })
    end

    if GlobalState.activeTrain_state ~= "active" then
        return Interface.Notifications.Show({
            style = "error",
            header = "Train robbery",
            message = Lang.train_notAvaible
        })
    end

    local train = NetworkGetEntityFromNetworkId(GlobalState.activeTrain.locomotive)
    local ped = PlayerPedId()
    local retval = GetOffsetFromEntityInWorldCoords(train, -0.010181, -1.332691, 4.057907)
    local pedCoords = GetEntityCoords(ped)
    local distance = #(pedCoords - retval)

    if distance > 2 then
        return Interface.Notifications.Show({
            style = "error",
            header = "Train robbery",
            message = Lang.train_farFromEngine
        })
    end

    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.8, -0.6)

    CreateThread(function()
        Utils:PlayAnim(6000, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer" , 1, 3.0, 2.0, 6000, false, true, true, {model = "hei_prop_heist_thermite", bone = 28422} )
    end)


    local entity = Utils:CreateProp("hei_prop_heist_thermite",coords,0.0,true,false)
    Utils:AssureFxAsset("scr_ornate_heist")

    AttachEntityToEntity(entity, train, 0, 0.0, -1.15, 3.075, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    UseParticleFxAssetNextCall('scr_ornate_heist')
    local ptfx = StartNetworkedParticleFxLoopedOnEntity('scr_heist_ornate_thermal_burn', entity, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false, 0)

    local succes = Interface.MemorySquares.New({
        time = 20,
        amount = 12,
        solutionAmount = 6,
        errors = 3,
        delay = 2
    })

    if succes then
        Wait(4000)
    end

    if GetResourceState("plouffe_dispatch") == "started" then
        exports.plouffe_dispatch:SendAlert("10-90 I")
    end

    TriggerServerEvent("plouffe_trainrobbery:installed_anfo", Tr.auth)

    Wait(2000)

    StopParticleFxLooped(ptfx, 0)
    DeleteEntity(entity)
end
exports("BlowupTrain", Tr.BlowupTrain)

function Tr.TryLoot()
    if not GlobalState.activeTrain_state or GlobalState.activeTrain_state ~= "explode" then
        return
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local boxEntity = nil
    local foundBox = nil
    local foundIndex = nil
    local closest = 10.0
    local props = GlobalState.activeTrain.props

    for index,loots in pairs(props) do
        for k,v in pairs(loots) do
            local box = NetworkGetEntityFromNetworkId(v)
            local boxCoords = GetEntityCoords(box)
            local distance = #(boxCoords - pedCoords)

            if DoesEntityExist(box) and distance < closest then
                closest = distance
                boxEntity = box
                foundBox = k
                foundIndex = index
            end
        end
    end

    if not foundBox then
        return Interface.Notifications.Show({
            style = "error",
            header = "Train robbery",
            message = Lang.train_noBox
        })
    end

    TaskTurnPedToFaceEntity(ped, boxEntity, 1000)

    local finished = exports.ox_lib:progressCircle({
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer",
            flag = 1
        },
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    })

    if not finished then
        return
    end

    local succes = Interface.MemorySquares.New({
        time = 20,
        amount = 8,
        solutionAmount = 8,
        errors = 3,
        delay = 2
    })

    if not succes then
        return
    end

    TriggerServerEvent("plouffe_trainrobbery:looting_box", foundBox, foundIndex, Tr.auth)
end

function Tr:ReleaseTrain()
    local entity = NetworkGetEntityFromNetworkId(GlobalState.activeTrain.locomotive)

    Utils:AssureEntityControl(entity)
    SetMissionTrainAsNoLongerNeeded()
    SetEntityAsNoLongerNeeded(entity)
    SetEntityCleanupByEngine(entity, true)

    for k,v in pairs(GlobalState.activeTrain.carriage) do
        entity = NetworkGetEntityFromNetworkId(v)
        Utils:AssureEntityControl(entity)
        SetEntityAsNoLongerNeeded(entity)
        SetEntityCleanupByEngine(entity, true)
    end

    for k,v in pairs(GlobalState.activeTrain.props) do
        for x,y in pairs(v) do
            entity = NetworkGetEntityFromNetworkId(y)
            if DoesEntityExist(entity) then
                Utils:AssureEntityControl(entity)
                SetEntityAsNoLongerNeeded(entity)
                SetEntityCleanupByEngine(entity, true)
            end
        end
    end
end

function Tr.RequestTrainSpawn()
    if Utils:GetItemCount(Tr.startItem) < 1 then
        return Interface.Notifications.Show({
            style = "error",
            header = "Train robbery",
            message = Lang.missing_something
        })
    end

    CreateThread(function()
        Utils:PlayAnim(4000, "cellphone@", "cellphone_call_listen_base" , 49, 3.0, 2.0, 4000, false, true, false, {model = "prop_npc_phone_02", bone = 28422})
    end)

    local finished = exports.ox_lib:progressCircle({
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    })

    if finished then
        TriggerServerEvent("plouffe_trainrobbery:request_robbery", Tr.auth)
    end
end
exports("RequestTrainSpawn", Tr.RequestTrainSpawn)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "plouffe_trainrobbery" then
        DeleteMissionTrain()
        DeleteAllTrains()
        SetMissionTrainAsNoLongerNeeded()
    end
end)