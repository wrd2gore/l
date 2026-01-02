-- feralisass.lua (Optimized for Solara)
print("Attempting to load feralisass.lua...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    speed = 21,
    jumpPower = 92,
    maxHealth = 154,
    currentWeaponIndex = 1
}

-- Safe Remote Check (Solara can hang on WaitForChild)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotes then
    warn("CRITICAL: Remotes folder not found! Game might have updated.")
    return
end

local damageEvent = remotes:WaitForChild("DamageEvent", 5)
if not damageEvent then
    warn("CRITICAL: DamageEvent not found!")
    return
end

local weapons = {
    {name = "Sword", damage = 15, cooldown = 0.8, range = 12},
    {name = "Bow", damage = 10, cooldown = 1.2, range = 45},
    {name = "Staff", damage = 25, cooldown = 2.5, range = 25}
}

local lastAttack = 0

-- Function to get target
local function getTarget()
    local closest, dist = nil, 20 -- Max distance to look for
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
    if not myPos then return nil end

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

-- Weapon Logic
local function useWeapon()
    local weapon = weapons[CONFIG.currentWeaponIndex]
    if (tick() - lastAttack) < weapon.cooldown then return end
    
    local target, distance = getTarget()
    
    if target and distance <= weapon.range then
        lastAttack = tick()
        -- Use pcall so if the server rejects the remote, the script doesn't crash
        pcall(function()
            damageEvent:FireServer(target, weapon.damage, CONFIG.currentWeaponIndex)
        end)
        print("feralisass | Hit: " .. target.Name)
    end
end

-- Input Detection
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.E then
        useWeapon()
    end
    
    if input.KeyCode == Enum.KeyCode.One then CONFIG.currentWeaponIndex = 1 print("Equipped: Sword") end
    if input.KeyCode == Enum.KeyCode.Two then CONFIG.currentWeaponIndex = 2 print("Equipped: Bow") end
    if input.KeyCode == Enum.KeyCode.Three then CONFIG.currentWeaponIndex = 3 print("Equipped: Staff") end
end)

-- Character Setup (Modified for Solara reliability)
local function applyStats(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = CONFIG.speed
        hum.JumpPower = CONFIG.jumpPower
        print("Stats Applied: Speed " .. CONFIG.speed)
    end
end

LocalPlayer.CharacterAdded:Connect(applyStats)
if LocalPlayer.Character then applyStats(LocalPlayer.Character) end

print("feralisass.lua LOADED successfully!")
