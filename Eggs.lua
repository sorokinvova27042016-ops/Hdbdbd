-- STEAL AN EGG WORKING AUTO-FARM V92MEGA | РАБОЧАЯ ВЕРСИЯ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")

-- ===== НАСТРОЙКИ =====
local settings = {
    AutoFarm = true,
    Speed = 67000,
    TeleportToEgg = true,
    CollectDelay = 0.5
}

-- ===== GUI МЕНЮ =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(0, 260, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🥚 STEAL EGG V92MEGA"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.BackgroundTransparency = 1
title.TextScaled = true

local function createToggle(text, y, settingKey)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 240, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text .. " ✅"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = text .. (settings[settingKey] and " ✅" or " ❌")
    end)
    return btn
end

createToggle("AUTO-FARM", 40, "AutoFarm")
createToggle("ТЕЛЕПОРТ К ЯЙЦУ", 75, "TeleportToEgg")

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

-- ===== УСТАНОВКА СКОРОСТИ =====
local function setSpeed(speed)
    pcall(function()
        Humanoid.WalkSpeed = speed
    end)
end

-- ===== ПОИСК ВСЕХ ЯИЦ НА КАРТЕ =====
local function findAllEggs()
    local eggs = {}
    
    -- ПОИСК ПО ВСЕМ ОБЪЕКТАМ
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            -- ПРОВЕРЯЕМ НАЗВАНИЕ
            if name:find("egg") or name:find("яйц") or name:find("steal") then
                -- ПРОВЕРЯЕМ, ЧТО ЭТО НЕ ИГРОК
                if not obj.Parent:IsA("Model") or not obj.Parent:FindFirstChild("Humanoid") then
                    table.insert(eggs, obj)
                end
            end
        end
    end
    
    return eggs
end

-- ===== ПОИСК БЛИЖАЙШЕГО ЯЙЦА =====
local function findNearestEgg()
    local eggs = findAllEggs()
    if #eggs == 0 then return nil end
    
    local rootPos = Character.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = math.huge
    
    for _, egg in pairs(eggs) do
        local dist = (egg.Position - rootPos).magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = egg
        end
    end
    
    return nearest
end

-- ===== ТЕЛЕПОРТ К ЯЙЦУ =====
local function teleportToEgg(egg)
    if not egg then return end
    if not Character or not Character.HumanoidRootPart then return end
    
    local eggPos = egg.Position + Vector3.new(0, 3, 0) -- НЕМНОГО ВЫШЕ
    Character.HumanoidRootPart.CFrame = CFrame.new(eggPos)
    task.wait(0.1)
end

-- ===== СБОР ЯЙЦА =====
local function collectEgg(egg)
    if not egg then return false end
    
    -- МЕТОД 1: ЧЕРЕЗ TOUCH
    if egg:FindFirstChild("TouchInterest") then
        firetouchinterest(Character.HumanoidRootPart, egg, 0)
        task.wait(0.2)
        firetouchinterest(Character.HumanoidRootPart, egg, 1)
        return true
    end
    
    -- МЕТОД 2: ЧЕРЕЗ CLICK DETECTOR
    local clickDetector = egg:FindFirstChild("ClickDetector")
    if clickDetector then
        clickDetector:Click()
        return true
    end
    
    -- МЕТОД 3: ПРОСТО ПРИБЛИЗИТЬСЯ
    local oldPos = Character.HumanoidRootPart.Position
    Character.HumanoidRootPart.CFrame = CFrame.new(egg.Position + Vector3.new(0, 2, 0))
    task.wait(0.5)
    Character.HumanoidRootPart.CFrame = CFrame.new(oldPos)
    
    return true
end

-- ===== ОСНОВНОЙ ЦИКЛ ФАРМА =====
local isFarming = false

local function farmEgg()
    if not settings.AutoFarm then return end
    if isFarming then return end
    if not Character or not Humanoid then return end
    
    isFarming = true
    
    -- УСТАНАВЛИВАЕМ СКОРОСТЬ
    setSpeed(settings.Speed)
    
    -- НАХОДИМ ЯЙЦО
    local targetEgg = findNearestEgg()
    
    if not targetEgg then
        print("❌ ЯЙЦО НЕ НАЙДЕНО, ЖДЁМ...")
        isFarming = false
        task.wait(2)
        return
    end
    
    print("🥚 НАЙДЕНО ЯЙЦО: " .. targetEgg.Name)
    
    -- ТЕЛЕПОРТИРУЕМСЯ К ЯЙЦУ
    if settings.TeleportToEgg then
        teleportToEgg(targetEgg)
    end
    
    -- СОБИРАЕМ ЯЙЦО
    local success = collectEgg(targetEgg)
    
    if success then
        print("✅ ЯЙЦО СОБРАНО!")
    else
        print("⚠️ ЯЙЦО НЕ УДАЛОСЬ СОБРАТЬ, ПРОБУЕМ СНОВА...")
    end
    
    task.wait(settings.CollectDelay)
    isFarming = false
end

-- ===== БЕСКОНЕЧНЫЙ ЦИКЛ =====
task.spawn(function()
    while true do
        if settings.AutoFarm then
            farmEgg()
        end
        task.wait(0.5)
    end
end)

-- ===== ПЕРЕЗАПУСК ПРИ РЕСПАВНЕ =====
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    wait(1)
    setSpeed(settings.Speed)
    print("🔄 ПЕРСОНАЖ ПЕРЕЗАГРУЖЕН")
end)

-- ===== ОТЛАДКА =====
print("✅ STEAL AN EGG WORKING V92MEGA ЗАГРУЖЕН!")
print("📌 [SHIFT] - МЕНЮ")
print("🥚 ПОИСК ЯИЦ АКТИВЕН")
print("🚀 СКОРОСТЬ 67K УСТАНОВЛЕНА")
print("📊 КОЛИЧЕСТВО НАЙДЕННЫХ ЯИЦ: " .. #findAllEggs())
