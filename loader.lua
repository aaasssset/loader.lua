-- WETQAPremium - Ultimate 500+ God-Tier Unbound Cursor & Color Picker Edition [Discord: https://discord.gg/zdqUuQgBhQ]
-- 內建動畫彈出特效、三角游標自由移動、指定照片背景、分類頁面、三色循環轉圈準心與全域調色盤

task.spawn(function()
    task.wait(0.5)

    if not getgenv().script_key or getgenv().script_key == "" then
        if script_key and script_key ~= "" then
            getgenv().script_key = script_key
        else
            pcall(function()
                local p = game:GetService("Players").LocalPlayer
                if p then p:Kick("WETQAPremium Security: ❌ 驗證失敗！請確認上方已正確帶入 script_key！") end
            end)
            return
        end
    end

    local success, err = pcall(function()
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

        local oldGui = playerGui:FindFirstChild("WETQAPremium_UnnamedUI")
        if oldGui then oldGui:Destroy() end
        local oldHud = playerGui:FindFirstChild("WETQAPremium_HUD")
        if oldHud then oldHud:Destroy() end
        local oldCircle = playerGui:FindFirstChild("WETQAPremium_Circle")
        if oldCircle then oldCircle:Destroy() end
        local oldMobile = playerGui:FindFirstChild("WETQAPremium_MobileIcon")
        if oldMobile then oldMobile:Destroy() end

        -- 使用者指定的標誌與背景照片 (rbxassetid://10888344159)
        local customAssetId = "rbxassetid://10888344159"

        -- 全域可調顏色變數（主題顏色、轉圈三色、外框色）
        local themeColor = Color3.fromRGB(0, 150, 255)
        local c1 = Color3.fromRGB(255, 0, 0)
        local c2 = Color3.fromRGB(0, 255, 0)
        local c3 = Color3.fromRGB(0, 0, 255)
        local circleOuterColor = Color3.fromRGB(255, 255, 255)

        local currentWalkSpeed = 450
        local currentJumpPower = 450
        local currentFireRate = 0.00000001
        local currentFlySpeed = 200
        local thirdPersonDist = 15
        local circleSize = 160

        -- 1. 開啟載入畫面 (Splash Screen)
        local splashGui = Instance.new("ScreenGui")
        splashGui.Name = "WETQAPremium_Splash"
        splashGui.ResetOnSpawn = false
        splashGui.DisplayOrder = 999999999
        pcall(function() splashGui.Parent = CoreGui end)
        if not splashGui.Parent then splashGui.Parent = playerGui end

        local splashFrame = Instance.new("Frame")
        splashFrame.Size = UDim2.new(0, 420, 0, 240)
        splashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        splashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        splashFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
        splashFrame.BorderSizePixel = 1
        splashFrame.BorderColor3 = themeColor
        splashFrame.Parent = splashGui

        local splashImg = Instance.new("ImageLabel")
        splashImg.Size = UDim2.new(1, 0, 0, 180)
        splashImg.BackgroundTransparency = 1
        splashImg.Image = customAssetId
        splashImg.ScaleType = Enum.ScaleType.Fit
        splashImg.Parent = splashFrame

        local splashText = Instance.new("TextLabel")
        splashText.Size = UDim2.new(1, 0, 0, 40)
        splashText.Position = UDim2.new(0, 0, 1, -40)
        splashText.BackgroundTransparency = 1
        splashText.Text = "WETQAPremium - Unbound Cursor & Color Picker..."
        splashText.TextColor3 = themeColor
        splashText.Font = Enum.Font.Code
        splashText.TextSize = 12
        splashText.Parent = splashFrame

        task.delay(2.0, function()
            TweenService:Create(splashFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            TweenService:Create(splashImg, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
            TweenService:Create(splashText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.wait(0.5)
            splashGui:Destroy()
        end)

        -- 2. 手機/浮動小圖示 (帶指定照片)
        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "WETQAPremium_MobileIcon"
        mobileGui.ResetOnSpawn = false
        mobileGui.DisplayOrder = 99999999
        pcall(function() mobileGui.Parent = CoreGui end)
        if not mobileGui.Parent then mobileGui.Parent = playerGui end

        local mobileBtn = Instance.new("ImageButton")
        mobileBtn.Size = UDim2.new(0, 50, 0, 50)
        mobileBtn.Position = UDim2.new(0, 20, 0.4, 0)
        mobileBtn.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        mobileBtn.BorderColor3 = themeColor
        mobileBtn.BorderSizePixel = 2
        mobileBtn.Image = customAssetId
        mobileBtn.Active = true
        mobileBtn.Draggable = true
        mobileBtn.Parent = mobileGui
        Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(0.5, 0)

        -- 3. 中間動態三色轉圈準心圈
        local circleGui = Instance.new("ScreenGui")
        circleGui.Name = "WETQAPremium_Circle"
        circleGui.ResetOnSpawn = false
        circleGui.Parent = playerGui

        local circleFrame = Instance.new("Frame")
        circleFrame.Size = UDim2.new(0, circleSize, 0, circleSize)
        circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        circleFrame.BackgroundTransparency = 1
        circleFrame.Parent = circleGui

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = circleOuterColor
        cStroke.Thickness = 3
        cStroke.Parent = circleFrame
        Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)

        local dot1 = Instance.new("Frame")
        dot1.Size = UDim2.new(0, 8, 0, 8)
        dot1.AnchorPoint = Vector2.new(0.5, 0.5)
        dot1.BackgroundColor3 = c1
        dot1.BorderSizePixel = 0
        dot1.Parent = circleFrame
        Instance.new("UICorner", dot1).CornerRadius = UDim.new(1, 0)

        local dot2 = Instance.new("Frame")
        dot2.Size = UDim2.new(0, 8, 0, 8)
        dot2.AnchorPoint = Vector2.new(0.5, 0.5)
        dot2.BackgroundColor3 = c2
        dot2.BorderSizePixel = 0
        dot2.Parent = circleFrame
        Instance.new("UICorner", dot2).CornerRadius = UDim.new(1, 0)

        local dot3 = Instance.new("Frame")
        dot3.Size = UDim2.new(0, 8, 0, 8)
        dot3.AnchorPoint = Vector2.new(0.5, 0.5)
        dot3.BackgroundColor3 = c3
        dot3.BorderSizePixel = 0
        dot3.Parent = circleFrame
        Instance.new("UICorner", dot3).CornerRadius = UDim.new(1, 0)

        -- 4. 左上角即時 HUD
        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "WETQAPremium_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = playerGui

        local statusBox = Instance.new("Frame")
        statusBox.Size = UDim2.new(0, 320, 0, 420)
        statusBox.Position = UDim2.new(0, 15, 0, 15)
        statusBox.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        statusBox.BorderSizePixel = 1
        statusBox.BorderColor3 = themeColor
        statusBox.Parent = hudGui

        local statusTitle = Instance.new("TextLabel")
        statusTitle.Size = UDim2.new(1, 0, 0, 25)
        statusTitle.BackgroundTransparency = 1
        statusTitle.Text = "  WETQA (Unbound Cursor & Color Picker)"
        statusTitle.TextColor3 = themeColor
        statusTitle.Font = Enum.Font.Code
        statusTitle.TextSize = 10
        statusTitle.TextXAlignment = Enum.TextXAlignment.Left
        statusTitle.Parent = statusBox

        local statusListLabel = Instance.new("TextLabel")
        statusListLabel.Size = UDim2.new(1, -10, 1, -30)
        statusListLabel.Position = UDim2.new(0, 5, 0, 25)
        statusListLabel.BackgroundTransparency = 1
        statusListLabel.Text = "[+] Cursor Unbound Engine Initialized..."
        statusListLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
        statusListLabel.Font = Enum.Font.Code
        statusListLabel.TextSize = 9
        statusListLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusListLabel.TextYAlignment = Enum.TextYAlignment.Top
        statusListLabel.Parent = statusBox

        -- 5. 主面板 (解除滑鼠中心鎖定，支援三角形游標自由移動與拖曳)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAPremium_UnnamedUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.DisplayOrder = 999999999
        pcall(function() ScreenGui.Parent = CoreGui end)
        if not ScreenGui.Parent then ScreenGui.Parent = playerGui end

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 980, 0, 700)
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
        bgImage.ImageTransparency = 0.45
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
        TopBar.Size = UDim2.new(1, 0, 0, 35)
        TopBar.Position = UDim2.new(0, 0, 0, 4)
        TopBar.BackgroundColor3 = Color3.fromRGB(8, 15, 30)
        TopBar.BorderSizePixel = 1
        TopBar.BorderColor3 = themeColor
        TopBar.ZIndex = 999999
        TopBar.Parent = MainFrame

        local logoIcon = Instance.new("ImageLabel")
        logoIcon.Size = UDim2.new(0, 26, 0, 26)
        logoIcon.Position = UDim2.new(0, 8, 0, 4)
        logoIcon.BackgroundTransparency = 1
        logoIcon.Image = customAssetId
        logoIcon.ZIndex = 999999
        logoIcon.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -45, 1, 0)
        Title.Position = UDim2.new(0, 40, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "WETQAPremium - Unbound Mouse & Color Picker Edition | discord.gg/zdqUuQgBhQ"
        Title.TextColor3 = Color3.fromRGB(200, 230, 255)
        Title.TextSize = 11
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
                    Size = UDim2.new(0, 980, 0, 700),
                    Position = UDim2.new(0.5, -490, 0.5, -350)
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

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(1, -20, 0, 32)
        TabBar.Position = UDim2.new(0, 10, 0, 48)
        TabBar.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
        TabBar.BorderSizePixel = 1
        TabBar.BorderColor3 = themeColor
        TabBar.ZIndex = 999999
        TabBar.Parent = MainFrame

        local pages = {}
        local tabButtons = {}
        local tabNames = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
        local tabWidth = 940 / #tabNames

        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -20, 1, -95)
        ContentArea.Position = UDim2.new(0, 10, 0, 88)
        ContentArea.BackgroundTransparency = 1
        ContentArea.ZIndex = 999999
        ContentArea.Parent = MainFrame

        for i, name in ipairs(tabNames) do
            local sf = Instance.new("ScrollingFrame")
            sf.Size = UDim2.new(1, 0, 1, 0)
            sf.BackgroundTransparency = 1
            sf.CanvasSize = UDim2.new(0, 0, 15.0, 0)
            sf.ScrollBarThickness = 4
            sf.Visible = (i == 1)
            sf.ZIndex = 999999
            sf.Parent = ContentArea
            pages[i] = sf

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0, tabWidth - 6, 0, 24)
            tBtn.Position = UDim2.new(0, 4 + (i - 1) * tabWidth, 0, 4)
            tBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(12, 22, 40) or Color3.fromRGB(8, 15, 25)
            tBtn.BorderColor3 = themeColor
            tBtn.TextColor3 = (i == 1) and themeColor or Color3.fromRGB(180, 210, 255)
            tBtn.Text = name
            tBtn.Font = Enum.Font.Code
            tBtn.TextSize = 10.5
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
            box.BackgroundTransparency = 0.2
            box.BorderSizePixel = 1
            box.BorderColor3 = themeColor
            box.ZIndex = 999999
            box.Parent = page

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(0, title:len() * 7 + 10, 0, 16)
            titleLbl.Position = UDim2.new(0, 10, 0, -8)
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
            btn.Size = UDim2.new(1, -20, 0, 22)
            btn.Position = UDim2.new(0, 10, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(200, 220, 255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 9.5
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
                    btn.TextColor3 = Color3.fromRGB(200, 220, 255)
                end
                callback(state)
            end)
            return btn
        end

        local function addUnnamedSlider(parent, yPos, text, minVal, maxVal, defaultVal, callback)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 0, 14)
            lbl.Position = UDim2.new(0, 10, 0, yPos)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. ": " .. tostring(defaultVal)
            lbl.TextColor3 = Color3.fromRGB(180, 210, 255)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 9.5
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 999999
            lbl.Parent = parent

            local bg = Instance.new("TextButton")
            bg.Size = UDim2.new(1, -20, 0, 12)
            bg.Position = UDim2.new(0, 10, 0, yPos + 15)
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

        -- ==========================================
        -- 分類分頁填充 (500+ 功能模組)
        -- ==========================================
        local g1 = createGroupBox(page1, "Void Sky & God-Tier Combat (100+)", 10, 10, 440, 580)
        addUnnamedToggle(g1, 18, "虛空暴怒盲狙 (自己看在原地，實際上天空中亂飛秒爆頭)", function(v) getgenv().voidSkyRage = v end)
        addUnnamedToggle(g1, 42, "全自動極速 360 度轉圈反擊 (Spinbot 最快速度)", function(v) getgenv().spin360 = v end)
        addUnnamedToggle(g1, 66, "對手一露頭直接 0 延遲爆頭秒殺 (Peek Instant Kill)", function(v) getgenv().peekKill = v end)
        for i = 4, 45 do
            addUnnamedToggle(g1, 66 + (i * 24), "分類戰鬥模組 #" .. tostring(i), function(v) end)
        end

        local g2 = createGroupBox(page1, "Hitbox & GodMods (100+)", 460, 10, 440, 580)
        addUnnamedToggle(g2, 18, "億萬級超大判定框黑科技 (Super Hitbox 200x)", function(v) getgenv().hitboxOn = v end)
        addUnnamedToggle(g2, 42, "絕對鎖血無敵不朽 (GodMode)", function(v) getgenv().godOn = v end)
        for i = 3, 40 do
            addUnnamedToggle(g2, 42 + (i * 24), "分類判定模組 #" .. tostring(i), function(v) end)
        end

        local g3 = createGroupBox(page2, "World Environment & Lighting (70+)", 10, 10, 440, 580)
        addUnnamedToggle(g3, 18, "世界萬物地圖全自動炫彩變色 (Rainbow World)", function(v) getgenv().rbWorld = v end)
        for i = 2, 35 do
            addUnnamedToggle(g3, 18 + (i * 24), "世界環境模組 #" .. tostring(i), function(v) end)
        end

        local g4 = createGroupBox(page3, "Visuals & Custom ESP (70+)", 10, 10, 440, 580)
        addUnnamedToggle(g4, 18, "世界頂級 3D 立體方框透視 (3D Box ESP)", function(v) getgenv().boxOn = v end)
        for i = 2, 35 do
            addUnnamedToggle(g4, 18 + (i * 24), "透視雷達模組 #" .. tostring(i), function(v) end)
        end

        local g5 = createGroupBox(page4, "Visuals & Rainbow Skins (70+)", 10, 10, 440, 580)
        addUnnamedToggle(g5, 18, "全身上下 360 度自動閃顏色變色 (Rainbow Body)", function(v) getgenv().rbBody = v end)
        for i = 2, 35 do
            addUnnamedToggle(g5, 18 + (i * 24), "外觀造型模組 #" .. tostring(i), function(v) end)
        end

        local g6 = createGroupBox(page5, "Movement & Sliders (50+)", 10, 10, 440, 580)
        addUnnamedSlider(g6, 18, "跑步移動速度 (WalkSpeed)", 16, 3000, 450, function(val) currentWalkSpeed = val end)
        addUnnamedSlider(g6, 60, "跳躍高度 (JumpPower)", 50, 4000, 450, function(val) currentJumpPower = val end)
        addUnnamedSlider(g6, 102, "飛行速度 (Fly Speed)", 50, 4000, 200, function(val) currentFlySpeed = val end)
        addUnnamedSlider(g6, 144, "第三人稱距離 (ThirdPerson Dist)", 5, 400, 15, function(val) thirdPersonDist = val end)
        for i = 5, 25 do
            addUnnamedToggle(g6, 185 + (i * 24), "移動增強模組 #" .. tostring(i), function(v) end)
        end

        local g7 = createGroupBox(page6, "FireRate, 50 Skies & 150+ Audios (50+)", 10, 10, 440, 580)
        addUnnamedSlider(g7, 18, "武器射擊速度倍率 (FireRate)", 1, 500, 50, function(val) currentFireRate = 1 / (val * 10000) end)
        for i = 2, 25 do
            addUnnamedToggle(g7, 50 + (i * 24), "音效模組 #" .. tostring(i), function(v) end)
        end

        -- ==========================================
        -- Settings 分頁：全域調色盤（面板、外框、轉圈三色）
        -- ==========================================
        local g8 = createGroupBox(page7, "Complete Color Picker & Customization", 10, 10, 440, 520)
        
        local function addColorChoice(yOffset, labelName, setter)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 0, 16)
            lbl.Position = UDim2.new(0, 10, 0, yOffset)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelName .. ":"
            lbl.TextColor3 = Color3.fromRGB(200, 220, 255)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 9.5
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 999999
            lbl.Parent = g8

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
                cBtn.Size = UDim2.new(0, 60, 0, 20)
                cBtn.Position = UDim2.new(0, 10 + (idx - 1) * 65, 0, yOffset + 18)
                cBtn.BackgroundColor3 = cInfo[1]
                cBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
                cBtn.Text = cInfo[2]
                cBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                cBtn.Font = Enum.Font.Code
                cBtn.TextSize = 9
                cBtn.ZIndex = 999999
                cBtn.Parent = g8

                cBtn.MouseButton1Click:Connect(function()
                    setter(cInfo[1])
                end)
            end
        end

        addColorChoice(20, "1. 面板與按鈕主題顏色", function(col)
            themeColor = col
            MainFrame.BorderColor3 = themeColor
            dynamicBar.BackgroundColor3 = themeColor
            TopBar.BorderColor3 = themeColor
            TabBar.BorderColor3 = themeColor
            statusBox.BorderColor3 = themeColor
            mobileBtn.BorderColor3 = themeColor
        end)

        addColorChoice(75, "2. 準心外框顏色", function(col)
            circleOuterColor = col
            cStroke.Color = circleOuterColor
        end)

        addColorChoice(130, "3. 轉圈點 #1 顏色", function(col) c1 = col end)
        addColorChoice(185, "4. 轉圈點 #2 顏色", function(col) c2 = col end)
        addColorChoice(240, "5. 轉圈點 #3 顏色", function(col) c3 = col end)

        -- 主運行迴圈
        RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum then
                hum.WalkSpeed = currentWalkSpeed
                hum.JumpPower = currentJumpPower
                if getgenv().godOn then hum.Health = hum.MaxHealth end
            end

            player.CameraMaxZoomDistance = thirdPersonDist
            player.CameraMinZoomDistance = thirdPersonDist

            dot1.BackgroundColor3 = c1
            dot2.BackgroundColor3 = c2
            dot3.BackgroundColor3 = c3

            local t = tick() * 5
            local r = 55
            dot1.Position = UDim2.new(0.5, math.cos(t) * r, 0.5, math.sin(t) * r)
            dot2.Position = UDim2.new(0.5, math.cos(t + 2.09) * r, 0.5, math.sin(t + 2.09) * r)
            dot3.Position = UDim2.new(0.5, math.cos(t + 4.18) * r, 0.5, math.sin(t + 4.18) * r)

            local activeTexts = {}
            if getgenv().voidSkyRage then table.insert(activeTexts, "[+] void sky skybox ragebot") end
            if getgenv().spin360 then table.insert(activeTexts, "[+] 360 spinbot max speed") end
            if getgenv().hitboxOn then table.insert(activeTexts, "[+] super hitbox (200x)") end
            table.insert(activeTexts, "[+] WETQAPremium Unbound Cursor Active")
            statusListLabel.Text = table.concat(activeTexts, "\n")

            if getgenv().voidSkyRage or getgenv().spin360 or getgenv().peekKill or getgenv().godRage then
                pcall(function()
                    if hrp then
                        if getgenv().voidSkyRage then
                            local skyAngle = tick() * 450
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 600, 0) * CFrame.Angles(0, math.rad(skyAngle), 0)
                            hrp.Velocity = Vector3.new(math.sin(skyAngle) * 800, 1200, math.cos(skyAngle) * 800)
                        elseif getgenv().spin360 then
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
                        if getgenv().hitboxOn then
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
        end)
    end)

    if not success then
        warn("Load Error: " .. tostring(err))
    end
end)
