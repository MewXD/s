local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("test", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("fish")
    Section:NewToggle("Auto Reel Perfect Catch", "Continuously catch perfect items", function(state)
        getgenv().config.auto_reel_perfect_catch = state
    
        if state then
            spawn(function()
                while getgenv().config.auto_reel_perfect_catch do
                    task.wait(0.1)  -- เพิ่มการรอ 0.1 วินาทีเพื่อให้ loop ไม่ทำงานเร็วเกินไป
    
                    local playerGui = lp:FindFirstChild("PlayerGui")
    
                    if playerGui then
                        local reel = playerGui:FindFirstChild("reel")
    
                        if reel then
                            print("Reel GUI found!")
    
                            -- รอให้ event `re` โหลดก่อน
                            local re = game.ReplicatedStorage:FindFirstChild("re")
                            
                            if re and re.events and re.events.reelfinished then
                                local success, errMsg = pcall(function()
                                    re.events.reelfinished:FireServer(100, true)
                                end)
    
                                if success then
                                    print("Successfully triggered reelfinished event")
                                else
                                    warn("Failed to trigger reelfinished event:", errMsg)
                                end
                            else
                                warn("Event reelfinished not found in re.events")
                            end
                        else
                            warn("Reel GUI not found in PlayerGui")
                        end
                    else
                        warn("PlayerGui not found")
                    end
                    task.wait(0.5)  -- รอครึ่งวินาทีอีกทีเพื่อประสิทธิภาพที่เหมาะสม
                end
            end)
        else
            getgenv().config.auto_reel_perfect_catch = false
            print("Auto Reel Perfect Catch loop stopped")
        end
    end)
    


local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage

getgenv().config = getgenv().config or {}
getgenv().config.auto_thorown_rod = false

Section:NewToggle("Auto Throw Rod", "Automatically throw the rod", function(state)
    if state then
        
        getgenv().config.auto_thorown_rod = true
        spawn(function()
            while getgenv().config.auto_thorown_rod do
                task.wait()

                
                local rod_name = re.playerstats[lp.Name].Stats.rod.Value
                local equipped_rod = lp.Character:FindFirstChild(rod_name)

                if equipped_rod and equipped_rod:FindFirstChild("events") and equipped_rod.events:FindFirstChild("cast") then
                    equipped_rod.events.cast:FireServer(100) 
                end
            end
        end)
    else
        
        getgenv().config.auto_thorown_rod = false
    end
end)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager") 

Section:NewToggle("Auto Shake", "Navigate", function(state)
    if state then
        getgenv().config.auto_shake = true

        
        spawn(function()
            while getgenv().config.auto_shake do
                task.wait()

                
                local playerGui = lp:WaitForChild("PlayerGui")
                local shake_button = playerGui:FindFirstChild("shakeui") 
                    and playerGui.shakeui:FindFirstChild("safezone") 
                    and playerGui.shakeui.safezone:FindFirstChild("button")

                if shake_button then
                    
                    shake_button.Selectable = true
                    GuiService.SelectedObject = shake_button 

                    
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) -- กดปุ่ม Enter
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) -- ปล่อยปุ่ม Enter
                end
            end
        end)
    else
        getgenv().config.auto_shake = false
    end
end)
Section:NewToggle("auto reel", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_reel = true

        spawn(function()
            while getgenv().config.auto_reel do
                task.wait(0)  

                
                local playerGui = lp:FindFirstChild("PlayerGui")
                if playerGui then
                    local reel = playerGui:FindFirstChild("reel")

                    if reel then
                        print("Reel found!")

                        
                        if re and re.events and re.events.reelfinished then
                            print("Attempting to fire reelfinished event")
                            local success, errorMsg = pcall(function()
                                re.events.reelfinished:FireServer(100, false)
                            end)

                            if success then
                                print("Reel event fired successfully")
                            else
                                warn("Failed to fire reel event:", errorMsg)
                            end
                        else
                            warn("Event reelfinished not found")
                        end
                    else
                        warn("Reel GUI not found in PlayerGui")
                    end
                else
                    warn("PlayerGui not found")
                end
            end
        end)

    else
        getgenv().config.auto_reel = false
        print("Auto Reel has been disabled")
    end
end)
local isTeleporting = false  

