warn("❌ [EXECUTOR] Не вдалося з-- Скрипт для Executor (Client-side)
-- Цей скрипт автоматично застосовує Developer Mode до вашого персонажа

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Створюємо яскраве повідомлення про успішну ін'єкцію
local function createNotification(title, text, duration)
    duration = duration or 5
    
    -- Створюємо GUI повідомлення
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevModeNotification"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 100)
    frame.Position = UDim2.new(0.5, -200, 0, -120)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Додаємо градієнт
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 100))
    }
    gradient.Parent = frame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.Position = UDim2.new(0, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = frame
    
    -- Анімація появи
    frame:TweenPosition(UDim2.new(0.5, -200, 0, 20), "Out", "Quad", 0.5, true)
    
    -- Видаляємо через час
    game:GetService("Debris"):AddItem(screenGui, duration)
    
    -- Анімація зникнення
    spawn(function()
        wait(duration - 0.5)
        frame:TweenPosition(UDim2.new(0.5, -200, 0, -120), "In", "Quad", 0.5, true)
    end)
end

-- Звуковий сигнал
local function playSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    sound.Volume = 0.5
    sound.Parent = game.Workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Повідомлення про запуск
createNotification("🚀 DEVELOPER MODE", "Скрипт успішно заін'єктився!", 3)
playSound()

print("🚀 [EXECUTOR] Developer Mode активовано!")

-- Список UserId розробників (можна залишити порожнім для автоматичного режиму)
local DEVELOPER_IDS = {
    -- Залишіть порожнім щоб працювати для всіх, або додайте конкретні ID
}

-- Функція для перевірки, чи є гравець розробником
local function isDeveloper(player)
    if #DEVELOPER_IDS == 0 then
        return true -- Якщо список порожній, працює для всіх
    end
    
    for _, devId in ipairs(DEVELOPER_IDS) do
        if player.UserId == devId then
            return true
        end
    end
    return false
end

-- Функція для client-side масштабування
local function scaleCharacter(character, scaleFactor)
    print("🔧 [EXECUTOR] Масштабуємо персонажа:", character.Name)
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Client-side масштабування через NumberValue об'єкти
    local function createOrUpdateValue(name, value)
        local existing = character:FindFirstChild(name)
        if existing then
            existing.Value = value
        else
            local newValue = Instance.new("NumberValue")
            newValue.Name = name
            newValue.Value = value
            newValue.Parent = character
        end
    end
    
    -- Встановлюємо значення масштабування
    createOrUpdateValue("BodyDepthScale", scaleFactor)
    createOrUpdateValue("BodyHeightScale", scaleFactor)
    createOrUpdateValue("BodyWidthScale", scaleFactor)
    createOrUpdateValue("HeadScale", scaleFactor)
    
    -- Додатково масштабуємо швидкості
    wait(0.5) -- Чекаємо застосування масштабу
    
    if humanoid then
        humanoid.WalkSpeed = 16 * scaleFactor
        if humanoid.JumpHeight then
            humanoid.JumpHeight = 7.2 * scaleFactor
        elseif humanoid.JumpPower then
            humanoid.JumpPower = 50 * scaleFactor
        end
    end
    
    print("✅ [EXECUTOR] Масштабування завершено!")
    
    -- Повідомлення про масштабування
    createNotification("📏 МАСШТАБУВАННЯ", "Персонаж зменшено вдвічі!", 3)
end

-- Функція для налаштування локального імунітету (обмежено на client-side)
local function setupClientImmunity(character)
    print("🔧 [EXECUTOR] Налаштовуємо client-side імунітет")
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Встановлюємо високе здоров'я (не math.huge, бо це може не працювати client-side)
    humanoid.MaxHealth = 99999
    humanoid.Health = 99999
    
    -- Забороняємо деякі стани (client-side обмеження)
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    end)
    
    -- Постійно відновлюємо здоров'я
    local healthConnection
    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if health < humanoid.MaxHealth * 0.99 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
    
    -- Очищаємо з'єднання при видаленні персонажа
    character.AncestryChanged:Connect(function()
        if not character.Parent then
            if healthConnection then
                healthConnection:Disconnect()
            end
        end
    end)
    
    print("✅ [EXECUTOR] Client-side імунітет налаштовано!")
    
    -- Повідомлення про імунітет
    createNotification("🛡️ ІМУНІТЕТ", "Захист від пошкоджень активовано!", 3)
end

-- Функція для применения всех настроек
local function applyDeveloperMode(character)
    if not character then return end
    
    -- Чекаємо завантаження персонажа
    local humanoid = character:WaitForChild("Humanoid", 5)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if not humanoid or not rootPart then
        warn("❌ [EXECUTOR] Не вдалося завантажити персонажа!")
        return
    end
    
    -- Невелика затримка для стабільності
    wait(1)
    
    print("🎯 [EXECUTOR] Застосовуємо Developer Mode...")
    
    -- Застосовуємо всі налаштування
    scaleCharacter(character, 0.5) -- Зменшуємо вдвічі
    setupClientImmunity(character)
    
    print("🎉 [EXECUTOR] Developer Mode застосовано успішно!")
    
    -- Фінальне повідомлення про успіх
    createNotification("🎉 ГОТОВО!", "Developer Mode повністю активний!", 4)
    playSound()
end

-- Основна логіка для executor
if LocalPlayer then
    print("👤 [EXECUTOR] Локальний гравець:", LocalPlayer.Name, "ID:", LocalPlayer.UserId)
    
    -- Перевіряємо, чи потрібно застосовувати
    if isDeveloper(LocalPlayer) or #DEVELOPER_IDS == 0 then
        print("✅ [EXECUTOR] Активуємо Developer Mode для поточного гравця")
        
        -- Застосовуємо до поточного персонажа
        if LocalPlayer.Character then
            applyDeveloperMode(LocalPlayer.Character)
        end
        
        -- Застосовуємо до майбутніх персонажів (при респавні)
        LocalPlayer.CharacterAdded:Connect(function(character)
            print("🔄 [EXECUTOR] Новий персонаж - застосовуємо налаштування...")
            applyDeveloperMode(character)
        end)
        
        -- Додаткова перевірка кожні 5 секунд (на випадок збоїв)
        spawn(function()
            while LocalPlayer and LocalPlayer.Parent do
                wait(5)
                if LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health < 50000 then
                        print("🔄 [EXECUTOR] Відновлюємо налаштування...")
                        setupClientImmunity(LocalPlayer.Character)
                    end
                end
            end
        end)
        
    else
        print("❌ [EXECUTOR] Ви не в списку розробників")
        createNotification("❌ ДОСТУП ЗАБОРОНЕНО", "Ви не в списку розробників", 3)
    end
else
    warn("❌ [EXECUTOR] Не вдалося знайти LocalPlayer!")
end

print("🚀 [EXECUTOR] Ініціалізацію завершено!")

-- Додаткові команди для ручного керування (виконайте в консолі executor)
_G.ApplyDevMode = function()
    if LocalPlayer.Character then
        applyDeveloperMode(LocalPlayer.Character)
    end
end

_G.ResetScale = function()
    if LocalPlayer.Character then
        scaleCharacter(LocalPlayer.Character, 1) -- Повертаємо нормальний розмір
    end
end

print("💡 [EXECUTOR] Доступні команди: _G.ApplyDevMode() та _G.ResetScale()")
