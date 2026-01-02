-- feralisass.lua (V8 - TOTAL CONTROL & AUTO-ADJUST MENU)

-- [[ OWNER CHECK ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

-- [[ CLEAN-UP SYSTEM ]] --
if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V8") then
        game.CoreGui:FindFirstChild("Feralisass_V8"):Destroy()
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
    FlyBypassHeight = 14, -- Resets at this height
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.4,
    
    MenuVisible = true
}

-- [[ LOGGING SYSTEM ]] --
local Logs = {}
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry) -- F9 Console
    
    if not IsOwner then return end
    table.insert(Logs, 1, entry)
    if #Logs > 100 then table.remove(Logs, #Logs) end
    
    pcall(function()
        local box = game.CoreGui.Feralisass_V8.MainFrame.LogScroll.LogTextBox
        box.Text = table.concat(Logs, "\n")
        game.CoreGui.Feralisass_V8.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ REMOTE SETUP ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events and Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V8"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 580 or 280, 0, 450)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "FERALISASS V8 | OWNER: " .. OWNER_NAME
Title.TextColor3 = Color3.new(1, 1, 1)

-- UI SYSTEM: Every feature gets a Toggle + Input
local function CreateControlPair(name, yPos, configKey, adjustKey, adjustPlaceholder)
    -- Toggle Button
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 240, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(20, 80, 20) or Color3.fromRGB(80, 20, 20)
        AddLog(name .. " switched " .. (CONFIG[configKey] and "ON" or "OFF"))
    end)

    -- Adjustment Box
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 240, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 35)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.Text = tostring(CONFIG[adjustKey])
    box.PlaceholderText = adjustPlaceholder
    box.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    box.BorderSizePixel = 0
    
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then 
            CONFIG[adjustKey] = n 
            AddLog("Set " .. adjustKey .. " to " .. n)
        end
    end)
end

-- Feature Pairs
CreateControlPair("Bypass Fly", 50, "FlyEnabled", "FlySpeed", "Speed (1-200)")
CreateControlPair("Hitbox Expander", 120, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControlPair("Kill Aura", 190, "KillAuraEnabled", "AuraRange", "Range (Studs)")
CreateControlPair("Aura Speed", 260, "KillAuraEnabled", "AuraDelay", "Delay (Lower = Faster)")

-- OWNER LOGS (Right Side)
if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Name = "LogScroll"
    LogScroll.Size = UDim2.new(0, 280, 0, 380)
    LogScroll.Position = UDim2.new(0, 270, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    LogScroll.BorderSizePixel = 0
    
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(50, 255, 50)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextSize = 11
    LogTextBox.Text = "--- LOGS (CTRL+C TO COPY) ---"
    LogTextBox.MultiLine = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false
    LogTextBox.TextWrapped = true
end

-- [[ ENGINES ]] --

-- Enhanced Fly Bypass
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    local lastDip = tick()
    
    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if CONFIG.FlyEnabled and root then
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            -- Anti-Strike Dip
            if tick() - lastDip > 1.5 then
                bv.Velocity = Vector3.new(0, -60, 0) -- Aggressive dip
                task.wait(0.05)
                lastDip = tick()
            else
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                bv.Velocity = dir * CONFIG.FlySpeed
            end
        else
            bv.Parent, bg.Parent = nil, nil
        end
    end
end)

-- Hitbox & Aura Engine
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder then continue end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        for _, npc in pairs(npcFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                if CONFIG.HitboxEnabled then
                    local s = math.min(CONFIG.HitboxSize, 20)
                    hrp.Size = Vector3.new(s, s, s)
                    hrp.Transparency = 0.8
                end
                
                if CONFIG.KillAuraEnabled and (hrp.Position - myRoot.Position).Magnitude < CONFIG.AuraRange then
                    if ClientEffect then
                        ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                        AddLog("Hit NPC: " .. npc.Name)
                    end
                end
            end
        end
    end
end)

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)

AddLog("Feralisass V8 Initialized.")
