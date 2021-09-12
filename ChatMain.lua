-- Services
local rs = game:GetService("ReplicatedStorage")
local txts = game:GetService("TextService")

-- Instances
local rsEvents = rs:WaitForChild("Events")
local rsModules = rs:WaitForChild("Modules")

local sendMessageEvent = rsEvents:WaitForChild("SendMessage")

local rsModulesChat = rsModules:WaitForChild("Chat")

-- Modules
local chatModule = require(rsModulesChat:WaitForChild("ChatModule"))

-- Script
sendMessageEvent.OnServerEvent:Connect(function(plr, str)
	assert(typeof(str) == "string", "Message is not a string.")
	
	str = chatModule:fixStr(str)
	
	local v, err = chatModule:valid(str)
	if v then
		local filtered = txts:FilterStringAsync(str, plr.UserId, Enum.TextFilterContext.PublicChat)
		local filteredStr = filtered:GetNonChatStringForBroadcastAsync()
		
		sendMessageEvent:FireAllClients("<font color=" .. chatModule:formatCol(Color3.new(1, 1, 1)) .. ">" .. filteredStr .. "</font>", plr)
	elseif (not v) and err then
		sendMessageEvent:FireClient(plr, err)
	end
end)
