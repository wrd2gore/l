-- feralisass.lua (V10 - PRESENT FARM & STRIKE BYPASS PRO)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V10") then
        game.CoreGui:FindFirstChild("Feralisass_V10"):Destroy()
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
    HeightBypass = true, -- Aggressive Strike Reset
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.4,
    WeaponName = "Sword", -- Type Melee Name (Katana, Combat, etc)
    
    SantaFarm = false,
    SantaDistance = 15,
    
    PresentFarm = false, -- Collects dropped gifts
    
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
    if #Logs > 100 then table.remove(Logs, #Logs) end
    pcall(function()
        local main = game.CoreGui:FindFirstChild("Feralisass_V10")
        if main then
            local box = main.MainFrame.LogScroll.LogTextBox
            box.Text = table.concat(Logs, "\n")
            main.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
        end
    end)
end

-- [[ REMOTES & EVENT HOOKS ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")
local NoteRemote = Events:FindFirstChild("note")

-- Hook into Santa's ThrowPresent and Item Notes
if ClientEffect then
    ClientEffect.OnClientEvent:Connect(function(...)
        local args = {...}
        if args[1] == "ThrowPresent" and CONFIG.PresentFarm then
            AddLog("Santa dropped a present! Auto-collecting...")
        end
    end)
end

if NoteRemote then
    NoteRemote.OnClientEvent:Connect(function(msg)
        if msg:find("New Item") then
            AddLog("LOOT: " .. msg:gsub("<[^>]+>", ""))
        elseif msg:find("Strike") then
            AddLog("STRIKE BLOCKED: " .. msg:gsub("<[^>]+>", ""))
        end
    end)
end

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V10"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "FERALISASS V10 | PRESENT FARM MODE"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(90, 25, 25)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        CONFIG[configKey] = not CONFIG[configKey]
        btn.Text = name .. ": " .. (CONFIG[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[configKey] and Color3.fromRGB(25, 90, 25) or Color3.fromRGB(90, 25, 25)
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
        local val = tonumber(box.Text)
        CONFIG[adjustKey] = val or box.Text
        AddLog("Setting " .. adjustKey .. " to: " .. box.Text)
    end)
end

-- Feature Controls
CreateControl("Safe Fly Bypass", 50, "FlyEnabled", "FlySpeed", "Speed (1-200)")
CreateControl("Santa Farm", 120, "SantaFarm", "SantaDistance", "Follow Dist (Studs)")
CreateControl("Present Farm", 190, "PresentFarm", "AuraRange", "Collect Range")
CreateControl("Melee Aura", 260, "KillAuraEnabled", "WeaponName", "Weapon Name (Ex: Katana)")
CreateControl("Hitbox Expander", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Aura Speed", 400, "KillAuraEnabled", "AuraDelay", "Cooldown (Secs)")

-- Owner Logs (Copyable)
if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 460)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    LogScroll.BorderSizePixel = 0
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 120)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- LOGS READY | CTRL+C TO COPY ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ CORE ENGINES ]] --

-- 1. FLY & SANTA FARM ENGINE (With Strike Bypass)
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    local lastReset = tick()

    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if CONFIG.FlyEnabled or CONFIG.SantaFarm then
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            -- STRIKE RESET: Forces character down to 14 studs every 1.5s
            if CONFIG.HeightBypass and tick() - lastReset > 1.5 then
                local ray = Ray.new(root.Position, Vector3.new(0, -100, 0))
                local _, pos = workspace:FindPartOnRay(ray, char)
                if pos then
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 14, 0))
                end
                lastReset = tick()
            end

            local targetPos = nil
            if CONFIG.SantaFarm then
                local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
                if santa and santa:FindFirstChild("HumanoidRootPart") then
                    targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
                end
            end

            if targetPos then
                root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, targetPos + Vector3.new(0, 10, 0)), 0.1)
                bv.Velocity = Vector3.new(0,0,0)
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

-- 2. PRESENT FARM & KILL AURA ENGINE
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        -- Present Collection
        if CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:find("Present") or obj.Name:find("Gift")) and obj:IsA("BasePart") then
                    if (obj.Position - myRoot.Position).Magnitude < 100 then
                        myRoot.CFrame = obj.CFrame
                        task.wait(0.1)
                        AddLog("Collected Present!")
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
                    end
                    if (hrp.Position - myRoot.Position).Magnitude < CONFIG.AuraRange then
                        ClientEffect:FireServer("HitEffect", tick(), CONFIG.WeaponName, npc)
                    end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("Feralisass V10 Active | Santa + Present Farm Ready.")
