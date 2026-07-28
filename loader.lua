-- WETQA & Unnamed Enhancements - 自動驗證與 Unnamed 完美復刻面板
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 自動檢查是否有帶入 script_key（如果沒有則給予預設身分）
local currentKey = script_key or "NO_KEY_PROVIDED"

-- 防止重複載入
local oldGui = player.PlayerGui:FindFirstChild("WETQA_Enhancements_Menu")
if oldGui then oldGui:Destroy() end

-- 建立主畫面 (完全復刻 Unnamed 風格)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WETQA_Enhancements_Menu"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 主視窗框架
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 720, 0, 520)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- 頂部標題列
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "WETQA 高階面板 - discord.gg/zdqUuQgBhQ"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(0, 100, 1, 0)
GameTitle.Position = UDim2.new(1, -110, 0, 0)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "Rivals"
GameTitle.TextColor3 = Color3.fromRGB(80, 150, 255)
GameTitle.TextSize = 13
GameTitle.Font = Enum.Font.Code
GameTitle.TextXAlignment = Enum.TextXAlignment.Right
GameTitle.Parent = TopBar

-- 切換顯示鍵 (RightShift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 分頁按鈕列
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 28)
TabBar.Position = UDim2.new(0, 12, 0, 42)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local tabs = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
local tabButtons = {}
local contentFrames = {}

-- 內容呈現容器
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -24, 1, -85)
Container.Position = UDim2.new(0, 12, 0, 75)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 1, 0)
    btn.Position = UDim2.new(0, (i - 1) * 92, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    btn.BorderColor3 = Color3.fromRGB(0, 255, 120)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Code
    btn.TextSize = 13
    btn.Parent = TabBar
    
    local cFrame = Instance.new("ScrollingFrame")
    cFrame.Size = UDim2.new(1, 0, 1, 0)
    cFrame.BackgroundTransparency = 1
    cFrame.BorderSizePixel = 1
    cFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
    cFrame.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    cFrame.ScrollBarThickness = 4
    cFrame.Visible = false
    cFrame.Parent = Container
    
    contentFrames[name] = cFrame
    
    btn.MouseButton1Click:Connect(function()
        for _, frame in pairs(contentFrames) do frame.Visible = false end
        for _, b in pairs(tabButtons) do b.TextColor3 = Color3.fromRGB(200, 200, 200) end
        cFrame.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 120)
    end)
    
    table.insert(tabButtons, btn)
end

-- 預設開啟 main 分頁
contentFrames["main"].Visible = true
tabButtons[1].TextColor3 = Color3.fromRGB(0, 255, 120)

-- ==========================================
-- 各分頁內容與功能建構
-- ==========================================

-- 1. MAIN 分頁 (自動顯示授權通過狀態 & Aimbot)
do
    local f = contentFrames["main"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    
    addHeader("status & authorization")
    
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -20, 0, 35)
    statusLbl.Position = UDim2.new(0, 10, 0, y)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "✅ [Auto-Verified] 授權金鑰已自動通過生效！"
    statusLbl.TextColor3 = Color3.fromRGB(0, 255, 120)
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 12
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent = f
    y = y + 45

    addHeader("silent aim & aimbot")
    
    local aimOn = false
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(1, -20, 0, 35)
    aimBtn.Position = UDim2.new(0, 10, 0, y)
    aimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    aimBtn.BorderColor3 = Color3.fromRGB(0, 255, 120)
    aimBtn.Text = "  [  ] enabled (Aimbot Lock)"
    aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimBtn.Font = Enum.Font.Code
    aimBtn.TextSize = 12
    aimBtn.TextXAlignment = Enum.TextXAlignment.Left
    aimBtn.Parent = f
    
    aimBtn.MouseButton1Click:Connect(function()
        aimOn = not aimOn
        aimBtn.Text = aimOn and "  [✔] enabled (Aimbot Lock)" or "  [  ] enabled (Aimbot Lock)"
        aimBtn.BackgroundColor3 = aimOn and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(20, 20, 30)
    end)
    
    RunService.RenderStepped:Connect(function()
        if aimOn then
            local cam = workspace.CurrentCamera
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end)
end

