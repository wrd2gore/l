-- feralisass.lua (SOLARA DIRECT EXECUTE VERSION)
print("--- [feralisass] INITIALIZING ---")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    speed = 21,
    jumpPower = 92,
    currentWeaponIndex = 1
}

-- REMOTE CHECKING (Look at F9 Console if this fails)
print("[feralisass] Looking for Remotes folder...")
local remotes = ReplicatedStorage:FindFirstChild("Remotes")

if not remotes then
    -- Try to find any folder that might contain events if "Remotes" is the wrong name
    warn("[feralisass] 'Remotes' folder not found. Searching for alternatives...")
    remotes = ReplicatedStorage:FindFirstChildOfClass("Folder") 
end

if not remotes then
    warn("[feralisass] ERROR: No remote folder found in ReplicatedStorage.")
    return
end

local damageEvent = remotes:FindFirstChild("DamageEvent") or remotes:FindFirstChildWhichIsA("RemoteEvent")

if not damageEvent then
    warn("[feralisass] ERROR: Could not find a Damage Remote Event.")
else
    print("[feralisass] Found Remote: " .. damageEvent.Name)
end

local weapons = {
    {name = "Sword", damage = 15, cooldown = 0.8, range = 15},
    {name = "Bow", damage = 10, cooldown = 1.2, range = 50},
    {name = "Staff", damage = 25, cooldown = 2.5, range = 30}
}

local lastAttack = 0

-- Combat Logic
local function getTarget()
    local closest, dist = nil, 30
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = character.HumanoidRootPart.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                closest = p
                dist = mag
            end
        end
    end
    return closest, dist
end

local function attack()
    local weapon = weapons[CONFIG.currentWeaponIndex]
    if (tick() - lastAttack) < weapon.cooldown then return end
    
    local target, distance = getTarget()
    if target and distance <= weapon.range then
        lastAttack = tick()
        damageEvent:FireServer(target, weapon.damage, CONFIG.currentWeaponIndex)
        print("[feralisass] Hit: " .. target.Name .. " (" .. weapon.name .. ")")
    end
end

-- Controls
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        attack()
    end
end)

-- Stats Apply
local function apply()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.WalkSpeed = CONFIG.speed
        hum.JumpPower = CONFIG.jumpPower
        print("[feralisass] Stats Applied Successfully.")
    end
end

apply()
LocalPlayer.CharacterAdded:Connect(apply)
print("--- [feralisass] LOADED SUCCESSFULLY ---")
