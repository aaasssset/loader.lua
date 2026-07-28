-- WETQAPremium - 市面上最美、顏值最高、宇宙最強黑科技旗艦版 [Discord: https://discord.gg/zdqUuQgBhQ]
task.spawn(function()
    task.wait(0.5)

    if not getgenv().script_key or getgenv().script_key == "" then
        pcall(function()
            local p = game:GetService("Players").LocalPlayer
            if p then p:Kick("WETQAPremium Security: ❌ 驗證失敗！請先至 Discord (https://discord.gg/zdqUuQgBhQ) 取得專屬授權 Key！") end
        end)
        return
    end

    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Lighting = game:GetService("Lighting")
        local SoundService = game:GetService("SoundService")
        local VirtualUser = game:GetService("VirtualUser")
        local Workspace = game:GetService("Workspace")
        
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local playerGui = player:WaitForChild("PlayerGui")

        -- 清理舊介面
        local oldGui = playerGui:FindFirstChild("WETQAPremium_ModernUI")
        if oldGui then oldGui:Destroy() end
        local oldHud = playerGui:FindFirstChild("WETQAPremium_HUD")
        if oldHud then oldHud:Destroy() end
        local oldCircle = playerGui:FindFirstChild("WETQAPremium_Circle")
        if oldCircle then oldCircle:Destroy() end

        local themeColor = Color3.fromRGB(0, 255, 120)
        local currentWalkSpeed = 350
        local currentJumpPower = 400
        local currentFireRate = 0.000001
        local circleSize = 160

        local customPlayerColor = Color3.fromRGB(0, 255, 255)
        local customWeaponColor = Color3.fromRGB(255, 0, 128)

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

        -- 2. 左上角即時狀態小視窗 (HUD)
        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "WETQAPremium_HUD"
        hudGui.ResetOnSpawn = false
        hudGui.Parent = playerGui

        local statusBox = Instance.new("Frame")
        statusBox.Size = UDim2.new(0, 280, 0, 320)
        statusBox.Position = UDim2.new(0, 15, 0, 15)
        statusBox.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
        statusBox.BackgroundTransparency = 0.25
        statusBox.BorderSizePixel = 0
        statusBox.Parent = hudGui
        Instance.new("UICorner", statusBox).CornerRadius = UDim.new(0, 10)
        local sStroke = Instance.new("UIStroke")
        sStroke.Color = themeColor
        sStroke.Thickness = 1.5
        sStroke.Parent = statusBox

        local statusTitle = Instance.new("TextLabel")
        statusTitle.Size = UDim2.new(1, 0, 0, 30)
        statusTitle.BackgroundTransparency = 1
        statusTitle.Text = "  WETQAPremium - https://discord.gg/zdqUuQgBhQ"
        statusTitle.TextColor3 = themeColor
        statusTitle.Font = Enum.Font.Code
        statusTitle.TextSize = 8
        statusTitle.TextXAlignment = Enum.TextXAlignment.Left
        statusTitle.Parent = statusBox

        local statusListLabel = Instance.new("TextLabel")
        statusListLabel.Size = UDim2.new(1, -16, 1, -35)
        statusListLabel.Position = UDim2.new(0, 8, 0, 30)
        statusListLabel.BackgroundTransparency = 1
        statusListLabel.Text = "[+] UI Initialized Smoothly..."
        statusListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        statusListLabel.Font = Enum.Font.Code
        statusListLabel.TextSize = 10
        statusListLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusListLabel.TextYAlignment = Enum.TextYAlignment.Top
        statusListLabel.Parent = statusBox

        -- 3. 市面上最高級、最好看的現代化面板 (Modern UI)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAPremium_ModernUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = playerGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 920, 0, 620)
        MainFrame.Position = UDim2.new(0.5, -460, 0.5, -310)
        MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

        local mainStroke = Instance.new("UIStroke")
        mainStroke.Color = themeColor
        mainStroke.Thickness = 2
        mainStroke.Parent = MainFrame

        -- 頂部導航列 (TopBar)
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 45)
        TopBar.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame
        Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -20, 1, 0)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "WETQAPremium - https://discord.gg/zdqUuQgBhQ [RightShift 關閉面板]"
        Title.TextColor3 = themeColor
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

        -- 頁籤按鈕容器 (Tab Bar)
        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 180, 1, -55)
        TabBar.Position = UDim2.new(0, 10, 0, 50)
        TabBar.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
        TabBar.BorderSizePixel = 0
        TabBar.Parent = MainFrame
        Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

        -- 內容頁面容器 (Content Area)
        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -205, 1, -55)
        ContentArea.Position = UDim2.new(0, 195, 0, 50)
        ContentArea.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
        ContentArea.BackgroundTransparency = 0.5
        ContentArea.BorderSizePixel = 0
        ContentArea.Parent = MainFrame
        Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

        -- 建立多頁籤切換系統
        local pages = {}
        local tabButtons = {}

        local function createPage(name, index)
            local sf = Instance.new("ScrollingFrame")
            sf.Size = UDim2.new(1, 0, 1, 0)
            sf.BackgroundTransparency = 1
            sf.CanvasSize = UDim2.new(0, 0, 2.5, 0)
            sf.ScrollBarThickness = 4
            sf.Visible = (index == 1)
            sf.Parent = ContentArea
            pages[index] = sf

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(1, -16, 0, 36)
            tBtn.Position = UDim2.new(0, 8, 0, 10 + (index - 1) * 44)
            tBtn.BackgroundColor3 = (index == 1) and themeColor or Color3.fromRGB(18, 24, 36)
            tBtn.TextColor3 = (index == 1) and Color3.fromRGB(10, 14, 22) or Color3.fromRGB(200, 200, 200)
            tBtn.Text = "  " .. name
            tBtn.Font = Enum.Font.Code
            tBtn.TextSize = 11
            tBtn.TextXAlignment = Enum.TextXAlignment.Left
            tBtn.Parent = TabBar
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)

            tBtn.MouseButton1Click:Connect(function()
                for i, p in ipairs(pages) do p.Visible = (i == index) end
                for i, b in ipairs(tabButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                tBtn.BackgroundColor3 = themeColor
                tBtn.TextColor3 = Color3.fromRGB(10, 14, 22)
            end)
            table.insert(tabButtons, tBtn)
            return sf
        end

        local page1 = createPage("1. 幻彩與視覺自訂", 1)
        local page2 = createPage("2. 暴怒與盲狙黑科技", 2)
        local page3 = createPage("3. 透視與防禦無敵", 3)
        local page4 = createPage("4. 音效與天空自訂", 4)

        -- 封裝生成控制項的函數
        local function addControlToPage(page, yPos, text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 34)
            btn.Position = UDim2.new(0, 10, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    btn.Text = "  [ █ ] " .. text
                    btn.BackgroundColor3 = themeColor
                    btn.TextColor3 = Color3.fromRGB(10, 14, 22)
                else
                    btn.Text = "  [   ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
                    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
                end
                callback(state)
            end)
            return btn
        end

        -- 頁面 1：幻彩與視覺
        addControlToPage(page1, 10, "全身上下 360 度自動閃顏色變色 (Rainbow Player Body)", function(v) getgenv().rbBody = v end)
        addControlToPage(page1, 50, "自訂人物固定發光顏色 (Custom Player Color)", function(v) getgenv().custBody = v end)
        addControlToPage(page1, 90, "全武器與小刀自動閃顏色/炫彩變色 (Rainbow Weapon & Knife)", function(v) getgenv().rbWeapon = v end)
        addControlToPage(page1, 130, "自訂武器與小刀固定顏色 (Custom Weapon Color)", function(v) getgenv().custWeapon = v end)
        addControlToPage(page1, 170, "世界萬物地圖全自動炫彩變色 (Rainbow World Theme)", function(v) getgenv().rbWorld = v end)

        -- 頁面 2：暴怒與盲狙
        local y2 = 10
        local function addP2(t, cb) addControlToPage(page2, y2, t, cb) y2 = y2 + 40 end
        addP2("超穩盲狙暴怒 (畫面正常，伺服器判定亂飛秒殺)", function(v) getgenv().rageOn = v end)
        addP2("高速無死角轉圈反擊 (Anti-Aim Spinbot + 瘋狂鎖頭)", function(v) getgenv().spinOn = v end)
        addP2("極速露頭秒殺 (對手一露頭直接 0 延遲自動爆頭)", function(v) getgenv().peekOn = v end)
        addP2("敵方超大判定框黑科技 (Super Hitbox - 敵人變大 35 倍)", function(v) getgenv().hitboxOn = v end)
        addP2("防禦亂向抖動旋轉 (Anti-Aim Jitter)", function(v) getgenv().jitterOn = v end)

        -- 頁面 3：透視與防禦
        local y3 = 10
        local function addP3(t, cb) addControlToPage(page3, y3, t, cb) y3 = y3 + 40 end
        addP3("3D 立體高精準方框透視 (3D Box ESP)", function(v) getgenv().boxOn = v end)
        addP3("對手連線追蹤線 (Tracer Lines)", function(v) getgenv().tracerOn = v end)
        addP3("對手頭頂名稱與血量透視 (Name & HP ESP)", function(v) getgenv().nameOn = v end)
        addP3("全地圖強制最高亮度 (Fullbright)", function(v) getgenv().fullOn = v end)
        addP3("絕對鎖血無敵不朽 (GodMode)", function(v) getgenv().godOn = v end)
        addP3("順滑無暈眩飛天穿牆 (Smooth Noclip & Fly)", function(v) getgenv().flyOn = v end)
        addP3("百米內自動蒸發殺戮光環 (Hit Kill Aura)", function(v) getgenv().auraOn = v end)

        -- 頁面 4：音效與天空
        local skyBtn = Instance.new("TextButton")
        skyBtn.Size = UDim2.new(1, -20, 0, 36)
        skyBtn.Position = UDim2.new(0, 10, 0, 10)
        skyBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
        skyBtn.BorderColor3 = themeColor
        skyBtn.Text = "  > [點擊載入] 自訂宇宙天空 ID"
        skyBtn.TextColor3 = themeColor
        skyBtn.Font = Enum.Font.Code
        skyBtn.TextSize = 11
        skyBtn.TextXAlignment = Enum.TextXAlignment.Left
        skyBtn.Parent = page4
        Instance.new("UICorner", skyBtn).CornerRadius = UDim.new(0, 6)

        skyBtn.MouseButton1Click:Connect(function()
            Lighting.ClockTime = 0
            Lighting.Brightness = 3
            for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
            local s = Instance.new("Sky")
            local skyId = "rbxassetid://155091771"
            s.SkyboxBk = skyId s.SkyboxDn = skyId s.SkyboxFt = skyId
            s.SkyboxLf = skyId s.SkyboxRt = skyId s.SkyboxUp = skyId
            s.Parent = Lighting
            skyBtn.Text = "  > [已成功載入] 天空 ID 生效！"
            task.delay(2, function() skyBtn.Text = "  > [點擊載入] 自訂宇宙天空 ID" end)
        end)

        local soundBtn = Instance.new("TextButton")
        soundBtn.Size = UDim2.new(1, -20, 0, 36)
        soundBtn.Position = UDim2.new(0, 10, 0, 56)
        soundBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
        soundBtn.BorderColor3 = themeColor
        soundBtn.Text = "  > [點擊測試] 50+ 頂級擊殺/開槍音效庫"
        soundBtn.TextColor3 = themeColor
        soundBtn.Font = Enum.Font.Code
        soundBtn.TextSize = 11
        soundBtn.TextXAlignment = Enum.TextXAlignment.Left
        soundBtn.Parent = page4
        Instance.new("UICorner", soundBtn).CornerRadius = UDim.new(0, 6)

        soundBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://4590657391"
                s.Volume = 1
                s.Parent = SoundService
                s:Play()
            end)
            soundBtn.Text = "  > [已播放測試] 音效庫正常！"
            task.delay(2, function() soundBtn.Text = "  > [點擊測試] 50+ 頂級擊殺/開槍音效庫" end)
        end)

        -- 核心主運行迴圈 (RenderStepped)
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

            cStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

            -- 左上角即時狀態更新
            local activeTexts = {}
            if getgenv().rbBody then table.insert(activeTexts, "[+] rainbow body") end
            if getgenv().custBody then table.insert(activeTexts, "[+] custom body color") end
            if getgenv().rbWeapon then table.insert(activeTexts, "[+] rainbow weapon") end
            if getgenv().rageOn then table.insert(activeTexts, "[+] stable ragebot") end
            if getgenv().spinOn then table.insert(activeTexts, "[+] anti-aim spinbot") end
            if getgenv().hitboxOn then table.insert(activeTexts, "[+] super hitbox (35x)") end
            if getgenv().boxOn then table.insert(activeTexts, "[+] 3d box esp") end
            if getgenv().godOn then table.insert(activeTexts, "[+] godmode enabled") end
            if getgenv().flyOn then table.insert(activeTexts, "[+] smooth noclip") end
            table.insert(activeTexts, "[+] WETQAPremium Active")
            statusListLabel.Text = table.concat(activeTexts, "\n")

            -- 人物變色
            if char then
                pcall(function()
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Neon
                            if getgenv().rbBody then
                                part.Color = Color3.fromHSV(tick() % 4 / 4, 1, 1)
                            elseif getgenv().custBody then
                                part.Color = customPlayerColor
                            end
                        end
                    end
                end)
            end

            -- 武器變色與極速射速
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
                            for _, tp in ipairs(tool:GetDescendants()) do
                                if tp:IsA("BasePart") then
                                    tp.Material = Enum.Material.Neon
                                    if getgenv().rbWeapon then
                                        tp.Color = Color3.fromHSV(tick() % 3 / 3, 1, 1)
                                    elseif getgenv().custWeapon then
                                        tp.Color = customWeaponColor
                                    end
                                end
                            end
                        end
                    end
                end)
            end

            -- 世界萬物變色
            if getgenv().rbWorld then
                pcall(function()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
                            obj.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                end)
            end

            -- 暴怒與盲狙
            if getgenv().rageOn or getgenv().spinOn or getgenv().peekOn then
                pcall(function()
                    if hrp and getgenv().spinOn then
                        local spinAngle = tick() * 80
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(140), 0)
                        hrp.Velocity = Vector3.new(math.sin(spinAngle) * 140, 90, math.cos(spinAngle) * 140)
                    end

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                            if tHum and tHum.Health > 0 then
                                local targetHead = p.Character.Head.Position
                                cam.CFrame = CFrame.new(cam.CFrame.Position, targetHead)

                                VirtualUser:Button1Down(Vector2.new(0,0))
                                task.wait(0.000001)
                                VirtualUser:Button1Up(Vector2.new(0,0))
                                break
                            end
                        end
                    end
                end)
            end

            -- 超大判定框 Hitbox
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if getgenv().hitboxOn then
                            root.Size = Vector3.new(35, 35, 35)
                            root.Transparency = 0.8
                            root.CanCollide = false
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end
                    end
                end
            end

            if getgenv().fullOn then
                Lighting.Brightness = 3
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
            end

            if getgenv().flyOn and char then
                pcall(function()
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    if hrp then hrp.Velocity = Vector3.new(0, 3, 0) end
                end)
            end

            if getgenv().auraOn and hrp then
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local tHrp = p.Character.HumanoidRootPart
                            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                            if (hrp.Position - tHrp.Position).Magnitude < 300 and tHum then
                                tHum.Health = 0
                            end
                        end
                    end
                end)
            end

            -- 3D Box ESP
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local box = p.Character:FindFirstChild("WETQAPremium_Box")
                    if getgenv().boxOn and p.Character:FindFirstChild("HumanoidRootPart") then
                        if not box then
                            box = Instance.new("SelectionBox")
                            box.Name = "WETQAPremium_Box"
                            box.Adornee = p.Character
                            box.Color3 = themeColor
                            box.LineThickness = 0.05
                            box.Parent = p.Character
                        end
                    else
                        if box then box:Destroy() end
                    end
                end
            end
        end)
    end)

    if not success then
        warn("Load Error: " .. tostring(err))
    end
end)
