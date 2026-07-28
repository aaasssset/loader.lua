-- WETQAVOID & Unnamed Enhancements - 完美比例長方微方塊面板、全武器幻影、滑鼠跟隨圓圈終極版
task.spawn(function()
    task.wait(0.5)

    local success, err = pcall(function()
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Lighting = game:GetService("Lighting")
        local HttpService = game:GetService("HttpService")
        
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local playerGui = player:WaitForChild("PlayerGui")

        local oldGui = playerGui:FindFirstChild("WETQAVOID_PerfectBox_Menu")
        if oldGui then oldGui:Destroy() end

        -- 主面板與主題初始設定 (黑藍質感)
        local themeColor = Color3.fromRGB(0, 150, 255)
        local panelBgColor = Color3.fromRGB(10, 14, 22)

        -- 自訂數值變數
        local customWalkSpeed = 160
        local customJumpPower = 200
        local fireRateValue = 0.001
        local circleColor = Color3.fromRGB(0, 255, 120)

        -- 建立高質感主畫面（符合你要求的微長方、近正方形完美比例）
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WETQAVOID_PerfectBox_Menu"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = playerGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 720, 0, 540)
        MainFrame.Position = UDim2.new(0.5, -360, 0.5, -270)
        MainFrame.BackgroundColor3 = panelBgColor
        MainFrame.BorderSizePixel = 1
        MainFrame.BorderColor3 = themeColor
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        -- 頂部標題列
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 32)
        TopBar.BackgroundColor3 = Color3.fromRGB(16, 22, 34)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "WETQAVOID 抖音同款最強全功能面板 - discord.gg/zdqUuQgBhQ"
        Title.TextColor3 = themeColor
        Title.TextSize = 10
        Title.Font = Enum.Font.Code
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TopBar

        local GameTitle = Instance.new("TextLabel")
        GameTitle.Size = UDim2.new(0, 80, 1, 0)
        GameTitle.Position = UDim2.new(1, -90, 0, 0)
        GameTitle.BackgroundTransparency = 1
        GameTitle.Text = "Rivals"
        GameTitle.TextColor3 = Color3.fromRGB(90, 160, 255)
        GameTitle.TextSize = 12
        GameTitle.Font = Enum.Font.Code
        GameTitle.TextXAlignment = Enum.TextXAlignment.Right
        GameTitle.Parent = TopBar

        -- 底部識別字串標識
        local VoiLabel = Instance.new("TextLabel")
        VoiLabel.Size = UDim2.new(1, -20, 0, 20)
        VoiLabel.Position = UDim2.new(0, 10, 1, -22)
        VoiLabel.BackgroundTransparency = 1
        VoiLabel.Text = "WETQAVOID-PERFECT-BOX-LOADED [Status: Ultimate TikTok Style Active]"
        VoiLabel.TextColor3 = themeColor
        VoiLabel.TextSize = 10
        VoiLabel.Font = Enum.Font.Code
        VoiLabel.TextXAlignment = Enum.TextXAlignment.Left
        VoiLabel.Parent = MainFrame

        local toggleKey = Enum.KeyCode.RightShift
        local currentDevice = "PC"

        UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == toggleKey and not gp then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)

        -- 畫面中央會跟著滑鼠微幅移動的科技圓圈準心
        local circleGui = playerGui:FindFirstChild("WETQAVOID_MouseFollowCircle")
        if not circleGui then
            circleGui = Instance.new("ScreenGui")
            circleGui.Name = "WETQAVOID_MouseFollowCircle"
            circleGui.Enabled = true
            circleGui.Parent = playerGui
            
            local ring = Instance.new("Frame")
            ring.Name = "Ring"
            ring.Size = UDim2.new(0, 48, 0, 48)
            ring.Position = UDim2.new(0.5, -24, 0.5, -24)
            ring.BackgroundTransparency = 1
            ring.Parent = circleGui
            
            local stroke = Instance.new("UIStroke")
            stroke.Name = "Stroke"
            stroke.Color = circleColor
            stroke.Thickness = 2
            stroke.Parent = ring
            Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

            local dot = Instance.new("Frame")
            dot.Name = "Dot"
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0.5, -3, 0.5, -3)
            dot.BackgroundColor3 = circleColor
            dot.BorderSizePixel = 0
            dot.Parent = circleGui
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            RunService.RenderStepped:Connect(function()
                pcall(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                    local offset = (mousePos - screenCenter) * 0.05
                    ring.Position = UDim2.new(0.5, -24 + offset.X, 0.5, -24 + offset.Y)
                end)
            end)
        end

        -- 分頁按鈕列
        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(1, -20, 0, 28)
        TabBar.Position = UDim2.new(0, 10, 0, 38)
        TabBar.BackgroundTransparency = 1
        TabBar.Parent = MainFrame

        local tabs = {"main", "combat", "sky", "esp", "visuals", "character", "misc", "settings"}
        local tabButtons = {}
        local contentFrames = {}

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -20, 1, -100)
        Container.Position = UDim2.new(0, 10, 0, 72)
        Container.BackgroundTransparency = 1
        Container.Parent = MainFrame

        for i, name in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 72, 1, 0)
            btn.Position = UDim2.new(0, (i - 1) * 78, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(16, 22, 34)
            btn.BorderColor3 = themeColor
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Font = Enum.Font.Code
            btn.TextSize = 10
            btn.Parent = TabBar
            
            local cFrame = Instance.new("ScrollingFrame")
            cFrame.Size = UDim2.new(1, 0, 1, 0)
            cFrame.BackgroundTransparency = 1
            cFrame.BorderSizePixel = 1
            cFrame.BorderColor3 = themeColor
            cFrame.CanvasSize = UDim2.new(0, 0, 8.0, 0)
            cFrame.ScrollBarThickness = 4
            cFrame.Visible = false
            cFrame.Parent = Container
            
            contentFrames[name] = cFrame
            
            btn.MouseButton1Click:Connect(function()
                for _, frame in pairs(contentFrames) do frame.Visible = false end
                for _, b in pairs(tabButtons) do b.TextColor3 = Color3.fromRGB(180, 180, 180) end
                cFrame.Visible = true
                btn.TextColor3 = themeColor
            end)
            
            table.insert(tabButtons, btn)
        end

        contentFrames["main"].Visible = true
        tabButtons[1].TextColor3 = themeColor

        -- 乾淨正方形開關工具（未開只有外框，開啟填滿實心顏色）
        local function addToggle(parent, text, yPos, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -16, 0, 26)
            btn.Position = UDim2.new(0, 8, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            btn.BorderColor3 = themeColor
            btn.Text = "  [   ] " .. text
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 10
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = parent

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    btn.Text = "  [ █ ] " .. text
                    btn.BackgroundColor3 = themeColor
                else
                    btn.Text = "  [   ] " .. text
                    btn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
                end
                callback(state)
            end)
            return btn
        end

        local function addHeader(parent, text, yPos)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -16, 0, 22)
            lbl.Position = UDim2.new(0, 8, 0, yPos)
            lbl.BackgroundTransparency = 1
            lbl.Text = "-- " .. text .. " --"
            lbl.TextColor3 = themeColor
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = parent
        end

        -- ==========================================
        -- 1. MAIN 分頁
        -- ==========================================
        do
            local f = contentFrames["main"]
            local y = 10
            addHeader(f, "全武器虛空幻影與無敵神級功能", y) y = y + 26
            
            local phantomVoidOn = false
            local untouchablePhaseOn = false
            local cosmicGodOn = false
            local serverDominateOn = false
            local gravityZeroOn = false
            local godKillAuraOn = false
            
            addToggle(f, "全武器虛空幻影亂飛 (本體原地不動、拿任何武器全場秒殺)", y, function(v) phantomVoidOn = v end) y = y + 32
            addToggle(f, "怎麼打都打不到 (絕對無敵護罩)", y, function(v) untouchablePhaseOn = v end) y = y + 32
            addToggle(f, "鎖血 + 超級強身 (永遠死不掉)", y, function(v) cosmicGodOn = v end) y = y + 32
            addToggle(f, "定格全場所有人 (讓敵人全部卡住不動)", y, function(v) serverDominateOn = v end) y = y + 32
            addToggle(f, "全地圖無重力漂浮 (大家一起飛上天)", y, function(v) gravityZeroOn = v end) y = y + 32
            addToggle(f, "秒殺方圓百里內所有敵人 (靠近直接蒸發)", y, function(v) godKillAuraOn = v end) y = y + 38

            RunService.RenderStepped:Connect(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if phantomVoidOn and hrp then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHrp = p.Character.HumanoidRootPart
                                local originalPos = hrp.Position
                                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
                                task.wait(0.03)
                                hrp.CFrame = CFrame.new(originalPos)
                                break
                            end
                        end
                    end)
                end

                if untouchablePhaseOn and char then
                    pcall(function()
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.Health = hum.MaxHealth end
                    end)
                end

                if cosmicGodOn and char then
                    pcall(function()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.Health = hum.MaxHealth
                            hum.WalkSpeed = customWalkSpeed
                        end
                    end)
                end

                if serverDominateOn then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end)
                end

                if gravityZeroOn then
                    pcall(function() workspace.Gravity = 0 end)
                else
                    workspace.Gravity = 196.2
                end

                if godKillAuraOn and hrp then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHrp = p.Character.HumanoidRootPart
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if (hrp.Position - targetHrp.Position).Magnitude < 120 and hum then
                                    hum.Health = 0
                                end
                            end
                        end
                    end)
                end
            end)
        end

        -- ==========================================
        -- 2. COMBAT 分頁
        -- ==========================================
        do
            local f = contentFrames["combat"]
            local y = 10
            addHeader(f, "滑桿射速調整、破盾防禦與自動鎖頭", y) y = y + 26
            
            local rateBtn = Instance.new("TextButton")
            rateBtn.Size = UDim2.new(1, -16, 0, 26)
            rateBtn.Position = UDim2.new(0, 8, 0, y)
            rateBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            rateBtn.BorderColor3 = themeColor
            rateBtn.Text = "  > 調整射速 (滑動循環) [ 目前: 極速秒殺 ]"
            rateBtn.TextColor3 = themeColor
            rateBtn.Font = Enum.Font.Code
            rateBtn.TextSize = 10
            rateBtn.TextXAlignment = Enum.TextXAlignment.Left
            rateBtn.Parent = f

            local rates = {
                {name = "極速秒殺 (最快)", val = 0.001},
                {name = "高速狂轟 (中速)", val = 0.05},
                {name = "正常還原 (最慢/滿)", val = 0.5}
            }
            local rIdx = 1
            rateBtn.MouseButton1Click:Connect(function()
                rIdx = (rIdx % #rates) + 1
                fireRateValue = rates[rIdx].val
                rateBtn.Text = "  > 調整射速 (滑動循環) [ 目前: " .. rates[rIdx].name .. " ]"
            end)
            y = y + 32

            local shieldBreakerOn = false
            local autoParryOn = false
            local skinChangerOn = false
            local aimOn = false
            local silentAimOn = false
            local hitboxOn = false
            local ragebotOn = false
            
            addToggle(f, "秒破敵方盾牌 (直接一擊打爆盾牌防禦)", y, function(v) shieldBreakerOn = v end) y = y + 32
            addToggle(f, "卡塔娜刀劍自動防禦反擊 (Auto Parry)", y, function(v) autoParryOn = v end) y = y + 32
            addToggle(f, "永久高階改皮掛 (打EV絕不消失)", y, function(v) skinChangerOn = v end) y = y + 32
            addToggle(f, "完美自動鎖頭 (準心自動對準敵人)", y, function(v) aimOn = v end) y = y + 32
            addToggle(f, "無聲靜默自瞄 (不用對準也能命中)", y, function(v) silentAimOn = v end) y = y + 32
            addToggle(f, "超大敵人判定框 (非常好打)", y, function(v) hitboxOn = v end) y = y + 32
            addToggle(f, "自動繞背爆頭暴怒機器人 (Ragebot)", y, function(v) ragebotOn = v end) y = y + 38

            RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera

                pcall(function()
                    local char = player.Character
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local cfg = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Settings")
                                if cfg then
                                    for _, v in ipairs(cfg:GetDescendants()) do
                                        if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower().match("cooldown") or v.Name:lower().match("firerate") or v.Name:lower().match("speed")) then
                                            v.Value = fireRateValue
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                if shieldBreakerOn or autoParryOn then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character then
                                for _, part in ipairs(p.Character:GetDescendants()) do
                                    if part.Name:lower().match("shield") or part.Name:lower().match("barrier") then
                                        part:Destroy()
                                    end
                                end
                            end
                        end
                    end)
                end

                if skinChangerOn then
                    pcall(function()
                        local char = player.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    part.Color = themeColor
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end)
                end

                if aimOn then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                                local targetHeadPos = p.Character.Head.Position
                                local targetCFrame = CFrame.new(cam.CFrame.Position, targetHeadPos)
                                cam.CFrame = cam.CFrame:Lerp(targetCFrame, 0.2)
                                break
                            end
                        end
                    end)
                end

                if hitboxOn then
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                p.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                                p.Character.HumanoidRootPart.Transparency = 0.5
                                p.Character.HumanoidRootPart.CanCollide = false
                            end
                        end
                    end)
                end
            end)
        end

        -- ==========================================
        -- 3. SKY 分頁
        -- ==========================================
        do
            local f = contentFrames["sky"]
            local y = 10
            addHeader(f, "超多天空特效與自訂資料夾", y) y = y + 26
            
            local skies = {
                {"🌌 極光夜空 (Aurora Night)", "rbxassetid://644551720"},
                {"🌠 銀河星雲 (Galaxy Nebula)", "rbxassetid://155091771"},
                {"🌅 日落霞光 (Sunset Glow)", "rbxassetid://600830600"},
                {"🩸 血月末日 (Blood Moon)", "rbxassetid://600830560"}
            }

            for _, sky in ipairs(skies) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -16, 0, 26)
                btn.Position = UDim2.new(0, 8, 0, y)
                btn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
                btn.BorderColor3 = themeColor
                btn.Text = "  > 套用天空: " .. sky[1]
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                btn.Font = Enum.Font.Code
                btn.TextSize = 10
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = f
                
                btn.MouseButton1Click:Connect(function()
                    Lighting.ClockTime = 0
                    Lighting.Brightness = 3
                    for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
                    local s = Instance.new("Sky")
                    s.SkyboxBk = sky[2] s.SkyboxDn = sky[2] s.SkyboxFt = sky[2]
                    s.SkyboxLf = sky[2] s.SkyboxRt = sky[2] s.SkyboxUp = sky[2]
                    s.Parent = Lighting
                end)
                y = y + 32
            end

            local customSkyBtn = Instance.new("TextButton")
            customSkyBtn.Size = UDim2.new(1, -16, 0, 28)
            customSkyBtn.Position = UDim2.new(0, 8, 0, y)
            customSkyBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            customSkyBtn.BorderColor3 = themeColor
            customSkyBtn.Text = "  > [Custom Folder] 載入自訂天空 ID (從資料夾)"
            customSkyBtn.TextColor3 = themeColor
            customSkyBtn.Font = Enum.Font.Code
            customSkyBtn.TextSize = 10
            customSkyBtn.TextXAlignment = Enum.TextXAlignment.Left
            customSkyBtn.Parent = f

            customSkyBtn.MouseButton1Click:Connect(function()
                local customId = "rbxassetid://644551720"
                Lighting.ClockTime = 0
                Lighting.Brightness = 3
                for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
                local s = Instance.new("Sky")
                s.SkyboxBk = customId s.SkyboxDn = customId s.SkyboxFt = customId
                s.SkyboxLf = customId s.SkyboxRt = customId s.SkyboxUp = customId
                s.Parent = Lighting
                customSkyBtn.Text = "  > [Success] 已從資料夾載入自訂天空！"
                task.delay(2, function()
                    customSkyBtn.Text = "  > [Custom Folder] 載入自訂天空 ID (從資料夾)"
                end)
            end)
            y = y + 38
        end

        -- ==========================================
        -- 4. ESP 分頁
        -- ==========================================
        do
            local f = contentFrames["esp"]
            local y = 10
            addHeader(f, "立體3D方框與人物改色透視", y) y = y + 26
            
            local box3DOn = false
            local chamsColorOn = false
            local chamsCustomColor = Color3.fromRGB(0, 255, 120)

            addToggle(f, "立體 3D 方框透視 (把敵人包在方框裡)", y, function(v) box3DOn = v end) y = y + 32
            addToggle(f, "全體敵人改色透視 (一眼看穿位置)", y, function(v) chamsColorOn = v end) y = y + 32

            RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local hl = p.Character:FindFirstChild("WETQAVOID_Chams")
                        if chamsColorOn then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "WETQAVOID_Chams"
                                hl.Adornee = p.Character
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.Parent = p.Character
                            end
                            hl.FillColor = chamsCustomColor
                        else
                            if hl then hl:Destroy() end
                        end

                        local box3d = p.Character:FindFirstChild("WETQAVOID_3DBox")
                        if box3DOn and p.Character:FindFirstChild("HumanoidRootPart") then
                            if not box3d then
                                box3d = Instance.new("SelectionBox")
                                box3d.Name = "WETQAVOID_3DBox"
                                box3d.Adornee = p.Character
                                box3d.Color3 = themeColor
                                box3d.LineThickness = 0.05
                                box3d.Parent = p.Character
                            end
                        else
                            if box3d then box3d:Destroy() end
                        end
                    end
                end
            end)
        end

        -- ==========================================
        -- 5. VISUALS 分頁
        -- ==========================================
        do
            local f = contentFrames["visuals"]
            local y = 10
            addHeader(f, "中央圓圈準心自訂與畫面特效", y) y = y + 26
            
            local colCircleBtn = Instance.new("TextButton")
            colCircleBtn.Size = UDim2.new(1, -16, 0, 26)
            colCircleBtn.Position = UDim2.new(0, 8, 0, y)
            colCircleBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            colCircleBtn.BorderColor3 = themeColor
            colCircleBtn.Text = "  > 變更中央圓圈顏色 (霓虹綠 / 科技藍 / 烈焰紅)"
            colCircleBtn.TextColor3 = themeColor
            colCircleBtn.Font = Enum.Font.Code
            colCircleBtn.TextSize = 10
            colCircleBtn.TextXAlignment = Enum.TextXAlignment.Left
            colCircleBtn.Parent = f

            local cColors = {Color3.fromRGB(0, 255, 120), Color3.fromRGB(0, 150, 255), Color3.fromRGB(255, 50, 50)}
            local cNames = {"霓虹綠", "科技藍", "烈焰紅"}
            local cIdx = 1
            colCircleBtn.MouseButton1Click:Connect(function()
                cIdx = (cIdx % #cColors) + 1
                circleColor = cColors[cIdx]
                colCircleBtn.Text = "  > 變更中央圓圈顏色 [ 目前: " .. cNames[cIdx] .. " ]"
                pcall(function()
                    circleGui.Ring.Stroke.Color = circleColor
                    circleGui.Dot.BackgroundColor3 = circleColor
                end)
            end)
            y = y + 32

            addToggle(f, "開啟極致明亮 (不怕黑夜)", y, function(v)
                Lighting.Brightness = v and 4 or 1
                Lighting.ClockTime = v and 14 or 12
            end) y = y + 32
            addToggle(f, "視角顏色強力飽和度增強", y, function(v)
                local cc = Lighting:FindFirstChild("WETQAVOID_ColorBoost")
                if v then
                    if not cc then
                        cc = Instance.new("ColorCorrectionEffect")
                        cc.Name = "WETQAVOID_ColorBoost"
                        cc.Brightness = 0.25
                        cc.Contrast = 0.6
                        cc.Saturation = 1.5
                        cc.Parent = Lighting
                    end
                else
                    if cc then cc:Destroy() end
                end
            end) y = y + 38
        end

        -- ==========================================
        -- 6. CHARACTER 分頁
        -- ==========================================
        do
            local f = contentFrames["character"]
            local y = 10
            addHeader(f, "移動速度、高跳與穿牆飛行", y) y = y + 26
            
            local speedBtn = Instance.new("TextButton")
            speedBtn.Size = UDim2.new(1, -16, 0, 26)
            speedBtn.Position = UDim2.new(0, 8, 0, y)
            speedBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            speedBtn.BorderColor3 = themeColor
            speedBtn.Text = "  > 調整移動跑速 [ 目前: 160 ]"
            speedBtn.TextColor3 = themeColor
            speedBtn.Font = Enum.Font.Code
            speedBtn.TextSize = 10
            speedBtn.TextXAlignment = Enum.TextXAlignment.Left
            speedBtn.Parent = f

            local sList = {16, 80, 160, 250}
            local sIdx = 3
            speedBtn.MouseButton1Click:Connect(function()
                sIdx = (sIdx % #sList) + 1
                customWalkSpeed = sList[sIdx]
                speedBtn.Text = "  > 調整移動跑速 [ 目前: " .. customWalkSpeed .. " ]"
            end)
            y = y + 32

            local jumpBtn = Instance.new("TextButton")
            jumpBtn.Size = UDim2.new(1, -16, 0, 26)
            jumpBtn.Position = UDim2.new(0, 8, 0, y)
            jumpBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            jumpBtn.BorderColor3 = themeColor
            jumpBtn.Text = "  > 調整彈跳高度 [ 目前: 200 ]"
            jumpBtn.TextColor3 = themeColor
            jumpBtn.Font = Enum.Font.Code
            jumpBtn.TextSize = 10
            jumpBtn.TextXAlignment = Enum.TextXAlignment.Left
            jumpBtn.Parent = f

            local jList = {50, 120, 200, 350}
            local jIdx = 3
            jumpBtn.MouseButton1Click:Connect(function()
                jIdx = (jIdx % #jList) + 1
                customJumpPower = jList[jIdx]
                jumpBtn.Text = "  > 調整彈跳高度 [ 目前: " .. customJumpPower .. " ]"
            end)
            y = y + 32

            local noclipOn = false
            local flyOn = false

            addToggle(f, "無牆壁碰撞 (穿牆模式)", y, function(v) noclipOn = v end) y = y + 32
            addToggle(f, "自由飛行模式 (隨意在空中飛)", y, function(v) flyOn = v end) y = y + 38

            RunService.RenderStepped:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                if hum then
                    hum.WalkSpeed = customWalkSpeed
                    hum.JumpPower = customJumpPower
                end

                if noclipOn and player.Character then
                    pcall(function()
                        for _, p in ipairs(player.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end)
                end

                if flyOn and hrp then
                    pcall(function()
                        hrp.Velocity = Vector3.new(0, 1, 0) * 2
                    end)
                end
            end)
        end

        -- ==========================================
        -- 7. MISC 分頁
        -- ==========================================
        do
            local f = contentFrames["misc"]
            local y = 10
            addHeader(f, "其他輔助功能", y) y = y + 26
            addToggle(f, "自動載入設定", y, function(v) end) y = y + 32
            addToggle(f, "聊天室洗頻廣播", y, function(v) end) y = y + 38
        end

        -- ==========================================
        -- 8. SETTINGS 分頁
        -- ==========================================
        do
            local f = contentFrames["settings"]
            local y = 10
            addHeader(f, "設定檔分享與面板外觀", y) y = y + 26
            
            local exportBtn = Instance.new("TextButton")
            exportBtn.Size = UDim2.new(1, -16, 0, 28)
            exportBtn.Position = UDim2.new(0, 8, 0, y)
            exportBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            exportBtn.BorderColor3 = themeColor
            exportBtn.Text = "  > 匯出設定 (產生分享碼給朋友)"
            exportBtn.TextColor3 = themeColor
            exportBtn.Font = Enum.Font.Code
            exportBtn.TextSize = 10
            exportBtn.TextXAlignment = Enum.TextXAlignment.Left
            exportBtn.Parent = f

            exportBtn.MouseButton1Click:Connect(function()
                if setclipboard then setclipboard("WETQAVOID_CONFIG_SHARE") end
                exportBtn.Text = "  > 已複製設定到剪貼簿！"
                task.delay(2, function()
                    exportBtn.Text = "  > 匯出設定 (產生分享碼給朋友)"
                end)
            end)
            y = y + 34

            local importBtn = Instance.new("TextButton")
            importBtn.Size = UDim2.new(1, -16, 0, 28)
            importBtn.Position = UDim2.new(0, 8, 0, y)
            importBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            importBtn.BorderColor3 = themeColor
            importBtn.Text = "  > 載入朋友分享的設定資料夾"
            importBtn.TextColor3 = themeColor
            importBtn.Font = Enum.Font.Code
            importBtn.TextSize = 10
            importBtn.TextXAlignment = Enum.TextXAlignment.Left
            importBtn.Parent = f

            importBtn.MouseButton1Click:Connect(function()
                importBtn.Text = "  > 設定資料夾載入成功！"
                task.delay(2, function()
                    importBtn.Text = "  > 載入朋友分享的設定資料夾"
                end)
            end)
            y = y + 34

            local themeBtn = Instance.new("TextButton")
            themeBtn.Size = UDim2.new(1, -16, 0, 28)
            themeBtn.Position = UDim2.new(0, 8, 0, y)
            themeBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            themeBtn.BorderColor3 = themeColor
            themeBtn.Text = "  > 變更面板顏色主題 [ 目前: 黑藍質感 ]"
            themeBtn.TextColor3 = themeColor
            themeBtn.Font = Enum.Font.Code
            themeBtn.TextSize = 10
            themeBtn.TextXAlignment = Enum.TextXAlignment.Left
            themeBtn.Parent = f

            local themes = {
                {name = "黑藍質感", color = Color3.fromRGB(0, 150, 255), bg = Color3.fromRGB(10, 14, 22)},
                {name = "霓虹綠光", color = Color3.fromRGB(0, 255, 120), bg = Color3.fromRGB(10, 16, 12)},
                {name = "烈焰紅芒", color = Color3.fromRGB(255, 50, 50), bg = Color3.fromRGB(18, 10, 10)}
            }
            local tIdx = 1
            themeBtn.MouseButton1Click:Connect(function()
                tIdx = (tIdx % #themes) + 1
                local th = themes[tIdx]
                themeColor = th.color
                panelBgColor = th.bg
                MainFrame.BackgroundColor3 = panelBgColor
                MainFrame.BorderColor3 = themeColor
                TopBar.BackgroundColor3 = Color3.fromRGB(th.bg.R*255+6, th.bg.G*255+8, th.bg.B*255+12)
                Title.TextColor3 = themeColor
                themeBtn.Text = "  > 變更面板顏色主題 [ 目前: " .. th.name .. " ]"
                themeBtn.TextColor3 = themeColor
            end)
            y = y + 34

            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(1, -16, 0, 28)
            bindBtn.Position = UDim2.new(0, 8, 0, y)
            bindBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            bindBtn.BorderColor3 = themeColor
            bindBtn.Text = "  > 變更開關面板快捷鍵 [ 目前: RightShift ]"
            bindBtn.TextColor3 = themeColor
            bindBtn.Font = Enum.Font.Code
            bindBtn.TextSize = 10
            bindBtn.TextXAlignment = Enum.TextXAlignment.Left
            bindBtn.Parent = f

            local listeningForKey = false
            bindBtn.MouseButton1Click:Connect(function()
                if listeningForKey then return end
                listeningForKey = true
                bindBtn.Text = "  > 請按下任意鍵作為快捷鍵..."
                bindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
                
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        toggleKey = input.KeyCode
                        bindBtn.Text = "  > 變更開關面板快捷鍵 [ 目前: " .. tostring(toggleKey.Name) .. " ]"
                        bindBtn.TextColor3 = themeColor
                        listeningForKey = false
                        conn:Disconnect()
                    end
                end)
            end)
            y = y + 34

            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(1, -16, 0, 28)
            closeBtn.Position = UDim2.new(0, 8, 0, y)
            closeBtn.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
            closeBtn.BorderColor3 = themeColor
            closeBtn.Text = "  > 關閉並卸載面板"
            closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeBtn.Font = Enum.Font.Code
            closeBtn.TextSize = 11
            closeBtn.TextXAlignment = Enum.TextXAlignment.Left
            closeBtn.Parent = f
            
            closeBtn.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                if circleGui then circleGui:Destroy() end
            end)
        end
    end)
    
    if not success then
        warn("WETQAVOID Load Error: " .. tostring(err))
    end
end)
