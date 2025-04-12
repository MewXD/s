local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("tween v999")
local controls = win:Server("Controls", "ServerIcon")

local TweenService = game:GetService("TweenService")
local Speed = 350 

local Plr = {}
for i, v in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(Plr, v.Name)
end

local mainChannel = controls:Channel("Main Controls")

local PlayerTP = nil

-- Dropdown สำหรับเลือกผู้เล่น
local drop = mainChannel:Dropdown(
    "Select Player!",
    Plr,
    function(t)
        PlayerTP = t
    end
)

-- Toggle สำหรับ Auto TP + Lock
mainChannel:Toggle(
    "Auto Tp",
    false,
    function(t)
        _G.TPPlayer = t
        local player = game.Players.LocalPlayer

        spawn(function()
            while _G.TPPlayer and task.wait() do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local humanoid = char:FindFirstChild("Humanoid")

                        -- ถ้ายังไม่มี Lock, ให้ใส่ BodyVelocity
                        if not hrp:FindFirstChild("Lock") then
                            if humanoid and humanoid.Sit then
                                humanoid.Sit = false
                            end
                            local Noclip = Instance.new("BodyVelocity")
                            Noclip.Name = "Lock"
                            Noclip.Parent = hrp
                            Noclip.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            Noclip.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                end)
            end

            -- ลบ Lock เมื่อปิด Auto TP
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("Lock") then
                    hrp.Lock:Destroy()
                end
            end)
        end)

        -- เริ่มการ TP
        spawn(function()
            while _G.TPPlayer and task.wait() do
                local targetPlayer = game.Players:FindFirstChild(PlayerTP)
                if player and player.Character and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                    local currentPosition = humanoidRootPart.Position

                    local distance = (targetPosition - currentPosition).Magnitude
                    local travelTime = distance / Speed
                    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
                        CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    })
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
        end)
    end
)
