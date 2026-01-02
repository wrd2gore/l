-- feralisass.lua (V4 - ANTI-DUPE & FULL CONTROL)

-- [[ CLEAN-UP SYSTEM ]] --
-- This checks if the script is already running and shuts it down before restarting
if _G.FeralisassRunning then
    _G.FeralisassCleanup = true -- Signal to old loops to stop
    if game.CoreGui:FindFirstChild("Feralisass_V4") then
        game.CoreGui:FindFirstChild("Feralisass_V4"):Destroy()
    end
    task.wait(0.5) -- Wait for old loops to clear
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
    HitboxSize = 50,
    KillAuraEnabled = false,
    AuraRange = 100,
    MenuVisible = true
}

-- [[ REMOTE SETUP ]] --
local ClientEffect = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V4"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "FERALISASS V4 - WRD2GORE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

-- UI Helper Function for Toggles
local function CreateToggle(name, yPos, configKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(40, 130, 40) or Color3.fromRGB(130, 40, 40)
    end)
end

-- UI Helper Function for Text Inputs
local function CreateInput(placeholder, yPos, configKey)
    local label = Instance.new("TextLabel", MainFrame)
    label.Size = UDim2.new(0.4, 0, 0, 30)
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.Text = placeholder .. ":"
    label.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0.45, 0, 0, 30)
    box.Position = UDim2.new(0.5, 0, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.Text = tostring(CONFIG[configKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then CONFIG[configKey] = num end
    end)
end

-- Create Buttons/Boxes
CreateToggle("Enable Fly", 50, "FlyEnabled")
CreateInput("Fly Speed", 90, "FlySpeed")
CreateToggle("Enable Hitbox", 135, "HitboxEnabled")
CreateInput("Hitbox Size", 175, "HitboxSize")
CreateToggle("Kill Aura", 220, "KillAuraEnabled")
CreateInput("Aura Range", 260, "AuraRange")

local HelpText = Instance.new("TextLabel", MainFrame)
HelpText.Size = UDim2.new(1, 0, 0, 60)
HelpText.Position = UDim2.new(0, 0, 0.82, 0)
HelpText.Text = "RightCtrl to hide\nTargets: NPCs Folder\n(Santa's Sleigh included)"
HelpText.TextColor3 = Color3.fromRGB(120, 120, 120)
HelpText.BackgroundTransparency = 1
HelpText.TextSize = 12

-- [[ CORE ENGINES ]] --

-- Fly Engine
local bv, bg
task.spawn(function()
    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if CONFIG.FlyEnabled then
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
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
    end
end)

-- Hitbox & Aura Engine
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(0.1)
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder then continue end

        for _, npc in pairs(npcFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hitbox
                if CONFIG.HitboxEnabled then
                    hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                    hrp.Transparency = 0.8
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1) -- Standard size
                end

                -- Kill Aura
                if CONFIG.KillAuraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < CONFIG.AuraRange then
                        -- Arguments: [1]=HitEffect, [2]=Time, [3]=Sword, [4]=Target
                        ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                    end
                end
            end
        end
    end
end)

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        CONFIG.MenuVisible = not CONFIG.MenuVisible
        MainFrame.Visible = CONFIG.MenuVisible
    end
end)

print("--- Feralisass V4 LOADED (Clean-up active) ---")
