-- feralisass.lua (V14 - SKILL SPOOF & SMOOTH GLIDE)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V14") then
        game.CoreGui:FindFirstChild("Feralisass_V14"):Destroy()
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
    FlySpeed = 50,
    
    SantaFarm = false,
    SantaDistance = 17, -- Distance to stay below Santa
    
    SkillBypass = true, -- Fires Concasser to trick height limit
    WeaponName = "Sword",
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.5,
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    PresentFarm = false,
    MenuVisible = true
}

-- [[ LOGGING ]] --
local Logs = {}
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry)
    if not IsOwner then return end
    table.insert(Logs, 1, entry)
    if #Logs > 150 then table.remove(Logs, #Logs) end
    pcall(function()
        local box = game.CoreGui.Feralisass_V14.MainFrame.LogScroll.LogTextBox
        box.Text = table.concat(Logs, "\n")
        game.CoreGui.Feralisass_V14.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")
local SkillManager = Events:FindFirstChild("skillManager")

-- [[ GUI ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V14"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 550)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "FERALISASS V14 | SKILL BYPASS MODE"
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
        AddLog(name .. " toggled.")
    end)

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 280, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        CONFIG[adjustKey] = tonumber(box.Text) or box.Text
        AddLog("Adjusted " .. adjustKey .. " to " .. box.Text)
    end)
end

CreateControl("Smooth Fly", 50, "FlyEnabled", "FlySpeed", "Fly Speed (1-150)")
CreateControl("Santa Skill Farm", 120, "SantaFarm", "SantaDistance", "Distance (Stay ~17)")
CreateControl("Equip Weapon", 190, "KillAuraEnabled", "WeaponName", "Weapon Name (Ex: Katana)")
CreateControl("Present Sniper", 260, "PresentFarm", "AuraRange", "Collect Range")
CreateControl("NPC Hitbox", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Farm Delay", 400, "KillAuraEnabled", "AuraDelay", "Aura Speed (0.4 is safe)")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 480)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    LogScroll.BorderSizePixel = 0
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 150)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- OWNER BYPASS CONSOLE ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ THE BYPASS ENGINE ]] --
local platform = Instance.new("Part")
platform.Size = Vector3.new(10, 1, 10)
platform.Transparency = 1
platform.Anchored = true
platform.Parent = workspace
_G.FlyPlatform = platform

task.spawn(function()
    local lastSkillUse = 0
    while not _G.FeralisassCleanup do
        RunService.Heartbeat:Wait()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- 1. CONCASSER SKILL SPOOF (Bypasses Height Checks)
        if (CONFIG.FlyEnabled or CONFIG.SantaFarm) and CONFIG.SkillBypass then
            if tick() - lastSkillUse > 4 then -- Fire every 4 seconds to maintain 'Skill State'
                pcall(function()
                    SkillManager:FireServer("Concasser", 20, false)
                end)
                lastSkillUse = tick()
                AddLog("Spoofing Skill State (Concasser)...")
            end
        end

        if CONFIG.FlyEnabled or CONFIG.SantaFarm then
            platform.CanCollide = true
            
            if CONFIG.SantaFarm then
                local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
                if santa and santa:FindFirstChild("HumanoidRootPart") then
                    -- SMOOTH GLIDE: Proportional movement to avoid Y-Axis Kicks
                    local targetCFrame = santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)
                    local distanceToSanta = (targetCFrame.Position - root.Position).Magnitude
                    
                    if distanceToSanta > 50 then
                        -- Fast travel if far away
                        root.CFrame = root.CFrame:Lerp(targetCFrame, 0.05)
                    else
                        -- Precision glide if close
                        root.CFrame = root.CFrame:Lerp(targetCFrame, 0.1)
                        -- Match Santa's Velocity to look natural
                        root.Velocity = santa.HumanoidRootPart.Velocity
                    end
                end
            elseif CONFIG.FlyEnabled then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                root.Velocity = dir * CONFIG.FlySpeed
            end
            
            platform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        else
            platform.CanCollide = false
            platform.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

-- [[ COMBAT & LOOT ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- Auto-Equip Weapon
        if CONFIG.KillAuraEnabled then
            local tool = LocalPlayer.Backpack:FindFirstChild(CONFIG.WeaponName) or char:FindFirstChild(CONFIG.WeaponName)
            if tool and tool.Parent ~= char then
                char.Humanoid:EquipTool(tool)
            end
        end

        -- Santa/NPC Aura
        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder and CONFIG.KillAuraEnabled then
            for _, npc in pairs(npcFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if CONFIG.HitboxEnabled then
                        hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                    end
                    if (hrp.Position - root.Position).Magnitude < CONFIG.AuraRange then
                        pcall(function() ClientEffect:FireServer("HitEffect", tick(), CONFIG.WeaponName, npc) end)
                    end
                end
            end
        end

        -- Present Sniper
        if CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:lower():find("present") or obj.Name:lower():find("gift")) and obj:IsA("BasePart") then
                    if (obj.Position - root.Position).Magnitude < 200 then
                        root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2)
                        AddLog("Collected Present!")
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("Feralisass V14 Loaded. Skill Spoofing Ready.")
