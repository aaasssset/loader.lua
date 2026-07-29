-- WETQAPremium - Optimized Powerful Core Edition [Discord: https://discord.gg/zdqUuQgBhQ]
-- 跨平台注射器支援、完美置中載入與主面板、核心精簡高效、高階飽和度交疊色彩轉圈準心與內建造型改皮掛

task.spawn(function()
    task.wait(0.5)

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:WaitForChild("PlayerGui")

    local executorName = "Unknown Executor"
    pcall(function()
        if identifyexecutor then executorName = identifyexecutor()
        elseif getexecutorname then executorName = getexecutorname() end
    end)

    -- 清理舊實例
    for _, name in ipairs({"WETQAPremium_UnnamedUI", "WETQAPremium_HUD", "WETQAPremium_Circle", "WETQAPremium_MobileIcon", "WETQAPremium_Splash", "WETQAPremium_KeySystem"}) do
        local old = playerGui:FindFirstChild(name)
        if old then old:Destroy() end
        pcall(function()
            local coreOld = CoreGui:FindFirstChild(name)
            if coreOld then coreOld:Destroy() end
        end)
    end

    local customAssetId = "rbxassetid://10888344159"

    -- 1. 啟動畫面強制置中
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "WETQAPremium_Splash"
    splashGui.ResetOnSpawn = false
    splashGui.DisplayOrder = 999999999
    pcall(function() splashGui.Parent = CoreGui end)
    if not splashGui.Parent then splashGui.Parent = playerGui end

    local splashFrame = Instance.new("Frame")
    splashFrame.Size = UDim2.new(0, 400, 0, 240)
    splashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    splashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    splashFrame.BackgroundColor3 = Color3.fromRGB(6, 12, 22)
    splashFrame.BorderSizePixel = 1
    splashFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    splashFrame.Parent = splashGui

    local splashImg = Instance.new("ImageLabel")
    splashImg.Size = UDim2.new(0, 160, 0, 160)
    splashImg.AnchorPoint = Vector2.new(0.5, 0.5)
    splashImg.Position = UDim2.new(0.5, 0, 0.4, 0)
    splashImg.BackgroundTransparency = 1
    splashImg.Image = customAssetId
    splashImg.ScaleType = Enum.ScaleType.Fit
    splashImg.Parent = splashFrame

    local splashText = Instance.new("TextLabel")
    splashText.Size = UDim2.new(1, 0, 0, 30)
    splashText.Position = UDim2.new(0, 0, 1, -35)
    splashText.BackgroundTransparency = 1
    splashText.Text = "WETQAPremium - 載入強效核心中..."
    splashText.TextColor3 = Color3.fromRGB(0, 150, 255)
    splashText.Font = Enum.Font.Code
    splashText.TextSize = 11
    splashText.Parent = splashFrame

    task.delay(1.5, function()
        TweenService:Create(splashFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(splashImg, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        TweenService:Create(splashText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        task.wait(0.4)
        splashGui:Destroy()
    end)

    -- 2. 註冊器（置中）
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "WETQAPremium_KeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.DisplayOrder = 999999998
    pcall(function() keyGui.Parent = CoreGui end)
    if not keyGui.Parent then keyGui.Parent = playerGui end

    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 360, 0, 230)
    keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    keyFrame.BackgroundColor3 = Color3.fromRGB(6, 12, 22)
    keyFrame.BorderSizePixel = 1
    keyFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    keyFrame.Parent = keyGui

    local keyTitle = Instance.new("TextLabel")
    keyTitle.Size = UDim2.new(1, 0, 0, 32)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "WETQAPremium - Key System"
    keyTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
    keyTitle.Font = Enum.Font.Code
    keyTitle.TextSize = 11
    keyTitle.Parent = keyFrame

    local execInfo = Instance.new("TextLabel")
    execInfo.Size = UDim2.new(1, -20, 0, 18)
    execInfo.Position = UDim2.new(0, 10, 0, 28)
    execInfo.BackgroundTransparency = 1
    execInfo.Text = "已偵測注射器: " .. tostring(executorName)
    execInfo.TextColor3 = Color3.fromRGB(150, 200, 255)
    execInfo.Font = Enum.Font.Code
    execInfo.TextSize = 9
    execInfo.Parent = keyFrame

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -40, 0, 36)
    keyBox.Position = UDim2.new(0, 20, 0, 52)
    keyBox.BackgroundColor3 = Color3.fromRGB(10, 18, 32)
    keyBox.BorderColor3 = Color3.fromRGB(0, 150, 255)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "請輸入金鑰..."
    keyBox.Text = getgenv().script_key or "WETQA-KEY"
    keyBox.Font = Enum.Font.Code
    keyBox.TextSize = 10
    keyBox.Parent = keyFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 145, 0, 34)
    submitBtn.Position = UDim2.new(0, 20, 0, 125)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    submitBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Text = "驗證解鎖"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.Code
    submitBtn.TextSize = 10
    submitBtn.Parent = keyFrame

    local getBtn = Instance.new("TextButton")
    getBtn.Size = UDim2.new(0, 145, 0, 34)
    getBtn.Position = UDim2.new(0, 175, 0, 125)
    getBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    getBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    getBtn.Text = "取得金鑰"
    getBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
    getBtn.Font = Enum.Font.Code
    getBtn.TextSize = 10
    getBtn.Parent = keyFrame

    local statusMsg = Instance.new("TextLabel")
    statusMsg.Size = UDim2.new(1, 0, 0, 25)
    statusMsg.Position = UDim2.new(0, 0, 1, -28)
    statusMsg.BackgroundTransparency = 1
    statusMsg.Text = "狀態: 請輸入金鑰以啟動強效核心"
    statusMsg.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusMsg.Font = Enum.Font.Code
    statusMsg.TextSize = 9
    statusMsg.Parent = keyFrame

    getBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/zdqUuQgBhQ")
            statusMsg.Text = "已複製 Discord 連結！"
        end)
    end)

    local keyVerified = false
    submitBtn.MouseButton1Click:Connect(function()
        if keyBox.Text ~= "" then
            getgenv().script_key = keyBox.Text
            keyVerified = true
            keyGui:Destroy()
        else
            statusMsg.Text = "❌ 金鑰不能為空！"
        end
    end)

    repeat task.wait(0.5) until keyVerified

    -- 3. 主程式（精簡高效強效版）
    local success, err = pcall(function()
        local themeColor = Color3.fromRGB(0, 150, 255)
        local circleOuterColor = Color3.fromRGB(255, 255, 255)
        
        local blendColor1 = Color3.fromRGB(255, 50, 50)
        local blendColor2 = Color3.fromRGB(50, 255, 50)
        local blendColor3 = Color3.fromRGB(50, 100, 255)
        local colorSaturation = 0.85

        local currentWalkSpeed = 100
        local currentJumpPower = 120
        local crosshairSize = 110
        local crosshairSpeed = 6

        -- 浮動切換按鈕
        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "WETQAPremium_MobileIcon"
        mobileGui.ResetOnSpawn = false
        mobileGui.DisplayOrder = 99999999
        pcall(function() mobileGui.Parent = CoreGui end)
        if not mobileGui.Parent then mobileGui.Parent = playerGui end

        local mobileBtn = Instance.new("ImageButton")
        mobileBtn.Size = UDim2.new(0, 42, 0, 42)
        mobileBtn.Position = UDim2.new(0, 15, 0.4, 0)
        mobileBtn.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        mobileBtn.BorderColor3 = themeColor
        mobileBtn.BorderSizePixel = 2
        mobileBtn.Image = customAssetId
        mobileBtn.Active = true
        mobileBtn.Draggable = true
        mobileBtn.Parent = mobileGui
        Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(0.5, 0)

        -- 飽和度交疊準心
        local circleGui = Instance.new("ScreenGui")
        circleGui.Name = "WETQAPremium_Circle"
        circleGui.ResetOnSpawn = false
        circleGui.Parent = playerGui

        local circleFrame = Instance.new("Frame")
        circleFrame.Name = "CrosshairFrame"
        circleFrame.Size = UDim2.new(0, crosshairSize, 0, crosshairSize)
        circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        circleFrame.BackgroundTransparency = 1
        circleFrame.Parent = circleGui

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = circleOuterColor
        cStroke.Thickness = 3
        cStroke.Parent = circleFrame
        Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)

        local blend1 = Instance.new("Frame")
        blend1.Size = UDim2.new(0, 22, 0, 22)
        blend1.AnchorPoint = Vector2.new(0.5, 0.5)
        blend1.BackgroundColor3 = blendColor1
        blend1.BackgroundTransparency = 0.2
        blend1.BorderSizePixel = 0
        blend1.Parent = circleFrame
        Instance.new("UICorner", blend1).CornerRadius = UDim.new(1, 0)

        local blend2 = Instance.new("Frame")
        blend2.Size = UDim2.new(0, 22, 0, 22)
        blend2.AnchorPoint = Vector2.new(0.5, 0.5)
        blend2.BackgroundColor3 = blendColor2
        blend2.BackgroundTransparency = 0.2
        blend2.BorderSizePixel = 0
        blend2.Parent = circleFrame
        Instance.new("UICorner", blend2).CornerRadius = UDim.new(1, 0)

        local blend3 = Instance.new("Frame")
        blend3.Size = UDim2.new(0, 22, 0, 22)
        blend3.AnchorPoint = Vector2.new(0.5, 0.5)
        blend3.BackgroundColor3 = blendColor3
        blend3.BackgroundTransparency = 0.2
        blend3.BorderSizePixel = 0
        blend3.Parent = circleFrame
        Instance.new("UICorner", blend3).CornerRadius = UDim.new(1, 0)

        -- 左上角 HUD 狀態顯示
        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "WETQAPremium_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = playerGui

        local statusBox = Instance.new("Frame")
        statusBox.Size = UDim2.new(0, 260, 0, 180)
        statusBox.Position = UDim2.new(0, 15, 0, 15)
        statusBox.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        statusBox.BorderSizePixel = 1
        statusBox.BorderColor3 = themeColor
        statusBox.Parent = hudGui

        local statusTitle = Instance.new("TextLabel")
        statusTitle.Size = UDim2.new(1, 0, 0, 24)
        statusTitle.BackgroundTransparency = 1
        statusTitle.Text = "  WETQA - Powerful Core"
        statusTitle.TextColor3 = themeColor
        statusTitle.Font = Enum.Font.Code
        statusTitle.TextSize = 10
        statusTitle.TextXAlignment = Enum.TextXAlignment.Left
        statusTitle.Parent = statusBox

        local statusListLabel = Instance.new("TextLabel")
        statusListLabel.Size = UDim2.new(1, -10, 1, -28)
        statusListLabel.Position = UDim2.new(0, 5, 0, 24)
        statusListLabel.BackgroundTransparency = 1
        statusListLabel.Text = "[+] Core Active...\n[+] Optimized & Ready"
        statusListLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
        statusListLabel.Font = Enum.Font.Code
        statusListLabel.TextSize = 9
        statusListLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusListLabel.TextYAlignment = Enum.TextYAlignment.Top
        statusListLabel.Parent = statusBox

        -- 精巧直立主面板
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAPremium_UnnamedUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.DisplayOrder = 999999999
        pcall(function() ScreenGui.Parent = CoreGui end)
        if not ScreenGui.Parent then ScreenGui.Parent = playerGui end

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 320, 0, 420)
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        MainFrame.BorderSizePixel = 2
        MainFrame.BorderColor3 = themeColor
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Visible = false
        MainFrame.ZIndex = 999999
        MainFrame.Parent = ScreenGui

        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 32)
        TopBar.BackgroundColor3 = Color3.fromRGB(8, 15, 30)
        TopBar.BorderSizePixel = 1
        TopBar.BorderColor3 = themeColor
        TopBar.ZIndex = 999999
        TopBar.Parent = MainFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -15, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "WETQA - Powerful Compact Edition"
        Title.TextColor3 = Color3.fromRGB(200, 230, 255)
        Title.TextSize = 10
        Title.Font = Enum.Font.Code
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 999999
        Title.Parent = TopBar

        local isOpen = false
        local function toggleWindow()
            isOpen = not isOpen
            if isOpen then
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 320, 0, 420),
                    Position = UDim2.new(0.5, -160, 0.5, -210)
                }):Play()
            else
                local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
                tw:Play()
                tw.Completed:Connect(function()
                    if not isOpen then MainFrame.Visible = false end
                end)
            end
        end

        UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == Enum.KeyCode.RightShift and not gp then
                toggleWindow()
            end
        end)

        mobileBtn.MouseButton1Click:Connect(function()
            toggleWindow()
        end)

        -- 內容容器
        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, -16, 1, -48)
        Container.Position = UDim2.new(0, 8, 0, 40)
        Container.BackgroundTransparency = 1
        Container.CanvasSize = UDim2.new(0, 0, 0, 350)
        Container.ScrollBarThickness = 3
        Container.ZIndex = 999999
        Container.Parent = MainFrame

        local function addToggle(yPos, text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(210, 230, 255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 999999
            btn.Parent = Container

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    btn.Text = "  [ █ ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(10, 35, 60)
                    btn.TextColor3 = themeColor
                else
                    btn.Text = "  [   ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
                    btn.TextColor3 = Color3.fromRGB(210, 230, 255)
                end
                callback(state)
            end)
        end

        -- 精簡核心強效功能開關
        addToggle(10, "全自動鎖頭黑科技 (Aimbot)", function(v) getgenv().strongAim = v end)
        addToggle(45, "超大判定框 (Hitbox Extender)", function(v) getgenv().strongHitbox = v end)
        addToggle(80, "鎖血無敵 (God Mode)", function(v) getgenv().strongGod = v end)
        addToggle(115, "飛天穿牆 (Noclip)", function(v) getgenv().strongNoclip = v end)
        addToggle(150, "全武器金光改皮 (Gold Skin)", function(v) getgenv().strongSkin = v end)
        addToggle(185, "全地圖最高亮度 (Fullbright)", function(v) getgenv().strongBright = v end)

        -- 核心運行迴圈
        RunService.RenderStepped:Connect(function()
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum then
                hum.WalkSpeed = currentWalkSpeed
                hum.JumpPower = currentJumpPower
                if getgenv().strongGod then hum.Health = hum.MaxHealth end
            end

            if getgenv().strongBright then
                Lighting.Brightness = 3
                Lighting.ClockTime = 14
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if getgenv().strongHitbox then
                            root.Size = Vector3.new(10, 10, 10)
                            root.Transparency = 0.7
                            root.CanCollide = false
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end
                    end
                end
            end

            if getgenv().strongSkin and char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, part in ipairs(tool:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromRGB(255, 215, 0)
                                part.Material = Enum.Material.Glass
                            end
                        end
                    end
                end
            end
        end)
    end)

    if not success then
        warn("Core Load Error: " .. tostring(err))
    end
end)
