-- WETQA高級面板 Ultimate Combined
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Auto create config folder
local configFolderName = "WETQA高級面板_Configs"
pcall(function()
    if makefolder and not isfolder(configFolderName) then
        makefolder(configFolderName)
    end
end)

-- Create UI ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WETQA高級面板Ultimate"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner") UICorner.CornerRadius = UDim.new(0, 8) UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 8) TopCorner.Parent = TopBar

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(0, 30, 1, 0) LogoIcon.Position = UDim2.new(0, 12, 0, 0)
LogoIcon.BackgroundTransparency = 1 LogoIcon.Text = "⚡" LogoIcon.TextColor3 = Color3.fromRGB(0, 255, 120) LogoIcon.TextSize = 16 LogoIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0) Title.Position = UDim2.new(0, 45, 0, 0)
Title.BackgroundTransparency = 1 Title.Text = "WETQA高級面板 - discord.gg/zdqUuQgBhQ | Ultimate"
Title.TextColor3 = Color3.fromRGB(200, 200, 200) Title.TextSize = 12 Title.Font = Enum.Font.GothamBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = TopBar

-- Dragging Functionality
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle UI with RightShift
local isUIVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        isUIVisible = not isUIVisible
        MainFrame.Visible = isUIVisible
    end
end)

-- Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -80)
Container.Position = UDim2.new(0, 0, 0, 80)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -10)
ContentContainer.Position = UDim2.new(0, 10, 0, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 3.5, 0)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = Container

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabBar.Parent = MainFrame
local TabCorner = Instance.new("UICorner") TabCorner.CornerRadius = UDim.new(0, 6) TabCorner.Parent = TabBar

local tabs = {"main", "aimbot", "esp", "world", "visuals", "character", "misc", "settings"}

