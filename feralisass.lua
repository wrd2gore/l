-- feralisass.lua (V3 - FULL UI CONTROL)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURATION ]] --
local CONFIG = {
    FlyEnabled = false,
    FlySpeed = 50,
    HitboxEnabled = false,
    HitboxSize = 50,
    KillAuraEnabled = false,
    AuraRange = 100,
    MenuVisible = true
}

-- [[ REMOTE SETUP ]] --
local ClientEffect = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V3"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "FERALISASS V3 - WRD2GORE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

-- UI Helper Function for Toggles
local function CreateToggle(name, yPos, configKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
end

-- UI Helper Function for Text Inputs
local function CreateInput(placeholder, yPos, configKey)
    local label = Instance.new("TextLabel", MainFrame)
    label.Size = UDim2.new(0.4, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.Text = placeholder .. ":"
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0.45, 0, 0, 30)
    box.Position = UDim2.new(0.5, 0, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = tostring(CONFIG[configKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then 
            CONFIG[configKey] = num 
            print("[feralisass] Set " .. configKey .. " to " .. num)
        end
    end)
end

-- Add Menu Items (Y-Positioning)
CreateToggle("Enable Fly", 50, "FlyEnabled")
CreateInput("Fly Speed", 90, "FlySpeed")

CreateToggle("Enable Hitbox", 135, "HitboxEnabled")
CreateInput("Hitbox Size", 175, "HitboxSize")

CreateToggle("Kill Aura", 220, "KillAuraEnabled")
CreateInput("Aura Range", 260, "AuraRange")

local HelpText = Instance.new("TextLabel", MainFrame)
HelpText.Size = UDim2.new(1, 0, 0, 60)
HelpText.Position = UDim2.new(0, 0, 0.82, 0)
HelpText.Text = "Press 'RightCtrl' to hide menu\nFly: W,A,S,D\nTargets: Workspace.NPCs"
HelpText.TextColor3 = Color3.fromRGB(150, 150, 150)
HelpText.BackgroundTransparency = 1
HelpText.TextSize = 12

-- [[ FLYING ENGINE ]] --
local bv, bg
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if CONFIG.FlyEnabled then
        if not bv then
            bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bg = Instance.new("BodyGyro", root)
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.D = 100 -- Smoothness
        end
        bg.CFrame = Camera.CFrame
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        bv.Velocity = dir * CONFIG.FlySpeed
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
end)

-- [[ HITBOX & KILL AURA ENGINE ]] --
RunService.Heartbeat:Connect(function()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return end

    for _, npc in pairs(npcFolder:GetChildren()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- 1. Hitbox Logic
            if CONFIG.HitboxEnabled then
                hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1) -- Reset to default
                hrp.Transparency = 1
            end

            -- 2. Kill Aura Logic
            if CONFIG.KillAuraEnabled then
                local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < CONFIG.AuraRange then
                    -- FIRE REMOTE BASED ON YOUR LOG: [1]=Effect, [2]=Time, [3]=Weapon, [4]=Target
                    ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                end
            end
        end
    end
end)

-- GUI Visibility Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        CONFIG.MenuVisible = not CONFIG.MenuVisible
        MainFrame.Visible = CONFIG.MenuVisible
    end
end)

print("--- feralisass V3 LOADED ---")
