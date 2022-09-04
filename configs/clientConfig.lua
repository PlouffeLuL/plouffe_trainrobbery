Tr = {Train = {}}
TriggerServerEvent("plouffe_trainrobbery:sendConfig")
local cookie
cookie = RegisterNetEvent("plouffe_trainrobbery:getConfig",function(list)
	if not list then
		while true do
			Tr = nil
		end
	else
		for k,v in pairs(list) do
			Tr[k] = v
		end

		Tr:Start()

		RemoveEventHandler(cookie)
	end
end)