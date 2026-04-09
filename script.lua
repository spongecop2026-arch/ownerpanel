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
-- ✅ MAIN
--====================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- VARIABLES
local aimbotEnabled = false
local smoothAim = false
local aiming = false
local smoothness = 0.15
local aimPart = "Head"
local IJ = false

-- ESP SETTINGS
ESP.Enabled = false
ESP.Players = true
ESP.Boxes = true
ESP.Names = true
ESP.Health = true
ESP.Distance = true
ESP.Tracers = false
ESP.Color = Color3.fromRGB(255,0,0)
ESP.TeamColor = false

-- FOV
local fovRadius = 120
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = fovRadius
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255,255,255)

-- HIGHLIGHT
local highlightEnabled = false
local highlights = {}

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

-- INPUT
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

--====================================================
-- MAIN LOOP
--====================================================

RunService.RenderStepped:Connect(function()
    local center = getCenter()
    fovCircle.Position = center

    local target = getClosest()

    -- FOV COLOR CHANGE
    if target then
        fovCircle.Color = Color3.fromRGB(255,0,0)
    else
        fovCircle.Color = Color3.fromRGB(255,255,255)
    end

    if not aimbotEnabled then return end
    if not target then return end

    local targetCF = CFrame.new(Camera.CFrame.Position, target[aimPart].Position)

    if smoothAim then
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothness)
    else
        if aiming then
            Camera.CFrame = targetCF
        end
    end
end)

--====================================================
-- HIGHLIGHT
--====================================================

RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if highlightEnabled then
                if not highlights[plr] then
                    local hl = Instance.new("Highlight")
                    hl.Parent = plr.Character
                    highlights[plr] = hl
                end
            else
                if highlights[plr] then
                    highlights[plr]:Destroy()
                    highlights[plr] = nil
                end
            end
        end
    end
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if IJ and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
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

local RoleTab = Window:CreateTab("Role", 4483362458)
RoleTab:CreateLabel("Role: " .. UserRole)

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    Callback = function(v) aimbotEnabled = v end
})

AimbotTab:CreateToggle({
    Name = "Smooth Aim (VIP+)",
    Callback = function(v)
        if UserRole == "OWNER" or UserRole == "VIP" then
            smoothAim = v
        end
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50,300},
    CurrentValue = 120,
    Callback = function(v)
        fovRadius = v
        fovCircle.Radius = v
    end
})

local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "Enable ESP",
    Callback = function(v)
        ESP.Enabled = v
    end
})

ESPTab:CreateToggle({
    Name = "Tracers",
    Callback = function(v)
        ESP.Tracers = v
    end
})

ESPTab:CreateToggle({
    Name = "Boxes",
    Callback = function(v)
        ESP.Boxes = v
    end
})

ESPTab:CreateToggle({
    Name = "Names",
    Callback = function(v)
        ESP.Names = v
    end
})

ESPTab:CreateToggle({
    Name = "Distance",
    Callback = function(v)
        ESP.Distance = v
    end
})

ESPTab:CreateToggle({
    Name = "Highlight Players",
    Callback = function(v)
        highlightEnabled = v
    end
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Callback = function(v) IJ = v end
})
