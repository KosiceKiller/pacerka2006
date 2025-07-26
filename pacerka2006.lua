-- Скрипт для Executor (Client-side)
-- Цей скрипт автоматично застосовує Developer Mode до вашого персонажа

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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
