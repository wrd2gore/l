-- feralisass.lua (V2 - FLY & KILL AURA & HITBOX)
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
    KillAura = false,
    CombatRange = 100,
}

-- [[ REMOTES ]] --
local EventFolder = ReplicatedStorage:WaitForChild("Events", 10)
local AttackRemote = EventFolder:FindFirstChild("ClientEffect") -- Based on your log

-- [[ GUI SYSTEM ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", MainFrame)

MainFrame.Size = UDim2.new(0, 220, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "FERALISASS V2"
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateToggle(name, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, 0, pos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)
    return btn
end

local function CreateInput(placeholder, pos, callback)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0.8, 0, 0, 30)
    box.Position = UDim2.new(0.1, 0, 0, pos)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.FocusLost:Connect(function()
        callback(tonumber(box.Text))
    end)
end

-- GUI Elements
CreateToggle("Fly", 50, function() CONFIG.FlyEnabled = not CONFIG.FlyEnabled return CONFIG.FlyEnabled end)
CreateInput("Fly Speed (1-200)", 90, function(val) if val then CONFIG.FlySpeed = val end end)
CreateToggle("Big Hitbox", 140, function() CONFIG.HitboxEnabled = not CONFIG.HitboxEnabled return CONFIG.HitboxEnabled end)
CreateToggle("Kill Aura", 180, function() CONFIG.KillAura = not CONFIG.KillAura return CONFIG.KillAura end)

local Info = Instance.new("TextLabel", MainFrame)
Info.Size = UDim2.new(1, 0, 0, 50)
Info.Position = UDim2.new(0, 0, 0.8, 0)
Info.Text = "RightCtrl to Hide\nFly Speed: " .. CONFIG.FlySpeed
Info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Info.BackgroundTransparency = 1

-- [[ FLY LOGIC ]] --
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

-- [[ HITBOX & KILL AURA LOGIC ]] --
task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.HitboxEnabled then
            -- Specifically target NPCs folder
            local npcFolder = workspace:FindFirstChild("NPCs")
            if npcFolder then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if CONFIG.KillAura and AttackRemote then
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder then return end

        for _, npc in pairs(npcFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < CONFIG.CombatRange then
                -- Matching your Remote Spy: [1]=Effect, [2]=Time, [3]=Weapon, [4]=Target
                AttackRemote:FireServer("HitEffect", tick(), "Sword", npc)
            end
        end
    end
end)

-- Hide Menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)
