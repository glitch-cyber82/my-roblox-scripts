-- 1. AUTO-EXECUTE LOADING HOOK (Waits for the new game server to load)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

if not PlayerGui then return end

-- Clean up any old windows to prevent the interface from duplicating
if PlayerGui:FindFirstChild("AutoExecSandboxGUI") then
    PlayerGui.AutoExecSandboxGUI:Destroy()
end

-- 2. CREATE SCREEN CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoExecSandboxGUI"
ScreenGui.DisplayOrder = 9999999
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 3. MAIN WINDOW PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 290)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- --- 🟢🔴 STATUS INDICATOR DOT ---
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(1, -22, 0, 12)
StatusDot.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Default: RED (Not Saving)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

-- Window Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Auto-Loaded Executor"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- 4. CODE TEXTBOX INPUT AREA
local CodeTextBox = Instance.new("TextBox")
CodeTextBox.Name = "CodeTextBox"
CodeTextBox.Size = UDim2.new(1, -24, 1, -120)
CodeTextBox.Position = UDim2.new(0, 12, 0, 35)
CodeTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
CodeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeTextBox.Text = "-- The whole executor UI now auto-loads via your autoexec folder.\nprint('System Ready')"
CodeTextBox.TextSize = 14
CodeTextBox.Font = Enum.Font.Code
CodeTextBox.TextXAlignment = Enum.TextXAlignment.Left
CodeTextBox.TextYAlignment = Enum.TextYAlignment.Top
CodeTextBox.MultiLine = true
CodeTextBox.ClearTextOnFocus = false
CodeTextBox.Parent = MainFrame

local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 4)
TextCorner.Parent = CodeTextBox

-- 5. RUN SCRIPT BUTTON
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(1, -24, 0, 35)
ExecuteButton.Position = UDim2.new(0, 12, 1, -45)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(40, 120, 80)
ExecuteButton.Text = "Run Script"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.TextSize = 14
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 4)
ButtonCorner.Parent = ExecuteButton

-- 6. ENABLE AUTO LOAD BUTTON (Saves text inside textbox across teleports)
local AutoLoadButton = Instance.new("TextButton")
AutoLoadButton.Name = "AutoLoadButton"
AutoLoadButton.Size = UDim2.new(0, 180, 0, 30)
AutoLoadButton.Position = UDim2.new(0, 12, 1, -85)
AutoLoadButton.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
AutoLoadButton.Text = "Enable Auto Load"
AutoLoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoLoadButton.TextSize = 12
AutoLoadButton.Font = Enum.Font.SourceSansBold
AutoLoadButton.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 4)
AutoCorner.Parent = AutoLoadButton

-- 7. STOP LOADING BUTTON (Clears saved textbox data)
local StopLoadButton = Instance.new("TextButton")
StopLoadButton.Name = "StopLoadButton"
StopLoadButton.Size = UDim2.new(0, 180, 0, 30)
StopLoadButton.Position = UDim2.new(1, -192, 1, -85)
StopLoadButton.BackgroundColor3 = Color3.fromRGB(130, 50, 50)
StopLoadButton.Text = "Stop Loading"
StopLoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopLoadButton.TextSize = 12
StopLoadButton.Font = Enum.Font.SourceSansBold
StopLoadButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 4)
StopCorner.Parent = StopLoadButton

-- --- ENGINE INTERNALS & FUNCTIONALITY ---

local function getQueueFunction()
    if queue_on_teleport then return queue_on_teleport end
    local alternative = nil
    pcall(function()
        if syn and syn.queue_on_teleport then alternative = syn.queue_on_teleport
        elseif fluxus and fluxus.queue_on_teleport then alternative = fluxus.queue_on_teleport
        elseif getgenv and getgenv().queue_on_teleport then alternative = getgenv().queue_on_teleport
        end
    end)
    return alternative
end

local function runCode(source)
    if source == "" then return end
    local func, err = loadstring(source)
    if func then
        pcall(func)
    else
        warn("Execution Error: " .. tostring(err))
    end
end

-- Button Triggers
ExecuteButton.MouseButton1Click:Connect(function()
    runCode(CodeTextBox.Text)
end)

AutoLoadButton.MouseButton1Click:Connect(function()
    -- Force visual cues immediately upon touch
    StatusDot.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Turn dot GREEN
    AutoLoadButton.Text = "Auto Load [ARMED]"
    AutoLoadButton.BackgroundColor3 = Color3.fromRGB(30, 50, 90)
    
    local teleportQueue = getQueueFunction()
    if teleportQueue then
        local payload = string.format([[
            repeat task.wait() until game:IsLoaded()
            task.wait(3)
            local code = %q
            local func = loadstring(code)
            if func then pcall(func) end
        ]], CodeTextBox.Text)
        
        pcall(function()
            teleportQueue(payload)
        end)
    end
end)

StopLoadButton.MouseButton1Click:Connect(function()
    -- Revert visual cues back to safe state
    StatusDot.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Reset dot to RED
    AutoLoadButton.Text = "Enable Auto Load"
    AutoLoadButton.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
    
    local teleportQueue = getQueueFunction()
    if teleportQueue then
        pcall(function()
            teleportQueue("")
        end)
    end
end)
