-- feralisass.lua (V11 - ADONIS BYPASS & SMOOTH FARM)

-- [[ OWNER CHECK & CLEAN-UP ]] --
local OWNER_NAME = "felthorrified"
local IsOwner = (game.Players.LocalPlayer.Name == OWNER_NAME)

if _G.FeralisassRunning then
    _G.FeralisassCleanup = true
    if game.CoreGui:FindFirstChild("Feralisass_V11") then
        game.CoreGui:FindFirstChild("Feralisass_V11"):Destroy()
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
    SafeMode = true, -- Prevents +Y Axis kicks
    
    HitboxEnabled = false,
    HitboxSize = 15,
    
    KillAuraEnabled = false,
    AuraRange = 60,
    AuraDelay = 0.5, -- Increased slightly for stability
    WeaponName = "Sword",
    
    SantaFarm = false,
    SantaDistance = 15,
    
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
    if #Logs > 100 then table.remove(Logs, #Logs) end
    pcall(function()
        local main = game.CoreGui:FindFirstChild("Feralisass_V11")
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

if NoteRemote then
    NoteRemote.OnClientEvent:Connect(function(msg)
        if msg:find("Strike") then
            AddLog("BYPASSING: " .. msg:gsub("<[^>]+>", ""))
        end
    end)
end

-- [[ GUI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Feralisass_V11"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, IsOwner and 620 or 310, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Text = "FERALISASS V11 | ADONIS BYPASS"
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
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderSizePixel = 0
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        CONFIG[adjustKey] = val or box.Text
    end)
end

CreateControl("Smooth Fly", 50, "FlyEnabled", "FlySpeed", "Speed (1-200)")
CreateControl("Santa Farm", 120, "SantaFarm", "SantaDistance", "Follow Dist (Keep 15+)")
CreateControl("Present Farm", 190, "PresentFarm", "AuraRange", "Collect Range")
CreateControl("Weapon Aura", 260, "KillAuraEnabled", "WeaponName", "Weapon Name")
CreateControl("Hitbox Expander", 330, "HitboxEnabled", "HitboxSize", "Size (Max 20)")
CreateControl("Attack Speed", 400, "KillAuraEnabled", "AuraDelay", "Cooldown (Min 0.4)")

if IsOwner then
    local LogScroll = Instance.new("ScrollingFrame", MainFrame)
    LogScroll.Size = UDim2.new(0, 310, 0, 460)
    LogScroll.Position = UDim2.new(0, 300, 0, 50)
    LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    local LogTextBox = Instance.new("TextBox", LogScroll)
    LogTextBox.Name = "LogTextBox"
    LogTextBox.Size = UDim2.new(1, -10, 1, 5000)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.TextColor3 = Color3.fromRGB(100, 255, 100)
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.Text = "--- BYPASS CONSOLE ACTIVE ---"
    LogTextBox.MultiLine, LogTextBox.ClearTextOnFocus, LogTextBox.TextEditable = true, false, false
end

-- [[ CORE ENGINE - SMOOTH MOVEMENT ]] --
task.spawn(function()
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    local lastReset = tick()

    while not _G.FeralisassCleanup do
        RunService.RenderStepped:Wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if CONFIG.FlyEnabled or CONFIG.SantaFarm or CONFIG.PresentFarm then
            bv.Parent, bg.Parent = root, root
            bv.MaxForce, bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9), Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = Camera.CFrame
            
            local targetPos = nil
            
            -- 1. Santa Farm Logic (Smooth Follow)
            if CONFIG.SantaFarm then
                local santa = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Santa's Sleigh")
                if santa and santa:FindFirstChild("HumanoidRootPart") then
                    targetPos = (santa.HumanoidRootPart.CFrame * CFrame.new(0, -CONFIG.SantaDistance, 0)).Position
                end
            end

            -- 2. Anti-Strike Bypass (Slow Sink instead of Snap)
            if tick() - lastReset > 1.8 then
                bv.Velocity = Vector3.new(0, -15, 0) -- Slow sink to trick floor check
                task.wait(0.1)
                lastReset = tick()
            end

            -- 3. Movement Execution
            if targetPos then
                -- LERP instead of snapping CFrame to prevent "+Y Axis too fast"
                root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, targetPos + Camera.CFrame.LookVector), 0.08)
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

-- [[ PRESENT & AURA ENGINE ]] --
task.spawn(function()
    while not _G.FeralisassCleanup do
        task.wait(CONFIG.AuraDelay)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        -- Present Farm (Smooth Travel)
        if CONFIG.PresentFarm then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:find("Present") or obj.Name:find("Gift")) and obj:IsA("BasePart") then
                    local dist = (obj.Position - myRoot.Position).Magnitude
                    if dist < 150 then
                        -- Move smoothly to present
                        for i = 0, 1, 0.1 do
                            if not CONFIG.PresentFarm then break end
                            myRoot.CFrame = myRoot.CFrame:Lerp(obj.CFrame, i)
                            task.wait()
                        end
                        AddLog("Collected Gift smoothly.")
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
AddLog("Feralisass V11 Loaded | Adonis Bypass Mode.")
