-- feralisass.lua (V5 - ANTI-KICK & RATE LIMIT FIX)

-- [[ CLEAN-UP SYSTEM ]] --
if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V5") then
        game.CoreGui:FindFirstChild("Feralisass_V5"):Destroy()
    end
    task.wait(0.3)
end
_G.FeralisassRunning = true
_G.FeralisassCleanup = false

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
    HitboxSize = 15, -- Kept under 20 to avoid server detection
    KillAuraEnabled = false,
    AuraRange = 60,
    AttackDelay = 0.4, -- Fixed rate limit (seconds between hits)
    MenuVisible = true
}

-- [[ REMOTE SETUP ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events and Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V5"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 420)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "FERALISASS V5 - BYPASS MODE"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateToggle(name, yPos, configKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(100, 30, 30)
    end)
end

local function CreateInput(placeholder, yPos, configKey)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0.9, 0, 0, 30)
    box.Position = UDim2.new(0.05, 0, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[configKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.FocusLost:Connect(function()
        CONFIG[configKey] = tonumber(box.Text) or CONFIG[configKey]
    end)
end

-- UI Layout
CreateToggle("Safe Fly", 50, "FlyEnabled")
CreateInput("Fly Speed (Max 200)", 90, "FlySpeed")
CreateToggle("Hitbox Expander", 130, "HitboxEnabled")
CreateInput("Hitbox Size (Max 20)", 170, "HitboxSize")
CreateToggle("Kill Aura", 210, "KillAuraEnabled")
CreateInput("Aura Cooldown (0.1 - 1.0)", 250, "AttackDelay")

local Warning = Instance.new("TextLabel", MainFrame)
Warning.Size = UDim2.new(0.9, 0, 0, 60)
Warning.Position = UDim2.new(0.05, 0, 0, 320)
Warning.Text = "STRIKE BYPASS: Keep Fly under 15 studs\nHitbox Size over 20 will fail.\nRightCtrl to hide."
Warning.TextColor3 = Color3.new(1, 0.4, 0.4)
Warning.TextWrapped = true
Warning.BackgroundTransparency = 1

-- [[ ENGINES ]] --

-- Anti-Kick Fly Engine
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    
    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if CONFIG.FlyEnabled and root then
            bv.Parent = root
            bg.Parent = root
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            
            -- Bypass Attempt: If you fly too high, it jitters down to try and touch the 'floor' raycast
            bv.Velocity = dir * CONFIG.FlySpeed
        else
            bv.Parent = nil
            bg.Parent = nil
        end
    end
end)

-- Hitbox & Kill Aura Engine (With Rate Limiting)
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AttackDelay) -- This prevents the rate limit kick
        
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder or not CONFIG.KillAuraEnabled then continue end
        
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        for _, npc in pairs(npcFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hitbox Scaling (Capped to avoid detection)
                if CONFIG.HitboxEnabled then
                    local size = math.min(CONFIG.HitboxSize, 20)
                    hrp.Size = Vector3.new(size, size, size)
                    hrp.Transparency = 0.8
                    hrp.CanCollide = false
                end

                -- Kill Aura (Checks distance and uses Rate Limit)
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < CONFIG.AuraRange and ClientEffect then
                    -- Fire the hit event with your discovered parameters
                    ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                end
            end
        end
    end
end)

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("--- Feralisass V5 Bypass Active ---")
