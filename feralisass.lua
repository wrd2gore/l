-- feralisass.lua (V23 - ACTIVE STATE SPOOF & GEPPO SPAM)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V23") then
        game.CoreGui:FindFirstChild("Feralisass_V23"):Destroy()
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
    FlySpeed = 28, 
    
    SantaFarm = false,
    SantaDistance = 14.5, -- STAYING UNDER 15 IS THE ONLY 100% WAY
    
    GeppoSpam = true,
    SpamDelay = 0.1, -- High frequency to drown out the anti-cheat timer
    
    KillAuraEnabled = false,
    AuraRange = 100, -- Increased to reach Santa from the floor
    AuraDelay = 0.4,
    CurrentTool = nil, 
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    PresentFarm = false,
    MenuVisible = true
}

-- [[ LOGGING ]] --
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry)
    if not IsOwner then return end
    pcall(function()
        local box = game.CoreGui.Feralisass_V23.MainFrame.LogScroll.LogTextBox
        box.Text = entry .. "\n" .. box.Text
        game.CoreGui.Feralisass_V23.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ AUTO-ITEM DETECTION ]] --
local function UpdateCombatTool()
    local tool = nil
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and not v.Name:lower():find("plank") then tool = v break end
    end
    if not tool then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and not v.Name:lower():find("plank") then tool = v break end
        end
    end
    if tool and (not CONFIG.CurrentTool or CONFIG.CurrentTool.Name ~= tool.Name) then
        CONFIG.CurrentTool = tool
        AddLog("Equipped: " .. tool.Name)
    end
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")
local SkillRemote = Events:FindFirstChild("skillManager")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V23"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "FERALISASS V23 | ULTIMATE GEPPO BYPASS"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(20, 80, 20) or Color3.fromRGB(80, 20, 20)
    end)

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 280, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        CONFIG[adjustKey] = tonumber(box.Text) or box.Text
    end)
end

CreateControl("Fly (Geppo Mode)", 50, "FlyEnabled", "FlySpeed", "Speed (28)")
CreateControl("Santa Farm (Ground)", 120, "SantaFarm", "SantaDistance", "Max Height (14.5)")
CreateControl("Bypass Spam", 190, "GeppoSpam", "SpamDelay", "Spam Rate (0.1)")
CreateControl("Auto Aura", 260, "KillAuraEnabled", "AuraRange", "Aura Range (100)")
CreateControl("NPC Hitbox", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Present Collector", 400, "PresentFarm", "AuraDelay", "Collect Delay (0.5)")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 510)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 120)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- GEPPO BYPASS ACTIVE ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ BYPASS & GEPPO ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        local dt = RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not root or not hum then continue end

        -- GEPPO STATE SPOOF (Spamming every frame possible)
        if CONFIG.GeppoSpam and (CONFIG.FlyEnabled or CONFIG.SantaFarm) then
            pcall(function()
                SkillRemote:FireServer("Sky Walk", 20, false) -- Tell server we geppo'd
                hum:ChangeState(Enum.HumanoidStateType.Landed) -- Tell server we are on ground
            end)
        end

        local targetPos = nil
        if CONFIG.SantaFarm then
            local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
            if santa and santa:FindFirstChild("HumanoidRootPart") then
                -- NEW LOGIC: Follow Santa but STAY 14 STUDS ABOVE THE FLOOR
                local ray = Ray.new(santa.HumanoidRootPart.Position, Vector3.new(0, -500, 0))
                local _, floorPos = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace:FindFirstChild("NPCs")})
                
                if floorPos then
                    targetPos = floorPos + Vector3.new(0, CONFIG.SantaDistance, 0)
                end
            end
        end

        -- Movement
        if targetPos or CONFIG.FlyEnabled then
            if targetPos then
                -- Move towards the spot under Santa
                local direction = (targetPos - root.Position).Unit
                local distance = (targetPos - root.Position).Magnitude
                if distance > 1 then
                    root.CFrame = root.CFrame + (direction * math.min(distance, CONFIG.FlySpeed * dt))
                end
            elseif CONFIG.FlyEnabled then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                root.CFrame = root.CFrame + (dir * CONFIG.FlySpeed * dt)
            end
        end
    end
end)

-- [[ AURA ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        UpdateCombatTool()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not CONFIG.KillAuraEnabled or not CONFIG.CurrentTool then continue end

        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder then
            for _, npc in pairs(npcFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - root.Position).Magnitude < CONFIG.AuraRange then
                    if CONFIG.HitboxEnabled then hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize) end
                    pcall(function() ClientEffect:FireServer("HitEffect", tick(), CONFIG.CurrentTool.Name, npc) end)
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("V23 Ready | Spam Bypass Active.")
