-- Скрипт для ServerScriptService
-- Цей скрипт автоматично зменшує розмір персонажа розробників вдвічі
-- та робить їх імунними до пошкоджень

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Список UserId розробників (замініть на реальні ID)
local DEVELOPER_IDS = {
    123456789, -- Замініть на реальні UserId розробників
    987654321,
    -- Додайте інші ID розробників тут
}

-- Функція для перевірки, чи є гравець розробником
local function isDeveloper(player)
    for _, devId in ipairs(DEVELOPER_IDS) do
        if player.UserId == devId then
            return true
        end
    end
    return false
end

-- Функція для масштабування персонажа (включаючи Hitbox)
local function scaleCharacter(character, scaleFactor)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Отримуємо всі частини тіла
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Масштабуємо розмір частини тіла
            part.Size = part.Size * scaleFactor
            
            -- Масштабуємо всі аксесуари та об'єкти на частині тіла
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("SpecialMesh") then
                    child.Scale = child.Scale * scaleFactor
                elseif child:IsA("Weld") or child:IsA("Motor6D") then
                    -- Масштабуємо позиції з'єднань
                    child.C0 = child.C0 * CFrame.new(0, 0, 0) + child.C0.Position * (scaleFactor - 1)
                    child.C1 = child.C1 * CFrame.new(0, 0, 0) + child.C1.Position * (scaleFactor - 1)
                end
            end
        elseif part.Name == "HumanoidRootPart" then
            -- Масштабуємо тільки розмір HumanoidRootPart (не позицію)
            part.Size = part.Size * scaleFactor
        end
    end
    
    -- Масштабуємо швидкість ходьби та стрибка відповідно до нового розміру
    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed * scaleFactor
        humanoid.JumpPower = humanoid.JumpPower * scaleFactor
    end
    
    -- Масштабуємо аксесуари
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                handle.Size = handle.Size * scaleFactor
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.Scale = mesh.Scale * scaleFactor
                end
            end
        end
    end
end

-- Функція для налаштування імунітету до пошкоджень
local function setupImmunity(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Встановлюємо нескінченне здоров'я
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    -- Забороняємо всі небажані стани
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    
    -- Додаткова перевірка на зміну здоров'я
    humanoid.HealthChanged:Connect(function(health)
        if health < math.huge then
            humanoid.Health = math.huge
        end
    end)
    
    -- Блокуємо можливість загибелі
    humanoid.Died:Connect(function()
        wait(0.1)
        humanoid.Health = math.huge
    end)
end

-- Функція для налаштування персонажа розробника
local function setupDeveloperCharacter(character, player)
    -- Чекаємо поки персонаж повністю завантажиться
    character:WaitForChild("Humanoid")
    character:WaitForChild("HumanoidRootPart")
    
    -- Невелика затримка для повного завантаження
    wait(0.5)
    
    print("[DEV MODE] Налаштовуємо персонажа для розробника:", player.Name)
    
    -- Зменшуємо персонажа вдвічі
    scaleCharacter(character, 0.5)
    
    -- Налаштовуємо імунітет до пошкоджень
    setupImmunity(character)
    
    print("[DEV MODE] Персонаж", player.Name, "успішно налаштований!")
end

-- Обробник появи гравця
local function onPlayerAdded(player)
    -- Перевіряємо, чи є гравець розробником
    if not isDeveloper(player) then
        return -- Якщо не розробник, нічого не робимо
    end
    
    print("[DEV MODE] Розробник приєднався:", player.Name, "ID:", player.UserId)
    
    -- Налаштовуємо поточний персонаж (якщо він уже існує)
    if player.Character then
        setupDeveloperCharacter(player.Character, player)
    end
    
    -- Налаштовуємо майбутні персонажі при респавні
    player.CharacterAdded:Connect(function(character)
        setupDeveloperCharacter(character, player)
    end)
end

-- Підключаємо обробник до події появи гравців
Players.PlayerAdded:Connect(onPlayerAdded)

-- Обробляємо гравців, які вже в грі (на випадок, якщо скрипт запускається після їх приєднання)
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

print("[DEV MODE] Скрипт розробника активовано!")
