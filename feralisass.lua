-- feralisass.lua (V7 - FLY BYPASS & COPYABLE LOGS)

-- [[ OWNER CHECK ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

-- [[ CLEAN-UP SYSTEM ]] --
if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V7") then
        game.CoreGui:FindFirstChild("Feralisass_V7"):Destroy()
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
    HitboxSize = 15,
    KillAuraEnabled = false,
    AuraRange = 60,
    AttackDelay = 0.4,
    MenuVisible = true
}

-- [[ LOGGING SYSTEM ]] --
local Logs = {}
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    
    -- Print to F9 Console
    print("[FERALISASS] " .. entry)
    
    if not IsOwner then return end
    table.insert(Logs, 1, entry)
    if #Logs > 100 then table.remove(Logs, #Logs) end
    
    -- Update Copyable UI TextBox
    pcall(function()
        local main = game.CoreGui:FindFirstChild("Feralisass_V7")
        if main then
            local box = main.MainFrame.LogScroll.LogTextBox
            box.Text = table.concat(Logs, "\n")
            main.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
        end
    end)
end

-- [[ REMOTE SETUP ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events and Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V7"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 550 or 250, 0, 420)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "FERALISASS V7 | " .. (IsOwner and "OWNER ADMIN" or "GUEST")
Title.TextColor3 = Color3.new(1, 1, 1)

-- Left Side Toggles
local function CreateToggle(name, yPos, configKey)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 220, 0, 35)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(20, 80, 20) or Color3.fromRGB(80, 20, 20)
    end)
end

CreateToggle("Safe Fly (Bypass)", 50, "FlyEnabled")
CreateToggle("Hitbox Expander", 130, "HitboxEnabled")
CreateToggle("Kill Aura", 210, "KillAuraEnabled")

-- Right Side COPYABLE LOGS (Owner Only)
if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Name = "LogScroll"
    LogScroll.Size = UDim2.new(0, 280, 0, 350)
    LogScroll.Position = UDim2.new(0, 255, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.ScrollBarThickness = 6

    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 1000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 100)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextSize = 12
    LogTextBox.Text = "--- CLICK HERE TO COPY LOGS ---"
    LogTextBox.MultiLine = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false -- Keeps it as logs but allows selection
    LogTextBox.TextWrapped = true
end

-- [[ FLY BYPASS ENGINE ]] --
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    local lastPulse = tick()

    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if CONFIG.FlyEnabled and root then
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            
            -- HEIGHT STRIKE BYPASS PULSE
            -- Every 1.8 seconds, we force the character down to reset the server height check
            if tick() - lastPulse > 1.8 then
                bv.Velocity = Vector3.new(0, -40, 0)
                task.wait(0.1)
                lastPulse = tick()
                AddLog("Bypassing Flight Strike...")
            else
                bv.Velocity = dir * CONFIG.FlySpeed
            end
        else
            bv.Parent, bg.Parent = nil, nil
        end
    end
end)

-- [[ HITBOX & KILL AURA ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AttackDelay)
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder or not CONFIG.KillAuraEnabled then continue end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        for _, npc in pairs(npcFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then
                if CONFIG.HitboxEnabled then
                    local size = math.min(CONFIG.HitboxSize, 20)
                    hrp.Size = Vector3.new(size, size, size)
                    hrp.Transparency = 0.8
                end
                
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < CONFIG.AuraRange and ClientEffect then
                    ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                    AddLog("Aura Hit: " .. npc.Name)
                end
            end
        end
    end
end)

-- Hide Menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)

AddLog("Feralisass V7 Ready for Owner.")
