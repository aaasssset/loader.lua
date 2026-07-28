-- WETQA高級面板 & Unnamed Enhancements - 終極虛空秒殺整合版
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 防止重複載入
local oldGui = player.PlayerGui:FindFirstChild("WETQA_Ultimate_Menu")
if oldGui then oldGui:Destroy() end

-- 建立主畫面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WETQA_Ultimate_Menu"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 主視窗
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- 頂部標題列
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ WETQA高級面板 & 風怒機器人虛空秒殺"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- 右上角關閉按鈕
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -38, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 切換鍵 (RightShift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 分頁按鈕容器
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = TabBar

-- 內容滾動區
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -95)
ContentContainer.Position = UDim2.new(0, 10, 0, 88)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 2.8, 0)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = MainFrame

local tabs = {"main", "aimbot", "esp", "world", "character", "enhancements"}

local function renderTab(tabName)
    ContentContainer:ClearAllChildren()
    local yOffset = 10
    
    local function addLabel(text, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 25)
        lbl.Position = UDim2.new(0, 0, 0, yOffset)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(0, 255, 120)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = ContentContainer
        yOffset = yOffset + 32
    end

    local function addButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.Position = UDim2.new(0, 0, 0, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        btn.Text = "  " .. text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = ContentContainer
        
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            callback(btn)
        end)
        
        yOffset = yOffset + 46
        return btn
    end

    if tabName == "main" then
        addLabel("🔑 授權與驗證中心")
        
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, 0, 0, 38)
        tb.Position = UDim2.new(0, 0, 0, yOffset)
        tb.PlaceholderText = "Enter WETQA Key..."
        tb.TextColor3 = Color3.fromRGB(255, 255, 255)
        tb.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tb.TextSize = 13
        tb.Font = Enum.Font.Gotham
        tb.Parent = ContentContainer
        
        if script_key then tb.Text = script_key end
        local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 6) tc.Parent = tb
        yOffset = yOffset + 46
        
        local st = Instance.new("TextLabel")
        st.Size = UDim2.new(1, 0, 0, 30)
        st.Position = UDim2.new(0, 0, 0, yOffset)
        st.BackgroundTransparency = 1
        st.Text = "Status: 準備就緒，請點擊驗證"
        st.TextColor3 = Color3.fromRGB(200, 200, 200)
        st.Font = Enum.Font.Gotham
        st.TextSize = 13
        st.Parent = ContentContainer
        yOffset = yOffset + 38

        addButton("Verify Key 驗證金鑰", function(btn)
            st.Text = "Checking key..."
            task.wait(0.3)
            if tb.Text ~= "" and script_key and tb.Text == script_key then
                st.TextColor3 = Color3.fromRGB(0, 255, 120)
                st.Text = "✅ [Verified] WETQA 高級面板啟用成功！"
            else
                st.TextColor3 = Color3.fromRGB(255, 80, 80)
                st.Text = "❌ Invalid Key or Mismatched!"
            end
        end)

    elseif tabName == "aimbot" then
        addLabel("🎯 自瞄與戰鬥模組")
        local aimOn = false
        addButton("📌 Aimbot (Silent/Legit): [ OFF ]", function(btn)
            aimOn = not aimOn
            btn.Text = aimOn and "  📌 Aimbot (Silent/Legit): [ ON ]" or "  📌 Aimbot (Silent/Legit): [ OFF ]"
            btn.BackgroundColor3 = aimOn and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(30, 30, 42)
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

    elseif tabName == "esp" then
        addLabel("👀 透視與視覺模組 (ESP)")
        local espOn = false
        addButton("👁️ Chams & Box ESP: [ OFF ]", function(btn)
            espOn = not espOn
            btn.Text = espOn and "  👁️ Chams & Box ESP: [ ON ]" or "  👁️ Chams & Box ESP: [ OFF ]"
            btn.BackgroundColor3 = espOn and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(30, 30, 42)
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

    elseif tabName == "world" then
        addLabel("🌍 世界與環境模組")
        local skies = {
            {"🌌 Aurora Night", "rbxassetid://644551720"},
            {"🌠 Galaxy Nebula", "rbxassetid://155091771"},
            {"🌅 Sunset Glow", "rbxassetid://600830600"}
        }
        for _, skyData in ipairs(skies) do
            addButton(skyData[1], function()
                Lighting.ClockTime = 0
                Lighting.Brightness = 2
                for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
                local sky = Instance.new("Sky")
                sky.SkyboxBk = skyData[2] sky.SkyboxDn = skyData[2] sky.SkyboxFt = skyData[2]
                sky.SkyboxLf = skyData[2] sky.SkyboxRt = skyData[2] sky.SkyboxUp = skyData[2]
                sky.Parent = Lighting
            end)
        end

    elseif tabName == "character" then
        addLabel("⚡ 角色與移動強化")
        local speedOn = false
        addButton("🚀 WalkSpeed Overclock (100): [ OFF ]", function(btn)
            speedOn = not speedOn
            btn.Text = speedOn and "  🚀 WalkSpeed Overclock (100): [ ON ]" or "  🚀 WalkSpeed Overclock (100): [ OFF ]"
            btn.BackgroundColor3 = speedOn and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(30, 30, 42)
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speedOn and 100 or 16 end
        end)

    elseif tabName == "enhancements" then
        addLabel("⚡ 專屬功能與風怒虛空秒殺")
        local fbOn = false
        addButton("🚀 Fullbright & No Fog: [ OFF ]", function(btn)
            fbOn = not fbOn
            btn.Text = fbOn and "  🚀 Fullbright & No Fog: [ ON ]" or "  🚀 Fullbright & No Fog: [ OFF ]"
            btn.BackgroundColor3 = fbOn and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(30, 30, 42)
            Lighting.Brightness = fbOn and 3 or 1
            Lighting.GlobalShadows = not fbOn
        end)

        local windBotOn = false
        addButton("🌪️ 風怒機器人 (虛空攻擊 & 自動秒殺): [ OFF ]", function(btn)
            windBotOn = not windBotOn
            btn.Text = windBotOn and "  🌪️ 風怒機器人 (虛空攻擊 & 自動秒殺): [ ON ]" or "  🌪️ 風怒機器人 (虛空攻擊 & 自動秒殺): [ OFF ]"
            btn.BackgroundColor3 = windBotOn and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(30, 30, 42)
        end)

        -- 風怒機器人虛空秒殺循環執行緒
        RunService.Heartbeat:Connect(function()
            if windBotOn then
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= player and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                -- 1. 將目標傳送到虛空 (Y軸拉到極低位置) 實現虛空攻擊
                                hrp.CFrame = hrp.CFrame + Vector3.new(0, -5000, 0)
                                -- 2. 自動攻擊瞬間清空血量秒殺
                                hum.Health = 0
                            end
                        end
                    end
                end)
            end
        end)
    end
end

-- 建立分頁按鈕
for i, name in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1 / #tabs, -4, 1, -4)
    tabBtn.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
    tabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 10
    tabBtn.Parent = TabBar
    
    local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 4) tc.Parent = tabBtn
    tabBtn.MouseButton1Click:Connect(function() renderTab(name) end)
end

-- 預設開啟首頁
renderTab("main")
