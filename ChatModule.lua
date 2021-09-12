-- Modules                                                                                                                                                                                                                                                                                               
local chatSettings = require(script.Parent:WaitForChild("ChatSettings"))                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                      
-- Script
local chatModule = {}

function chatModule:formatCol(col) -- Formats Color3 to match the RichText's font color tag
	return "\"rgb(" .. tostring(math.floor(col.r * 255)) .. "," .. tostring(math.floor(col.g * 255)) .. "," .. tostring(math.floor(col.b * 255)) .. ")\""
end

function chatModule:valid(str) -- Check if message is valid, this is checked on both Client and Server
	if #str > chatSettings.CharacterLimit then
		return false, "<font color=" .. chatModule:formatCol(Color3.new(1, 0.5, 0.5)) .. ">!!ERROR!! Over Character Limit(" .. tostring(#str) .. " > " .. tostring(chatSettings.CharacterLimit) .. ")</font>"
	end
	
	local justSpaces = true -- JustSpaces?, literally.
	for i, v in pairs(str:split("")) do
		if v ~= " " then
			justSpaces = false
			break
		end
	end
	if justSpaces then
		return false, "<font color=" .. chatModule:formatCol(Color3.new(1, 0.5, 0.5)) .. ">!!ERROR!! Invalid Formatting</font>"
	end
	return true
	--[[
		returns:
		
		   valid? error message?
		
		1. false  string
		2. true   nil
	]]
end

function chatModule:fixStr(str) -- RichText symbol format fixing
	return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
end

function chatModule:unfixStr(str) -- Revert from RichText symbol format
	return str:gsub("&apos;", "'"):gsub("&quot;", "\""):gsub("&gt;", ">"):gsub("&lt;", "<"):gsub("&amp;", "&")
end

return chatModule
