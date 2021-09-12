-- Services                                                                                                                                                                                                             
local ts = game:GetService("TweenService")                                                                                                                                                                           
                                                                                                                                                                                                                  
-- Script
local chatSettings = {
	ChatLogLimit = 50,
	CharacterLimit = 250,
	ProcessInstanceFunc = function(frame, textLabel)
		textLabel.Position = UDim2.new(0, -textLabel.TextBounds.X, 0, 2)
		textLabel.TextTransparency = 1
		
		local slideTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local fadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		
		local t1 = ts:Create(textLabel, slideTweenInfo, {Position = UDim2.new(0, 8, 0, 2)})
		local t2 = ts:Create(textLabel, fadeTweenInfo, {TextTransparency = 0})
		
		t1:Play()
		t2:Play()
	end
}

return chatSettings
