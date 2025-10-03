local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BrainrotsFolder = workspace:WaitForChild("ScriptedMap"):WaitForChild("Brainrots")
local EquipBestRemote = Remotes:WaitForChild("EquipBestBrainrots")

-- UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

local Window = Library:CreateWindow({
	Title = "Cxsmic",
	Footer = "Beta test",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab("Main", "house"),
	Player = Window:AddKeyTab("Local Player", "user-pen"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Main")

-- ฟังก์ชันช่วยเหลือ
local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function teleportToMob(hrp, mob)
	local rootPart = mob:FindFirstChild("RootPart")
	if rootPart then
		hrp.CFrame = rootPart.CFrame * CFrame.new(0, -1, 0)
	end
end

local function attackMobWithVirtualUser()
	VirtualUser:Button1Down(Vector2.new(0, 0))
end

-- สถานะ Toggle และดีเลย์
local farming, autoCollect, autoSell = false, false, false
local lastAttack, lastCollect, lastSell = 0, 0, 0
local attackDelay = 0.2
local collectDelay = 2
local sellDelay = 2

-- Heartbeat เดียวจัดการทุกอย่าง
RunService.Heartbeat:Connect(function()
	local char = getCharacter()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local now = tick()

	-- AutoFarm
	if farming and now - lastAttack >= attackDelay then
		for _, mob in ipairs(BrainrotsFolder:GetChildren()) do
			if mob:IsA("Model") and mob:FindFirstChild("RootPart") then
				teleportToMob(hrp, mob)
				attackMobWithVirtualUser()
				lastAttack = now
				break -- ตีแค่ตัวเดียวต่อ frame
			end
		end
	end

	-- AutoCollect
	if autoCollect and now - lastCollect >= collectDelay then
		EquipBestRemote:FireServer()
		lastCollect = now
	end

	-- AutoSell
	if autoSell and now - lastSell >= sellDelay then
		Remotes:WaitForChild("ItemSell"):FireServer()
		lastSell = now
	end
end)

-- UI Toggles
LeftGroupBox:AddToggle("AutoFarm", {
	Text = "Auto Farm",
	Default = false,
	Tooltip = "Kill all brainrot",
	Callback = function(state)
		farming = state
	end
})

LeftGroupBox:AddToggle("AutoCollect", {
	Text = "Auto Collect and EquipBest",
	Default = false,
	Tooltip = "",
	Callback = function(state)
		autoCollect = state
	end
})

LeftGroupBox:AddToggle("AutoSell", {
	Text = "Auto Sell B",
	Default = false,
	Tooltip = "Sell items automatically",
	Callback = function(state)
		autoSell = state
	end
})

-- UI SETTINGS
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