Section:NewToggle("Teleport to Saved Position (Loop)", "Continuously teleport character to saved position", function(state)
    if state then
        isTeleporting = true

        spawn(function()
            while isTeleporting do
                task.wait(0)  

                if getgenv().position and lp.Character and lp.Character.HumanoidRootPart then
                    lp.Character.HumanoidRootPart.CFrame = getgenv().position
                else
                    warn("No saved position or character not found")
                    break 
                end
            end
        end)

    else
        isTeleporting = false
        print("Teleport loop has been stopped")
    end
end)

Section:NewButton("Save Position", "Save your character's position permanently", function()
    if lp.Character and lp.Character.HumanoidRootPart then
        getgenv().position = lp.Character.HumanoidRootPart.CFrame
        print("Position has been saved successfully")
    end
end)
Section:NewDropdown("Megalodon", "DropdownInf", {"Megalodon Default"}, function(currentOption)
    if currentOption == "Megalodon Default" and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart then
        local target = workspace.zones.fishing:FindFirstChild("Megalodon Default")

        if target and target:IsA("BasePart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
            print("Teleported to Megalodon Default")
        else
            warn("Megalodon Default not found in Workspace")
        end
    end
end)

Section:NewToggle("Auto Meteor Collect", "Continuously teleport and collect Meteor", function(state)
    getgenv().config.AutoMeteorCollect = state

    if state then
        spawn(function()
            while getgenv().config.AutoMeteorCollect do
                task.wait(0)  

                
                local meteor = workspace.MeteorCrater and workspace.MeteorCrater:FindFirstChild("Root")

                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and meteor then
                    
                    lp.Character.HumanoidRootPart.CFrame = meteor.CFrame
                    print("Teleported to Meteor Crater")

                    wait(0.1)  

                    
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)  -- กด E
                    wait(0.2)  
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)  -- ปล่อยปุ่ม E

                    print("Item collected successfully")

                    
                    repeat
                        task.wait(1)
                        meteor = workspace.MeteorCrater and workspace.MeteorCrater:FindFirstChild("Root")
                    until meteor  

                    print("New Meteor detected, teleporting again...")

                else
                    warn("Meteor หรือ Character ไม่พบ")
                    break
                end
            end
        end)
    else
        getgenv().config.AutoMeteorCollect = false
        print("Auto Meteor Collect loop stopped")
    end
end)





Section:NewToggle("Teleport to Meg", "ToggleInfo", function(state)

end)
local Tab = Window:NewTab("teleport")
local Section = Tab:NewSection("teleport")
local Section = Tab:NewSection("Select Player!")

-- Define LocalPlayer
local lp = game.Players.LocalPlayer

-- Dropdown สำหรับ Teleport ไปยังเกาะ
local islandOptions = {}  -- ตารางสำหรับเก็บรายชื่อเกาะ

-- ดึงชื่อของเกาะทั้งหมดจาก Workspace
for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end
Section:NewDropdown("Teleport to islands", "DropdownInf", islandOptions, function(currentOption)
    if lp.Character and lp.Character.HumanoidRootPart then
        for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
            if teleport_island.Name == currentOption and teleport_island:IsA("BasePart") then
                lp.Character.HumanoidRootPart.CFrame = teleport_island.CFrame
                print("Teleported to island:", currentOption)
                return
            end
        end
    end
end)
Plr = {}
for i,v in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(Plr,v.Name) 
end
local drop = Section:NewDropdown("Select Player!", "Click To Select", Plr, function(t)
   PlayerTP = t
end)
Section:NewButton("Click To TP", "", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[PlayerTP].Character.HumanoidRootPart.CFrame
end)
Section:NewToggle("Auto Tp", "", function(t)
_G.TPPlayer = t
while _G.TPPlayer do wait()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[PlayerTP].Character.HumanoidRootPart.CFrame
end
end)
Section:NewButton("Refresh Player","Refresh Dropdown", function()
  drop:Refresh(Plr)
end)
local Tab = Window:NewTab("boost fps (maybe)")
local Section = Tab:NewSection("Destroy Part")
Section:NewButton("Remove Shadows Friends", "ButtonInfo", function()
local part = game.Workspace.Shadows

part:Destroy()
end)
local Section = Tab:NewSection("Destroy Part")
Section:NewButton("Remove fish", "ButtonInfo", function()
local part = game.Workspace.active

part:Destroy()
end)