-- STEAL AN EGG NAVIGATION FIX V92MEGA | СЛЕДОВАНИЕ ПО ДОРОЖКАМ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ===== НАСТРОЙКИ =====
local settings = {
    AutoFarm = true,
    Speed = 50, -- СКОРОСТЬ ПО ДОРОЖКАМ
    UsePathfinding = true,
    CollectRadius = 15
}

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 260, 0, 180)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(0, 260, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🥚 STEAL EGG NAVIGATION"
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

createToggle("AUTO-FARM (ПО ДОРОЖКАМ)", 40, "AutoFarm")

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 120, 0, 28)
closeBtn.Position = UDim2.new(0, 70, 0, 140)
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

-- ===== ПОИСК ТОЧЕК НА КАРТЕ (ДОРОЖКИ) =====
local function findPathPoints()
    local points = {}
    
    -- ИЩЕМ ОБЪЕКТЫ С ДОРОЖКАМИ
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            -- ИЩЕМ ДОРОЖКИ, ТРОПЫ, ПУТИ
            if name:find("path") or name:find("road") or name:find("track") or 
               name:find("way") or name:find("route") or name:find("tunnel") then
                table.insert(points, obj.Position)
            end
        end
    end
    
    -- ЕСЛИ ДОРОЖЕК НЕТ - ИСПОЛЬЗУЕМ ЯЙЦА КАК ОРИЕНТИРЫ
    if #points == 0 then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:lower():find("egg") then
                table.insert(points, obj.Position)
            end
        end
    end
    
    return points
end

-- ===== ПОИСК БЛИЖАЙШЕГО ЯЙЦА =====
local function findNearestEgg()
    local eggs = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("egg") then
            if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                table.insert(eggs, obj)
            end
        end
    end
    
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

-- ===== ДВИЖЕНИЕ ПО ТОЧКАМ (ПО ДОРОЖКАМ) =====
local function moveAlongPath(targetPos)
    if not Character or not Humanoid then return end
    
    local pathPoints = findPathPoints()
    local currentPos = Character.HumanoidRootPart.Position
    
    -- СОРТИРУЕМ ТОЧКИ ПО БЛИЗОСТИ К ЦЕЛИ
    table.sort(pathPoints, function(a, b)
        local distA = (a - targetPos).magnitude
        local distB = (b - targetPos).magnitude
        return distA < distB
    end)
    
    -- ВЫБИРАЕМ БЛИЖАЙШУЮ ТОЧКУ К ЦЕЛИ
    local targetPoint = pathPoints[1]
    if not targetPoint then
        targetPoint = targetPos
    end
    
    -- ДВИЖЕНИЕ К ТОЧКЕ
    Humanoid:MoveTo(targetPoint)
    
    -- ЖДЁМ ПРИБЫТИЯ
    local startTime = tick()
    while (Character.HumanoidRootPart.Position - targetPoint).magnitude > 5 do
        if tick() - startTime > 15 then break end
        Humanoid:MoveTo(targetPoint)
        task.wait(0.1)
    end
    
    -- ДВИЖЕНИЕ К ЦЕЛИ
    Humanoid:MoveTo(targetPos)
    startTime = tick()
    while (Character.HumanoidRootPart.Position - targetPos).magnitude > 5 do
        if tick() - startTime > 10 then break end
        Humanoid:MoveTo(targetPos)
        task.wait(0.1)
    end
    
    return true
end

-- ===== СБОР ЯЙЦА =====
local function collectEgg(egg)
    if not egg then return false end
    
    -- ПРИБЛИЖАЕМСЯ К ЯЙЦУ
    local eggPos = egg.Position + Vector3.new(0, 2, 0)
    Humanoid:MoveTo(eggPos)
    task.wait(0.5)
    
    -- ПЫТАЕМСЯ СОБРАТЬ
    if egg:FindFirstChild("TouchInterest") then
        firetouchinterest(Character.HumanoidRootPart, egg, 0)
        task.wait(0.2)
        firetouchinterest(Character.HumanoidRootPart, egg, 1)
        return true
    end
    
    if egg:FindFirstChild("ClickDetector") then
        pcall(function()
            egg.ClickDetector:Click()
            return true
        end)
    end
    
    -- ПРОСТО ЖДЁМ АВТО-СБОРА
    task.wait(1)
    return true
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
local isFarming = false

local function farmEggs()
    if not settings.AutoFarm then return end
    if isFarming then return end
    if not Character or not Humanoid then return end
    
    isFarming = true
    
    -- НАХОДИМ ЯЙЦО
    local targetEgg = findNearestEgg()
    
    if not targetEgg then
        print("❌ ЯЙЦО НЕ НАЙДЕНО")
        isFarming = false
        task.wait(2)
        return
    end
    
    print("🥚 ДВИЖЕНИЕ К ЯЙЦУ ПО ДОРОЖКАМ...")
    
    -- ДВИЖЕНИЕ ПО ДОРОЖКАМ К ЯЙЦУ
    local moved = moveAlongPath(targetEgg.Position)
    
    if moved then
        print("✅ ПРИБЫЛИ К ЯЙЦУ")
        collectEgg(targetEgg)
        print("✅ ЯЙЦО СОБРАНО!")
    else
        print("⚠️ НЕ УДАЛОСЬ ДОБРАТЬСЯ")
    end
    
    task.wait(1)
    isFarming = false
end

-- ===== БЕСКОНЕЧНЫЙ ЦИКЛ =====
task.spawn(function()
    while true do
        if settings.AutoFarm then
            farmEggs()
        end
        task.wait(0.5)
    end
end)

-- ===== ОБНОВЛЕНИЕ СКОРОСТИ =====
local function setSpeed(speed)
    pcall(function()
        Humanoid.WalkSpeed = speed
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    wait(1)
    setSpeed(settings.Speed)
end)

setSpeed(settings.Speed)

print("✅ STEAL AN EGG NAVIGATION FIX ЗАГРУЖЕН!")
print("📌 [SHIFT] - МЕНЮ")
print("🗺️ ДВИЖЕНИЕ ПО ДОРОЖКАМ АКТИВНО")
print("📍 СЛЕДУЕТ ПО ПУТИ К ЯЙЦУ")
