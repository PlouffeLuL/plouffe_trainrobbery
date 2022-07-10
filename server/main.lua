CreateThread(Tr.Init)

RegisterNetEvent("plouffe_trainrobbery:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    while not Server.ready do
        Wait(100)
    end

    if registred then
        local cbArray = Tr:GetData()
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_trainrobbery:getConfig", playerId, cbArray)
    else
        TriggerClientEvent("plouffe_trainrobbery:getConfig", playerId, nil)
    end
end)

RegisterNetEvent("plouffe_trainrobbery:installed_anfo",function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_trainrobbery:installed_anfo") then
        Tr:ExplodeTrain(playerId)
    end
end)

RegisterNetEvent("plouffe_trainrobbery:looting_box",function(box, index, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_trainrobbery:looting_box") then
        Tr:LootTrain(playerId, index, box)
    end
end)

RegisterNetEvent("plouffe_trainrobbery:request_robbery",function(authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_trainrobbery:request_robbery") then
        Tr:RequestTrainSpawn(playerId)
    end
end)