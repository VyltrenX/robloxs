-- [[ UNBEATABLE FNF AUTOPLAYER WITH TOGGLE GUI ]]
print("⚡ Ultimate Autoplayer GUI Loaded!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Global state control
local _G.AutoplayerEnabled = false

-- Key Map matching standard FNF controls
local KEY_MAP = {
	["Left"]  = Enum.KeyCode.A,
	["Down"]  = Enum.KeyCode.S,
	["Up"]    = Enum.KeyCode.W,
	["Right"] = Enum.KeyCode.D
}

---------------------------------------------------------
-- 🎨 PART 1: THE VISUAL GUI CREATION
---------------------------------------------------------

-- Safely destroy any older copies of this menu if it's rerun
if playerGui:FindFirstChild("FNFAutoplayerUI") then
	playerGui.FNFAutoplayerUI:Destroy()
end

-- Main Canvas Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FNFAutoplayerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Panel Menu Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Renders on the left side of the screen
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Allows you to click and drag the menu anywhere
MainFrame.Parent = ScreenGui

-- Rounded Corners for Style
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Header Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ FNF REMIX BOT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

-- Status Display Indicator
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: DISABLED"
StatusLabel.TextColor3 = Color3.fromRGB(240, 70, 70)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- Interactive Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 160, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -80, 0, 70)
ToggleButton.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
ToggleButton.Text = "TURN ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Button Animation & Logic Trigger
ToggleButton.MouseButton1Click:Connect(function()
	_G.AutoplayerEnabled = not _G.AutoplayerEnabled
	
	if _G.AutoplayerEnabled then
		-- Update UI style to active green state
		StatusLabel.Text = "Status: ACTIVE"
		StatusLabel.TextColor3 = Color3.fromRGB(70, 240, 140)
		ToggleButton.Text = "TURN OFF"
		TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 180, 100)}):Play()
	else
		-- Reset UI style back to inactive red state
		StatusLabel.Text = "Status: DISABLED"
		StatusLabel.TextColor3 = Color3.fromRGB(240, 70, 70)
		ToggleButton.Text = "TURN ON"
		TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 70, 70)}):Play()
	end
end)

---------------------------------------------------------
-- 🤖 PART 2: THE COMPACT TRACKING SYSTEM
---------------------------------------------------------

-- Simulates an instant frame-perfect tap
local function hitNote(keyCode, duration)
	VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
	task.wait(duration or 0.02)
	VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- Infinite execution engine loop
RunService.RenderStepped:Connect(function()
	-- Exit instantly if the user turned the cheat off on the panel
	if not _G.AutoplayerEnabled then return end
	
	local gameGui = playerGui:FindFirstChild("GameGui") or playerGui:FindFirstChild("Gameplay") or playerGui:FindFirstChild("ScreenGui")
	if not gameGui then return end
	
	local noteContainer = gameGui:FindFirstChild("Notes") or gameGui:FindFirstChild("ArrowContainer")
	if not noteContainer then return end
	
	for _, arrow in ipairs(noteContainer:GetChildren()) do
		if arrow:GetAttribute("MustHit") == true or arrow.Name:find("Player") then
			
			local currentY = arrow.Position.Y.Offset
			local targetY = 50 -- Check your game screen layout if note sync drifts
			
			-- Only registers inside a narrow target execution window
			if math.abs(currentY - targetY) <= 6 then 
				local direction = arrow:GetAttribute("Direction") or arrow.Name
				local key = KEY_MAP[direction]
				
				if key then
					local length = arrow:GetAttribute("Duration") or 0.02
					
					task.spawn(function()
						hitNote(key, length)
					end)
					
					-- Remove note locally to avoid re-trigger calculations
					arrow:Destroy() 
				end
			end
		end
	end
end)
