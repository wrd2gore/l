-- feralisass.lua (V21 - SKILL-STATE BYPASS & GEPPO PULSE)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V21") then
        game.CoreGui:FindFirstChild("Feralisass_V21"):Destroy()
    end
    if _G.FlyPlatform then _G.FlyPlatform:Destroy() end
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
    FlySpeed = 26, 
    
    SantaFarm = false,
    SantaDistance = 18, -- Increased for extra safety
    
    GeppoPulseEnabled = true,
    GeppoInterval = 2, -- Reset strikes every 2 seconds as requested
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.5,
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
        local box = game.CoreGui.Feralisass_V21.MainFrame.LogScroll.LogTextBox
        box.Text = entry .. "\n" .. box.Text
        game.CoreGui.Feralisass_V21.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ AUTO-ITEM DETECTION ]] --
local function UpdateCombatTool()
    local tool = nil
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and not v.Name:lower():find("plank") and not v.Name:lower():find("hammer") then
            tool = v break
        end
    end
    if not tool then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and not v.Name:lower():find("plank") and not v.Name:lower():find("hammer") then
                tool = v break
            end
        end
    end
    if tool and (not CONFIG.CurrentTool or CONFIG.CurrentTool.Name ~= tool.Name) then
        CONFIG.CurrentTool = tool
        AddLog("Weapon Detected: " .. tool.Name)
    end
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")
local SkillRemote = Events:FindFirstChild("skillManager")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V21"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "FERALISASS V21 | SKILL-STATE BYPASS"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(20, 60, 20) or Color3.fromRGB(60, 20, 20)
    end)

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 280, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        CONFIG[adjustKey] = tonumber(box.Text) or box.Text
    end)
end

CreateControl("Bypass Glide Fly", 50, "FlyEnabled", "FlySpeed", "Speed (Keep ~26)")
CreateControl("Santa Skill Farm", 120, "SantaFarm", "SantaDistance", "Safe Distance (18)")
CreateControl("Strike Reset Rate", 190, "GeppoPulseEnabled", "GeppoInterval", "Pulse Interval (2)")
CreateControl("Combat Aura", 260, "KillAuraEnabled", "AuraDelay", "Aura Delay (0.5)")
CreateControl("NPC Hitbox", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Collect Gifts", 400, "PresentFarm", "AuraRange", "Claim Range")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 510)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 120)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- ADMIN BYPASS LOGS ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ BYPASS & GEPPO ENGINE ]] --
task.spawn(function()
    local lastPulse = 0
    while not _G.FeralisassCleanup do
        local dt = RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local targetPos = nil

        -- Santa/Present Logic
        if CONFIG.SantaFarm then
            local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
            if santa and santa:FindFirstChild("HumanoidRootPart") then
                targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
            end
        elseif CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:lower():find("present") or obj.Name:lower():find("gift")) and obj:IsA("BasePart") then
                    if (obj.Position - root.Position).Magnitude < 400 then
                        targetPos = obj.Position + Vector3.new(0, 3, 0) break
                    end
                end
            end
        end

        if targetPos or CONFIG.FlyEnabled then
            -- GEPPO & SKILL BYPASS PULSE
            if CONFIG.GeppoPulseEnabled and tick() - lastPulse > CONFIG.GeppoInterval then
                pcall(function()
                    -- Sequence of 3 skills to completely trick Adonis/GPO Height Check
                    SkillRemote:FireServer("Sky Walk", 20, false)
                    SkillRemote:FireServer("Sky Walk", 0.2)
                    SkillRemote:FireServer("Concasser", 20, false) 
                end)
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                
                -- Tiny vertical jitter to help the server register the "Jump"
                root.Velocity = Vector3.new(root.Velocity.X, 4, root.Velocity.Z)
                
                lastPulse = tick()
                AddLog("Fired Skill Bypass Sequence (Geppo/Concasser)")
            end

            if targetPos then
                local direction = (targetPos - root.Position).Unit
                local distance = (targetPos - root.Position).Magnitude
                if distance > 1 then
                    -- Strict speed glide to prevent +Y Axis Too Fast
                    root.CFrame = root.CFrame + (direction * math.min(distance, CONFIG.FlySpeed * dt))
                end
                -- Match Santa's velocity to prevent jitter kicks
                if CONFIG.SantaFarm then root.Velocity = Vector3.new(0,0,0) end
            elseif CONFIG.FlyEnabled then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                root.CFrame = root.CFrame + (dir * CONFIG.FlySpeed * dt)
                root.Velocity = Vector3.new(0, 0.1, 0) -- Anti-falling gravity
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

        if CONFIG.CurrentTool.Parent ~= LocalPlayer.Character then
            LocalPlayer.Humanoid:EquipTool(CONFIG.CurrentTool)
        end

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
AddLog("V21 Loaded | Skill-State Bypass Ready.")
