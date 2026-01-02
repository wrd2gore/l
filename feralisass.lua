-- feralisass.lua
-- Enhanced Weapon & Combat System

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
    respawnTime = 5,
    currentWeaponIndex = 1
}

-- Locating Remotes (Based on deobfuscated structure)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
if not remotes then
    warn("Remotes folder not found. Script might not function on this game.")
    return
end

local damageEvent = remotes:WaitForChild("DamageEvent")
local weapons = {
    {name = "Sword", damage = 15, cooldown = 0.8, range = 12},
    {name = "Bow", damage = 10, cooldown = 1.2, range = 45},
    {name = "Staff", damage = 25, cooldown = 2.5, range = 25}
}

local lastAttack = 0

-- Helper: Find nearest target
local function getTarget()
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                closest = p
                dist = mag
            end
        end
    end
    return closest, dist
end

-- Weapon Execution Logic
local function useWeapon()
    local weapon = weapons[CONFIG.currentWeaponIndex]
    if tick() - lastAttack < weapon.cooldown then return end
    
    local target, distance = getTarget()
    
    if target and distance <= weapon.range then
        lastAttack = tick()
        -- Fires the event found in your deobfuscated code
        damageEvent:FireServer(target, weapon.damage, CONFIG.currentWeaponIndex)
        
        -- Optional: Simple visual indicator
        print("[feralisass] Hit " .. target.Name .. " with " .. weapon.name)
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Attack (Left Click or E)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.E then
        useWeapon()
    end
    
    -- Switch Weapons (1, 2, 3)
    if input.KeyCode == Enum.KeyCode.One then CONFIG.currentWeaponIndex = 1 print("Weapon: Sword") end
    if input.KeyCode == Enum.KeyCode.Two then CONFIG.currentWeaponIndex = 2 print("Weapon: Bow") end
    if input.KeyCode == Enum.KeyCode.Three then CONFIG.currentWeaponIndex = 3 print("Weapon: Staff") end
end)

-- Apply Character Buffs
local function applyStats()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = CONFIG.speed
    hum.JumpPower = CONFIG.jumpPower
end

LocalPlayer.CharacterAdded:Connect(applyStats)
applyStats()

print("feralisass.lua loaded successfully.")
