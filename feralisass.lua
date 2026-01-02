-- feralisass.lua (V12 - PLATFORM FLY BYPASS & SANTA/GIFT AUTO-FARM)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V12") then
        game.CoreGui:FindFirstChild("Feralisass_V12"):Destroy()
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
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.4,
    WeaponName = "Sword", -- Melee weapon name
    
    SantaFarm = false,
    SantaDistance = 16, -- Safe distance (keeps you low enough)
    
    PresentFarm = false,
    
    MenuVisible = true
}

-- [[ LOGGING SYSTEM ]] --
local Logs = {}
local function AddLog(msg)
    local timestamp = os.date("%X")
    local entry = "[" .. timestamp .. "] " .. msg
    print("[FERALISASS] " .. entry)
    if not IsOwner then return end
    table.insert(Logs, 1, entry)
    if #Logs > 150 then table.remove(Logs, #Logs) end
    pcall(function()
        local box = game.CoreGui.Feralisass_V12.MainFrame.LogScroll.LogTextBox
        box.Text = table.concat(Logs, "\n")
        game.CoreGui.Feralisass_V12.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
    end)
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V12"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "FERALISASS V12 | ULTIMATE BYPASS"
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
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        CONFIG[adjustKey] = val or box.Text
        AddLog("Updated " .. adjustKey .. " to " .. box.Text)
    end)
end

-- Controls
CreateControl("Platform Fly", 50, "FlyEnabled", "FlySpeed", "Speed (1-200)")
CreateControl("Santa Farm", 120, "SantaFarm", "SantaDistance", "Distance Below (Keep >15)")
CreateControl("Present Farm", 190, "PresentFarm", "AuraRange", "Scan Range")
CreateControl("Melee Weapon", 260, "KillAuraEnabled", "WeaponName", "Weapon Name (Ex: Sword)")
CreateControl("Hitbox Scaling", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Attack Delay", 400, "KillAuraEnabled", "AuraDelay", "Cooldown (Secs)")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 460)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    LogScroll.BorderSizePixel = 0
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(80, 255, 80)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- OWNER LOGS READY | CTRL+C TO COPY ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ PLATFORM FLY ENGINE ]] --
local platform = Instance.new("Part")
platform.Size = Vector3.new(6, 1, 6)
platform.Transparency = 1
platform.Anchored = true
platform.CanCollide = true
platform.Parent = workspace
_G.FlyPlatform = platform

task.spawn(function()
    while not _G.FeralisassCleanup do
        RunService.Heartbeat:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if CONFIG.FlyEnabled or CONFIG.SantaFarm then
            platform.CanCollide = true
            
            local targetPos = root.Position
            if CONFIG.SantaFarm then
                local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
                if santa and santa:FindFirstChild("HumanoidRootPart") then
                    targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
                end
            end

            -- Movement Logic
            if CONFIG.SantaFarm then
                root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, targetPos + root.CFrame.LookVector), 0.1)
            elseif CONFIG.FlyEnabled then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                
                root.Velocity = dir * CONFIG.FlySpeed
                -- Vertical adjustment (Q/E)
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then root.CFrame = root.CFrame + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then root.CFrame = root.CFrame + Vector3.new(0, -1, 0) end
            end
            
            -- Keep platform under feet to trick Anti-Cheat
            platform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        else
            platform.CanCollide = false
            platform.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

-- [[ AURA & PRESENT ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        -- Present Farm
        if CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:lower():find("present") or obj.Name:lower():find("gift")) and obj:IsA("BasePart") then
                    if (obj.Position - myRoot.Position).Magnitude < 200 then
                        myRoot.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2)
                        AddLog("Collected Gift!")
                    end
                end
            end
        end

        -- Kill Aura
        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder and CONFIG.KillAuraEnabled then
            for _, npc in pairs(npcFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if CONFIG.HitboxEnabled then
                        hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                        hrp.CanCollide = false
                    end
                    if (hrp.Position - myRoot.Position).Magnitude < CONFIG.AuraRange then
                        pcall(function() ClientEffect:FireServer("HitEffect", tick(), CONFIG.WeaponName, npc) end)
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("Feralisass V12 Loaded | Platform Bypass Active.")
