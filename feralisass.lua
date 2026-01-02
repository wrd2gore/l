-- feralisass.lua (V9 - SANTA FARM & WEAPON SELECTOR)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V9") then
        game.CoreGui:FindFirstChild("Feralisass_V9"):Destroy()
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
    AutoDipEnabled = true, -- Resets Height Strikes
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.4,
    WeaponName = "Sword", -- Adjust this to your melee weapon name
    
    SantaFarm = false,
    SantaDistance = 15, -- Distance to stay below Santa
    
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
        local main = game.CoreGui:FindFirstChild("Feralisass_V9")
        if main then
            local box = main.MainFrame.LogScroll.LogTextBox
            box.Text = table.concat(Logs, "\n")
            main.MainFrame.LogScroll.CanvasSize = UDim2.new(0, 0, 0, box.TextBounds.Y + 20)
        end
    end)
end

-- [[ REMOTES ]] --
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local ClientEffect = Events:FindFirstChild("ClientEffect")
local NoteRemote = Events:FindFirstChild("note")

-- Hook Note Remote to catch strikes in UI Logs
if NoteRemote then
    NoteRemote.OnClientEvent:Connect(function(msg)
        if msg:find("Strike") then
            AddLog("SERVER WARNING: " .. msg:gsub("<[^>]+>", ""))
        end
    end)
end

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V9"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 600 or 300, 0, 500)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "FERALISASS V9 | SANTA FARM EDITION"
Title.TextColor3 = Color3.new(1, 1, 1)

local function CreateControl(name, yPos, configKey, adjustKey, placeholder)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 260, 0, 30)
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
    box.Size = UDim2.new(0, 260, 0, 25)
    box.Position = UDim2.new(0, 10, 0, yPos + 32)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.PlaceholderText = placeholder
    box.Text = tostring(CONFIG[adjustKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        CONFIG[adjustKey] = val or box.Text
        AddLog("Adjusted " .. adjustKey .. " to " .. box.Text)
    end)
end

-- UI Features
CreateControl("Bypass Fly", 50, "FlyEnabled", "FlySpeed", "Speed (1-200)")
CreateControl("Santa Farm", 120, "SantaFarm", "SantaDistance", "Follow Distance (Studs)")
CreateControl("Hitbox Scaling", 190, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Kill Aura", 260, "KillAuraEnabled", "AuraRange", "Range")
CreateControl("Weapon Select", 330, "KillAuraEnabled", "WeaponName", "Weapon Name (Ex: Katana)")

-- Owner Logs
if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 300, 0, 440)
    LogScroll.Position = UDim2.new(0, 285, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(0, 255, 100)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- ADMIN CONSOLE READY ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ ENGINES ]] --

-- Fly & Santa Follow Engine
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    local lastDip = tick()

    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if CONFIG.FlyEnabled or CONFIG.SantaFarm then
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            local targetPos = nil
            if CONFIG.SantaFarm then
                local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
                if santa and santa:FindFirstChild("HumanoidRootPart") then
                    targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
                end
            end

            -- Anti-Strike Bypass Logic
            if CONFIG.AutoDipEnabled and tick() - lastDip > 1.4 then
                -- Raycast to find floor
                local ray = Ray.new(root.Position, Vector3.new(0, -50, 0))
                local part, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if pos then
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 14, 0)) -- Reset to 14 studs high
                end
                lastDip = tick()
            end

            if targetPos then
                root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, santa.HumanoidRootPart.Position), 0.1)
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
                    hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
                    hrp.CanCollide = false
                end
                if CONFIG.KillAuraEnabled and (hrp.Position - myRoot.Position).Magnitude < CONFIG.AuraRange then
                    -- Fires using your specified weapon name
                    ClientEffect:FireServer("HitEffect", tick(), CONFIG.WeaponName, npc)
                    AddLog("Aura Hit -> " .. npc.Name .. " (" .. CONFIG.WeaponName .. ")")
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end end)
AddLog("Feralisass V9 Loaded. Ready for Santa.")