local function renderTab(tabName)
    ContentContainer:ClearAllChildren()
    local yOffset = 10
    
    if tabName == "main" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "🔑 WETQA高級面板 - 授權與驗證" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local tb = Instance.new("TextBox") tb.Size = UDim2.new(1, 0, 0, 38) tb.Position = UDim2.new(0,0,0,yOffset) tb.PlaceholderText = "Enter WETQA Key..." tb.TextColor3 = Color3.fromRGB(255,255,255) tb.BackgroundColor3 = Color3.fromRGB(30,30,40) tb.TextSize = 13 tb.Font = Enum.Font.Gotham tb.Parent = ContentContainer
        
        if script_key then
            tb.Text = script_key
        end

        local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0,6) tc.Parent = tb
        yOffset = yOffset + 48
        
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, 0, 0, 38) btn.Position = UDim2.new(0,0,0,yOffset) btn.Text = "Verify Key" btn.TextColor3 = Color3.fromRGB(255,255,255) btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) btn.Font = Enum.Font.GothamBold btn.TextSize = 13 btn.Parent = ContentContainer
        local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0,6) bc.Parent = btn
        yOffset = yOffset + 48
        
        local st = Instance.new("TextLabel") st.Size = UDim2.new(1, 0, 0, 30) st.Position = UDim2.new(0,0,0,yOffset) st.BackgroundTransparency = 1 st.Text = "Status: Waiting for verification..." st.TextColor3 = Color3.fromRGB(200,200,200) st.Font = Enum.Font.Gotham st.TextSize = 13 st.Parent = ContentContainer
        yOffset = yOffset + 40

        local info = Instance.new("TextLabel") info.Size = UDim2.new(1, 0, 0, 50) info.Position = UDim2.new(0,0,0,yOffset) info.BackgroundTransparency = 1 info.Text = "💡 WETQA高級面板載入成功！\n按下 [ RightShift ] 切換面板顯示。" info.TextColor3 = Color3.fromRGB(150,150,150) info.Font = Enum.Font.Gotham info.TextSize = 12 info.TextXAlignment = Enum.TextXAlignment.Left info.Parent = ContentContainer
        
        btn.MouseButton1Click:Connect(function()
            st.Text = "Checking key..."
            task.wait(0.3)
            if tb.Text ~= "" and script_key and tb.Text == script_key then
                st.TextColor3 = Color3.fromRGB(0,255,120)
                st.Text = "✅ [Verified] WETQA高級面板 啟用成功！"
            else
                st.TextColor3 = Color3.fromRGB(255,80,80)
                st.Text = "❌ Invalid Key or Mismatched!"
            end
        end)

    elseif tabName == "aimbot" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "🎯 WETQA高級面板 - 自瞄與戰鬥" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local b1 = Instance.new("TextButton") b1.Size = UDim2.new(1, 0, 0, 38) b1.Position = UDim2.new(0,0,0,yOffset) b1.BackgroundColor3 = Color3.fromRGB(30,30,42) b1.Text = "  📌 Aimbot (Silent/Legit): [ OFF ]" b1.TextColor3 = Color3.fromRGB(255,255,255) b1.Font = Enum.Font.Gotham b1.TextSize = 13 b1.TextXAlignment = Enum.TextXAlignment.Left b1.Parent = ContentContainer
        local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0,6) c1.Parent = b1
        yOffset = yOffset + 48
        local aimEnabled = false
        b1.MouseButton1Click:Connect(function()
            aimEnabled = not aimEnabled
            b1.Text = aimEnabled and "  📌 Aimbot (Silent/Legit): [ ON ]" or "  📌 Aimbot (Silent/Legit): [ OFF ]"
            b1.BackgroundColor3 = aimEnabled and Color3.fromRGB(0,120,80) or Color3.fromRGB(30,30,42)
        end)

        local b2 = Instance.new("TextButton") b2.Size = UDim2.new(1, 0, 0, 38) b2.Position = UDim2.new(0,0,0,yOffset) b2.BackgroundColor3 = Color3.fromRGB(30,30,42) b2.Text = "  🔥 Ragebot (Void Attack): [ OFF ]" b2.TextColor3 = Color3.fromRGB(255,255,255) b2.Font = Enum.Font.Gotham b2.TextSize = 13 b2.TextXAlignment = Enum.TextXAlignment.Left b2.Parent = ContentContainer
        local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0,6) c2.Parent = b2
        yOffset = yOffset + 48
        local rageEnabled = false
        b2.MouseButton1Click:Connect(function()
            rageEnabled = not rageEnabled
            b2.Text = rageEnabled and "  🔥 Ragebot (Void Attack): [ ON ]" or "  🔥 Ragebot (Void Attack): [ OFF ]"
            b2.BackgroundColor3 = rageEnabled and Color3.fromRGB(180,40,40) or Color3.fromRGB(30,30,42)
        end)
        
        RunService.RenderStepped:Connect(function()
            if aimEnabled then
                local cam = workspace.CurrentCamera
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        cam.CFrame = CFrame.new(cam.CFrame.Position, p.Character.Head.Position)
                        break
                    end
                end
            elseif rageEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local timeTick = tick() * 30
                hrp.Velocity = Vector3.new(math.sin(timeTick) * 200, 100, math.cos(timeTick) * 200)
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
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "👀 WETQA高級面板 - 透視套件" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local b1 = Instance.new("TextButton") b1.Size = UDim2.new(1, 0, 0, 38) b1.Position = UDim2.new(0,0,0,yOffset) b1.BackgroundColor3 = Color3.fromRGB(30,30,42) b1.Text = "  👁️ Chams & Box ESP: [ OFF ]" b1.TextColor3 = Color3.fromRGB(255,255,255) b1.Font = Enum.Font.Gotham b1.TextSize = 13 b1.TextXAlignment = Enum.TextXAlignment.Left b1.Parent = ContentContainer
        local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0,6) c1.Parent = b1
        yOffset = yOffset + 48
        local espOn = false
        b1.MouseButton1Click:Connect(function()
            espOn = not espOn
            b1.Text = espOn and "  👁️ Chams & Box ESP: [ ON ]" or "  👁️ Chams & Box ESP: [ OFF ]"
            b1.BackgroundColor3 = espOn and Color3.fromRGB(0,120,80) or Color3.fromRGB(30,30,42)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if espOn then
                        local hl = Instance.new("Highlight") hl.Name = "WETQA高級面板_ESP" hl.Adornee = p.Character hl.FillColor = Color3.fromRGB(0,255,120) hl.Parent = p.Character
                    else
                        local hl = p.Character:FindFirstChild("WETQA高級面板_ESP") if hl then hl:Destroy() end
                    end
                end
            end
        end)

    elseif tabName == "world" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "🌍 WETQA高級面板 - 世界與天空盒" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local skies = {
            {"🌌 Aurora Night", "rbxassetid://644551720"},
            {"🌠 Galaxy Nebula", "rbxassetid://155091771"},
            {"🌅 Sunset Glow", "rbxassetid://600830600"},
            {"🩸 Blood Moon", "rbxassetid://265541175"}
        }
        
        for _, skyData in ipairs(skies) do
            local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, 0, 0, 38) btn.Position = UDim2.new(0,0,0,yOffset) btn.BackgroundColor3 = Color3.fromRGB(30,30,42) btn.Text = "  " .. skyData[1] btn.TextColor3 = Color3.fromRGB(255,255,255) btn.Font = Enum.Font.Gotham btn.TextSize = 13 btn.TextXAlignment = Enum.TextXAlignment.Left btn.Parent = ContentContainer
            local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,6) sc.Parent = btn
            yOffset = yOffset + 46
            
            btn.MouseButton1Click:Connect(function()
                Lighting.ClockTime = 0 Lighting.Brightness = 2
                for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
                local sky = Instance.new("Sky")
                sky.SkyboxBk = skyData[2] sky.SkyboxDn = skyData[2] sky.SkyboxFt = skyData[2]
                sky.SkyboxLf = skyData[2] sky.SkyboxRt = skyData[2] sky.SkyboxUp = skyData[2]
                sky.Parent = Lighting
            end)
        end

    elseif tabName == "visuals" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "✨ WETQA高級面板 - 視覺與準心" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local chToggle = Instance.new("TextButton") chToggle.Size = UDim2.new(1, 0, 0, 38) chToggle.Position = UDim2.new(0,0,0,yOffset) chToggle.BackgroundColor3 = Color3.fromRGB(30,30,42) chToggle.Text = "  🎯 Circular Crosshair: [ OFF ]" chToggle.TextColor3 = Color3.fromRGB(255,255,255) chToggle.Font = Enum.Font.Gotham chToggle.TextSize = 13 chToggle.TextXAlignment = Enum.TextXAlignment.Left chToggle.Parent = ContentContainer
        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,6) cc.Parent = chToggle
        yOffset = yOffset + 48
        
        local crossGui = player:PlayerGui:FindFirstChild("WETQA高級面板_Crosshair")
        if not crossGui then
            crossGui = Instance.new("ScreenGui") crossGui.Name = "WETQA高級面板_Crosshair" crossGui.Enabled = false crossGui.Parent = player.PlayerGui
            local dot = Instance.new("Frame") dot.Name = "Dot" dot.Size = UDim2.new(0, 10, 0, 10) dot.Position = UDim2.new(0.5, -5, 0.5, -5) dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100) dot.BorderSizePixel = 0 dot.Parent = crossGui
            local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = dot
        end
        
        local crossOn = false
        chToggle.MouseButton1Click:Connect(function()
            crossOn = not crossOn
            crossGui.Enabled = crossOn
            chToggle.Text = crossOn and "  🎯 Circular Crosshair: [ ON ]" or "  🎯 Circular Crosshair: [ OFF ]"
            chToggle.BackgroundColor3 = crossOn and Color3.fromRGB(0,120,80) or Color3.fromRGB(30,30,42)
        end)

        local colBtn = Instance.new("TextButton") colBtn.Size = UDim2.new(1, 0, 0, 38) colBtn.Position = UDim2.new(0,0,0,yOffset) colBtn.BackgroundColor3 = Color3.fromRGB(30,30,42) colBtn.Text = "  🎨 Crosshair Color Switcher" colBtn.TextColor3 = Color3.fromRGB(255,255,255) colBtn.Font = Enum.Font.Gotham colBtn.TextSize = 13 colBtn.TextXAlignment = Enum.TextXAlignment.Left colBtn.Parent = ContentContainer
        local ccc = Instance.new("UICorner") ccc.CornerRadius = UDim.new(0,6) ccc.Parent = colBtn
        yOffset = yOffset + 48
        
        local crossColors = {Color3.fromRGB(0,255,100), Color3.fromRGB(255,50,50), Color3.fromRGB(50,150,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255)}
        local cIdx = 1
        colBtn.MouseButton1Click:Connect(function()
            cIdx = (cIdx % #crossColors) + 1
            local dot = crossGui:FindFirstChild("Dot")
            if dot then dot.BackgroundColor3 = crossColors[cIdx] end
        end)

    elseif tabName == "character" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "⚡ WETQA高級面板 - 角色與移動強化" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35

        local b1 = Instance.new("TextButton") b1.Size = UDim2.new(1, 0, 0, 38) b1.Position = UDim2.new(0,0,0,yOffset) b1.BackgroundColor3 = Color3.fromRGB(30,30,42) b1.Text = "  🚀 WalkSpeed Overclock (100): [ OFF ]" b1.TextColor3 = Color3.fromRGB(255,255,255) b1.Font = Enum.Font.Gotham b1.TextSize = 13 b1.TextXAlignment = Enum.TextXAlignment.Left b1.Parent = ContentContainer
        local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0,6) c1.Parent = b1
        yOffset = yOffset + 48
        local speedOn = false
        b1.MouseButton1Click:Connect(function()
            speedOn = not speedOn
            b1.Text = speedOn and "  🚀 WalkSpeed Overclock (100): [ ON ]" or "  🚀 WalkSpeed Overclock (100): [ OFF ]"
            b1.BackgroundColor3 = speedOn and Color3.fromRGB(0,120,80) or Color3.fromRGB(30,30,42)
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speedOn and 100 or 16 end
        end)

        local b2 = Instance.new("TextButton") b2.Size = UDim2.new(1, 0, 0, 38) b2.Position = UDim2.new(0,0,0,yOffset) b2.BackgroundColor3 = Color3.fromRGB(30,30,42) b2.Text = "  ✈️ Infinite Fly: [ OFF ]" b2.TextColor3 = Color3.fromRGB(255,255,255) b2.Font = Enum.Font.Gotham b2.TextSize = 13 b2.TextXAlignment = Enum.TextXAlignment.Left b2.Parent = ContentContainer
        local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0,6) c2.Parent = b2
        yOffset = yOffset + 48
        local flyOn = false
        b2.MouseButton1Click:Connect(function()
            flyOn = not flyOn
            b2.Text = flyOn and "  ✈️ Infinite Fly: [ ON ]" or "  ✈️ Infinite Fly: [ OFF ]"
            b2.BackgroundColor3 = flyOn and Color3.fromRGB(0,120,80) or Color3.fromRGB(30,30,42)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if flyOn then
                    local bv = Instance.new("BodyVelocity") bv.Name = "WETQA高級面板_Fly" bv.MaxForce = Vector3.new(90000, 90000, 90000) bv.Velocity = Vector3.new(0,0,0) bv.Parent = hrp
                else
                    local bv = hrp:FindFirstChild("WETQA高級面板_Fly") if bv then bv:Destroy() end
                end
            end
        end)

    elseif tabName == "misc" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "⚙️ WETQA高級面板 - 其他工具" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local devLbl = Instance.new("TextLabel") devLbl.Size = UDim2.new(1, 0, 0, 38) devLbl.Position = UDim2.new(0,0,0,yOffset) devLbl.BackgroundColor3 = Color3.fromRGB(30,30,42) devLbl.Text = "  💻 Device Status: PC (Computer)" devLbl.TextColor3 = Color3.fromRGB(255,255,255) devLbl.Font = Enum.Font.Gotham devLbl.TextSize = 13 devLbl.TextXAlignment = Enum.TextXAlignment.Left devLbl.Parent = ContentContainer
        local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0,6) dc.Parent = devLbl
        yOffset = yOffset + 48

    elseif tabName == "settings" then
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, 0, 0, 25) lbl.Position = UDim2.new(0,0,0,yOffset) lbl.BackgroundTransparency = 1 lbl.Text = "🛠️ WETQA高級面板 - 設定與配置" lbl.TextColor3 = Color3.fromRGB(0, 255, 120) lbl.Font = Enum.Font.GothamBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = ContentContainer
        yOffset = yOffset + 35
        
        local saveBtn = Instance.new("TextButton") saveBtn.Size = UDim2.new(1, 0, 0, 38) saveBtn.Position = UDim2.new(0,0,0,yOffset) saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) saveBtn.Text = "  💾 Save Configuration" saveBtn.TextColor3 = Color3.fromRGB(255,255,255) saveBtn.Font = Enum.Font.GothamBold saveBtn.TextSize = 12 saveBtn.TextXAlignment = Enum.TextXAlignment.Left saveBtn.Parent = ContentContainer
        local sbc = Instance.new("UICorner") sbc.CornerRadius = UDim.new(0,6) sbc.Parent = saveBtn
        yOffset = yOffset + 48
        
        local statusConfig = Instance.new("TextLabel") statusConfig.Size = UDim2.new(1, 0, 0, 30) statusConfig.Position = UDim2.new(0,0,0,yOffset) statusConfig.BackgroundTransparency = 1 statusConfig.Text = "Config Status: Not saved yet" statusConfig.TextColor3 = Color3.fromRGB(200,200,200) statusConfig.Font = Enum.Font.Gotham statusConfig.TextSize = 13 statusConfig.Parent = ContentContainer
        yOffset = yOffset + 40

        saveBtn.MouseButton1Click:Connect(function()
            local configData = HttpService:JSONEncode({theme = "WETQA高級面板", activeTime = tick()})
            pcall(function()
                if writefile then
                    writefile(configFolderName .. "/WETQA高級面板_Config.json", configData)
                end
            end)
            statusConfig.TextColor3 = Color3.fromRGB(0,255,120)
            statusConfig.Text = "✅ Config successfully saved!"
        end)

        local clsBtn = Instance.new("TextButton") clsBtn.Size = UDim2.new(1, 0, 0, 38) clsBtn.Position = UDim2.new(0,0,0,yOffset) clsBtn.BackgroundColor3 = Color3.fromRGB(180,50,50) clsBtn.Text = "  ❌ Unload & Close Menu" clsBtn.TextColor3 = Color3.fromRGB(255,255,255) clsBtn.Font = Enum.Font.GothamBold clsBtn.TextSize = 13 clsBtn.TextXAlignment = Enum.TextXAlignment.Left clsBtn.Parent = ContentContainer
        local clc = Instance.new("UICorner") clc.CornerRadius = UDim.new(0,6) clc.Parent = clsBtn
        clsBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    end
end

-- Generate Tab Buttons
for i, name in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1 / #tabs, -4, 1, -4)
    tabBtn.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
    tabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    tabBtn.Text = name:upper()
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.Parent = TabBar
    local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 4) tc.Parent = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function() renderTab(name) end)
end

-- Default Open Main Tab
renderTab("main")
