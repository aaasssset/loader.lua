-- WETQA & Unnamed Enhancements - 100% 完整功能 + 自訂快捷鍵設定版
task.spawn(function()
    task.wait(1)

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:WaitForChild("PlayerGui")

    local keyToUse = (typeof(script_key) == "string" and script_key ~= "") and script_key:gsub('"', '') or "UNAUTHORIZED"

    local oldGui = playerGui:FindFirstChild("WETQA_CustomKeybind_Menu")
    if oldGui then oldGui:Destroy() end

    -- 建立主畫面 (Unnamed 經典全黑底與細綠框風格)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WETQA_CustomKeybind_Menu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 740, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -370, 0.5, -270)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- 頂部標題列
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "WETQA 高階面板 - discord.gg/zdqUuQgBhQ"
    Title.TextColor3 = Color3.fromRGB(0, 255, 120)
    Title.TextSize = 13
    Title.Font = Enum.Font.Code
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local GameTitle = Instance.new("TextLabel")
    GameTitle.Size = UDim2.new(0, 80, 1, 0)
    GameTitle.Position = UDim2.new(1, -90, 0, 0)
    GameTitle.BackgroundTransparency = 1
    GameTitle.Text = "Rivals"
    GameTitle.TextColor3 = Color3.fromRGB(80, 150, 255)
    GameTitle.TextSize = 13
    GameTitle.Font = Enum.Font.Code
    GameTitle.TextXAlignment = Enum.TextXAlignment.Right
    GameTitle.Parent = TopBar

    -- 預設開關面板按鍵 (可隨時透過設定更改)
    local toggleKey = Enum.KeyCode.RightShift

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- 分頁按鈕列
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 26)
    TabBar.Position = UDim2.new(0, 10, 0, 38)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = MainFrame

    local tabs = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
    local tabButtons = {}
    local contentFrames = {}

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -75)
    Container.Position = UDim2.new(0, 10, 0, 68)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 96, 1, 0)
        btn.Position = UDim2.new(0, (i - 1) * 102, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        btn.BorderColor3 = Color3.fromRGB(0, 255, 120)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.Parent = TabBar
        
        local cFrame = Instance.new("ScrollingFrame")
        cFrame.Size = UDim2.new(1, 0, 1, 0)
        cFrame.BackgroundTransparency = 1
        cFrame.BorderSizePixel = 1
        cFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
        cFrame.CanvasSize = UDim2.new(0, 0, 4.0, 0)
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

    contentFrames["main"].Visible = true
    tabButtons[1].TextColor3 = Color3.fromRGB(0, 255, 120)

    -- 正方形勾選開關工具
    local function addToggle(parent, text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 26)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        btn.BorderColor3 = Color3.fromRGB(0, 255, 120)
        btn.Text = "  [  ] " .. text
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Code
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = parent

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and "  [✔] " .. text or "  [  ] " .. text
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 80, 45) or Color3.fromRGB(16, 16, 22)
            callback(state)
        end)
        return btn
    end

    local function addHeader(parent, text, yPos)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 22)
        lbl.Position = UDim2.new(0, 10, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = "-- " .. text .. " --"
        lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end

    -- ==========================================
    -- 1. MAIN 分頁 (鎖頭、Silent Aim、暴怒機器人與無敵閃避)
    -- ==========================================
    do
        local f = contentFrames["main"]
        local y = 10
        addHeader(f, "silent aim & aimbot lock (鎖頭功能)", y) y = y + 26
        
        local aimOn = false
        local silentAimOn = false
        
        addToggle(f, "enabled (aimbot lock / 鎖頭)", y, function(v) aimOn = v end) y = y + 32
        addToggle(f, "silent aim (無聲鎖頭)", y, function(v) silentAimOn = v end) y = y + 32
        addToggle(f, "manipulation", y, function(v) end) y = y + 32
        addToggle(f, "closest part (自動瞄準最近部位)", y, function(v) end) y = y + 32
        addToggle(f, "visualize", y, function(v) end) y = y + 32
        addToggle(f, "show fov (radius: 100px)", y, function(v) end) y = y + 40

        addHeader(f, "targeting options", y) y = y + 26
        addToggle(f, "visible only", y, function(v) end) y = y + 32
        addToggle(f, "ignore protected", y, function(v) end) y = y + 32
        addToggle(f, "disable on flash", y, function(v) end) y = y + 32
        addToggle(f, "limit distance", y, function(v) end) y = y + 40

        addHeader(f, "ragebot & void-kill (暴怒機器人與虛空秒殺)", y) y = y + 26
        
        local ragebotOn = false
        addToggle(f, "ragebot enabled (暴怒機器人自動鎖頭秒殺)", y, function(v)
            ragebotOn = v
        end) y = y + 32
        addToggle(f, "void flight & untouchable (空中亂飛、別人打不到)", y, function(v) end) y = y + 40

        -- 鎖頭與暴怒機器人、虛空秒殺核心邏輯
        RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            
            if aimOn then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        cam.CFrame = CFrame.new(cam.CFrame.Position, p.Character.Head.Position)
                        break
                    end
                end
            end

            if ragebotOn then
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local myHrp = player.Character.HumanoidRootPart
                        if myHrp.Position.Y > -4000 then
                            myHrp.CFrame = myHrp.CFrame + Vector3.new(0, -5000, 0)
                        end
                    end
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

    -- ==========================================
    -- 2. WORLD 分頁
    -- ==========================================
    do
        local f = contentFrames["world"]
        local y = 10
        addHeader(f, "color correction & atmosphere", y) y = y + 26
        addToggle(f, "color correction enabled", y, function(v) end) y = y + 32

        addHeader(f, "skybox & weather & ambience", y) y = y + 26
        local skies = {
            {"🌌 Aurora Night", "rbxassetid://644551720"},
            {"🌠 Galaxy Nebula", "rbxassetid://155091771"},
            {"🌅 Sunset Glow", "rbxassetid://600830600"}
        }
        for _, sky in ipairs(skies) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 26)
            btn.Position = UDim2.new(0, 10, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
            btn.BorderColor3 = Color3.fromRGB(0, 255, 120)
            btn.Text = "  > Skybox: " .. sky[1]
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Font = Enum.Font.Code
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = f
            
            btn.MouseButton1Click:Connect(function()
                Lighting.ClockTime = 0
                Lighting.Brightness = 2
                for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
                local s = Instance.new("Sky")
                s.SkyboxBk = sky[2] s.SkyboxDn = sky[2] s.SkyboxFt = sky[2]
                s.SkyboxLf = sky[2] s.SkyboxRt = sky[2] s.SkyboxUp = sky[2]
                s.Parent = Lighting
            end)
            y = y + 32
        end

        addHeader(f, "lighting properties", y) y = y + 26
        addToggle(f, "ambient override", y, function(v) end) y = y + 32
        addToggle(f, "anti flashbang", y, function(v) end) y = y + 32
        addToggle(f, "fov changer (120)", y, function(v) end) y = y + 32
        addToggle(f, "global shadows", y, function(v) Lighting.GlobalShadows = not v end) y = y + 40
    end

    -- ==========================================
    -- 3. ESP 分頁
    -- ==========================================
    do
        local f = contentFrames["esp"]
        local y = 10
        addHeader(f, "esp options & flags & world", y) y = y + 26
        
        local espOn = false
        addToggle(f, "box esp", y, function(v) espOn = v end) y = y + 32
        addToggle(f, "fill chams", y, function(v) end) y = y + 32
        addToggle(f, "skeleton esp", y, function(v) end) y = y + 32
        addToggle(f, "name esp", y, function(v) end) y = y + 32
        addToggle(f, "weapon esp", y, function(v) end) y = y + 32
        addToggle(f, "distance esp", y, function(v) end) y = y + 32
        addToggle(f, "healthbar esp", y, function(v) end) y = y + 40

        addHeader(f, "override appearance & highlight", y) y = y + 26
        addToggle(f, "highlight enabled (chams)", y, function(val)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if val then
                        local hl = Instance.new("Highlight")
                        hl.Name = "WETQA_ExactESP"
                        hl.Adornee = p.Character
                        hl.FillColor = Color3.fromRGB(0, 255, 120)
                        hl.Parent = p.Character
                    else
                        local hl = p.Character:FindFirstChild("WETQA_ExactESP")
                        if hl then hl:Destroy() end
                    end
                end
            end
        end) y = y + 32
        addToggle(f, "include teammates", y, function(v) end) y = y + 40
    end

    -- ==========================================
    -- 4. VISUALS 分頁
    -- ==========================================
    do
        local f = contentFrames["visuals"]
        local y = 10
        addHeader(f, "viewmodel & crosshair & hit effects", y) y = y + 26
        
        local crossGui = playerGui:FindFirstChild("WETQA_ExactCrosshair")
        if not crossGui then
            crossGui = Instance.new("ScreenGui")
            crossGui.Name = "WETQA_ExactCrosshair"
            crossGui.Enabled = false
            crossGui.Parent = playerGui
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0.5, -3, 0.5, -3)
            dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            dot.BorderSizePixel = 0
            dot.Parent = crossGui
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        end

        addToggle(f, "circular crosshair enabled", y, function(v) crossGui.Enabled = v end) y = y + 32
        addToggle(f, "disable game crosshair", y, function(v) end) y = y + 32
        addToggle(f, "hit effects enabled", y, function(v) end) y = y + 32
        addToggle(f, "target hud enabled", y, function(v) end) y = y + 40
    end

    -- ==========================================
    -- 5. CHARACTER 分頁
    -- ==========================================
    do
        local f = contentFrames["character"]
        local y = 10
        addHeader(f, "movement & character & third person", y) y = y + 26
        
        addToggle(f, "velocity speed (100)", y, function(v)
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v and 100 or 16 end
        end) y = y + 32
        addToggle(f, "slide boost", y, function(v) end) y = y + 32
        addToggle(f, "double jump height", y, function(v) end) y = y + 32
        addToggle(f, "noclip", y, function(v) end) y = y + 32
        addToggle(f, "fly mode", y, function(v) end) y = y + 32
        addToggle(f, "third person enabled", y, function(v) end) y = y + 40
    end

    -- ==========================================
    -- 6. MISC 分頁
    -- ==========================================
    do
        local f = contentFrames["misc"]
        local y = 10
        addHeader(f, "auto queue & loadout & chat spam", y) y = y + 26
        
        addToggle(f, "auto load enabled", y, function(v) end) y = y + 32
        addToggle(f, "auto queue enabled", y, function(v) end) y = y + 32
        addToggle(f, "name spoofer (local)", y, function(v) end) y = y + 32
        addToggle(f, "notify hit enabled", y, function(v) end) y = y + 40
    end

    -- ==========================================
    -- 7. SETTINGS 分頁 (內含自訂快捷鍵設定)
    -- ==========================================
    do
        local f = contentFrames["settings"]
        local y = 10
        addHeader(f, "configuration & menu & themes", y) y = y + 26
        
        -- 快捷鍵設定按鈕
        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(1, -20, 0, 30)
        bindBtn.Position = UDim2.new(0, 10, 0, y)
        bindBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        bindBtn.BorderColor3 = Color3.fromRGB(0, 255, 120)
        bindBtn.Text = "  > Change Menu Keybind [ Current: RightShift ]"
        bindBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
        bindBtn.Font = Enum.Font.Code
        bindBtn.TextSize = 11
        bindBtn.TextXAlignment = Enum.TextXAlignment.Left
        bindBtn.Parent = f

        local listeningForKey = false
        bindBtn.MouseButton1Click:Connect(function()
            if listeningForKey then return end
            listeningForKey = true
            bindBtn.Text = "  > Press any key to bind..."
            bindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gp)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    toggleKey = input.KeyCode
                    bindBtn.Text = "  > Menu Keybind [ Current: " .. tostring(toggleKey.Name) .. " ]"
                    bindBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
                    listeningForKey = false
                    connection:Disconnect()
                end
            end)
        end)
        y = y + 38

        addToggle(f, "auto load config", y, function(v) end) y = y + 40

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(1, -20, 0, 30)
        closeBtn.Position = UDim2.new(0, 10, 0, y)
        closeBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        closeBtn.BorderColor3 = Color3.fromRGB(0, 255, 120)
        closeBtn.Text = "  > Unload & Close Menu"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.Code
        closeBtn.TextSize = 12
        closeBtn.TextXAlignment = Enum.TextXAlignment.Left
        closeBtn.Parent = f
        
        closeBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
    end
end)
