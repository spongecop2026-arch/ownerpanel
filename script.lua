--====================================================
-- 🔐 KEY SYSTEM
--====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Keys = {
    ["Spongecop2026"] = "OWNER",
    ["ViP_09!"] = "VIP",
    ["Buyer_7"] = "BUYER"
}

local UserRole = "NONE"
local unlocked = false

local function GetRole(key)
    return Keys[key]
end

local gui = Instance.new("ScreenGui")
gui.Name = "KeyUI"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,180)
frame.Position = UDim2.new(0.5,-150,0.5,-90)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Enter Key"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1,-20,0,40)
box.Position = UDim2.new(0,10,0,50)
box.PlaceholderText = "Key..."

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1,-20,0,40)
btn.Position = UDim2.new(0,10,0,110)
btn.Text = "Submit"

btn.MouseButton1Click:Connect(function()
    local key = box.Text
    if GetRole(key) then
        UserRole = GetRole(key)
        unlocked = true
        gui:Destroy()
    else
        box.Text = "Invalid Key"
    end
end)

repeat task.wait() until unlocked

--====================================================
-- MAIN
--====================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- AIMBOT / TARGET
local aimbotEnabled = false
local smoothAim = false
local aiming = false
local smoothness = 0.15
local aimPart = "Head"
local lockedTarget = nil

-- SPEED
local walkSpeed = 16
local runSpeed = 32
local running = false
local speedEnabled = true
local defaultSpeed = 16

-- ESP
ESP.Enabled = false

-- FOV
local fovRadius = 120
local showFOV = true
local fovCircle = Drawing.new("Circle")

-- HIGHLIGHT
local highlightEnabled = false
local highlights = {}

--====================================================
-- 👕 SKIN SYSTEM
--====================================================

local SkinFolder = Instance.new("Folder")
SkinFolder.Name = "ClientSkins"
SkinFolder.Parent = ReplicatedStorage

local function createSkin(name, shirtId, pantsId)
    local folder = Instance.new("Folder")
    folder.Name = name

    local shirt = Instance.new("Shirt")
    shirt.ShirtTemplate = shirtId
    shirt.Parent = folder

    local pants = Instance.new("Pants")
    pants.PantsTemplate = pantsId
    pants.Parent = folder

    folder.Parent = SkinFolder
end

-- 🔥 PUT REAL IDS HERE
createSkin("Red", "rbxassetid://144076760", "rbxassetid://144076759")
createSkin("Blue", "rbxassetid://398633812", "rbxassetid://398633584")

local function applySkin(skin)
    local char = LocalPlayer.Character
    if not char then return end

    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") then
            v:Destroy()
        end
    end

    for _, v in pairs(skin:GetChildren()) do
        v:Clone().Parent = char
    end
end

--====================================================
-- FUNCTIONS
--====================================================

local function getCenter()
    local v = Camera.ViewportSize
    return Vector2.new(v.X/2, v.Y/2)
end

local function getClosest()
    local closest, dist = nil, fovRadius
    local center = getCenter()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(aimPart) then
            local pos, visible = Camera:WorldToViewportPoint(plr.Character[aimPart].Position)
            if visible then
                local diff = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if diff < dist then
                    dist = diff
                    closest = plr.Character
                end
            end
        end
    end

    return closest
end

local function getTarget()
    if lockedTarget and lockedTarget.Parent then
        return lockedTarget
    end
    lockedTarget = getClosest()
    return lockedTarget
end

-- INPUT
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        running = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        running = false
    end
end)

--====================================================
-- MAIN LOOP
--====================================================

RunService.RenderStepped:Connect(function()
    local center = getCenter()

    -- FOV
    fovCircle.Visible = showFOV
    fovCircle.Position = center
    fovCircle.Radius = fovRadius

    local target = getTarget()

    -- AIMBOT
    if aimbotEnabled and target then
        local targetCF = CFrame.new(Camera.CFrame.Position, target[aimPart].Position)
        if smoothAim then
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothness)
        elseif aiming then
            Camera.CFrame = targetCF
        end
    end

    -- SPEED
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedEnabled and (running and runSpeed or walkSpeed) or defaultSpeed
        end
    end

    -- HIGHLIGHT
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if highlightEnabled then
                if not highlights[plr] then
                    highlights[plr] = Instance.new("Highlight", plr.Character)
                end
            elseif highlights[plr] then
                highlights[plr]:Destroy()
                highlights[plr] = nil
            end
        end
    end
end)

--====================================================
-- UI
--====================================================

local Window = Rayfield:CreateWindow({
    Name = "OWNER PANEL",
    LoadingTitle = "Loading...",
    LoadingSubtitle = UserRole,
    Theme = "Ocean"
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateToggle({Name="Enable Aimbot",Callback=function(v)aimbotEnabled=v end})
AimbotTab:CreateToggle({Name="Smooth Aim",Callback=function(v)smoothAim=v end})

local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({Name="Enable ESP",Callback=function(v)ESP.Enabled=v end})
ESPTab:CreateToggle({Name="Highlight",Callback=function(v)highlightEnabled=v end})

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
    Name="Walk Speed",
    Range={8,150},
    CurrentValue=16,
    Callback=function(v)walkSpeed=v end
})

PlayerTab:CreateSlider({
    Name="Run Speed",
    Range={16,300},
    CurrentValue=32,
    Callback=function(v)runSpeed=v end
})

-- 👕 SKIN TAB
local SkinTab = Window:CreateTab("Skins", 4483362458)

for _, skin in pairs(SkinFolder:GetChildren()) do
    SkinTab:CreateButton({
        Name = skin.Name,
        Callback = function()
            applySkin(skin)
        end
    })
end

if UserRole == "OWNER" then
    SkinTab:CreateButton({
        Name = "Cycle Skins",
        Callback = function()
            for _, skin in pairs(SkinFolder:GetChildren()) do
                applySkin(skin)
                task.wait(2)
            end
        end
    })
end
