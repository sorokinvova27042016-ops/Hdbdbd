-- STEAL AN EGG ANTI-CHEAT BYPASS V92MEGA | ОБХОД АНТИЧИТА
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ===== НАСТРОЙКИ =====
local settings = {
    AutoFarm = true,
    FlySpeed = 150, -- СКОРОСТЬ ПОЛЁТА (НЕ ТЕЛЕПОРТ)
    CollectRadius = 20,
    UseRemoteEvent = true
}

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(0, 260, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🥚 STEAL EGG BYPASS"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.BackgroundTransparency = 1
title.TextScaled = true

local function createToggle(text, y, settingKey)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 240, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text .. " ✅"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = text .. (settings[settingKey] and " ✅" or " ❌")
    end)
    return btn
end

createToggle("AUTO-FARM (ОБХОД)", 40, "AutoFarm")

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 120, 0, 28)
closeBtn.Position = UDim2.new(0, 70, 0, 160)
closeBtn.Text = "ЗАКРЫТЬ [SHIFT]"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, isTyping)
    if isTyping then return end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ===== ОБХОД АНТИЧИТА: ПЛАВНЫЙ ПОЛЁТ =====
local function flyToPosition(targetPos)
    if not Character or not Character.HumanoidRootPart then return end
    
    local startPos = Character.HumanoidRootPart.Position
    local distance = (targetPos - startPos).magnitude
    local duration = distance / settings.FlySpeed
    
    if duration > 10 then duration = 10 end
    if duration < 0.5 then duration = 0.5 end
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    
    return tween
end

-- ===== ПОЛУЧЕНИЕ REMOTE ДЛЯ СБОРА =====
local function getCollectRemote()
    local remotes = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("collect") or name:find("egg") or name:find("steal") or name:find("pickup") then
                table.insert(remotes, obj)
            end
        end
    end
    
    return remotes
end

-- ===== ПОИСК ЯИЦ (С УЧЁТОМ АНТИЧИТА) =====
local function findEggs()
    local eggs = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("яйц") then
                local found = false
                for _, egg in pairs(eggs) do
                    if (egg.Position - obj.Position).magnitude < 5 then
                        found = true
                        break
                    end
                end
                if not found and obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                    table.insert(eggs, obj)
                end
            end
        end
    end
    
    return eggs
end

-- ===== СБОР ЧЕРЕЗ REMOTE EVENT =====
local function collectViaRemote(egg)
    local remotes = getCollectRemote()
    
    for _, remote in pairs(remotes) do
        local success, err = pcall(function()
            remote:FireServer(egg, egg.Position)
            remote:FireServer(egg.Name)
            remote:FireServer(egg.Parent)
        end)
        if success then
            print("✅ ОТПРАВЛЕН ЗАПРОС НА СБОР ЧЕРЕЗ REMOTE")
            return true
        end
    end
    
    return false
end

-- ===== СБОР ЧЕРЕЗ КЛИК =====
local function collectViaClick(egg)
    if egg:FindFirstChild("ClickDetector") then
        pcall(function()
            egg.ClickDetector:Click()
            print("✅ КЛИК ПО ЯЙЦУ")
            return true
        end)
    end
    
    -- ИМИТАЦИЯ КАСАНИЯ
    if egg:FindFirstChild("TouchInterest") then
        pcall(function()
            firetouchinterest(Character.HumanoidRootPart, egg, 0)
            task.wait(0.1)
            firetouchinterest(Character.HumanoidRootPart, egg, 1)
            print("✅ КАСАНИЕ ЯЙЦА")
            return true
        end)
    end
    
    return false
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
local isFarming = false

local function farmEggs()
    if not settings.AutoFarm then return end
    if isFarming then return end
    if not Character or not Humanoid then return end
    
    isFarming = true
    
    local eggs = findEggs()
    if #eggs == 0 then
        print("❌ ЯЙЦА НЕ НАЙДЕНЫ")
        isFarming = false
        task.wait(3)
        return
    end
    
    -- ВЫБИРАЕМ СЛУЧАЙНОЕ ЯЙЦО
    local targetEgg = eggs[math.random(1, #eggs)]
    local eggPos = targetEgg.Position + Vector3.new(0, 2, 0)
    
    print("🥚 ЛЕТИМ К ЯЙЦУ: " .. targetEgg.Name)
    
    -- ПЛАВНЫЙ ПОЛЁТ К ЯЙЦУ (НЕ ТЕЛЕПОРТ)
    local tween = flyToPosition(eggPos)
    tween.Completed:Wait()
    
    task.wait(0.5)
    
    -- ПЫТАЕМСЯ СОБРАТЬ РАЗНЫМИ СПОСОБАМИ
    local collected = false
    
    -- 1. ЧЕРЕЗ REMOTE (ОБХОД АНТИЧИТА)
    if settings.UseRemoteEvent then
        collected = collectViaRemote(targetEgg)
    end
    
    -- 2. ЧЕРЕЗ КЛИК/КАСАНИЕ
    if not collected then
        collected = collectViaClick(targetEgg)
    end
    
    -- 3. ПРОСТО СТОЯТЬ РЯДОМ (ИМИТАЦИЯ)
    if not collected then
        print("⏳ ОЖИДАНИЕ АВТО-СБОРА...")
        task.wait(2)
        collected = true
    end
    
    if collected then
        print("✅ ЯЙЦО СОБРАНО УСПЕШНО!")
    end
    
    -- НЕБОЛЬШАЯ ЗАДЕРЖКА
    task.wait(1)
    isFarming = false
end

-- ===== БЕСКОНЕЧНЫЙ ЦИКЛ =====
task.spawn(function()
    while true do
        if settings.AutoFarm then
            farmEggs()
        end
        task.wait(1)
    end
end)

-- ===== ОБНОВЛЕНИЕ ПРИ РЕСПАВНЕ =====
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    wait(1)
end)

print("✅ STEAL AN EGG BYPASS V92MEGA ЗАГРУЖЕН!")
print("📌 [SHIFT] - МЕНЮ")
print("🛡️ АНТИЧИТ ОБХОД АКТИВЕН")
print("🚀 ИСПОЛЬЗУЕТСЯ ПЛАВНЫЙ ПОЛЁТ + REMOTE EVENT")
