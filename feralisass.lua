-- feralisass.lua (V6 - OWNER-ONLY ADMIN & LOG SYSTEM)

-- [[ OWNER CHECK ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

-- [[ DISCORD WEBHOOK (Optional) ]] --
-- Put your Discord Webhook URL inside the quotes below to receive logs on Discord
local WEBHOOK_URL = "" 

-- [[ CLEAN-UP SYSTEM ]] --
if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V6") then
        game.CoreGui:FindFirstChild("Feralisass_V6"):Destroy()
    end
    task.wait(0.3)
end
_G.FeralisassRunning = true
_G.FeralisassCleanup = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
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
    if not IsOwner then return end
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    table.insert(Logs, 1, entry)
    if #Logs > 50 then table.remove(Logs, #Logs) end
    
    -- Update UI if it exists
    if game.CoreGui:FindFirstChild("Feralisass_V6") then
        local logBox = game.CoreGui.Feralisass_V6.MainFrame:FindFirstChild("LogScroll")
        if logBox then
            logBox.TextLabel.Text = table.concat(Logs, "\n")
            logBox.CanvasSize = UDim2.new(0, 0, 0, #Logs * 15)
        end
    end
end

-- Webhook Execution Log
if WEBHOOK_URL ~= "" then
    pcall(function()
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "Script Executed!",
                ["description"] = "User: " .. LocalPlayer.Name .. "\nID: " .. LocalPlayer.UserId .. "\nGame: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
                ["color"] = 16711680
            }}
        }
        -- Note: Solara might need 'request' or 'http_request'
        if request then
            request({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
        end
    end)
end

-- [[ REMOTE SETUP ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events and Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V6"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 500 or 250, 0, 420) -- Expand for owner
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "FERALISASS V6 - " .. (IsOwner and "OWNER ADMIN" or "GUEST")
Title.TextColor3 = Color3.new(1, 1, 1)

-- Standard UI Layout (Left Side)
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
        AddLog("Toggled " .. name .. " " .. (CONFIG[configKey] and "ON" or "OFF"))
    end)
end

CreateToggle("Safe Fly", 50, "FlyEnabled")
CreateToggle("Hitbox Expander", 130, "HitboxEnabled")
CreateToggle("Kill Aura", 210, "KillAuraEnabled")

-- OWNER ONLY LOG PANEL (Right Side)
if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Name = "LogScroll"
    LogScroll.Size = UDim2.new(0, 230, 0, 350)
    LogScroll.Position = UDim2.new(0, 255, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogScroll.BorderSizePixel = 0
    LogScroll.ScrollBarThickness = 4
    
    local LogLabel = Instance.new("TextLabel", LogScroll)
    LogLabel.Size = UDim2.new(1, -10, 1, 0)
    LogLabel.BackgroundTransparency = 1
    LogLabel.TextColor3 = Color3.new(0.4, 1, 0.4) -- Matrix Green
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.TextYAlignment = Enum.TextYAlignment.Top
    LogLabel.TextSize = 12
    LogLabel.Text = "--- OWNER LOGS READY ---"
    LogLabel.TextWrapped = true
end

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
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            bv.Velocity = dir * CONFIG.FlySpeed
        else
            bv.Parent, bg.Parent = nil, nil
        end
    end
end)

-- Hitbox & Kill Aura Engine
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
                end
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < CONFIG.AuraRange and ClientEffect then
                    ClientEffect:FireServer("HitEffect", tick(), "Sword", npc)
                    AddLog("Killed: " .. npc.Name)
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

AddLog("System Started as Owner.")
print("--- Feralisass V6 OWNER-MODE Active ---")