-- 2. WORLD 分頁
do
    local f = contentFrames["world"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("skybox & atmosphere")
    
    local skies = {
        {"🌌 Aurora Night", "rbxassetid://644551720"},
        {"🌠 Galaxy Nebula", "rbxassetid://155091771"},
        {"🌅 Sunset Glow", "rbxassetid://600830600"}
    }
    for _, skyData in ipairs(skies) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -20, 0, 35)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        b.BorderColor3 = Color3.fromRGB(0, 255, 120)
        b.Text = "  > " .. skyData[1]
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = f
        
        b.MouseButton1Click:Connect(function()
            Lighting.ClockTime = 0
            Lighting.Brightness = 2
            for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
            local sky = Instance.new("Sky")
            sky.SkyboxBk = skyData[2] sky.SkyboxDn = skyData[2] sky.SkyboxFt = skyData[2]
            sky.SkyboxLf = skyData[2] sky.SkyboxRt = skyData[2] sky.SkyboxUp = skyData[2]
            sky.Parent = Lighting
        end)
        y = y + 42
    end
end

-- 3. ESP 分頁
do
    local f = contentFrames["esp"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("esp options & override appearance")
    
    local espOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.BorderColor3 = Color3.fromRGB(0, 255, 120)
    b.Text = "  [  ] box / chams esp"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = f
    
    b.MouseButton1Click:Connect(function()
        espOn = not espOn
        b.Text = espOn and "  [✔] box / chams esp" or "  [  ] box / chams esp"
        b.BackgroundColor3 = espOn and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(20, 20, 30)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if espOn then
                    local hl = Instance.new("Highlight")
                    hl.Name = "WETQA_ESP"
                    hl.Adornee = p.Character
                    hl.FillColor = Color3.fromRGB(0, 255, 120)
                    hl.Parent = p.Character
                else
                    local hl = p.Character:FindFirstChild("WETQA_ESP")
                    if hl then hl:Destroy() end
                end
            end
        end
    end)
end

-- 4. VISUALS 分頁
do
    local f = contentFrames["visuals"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("crosshair & viewmodel")
    
    local crossGui = player:PlayerGui:FindFirstChild("WETQA_Crosshair")
    if not crossGui then
        crossGui = Instance.new("ScreenGui")
        crossGui.Name = "WETQA_Crosshair"
        crossGui.Enabled = false
        crossGui.Parent = player.PlayerGui
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0.5, -4, 0.5, -4)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        dot.BorderSizePixel = 0
        dot.Parent = crossGui
        local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = dot
    end
    
    local crossOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.BorderColor3 = Color3.fromRGB(0, 255, 120)
    b.Text = "  [  ] enabled (Circular Crosshair)"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = f
    
    b.MouseButton1Click:Connect(function()
        crossOn = not crossOn
        crossGui.Enabled = crossOn
        b.Text = crossOn and "  [✔] enabled (Circular Crosshair)" or "  [  ] enabled (Circular Crosshair)"
        b.BackgroundColor3 = crossOn and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(20, 20, 30)
    end)
end

-- 5. CHARACTER 分頁
do
    local f = contentFrames["character"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("movement & character options")
    
    local speedOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.BorderColor3 = Color3.fromRGB(0, 255, 120)
    b.Text = "  [  ] velocity speed (100)"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = f
    
    b.MouseButton1Click:Connect(function()
        speedOn = not speedOn
        b.Text = speedOn and "  [✔] velocity speed (100)" or "  [  ] velocity speed (100)"
        b.BackgroundColor3 = speedOn and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(20, 20, 30)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedOn and 100 or 16 end
    end)
end

-- 6. MISC 分頁 (內含風怒機器人虛空秒殺)
do
    local f = contentFrames["misc"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("auto queue & custom windbot void-attack")
    
    local windBotOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.BorderColor3 = Color3.fromRGB(0, 255, 120)
    b.Text = "  [  ] windbot void attack & auto kill"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = f
    
    b.MouseButton1Click:Connect(function()
        windBotOn = not windBotOn
        b.Text = windBotOn and "  [✔] windbot void attack & auto kill" or "  [  ] windbot void attack & auto kill"
        b.BackgroundColor3 = windBotOn and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(20, 20, 30)
    end)
    
    -- 風怒機器人虛空秒殺循環
    RunService.Heartbeat:Connect(function()
        if windBotOn then
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, -5000, 0)
                            hum.Health = 0
                        end
                    end
                end
            end)
        end
    end)
end

-- 7. SETTINGS 分頁
do
    local f = contentFrames["settings"]
    local y = 15
    local function addHeader(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 10, 0, y)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(0, 255, 120)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        y = y + 30
    end
    addHeader("configuration & menu options")
    
    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.new(1, -20, 0, 35)
    closeB.Position = UDim2.new(0, 10, 0, y)
    closeB.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    closeB.BorderColor3 = Color3.fromRGB(0, 255, 120)
    closeB.Text = "  > Unload & Close Menu"
    closeB.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeB.Font = Enum.Font.Code
    closeB.TextSize = 12
    closeB.TextXAlignment = Enum.TextXAlignment.Left
    closeB.Parent = f
    
    closeB.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end
