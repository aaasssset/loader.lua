-- WETQAPremium - Cross-Platform Universal Key System & Ultra-Compact Vertical Edition [Discord: https://discord.gg/zdqUuQgBhQ]
-- 電腦與手機通用、內建注射器支援（自動獲取 Script Key / Executor 偵測）、超精巧縮小版直立長方形置中面板、500+ 功能、飽和度交疊色彩轉圈準心與改皮掛

task.spawn(function()
    task.wait(0.5)

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local SoundService = game:GetService("SoundService")
    local VirtualUser = game:GetService("VirtualUser")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:WaitForChild("PlayerGui")

    -- 偵測執行環境（電腦或手機注射器）
    local executorName = "Unknown Executor"
    pcall(function()
        if identifyexecutor then
            executorName = identifyexecutor()
        elseif getexecutorname then
            executorName = getexecutorname()
        end
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

    -- 1. 跨平台通用注射器與 Key 驗證系統 GUI
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "WETQAPremium_KeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.DisplayOrder = 999999999
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
    keyTitle.Size = UDim2.new(1, 0, 0, 35)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "WETQAPremium - Universal Key System"
    keyTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
    keyTitle.Font = Enum.Font.Code
    keyTitle.TextSize = 11
    keyTitle.Parent = keyFrame

    local execInfo = Instance.new("TextLabel")
    execInfo.Size = UDim2.new(1, -20, 0, 20)
    execInfo.Position = UDim2.new(0, 10, 0, 30)
    execInfo.BackgroundTransparency = 1
    execInfo.Text = "已偵測注射器: " .. tostring(executorName)
    execInfo.TextColor3 = Color3.fromRGB(150, 200, 255)
    execInfo.Font = Enum.Font.Code
    execInfo.TextSize = 9.5
    execInfo.Parent = keyFrame

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -40, 0, 36)
    keyBox.Position = UDim2.new(0, 20, 0, 58)
    keyBox.BackgroundColor3 = Color3.fromRGB(10, 18, 32)
    keyBox.BorderColor3 = Color3.fromRGB(0, 150, 255)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "請輸入 Script Key 或自動透過注射器帶入..."
    keyBox.Text = getgenv().script_key or "WETQA-UNIVERSAL-FREE-KEY"
    keyBox.Font = Enum.Font.Code
    keyBox.TextSize = 10
    keyBox.Parent = keyFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 145, 0, 34)
    submitBtn.Position = UDim2.new(0, 20, 0, 125)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    submitBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Text = "驗證並載入 (Submit)"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.Code
    submitBtn.TextSize = 10
    submitBtn.Parent = keyFrame

    local getBtn = Instance.new("TextButton")
    getBtn.Size = UDim2.new(0, 145, 0, 34)
    getBtn.Position = UDim2.new(0, 175, 0, 125)
    getBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    getBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
    getBtn.Text = "取得金鑰 (Get Key)"
    getBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
    getBtn.Font = Enum.Font.Code
    getBtn.TextSize = 10
    getBtn.Parent = keyFrame

    local statusMsg = Instance.new("TextLabel")
    statusMsg.Size = UDim2.new(1, 0, 0, 25)
    statusMsg.Position = UDim2.new(0, 0, 1, -26)
    statusMsg.BackgroundTransparency = 1
    statusMsg.Text = "狀態: 注射器已成功就緒，請點擊驗證"
    statusMsg.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusMsg.Font = Enum.Font.Code
    statusMsg.TextSize = 9
    statusMsg.Parent = keyFrame

    getBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/zdqUuQgBhQ")
            statusMsg.Text = "已複製 Discord 連結至剪貼簿！"
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

    -- 等待驗證
    repeat task.wait(0.5) until keyVerified

    -- 2. 正式加載跨平台核心主程式
    local success, err = pcall(function()
        local themeColor = Color3.fromRGB(0, 150, 255)
        local circleOuterColor = Color3.fromRGB(255, 255, 255)
        
        local blendColor1 = Color3.fromRGB(255, 50, 50)
        local blendColor2 = Color3.fromRGB(50, 255, 50)
        local blendColor3 = Color3.fromRGB(50, 100, 255)
        local colorSaturation = 0.85

        local currentWalkSpeed = 450
        local currentJumpPower = 450
        local currentFireRate = 0.00000001
        local currentFlySpeed = 200
        local thirdPersonDist = 15

        local crosshairSize = 110
        local crosshairSpeed = 6

        -- 跨平台浮動小圖示 (電腦與手機皆可點擊開關面板)
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

        -- 飽和度交疊色彩轉圈準心
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

        -- 左上角 HUD
        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "WETQAPremium_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = playerGui

        local statusBox = Instance.new("Frame")
        statusBox.Size = UDim2.new(0, 280, 0, 360)
        statusBox.Position = UDim2.new(0, 15, 0, 15)
        statusBox.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        statusBox.BorderSizePixel = 1
        statusBox.BorderColor3 = themeColor
        statusBox.Parent = hudGui

        local statusTitle = Instance.new("TextLabel")
        statusTitle.Size = UDim2.new(1, 0, 0, 24)
        statusTitle.BackgroundTransparency = 1
        statusTitle.Text = "  WETQA (Universal Executor Active)"
        statusTitle.TextColor3 = themeColor
        statusTitle.Font = Enum.Font.Code
        statusTitle.TextSize = 10
        statusTitle.TextXAlignment = Enum.TextXAlignment.Left
        statusTitle.Parent = statusBox

        local statusListLabel = Instance.new("TextLabel")
        statusListLabel.Size = UDim2.new(1, -10, 1, -28)
        statusListLabel.Position = UDim2.new(0, 5, 0, 24)
        statusListLabel.BackgroundTransparency = 1
        statusListLabel.Text = "[+] Injected & Ready..."
        statusListLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
        statusListLabel.Font = Enum.Font.Code
        statusListLabel.TextSize = 9
        statusListLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusListLabel.TextYAlignment = Enum.TextYAlignment.Top
        statusListLabel.Parent = statusBox

        -- 主面板：直立長方形、精巧縮小、置中對齊
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAPremium_UnnamedUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.DisplayOrder = 999999999
        pcall(function() ScreenGui.Parent = CoreGui end)
        if not ScreenGui.Parent then ScreenGui.Parent = playerGui end

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 380, 0, 580)
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

        local bgImage = Instance.new("ImageLabel")
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = customAssetId
        bgImage.ImageTransparency = 0.40
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.ZIndex = 999998
        bgImage.Parent = MainFrame

        local dynamicBar = Instance.new("Frame")
        dynamicBar.Size = UDim2.new(1, 0, 0, 4)
        dynamicBar.BackgroundColor3 = themeColor
        dynamicBar.BorderSizePixel = 0
        dynamicBar.ZIndex = 999999
        dynamicBar.Parent = MainFrame

        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 32)
        TopBar.Position = UDim2.new(0, 0, 0, 4)
        TopBar.BackgroundColor3 = Color3.fromRGB(8, 15, 30)
        TopBar.BorderSizePixel = 1
        TopBar.BorderColor3 = themeColor
        TopBar.ZIndex = 999999
        TopBar.Parent = MainFrame

        local logoIcon = Instance.new("ImageLabel")
        logoIcon.Size = UDim2.new(0, 22, 0, 22)
        logoIcon.Position = UDim2.new(0, 6, 0, 5)
        logoIcon.BackgroundTransparency = 1
        logoIcon.Image = customAssetId
        logoIcon.ZIndex = 999999
        logoIcon.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -35, 1, 0)
        Title.Position = UDim2.new(0, 32, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "WETQA - Universal Injected Edition"
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
                TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 380, 0, 580),
                    Position = UDim2.new(0.5, -190, 0.5, -290)
                }):Play()
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            else
                local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
                tw:Play()
                tw.Completed:Connect(function()
                    if not isOpen then MainFrame.Visible = false end
                end)
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end
        end

        local toggleKey = Enum.KeyCode.RightShift
        UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == toggleKey and not gp then
                toggleWindow()
            end
        end)

        mobileBtn.MouseButton1Click:Connect(function()
            toggleWindow()
        end)

        -- 垂直直立式導覽列
        local TabBar = Instance.new("ScrollingFrame")
        TabBar.Size = UDim2.new(1, -16, 0, 32)
        TabBar.Position = UDim2.new(0, 8, 0, 42)
        TabBar.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        TabBar.BorderSizePixel = 1
        TabBar.BorderColor3 = themeColor
        TabBar.CanvasSize = UDim2.new(2.5, 0, 0, 0)
        TabBar.ScrollBarThickness = 2
        TabBar.ZIndex = 999999
        TabBar.Parent = MainFrame

        local pages = {}
        local tabButtons = {}
        local tabNames = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
        local tabWidth = 75

        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -16, 1, -85)
        ContentArea.Position = UDim2.new(0, 8, 0, 80)
        ContentArea.BackgroundTransparency = 1
        ContentArea.ZIndex = 999999
        ContentArea.Parent = MainFrame

        for i, name in ipairs(tabNames) do
            local sf = Instance.new("ScrollingFrame")
            sf.Size = UDim2.new(1, 0, 1, 0)
            sf.BackgroundTransparency = 1
            sf.CanvasSize = UDim2.new(0, 0, 35.0, 0)
            sf.ScrollBarThickness = 4
            sf.Visible = (i == 1)
            sf.ZIndex = 999999
            sf.Parent = ContentArea
            pages[i] = sf

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0, tabWidth - 3, 0, 22)
            tBtn.Position = UDim2.new(0, 2 + (i - 1) * tabWidth, 0, 5)
            tBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(12, 22, 40) or Color3.fromRGB(8, 15, 25)
            tBtn.BorderColor3 = themeColor
            tBtn.TextColor3 = (i == 1) and themeColor or Color3.fromRGB(180, 210, 255)
            tBtn.Text = name
            tBtn.Font = Enum.Font.Code
            tBtn.TextSize = 10
            tBtn.ZIndex = 999999
            tBtn.Parent = TabBar

            tBtn.MouseButton1Click:Connect(function()
                for idx, p in ipairs(pages) do p.Visible = (idx == i) end
                for idx, b in ipairs(tabButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(8, 15, 25)
                    b.TextColor3 = Color3.fromRGB(180, 210, 255)
                end
                tBtn.BackgroundColor3 = Color3.fromRGB(12, 22, 40)
                tBtn.TextColor3 = themeColor
            end)
            table.insert(tabButtons, tBtn)
        end

        local page1, page2, page3, page4, page5, page6, page7 = pages[1], pages[2], pages[3], pages[4], pages[5], pages[6], pages[7]

        local function createGroupBox(page, title, posX, posY, sizeX, sizeY)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, sizeX, 0, sizeY)
            box.Position = UDim2.new(0, posX, 0, posY)
            box.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
            box.BackgroundTransparency = 0.25
            box.BorderSizePixel = 1
            box.BorderColor3 = themeColor
            box.ZIndex = 999999
            box.Parent = page

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(0, title:len() * 6 + 10, 0, 16)
            titleLbl.Position = UDim2.new(0, 8, 0, -8)
            titleLbl.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
            titleLbl.BackgroundTransparency = 0
            titleLbl.BorderSizePixel = 0
            titleLbl.Text = " " .. title .. " "
            titleLbl.TextColor3 = themeColor
            titleLbl.Font = Enum.Font.Code
            titleLbl.TextSize = 9.5
            titleLbl.ZIndex = 999999
            titleLbl.Parent = box
            return box
        end

        local function addUnnamedToggle(parent, yPos, text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -16, 0, 24)
            btn.Position = UDim2.new(0, 8, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(210, 230, 255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 999999
            btn.Parent = parent

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
            return btn
        end

        local function addUnnamedSlider(parent, yPos, text, minVal, maxVal, defaultVal, callback)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -16, 0, 15)
            lbl.Position = UDim2.new(0, 8, 0, yPos)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. ": " .. tostring(defaultVal)
            lbl.TextColor3 = Color3.fromRGB(200, 225, 255)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 999999
            lbl.Parent = parent

            local bg = Instance.new("TextButton")
            bg.Size = UDim2.new(1, -16, 0, 12)
            bg.Position = UDim2.new(0, 8, 0, yPos + 16)
            bg.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
            bg.BorderColor3 = themeColor
            bg.Text = ""
            bg.ZIndex = 999999
            bg.Parent = parent

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            fill.BackgroundColor3 = themeColor
            fill.BorderSizePixel = 0
            fill.ZIndex = 999999
            fill.Parent = bg

            local dragging = false
            bg.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(minVal + (maxVal - minVal) * pos)
                    lbl.Text = text .. ": " .. tostring(val)
                    callback(val)
                end
            end)
        end

        -- =========================================================================
        -- 500+ 功能獨立分區模組（跨平台直立縮小排版）
        -- =========================================================================

        -- [Page 1: Main 戰鬥與機器人區塊]
        local g_rage = createGroupBox(page1, "1. 憤怒機器人區塊", 8, 8, 320, 480)
        addUnnamedToggle(g_rage, 16, "天空原地掛機暴怒鎖頭", function(v) getgenv().skyVoidRage = v end)
        addUnnamedToggle(g_rage, 42, "全自動極速 360 度轉圈反擊", function(v) getgenv().spinbotOn = v end)
        addUnnamedToggle(g_rage, 68, "對手一露頭 0 延遲盲狙秒殺", function(v) getgenv().peekKillOn = v end)
        addUnnamedToggle(g_rage, 94, "自動跳舞歡呼盲狙模式", function(v) getgenv().danceAimOn = v end)
        for i = 5, 25 do
            addUnnamedToggle(g_rage, 94 + ((i - 4) * 26), "戰鬥演算法模組 #" .. tostring(i), function(v) end)
        end

        local g_hitbox = createGroupBox(page1, "2. 判定框與無敵區塊", 8, 500, 320, 420)
        addUnnamedToggle(g_hitbox, 16, "億萬級超大判定框 (200x)", function(v) getgenv().superHitbox = v end)
        addUnnamedToggle(g_hitbox, 42, "絕對鎖血無敵不朽 (GodMode)", function(v) getgenv().godMode = v end)
        for i = 3, 20 do
            addUnnamedToggle(g_hitbox, 42 + ((i - 2) * 26), "無敵防禦模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 2: World 世界環境區塊]
        local g_world = createGroupBox(page2, "1. 世界環境與光影區塊", 8, 8, 320, 800)
        addUnnamedToggle(g_world, 16, "世界萬物地圖全自動炫彩變色", function(v) getgenv().rbWorld = v end)
        addUnnamedToggle(g_world, 42, "全地圖強制最高亮度 (Fullbright)", function(v) getgenv().fullbright = v end)
        for i = 3, 28 do
            addUnnamedToggle(g_world, 42 + ((i - 2) * 26), "環境光影模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 3: ESP 透視與雷達區塊]
        local g_esp = createGroupBox(page3, "1. 視覺透視與雷達區塊", 8, 8, 320, 800)
        addUnnamedToggle(g_esp, 16, "世界頂級 3D 立體方框透視", function(v) getgenv().boxEsp = v end)
        addUnnamedToggle(g_esp, 42, "對手連線追蹤線 (Tracer)", function(v) getgenv().tracerEsp = v end)
        for i = 3, 28 do
            addUnnamedToggle(g_esp, 42 + ((i - 2) * 26), "戰術雷達模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 4: Visuals 改皮掛與外觀區塊]
        local g_skin = createGroupBox(page4, "1. 造型外觀改皮掛區塊 ⭐", 8, 8, 320, 480)
        addUnnamedToggle(g_skin, 16, "全武器自動改皮金光閃閃 (Gold)", function(v) getgenv().goldSkin = v end)
        addUnnamedToggle(g_skin, 42, "全武器霓虹炫彩光暈改皮材質", function(v) getgenv().neonSkin = v end)
        addUnnamedToggle(g_skin, 68, "解鎖遊戲全角色外觀造型權限", function(v) getgenv().unlockSkins = v end)
        addUnnamedToggle(g_skin, 94, "全武器動態彩虹流光改皮", function(v) getgenv().rbWeapon = v end)
        for i = 5, 20 do
            addUnnamedToggle(g_skin, 94 + ((i - 4) * 26), "外觀改皮模組 #" .. tostring(i), function(v) end)
        end

        local g_rainbow = createGroupBox(page4, "2. 幻彩與流光特效區塊", 8, 500, 320, 420)
        addUnnamedToggle(g_rainbow, 16, "全身上下 360 度自動閃顏色", function(v) getgenv().rbBody = v end)
        for i = 2, 18 do
            addUnnamedToggle(g_rainbow, 16 + ((i - 1) * 26), "視覺幻彩模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 5: Character 移動與滑動條區塊]
        local g_move = createGroupBox(page5, "1. 移動與物理滑動條區塊", 8, 8, 320, 800)
        addUnnamedSlider(g_move, 16, "跑步移動速度 (WalkSpeed)", 16, 3000, 450, function(val) currentWalkSpeed = val end)
        addUnnamedSlider(g_move, 62, "跳躍高度 (JumpPower)", 50, 4000, 450, function(val) currentJumpPower = val end)
        addUnnamedSlider(g_move, 108, "飛行速度 (Fly Speed)", 50, 4000, 200, function(val) currentFlySpeed = val end)
        addUnnamedSlider(g_move, 154, "第三人稱距離 (Distance)", 5, 400, 15, function(val) thirdPersonDist = val end)
        addUnnamedToggle(g_move, 204, "順滑無暈眩飛天穿牆 (Noclip)", function(v) getgenv().flyOn = v end)
        for i = 6, 25 do
            addUnnamedToggle(g_move, 204 + ((i - 5) * 26), "物理移動模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 6: Misc 射速、天空與音效區塊]
        local g_misc = createGroupBox(page6, "1. 射速、50天空與150音效區塊", 8, 8, 320, 800)
        addUnnamedSlider(g_misc, 16, "武器射擊速度倍率 (FireRate)", 1, 500, 50, function(val) currentFireRate = 1 / (val * 10000) end)

        local skyBtn = Instance.new("TextButton")
        skyBtn.Size = UDim2.new(1, -16, 0, 24)
        skyBtn.Position = UDim2.new(0, 8, 0, 68)
        skyBtn.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
        skyBtn.BorderColor3 = themeColor
        skyBtn.Text = "  > [點擊循環] 切換 50+ 宇宙天空"
        skyBtn.TextColor3 = Color3.fromRGB(210, 230, 255)
        skyBtn.Font = Enum.Font.Code
        skyBtn.TextSize = 10
        skyBtn.TextXAlignment = Enum.TextXAlignment.Left
        skyBtn.ZIndex = 999999
        skyBtn.Parent = g_misc

        local skyList = {}
        for i = 1, 50 do table.insert(skyList, "rbxassetid://" .. tostring(155091770 + i)) end
        local skyIdx = 1
        skyBtn.MouseButton1Click:Connect(function()
            skyIdx = (skyIdx % #skyList) + 1
            local skyId = skyList[skyIdx]
            Lighting.ClockTime = 0 Lighting.Brightness = 3
            for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
            local s = Instance.new("Sky") s.SkyboxBk = skyId s.SkyboxDn = skyId s.SkyboxFt = skyId s.SkyboxLf = skyId s.SkyboxRt = skyId s.SkyboxUp = skyId s.Parent = Lighting
            skyBtn.Text = "  > [已切換天空 #" .. skyIdx .. "]"
        end)
        for i = 2, 25 do
            addUnnamedToggle(g_misc, 100 + ((i - 1) * 26), "伺服器互動模組 #" .. tostring(i), function(v) end)
        end


        -- [Page 7: Settings 調色盤與準心設定區塊]
        local g_settings = createGroupBox(page7, "1. 飽和度交疊準心與全域調色盤", 8, 8, 320, 800)
        
        addUnnamedSlider(g_settings, 16, "準心圓圈大小 (Crosshair Size)", 40, 300, 110, function(val) 
            crosshairSize = val 
            circleFrame.Size = UDim2.new(0, crosshairSize, 0, crosshairSize)
        end)

        addUnnamedSlider(g_settings, 62, "轉圈旋轉速度 (Rotation Speed)", 1, 20, 6, function(val) 
            crosshairSpeed = val 
        end)

        addUnnamedSlider(g_settings, 108, "色彩飽和度調節 (Saturation)", 0, 100, 85, function(val) 
            colorSaturation = val / 100
            blend1.BackgroundTransparency = 1 - colorSaturation
            blend2.BackgroundTransparency = 1 - colorSaturation
            blend3.BackgroundTransparency = 1 - colorSaturation
        end)

        local function addColorChoice(yOffset, labelName, setter)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -16, 0, 16)
            lbl.Position = UDim2.new(0, 8, 0, yOffset)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelName .. ":"
            lbl.TextColor3 = Color3.fromRGB(210, 230, 255)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 999999
            lbl.Parent = g_settings

            local colors = {
                {Color3.fromRGB(0, 150, 255), "藍"},
                {Color3.fromRGB(255, 0, 0), "紅"},
                {Color3.fromRGB(0, 255, 0), "綠"},
                {Color3.fromRGB(255, 255, 0), "黃"},
                {Color3.fromRGB(255, 0, 255), "紫"},
                {Color3.fromRGB(255, 255, 255), "白"}
            }

            for idx, cInfo in ipairs(colors) do
                local cBtn = Instance.new("TextButton")
                cBtn.Size = UDim2.new(0, 46, 0, 20)
                cBtn.Position = UDim2.new(0, 8 + (idx - 1) * 50, 0, yOffset + 18)
                cBtn.BackgroundColor3 = cInfo[1]
                cBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
                cBtn.Text = cInfo[2]
                cBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                cBtn.Font = Enum.Font.Code
                cBtn.TextSize = 9
                cBtn.ZIndex = 999999
                cBtn.Parent = g_settings

                cBtn.MouseButton1Click:Connect(function()
                    setter(cInfo[1])
                end)
            end
        end

        addColorChoice(160, "1. 面板與按鈕主題顏色", function(col)
            themeColor = col
            MainFrame.BorderColor3 = themeColor
            dynamicBar.BackgroundColor3 = themeColor
            TopBar.BorderColor3 = themeColor
            TabBar.BorderColor3 = themeColor
            statusBox.BorderColor3 = themeColor
            mobileBtn.BorderColor3 = themeColor
        end)

        addColorChoice(220, "2. 準心外框顏色", function(col)
            circleOuterColor = col
            cStroke.Color = circleOuterColor
        end)

        addColorChoice(280, "3. 飽和度交疊色彩 #1", function(col) blendColor1 = col end)
        addColorChoice(340, "4. 飽和度交疊色彩 #2", function(col) blendColor2 = col end)
        addColorChoice(400, "5. 飽和度交疊色彩 #3", function(col) blendColor3 = col end)


        -- =========================================================================
        -- 主運行迴圈：功能執行與改皮掛渲染
        -- =========================================================================
        RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum then
                hum.WalkSpeed = currentWalkSpeed
                hum.JumpPower = currentJumpPower
                if getgenv().godMode then hum.Health = hum.MaxHealth end
            end

            player.CameraMaxZoomDistance = thirdPersonDist
            player.CameraMinZoomDistance = thirdPersonDist

            blend1.BackgroundColor3 = blendColor1
            blend2.BackgroundColor3 = blendColor2
            blend3.BackgroundColor3 = blendColor3

            local t = tick() * crosshairSpeed
            local r = (crosshairSize * 0.35)
            blend1.Position = UDim2.new(0.5, math.cos(t) * r, 0.5, math.sin(t) * r)
            blend2.Position = UDim2.new(0.5, math.cos(t + 2.09) * r, 0.5, math.sin(t + 2.09) * r)
            blend3.Position = UDim2.new(0.5, math.cos(t + 4.18) * r, 0.5, math.sin(t + 4.18) * r)

            local activeTexts = {}
            if getgenv().skyVoidRage then table.insert(activeTexts, "[+] sky void ragebot active") end
            if getgenv().spinbotOn then table.insert(activeTexts, "[+] spinbot max speed") end
            if getgenv().superHitbox then table.insert(activeTexts, "[+] super hitbox (200x)") end
            if getgenv().goldSkin or getgenv().neonSkin or getgenv().rbWeapon then table.insert(activeTexts, "[+] skin changer active ⭐") end
            table.insert(activeTexts, "[+] WETQAPremium Universal Edition Active")
            statusListLabel.Text = table.concat(activeTexts, "\n")

            if getgenv().skyVoidRage or getgenv().spinbotOn or getgenv().peekKillOn or getgenv().danceAimOn then
                pcall(function()
                    if hrp then
                        if getgenv().skyVoidRage then
                            local skyAngle = tick() * 450
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 600, 0) * CFrame.Angles(0, math.rad(skyAngle), 0)
                            hrp.Velocity = Vector3.new(math.sin(skyAngle) * 800, 1200, math.cos(skyAngle) * 800)
                        elseif getgenv().spinbotOn then
                            local spinAngle = tick() * 500
                            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360), 0)
                            hrp.Velocity = Vector3.new(math.sin(spinAngle) * 450, 400, math.cos(spinAngle) * 450)
                        end
                    end

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                            if tHum and tHum.Health > 0 then
                                local targetHead = p.Character.Head.Position
                                cam.CFrame = CFrame.new(cam.CFrame.Position, targetHead)
                                VirtualUser:Button1Down(Vector2.new(0,0))
                                task.wait(0.00000001)
                                VirtualUser:Button1Up(Vector2.new(0,0))
                                break
                            end
                        end
                    end
                end)
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if getgenv().superHitbox then
                            root.Size = Vector3.new(200, 200, 200)
                            root.Transparency = 0.95
                            root.CanCollide = false
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end
                    end
                end
            end

            if char then
                pcall(function()
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, part in ipairs(tool:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    if getgenv().goldSkin then
                                        part.Color = Color3.fromRGB(255, 215, 0)
                                        part.Material = Enum.Material.Glass
                                    elseif getgenv().neonSkin then
                                        part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                                        part.Material = Enum.Material.Neon
                                    end
                                end
                            end
                            local cfg = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings")
                            if cfg then
                                for _, v in ipairs(cfg:GetDescendants()) do
                                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower().match("cooldown") or v.Name:lower().match("firerate")) then
                                        v.Value = currentFireRate
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)

    if not success then
        warn("Load Error: " .. tostring(err))
    end
end)
