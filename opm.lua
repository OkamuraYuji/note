-- Yjing Hub Full GUI (Safe refactor with getgenv States)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === States in getgenv ===
getgenv().States = getgenv().States or {
    AutoChest = false,
    Hop = false,
}

-- === GUI ===
local yjing = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local MinBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local Sidebar = Instance.new("Frame")
local MainBtn = Instance.new("TextButton")
local PlayerBtn = Instance.new("TextButton")
local Frame_3 = Instance.new("Frame")

yjing.Name = "yjing"
yjing.Parent = player:WaitForChild("PlayerGui")
yjing.ResetOnSpawn = false

Frame.Parent = yjing
Frame.Active = true
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Draggable = true
Frame.Position = UDim2.new(0.5, -291, 0.5, -164)
Frame.Size = UDim2.new(0, 295, 0, 220)

TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 10, 0, 0)
TextLabel.Size = UDim2.new(0.5, -10, 0, 30)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "Yjing Hub"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 18
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

MinBtn.Parent = Frame
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18

CloseBtn.Parent = Frame
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 18

Sidebar.Parent = Frame
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.Size = UDim2.new(0, 90, 1, -30)

MainBtn.Parent = Sidebar
MainBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
MainBtn.Position = UDim2.new(0, 5, 0, 10)
MainBtn.Size = UDim2.new(1, -10, 0, 30)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.Text = "Main"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.TextSize = 14

PlayerBtn.Parent = Sidebar
PlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerBtn.Position = UDim2.new(0, 5, 0, 55)
PlayerBtn.Size = UDim2.new(1, -10, 0, 30)
PlayerBtn.Font = Enum.Font.GothamBold
PlayerBtn.Text = "Player"
PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerBtn.TextSize = 14

Frame_3.Parent = Frame
Frame_3.BackgroundTransparency = 1
Frame_3.Position = UDim2.new(0.3, 0, 0.15, 0)
Frame_3.Size = UDim2.new(0.7, 0, 0.8, 0)

-- === Helpers ===
local function ClearContent()
    for _,c in ipairs(Frame_3:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

local function updateToggleButton(btn, key)
    local state = getgenv().States[key]
    btn.Text = btn:GetAttribute("Label") .. ": " .. (state and "ON" or "OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or btn:GetAttribute("DefaultColor")
end

local function makeToggle(parent, y, label, key, defaultColor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn:SetAttribute("Label", label)
    btn:SetAttribute("DefaultColor", defaultColor)
    updateToggleButton(btn, key)

    btn.MouseButton1Click:Connect(function()
        getgenv().States[key] = not getgenv().States[key]
        updateToggleButton(btn, key)
    end)
end

-- === Teleport save (safe) ===
local function teleportWithSave(callback)
    local minimal = {
        AutoChest = getgenv().States.AutoChest,
        Hop = getgenv().States.Hop,
    }
    getgenv().SavedStates = minimal
    getgenv().SavedStatesJSON = HttpService:JSONEncode(minimal)

    local restore = string.format([[
        local HttpService = game:GetService("HttpService")
        local ok, data = pcall(function()
            return HttpService:JSONDecode([[%s]])
        end)
        if ok and data then
            getgenv().States = data
        end
    ]], getgenv().SavedStatesJSON or "{}")

    if queue_on_teleport then
        queue_on_teleport(restore)
    end

    if typeof(callback) == "function" then
        callback()
    end
end

-- === Tabs ===
local function LoadMain()
    ClearContent()
    makeToggle(Frame_3, 10, "Auto Chest", "AutoChest", Color3.fromRGB(170,0,0))
    makeToggle(Frame_3, 60, "Server Hop", "Hop", Color3.fromRGB(50,50,50))
end

local function LoadPlayer()
    ClearContent()

    -- WalkSpeed (safe)
    local wsBtn = Instance.new("TextButton", Frame_3)
    wsBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    wsBtn.Position = UDim2.new(0, 10, 0, 10)
    wsBtn.Size = UDim2.new(0.7, 0, 0, 40)
    wsBtn.Text = "WalkSpeed:"
    wsBtn.Font = Enum.Font.GothamBold
    wsBtn.TextColor3 = Color3.new(1,1,1)
    wsBtn.TextSize = 18

    local wsBox = Instance.new("TextBox", wsBtn)
    wsBox.Size = UDim2.new(0, 40, 0, 35)
    wsBox.Position = UDim2.new(1, 10, 0, 0)
    wsBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    wsBox.Text = "16"
    wsBox.Font = Enum.Font.GothamBold
    wsBox.TextColor3 = Color3.new(1,1,1)
    wsBox.TextScaled = true

    wsBox.FocusLost:Connect(function(enter)
        if enter then
            local val = tonumber(wsBox.Text)
            if val and val >= 16 and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            else
                wsBox.Text = "16"
            end
        end
    end)

    -- JumpPower (safe)
    local jpBtn = Instance.new("TextButton", Frame_3)
    jpBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    jpBtn.Position = UDim2.new(0, 10, 0, 60)
    jpBtn.Size = UDim2.new(0.7, 0, 0, 40)
    jpBtn.Text = "JumpPower:"
    jpBtn.Font = Enum.Font.GothamBold
    jpBtn.TextColor3 = Color3.new(1,1,1)
    jpBtn.TextSize = 18

    local jpBox = Instance.new("TextBox", jpBtn)
    jpBox.Size = UDim2.new(0, 40, 0, 35)
    jpBox.Position = UDim2.new(1, 10, 0, 0)
    jpBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    jpBox.Text = "50"
    jpBox.Font = Enum.Font.GothamBold
    jpBox.TextColor3 = Color3.new(1,1,1)
    jpBox.TextScaled = true

    jpBox.FocusLost:Connect(function(enter)
        if enter then
            local val = tonumber(jpBox.Text)
            if val and val >= 50 and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = val end
            else
                jpBox.Text = "50"
            end
        end
    end)
end

-- Tab switching
MainBtn.MouseButton1Click:Connect(function()
    MainBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    PlayerBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    LoadMain()
end)

PlayerBtn.MouseButton1Click:Connect(function()
    PlayerBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    MainBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    LoadPlayer()
end)

-- Close/minimize
CloseBtn.MouseButton1Click:Connect(function()
    yjing:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame_3.Visible = not minimized
    Sidebar.Visible = not minimized
    Frame.Size = minimized and UDim2.new(0,295,0,30) or UDim2.new(0,295,0,220)
end)

-- Default load
LoadMain()
