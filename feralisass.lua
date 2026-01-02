-- feralisass.lua (V25 - SOLARA STABILITY & SMOOTH BYPASS)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V25") then
        game.CoreGui:FindFirstChild("Feralisass_V25"):Destroy()
    end
    task.wait(0.5)
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
    SantaDistance = 18,
    
    GeppoBypass = true,
    GeppoRate = 1.5, -- How many seconds between Sky Walks
    
    KillAuraEnabled = false,
    AuraRange = 70,
    AuraDelay = 0.5,
    CurrentTool = nil,
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    PresentFarm = false,
    MenuVisible = true
}

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 15)
local ClientEffect = Events and Events:FindFirstChild("ClientEffect")
local SkillRemote = Events and Events:FindFirstChild("skillManager")

-- [[ LOGGING ]] --
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry)
    if not IsOwner then return end
    pcall(function()
        local gui = game.CoreGui:FindFirstChild("Feralisass_V25")
        if gui then
            local box = gui.MainFrame.LogScroll.LogTextBox
            box.Text = entry .. "\n" .. box.Text
        end
    end)
end

-- [[ AUTO-ITEM SCANNER ]] --
local function GetWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check hand
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and not tool.Name:lower():find("plank") then return tool end
    end
    -- Check backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and not tool.Name:lower():find("plank") then return tool end
    end
    return nil
end

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V25"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "FERALISASS V25 | STABILITY FIX"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(70, 20, 20)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(20, 70, 20) or Color3.fromRGB(70, 20, 20)
    end)

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 280, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        CONFIG[adjustKey] = tonumber(box.Text) or box.Text
    end)
end

CreateControl("Smooth Glide Fly", 50, "FlyEnabled", "FlySpeed", "Speed (Safe 28)")
CreateControl("Santa Smooth Farm", 120, "SantaFarm", "SantaDistance", "Height (18)")
CreateControl("Geppo Reset (Secs)", 190, "GeppoBypass", "GeppoRate", "Pulse Rate (1.5)")
CreateControl("Auto-Weapon Aura", 260, "KillAuraEnabled", "AuraDelay", "Hit Speed (0.5)")
CreateControl("Hitbox Expander", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Present Collector", 400, "PresentFarm", "AuraRange", "Scan Range")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 510)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 120)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- GEPPO LOGS READY ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ MOVEMENT ENGINE ]] --
task.spawn(function()
    local lastGeppo = 0
    while not _G.FeralisassCleanup do
        local dt = RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if not root or not hum then continue end

        local targetPos = nil
        if CONFIG.SantaFarm then
            local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
            if santa and santa:FindFirstChild("HumanoidRootPart") then
                targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
            end
        end

        -- GEPPO BYPASS (Spams Geppo State to reset strikes)
        if CONFIG.GeppoBypass and (CONFIG.FlyEnabled or CONFIG.SantaFarm) then
            if tick() - lastGeppo > CONFIG.GeppoRate then
                pcall(function()
                    SkillRemote:FireServer("Sky Walk", 20, false)
                    SkillRemote:FireServer("Sky Walk", 0.2)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
                lastGeppo = tick()
                AddLog("Geppo Pulse Sent.")
            end
        end

        -- GLIDE MOVEMENT
        if targetPos or CONFIG.FlyEnabled then
            if targetPos then
                local dir = (targetPos - root.Position).Unit
                local dist = (targetPos - root.Position).Magnitude
                if dist > 0.5 then
                    -- STRICT SPEED: Moves at exactly CONFIG.FlySpeed studs per second
                    root.CFrame = root.CFrame + (dir * math.min(dist, CONFIG.FlySpeed * dt))
                end
                root.Velocity = Vector3.new(0, 0.1, 0) -- Kill gravity
            elseif CONFIG.FlyEnabled then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                root.CFrame = root.CFrame + (dir * CONFIG.FlySpeed * dt)
                root.Velocity = Vector3.new(0, 0.1, 0)
            end
        end
    end
end)

-- [[ AURA ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root or not CONFIG.KillAuraEnabled then continue end

        local weapon = GetWeapon()
        if weapon then
            if weapon.Parent ~= char then LocalPlayer.Humanoid:EquipTool(weapon) end
            
            local npcFolder = workspace:FindFirstChild("NPCs")
            if npcFolder then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - root.Position).Magnitude < CONFIG.AuraRange then
                        if CONFIG.HitboxEnabled then hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize) end
                        pcall(function() ClientEffect:FireServer("HitEffect", tick(), weapon.Name, npc) end)
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("V25 Active. Solara Mode Enabled.")
