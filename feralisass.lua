-- feralisass.lua (V19 - STRICT GLIDE & AUTO-ITEM DETECTION)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V19") then
        game.CoreGui:FindFirstChild("Feralisass_V19"):Destroy()
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
    FlySpeed = 28, -- Capped to walking speed for bypass
    
    SantaFarm = false,
    SantaDistance = 17,
    
    PresentFarm = false,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.5,
    CurrentTool = nil, -- Auto-detected
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    MenuVisible = true
}

-- [[ LOGGING SYSTEM ]] --
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry)
    if not IsOwner then return end
    pcall(function()
        local box = game.CoreGui.Feralisass_V19.MainFrame.LogScroll.LogTextBox
        box.Text = entry .. "\n" .. box.Text
        game.CoreGui.Feralisass_V19.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ AUTO-ITEM DETECTION ]] --
local function UpdateCombatTool()
    local tool = nil
    -- Search character first
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and not v.Name:lower():find("plank") and not v.Name:lower():find("hammer") then
            tool = v
            break
        end
    end
    -- Search backpack if not in hand
    if not tool then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and not v.Name:lower():find("plank") and not v.Name:lower():find("hammer") then
                tool = v
                break
            end
        end
    end
    
    if tool and (not CONFIG.CurrentTool or CONFIG.CurrentTool.Name ~= tool.Name) then
        CONFIG.CurrentTool = tool
        AddLog("Combat Item Detected: " .. tool.Name)
    end
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V19"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 20, 30)
Title.Text = "FERALISASS V19 | AUTO-DETECT & GLIDE"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(80, 30, 30)
    end)

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 280, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        CONFIG[adjustKey] = tonumber(box.Text) or box.Text
    end)
end

CreateControl("Strict Glide Fly", 50, "FlyEnabled", "FlySpeed", "Glide Speed (Safe: 28)")
CreateControl("Santa Auto-Farm", 120, "SantaFarm", "SantaDistance", "Safe Height (17)")
CreateControl("Present Auto-Claim", 190, "PresentFarm", "AuraRange", "Collect Scan Range")
CreateControl("Combat Aura", 260, "KillAuraEnabled", "AuraDelay", "Aura Speed (0.5)")
CreateControl("NPC Hitbox", 330, "HitboxEnabled", "HitboxSize", "Hitbox Size (Max 20)")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 510)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(10, 5, 10)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(150, 255, 150)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- AUTO-LOG CONSOLE ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ THE GLIDE ENGINE ]] --
local platform = Instance.new("Part")
platform.Size = Vector3.new(12, 1, 12)
platform.Transparency = 1
platform.Anchored = true
platform.Parent = workspace
_G.FlyPlatform = platform

task.spawn(function()
    local lastGeppo = 0
    while not _G.FeralisassCleanup do
        local dt = RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local targetPos = nil

        -- Determine Target
        if CONFIG.SantaFarm then
            local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
            if santa and santa:FindFirstChild("HumanoidRootPart") then
                targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
            end
        elseif CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:lower():find("present") or obj.Name:lower():find("gift")) and obj:IsA("BasePart") then
                    if (obj.Position - root.Position).Magnitude < 400 then
                        targetPos = obj.Position + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end

        -- Execute Glide (NO TELEPORTING)
        if targetPos or CONFIG.FlyEnabled then
            platform.CanCollide = true
            platform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
            
            -- Geppo Strike Reset every 2s
            if tick() - lastGeppo > 2 then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastGeppo = tick()
            end

            if targetPos then
                local direction = (targetPos - root.Position).Unit
                local distance = (targetPos - root.Position).Magnitude
                
                if distance > 1 then
                    -- This line forces the character to move at EXACTLY CONFIG.FlySpeed studs per second
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
        else
            platform.CanCollide = false
            platform.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

-- [[ AURA & ITEM SCANNER ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        UpdateCombatTool() -- Scan for swords/fruits
        
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not CONFIG.KillAuraEnabled or not CONFIG.CurrentTool then continue end

        -- Auto-Equip
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
AddLog("V19 Ready. Strict Glide & Auto-Item active.")
