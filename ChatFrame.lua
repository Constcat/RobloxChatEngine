-- Services                                                                                                                                          
local rs = game:GetService("ReplicatedStorage")                                                                                                              
local cas = game:GetService("ContextActionService")                                                                                                        
local ts = game:GetService("TweenService")
local sgui = game:GetService("StarterGui")
local chat = game:GetService("Chat")

-- Instances
local rsEvents = rs:WaitForChild("Events")
local rsModules = rs:WaitForChild("Modules")

local sendMessageEvent = rsEvents:WaitForChild("SendMessage")

local rsModulesChat = rsModules:WaitForChild("Chat")

local gui = script.Parent

local frame = gui:WaitForChild("Frame")

local chatFrame = frame:WaitForChild("ChatFrame")

local backgroundFrame = chatFrame:WaitForChild("Background")

local topBarButton = frame:WaitForChild("TopBarButton")
local topBarImage = topBarButton:WaitForChild("Image")

local scrollingFrame = backgroundFrame:WaitForChild("ScrollingFrame")

local uiListLayout = scrollingFrame:WaitForChild("UIListLayout")

local textBar = chatFrame:WaitForChild("TextBar")
local textBarBox = textBar:WaitForChild("Text")
local textBarLabel = textBar:WaitForChild("TextLabel")

local cc = workspace.CurrentCamera

-- Modules
local chatModule = require(rsModulesChat:WaitForChild("ChatModule"))
local chatSettings = require(rsModulesChat:WaitForChild("ChatSettings"))

-- Script
local open = true
local textBarFocused = false

local function updateMessage(frame) -- Update text frame if viewport has changed to match/fit.
	if frame and frame:IsA("Frame") then
		local textLabel = frame:FindFirstChild("TextLabel")
		if textLabel and textLabel:IsA("TextLabel") then
			frame.Size = UDim2.new(1, -8, 0, textLabel.TextBounds.Y + 4)
		end
	end
end

local function updateMessages() -- Update text frames, but for every text frame in the scrollingFrame
	for i, v in pairs(scrollingFrame:GetChildren()) do
		if v:IsA("Frame") then
			updateMessage(v)
		end
	end
end

local function updateAbsoluteContentSize() -- Update content size and scale scrollingFrame with content size
	local acsy = uiListLayout.AbsoluteContentSize.Y
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, acsy)
	scrollingFrame.CanvasPosition = Vector2.new(0, acsy - scrollingFrame.AbsoluteSize.Y)
end

local function updateChatBar() -- Update chat bar size with TextBounds
	if (textBarBox.Text == "") then
		if textBarFocused then
			textBarLabel.Text = ""
			textBarLabel.TextColor3 = Color3.new(1, 1, 1)
		else
			textBarLabel.Text = "Press Enter or '/' to chat..."
			textBarLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
		end
	else
		textBarLabel.Text = textBarBox.Text
		textBarLabel.TextColor3 = Color3.new(1, 1, 1)
	end
	textBar.Size = UDim2.new(1, 0, 0, math.max(textBarLabel.TextBounds.Y, textBarLabel.TextSize) + 16)
end

local function newMessage(str) -- New message? we got em
	local frame = Instance.new("Frame", scrollingFrame)
	frame.Size = UDim2.new(1, -8, 0, 0) -- Unidentified height, width must be defined to get correct Y text bounds
	frame.BackgroundTransparency = 1
	frame.ZIndex = 5
	
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 8, 0, 2)
	textLabel.Size = UDim2.new(1, -8, 1, -4)
	textLabel.TextSize = 15
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.Ubuntu
	textLabel.Text = str
	textLabel.RichText = true
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.ZIndex = 6
	
	updateMessage(frame)
	updateAbsoluteContentSize()
	
	chatSettings.ProcessInstanceFunc(frame, textLabel)
	
	return frame
end

local function recvMessage(str, plr)
	assert(typeof(str) == "string", "Message is not a string.")
	
	if str ~= "" then
		if plr and plr:IsA("Player") then
			local char = plr.Character
			if char then
				local nonRichTextStr = chatModule:unfixStr(str:gsub("%b<>", ""))
				if nonRichTextStr ~= "" then
					chat:Chat(char, nonRichTextStr, Enum.ChatColor.White)
				end
			end
			str = "<font color=" .. chatModule:formatCol(Color3.new(0.5, 0.5, 0.5)) .. "><b>" .. plr.Name .. ": </b></font>" .. str
		end
		
		local frame = newMessage(str)
		frame.LayoutOrder = 1
		
		for i, v in pairs(scrollingFrame:GetChildren()) do
			if v:IsA("Frame") then
				v.LayoutOrder -= 1
				if v.LayoutOrder <= -chatSettings.ChatLogLimit then
					v:Destroy()
				end
			end
		end
	end
end

sendMessageEvent.OnClientEvent:Connect(recvMessage)

textBarBox.FocusLost:Connect(function(ep)
	textBarFocused = false
	updateChatBar()
	if ep and open then
		local str = textBarBox.Text
		local v, err = chatModule:valid(str)
		if v then
			sendMessageEvent:FireServer(str)
		elseif (not v) and err then
			recvMessage(err)
		end
		textBarBox.Text = ""
	end
end)

textBarBox.Focused:Connect(function()
	textBarFocused = true
	updateChatBar()
end)

cas:BindActionAtPriority("Chat", function(an, is, io)
	if (is == Enum.UserInputState.Begin) and open then
		wait()
		textBarBox:CaptureFocus()
	end
	return Enum.ContextActionResult.Pass
end, true, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Return, Enum.KeyCode.Slash)

local function update()
	updateMessages()
	updateAbsoluteContentSize()
end

local function updateOpen()
	chatFrame.Visible = open
	local off, on = "rbxasset://textures/ui/TopBar/chatOff.png", "rbxasset://textures/ui/TopBar/chatOn.png"
	if open then
		topBarImage.Image = on
	else
		topBarImage.Image = off
		textBarBox:ReleaseFocus()
	end
end

local function init()
	while true do
		local s, err = pcall(function()
			sgui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		end)
		if s then break end
		wait()
	end
	
	cc:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	textBarBox:GetPropertyChangedSignal("Text"):Connect(updateChatBar)
	topBarButton.MouseButton1Down:Connect(function()
		open = not open
		updateOpen()
	end)
	
	update()
	updateChatBar()
	updateOpen()
	
	frame.Visible = true
end

init()
