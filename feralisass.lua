-- feralisass.lua (GUI VERSION)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [[ CONFIGURATION ]] --
local CONFIG = {
    SpeedEnabled = false,
    WalkSpeed = 21,
    JumpPower = 92,
    CombatEnabled = false,
    AttackRange = 25,
    Cooldown = 0.6,
    AutoAttack = false
}

-- [[ DYNAMIC REMOTE FINDER ]] --
local damageEvent = nil
local function findRemote()
    local folders = {"Remotes", "Events", "Remote", "Communication"}
    for _, fName in pairs(folders) do
        local f = ReplicatedStorage:FindFirstChild(fName)
        if f then
            for _, v in pairs(f:GetChildren()) do
                if v:IsA("RemoteEvent") and not v.Name:lower():find("reward") then
                    if v.Name:lower():find("damage") or v.Name:lower():find("hit") or v.Name:lower():find("combat") then
                        return v
                    end
                end
            end
        end
    end
    return nil
end
damageEvent = findRemote()

-- [[ GUI SYSTEM ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedToggle = Instance.new("TextButton")
local CombatToggle = Instance.new("TextButton")
local SpeedInput = Instance.new("TextBox")
local RangeInput = Instance.new("TextBox")
local Credit = Instance.new("TextLabel")

ScreenGui.Name = "FeralisassMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "FERALISASS V1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextSize = 18

-- Speed Toggle
SpeedToggle.Parent = MainFrame
SpeedToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
SpeedToggle.Size = UDim2.new(0.8, 0, 0, 35)
SpeedToggle.Text = "Speed: OFF"
SpeedToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Combat Toggle
CombatToggle.Parent = MainFrame
CombatToggle.Position = UDim2.new(0.1, 0, 0.35, 0)
CombatToggle.Size = UDim2.new(0.8, 0, 0, 35)
CombatToggle.Text = "Auto-Attack: OFF"
CombatToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Walkspeed Input
SpeedInput.Parent = MainFrame
SpeedInput.Position = UDim2.new(0.1, 0, 0.55, 0)
SpeedInput.Size = UDim2.new(0.8, 0, 0, 30)
SpeedInput.PlaceholderText = "Speed Value (21)"
SpeedInput.Text = "21"

-- Range Input
RangeInput.Parent = MainFrame
RangeInput.Position = UDim2.new(0.1, 0, 0.7, 0)
RangeInput.Size = UDim2.new(0.8, 0, 0, 30)
RangeInput.PlaceholderText = "Attack Range (25)"
RangeInput.Text = "25"

Credit.Parent = MainFrame
Credit.Position = UDim2.new(0, 0, 0.9, 0)
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Text = "RightCtrl to Hide"
Credit.TextColor3 = Color3.new(0.6, 0.6, 0.6)
Credit.TextSize = 12

-- [[ LOGIC CONNECTORS ]] --

SpeedToggle.MouseButton1Click:Connect(function()
    CONFIG.SpeedEnabled = not CONFIG.SpeedEnabled
    SpeedToggle.Text = CONFIG.SpeedEnabled and "Speed: ON" or "Speed: OFF"
    SpeedToggle.BackgroundColor3 = CONFIG.SpeedEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

CombatToggle.MouseButton1Click:Connect(function()
    CONFIG.AutoAttack = not CONFIG.AutoAttack
    CombatToggle.Text = CONFIG.AutoAttack and "Auto-Attack: ON" or "Auto-Attack: OFF"
    CombatToggle.BackgroundColor3 = CONFIG.AutoAttack and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

SpeedInput.FocusLost:Connect(function()
    CONFIG.WalkSpeed = tonumber(SpeedInput.Text) or 21
end)

RangeInput.FocusLost:Connect(function()
    CONFIG.AttackRange = tonumber(RangeInput.Text) or 25
end)

-- Hide/Show Menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- [[ MAIN LOOP ]] --
local lastAttack = 0
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- Speed Hack
    if CONFIG.SpeedEnabled and hum then
        hum.WalkSpeed = CONFIG.WalkSpeed
    end
    
    -- Auto Attack
    if CONFIG.AutoAttack and damageEvent and tick() - lastAttack > CONFIG.Cooldown then
        local target = nil
        local dist = CONFIG.AttackRange
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    target = p
                    dist = d
                end
            end
        end
        
        if target then
            lastAttack = tick()
            damageEvent:FireServer(target, 10, 1)
        end
    end
end)

print("--- Feralisass GUI Loaded ---")
