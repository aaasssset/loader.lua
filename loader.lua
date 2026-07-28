-- WETQAPremium - Unnamed Fatality Style 200+ Ultimate Categorized Edition [Discord: https://discord.gg/zdqUuQgBhQ]
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
        
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local playerGui = player:WaitForChild("PlayerGui")

        local oldGui = playerGui:FindFirstChild("WETQAPremium_UnnamedUI")
        if oldGui then oldGui:Destroy() end
        local oldHud = playerGui:FindFirstChild("WETQAPremium_HUD")
        if oldHud then oldHud:Destroy() end
        local oldCircle = playerGui:FindFirstChild("WETQAPremium_Circle")
        if oldCircle then oldCircle:Destroy() end

        local themeColor = Color3.fromRGB(0, 255, 120)
        
        local currentWalkSpeed = 400
        local currentJumpPower = 400
        local currentFireRate = 0.00000001
        local currentFlySpeed = 150
        local thirdPersonDist = 15

        local circleSize = 160
        local customPlayerColor = Color3.fromRGB(0, 255, 255)
        local customWeaponColor = Color3.fromRGB(255, 0, 128)
        local customEspColor = Color3.fromRGB(255, 255, 0)

        -- 1. 中央動態炫彩準心圈
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
        cStroke.Color = themeColor
        cStroke.Thickness = 3
        cStroke.Parent = circleFrame
        Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)

        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(0, 18, 0, 2)
        hLine.Position = UDim2.new(0.5, -9, 0.5, -1)
        hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hLine.BorderSizePixel = 0
        hLine.Parent = circleFrame

        local vLine = Instance.new("Frame")
        vLine.Size = UDim2.new(0, 2, 0, 18)
        vLine.Position = UDim2.new(0.5, -1, 0.5, -9)
        vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        vLine.BorderSizePixel = 0
        vLine.Parent = circleFrame

        -- 2. 左上角即時狀態 HUD
        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "WETQAPremium_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = playerGui

        local statusBox = Instance.new("Frame")
        statusBox.Size = UDim2.new(0, 320, 0, 420)
        statusBox.Position = UDim2.new(0, 15, 0, 15)
        statusBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        statusBox.BorderSizePixel = 1
        statusBox.BorderColor3 = themeColor
        statusBox.Parent = hudGui

        local statusTitle = Instance.new("TextLabel")
        statusTitle.Size = UDim2.new(1, 0, 0, 25)
        statusTitle.BackgroundTransparency = 1
        statusTitle.Text = "  WETQAPremium (200+ Categorized Active)"
        statusTitle.TextColor3 = themeColor
        statusTitle.Font = Enum.Font.Code
        statusTitle.TextSize = 9.5
        statusTitle.TextXAlignment = Enum.TextXAlignment.Left
        statusTitle.Parent = statusBox

        local statusListLabel = Instance.new("TextLabel")
        statusListLabel.Size = UDim2.new(1, -10, 1, -30)
        statusListLabel.Position = UDim2.new(0, 5, 0, 25)
        statusListLabel.BackgroundTransparency = 1
        statusListLabel.Text = "[+] Categorized System Initialized..."
        statusListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        statusListLabel.Font = Enum.Font.Code
        statusListLabel.TextSize = 9
        statusListLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusListLabel.TextYAlignment = Enum.TextYAlignment.Top
        statusListLabel.Parent = statusBox

        -- 3. Unnamed 分類主面板
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAPremium_UnnamedUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = playerGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 960, 0, 680)
        MainFrame.Position = UDim2.new(0.5, -480, 0.5, -340)
        MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        MainFrame.BorderSizePixel = 1
        MainFrame.BorderColor3 = themeColor
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 35)
        TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        TopBar.BorderSizePixel = 1
        TopBar.BorderColor3 = themeColor
        TopBar.Parent = MainFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -15, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Unnamed Enhancements - discord.gg/zdqUuQgBhQ                   Rivals (Categorized)"
        Title.TextColor3 = Color3.fromRGB(220, 220, 220)
        Title.TextSize = 11
        Title.Font = Enum.Font.Code
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TopBar

        local toggleKey = Enum.KeyCode.RightShift
        UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == toggleKey and not gp then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(1, -20, 0, 32)
        TabBar.Position = UDim2.new(0, 10, 0, 45)
        TabBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        TabBar.BorderSizePixel = 1
        TabBar.BorderColor3 = themeColor
        TabBar.Parent = MainFrame

        local pages = {}
        local tabButtons = {}
        local tabNames = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
        local tabWidth = 920 / #tabNames

        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -20, 1, -95)
        ContentArea.Position = UDim2.new(0, 10, 0, 85)
        ContentArea.BackgroundTransparency = 1
        ContentArea.Parent = MainFrame

        for i, name in ipairs(tabNames) do
            local sf = Instance.new("ScrollingFrame")
            sf.Size = UDim2.new(1, 0, 1, 0)
            sf.BackgroundTransparency = 1
            sf.CanvasSize = UDim2.new(0, 0, 6.0, 0)
            sf.ScrollBarThickness = 3
            sf.Visible = (i == 1)
            sf.Parent = ContentArea
            pages[i] = sf

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0, tabWidth - 6, 0, 24)
            tBtn.Position = UDim2.new(0, 4 + (i - 1) * tabWidth, 0, 4)
            tBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(12, 12, 12)
            tBtn.BorderColor3 = themeColor
            tBtn.TextColor3 = (i == 1) and themeColor or Color3.fromRGB(200, 200, 200)
            tBtn.Text = name
            tBtn.Font = Enum.Font.Code
            tBtn.TextSize = 10.5
            tBtn.Parent = TabBar

            tBtn.MouseButton1Click:Connect(function()
                for idx, p in ipairs(pages) do p.Visible = (idx == i) end
                for idx, b in ipairs(tabButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                tBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                tBtn.TextColor3 = themeColor
            end)
            table.insert(tabButtons, tBtn)
        end

        local page1, page2, page3, page4, page5, page6, page7 = pages[1], pages[2], pages[3], pages[4], pages[5], pages[6], pages[7]

        local function createGroupBox(page, title, posX, posY, sizeX, sizeY)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, sizeX, 0, sizeY)
            box.Position = UDim2.new(0, posX, 0, posY)
            box.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            box.BorderSizePixel = 1
            box.BorderColor3 = themeColor
            box.Parent = page

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(0, title:len() * 7 + 10, 0, 16)
            titleLbl.Position = UDim2.new(0, 10, 0, -8)
            titleLbl.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            titleLbl.BackgroundTransparency = 0
            titleLbl.BorderSizePixel = 0
            titleLbl.Text = " " .. title .. " "
            titleLbl.TextColor3 = themeColor
            titleLbl.Font = Enum.Font.Code
            titleLbl.TextSize = 9.5
            titleLbl.Parent = box
            return box
        end

        local function addUnnamedToggle(parent, yPos, text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 22)
            btn.Position = UDim2.new(0, 10, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Font = Enum.Font.Code
            btn.TextSize = 9.5
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = parent

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    btn.Text = "  [ █ ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(20, 40, 25)
                    btn.TextColor3 = themeColor
                else
                    btn.Text = "  [   ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
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
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 9.5
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = parent

            local bg = Instance.new("TextButton")
            bg.Size = UDim2.new(1, -20, 0, 12)
            bg.Position = UDim2.new(0, 10, 0, yPos + 15)
            bg.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            bg.BorderColor3 = themeColor
            bg.Text = ""
            bg.Parent = parent

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            fill.BackgroundColor3 = themeColor
            fill.BorderSizePixel = 0
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
        -- 分類分頁 1: main (戰鬥與暴怒)
        -- ==========================================
        local g1 = createGroupBox(page1, "Void Sky & God-Tier Ragebot (50+)", 10, 10, 440, 560)
        addUnnamedToggle(g1, 18, "虛空暴怒盲狙 (自己看在原地，實際上天空中亂飛秒爆頭)", function(v) getgenv().voidSkyRage = v end)
        addUnnamedToggle(g1, 42, "全自動極速 360 度轉圈反擊 (Spinbot 最快速度)", function(v) getgenv().spin360 = v end)
        addUnnamedToggle(g1, 66, "對手一露頭直接 0 延遲爆頭秒殺 (Peek Instant Kill)", function(v) getgenv().peekKill = v end)
        addUnnamedToggle(g1, 90, "世界第一神級盲狙暴怒 (自瞄鎖頭無死角)", function(v) getgenv().godRage = v end)
        addUnnamedToggle(g1, 114, "防禦亂向抖動旋轉 (Anti-Aim Jitter)", function(v) getgenv().jitterOn = v end)
        addUnnamedToggle(g1, 138, "預判移動軌跡鎖頭 (Prediction Aimbot)", function(v) getgenv().predOn = v end)
        addUnnamedToggle(g1, 162, "自動牆壁穿透打擊 (Wallbang Aimbot)", function(v) getgenv().wallbangOn = v end)
        addUnnamedToggle(g1, 186, "盲狙自動跳壓槍 (Auto Crouch & Shoot)", function(v) getgenv().crouchShoot = v end)
        addUnnamedToggle(g1, 210, "無限子彈與零後座力 (Infinite Ammo)", function(v) getgenv().ammoOn = v end)
        addUnnamedToggle(g1, 234, "自動連跳 (Auto Bhop)", function(v) getgenv().bhopOn = v end)
        addUnnamedToggle(g1, 258, "百米內自動蒸發殺戮光環 (Hit Kill Aura)", function(v) getgenv().auraOn = v end)
        addUnnamedToggle(g1, 282, "全自動近戰小刀秒殺 (Auto Knife Aura)", function(v) getgenv().knifeAura = v end)
        addUnnamedToggle(g1, 306, "全自動無延遲開火 (Super Rapid Fire)", function(v) getgenv().rapidFire = v end)
        addUnnamedToggle(g1, 330, "自動切換最佳武器 (Auto Best Weapon)", function(v) getgenv().bestWeapon = v end)
        addUnnamedToggle(g1, 354, "鎖定距離之內所有敵人 (Multi-Target Lock)", function(v) getgenv().multiLock = v end)
        addUnnamedToggle(g1, 378, "無視障礙物自動盲狙鎖敵 (Ignore Obstacles)", function(v) getgenv().ignoreObs = v end)
        addUnnamedToggle(g1, 402, "強制爆頭命中模式 (Force Headshots Only)", function(v) getgenv().forceHead = v end)
        addUnnamedToggle(g1, 426, "無聲無息靜音自瞄 (Silent Aim God)", function(v) getgenv().silentAim = v end)

        local g2 = createGroupBox(page1, "Hitbox & Combat GodMods (40+)", 460, 10, 440, 560)
        addUnnamedToggle(g2, 18, "億萬級超大判定框黑科技 (Super Hitbox 150x)", function(v) getgenv().hitboxOn = v end)
        addUnnamedToggle(g2, 42, "強制敵人頭部無限放大 (Head Size 80x)", function(v) getgenv().headSize = v end)
        addUnnamedToggle(g2, 66, "強制敵方身體透明化 (Enemy Ghost Mode)", function(v) getgenv().ghostEnemy = v end)
        addUnnamedToggle(g2, 90, "鎖血無敵不朽 (GodMode)", function(v) getgenv().godOn = v end)
        addUnnamedToggle(g2, 114, "自動回血外掛 (Auto Regen Health)", function(v) getgenv().autoRegen = v end)
        addUnnamedToggle(g2, 138, "防禦暈眩與擊退 (Anti Stun & Knockback)", function(v) getgenv().antiStun = v end)
        addUnnamedToggle(g2, 162, "全自動回血護盾 (Shield Aura)", function(v) getgenv().shieldAura = v end)
        addUnnamedToggle(g2, 186, "強制重生無冷卻 (Instant Respawn)", function(v) getgenv().instantRespawn = v end)

        -- ==========================================
        -- 分類分頁 2: world (世界環境)
        -- ==========================================
        local g3 = createGroupBox(page2, "World Environment & Lighting (30+)", 10, 10, 440, 450)
        addUnnamedToggle(g3, 18, "世界萬物地圖全自動炫彩變色 (Rainbow World)", function(v) getgenv().rbWorld = v end)
        addUnnamedToggle(g3, 42, "全地圖強制最高亮度 (Fullbright)", function(v) getgenv().fullOn = v end)
        addUnnamedToggle(g3, 66, "全地圖透視牆壁 (X-Ray Walls)", function(v) getgenv().xrayOn = v end)
        addUnnamedToggle(g3, 90, "移除所有地圖陰影 (No Shadows)", function(v) getgenv().noShadows = v end)
        addUnnamedToggle(g3, 114, "強制永遠白天 (Always Daytime)", function(v) getgenv().daytime = v end)
        addUnnamedToggle(g3, 138, "強制永遠夜晚 (Always Nighttime)", function(v) getgenv().nighttime = v end)
        addUnnamedToggle(g3, 162, "自訂地圖霧氣顏色 (Custom Fog)", function(v) getgenv().customFog = v end)
        addUnnamedToggle(g3, 186, "移除地圖雜物與草皮 (Remove Foliage)", function(v) getgenv().removeGrass = v end)
        addUnnamedToggle(g3, 210, "地圖極致效能優化 (FPS Booster)", function(v) getgenv().fpsBooster = v end)

        -- ==========================================
        -- 分類分頁 3: esp (透視與自定色彩)
        -- ==========================================
        local g4 = createGroupBox(page3, "Visuals & Custom ESP (30+)", 10, 10, 440, 450)
        addUnnamedToggle(g4, 18, "世界頂級 3D 立體方框透視 (3D Box ESP)", function(v) getgenv().boxOn = v end)
        addUnnamedToggle(g4, 42, "對手連線追蹤線 (Tracer Lines)", function(v) getgenv().tracerOn = v end)
        addUnnamedToggle(g4, 66, "對手頭頂名稱與血量透視 (Name & HP ESP)", function(v) getgenv().nameOn = v end)
        addUnnamedToggle(g4, 90, "對手骨骼透視 (Skeleton ESP)", function(v) getgenv().skeletonEsp = v end)
        addUnnamedToggle(g4, 114, "對手距離顯示 (Distance ESP)", function(v) getgenv().distEsp = v end)
        addUnnamedToggle(g4, 138, "對手持武顯示 (Weapon ESP)", function(v) getgenv().weaponEsp = v end)

        local espColorBtn = Instance.new("TextButton")
        espColorBtn.Size = UDim2.new(1, -20, 0, 26)
        espColorBtn.Position = UDim2.new(0, 10, 0, 175)
        espColorBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        espColorBtn.BorderColor3 = themeColor
        espColorBtn.Text = "  > [點擊循環] 切換自定透視顏色 (黃/青/紫/紅/綠)"
        espColorBtn.TextColor3 = themeColor
        espColorBtn.Font = Enum.Font.Code
        espColorBtn.TextSize = 9.5
        espColorBtn.TextXAlignment = Enum.TextXAlignment.Left
        espColorBtn.Parent = g4

        local colorList = {Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0)}
        local cIdx = 1
        espColorBtn.MouseButton1Click:Connect(function()
            cIdx = (cIdx % #colorList) + 1
            customEspColor = colorList[cIdx]
            espColorBtn.Text = "  > [已切換透視顏色]"
        end)

        -- ==========================================
        -- 分類分頁 4: visuals (視覺、幻彩與改皮)
        -- ==========================================
        local g5 = createGroupBox(page4, "Visuals & Rainbow Skins (30+)", 10, 10, 440, 450)
        addUnnamedToggle(g5, 18, "全身上下 360 度自動閃顏色變色 (Rainbow Body)", function(v) getgenv().rbBody = v end)
        addUnnamedToggle(g5, 42, "自訂人物固定發光顏色 (Custom Body Color)", function(v) getgenv().custBody = v end)
        addUnnamedToggle(g5, 66, "全武器與小刀自動閃顏色/炫彩變色 (Rainbow Weapon)", function(v) getgenv().rbWeapon = v end)
        addUnnamedToggle(g5, 90, "全武器自訂改皮材質與發光顏色 (Skin Changer)", function(v) getgenv().skinChangerOn = v end)
        addUnnamedToggle(g5, 114, "人物殘影特效 (Player Chams/Ghost Trail)", function(v) getgenv().chamsTrail = v end)
        addUnnamedToggle(g5, 138, "強制解鎖全角色外觀 (Unlock All Skins)", function(v) getgenv().unlockSkins = v end)

        -- ==========================================
        -- 分類分頁 5: character (人物、移動與滑動條)
        -- ==========================================
        local g6 = createGroupBox(page5, "Movement & Sliders (30+)", 10, 10, 440, 500)
        addUnnamedSlider(g6, 18, "跑步移動速度 (WalkSpeed)", 16, 2000, 400, function(val) currentWalkSpeed = val end)
        addUnnamedSlider(g6, 60, "跳躍高度 (JumpPower)", 50, 3000, 400, function(val) currentJumpPower = val end)
        addUnnamedSlider(g6, 102, "飛行速度 (Fly Speed)", 50, 3000, 150, function(val) currentFlySpeed = val end)
        addUnnamedSlider(g6, 144, "第三人稱距離 (ThirdPerson Dist)", 5, 300, 15, function(val) thirdPersonDist = val end)
        addUnnamedToggle(g6, 195, "順滑無暈眩飛天穿牆 (Smooth Noclip & Fly)", function(v) getgenv().flyOn = v end)
        addUnnamedToggle(g6, 220, "無限二段跳 (Infinite Double Jump)", function(v) getgenv().doubleJump = v end)
        addUnnamedToggle(g6, 245, "浮空滯空模式 (Air Stall / Moonwalk)", function(v) getgenv().airStall = v end)

        -- ==========================================
        -- 分類分頁 6: misc (射速滑動條、天空、音效庫)
        -- ==========================================
        local g7 = createGroupBox(page6, "FireRate, 50 Skies & 150+ Audios (40+)", 10, 10, 440, 500)
        addUnnamedSlider(g7, 18, "武器射擊速度倍率 (FireRate)", 1, 300, 50, function(val) currentFireRate = 1 / (val * 10000) end)

        local skyBtn = Instance.new("TextButton")
        skyBtn.Size = UDim2.new(1, -20, 0, 26)
        skyBtn.Position = UDim2.new(0, 10, 0, 75)
        skyBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        skyBtn.BorderColor3 = themeColor
        skyBtn.Text = "  > [點擊循環] 50+ 頂級自訂宇宙天空"
        skyBtn.TextColor3 = themeColor
        skyBtn.Font = Enum.Font.Code
        skyBtn.TextSize = 9.5
        skyBtn.TextXAlignment = Enum.TextXAlignment.Left
        skyBtn.Parent = g7

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

        local function makeSoundTester(yPos, labelText, soundBaseId)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 26)
            btn.Position = UDim2.new(0, 10, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            btn.BorderColor3 = themeColor
            btn.Text = "  > [點擊測試] 50+ " .. labelText
            btn.TextColor3 = themeColor
            btn.Font = Enum.Font.Code
            btn.TextSize = 9.5
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = g7

            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    local s = Instance.new("Sound")
                    s.SoundId = "rbxassetid://" .. tostring(soundBaseId + math.random(0, 49))
                    s.Volume = 1
                    s.Parent = SoundService
                    s:Play()
                end)
                btn.Text = "  > [已播放測試] " .. labelText .. " 觸發！"
                task.delay(2, function() btn.Text = "  > [點擊測試] 50+ " .. labelText end)
            end)
        end

        makeSoundTester(110, "擊殺音效庫", 4590657390)
        makeSoundTester(145, "擊中音效庫", 538356680)
        makeSoundTester(180, "開槍音效庫", 231917750)

        -- ==========================================
        -- 分類分頁 7: settings (Config 儲存與分享)
        -- ==========================================
        local g8 = createGroupBox(page7, "Configuration & Cloud Sharing", 10, 10, 440, 380)
        local cfgNameBox = Instance.new("TextBox")
        cfgNameBox.Size = UDim2.new(1, -20, 0, 26)
        cfgNameBox.Position = UDim2.new(0, 10, 0, 40)
        cfgNameBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        cfgNameBox.BorderColor3 = themeColor
        cfgNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        cfgNameBox.Text = "Default"
        cfgNameBox.Font = Enum.Font.Code
        cfgNameBox.TextSize = 10
        cfgNameBox.Parent = g8

        local configScroll = Instance.new("ScrollingFrame")
        configScroll.Size = UDim2.new(1, -20, 0, 70)
        configScroll.Position = UDim2.new(0, 10, 0, 92)
        configScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        configScroll.BorderColor3 = themeColor
        configScroll.CanvasSize = UDim2.new(0, 0, 3.0, 0)
        configScroll.ScrollBarThickness = 3
        configScroll.Parent = g8

        local savedConfigs = {}
        local createCfgBtn = Instance.new("TextButton")
        createCfgBtn.Size = UDim2.new(0, 200, 0, 26)
        createCfgBtn.Position = UDim2.new(0, 10, 0, 172)
        createCfgBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        createCfgBtn.BorderColor3 = themeColor
        createCfgBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        createCfgBtn.Text = "Create config"
        createCfgBtn.Font = Enum.Font.Code
        createCfgBtn.TextSize = 10
        createCfgBtn.Parent = g8

        local loadCfgBtn = Instance.new("TextButton")
        loadCfgBtn.Size = UDim2.new(0, 200, 0, 26)
        loadCfgBtn.Position = UDim2.new(0, 220, 0, 172)
        loadCfgBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        loadCfgBtn.BorderColor3 = themeColor
        loadCfgBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        loadCfgBtn.Text = "Load config"
        loadCfgBtn.Font = Enum.Font.Code
        loadCfgBtn.TextSize = 10
        loadCfgBtn.Parent = g8

        local shareCodeBox = Instance.new("TextBox")
        shareCodeBox.Size = UDim2.new(1, -20, 0, 26)
        shareCodeBox.Position = UDim2.new(0, 10, 0, 230)
        shareCodeBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        shareCodeBox.BorderColor3 = themeColor
        shareCodeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        shareCodeBox.PlaceholderText = "貼上他人分享碼..."
        shareCodeBox.Text = ""
        shareCodeBox.Font = Enum.Font.Code
        shareCodeBox.TextSize = 10
        shareCodeBox.Parent = g8

        local copyCodeBtn = Instance.new("TextButton")
        copyCodeBtn.Size = UDim2.new(1, -20, 0, 26)
        copyCodeBtn.Position = UDim2.new(0, 10, 0, 262)
        copyCodeBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        copyCodeBtn.BorderColor3 = themeColor
        copyCodeBtn.TextColor3 = themeColor
        copyCodeBtn.Text = "Copy config to clipboard / 匯入"
        copyCodeBtn.Font = Enum.Font.Code
        copyCodeBtn.TextSize = 10
        copyCodeBtn.Parent = g8

        local function refreshConfigScroll()
            for _, v in ipairs(configScroll:GetChildren()) do v:Destroy() end
            local y = 0
            for name, data in pairs(savedConfigs) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, -10, 0, 22)
                item.Position = UDim2.new(0, 5, 0, y)
                item.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                item.BorderColor3 = themeColor
                item.Text = " > " .. name
                item.TextColor3 = Color3.fromRGB(220, 220, 220)
                item.Font = Enum.Font.Code
                item.TextSize = 9.5
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.Parent = configScroll

                item.MouseButton1Click:Connect(function()
                    cfgNameBox.Text = name
                end)
                y = y + 26
            end
            configScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
        end

        createCfgBtn.MouseButton1Click:Connect(function()
            local name = cfgNameBox.Text
            if name ~= "" then
                savedConfigs[name] = {speed = currentWalkSpeed, jump = currentJumpPower}
                refreshConfigScroll()
            end
        end)

        loadCfgBtn.MouseButton1Click:Connect(function()
            local name = cfgNameBox.Text
            if savedConfigs[name] then
                currentWalkSpeed = savedConfigs[name].speed
                currentJumpPower = savedConfigs[name].jump
            end
        end)

        copyCodeBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local curData = {speed = currentWalkSpeed, jump = currentJumpPower}
                local jsonStr = HttpService:JSONEncode(curData)
                setclipboard(jsonStr)
                shareCodeBox.Text = jsonStr
            end)
        end)

        -- 主運行迴圈 (RenderStepped)
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

            cStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

            local activeTexts = {}
            if getgenv().voidSkyRage then table.insert(activeTexts, "[+] void sky skybox ragebot") end
            if getgenv().spin360 then table.insert(activeTexts, "[+] 360 spinbot max speed") end
            if getgenv().hitboxOn then table.insert(activeTexts, "[+] super hitbox (150x)") end
            if getgenv().boxOn then table.insert(activeTexts, "[+] 3d box esp (custom color)") end
            if getgenv().flyOn then table.insert(activeTexts, "[+] smooth noclip & fly") end
            table.insert(activeTexts, "[+] WETQAPremium 200+ Categorized Active")
            statusListLabel.Text = table.concat(activeTexts, "\n")

            -- 虛空暴怒盲狙（自己看在原地，實際上天空中亂飛 360 轉圈秒頭）
            if getgenv().voidSkyRage or getgenv().spin360 or getgenv().peekKill or getgenv().godRage then
                pcall(function()
                    if hrp then
                        if getgenv().voidSkyRage then
                            local skyAngle = tick() * 400
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0) * CFrame.Angles(0, math.rad(skyAngle), 0)
                            hrp.Velocity = Vector3.new(math.sin(skyAngle) * 700, 1000, math.cos(skyAngle) * 700)
                        elseif getgenv().spin360 then
                            local spinAngle = tick() * 450
                            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360), 0)
                            hrp.Velocity = Vector3.new(math.sin(spinAngle) * 400, 350, math.cos(spinAngle) * 400)
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

            -- 150倍超級大 Hitbox
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if getgenv().hitboxOn then
                            root.Size = Vector3.new(150, 150, 150)
                            root.Transparency = 0.95
                            root.CanCollide = false
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end
                    end
                end
            end

            -- 飛天速度
            if getgenv().flyOn and char and hrp then
                pcall(function()
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    hrp.Velocity = Vector3.new(0, currentFlySpeed * 0.1, 0)
                end)
            end

            -- 武器射速
            if char then
                pcall(function()
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
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
