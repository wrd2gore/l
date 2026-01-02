-- feralisass.lua (SMART FIX FOR SOLARA)
print("--- [feralisass] STARTING SCAN ---")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    speed = 21,
    jumpPower = 92,
    range = 20, -- Attack distance
    cooldown = 0.5
}

-- 1. DYNAMIC REMOTE FINDER
-- This searches for any RemoteEvent that looks like it's for combat
local combatRemote = nil
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")

if remotesFolder then
    -- Look for common names since 'DamageEvent' failed
    combatRemote = remotesFolder:FindFirstChild("Damage") 
                or remotesFolder:FindFirstChild("Hit") 
                or remotesFolder:FindFirstChild("Attack")
                or remotesFolder:FindFirstChild("Combat")
    
    -- If still not found, just take the first RemoteEvent in that folder
    if not combatRemote then
        for _, v in pairs(remotesFolder:GetChildren()) do
            if v:IsA("RemoteEvent") then
                combatRemote = v
                break
            end
        end
    end
end

if combatRemote then
    print("[feralisass] SUCCESS: Hooked into Remote: " .. combatRemote.Name)
else
    warn("[feralisass] FAIL: Could not find any combat remotes. Game security might be high.")
    -- Fallback: If we can't find it, the script can't do damage, but speed will still work.
end

-- 2. TARGETING SYSTEM
local lastAttack = 0
local function getClosestPlayer()
    local target, dist = nil, CONFIG.range
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                target = p
                dist = d
            end
        end
    end
    return target
end

-- 3. COMBAT EXECUTION
local function doAttack()
    if tick() - lastAttack < CONFIG.cooldown then return end
    
    local enemy = getClosestPlayer()
    if enemy and combatRemote then
        lastAttack = tick()
        -- Fires the remote we found dynamically
        combatRemote:FireServer(enemy, 10, 1) -- Target, Damage, WeaponIndex
        print("[feralisass] Attacked: " .. enemy.Name)
    end
end

-- 4. INPUTS & STATS
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.E then
        doAttack()
    end
end)

local function applyStats()
    local hum = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid", 10)
    if hum then
        hum.WalkSpeed = CONFIG.speed
        hum.JumpPower = CONFIG.jumpPower
        print("[feralisass] Movement Buffed.")
    end
end

applyStats()
LocalPlayer.CharacterAdded:Connect(applyStats)

print("--- [feralisass] LOADED (Press F9 for Details) ---")
