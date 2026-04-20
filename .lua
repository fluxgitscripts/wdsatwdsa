local function print() end
local function warn() end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

if not player.Character then
    player.CharacterAdded:Wait()
end

local vehiclesFolder = workspace:WaitForChild("Vehicles")

local vehicle = vehiclesFolder:FindFirstChild(player.Name)
while not vehicle do
    vehiclesFolder.ChildAdded:Wait()
    vehicle = vehiclesFolder:FindFirstChild(player.Name)
end
task.wait(2)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService('VirtualUser')

local ConfigFile = "VantaScriptsConfig1.lua"
local DefaultConfig = {
    detectionRange = 60,
    saveMoneyBeforeRejoin = true,
    moneyToSaveValue = 100000,
    vehicleMinSpeed = 140,
    jewelerExtraRobSelection = {"Diamond", "Jewelry"},
    robberySelection = {"Bank", "Club", "Jewellery", "GasnGo", "Container 1", "Container 2", "Container 3", "Container 4", "Ares Fuel", "Tool Shop", "Farm Shop", "Osso Fuel", "Clothing Store"},
    vendingRobbery = false,
    vendingPriority = "After Main Robberys",
    rejoinWhenDead = true,
    rejoinWhenKicked = true,
    autoSell = true,
    autoServerChanger = true,
    lockCameraWhenInCar = true,
    useConfig = true
}

local CurrentConfig = {}
for k, v in pairs(DefaultConfig) do CurrentConfig[k] = v end

_G.lockbypassdrawing = false
_G.criminalappdrawing = false

local function SerializeTable(tbl)
    local function serialize(val)
        if type(val) == "string" then
            return string.format("%q", val)
        elseif type(val) == "table" then
            local res = "{"
            for k, v in pairs(val) do
                local key = type(k) == "string" and string.format("[%q]", k) or string.format("[%d]", k)
                res = res .. key .. " = " .. serialize(v) .. ", "
            end
            return res .. "}"
        else
            return tostring(val)
        end
    end
    return "return " .. serialize(tbl)
end

local function SaveConfig(force)
    if writefile then
        if not force and not CurrentConfig.useConfig then return end
        pcall(function()
            writefile(ConfigFile, SerializeTable(CurrentConfig))
        end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        local success, chunk = pcall(function() return loadfile(ConfigFile) end)
        if success and type(chunk) == "function" then
            local data = chunk()
            if data and type(data) == "table" then
                if data.useConfig ~= nil then
                    CurrentConfig.useConfig = data.useConfig
                end
                
                if CurrentConfig.useConfig then
                    for k, v in pairs(data) do
                        if DefaultConfig[k] ~= nil then
                            CurrentConfig[k] = v
                        end
                    end
                end
            end
        end
    end
end

LoadConfig()
local VirtualInputManager = game:GetService("VirtualInputManager")
local function clickAtCoordinates(scaleX, scaleY, duration)
    local camera = Workspace.CurrentCamera
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    local absoluteX = screenWidth * scaleX
    local absoluteY = screenHeight * scaleY

    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)

    if duration and duration > 0 then
        task.wait(duration)
    end

    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0)
end

clickAtCoordinates(0.5, 0.9)

    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local function isPlayerStaff(player)
        if player.UserId == game.CreatorId then
            return true
        end
        
        if game.CreatorType == Enum.CreatorType.Group then
            local success, rank = pcall(function()
                return player:GetRankInGroup(game.CreatorId)
            end)
            if success and rank >= 250 then
                return true
            end
        end
        
        return false
    end

local camstop = false
local TweenService = game:GetService("TweenService")
local isFirstGasMove = true
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local RobberyZoomValue = 10
local CurrentBombs = 0
_G.ossoVisitedOnce = false
_G.lockHeightTo7 = false

local kickDetectionActive = true
local hasTriggeredHop = false

local emergencyServerId = nil
local emergencyServerPlaceId = game.PlaceId
_G.lastKnownDealerCFrame = nil

local parkingBrakeColorFrame = nil

local function createDebugMenu()
end

local function addDebugLog(message, color)
end

local function updateTolerance(current, max)
end

local function updatePKeyStatus(isPressed)
end

local PARKING_BRAKE_DISPLAY_ORDER = 28

local function checkPrisonerAndWait()
    local team = LocalPlayer.Team
    if team and team.Name == "Prisoner" then

        while LocalPlayer.Team and LocalPlayer.Team.Name == "Prisoner" do
            LocalPlayer:GetPropertyChangedSignal("Team"):Wait()
            task.wait(1)
        end
        
        task.wait(2)
    end
end

checkPrisonerAndWait()

local function findParkingBrakeFrame()
    if parkingBrakeColorFrame then return parkingBrakeColorFrame end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local targetScreenGui = nil
    for _, child in ipairs(playerGui:GetChildren()) do
        if child:IsA("ScreenGui") and child.DisplayOrder == PARKING_BRAKE_DISPLAY_ORDER then
            targetScreenGui = child
            break
        end
    end
    
    if not targetScreenGui then
        local errorMsg = "DisplayOrder " .. PARKING_BRAKE_DISPLAY_ORDER .. " ScreenGui not found"
        return nil
    end
    
    local frameContainer = nil
    for _, child in ipairs(targetScreenGui:GetChildren()) do
        if child:IsA("Frame") then
            frameContainer = child
            break
        end
    end
    
    if not frameContainer then
        local errorMsg = "No Frame found inside ScreenGui"
        return nil
    end
    
    local parkingBrakeFrame = frameContainer:FindFirstChild("ParkingBrake")
    if not parkingBrakeFrame or not parkingBrakeFrame:IsA("Frame") then
        local errorMsg = "ParkingBrake Frame not found"
        return nil
    end
    
    local frame1 = parkingBrakeFrame:FindFirstChild("1")
    if not frame1 or not frame1:IsA("Frame") then
        return nil
    end
    
    local frame2 = frame1:FindFirstChild("2")
    if not frame2 or not frame2:IsA("Frame") then
        return nil
    end
    
    parkingBrakeColorFrame = frame2
    
    local framePath = "ScreenGui[DisplayOrder=" .. PARKING_BRAKE_DISPLAY_ORDER .. "] -> Frame -> ParkingBrake -> 1 -> 2"
    
    return parkingBrakeColorFrame
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not parkingBrakeColorFrame then
        findParkingBrakeFrame()
    end
end)

if LocalPlayer.Character then
    task.spawn(function()
        task.wait(1)
        findParkingBrakeFrame()
    end)
end

local emergencyServerLastUpdate = 0

local function findEmergencyServer()
    local HttpService = game:GetService("HttpService")
    local placeId = game.PlaceId
    
    local success, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)
    
    if success and response then
        local body = HttpService:JSONDecode(response)
        if body and body.data then
            local servers = {}
            for _, v in ipairs(body.data) do
                if type(v) == "table" and v.id and v.id ~= game.JobId then
                    local playing = tonumber(v.playing) or 0
                    local maxPlayers = tonumber(v.maxPlayers) or 0
                    
                    if playing < 35 and playing < maxPlayers then
                        table.insert(servers, v.id)
                    end
                end
            end
            
            if #servers > 0 then
                emergencyServerId = servers[math.random(1, #servers)]
                emergencyServerPlaceId = placeId
                emergencyServerLastUpdate = tick()
                )
                return true
            end
        end
    end
    
    return false
end

task.spawn(function()
    while true do
        local success, result = pcall(findEmergencyServer)
        if success and result then

            task.wait(60)
        else

            task.wait(5)
        end
    end
end)

local function emergencyServerHop()
    if hasTriggeredHop then return end
    hasTriggeredHop = true
    
    local TeleportService = game:GetService("TeleportService")

    if not emergencyServerId then
        findEmergencyServer()
    end
    
    if emergencyServerId then
        )
        
        pcall(function()
            if queue_on_teleport then
                queue_on_teleport(getgenv().RejoinScript)
            end
        end)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(emergencyServerPlaceId, emergencyServerId, LocalPlayer)
        end)
        
        if not success then
            )
            hasTriggeredHop = false 
        end
    else
        no server found matching criteria, cannot hop!")
        hasTriggeredHop = false
    end
end

local LocationCoordinates = {
    Bank = CFrame.new(-1366.52893, 3.77958393, 3018.23291, 0.999665797, 0.02563053, -0.00337082823, -0.0256738216, 0.999579251, -0.0134970928, 0.00302347238, 0.0135791246, 0.999903202),
    Gasngo = CFrame.new(-1366.52893, 3.77958393, 3018.23291, 0.999665797, 0.02563053, -0.00337082823, -0.0256738216, 0.999579251, -0.0134970928, 0.00302347238, 0.0135791246, 0.999903202),
    Jewellery = CFrame.new(-1366.52893, 3.77958393, 3018.23291, 0.999665797, 0.02563053, -0.00337082823, -0.0256738216, 0.999579251, -0.0134970928, 0.00302347238, 0.0135791246, 0.999903202),
    Containerone = CFrame.new(884.397522, 7.29635715, 2237.14722, -0.0124400863, 4.35332549e-06, -0.999922633, 0.000363848143, 0.99999994, -1.72990525e-07, 0.999922574, -0.000363822153, -0.0124400873),
    Containertwo = CFrame.new(884.397522, 7.29635715, 2237.14722, -0.0124400863, 4.35332549e-06, -0.999922633, 0.000363848143, 0.99999994, -1.72990525e-07, 0.999922574, -0.000363822153, -0.0124400873),
    Containerthree = CFrame.new(884.397522, 7.29635715, 2237.14722, -0.0124400863, 4.35332549e-06, -0.999922633, 0.000363848143, 0.99999994, -1.72990525e-07, 0.999922574, -0.000363822153, -0.0124400873),
    Containerfour = CFrame.new(884.397522, 7.29635715, 2237.14722, -0.0124400863, 4.35332549e-06, -0.999922633, 0.000363848143, 0.99999994, -1.72990525e-07, 0.999922574, -0.000363822153, -0.0124400873),
    Ares = CFrame.new(-843.817322, 6.44403267, 1256.11328, -0.014433668, -0.0142262159, 0.999794602, 0.0288901459, 0.99947542, 0.0146387508, -0.9994784, 0.0290955026, -0.0140150981),
    Oso = CFrame.new(-322.424042, 6.99261236, -1584.25049, -0.997829378, 0.0273925308, -0.0598849133, 0.0266063921, 0.999549568, 0.0138858287, 0.0602383055, 0.0122623667, -0.998108685)
}

local gasregion = LocationCoordinates.Gasngo
local contaregion = LocationCoordinates.Containerone
local aresregion = LocationCoordinates.Ares
local ossoregionDirect = LocationCoordinates.Oso
local ossoregion = {
    CFrame.new(-1078.37268, 7.3514061, 1199.69238, 0.997234821, -0.0692884922, -0.0268670768, 0.0696833208, 0.99747026, 0.0140478183, 0.0258257575, -0.0158811603, 0.999540329),
    CFrame.new(-1082.69312, 6.96492767, -1596.67273, 0.0677127764, 0.0121059511, -0.997631431, 0.0231458489, 0.9996382, 0.0137012936, 0.997436345, -0.0240187775, 0.0674080774),
    ossoregionDirect
}
local waitPosition = CFrame.new(-496.833862, 6.98107767, -1843.70667, -0.316065758, 0.0200893749, -0.948524594, 0.0243739691, 0.999617755, 0.0130496556, 0.94842416, -0.0189947598, -0.316434592)
local ProximityPromptTimeBet = 2.5
local locktime = 200
local dedectdistance = 55
local healthdecrease = 10
local minMoneyToSell = 100000

function sellAllItems()
    local closestDealer = findNearestDealer()
    local targetCF = closestDealer and closestDealer.Head.CFrame or _G.lastKnownDealerCFrame

    if targetCF then 
        frameTween(targetCF + Vector3.new(0, -2, 0))
        task.wait(0.5)
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local dealerY = targetCF.Position.Y
            local orientation = char.HumanoidRootPart.Orientation
            char.HumanoidRootPart.CFrame = CFrame.new(pos.X, dealerY, pos.Z) * CFrame.Angles(
                math.rad(orientation.X),
                math.rad(orientation.Y),
                math.rad(orientation.Z)
            )
        end
        
        local itemsToSell = {"Gold", "M58B Shotgun", "MP5", "Glock 17", "Machete", "Bomb"}
        for _, item in ipairs(itemsToSell) do
            local sellArgs = {
                [1] = item,
                [2] = "Dealer"
            }
            RemoteEvents.SellItem:FireServer(unpack(sellArgs))
            task.wait(0.1)
        end
        
        return true
    end
    
    return false
end

local RemoteEvents = {
    RobEvent = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("274b3bb0-ebe4-45f2-8664-22db4ef7a7b7"),
    BombEquip = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("4766e04c-1184-445b-9efa-4d04c1bae5a0"),
    FireBomb = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("aa42decc-a9f2-4ac7-9453-1f3972735e45"),
    BuyItem = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("b61c7b35-37db-4d78-84d1-d1444dba28f1"),
    SellItem = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("d3d9d96f-87d4-469d-a9b4-36964827a747"),
    CollectMoney = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("274b3bb0-ebe4-45f2-8664-22db4ef7a7b7"),
    GetPhone = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("4766e04c-1184-445b-9efa-4d04c1bae5a0"),
    ClosePhone = game:GetService("ReplicatedStorage"):WaitForChild("6Dg"):WaitForChild("3cf94f57-d9ef-420d-9595-398856c22830"),
}
local MONEY_COLLECT_CODE = "Az0"
local GOLD_COLLECT_CODE = "5q0"
local CASH_COLLECT_CODE = "51q"
local VENDING_COLLECT_CODE = "zEb"
local BOMB_GUI_DISPLAY_ORDER = nil

local function findBombGuiDisplayOrder()

    if BOMB_GUI_DISPLAY_ORDER then return BOMB_GUI_DISPLAY_ORDER end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("ImageLabel") and descendant.Image == "rbxassetid://81957721494606" then

            local p1 = descendant.Parent
            local p2 = p1 and p1.Parent
            local p3 = p2 and p2.Parent
            local p4 = p3 and p3.Parent
            local p5 = p4 and p4.Parent
            
            if p5 and p5:IsA("ScreenGui") then
                BOMB_GUI_DISPLAY_ORDER = p5.DisplayOrder
                )
                return BOMB_GUI_DISPLAY_ORDER
            end
        end
    end
    return nil
end

local LOCK_SCREEN_DISPLAY_ORDER = 37

local function bypassLockScreen()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local searchStartTime = tick()
    local searchDuration = 15
    local targetButton = nil
    local checkCount = 0
    
    while (tick() - searchStartTime) < searchDuration and not targetButton do
        checkCount = checkCount + 1
        local targetScreenGui = nil
        
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.DisplayOrder == LOCK_SCREEN_DISPLAY_ORDER then
                targetScreenGui = child
                break
            end
        end
        
        if not targetScreenGui then
            for _, child in ipairs(playerGui:GetChildren()) do
                if child:IsA("ScreenGui") then
                    local hasFrame = false
                    for _, subChild in ipairs(child:GetChildren()) do
                        if subChild:IsA("Frame") then
                            hasFrame = true
                            break
                        end
                    end
                    if hasFrame then
                        targetScreenGui = child
                        .. ")")
                        break
                    end
                end
            end
        end
        
        if targetScreenGui then
            local targetFrame = nil
            for _, child in ipairs(targetScreenGui:GetChildren()) do
                if child:IsA("Frame") then
                    targetFrame = child
                    break
                end
            end
            
            if targetFrame then
                local allButtons = {}
                for _, child in ipairs(targetFrame:GetDescendants()) do
                    if child:IsA("ImageButton") then
                        table.insert(allButtons, child)
                    end
                end
                
                if #allButtons == 0 then
                    for _, child in ipairs(targetFrame:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("GuiButton") then
                            table.insert(allButtons, child)
                        end
                    end
                end
                
                if #allButtons > 0 then
                    targetButton = allButtons[#allButtons]
                    .. ")")
                    break
                else
                    if checkCount % 10 == 0 then
                        )
                    end
                end
            else
                if checkCount % 10 == 0 then
                    )
                end
            end
        else
            if checkCount % 10 == 0 then
                local screenGuiCount = 0
                for _, child in ipairs(playerGui:GetChildren()) do
                    if child:IsA("ScreenGui") then
                        screenGuiCount = screenGuiCount + 1
                    end
                end
                end
        end
        
        if not targetButton then
            local elapsed = tick() - searchStartTime
            if checkCount % 10 == 0 then
                .. "s / " .. searchDuration .. "s, Kontrol #" .. checkCount .. ")")
            end
            task.wait(0.5)
        end
    end
    
    if not targetButton then
        ")
        return
    end
    
    local targetScreenGui = nil
    for _, child in ipairs(playerGui:GetChildren()) do
        if child:IsA("ScreenGui") and child.DisplayOrder == LOCK_SCREEN_DISPLAY_ORDER then
            targetScreenGui = child
            break
        end
    end
    
    if not targetScreenGui then return end
    
    local buttonPos = targetButton.AbsolutePosition
    local buttonSize = targetButton.AbsoluteSize
    local centerX = math.floor(buttonPos.X + buttonSize.X / 2)
    local centerY = math.floor(buttonPos.Y + buttonSize.Y / 2)

    local box
    if _G.lockbypassdrawing then
        box = Drawing.new("Square")
        box.Position = Vector2.new(buttonPos.X, buttonPos.Y)
        box.Size = Vector2.new(buttonSize.X, buttonSize.Y)
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Filled = false
        box.Thickness = 3
        box.Visible = true
    end

    local points = {}
    for i = 0, 20 do
        local targetX = centerX
        local targetY = centerY + (i * 10)
        local pointData = {Position = Vector2.new(targetX, targetY)}

        if _G.lockbypassdrawing then
            local point = Drawing.new("Circle")
            point.Position = pointData.Position
            point.Radius = 6
            point.Color = Color3.fromRGB(0, 255, 0)
            point.Filled = true
            point.Visible = true
            pointData.Drawing = point
        end
        table.insert(points, pointData)
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")

    for i, pData in ipairs(points) do
        if not targetScreenGui.Enabled then
            if box then box:Destroy() end
            for _, p in ipairs(points) do if p.Drawing then p.Drawing:Destroy() end end
            return
        end
        
        VirtualInputManager:SendMouseButtonEvent(pData.Position.X, pData.Position.Y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(pData.Position.X, pData.Position.Y, 0, false, game, 0)
        task.wait(0.02)
    end

    if box then box:Destroy() end
    for _, p in ipairs(points) do if p.Drawing then p.Drawing:Destroy() end end
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    task.wait(1)
    bypassLockScreen()
end)

local healthTracking = {
    lastHealth = 100,
    damagedLocation = nil
}

local isRespawning = false
local isHeaderRunning = false

function checkHealthAndReset()
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") and not isRespawning then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid.Health < 25 then
            isRespawning = true
            isHeaderRunning = false
            humanoid.Jump = true
            humanoid.Health = 0
            humanoid:BreakJoints()
            
            local connection
            connection = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(3)
                isRespawning = false
                connection:Disconnect()
                task.spawn(header)
            end)
            
            return true
        end
    end
    return false
end

local CurrentBombs = 0
local BombCheckInterval = 0.5

local function getBombCount()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = nil
    local bombCount = 0

    if not BOMB_GUI_DISPLAY_ORDER then
        BOMB_GUI_DISPLAY_ORDER = findBombGuiDisplayOrder()
        if not BOMB_GUI_DISPLAY_ORDER then return 0 end
    end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.DisplayOrder == BOMB_GUI_DISPLAY_ORDER then
            screenGui = gui
            break
        end
    end

    if not screenGui then
        return 0
    end

    for _, descendant in ipairs(screenGui:GetDescendants()) do
        if descendant:IsA("ImageLabel") and descendant.Image == "rbxassetid://132706206999660" then
            local parent = descendant.Parent
            if parent then
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextLabel") then
                        local number = tonumber(child.Text)
                        if number then
                            bombCount = number
                            break
                        end
                    end
                end
            end
        end
    end

    return bombCount
end

local function startBombChecker()
    task.spawn(function()
        while true do
            local newBombCount = getBombCount()
            if newBombCount ~= CurrentBombs then
                CurrentBombs = newBombCount
            end
            task.wait(0.5)
        end
    end)
end

startBombChecker()

function getMoneyAmount()
    local success, result = pcall(function()
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
        
        local moneyGui = nil
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.DisplayOrder == 29 then
                moneyGui = gui
                break
            end
        end
        
        if not moneyGui then
            return 0
        end
        
        local descendants = moneyGui:GetDescendants()
        
        for _, descendant in ipairs(descendants) do
            if descendant:IsA("TextLabel") and descendant.Name == "3" then
                local parent = descendant.Parent
                if parent and parent.Name == "4" and parent:IsA("Frame") then
                    local grandParent = parent.Parent
                    if grandParent and grandParent.Name == "4" and grandParent:IsA("Frame") then
                        local greatGrandParent = grandParent.Parent
                        if greatGrandParent and greatGrandParent.Name == "3" and greatGrandParent:IsA("ImageLabel") then
                            local moneyText = descendant.Text

                            local cleaned = moneyText:gsub("", ""):gsub("%s+", "")
                            local numericPart = cleaned:match("([^%.]+)")
                            local value = (tonumber(numericPart) or 0) * 1000
                            
                            :", value)
                            return value or 0
                        end
                    end
                end
            end
        end
        
        return 0
    end)
    
    if not success then
        )
        return 0
    end
    
    return result
end

function hopServer()
    if _G.saveMoneyBeforeRejoin then
        runSaveMoneySequence()
    end

    if not emergencyServerId then
        findEmergencyServer()
    end
    
    if emergencyServerId then
        )
        
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId

        pcall(function()
            if queue_on_teleport then
                queue_on_teleport(getgenv().RejoinScript)
            end
        end)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, emergencyServerId, LocalPlayer)
        end)
        
        if not success then
            )

            emergencyServerId = nil
        end
    else
        no fresh server found! Trying alternative method...")

        local success, response = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
        end)
        
        if success and response then
            local body = game:GetService("HttpService"):JSONDecode(response)
            if body and body.data then
                local servers = {}
                for _, v in ipairs(body.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, v.id)
                    end
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                    return
                end
            end
        end
        end
end

function detectPolice(robberyType)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    
    local currentHealth = humanoid.Health
    
    if currentHealth <= 25 and (_G.rejoinWhenDead == nil or _G.rejoinWhenDead == true) then
        .. " (25 or below). Server hopping...")
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Low Health",
            Text = "Server hopping..."
        })
        hopServer()
        return true
    end
    
    if healthTracking.damagedLocation ~= nil and healthTracking.damagedLocation ~= robberyType then
        healthTracking.lastHealth = currentHealth
        healthTracking.damagedLocation = nil
    end
    
    local healthLoss = healthTracking.lastHealth - currentHealth
    
    if healthLoss >= healthdecrease then
        .. ". Stopping robbery.")
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Health Decreased",
            Text = "Passing the place"
        })
        lockRobbery(robberyType)
        
        healthTracking.damagedLocation = robberyType
        
        if robberyType == "Club" or robberyType == "Bank" or robberyType == "Gasngo" or robberyType == "Jewellery" then
            frameTween(gasregion)
        elseif robberyType == "Containerone" or robberyType == "Containertwo" or robberyType == "Containerthree" or robberyType == "Containerfour" then
            frameTween(contaregion)
        elseif robberyType == "Ares" or robberyType == "Tool" then
            frameTween(aresregion)
        elseif robberyType == "Farm" or robberyType == "Clothing" then
            frameTween(ossoregionDirect)
        elseif robberyType == "Oso" then
            frameTween(ossoregionDirect)
        end
        
        return true
    end
    
    healthTracking.lastHealth = currentHealth
    
    local rootPart = character.HumanoidRootPart
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Team and player.Team.Name == "Police" then
                local playerCharacter = player.Character
                if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                    local distance = (playerCharacter.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    if distance <= dedectdistance then
                        .. " studs. Stopping robbery.")
                        game:GetService("StarterGui"):SetCore("SendNotification",{
                            Title = "Police Dedected",
                            Text = "Passing the place"
                        })
                        lockRobbery(robberyType)
                        
                        if robberyType == "Club" or robberyType == "Bank" or robberyType == "Gasngo" or robberyType == "Jewellery" then
                            frameTween(gasregion)

                        elseif robberyType=="Containerone"
                            or robberyType=="Containertwo"
                            or robberyType=="Containerthree"
                            or robberyType=="Containerfour" then
                            frameTween(contaregion)

                        elseif robberyType == "Ares" or robberyType == "Tool" then
                            frameTween(aresregion)
                        elseif robberyType == "Farm" or robberyType == "Clothing" then
                            frameTween(ossoregionDirect)
                        elseif robberyType == "Oso" then
                            returnFromOso()
                        end
                        
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function lockRobbery(robberyType)
    if robberyType == "Club" then
        clublock = true
        clubLockTime = os.time()
        elseif robberyType == "Bank" then
        banklock = true
        bankLockTime = os.time()
        elseif robberyType == "Jewellery" then
        jewellerylock = true
        jewelleryLockTime = os.time()
        elseif robberyType == "Gasngo" then
        gasngolock = true
        gasngoLockTime = os.time()
        elseif robberyType == "Containerone" then
        containeronelock = true
        containeroneLockTime = os.time()
        elseif robberyType == "Containertwo" then
        containertwolock = true
        containertwoLockTime = os.time()
        elseif robberyType == "Containerthree" then
        containerthreelock = true
        containerthreeLockTime = os.time()
        elseif robberyType == "Containerfour" then
        containerfourlock = true
        containerfourLockTime = os.time()
        elseif robberyType == "Tool" then
        toollock = true
        toolLockTime = os.time()
        elseif robberyType == "Clothing" then
        clothinglock = true
        clothingLockTime = os.time()
        elseif robberyType == "Ares" then
        areslock = true
        aresLockTime = os.time()
        elseif robberyType == "Farm" then
        farmlock = true
        farmLockTime = os.time()
        elseif robberyType == "Oso" then
        osolock = true
        osoLockTime = os.time()
        end
end

function header()
    if isRespawning then
        return
    end
    
    isHeaderRunning = true
    local dealer = findNearestDealer()
    
    if not dealer then
        frameTween(gasregion)
        task.wait(0.5)
        
        dealer = findNearestDealer()
        
        if not dealer then
            frameTween(contaregion)
            task.wait(0.5)
            
            dealer = findNearestDealer()
            
            if not dealer then
                hopServer()
                return
            end
        end
    end
    
    if CurrentBombs < 3 then
        , dealer'a gidiliyor...")
        frameTween(dealer.Head.CFrame)
        buyBombAndSell(3 - CurrentBombs)
        task.wait(0.5)
    else
        , starting robbery loop...")
    end
    
    startRobberyCycle()
end

function updateHealthTracking()
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        healthTracking.lastHealth = character:FindFirstChildOfClass("Humanoid").Health
    end
end

function findNearestDealer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = character.HumanoidRootPart
    local dealersFolder = workspace:FindFirstChild("Dealers")
    if not dealersFolder then
        return nil
    end
    
    local closestDealer = nil
    local shortestDistance = math.huge
    
    for _, dealer in ipairs(dealersFolder:GetChildren()) do
        if dealer:IsA("Model") and dealer:FindFirstChild("Head") then
            local distance = (dealer.Head.Position - rootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestDealer = dealer
            end
        end
    end
    
    if closestDealer then
        _G.lastKnownDealerCFrame = closestDealer.Head.CFrame
    end

    return closestDealer
end

local activeCircle, renderConn
local function drawCircle(x, y, duration)
    if activeCircle then activeCircle:Remove() activeCircle = nil end
    if renderConn then renderConn:Disconnect() renderConn = nil end
    local c = Drawing.new("Circle")
    c.Visible = true
    c.Radius = 20
    c.Thickness = 2
    c.Filled = false
    c.Color = Color3.fromRGB(0, 255, 0)
    c.Position = Vector2.new(x, y)
    activeCircle = c
    renderConn = RunService.RenderStepped:Connect(function()
        if activeCircle then activeCircle.Position = Vector2.new(x, y) end
    end)
    task.delay(duration or 1, function()
        if renderConn then renderConn:Disconnect() renderConn = nil end
        if activeCircle then activeCircle:Remove() activeCircle = nil end
    end)
end

local VirtualInputManager = game:GetService("VirtualInputManager")

function checkCurrentMoneyViaPhone()
    RemoteEvents.GetPhone:FireServer("Phone")
    task.wait(1)

    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local root, home, criminalBtn

    local successPath = pcall(function()
        root = pg["FDDA4801-95D9-493D-8508-33F7B0C3CE1E"]["FDDA4801-95D9-493D-8508-33F7B0C3CE1E"]["3"]["4"]
        home = root:FindFirstChild("Home")
        criminalBtn = home and home:FindFirstChild("Criminal") and home.Criminal:FindFirstChild("1")
    end)

    if not successPath or not root or not criminalBtn then

        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.DisplayOrder == 29 then
                pcall(function()
                    local frame = gui:FindFirstChildOfClass("Frame")
                    root = frame["3"]["4"]
                    home = root:FindFirstChild("Home")
                    criminalBtn = home.Criminal["1"]
                end)
                break
            end
        end
    end

    if not criminalBtn then
        RemoteEvents.ClosePhone:FireServer()
        return 0
    end

    local clickOffset = 0
    local success = false
    local maxTries = 40 

    ")
    
    for i = 1, maxTries do
        local checkHome = root:FindFirstChild("Home")
        if not checkHome or not checkHome.Visible then
            success = true
            break
        end

        local pos = criminalBtn.AbsolutePosition
        local size = criminalBtn.AbsoluteSize
        local x = pos.X + size.X / 2
        local y = pos.Y + size.Y / 2 + clickOffset

        if _G.criminalappdrawing then
            drawCircle(x, y, 0.5)
        end

        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)

        clickOffset = clickOffset + 2
        task.wait(0.1) 
    end

    if not success then
        RemoteEvents.ClosePhone:FireServer()
        return 0
    end

    local moneyLabel = root:WaitForChild("4"):WaitForChild("3")

    local rawText = moneyLabel.Text
    local startTime = tick()
    while (rawText == "
        task.wait(0.2)
        rawText = moneyLabel.Text
    end

    if rawText == "
        task.wait(0.5)
        rawText = moneyLabel.Text
    end

    local cleaned = rawText:gsub("", ""):gsub("%s+", "")
    local hasK = rawText:find("k")
    cleaned = cleaned:gsub("k", "")
    
    local amount = 0
    if hasK then
        amount = (tonumber(cleaned) or 0) * 1000
    else
        amount = tonumber(cleaned:gsub("%.", "")) or 0
    end

    RemoteEvents.ClosePhone:FireServer()
    return amount
end

function findDiamondCount()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local targetImage = "rbxassetid://104822377573164"

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("ImageLabel") and obj.Image == targetImage then
            local parent = obj.Parent
            if parent then
                local countLabel = parent:FindFirstChild("3")
                if countLabel and countLabel:IsA("TextLabel") then
                    return tonumber(countLabel.Text) or 0
                end
            end
        end
    end
    return 0
end

function runSaveMoneySequence()
    if not _G.saveMoneyBeforeRejoin then return end
    
    local currentMoney = checkCurrentMoneyViaPhone()
    local threshold = _G.moneyToSaveValue or 50000
    
    .. " | Target (Slider): " .. tostring(threshold))
    
    if currentMoney >= threshold then
        >= Threshold (" .. threshold .. "). Starting sell routine...")
        
        local dealer = findNearestDealer()
        local dealerCF = dealer and dealer.Head.CFrame or _G.lastKnownDealerCFrame
        
        if dealerCF then
             ...")
             frameTween(dealerCF + Vector3.new(0, -2, 0))
             task.wait(0.5)
             buyBombAndSell(0)
             task.wait(1)
             
             ...")
             frameTween(dealerCF + Vector3.new(0, -2, 0))
             task.wait(0.5)
             buyBombAndSell(0)
             task.wait(1)
        end
        
        local diamondCount = findDiamondCount()
        if diamondCount > 0 then
            local smugglerFolder = workspace:FindFirstChild("Smugglers")
            local nearestSmuggler = nil
            local minShoreDis = math.huge
            local lpPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
            
            if smugglerFolder then
                for _, s in ipairs(smugglerFolder:GetChildren()) do
                    local dist = (s:GetPivot().Position - lpPos).Magnitude
                    if dist < minShoreDis then
                        minShoreDis = dist
                        nearestSmuggler = s
                    end
                end
            end
            
            local isOption1 = false
            if nearestSmuggler then
                local pivot = nearestSmuggler:GetPivot().Position
                if (pivot - Vector3.new(812.562988, -21.125, -1512.63098)).Magnitude < 5 then
                    isOption1 = true
                end
            end
            
            if isOption1 then
                frameTween(CFrame.new(738.794312, 3.52832198, -1504.39526, -0.999932051, -0.000173144057, 0.0116532659, -0.000172138112, 1, 8.73264944e-05, -0.0116532808, 8.53145903e-05, -0.999932051))
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                task.wait(0.5)
                plrTween(CFrame.new(776.414001, -1.91762531, -1503.91406, 0.0891489089, 5.83950666e-08, -0.996018291, -2.115193e-08, 1, 5.67352956e-08, 0.996018291, 1.6009821e-08, 0.0891489089))
                plrTween(CFrame.new(809.989624, -22.6515007, -1512.96936, -0.0414817855, 3.46067743e-08, -0.999139249, -6.74841942e-08, 1, 3.74383617e-08, 0.999139249, 6.89791193e-08, -0.0414817855))
                
                RemoteEvents.SellItem:FireServer("Diamond", "Smuggler")
                task.wait(1)
                
                .")
                frameTween(CFrame.new(717.392944, 3.03320456, -1621.90698, 0.996323705, -0.00225340808, 0.0856386647, 0.00223121, 0.999997437, 0.000354919262, -0.0856392458, -0.000162536657, 0.996326208))
                plrTween(CFrame.new(704.428711, 57.038311, -1625.33545, -0.0239031445, -5.31348299e-08, 0.999714255, -4.20952233e-08, 1, 5.21435233e-08, -0.999714255, -4.08367988e-08, -0.0239031445))
            else
                frameTween(CFrame.new(1022.30725, 3.29838538, 1981.34595, -0.999049842, -6.31316216e-05, 0.0435817763, -6.47525158e-05, 1, -3.57803183e-05, -0.0435817726, -3.85683525e-05, -0.999049842))
                task.wait(0.5)

                local sA, sB = nil, nil
                if smugglerFolder then
                    for _, s in ipairs(smugglerFolder:GetChildren()) do
                        local pivot = s:GetPivot().Position
                        if (pivot - Vector3.new(1158.92798, 61.3100014, 2242.5459)).Magnitude < 5 then sA = s
                        elseif (pivot - Vector3.new(1106.51501, 30.5569992, 1884.62598)).Magnitude < 5 then sB = s end
                    end
                end
                
                if sA then
                    frameTween(CFrame.new(1068.81897, 3.68664122, 2360.88403, -0.999967217, 0.00177234877, -0.00789792184, 0.00177910307, 0.999998033, -0.000848251279, 0.00789640285, -0.000862274668, -0.999968469))
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                    task.wait(0.5)
                    plrTween(CFrame.new(1086.58813, 28.6692123, 2347.50122, 0.529347003, 1.28076136e-08, -0.848405421, -5.82818096e-08, 1, -2.12677662e-08, 0.848405421, 6.07046289e-08, 0.529347003))
                    plrTween(CFrame.new(1164.49548, 28.6692219, 2299.34814, 0.746554852, -9.9519994e-08, -0.665323853, 9.49999475e-08, 1, -4.29825597e-08, 0.665323853, -3.1116894e-08, 0.746554852))
                    plrTween(CFrame.new(1159.0835, 59.7837868, 2245.94263, 0.999968708, -1.64257532e-08, 0.00790836383, 1.58278546e-08, 1, 7.56659801e-08, -0.00790836383, -7.55384448e-08, 0.999968708))
                elseif sB then
                    frameTween(CFrame.new(1061.09058, 3.38043857, 1857.00891, -0.994440079, -0.104499161, 0.0129944365, -0.104507692, 0.994524062, 2.29175257e-05, -0.0129256751, -0.00133522844, -0.99991554))
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                    task.wait(0.5)
                    plrTween(CFrame.new(1089.96936, 29.3470783, 1867.51062, -0.479879558, -2.06622524e-08, -0.877334356, -4.18251295e-10, 1, -2.33224e-08, 0.877334356, -1.08249969e-08, -0.479879558))
                    plrTween(CFrame.new(1106.42712, 29.1611652, 1881.38416, -0.999763131, 3.72628683e-08, -0.0217638966, 3.82435233e-08, 1, -4.4642622e-08, 0.0217638966, -4.54643754e-08, -0.999763131))
                end
                
                RemoteEvents.SellItem:FireServer("Diamond", "Smuggler")
                task.wait(1)
                
                .")
                frameTween(CFrame.new(830.270081, 3.30110955, 1944.85144, 0.999892354, -0.0010065136, -0.0146365445, 0.0010150692, 0.999999344, 0.000577118248, 0.0146359541, -0.000591913238, 0.999892712))
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                task.wait(0.5)
                plrTween(CFrame.new(820.411804, 36.3572502, 1943.24316, -0.229677007, -8.41218295e-08, 0.9732669, 2.25046275e-08, 1, 9.17432033e-08, -0.9732669, 4.29743139e-08, -0.229677007))
                plrTween(CFrame.new(790.075378, 36.3572502, 1923.53101, 0.600118101, 2.04306705e-08, -0.799911439, -5.7553442e-09, 1, 2.12233306e-08, 0.799911439, -8.13273893e-09, 0.600118101))
            end
        else
            directly.")
            frameTween(CFrame.new(717.392944, 3.03320456, -1621.90698, 0.996323705, -0.00225340808, 0.0856386647, 0.00223121, 0.999997437, 0.000354919262, -0.0856392458, -0.000162536657, 0.996326208))
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
            task.wait(0.5)
            plrTween(CFrame.new(704.428711, 57.038311, -1625.33545, -0.0239031445, -5.31348299e-08, 0.999714255, -4.20952233e-08, 1, 5.21435233e-08, -0.999714255, -4.08367988e-08, -0.0239031445))
        end
        
        local totalSeconds = 10 * 60
        local sg = Instance.new("ScreenGui")
        sg.Name = "VantaCountdown"
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 300, 0, 60)
        label.Position = UDim2.new(0.5, -150, 0, 80)
        label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        label.BackgroundTransparency = 0.3
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 26
        label.Font = Enum.Font.GothamBold
        label.BorderSizePixel = 2
        label.BorderColor3 = Color3.fromRGB(100, 200, 255)
        label.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = label

        for i = totalSeconds, 1, -1 do
            local mins = math.floor(i / 60)
            local secs = i % 60
            label.Text = string.format(" Rejoining in: %02d:%02d", mins, secs)
            task.wait(1)
        end
        sg:Destroy()
        
        end
    return true
end

function startRobberyCycle()
    isHeaderRunning = true
    
    while isHeaderRunning do
        if isRespawning then
            break
        end
        
        updateLocks()

        
        local gasRegionDone = false
        
        if CurrentBombs < 4 then
            , heading to nearest dealer...")
            local dealer = findNearestDealer()
            if dealer then
                frameTween(dealer.Head.CFrame)
                buyBombAndSell(4 - CurrentBombs)
            end
        end
        
        while not gasRegionDone do
            if _G.vendingPriority == "Before Main Robberys" then
                handleVendingRobbery(gasregion, contaregion)
            end
            
            frameTween(gasregion)
            _G.gasRegionReached = true
            
            local club, bank, gasngo, jewellery = cgas()
            
            if bank and not banklock then
                BankRob()
            elseif club and not clublock then
                ClubRob()
            elseif gasngo and not gasngolock then
                GasngoRob()
            elseif jewellery and not jewellerylock then
                JewelleryRob()
            else
                gasRegionDone = true
                if _G.vendingPriority == "After Main Robberys" then
                    handleVendingRobbery(gasregion, contaregion)
                end
                end
        end
        
        local containerRegionDone = false
        
        if CurrentBombs < 4 then
            , heading to nearest dealer...")
            local dealer = findNearestDealer()
            if dealer then
                frameTween(dealer.Head.CFrame)
                buyBombAndSell(4 - CurrentBombs)
            end
        end
        
        while not containerRegionDone do
            frameTween(contaregion)
            local containerone, containertwo, containerthree, containerfour = cconta()
            
            if containerone and not containeronelock then
                ContaineroneRob()
            elseif containertwo and not containertwolock then
                ContainertwoRob()
            elseif containerthree and not containerthreelock then
                ContainerthreeRob()
            elseif containerfour and not containerfourlock then
                ContainerfourRob()
            else
                containerRegionDone = true
                end
        end
        
        local aresRegionDone = false

        frameTween(CFrame.new(858.241272, 3.12237835, 1773.55664, 0.125734136, 0.00639350479, 0.992043376, -0.0092076268, 0.999943674, -0.00527742226, -0.992021263, -0.00847081374, 0.125785917))
        frameTween(CFrame.new(199.099487, 3.63040662, 1687.92432, 0.00216283719, 0.0136310551, 0.999904752, 0.0196070857, 0.999714315, -0.0136708701, -0.99980545, 0.019634787, 0.00189495401))
        
        while not aresRegionDone do
            frameTween(aresregion)

            local ares, tool = cares()
            
            if ares and not areslock then
                AresRob()

            elseif tool and not toollock then
                ToolRob()

            else
                aresRegionDone = true
                if _G.ossoVisitedOnce then
                    _G.lockHeightTo7 = true
                end
                end
        end
        
        local ossoRegionDone = false
        
        while not ossoRegionDone do
            
            fixedY = 2
            
            local currentRegion = "unknown"
            
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local position = character.HumanoidRootPart.Position
                
                local regions = {
                    {name = "gas", position = gasregion.Position, threshold = 500},
                    {name = "container", position = contaregion.Position, threshold = 500},
                    {name = "ares", position = aresregion.Position, threshold = 500},
                    {name = "osso", position = ossoregionDirect.Position, threshold = 500}
                }
                
                for _, region in ipairs(regions) do
                    if (position - region.position).Magnitude < region.threshold then
                        currentRegion = region.name
                        break
                    end
                end
            end
            
            frameTween(ossoregionDirect)
            
            fixedY = -1.9

            local farm, oso, clothing = cosso()
            
            if farm and not farmlock then
                FarmRob()

            elseif oso and not osolock then
                OsRob()

            elseif clothing and not clothinglock then
                ClothingRob()

            else
                ossoRegionDone = true
                end
        end
        
        hopServer()

    end
end

function checkGasRegion()
    frameTween(gasregion)    
    
    local clubAvailable, bankAvailable, gasngoAvailable, jewelleryAvailable = cgas()
    
    if bankAvailable and not banklock then
        BankRob()
        return true
    elseif clubAvailable and not clublock then
        ClubRob()
        return true
    elseif jewelleryAvailable and not jewellerylock then
        JewelleryRob()
        return true
    elseif gasngoAvailable and not gasngolock then
        GasngoRob()
        return true
    end
    
    return false
end

function checkContainerRegion()
    if CurrentBombs < 4 then
        return false
    end

    frameTween(contaregion)
    
    local containeroneAvailable,
      containertwoAvailable,
      containerthreeAvailable,
      containerfourAvailable = cconta()

    
    if containeroneAvailable and not containeronelock then
        ContaineroneRob()
        return true
    elseif containertwoAvailable and not containertwolock then
        ContainertwoRob()
        return true
    elseif containerthreeAvailable and not containerthreelock then
        ContainerthreeRob()
        return true
    elseif containerfourAvailable and not containerfourlock then
        ContainerfourRob()
        return true
    end

return false
end

function checkAresRegion()
    frameTween(aresregion)
    
    local aresAvailable, toolAvailable = cares()
    
    if aresAvailable and not areslock then
        AresRob()
        return true
    elseif toolAvailable and not toollock then
        ToolRob()
        return true
    end
    
    return false
end

function checkOssoRegion()
    frameTween(ossoregionDirect)

    
    local farmAvailable, osoAvailable, clothingAvailable = cosso()
    
    if farmAvailable and not farmlock then
        FarmRob()
        return true
    elseif osoAvailable and not osolock then
        OsRob()
        return true
    elseif clothingAvailable and not clothinglock then
        ClothingRob()
        return true
    end
    
    return false
end

function cosso()
    updateLocks()

local success, farmObj = pcall(function()
    return workspace.Robberies["Farm Shop Robbery"]["Farm Shop"].MoneyTray
end)

if success and farmObj then
    local targetCFrame = CFrame.new(-961.383362, 7.36743832, -1177, 0, 0, 1, 0, 1, 0, -1, 0, 0)

    local farmCFrame = farmObj.CFrame

    if farmCFrame == targetCFrame then
        farm = true
    else
        farm = false
    end
else
    farm = false
end

    local success2, osoObj = pcall(function()
        return workspace.Robberies["Osso Fuel Station Robbery"]["Osso Fuel Station"].MoneyTray
    end)
    
    if success2 and osoObj then
        local targetCFrame = CFrame.new(-80.0498047, 5.25518656, -780.373901, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    
        local osoCFrame = osoObj.CFrame
    
        if osoCFrame == targetCFrame then
            oso = true
        else
            oso = false
        end
    else
        oso = false
    end
    

    local success3, clothingObj = pcall(function()
        return workspace.Robberies["Clothing Store Robbery"]["Clothing Store"].MoneyTray
    end)
    
    if success3 and clothingObj then
        local targetCFrame = CFrame.new(472.149292, 5.15978765, -1406.59155, 0, 0, 1, 0, 1, 0, -1, 0, 0)
    
        local clothingCFrame = clothingObj.CFrame
    
        if clothingCFrame == targetCFrame then
            clothing = true
        else
            clothing = false
        end
    else
        clothing = false
    end
    

    if not _G.selectedRobberies["Farm Shop"] then farm = false end
    if not _G.selectedRobberies["Osso Fuel"] then oso = false end
    if not _G.selectedRobberies["Clothing Store"] then clothing = false end

    return farm, oso, clothing
end

function cares()
    updateLocks()

    ares = false
    tool = false

    local targetCFrame = CFrame.new(
        -841.482483, 5.07732582, 1532.29358, 
         0, 0, -1, 
         0, 1,  0, 
         1, 0,  0
    )
    
    local success, aresObj = pcall(function()
        return workspace.Robberies["Ares Fuel Station Robbery"]["Ares Fuel Station"].MoneyTray
    end)
    
    if success and aresObj and aresObj:IsA("BasePart") then
        if aresObj.CFrame == targetCFrame and not aresLocked then
            ares = true
            else
            end
    else
        end

    local targetToolCFrame = CFrame.new(
        -756.375, 5.52618742, 628.139771,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    )

    local success2, toolObj = pcall(function()
        return workspace.Robberies["Tool Shop Robbery"]["Tool Shop"].MoneyTray
    end)

    if success2 and toolObj and toolObj:IsA("BasePart") then
        if toolObj.CFrame == targetToolCFrame then
            tool = true
            else
            end
    else
        end

    if not _G.selectedRobberies["Ares Fuel"] then ares = false end
    if not _G.selectedRobberies["Tool Shop"] then tool = false end

    return ares, tool
end

function cconta()
    updateLocks()

    containerone=false
    containertwo=false
    containerthree=false
    containerfour=false

    local folder=workspace.Robberies.ContainerRobberies

    local targets={
        {name="ContainerOne",pos=Vector3.new(1127.3623046875,30.690214157104492,2164.527099609375),lock=containeronelock,set=function()containerone=true end},
        {name="ContainerTwo",pos=Vector3.new(1156.0094,30.6899986,2166.46265),lock=containertwolock,set=function()containertwo=true end},
        {name="ContainerThree",pos=Vector3.new(1123.049560546875,30.690214157104492,2317.128662109375),lock=containerthreelock,set=function()containerthree=true end},
        {name="ContainerFour",pos=Vector3.new(1151.72705078125,30.690214157104492,2319.04638671875),lock=containerfourlock,set=function()containerfour=true end}
    }

    for _,info in ipairs(targets) do
        local success,foundModel=pcall(function()
            for _,obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("MeshPart") and obj.Name=="Base" then
                    if (obj.Position-info.pos).Magnitude<=2 then
                        return obj.Parent
                    end
                end
            end
        end)

        if success and foundModel and foundModel:FindFirstChild("Barricade") then
            local barricade=foundModel.Barricade
            local parts={}

            for _,p in ipairs(barricade:GetChildren()) do
                if p:IsA("BasePart") then
                    table.insert(parts,p)
                end
            end

            local part=parts[math.random(#parts)]

            if part and part.Transparency==1 and not info.lock then
                info.set()
                else
                end
        else
            end
    end

    if not _G.selectedRobberies["Container 1"] then containerone = false end
    if not _G.selectedRobberies["Container 2"] then containertwo = false end
    if not _G.selectedRobberies["Container 3"] then containerthree = false end
    if not _G.selectedRobberies["Container 4"] then containerfour = false end

    return containerone,containertwo,containerthree,containerfour
end

function cgas()
    updateLocks()

    local expectedCFrame = CFrame.new(
        -1744.05078, 11.3275862, 3010.18188,
        -1, 0, 0,
        0, 1, 0,
        0, 0, -1
    )

    local success, metalPart = pcall(function()
        return workspace.Robberies["Club Robbery"].Club.Door.Accessory.Metal
    end)

    if success and metalPart and metalPart:IsA("BasePart") then
        club = (metalPart.CFrame == expectedCFrame)
    else
        club = false
    end

    local success2, bankLight = pcall(function()
        return workspace.Robberies.BankRobbery.LightGreen.Light
    end)

    if success2 and bankLight then
        bank = bankLight.Enabled and not banklock
    else
        bank = false
    end

    local success3, moneyTray = pcall(function()
        return workspace.Robberies["Gas-N-Go Fuel Station Robbery"]["Gas-N-Go Fuel Station"].MoneyTray
    end)

    if success3 and moneyTray then
        local targetPos = Vector3.new(-1524.49194, 6.00749016, 3763)
        gasngo = ((moneyTray.Position - targetPos).Magnitude < 0.1) and not gasngolock
    else
        gasngo = false
    end

    jewellery = false

    local robberies = workspace:FindFirstChild("Robberies")
    local jewelerSafe = robberies and robberies:FindFirstChild("Jeweler Safe Robbery")
    local jeweler = jewelerSafe and jewelerSafe:FindFirstChild("Jeweler")
    local doorFolder = jeweler and jeweler:FindFirstChild("Door")

    if doorFolder then
        local doorPart

        for _, obj in ipairs(doorFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                doorPart = obj
                break
            end
        end

        if doorPart then
            local _, y, _ = doorPart.CFrame:ToEulerAnglesYXZ()
            local yDeg = math.deg(y) % 360

            if math.abs(yDeg - 90) < 10 or math.abs(yDeg - 270) < 10 then
                jewellery = true
            end
        end
    end

    if not _G.selectedRobberies["Club"] then club = false end
    if not _G.selectedRobberies["Bank"] then bank = false end
    if not _G.selectedRobberies["GasnGo"] then gasngo = false end
    if not _G.selectedRobberies["Jewellery"] then jewellery = false end

    return club, bank, gasngo, jewellery
end

function buyBombAndSell(count)

    if count < 0 then return end
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    
    local closestDealer = findNearestDealer()
    local targetCF = closestDealer and closestDealer.Head.CFrame or _G.lastKnownDealerCFrame
    
    if not targetCF then return end

    frameTween(targetCF + Vector3.new(0, -2, 0))
    
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local dealerY = targetCF.Position.Y
        local orientation = char.HumanoidRootPart.Orientation
        char.HumanoidRootPart.CFrame = CFrame.new(pos.X, dealerY, pos.Z) * CFrame.Angles(
            math.rad(orientation.X),
            math.rad(orientation.Y),
            math.rad(orientation.Z)
        )
    end

    if count > 0 then
        local bombsNeeded = math.min(count, 4 - CurrentBombs)
        if bombsNeeded > 0 then
            for i = 1, bombsNeeded do
                RemoteEvents.BuyItem:FireServer("Bomb", "Dealer")
                task.wait(0.1)
            end
        end
    end

    if _G.autoSellEnabled then
        local itemsToSell = {
            "Gold",
            "M58B Shotgun",
            "MP5",
            "Glock 17",
            "Machete",
            "Circular Saw",
            "Grenade",
            "Remote Control",
            "Jewelry"
        }

        if count == 0 then
            table.insert(itemsToSell, "Bomb")
        end
        
        for _, item in ipairs(itemsToSell) do
            RemoteEvents.SellItem:FireServer(item, "Dealer")
            task.wait(0.1)
        end

        if count == 0 then
            for bombSellCount = 1, 4 do
                RemoteEvents.SellItem:FireServer("Bomb", "Dealer")
                task.wait(0.3)
            end
        end
    end
end

local function bombequip()
    local args = {
        [1] = "Bomb"
    }
    RemoteEvents.BombEquip:FireServer(unpack(args))
end

local function getNil(name, class)
    for _, v in next, getnilinstances() do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

local function getCharacter(player)
    local character = player.Character
    if character and character.Parent then
        return character
    end

    local char = player.CharacterAdded:Wait()
    repeat task.wait() until char.Parent
    return char
end

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local function throwbomb()
    local character = LocalPlayer.Character
    if not character then return end

    local tool = character:FindFirstChild("Bomb")
    if not tool then return end

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    task.wait(0.6)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.3)

    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:UnequipTools()
    end
end

local function firebomb()
    RemoteEvents.FireBomb:FireServer()
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer

function plrTween(targetCFrame)
    local char = player.Character or player.CharacterAdded:Wait()
    if not char.PrimaryPart then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Running) end

    local speed = 50
    local distance = (char.PrimaryPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local startCFrame = char:GetPivot()

    char:PivotTo(CFrame.new(startCFrame.Position, targetCFrame.Position))
    task.wait(0.1)

    local tweenValue = Instance.new("CFrameValue")
    tweenValue.Value = startCFrame
    local conn = tweenValue.Changed:Connect(function(newCFrame)
        char:PivotTo(CFrame.new(newCFrame.Position, newCFrame.Position + targetCFrame.LookVector))
    end)

    local tween = TweenService:Create(tweenValue, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    conn:Disconnect()
    char:PivotTo(targetCFrame)
    tweenValue:Destroy()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

_G.flightSpeed = 190
local minSpeed, maxSpeed = 140, 200
local speedStep = 10
local fps = 60

RunService.RenderStepped:Connect(function(deltaTime)
    fps = math.floor(1 / deltaTime)
end)

local function getPing()
    if player and player:IsDescendantOf(game) then
        return player:GetNetworkPing() * 1000
    end
    return 100
end

task.spawn(function()
    while true do
        local currentPing = getPing()
        local pingFactor = math.clamp(1 - (currentPing / 300), 0, 1)
        local fpsFactor = math.clamp(fps / 60, 0.5, 1.2)

        local targetSpeed = math.clamp(minSpeed * fpsFactor * pingFactor, minSpeed, maxSpeed)

        if _G.flightSpeed < targetSpeed then
            _G.flightSpeed = math.min(_G.flightSpeed + speedStep, targetSpeed)
        elseif _G.flightSpeed > targetSpeed then
            _G.flightSpeed = math.max(_G.flightSpeed - speedStep, targetSpeed)
        end

        task.wait(1)
    end
end)

function frameTween(targetCFrame)
    
    parkingBrakeColorFrame = nil
    findParkingBrakeFrame()
    
    local failedChecks = 0
    local maxFailedChecks = 3
    
    addDebugLog(" frameTween STARTED - Tolerance reset", Color3.fromRGB(100, 200, 255))
    updateTolerance(failedChecks, maxFailedChecks)
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if _G.rejoinWhenDead and humanoid.Health < 25 then
        hopServer()
        return
    end

    local vehicle = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
    if not vehicle then return end

    local driveSeat = vehicle:FindFirstChild("DriveSeat")
    if not driveSeat or not driveSeat:IsA("Seat") then return end

    if not vehicle.PrimaryPart then
        local body = vehicle:FindFirstChild("Body")
        local mass = body and body:FindFirstChild("Mass")
        if mass then vehicle.PrimaryPart = mass else return end
    end

    driveSeat:Sit(humanoid)
    task.wait(0.1)

    local originalProps = {}
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            originalProps[part] = {
                v = part.Velocity,
                rv = part.RotVelocity,
                lv = part.AssemblyLinearVelocity,
                av = part.AssemblyAngularVelocity
            }
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function createTweenInternal(startCF, endCF, isVertical)
        local distance = (endCF.Position - startCF.Position).Magnitude
        local speed = isVertical and (_G.flightSpeed / 2) or _G.flightSpeed
        local tweenValue = Instance.new("CFrameValue")
        tweenValue.Value = startCF

        local conn = tweenValue.Changed:Connect(function()
            if vehicle.PrimaryPart then
                vehicle:SetPrimaryPartCFrame(tweenValue.Value)
                for _, part in pairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end)

        local tween = game:GetService("TweenService"):Create(
            tweenValue,
            TweenInfo.new(distance / speed, Enum.EasingStyle.Linear),
            {Value = endCF}
        )

        return tween, tweenValue, conn
    end

    local function smoothMove(startCF, endCF, isVertical)
        local tween, tVal, conn = createTweenInternal(startCF, endCF, isVertical)
        
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local isTweenActive = true
        local pKeyCheckInterval = 2
        local colorCheckConnection = nil
        
        if parkingBrakeColorFrame and (_G.rejoinWhenKicked == nil or _G.rejoinWhenKicked == true) then
            colorCheckConnection = parkingBrakeColorFrame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            end)
        end
        
        local pKeyCheckThread = nil
        if _G.rejoinWhenKicked == nil or _G.rejoinWhenKicked == true then
            pKeyCheckThread = task.spawn(function()
                while isTweenActive and not hasTriggeredHop do
                local shouldSkip = false
                
                if not parkingBrakeColorFrame or not parkingBrakeColorFrame.Parent then
                    addDebugLog(" Frame lost, searching again...", Color3.fromRGB(255, 165, 0))
                    findParkingBrakeFrame()
                    if not parkingBrakeColorFrame or not parkingBrakeColorFrame.Parent then
                        addDebugLog(" Frame not found! Increasing tolerance...", Color3.fromRGB(255, 100, 100))
                        failedChecks = failedChecks + 1
                        updateTolerance(failedChecks, maxFailedChecks)
                        
                        if failedChecks >= maxFailedChecks then
                            addDebugLog(" KICK DETECTED! Frame not found - Server hopping...", Color3.fromRGB(255, 0, 0))
                            isTweenActive = false
                            if colorCheckConnection then
                                colorCheckConnection:Disconnect()
                                colorCheckConnection = nil
                            end
                            emergencyServerHop()
                            return
                        end
                        
                        task.wait(pKeyCheckInterval)
                        continue
                    end
                end
                
                if parkingBrakeColorFrame then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.P, false, game)
                    updatePKeyStatus(true)
                    addDebugLog("P key PRESSED", Color3.fromRGB(255, 100, 100))
                    
                    task.wait(0.3)
                    
                    local expectedR, expectedG, expectedB = 39, 174, 96
                    local colorChanged = false
                    local frameValid = true
                    
                    local success, currentColor = pcall(function()
                        if not parkingBrakeColorFrame or not parkingBrakeColorFrame.Parent then
                            frameValid = false
                            return Color3.new(0, 0, 0)
                        end
                        return parkingBrakeColorFrame.BackgroundColor3
                    end)
                    
                    if not success or not frameValid then
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                        updatePKeyStatus(false)
                        failedChecks = failedChecks + 1
                        updateTolerance(failedChecks, maxFailedChecks)
                        addDebugLog(" Frame inaccessible! Tolerance: " .. failedChecks .. "/" .. maxFailedChecks, Color3.fromRGB(255, 100, 100))
                        
                        if failedChecks >= maxFailedChecks then
                            addDebugLog(" KICK DETECTED! Frame inaccessible - Server hopping...", Color3.fromRGB(255, 0, 0))
                            isTweenActive = false
                            if colorCheckConnection then
                                colorCheckConnection:Disconnect()
                                colorCheckConnection = nil
                            end
                            emergencyServerHop()
                            return
                        end
                        
                        task.wait(pKeyCheckInterval)
                        continue
                    end
                    
                    local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
                    
                    local isInvalidColor = (r == 0 and g == 0 and b == 0) or (r < 0 or g < 0 or b < 0)
                    
                    if isInvalidColor then
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                        updatePKeyStatus(false)
                        failedChecks = failedChecks + 1
                        updateTolerance(failedChecks, maxFailedChecks)
                        addDebugLog(" Invalid color detected (RGB(0,0,0))! Tolerance: " .. failedChecks .. "/" .. maxFailedChecks, Color3.fromRGB(255, 100, 100))
                        
                        if failedChecks >= maxFailedChecks then
                            addDebugLog(" KICK DETECTED! Invalid color - Server hopping...", Color3.fromRGB(255, 0, 0))
                            isTweenActive = false
                            if colorCheckConnection then
                                colorCheckConnection:Disconnect()
                                colorCheckConnection = nil
                            end
                            emergencyServerHop()
                            return
                        end
                        
                        task.wait(pKeyCheckInterval)
                        continue
                    end
                    
                    local colorMatch = math.abs(r - expectedR) <= 5 and math.abs(g - expectedG) <= 5 and math.abs(b - expectedB) <= 5
                    
                    addDebugLog("Color check: RGB(" .. r .. "," .. g .. "," .. b .. ") - Expected: RGB(39,174,96)", colorMatch and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 165, 0))
                    
                    if colorMatch then
                        colorChanged = true
                        failedChecks = 0
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                        updatePKeyStatus(false)
                        updateTolerance(failedChecks, maxFailedChecks)
                        addDebugLog(" Color correct! P key released, tolerance reset", Color3.fromRGB(100, 255, 100))
                    else
                        local checkStartTime = tick()
                        local checkDuration = 3
                        local checkCount = 0
                        addDebugLog(" Color wrong, checking every 0.1 seconds for 3 seconds...", Color3.fromRGB(255, 165, 0))
                        
                        while (tick() - checkStartTime) < checkDuration do
                            if hasTriggeredHop or not isTweenActive then 
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                                updatePKeyStatus(false)
                                addDebugLog("Tween stopped, P key released", Color3.fromRGB(200, 200, 200))
                                return 
                            end
                            
                            checkCount = checkCount + 1
                            local elapsedTime = tick() - checkStartTime
                            
                            if checkCount == 1 then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.P, false, game)
                            end
                            
                            local frameStillValid = true
                            local checkSuccess, checkColor = pcall(function()
                                if not parkingBrakeColorFrame or not parkingBrakeColorFrame.Parent then
                                    frameStillValid = false
                                    return Color3.new(0, 0, 0)
                                end
                                return parkingBrakeColorFrame.BackgroundColor3
                            end)
                            
                            if not checkSuccess or not frameStillValid then
                                addDebugLog(" Frame lost during tween! Tolerance will count", Color3.fromRGB(255, 100, 100))
                                colorChanged = false
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                                updatePKeyStatus(false)
                                break
                            end
                            
                            local checkR, checkG, checkB = math.floor(checkColor.R * 255), math.floor(checkColor.G * 255), math.floor(checkColor.B * 255)
                            
                            if (checkR == 0 and checkG == 0 and checkB == 0) then
                                addDebugLog(" Invalid color detected during tween! Tolerance will count", Color3.fromRGB(255, 100, 100))
                                colorChanged = false
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                                updatePKeyStatus(false)
                                break
                            end
                            
                            colorMatch = math.abs(checkR - expectedR) <= 5 and math.abs(checkG - expectedG) <= 5 and math.abs(checkB - expectedB) <= 5
                            
                            if checkCount % 5 == 0 then
                                addDebugLog(" Kontrol #" .. checkCount .. " (" .. string.format("%.1f", elapsedTime) .. "s): RGB(" .. checkR .. "," .. checkG .. "," .. checkB .. ")", colorMatch and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 165, 0))
                            end
                            
                            if colorMatch then
                                colorChanged = true
                                failedChecks = 0
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                                updatePKeyStatus(false)
                                updateTolerance(failedChecks, maxFailedChecks)
                                addDebugLog(" Color changed! (Check #" .. checkCount .. ", " .. string.format("%.1f", elapsedTime) .. "s) P key released, tolerance reset", Color3.fromRGB(100, 255, 100))
                                break
                            end
                            
                            task.wait(0.1)
                        end
                        
                        if not colorChanged then
                            local totalTime = tick() - checkStartTime
                            addDebugLog(" 3 saniye completed: " .. checkCount .. " checks done (" .. string.format("%.1f", totalTime) .. "s)", Color3.fromRGB(200, 200, 200))
                        end
                        
                        if not colorChanged then
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
                            updatePKeyStatus(false)
                            failedChecks = failedChecks + 1
                            updateTolerance(failedChecks, maxFailedChecks)
                            addDebugLog(" Color did not change after 3 seconds! Tolerance: " .. failedChecks .. "/" .. maxFailedChecks, Color3.fromRGB(255, 100, 100))
                            ")
                            
                            if failedChecks >= maxFailedChecks then
                                addDebugLog(" KICK DETECTED! Server hopping...", Color3.fromRGB(255, 0, 0))
                                isTweenActive = false
                                if colorCheckConnection then
                                    colorCheckConnection:Disconnect()
                                    colorCheckConnection = nil
                                end
                                emergencyServerHop()
                                return
                            end
                        end
                    end
                end
                
                task.wait(pKeyCheckInterval)
            end
        end)
        end
        
        task.wait(0.05)
        
        tween:Play()
        tween.Completed:Wait()
        
        isTweenActive = false
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.P, false, game)
        updatePKeyStatus(false)
        addDebugLog("Tween completed, P key released", Color3.fromRGB(200, 200, 200))
        
        if colorCheckConnection then
            colorCheckConnection:Disconnect()
            colorCheckConnection = nil
        end
        
        conn:Disconnect()
        tVal:Destroy()
        if humanoid.SeatPart ~= driveSeat then
            driveSeat:Sit(humanoid)
            task.wait(0.1)
        end
    end

    local startCF = vehicle.PrimaryPart.CFrame
    local startCF = vehicle.PrimaryPart.CFrame
    local startPos = startCF.Position
    local finalTargetPos = targetCFrame.Position
    
    local isGoingToOsso = false
    local isGoingToContainer = false
    local threshold = 50

    if (finalTargetPos - ossoregionDirect.Position).Magnitude < threshold then
        isGoingToOsso = true
        _G.ossoVisitedOnce = true
        ")
    end

    if not isGoingToOsso and (finalTargetPos - contaregion.Position).Magnitude < threshold then
        isGoingToContainer = true
        ")
    end

    local isFirstGasTarget = false
    if not isGoingToOsso and not isGoingToContainer and isFirstGasMove and (finalTargetPos - gasregion.Position).Magnitude < threshold then
        isFirstGasTarget = true
        isFirstGasMove = false
        ")
    end

    local travelY = -1.8
    if _G.lockHeightTo7 then
        travelY = 7
    elseif isGoingToOsso then
        travelY = 7
        _G.lockHeightTo7 = true
    elseif isGoingToContainer or isFirstGasTarget then
        travelY = -1.80769644
    end
    
    " or isGoingToContainer and " (Container Move)" or " (Default)"))

    local flatFace = Vector3.new(targetCFrame.LookVector.X, 0, targetCFrame.LookVector.Z)
    if flatFace.Magnitude < 0.1 then 
        flatFace = Vector3.new(startCF.LookVector.X, 0, startCF.LookVector.Z)
    end
    if flatFace.Magnitude < 0.1 then flatFace = Vector3.new(0, 0, 1) end
    flatFace = flatFace.Unit

    ")
    local phase1EndPos = Vector3.new(startPos.X, travelY, startPos.Z)
    local phase1EndCF = CFrame.lookAt(phase1EndPos, phase1EndPos + flatFace)
    smoothMove(startCF, phase1EndCF, true)
    task.wait(0.1)

    ")
    local phase2EndPos = Vector3.new(finalTargetPos.X, travelY, finalTargetPos.Z)
    local phase2EndCF = CFrame.lookAt(phase2EndPos, phase2EndPos + flatFace)
    smoothMove(phase1EndCF, phase2EndCF, false)
    task.wait(0.1)

    ")
    smoothMove(phase2EndCF, targetCFrame, true)

    failedChecks = 0
    updateTolerance(failedChecks, maxFailedChecks)
    addDebugLog(" frameTween completed, tolerance reset (0/3)", Color3.fromRGB(100, 200, 255))
    for part, props in pairs(originalProps) do
        if part and part.Parent then
            part.Velocity = props.v
            part.RotVelocity = props.rv
            part.AssemblyLinearVelocity = props.lv
            part.AssemblyAngularVelocity = props.av
        end
    end

    vehicle:SetPrimaryPartCFrame(targetCFrame)
    driveSeat:Sit(humanoid)
    end

function bringcar()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local car = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
    if not car then
        return false
    end

    local driveSeat = car:FindFirstChild("DriveSeat", true)
    if not driveSeat then
        return false
    end

    car.PrimaryPart = driveSeat
    local targetPosition = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 10
    local lookAtPosition = character.HumanoidRootPart.Position

    car:SetPrimaryPartCFrame(CFrame.new(targetPosition, lookAtPosition))
    task.wait(0.5)

    driveSeat:Sit(character:FindFirstChildOfClass("Humanoid"))
    local waitTime = 0
    while character:FindFirstChildOfClass("Humanoid").SeatPart ~= driveSeat and waitTime < 5 do
        task.wait(0.1)
        waitTime = waitTime + 0.1
    end

    if character:FindFirstChildOfClass("Humanoid").SeatPart ~= driveSeat then
        return false
    end

    return true
end

function ClubRob()
    local originalDetectDistance = dedectdistance
    dedectdistance = 65
    
    updateHealthTracking()
    if checkHealthAndReset() then
        dedectdistance = originalDetectDistance
        header()
        return
    end
    
    local clubtopframe = CFrame.new(-1756.32764, 3.34990072, 3012.82764, 0.0072402712, 0.000172982691, -0.999973774, 0.00223436486, 0.999997497, 0.000189164624, 0.999971271, -0.0022356757, 0.00723986654)
    frameTween(clubtopframe)
    task.wait(0.4)
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.3)
    
    local clubdownbomframe = CFrame.new(-1744.33691, 11.0985003, 3021.729, 0.999746203, -1.32538043e-08, 0.0225276276, 1.10258052e-08, 1, 9.90249305e-08, -0.0225276276, -9.87514142e-08, 0.999746203)
    plrTween(clubdownbomframe)
    task.wait(0.3)
    
    local character = game.Players.LocalPlayer.Character
    if character then
        character.HumanoidRootPart.CFrame = clubdownbomframe
    end
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end

    task.wait(0.5)

    bombequip()
    task.wait(0.7)
    
    local hasBomb = false
    for i = 1, 5 do
        if character and character:FindFirstChild("Bomb") then
            hasBomb = true
            break
        end
        ")
        bombequip()
        task.wait(0.6)
    end
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end

    if hasBomb then
        local throwLoopActive = true
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Anchored = true
            local camera = workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Scriptable
            task.spawn(function()
                while throwLoopActive do
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = clubdownbomframe
                    end
                    camera.CFrame = CFrame.new(-1744.34473, 14.5178528, 3029.33325, 0.999999464, 0.000251241057, -0.000990671688, 0, 0.969314277, 0.245824665, 0.00102203351, -0.245824531, 0.9693138)
                    task.wait()
                end
                camera.CameraType = Enum.CameraType.Custom
            end)
        end
        
        throwbomb()
        task.wait(0.6)
        throwLoopActive = false
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Anchored = false
        end
    else
        end
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end
    
    plrTween(CFrame.new(-1744.17468, 11, 3043.31348, 0.999123216, -6.63560185e-09, 0.0418666899, 9.07292375e-09, 1, -5.80262416e-08, -0.0418666899, 5.83552193e-08, 0.999123216))
    task.wait(1)
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end
    
    firebomb()
    task.wait(2.8)
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end
    
    plrTween(CFrame.new(-1743.99744, 11.0985003, 3012.64453, 0.999937356, 2.40936835e-08, 0.0111951213, -2.33409612e-08, 1, -6.7367381e-08, -0.0111951213, 6.71018512e-08, 0.999937356))
    task.wait(0.3)
    
    if detectPolice("Club") then dedectdistance = originalDetectDistance return end

    local oldMaxZoom = game.Players.LocalPlayer.CameraMaxZoomDistance
    game.Players.LocalPlayer.CameraMaxZoomDistance = RobberyZoomValue

    local itemsFolder = workspace:WaitForChild("Robberies"):WaitForChild("Club Robbery"):WaitForChild("Club"):WaitForChild("Items")
    local moneyFolder = workspace:WaitForChild("Robberies"):WaitForChild("Club Robbery"):WaitForChild("Club"):WaitForChild("Money")
    
    local Collected = {}
    local Range = 40
    local ProximityPromptTimeBetClub = 2.5

    local function clubLoot(folder)
        for _, m in ipairs(folder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and not Collected[m] and (m.Position - rootPart.Position).Magnitude <= Range then
                    Collected[m] = true
                    task.spawn(function()
                        local code = (folder == moneyFolder) and MONEY_COLLECT_CODE or GOLD_COLLECT_CODE
                        : " .. m.Name .. " | Transparency: " .. m.Transparency .. " | Code: " .. code)
                        RemoteEvents.RobEvent:FireServer(m, code, true)
                        task.wait(ProximityPromptTimeBetClub)
                        RemoteEvents.RobEvent:FireServer(m, code, false)
                        task.wait(0.5)
                        
                        if m and m.Parent and m.Transparency == 0 then
                            : " .. m.Name .. " (Transparency: 0) - Will retry")
                            Collected[m] = nil
                        else
                            : " .. m.Name .. " (Transparency: " .. (m and m.Transparency or 1) .. ")")
                        end
                    end)
                end
            end
        end
    end

    local startTime = tick()
    local maxDuration = 15
    
    while tick() - startTime < maxDuration do
        if detectPolice("Club") then 
            break 
        end
        
        clubLoot(itemsFolder)
        clubLoot(moneyFolder)
        
        local visibleItems = 0
        for _, m in ipairs(itemsFolder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and (m.Position - rootPart.Position).Magnitude <= Range then
                    visibleItems = visibleItems + 1
                end
            end
        end
        for _, m in ipairs(moneyFolder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and (m.Position - rootPart.Position).Magnitude <= Range then
                    visibleItems = visibleItems + 1
                end
            end
        end
        
        if visibleItems == 0 then
            local elapsed = math.floor(tick() - startTime)
            ")
            break
        end
        
        task.wait(0.5)
    end

    if oldMaxZoom > 0 then
        game.Players.LocalPlayer.CameraMaxZoomDistance = oldMaxZoom
    end
   
    clublock = true
    clubLockTime = os.time()
   
    dedectdistance = originalDetectDistance
    end

function ContaineroneRob()
    updateHealthTracking()

    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)

    frameTween(CFrame.new(1073.255, 3.94887185, 2156.22827, 0.999930084, 1.88356933e-06, 0.0118226139, -1.91243021e-06, 1, 2.42985311e-06, -0.0118226139, -2.45229307e-06, 0.999930084))
    task.wait(0.9)

    if detectPolice("Containerone") then return end

    local character = LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Sit = false
    task.wait(0.5)

    if detectPolice("Containerone") then return end

    plrTween(CFrame.new(1088.36853, 28.6692448, 2148.1062, -0.0592542812, -1.18093176e-07, -0.998242915, -3.11149009e-08, 1, -1.1645411e-07, 0.998242915, 2.41598244e-08, -0.0592542812))
    task.wait(0.7)

    if detectPolice("Containerone") then return end

    plrTween(CFrame.new(
        1106.7074, 28.669241, 2176.46753,
        0.513249218, 0, -0.858239591,
        0, 1, 0,
        0.858239591, 0, 0.513249218
    ))

    bombequip()
    task.wait(0.5)

    if detectPolice("Containerone") then return end

    local camera = workspace.CurrentCamera
    local oldCameraType = camera.CameraType
    local oldCameraCFrame = camera.CFrame

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(
        1096.15295, 33.4737244, 2183.10547,
        0.532389402, 0.2174211, -0.818101168,
        0, 0.966452003, 0.256847262,
        0.846499562, -0.136742756, 0.514528811
    )

    throwbomb()

    task.wait(0.6)

    camera.CameraType = oldCameraType
    camera.CFrame = oldCameraCFrame

    if detectPolice("Containerone") then return end

    plrTween(CFrame.new(1087.60315, 28.669239, 2187.35986, 0.165859088, 7.45111137e-08, -0.98614949, 5.4006982e-08, 1, 8.46409876e-08, 0.98614949, -6.72974352e-08, 0.165859088))

    firebomb()
    task.wait(3)

    local insidePosition = CFrame.new(1128.29346, 28.6692429, 2164.92383, 0.869349122, -4.37780763e-08, 0.494198471, 2.37285942e-08, 1, 4.68428034e-08, -0.494198471, -2.89961157e-08, 0.869349122)
    plrTween(insidePosition)

    if detectPolice("Containerone") then return end

    local containerModel = nil
    local closestDistance = math.huge
    local targetPos = Vector3.new(1127.3623046875, 30.690214157104492, 2164.527099609375)

    for attempt = 1, 10 do
        for _, obj in ipairs(workspace.Robberies.ContainerRobberies:GetDescendants()) do
            if obj:IsA("MeshPart") and obj.Name == "Base" then
                local parentModel = obj.Parent
                if parentModel and parentModel:IsA("Model") and parentModel.Name == "ContainerRobbery" then
                    local dist = (obj.Position - targetPos).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        containerModel = parentModel
                    end
                end
            end
        end
        if containerModel then break end
        task.wait(0.5)
    end

    if not containerModel then
        return
    end

local Range = 30
local CollectTime = ProximityPromptTimeBet
local root = character:WaitForChild("HumanoidRootPart")

local function getTransparencyTarget(item)
    local target = nil
    
    if item:IsA("Model") then
        target = item:FindFirstChild("Main", true) or item:FindFirstChild("Handle", true)
    elseif item:IsA("MeshPart") then
        target = item
    end
    
    return target
end

local function isItemCollectable(target)
    if not target or not target:IsA("MeshPart") then return false end
    return target.Transparency == 0
end

local Collected = {}

local function collectFolder(folderName, collectCode)
    local folder = containerModel:FindFirstChild(folderName)
    if not folder then 
        return 
    end
    
    local totalCollected = 0
    local maxRounds = 5
    
    for round = 1, maxRounds do
        local itemsToCollect = {}

        for _, item in ipairs(folder:GetChildren()) do
            local target = getTransparencyTarget(item)
            if isItemCollectable(target) and not Collected[target] then
                local distance = (target.Position - root.Position).Magnitude
                if distance <= Range then
                    table.insert(itemsToCollect, {item = item, target = target})
                end
            end
        end
        
        if #itemsToCollect == 0 then
            break
        end

        for _, data in ipairs(itemsToCollect) do
            Collected[data.target] = true
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, true)
            end)
        end
        
        task.wait(CollectTime)

        for _, data in ipairs(itemsToCollect) do
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, false)
            end)
        end
        
        task.wait(0.8)

        local roundCollected = 0
        for _, data in ipairs(itemsToCollect) do
            if data.target and data.target.Parent and data.target.Transparency == 0 then

                Collected[data.target] = nil
            else
                roundCollected = roundCollected + 1
            end
        end
        
        totalCollected = totalCollected + roundCollected
        task.wait(0.3)
    end

    local distantItems = {}
    for _, item in ipairs(folder:GetChildren()) do
        local target = getTransparencyTarget(item)
        if isItemCollectable(target) and not Collected[target] then
            local distance = (target.Position - root.Position).Magnitude
            if distance > Range then
                table.insert(distantItems, {item = item, target = target, distance = distance})
            end
        end
    end
    
    if #distantItems > 0 then
        table.sort(distantItems, function(a, b) return a.distance < b.distance end)
        for _, data in ipairs(distantItems) do
            local targetPos = data.target.Position + Vector3.new(0, 2, 0)
            plrTween(CFrame.new(targetPos))
            task.wait(0.3)

            local nearbyBatch = {}
            for _, otherData in ipairs(distantItems) do
                if isItemCollectable(otherData.target) and not Collected[otherData.target] then
                    local dist = (otherData.target.Position - data.target.Position).Magnitude
                    if dist <= 20 then
                        table.insert(nearbyBatch, otherData)
                        Collected[otherData.target] = true
                    end
                end
            end

            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, true)
                end)
            end
            task.wait(CollectTime)
            
            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, false)
                end)
            end
            task.wait(0.6)

            local batchCollected = 0
            for _, batchData in ipairs(nearbyBatch) do
                if not (batchData.target and batchData.target.Parent and batchData.target.Transparency == 0) then
                    batchCollected = batchCollected + 1
                end
            end
            
            totalCollected = totalCollected + batchCollected
            task.wait(0.2)
        end
    end
    
    ===\n")
end

collectFolder("Items", GOLD_COLLECT_CODE)
task.wait(0.6)

collectFolder("Money", MONEY_COLLECT_CODE)

    frameTween(contaregion)
    containeronelock = true
    containeroneLockTime = os.time()
end

function ContainertwoRob()
    updateHealthTracking()

    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)

    frameTween(CFrame.new(1073.255, 3.94887185, 2156.22827, 0.999930084, 1.88356933e-06, 0.0118226139, -1.91243021e-06, 1, 2.42985311e-06, -0.0118226139, -2.45229307e-06, 0.999930084))
    task.wait(0.9)

    if detectPolice("Containertwo") then return end

    local character = LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Sit = false
    task.wait(0.5)

    if detectPolice("Containertwo") then return end

    plrTween(CFrame.new(1088.36853, 28.6692448, 2148.1062, -0.0592542812, -1.18093176e-07, -0.998242915, -3.11149009e-08, 1, -1.1645411e-07, 0.998242915, 2.41598244e-08, -0.0592542812))
    task.wait(0.7)

    if detectPolice("Containertwo") then return end

    plrTween(CFrame.new(1173.95007, 28.6692429, 2156.50854, -0.519922912, -9.08951279e-08, 0.854213178, -1.12454721e-07, 1, 3.79616516e-08, -0.854213178, -7.63231753e-08, -0.519922912))

    bombequip()
    task.wait(0.3)

    if detectPolice("Containertwo") then return end

    local camera = workspace.CurrentCamera
    local oldCameraType = camera.CameraType
    local oldCameraCFrame = camera.CFrame

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(1190.74744, 34.9694366, 2146.77612, -0.501333475, -0.208064973, 0.839865327, 0, 0.970657349, 0.240466908, -0.865254104, 0.120554112, -0.486623079)

    throwbomb()

    task.wait(0.6)

    camera.CameraType = oldCameraType
    camera.CFrame = oldCameraCFrame

    if detectPolice("Containertwo") then return end

    plrTween(CFrame.new(1197.71875, 28.6692448, 2142.79517, -0.556013286, -4.41213643e-08, 0.83117342, 1.19582708e-08, 1, 6.10827087e-08, -0.83117342, 4.39021939e-08, -0.556013286))

    firebomb()
    task.wait(3)

    local insidePosition = CFrame.new(1155.49329, 28.6692429, 2166.14795, 0.871396005, -3.4300256e-09, 0.490580261, 5.11015397e-10, 1, 6.08407813e-09, -0.490580261, -5.05094766e-09, 0.871396005)
    plrTween(insidePosition)

    if detectPolice("Containertwo") then return end

    local containerModel = nil
    local closestDistance = math.huge
    local targetPos = Vector3.new(1156.0093994140625, 30.689998626708984, 2166.462646484375)

    for attempt = 1, 10 do
        for _, obj in ipairs(workspace.Robberies.ContainerRobberies:GetDescendants()) do
            if obj:IsA("MeshPart") and obj.Name == "Base" then
                local parentModel = obj.Parent
                if parentModel and parentModel:IsA("Model") and parentModel.Name == "ContainerRobbery" then
                    local dist = (obj.Position - targetPos).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        containerModel = parentModel
                    end
                end
            end
        end
        if containerModel then break end
        task.wait(0.5)
    end

    if not containerModel then
        return
    end

local Range = 30
local CollectTime = ProximityPromptTimeBet
local root = character:WaitForChild("HumanoidRootPart")

local function getTransparencyTarget(item)
    local target = nil
    
    if item:IsA("Model") then
        target = item:FindFirstChild("Main", true) or item:FindFirstChild("Handle", true)
    elseif item:IsA("MeshPart") then
        target = item
    end
    
    return target
end

local function isItemCollectable(target)
    if not target or not target:IsA("MeshPart") then return false end
    return target.Transparency == 0
end

local Collected = {}

local function collectFolder(folderName, collectCode)
    local folder = containerModel:FindFirstChild(folderName)
    if not folder then 
        return 
    end
    
    local totalCollected = 0
    local maxRounds = 5
    
    for round = 1, maxRounds do
        local itemsToCollect = {}

        for _, item in ipairs(folder:GetChildren()) do
            local target = getTransparencyTarget(item)
            if isItemCollectable(target) and not Collected[target] then
                local distance = (target.Position - root.Position).Magnitude
                if distance <= Range then
                    table.insert(itemsToCollect, {item = item, target = target})
                end
            end
        end
        
        if #itemsToCollect == 0 then
            break
        end

        for _, data in ipairs(itemsToCollect) do
            Collected[data.target] = true
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, true)
            end)
        end
        
        task.wait(CollectTime)

        for _, data in ipairs(itemsToCollect) do
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, false)
            end)
        end
        
        task.wait(0.8)

        local roundCollected = 0
        for _, data in ipairs(itemsToCollect) do
            if data.target and data.target.Parent and data.target.Transparency == 0 then

                Collected[data.target] = nil
            else
                roundCollected = roundCollected + 1
            end
        end
        
        totalCollected = totalCollected + roundCollected
        task.wait(0.3)
    end

    local distantItems = {}
    for _, item in ipairs(folder:GetChildren()) do
        local target = getTransparencyTarget(item)
        if isItemCollectable(target) and not Collected[target] then
            local distance = (target.Position - root.Position).Magnitude
            if distance > Range then
                table.insert(distantItems, {item = item, target = target, distance = distance})
            end
        end
    end
    
    if #distantItems > 0 then
        table.sort(distantItems, function(a, b) return a.distance < b.distance end)
        for _, data in ipairs(distantItems) do
            local targetPos = data.target.Position + Vector3.new(0, 2, 0)
            plrTween(CFrame.new(targetPos))
            task.wait(0.3)

            local nearbyBatch = {}
            for _, otherData in ipairs(distantItems) do
                if isItemCollectable(otherData.target) and not Collected[otherData.target] then
                    local dist = (otherData.target.Position - data.target.Position).Magnitude
                    if dist <= 20 then
                        table.insert(nearbyBatch, otherData)
                        Collected[otherData.target] = true
                    end
                end
            end

            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, true)
                end)
            end
            task.wait(CollectTime)
            
            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, false)
                end)
            end
            task.wait(0.6)

            local batchCollected = 0
            for _, batchData in ipairs(nearbyBatch) do
                if not (batchData.target and batchData.target.Parent and batchData.target.Transparency == 0) then
                    batchCollected = batchCollected + 1
                end
            end
            
            totalCollected = totalCollected + batchCollected
            task.wait(0.2)
        end
    end
    
    ===\n")
end

collectFolder("Items", GOLD_COLLECT_CODE)
task.wait(0.6)

collectFolder("Money", MONEY_COLLECT_CODE)

    frameTween(contaregion)
    containertwolock = true
    containertwoLockTime = os.time()
end

function ContainerthreeRob()
    updateHealthTracking()

    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)

    frameTween(CFrame.new(1055.54541, 3.59994721, 2294.27759, -0.99944365, -0.00769293215, -0.0324539281, -0.00762391789, 0.99996841, -0.00224973587, 0.0324702077, -0.00200105808, -0.999470711))
    task.wait(0.9)

    if detectPolice("Containerthree") then return end

    local character = LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Sit = false
    task.wait(0.5)

    if detectPolice("Containerthree") then return end

    plrTween(CFrame.new(1087.47437, 28.66922, 2298.15137, -0.0557407849, -1.75191843e-08, -0.998445272, 1.76595538e-08, 1, -1.85323543e-08, 0.998445272, -1.8665105e-08, -0.0557407849))
    task.wait(0.7)

    if detectPolice("Containerthree") then return end

    plrTween(CFrame.new(1107.67346, 28.6692142, 2325.60254, 0.537478685, -3.96208577e-08, -0.843277335, 2.48465302e-08, 1, -3.11479731e-08, 0.843277335, -4.21114477e-09, 0.537478685))

    bombequip()
    task.wait(0.3)

    if detectPolice("Containerthree") then return end

    local camera = workspace.CurrentCamera
    local oldCameraType = camera.CameraType
    local oldCameraCFrame = camera.CFrame

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(1091.34741, 36.3098907, 2335.38208, 0.513874054, 0.263785958, -0.816302955, 0, 0.95155108, 0.307490975, 0.857865691, -0.15801163, 0.488977343)

    throwbomb()

    task.wait(0.6)

    camera.CameraType = oldCameraType
    camera.CFrame = oldCameraCFrame

    if detectPolice("Containerthree") then return end

    plrTween(CFrame.new(1085.97607, 28.6692123, 2344.79199, 0.306023389, -4.15196517e-08, -0.952023983, -2.66976201e-08, 1, -5.21937977e-08, 0.952023983, 4.13892955e-08, 0.306023389))

    firebomb()
    task.wait(3)

    local insidePosition = CFrame.new(1123.5127, 28.6692181, 2315.70459, 0.869538963, 9.47929166e-08, 0.493864357, -8.14743473e-08, 1, -4.84906444e-08, -0.493864357, 1.9272286e-09, 0.869538963)
    plrTween(insidePosition)

    if detectPolice("Containerthree") then return end

    local containerModel = nil
    local closestDistance = math.huge
    local targetPos = Vector3.new(1123.049560546875, 30.690214157104492, 2317.128662109375)

    for attempt = 1, 10 do
        for _, obj in ipairs(workspace.Robberies.ContainerRobberies:GetDescendants()) do
            if obj:IsA("MeshPart") and obj.Name == "Base" then
                local parentModel = obj.Parent
                if parentModel and parentModel:IsA("Model") and parentModel.Name == "ContainerRobbery" then
                    local dist = (obj.Position - targetPos).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        containerModel = parentModel
                    end
                end
            end
        end
        if containerModel then break end
        task.wait(0.5)
    end

    if not containerModel then
        return
    end

local Range = 30
local CollectTime = ProximityPromptTimeBet
local root = character:WaitForChild("HumanoidRootPart")

local function getTransparencyTarget(item)
    local target = nil
    
    if item:IsA("Model") then
        target = item:FindFirstChild("Main", true) or item:FindFirstChild("Handle", true)
    elseif item:IsA("MeshPart") then
        target = item
    end
    
    return target
end

local function isItemCollectable(target)
    if not target or not target:IsA("MeshPart") then return false end
    return target.Transparency == 0
end

local Collected = {}

local function collectFolder(folderName, collectCode)
    local folder = containerModel:FindFirstChild(folderName)
    if not folder then 
        return 
    end
    
    local totalCollected = 0
    local maxRounds = 5
    
    for round = 1, maxRounds do
        local itemsToCollect = {}

        for _, item in ipairs(folder:GetChildren()) do
            local target = getTransparencyTarget(item)
            if isItemCollectable(target) and not Collected[target] then
                local distance = (target.Position - root.Position).Magnitude
                if distance <= Range then
                    table.insert(itemsToCollect, {item = item, target = target})
                end
            end
        end
        
        if #itemsToCollect == 0 then
            break
        end

        for _, data in ipairs(itemsToCollect) do
            Collected[data.target] = true
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, true)
            end)
        end
        
        task.wait(CollectTime)

        for _, data in ipairs(itemsToCollect) do
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, false)
            end)
        end
        
        task.wait(0.8)

        local roundCollected = 0
        for _, data in ipairs(itemsToCollect) do
            if data.target and data.target.Parent and data.target.Transparency == 0 then

                Collected[data.target] = nil
            else
                roundCollected = roundCollected + 1
            end
        end
        
        totalCollected = totalCollected + roundCollected
        task.wait(0.3)
    end

    local distantItems = {}
    for _, item in ipairs(folder:GetChildren()) do
        local target = getTransparencyTarget(item)
        if isItemCollectable(target) and not Collected[target] then
            local distance = (target.Position - root.Position).Magnitude
            if distance > Range then
                table.insert(distantItems, {item = item, target = target, distance = distance})
            end
        end
    end
    
    if #distantItems > 0 then
        table.sort(distantItems, function(a, b) return a.distance < b.distance end)
        for _, data in ipairs(distantItems) do
            local targetPos = data.target.Position + Vector3.new(0, 2, 0)
            plrTween(CFrame.new(targetPos))
            task.wait(0.3)

            local nearbyBatch = {}
            for _, otherData in ipairs(distantItems) do
                if isItemCollectable(otherData.target) and not Collected[otherData.target] then
                    local dist = (otherData.target.Position - data.target.Position).Magnitude
                    if dist <= 20 then
                        table.insert(nearbyBatch, otherData)
                        Collected[otherData.target] = true
                    end
                end
            end

            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, true)
                end)
            end
            task.wait(CollectTime)
            
            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, false)
                end)
            end
            task.wait(0.6)

            local batchCollected = 0
            for _, batchData in ipairs(nearbyBatch) do
                if not (batchData.target and batchData.target.Parent and batchData.target.Transparency == 0) then
                    batchCollected = batchCollected + 1
                end
            end
            
            totalCollected = totalCollected + batchCollected
            task.wait(0.2)
        end
    end
    
    ===\n")
end

collectFolder("Items", GOLD_COLLECT_CODE)
task.wait(0.6)

collectFolder("Money", MONEY_COLLECT_CODE)

    frameTween(contaregion)
    containerthreelock = true
    containerthreeLockTime = os.time()
end

function ContainerfourRob()
    updateHealthTracking()

    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)

    frameTween(CFrame.new(1055.54541, 3.59994721, 2294.27759, -0.99944365, -0.00769293215, -0.0324539281, -0.00762391789, 0.99996841, -0.00224973587, 0.0324702077, -0.00200105808, -0.999470711))
    task.wait(0.9)

    if detectPolice("Containerfour") then return end

    local character = LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Sit = false
    task.wait(0.5)

    if detectPolice("Containerfour") then return end

    plrTween(CFrame.new(1087.47437, 28.66922, 2298.15137, -0.0557407849, -1.75191843e-08, -0.998445272, 1.76595538e-08, 1, -1.85323543e-08, 0.998445272, -1.8665105e-08, -0.0557407849))
    task.wait(0.7)

    if detectPolice("Containerfour") then return end

    plrTween(CFrame.new(1170.84509, 28.6692219, 2308.52148, -0.490529925, 2.37054709e-09, 0.871424317, 1.58402962e-08, 1, 6.19628393e-09, -0.871424317, 1.68430834e-08, -0.490529925))

    bombequip()
    task.wait(0.3)

    if detectPolice("Containerfour") then return end

    local camera = workspace.CurrentCamera
    local oldCameraType = camera.CameraType
    local oldCameraCFrame = camera.CFrame

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(1181.77356, 33.1883469, 2302.37012, -0.490502506, -0.204551771, 0.847092628, 0, 0.972061038, 0.234728515, -0.871439815, 0.115134925, -0.476798326)

    throwbomb()

    task.wait(0.6)

    camera.CameraType = oldCameraType
    camera.CFrame = oldCameraCFrame

    if detectPolice("Containerfour") then return end

    plrTween(CFrame.new(1195.85474, 28.6692219, 2302.28784, -0.217762381, -2.64874593e-08, 0.976001799, -7.21264186e-08, 1, 1.10461249e-08, -0.976001799, -6.79900864e-08, -0.217762381))

    firebomb()
    task.wait(3)

    local insidePosition = CFrame.new(1151.65234, 28.6692142, 2320.79492, -0.870159745, -2.83185564e-09, -0.492769748, -1.32131639e-08, 1, 1.75857124e-08, 0.492769748, 2.18134275e-08, -0.870159745)
    plrTween(insidePosition)

    if detectPolice("Containerfour") then return end

    local containerModel = nil
    local closestDistance = math.huge
    local targetPos = Vector3.new(1151.72705078125, 30.690214157104492, 2319.04638671875)

    for attempt = 1, 10 do
        for _, obj in ipairs(workspace.Robberies.ContainerRobberies:GetDescendants()) do
            if obj:IsA("MeshPart") and obj.Name == "Base" then
                local parentModel = obj.Parent
                if parentModel and parentModel:IsA("Model") and parentModel.Name == "ContainerRobbery" then
                    local dist = (obj.Position - targetPos).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        containerModel = parentModel
                    end
                end
            end
        end
        if containerModel then break end
        task.wait(0.5)
    end

    if not containerModel then
        return
    end

local Range = 30
local CollectTime = ProximityPromptTimeBet
local root = character:WaitForChild("HumanoidRootPart")

local function getTransparencyTarget(item)
    local target = nil
    
    if item:IsA("Model") then
        target = item:FindFirstChild("Main", true) or item:FindFirstChild("Handle", true)
    elseif item:IsA("MeshPart") then
        target = item
    end
    
    return target
end

local function isItemCollectable(target)
    if not target or not target:IsA("MeshPart") then return false end
    return target.Transparency == 0
end

local Collected = {}

local function collectFolder(folderName, collectCode)
    local folder = containerModel:FindFirstChild(folderName)
    if not folder then 
        return 
    end
    
    local totalCollected = 0
    local maxRounds = 5
    
    for round = 1, maxRounds do
        local itemsToCollect = {}

        for _, item in ipairs(folder:GetChildren()) do
            local target = getTransparencyTarget(item)
            if isItemCollectable(target) and not Collected[target] then
                local distance = (target.Position - root.Position).Magnitude
                if distance <= Range then
                    table.insert(itemsToCollect, {item = item, target = target})
                end
            end
        end
        
        if #itemsToCollect == 0 then
            break
        end

        for _, data in ipairs(itemsToCollect) do
            Collected[data.target] = true
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, true)
            end)
        end
        
        task.wait(CollectTime)

        for _, data in ipairs(itemsToCollect) do
            task.spawn(function()
                RemoteEvents.RobEvent:FireServer(data.target, collectCode, false)
            end)
        end
        
        task.wait(0.8)

        local roundCollected = 0
        for _, data in ipairs(itemsToCollect) do
            if data.target and data.target.Parent and data.target.Transparency == 0 then

                Collected[data.target] = nil
            else
                roundCollected = roundCollected + 1
            end
        end
        
        totalCollected = totalCollected + roundCollected
        task.wait(0.3)
    end

    local distantItems = {}
    for _, item in ipairs(folder:GetChildren()) do
        local target = getTransparencyTarget(item)
        if isItemCollectable(target) and not Collected[target] then
            local distance = (target.Position - root.Position).Magnitude
            if distance > Range then
                table.insert(distantItems, {item = item, target = target, distance = distance})
            end
        end
    end
    
    if #distantItems > 0 then
        table.sort(distantItems, function(a, b) return a.distance < b.distance end)
        for _, data in ipairs(distantItems) do
            local targetPos = data.target.Position + Vector3.new(0, 2, 0)
            plrTween(CFrame.new(targetPos))
            task.wait(0.3)

            local nearbyBatch = {}
            for _, otherData in ipairs(distantItems) do
                if isItemCollectable(otherData.target) and not Collected[otherData.target] then
                    local dist = (otherData.target.Position - data.target.Position).Magnitude
                    if dist <= 20 then
                        table.insert(nearbyBatch, otherData)
                        Collected[otherData.target] = true
                    end
                end
            end

            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, true)
                end)
            end
            task.wait(CollectTime)
            
            for _, batchData in ipairs(nearbyBatch) do
                task.spawn(function()
                    RemoteEvents.RobEvent:FireServer(batchData.target, collectCode, false)
                end)
            end
            task.wait(0.6)

            local batchCollected = 0
            for _, batchData in ipairs(nearbyBatch) do
                if not (batchData.target and batchData.target.Parent and batchData.target.Transparency == 0) then
                    batchCollected = batchCollected + 1
                end
            end
            
            totalCollected = totalCollected + batchCollected
            task.wait(0.2)
        end
    end
    
    ===\n")
end

collectFolder("Items", GOLD_COLLECT_CODE)
task.wait(0.6)

collectFolder("Money", MONEY_COLLECT_CODE)

    frameTween(contaregion)
    containerfourlock = true
    containerfourLockTime = os.time()
end

local MAX_DISTANCE = 70
local BATCH_RADIUS = 20

local MAX_DISTANCE = 70
local BATCH_RADIUS = 20

local function collectMoney(robberyType)
    local drops = workspace:WaitForChild("Drops")
    local playerName = player.Name

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    while true do
        local moneys = {}

        for _, drop in ipairs(drops:GetChildren()) do
            if drop:IsA("MeshPart")
                and drop.Name == playerName
                and drop.Transparency == 0
                and (drop.Position - rootPart.Position).Magnitude <= MAX_DISTANCE then
                table.insert(moneys, drop)
            end
        end

        if #moneys == 0 then
            return true
        end

        table.sort(moneys, function(a, b)
            return (a.Position - rootPart.Position).Magnitude <
                   (b.Position - rootPart.Position).Magnitude
        end)

        if detectPolice(robberyType) then
            lockRobbery(robberyType)
            return false
        end

        local targetMoney = moneys[1]
        local targetPos = targetMoney.Position

        plrTween(CFrame.new(targetPos + Vector3.new(0, 3, 0)))
        task.wait(0.35)

        local batch = {}
        for _, m in ipairs(moneys) do
            if m.Parent
                and m.Transparency == 0
                and (m.Position - targetPos).Magnitude <= BATCH_RADIUS then
                table.insert(batch, m)
            end
        end

        for _, m in ipairs(batch) do
            task.spawn(function()
                RemoteEvents.CollectMoney:FireServer(m, CASH_COLLECT_CODE, true)
            end)
        end

        task.wait(ProximityPromptTimeBet)

        for _, m in ipairs(batch) do
            task.spawn(function()
                RemoteEvents.CollectMoney:FireServer(m, CASH_COLLECT_CODE, false)
            end)
        end

        task.wait(0.25)

    end
end

function GasngoRob()
    updateHealthTracking()
    
    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)
    local gasngotopframe = CFrame.new(-1487.17456, 7.25128698, 3748.30493, -0.495812625, -0.0415738374, 0.867433846, 0.0261790343, 0.997684002, 0.0627799481, -0.86803484, 0.0538356714, -0.49357596)
    local tween = frameTween(gasngotopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Gasngo") then return end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.5)

    local gasngodownframe = CFrame.new(-1522.00403, 5.74999905, 3762.99707, -0.0313359685, 7.03007075e-08, 0.999508917, 2.57135344e-08, 1, -6.95290936e-08, -0.999508917, 2.35221442e-08, -0.0313359685)
    tween = plrTween(gasngodownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Gasngo") then return end

    for i = 1, 8 do
        if detectPolice("Gasngo") then return end
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Gasngo") then return end

    local function safeCollectMoney()
        local drops = workspace:WaitForChild("Drops")
        local playerName = LocalPlayer.Name
        local moneys = {}
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end

        for _, drop in pairs(drops:GetChildren()) do
            if drop:IsA("MeshPart") and drop.Name == playerName then
                table.insert(moneys, drop)
                    end
                end

        table.sort(moneys, function(a, b)
            local distA = (a.Position - rootPart.Position).Magnitude
            local distB = (b.Position - rootPart.Position).Magnitude
            return distA < distB
        end)

        local processedMoneys = {}

        for _, money in ipairs(moneys) do
            if money.Parent and money.Transparency == 0 and not processedMoneys[money] then
                if detectPolice("Gasngo") then return false end
                
                local positionAbove = money.Position + Vector3.new(0, 3, 0)
                plrTween(CFrame.new(positionAbove))
                task.wait(0.3)

                local currentPos = money.Position
                local batch = {}
                for _, m in ipairs(moneys) do
                    if m.Parent and m.Transparency == 0 and not processedMoneys[m] then
                        if (m.Position - currentPos).Magnitude <= 20 then
                            table.insert(batch, m)
                            processedMoneys[m] = true
                        end
                    end
                end

                for _, m in ipairs(batch) do
                    task.spawn(function()
                        RemoteEvents.CollectMoney:FireServer(m, CASH_COLLECT_CODE, true)
                    end)
                end
                
                task.wait(ProximityPromptTimeBet)
                
                for _, m in ipairs(batch) do
                    task.spawn(function()
                        RemoteEvents.CollectMoney:FireServer(m, CASH_COLLECT_CODE, false)
                    end)
                end
                
                task.wait(0.2)
            end
        end

        return true
    end

    if not safeCollectMoney() then
        gasngolock = true
        gasngoLockTime = os.time()
        return
    end

    gasngolock = true
    gasngoLockTime = os.time()
end

function AresRob()
    updateHealthTracking()
    
    if not checkBeforeRobbery() then
        return
    end

    task.wait(0.8)
    local arestopframe = CFrame.new(-820.80896, 3.34961104, 1533.9646, 0.999215782, 0.00233023753, -0.0395277292, -0.0023302373, 0.999997377, 4.60725532e-05, 0.0395277292, 4.60725714e-05, 0.999218583)
    local tween = frameTween(arestopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Ares") then return end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
    task.wait(0.6)

    local aresdownframe = CFrame.new(-838.88446, 5.04301119, 1532.31934, 0.0025932698, -9.98028113e-08, 0.999996662, 5.22094545e-08, 1, 9.96677585e-08, -0.999996662, 5.19508134e-08, 0.0025932698)
    tween = plrTween(aresdownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Ares") then return end

    for i = 1, 8 do
        if detectPolice("Ares") then return end
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Ares") then return end

    if not collectMoney("Ares") then
        return
    end

    areslock = true
    aresLockTime = os.time()
end

function OsRob()
    updateHealthTracking()
    
    if not checkBeforeRobbery() then
        returnFromOso()
                return
            end
    fixedY = 2
    
    task.wait(0.8)

    local osotopframe = CFrame.new(-103.620995, 3.30231309, -788.135742, 0.00859444309, -0.0130922208, -0.999877334, -0.0261210296, 0.999570131, -0.0133127216, 0.999621868, 0.0262322407, 0.00824876595)
    local tween = frameTween(osotopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Oso") then 
            return
        end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.5)

    local osodownframe = CFrame.new(-80.0744171, 5.23437977, -782.978699, -0.997873425, -1.41869565e-08, -0.0651813969, -1.72479595e-08, 1, 4.63985792e-08, 0.0651813969, 4.74241553e-08, -0.997873425)
    tween = plrTween(osodownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Oso") then return end

    for i = 1, 8 do
        if detectPolice("Oso") then return end
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Oso") then return end

    if not collectMoney("Oso") then
        returnFromOso()
        return
    end

    osolock = true
    osoLockTime = os.time()
    
    returnFromOso()
end

function returnFromOso()
    frameTween(ossoregionDirect)
    
    end

function ClothingRob()
    updateHealthTracking()
    
    if not checkBeforeRobbery() then
        return
    end
    fixedY = 2
    
    task.wait(0.8)

    frameTween(CFrame.new(88.2787933, 7.23024893, -1533.47449, 0.0209446028, 0.0129613755, -0.999696612, 0.0256774649, 0.999579132, 0.0134978201, 0.999450862, -0.025952382, 0.0206029732))
    local clothingtopframe = CFrame.new(462.993042, 7.0231657, -1390.98059, -0.0195562579, 0.0134410728, -0.999718428, 0.0247208178, 0.999610424, 0.0129560381, 0.999503076, -0.0244604852, -0.0198809132)
    local tween = frameTween(clothingtopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Clothing") then return end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.5)

    local clothingdownframe = CFrame.new(469.563385, 5.25157642, -1406.52063, 0.0608269088, -7.10946537e-08, -0.998148322, 7.95685651e-09, 1, -7.0741649e-08, 0.998148322, -3.63912744e-09, 0.0608269088)
    tween = plrTween(clothingdownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Clothing") then return end

    for i = 1, 8 do
        if detectPolice("Clothing") then return end
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Clothing") then return end

    if not collectMoney("Clothing") then
        fixedY = -1.9
        return
    end

    clothinglock = true
    clothingLockTime = os.time()
    fixedY = -1.9
end

function ToolRob()
    updateHealthTracking()
    
    if checkHealthAndReset() then
        header()
        return
    end

    task.wait(0.8)

    local tooltopframe = CFrame.new(-753.678833, 3.34990263, 594.156799, -0.0383914523, 6.95688504e-05, 0.99926275, -0.000679028803, 0.999999762, -9.57082884e-05, -0.999262571, -0.000682202575, -0.0383913964)
    local tween = frameTween(tooltopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Tool") then return end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.5)

    local tooldownframe = CFrame.new(-756.316284, 5.49396896, 625.586731, -0.999889016, -4.14735197e-08, -0.0148986224, -4.2635353e-08, 1, 7.76650282e-08, 0.0148986224, 7.82916203e-08, -0.999889016)
    tween = plrTween(tooldownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Tool") then return end

    for i = 1, 8 do
        if detectPolice("Tool") then return end
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Tool") then return end

    if not collectMoney("Tool") then
        return
    end

    toollock = true
    toolLockTime = os.time()
end

function FarmRob()
    updateHealthTracking()
    
    if checkHealthAndReset() then
        header()
        frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
        return
    end
    fixedY = 2
    task.wait(0.8)

    frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
    local farmtopframe = CFrame.new(-1001.93323, 6.97521162, -1179.96838, 0.0886971056, 0.0129547976, -0.995974422, 0.0261870977, 0.999539435, 0.0153332772, 0.995714366, -0.0274416953, 0.0883170068)
    local tween = frameTween(farmtopframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.7)
    
    if detectPolice("Farm") then 
        frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
        return
    end

    game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
    task.wait(0.5)

    local farmdownframe = CFrame.new(-963.983215, 7.10850525, -1176.99902, -0.0078917807, -4.42466046e-08, -0.999968886, -5.80421791e-08, 1, -4.37899139e-08, 0.999968886, 5.76947912e-08, -0.0078917807)
    tween = plrTween(farmdownframe)
    if tween then tween.Completed:Wait() end
    task.wait(0.5)
    
    if detectPolice("Farm") then 
        frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
        return
    end

    for i = 1, 8 do
        if detectPolice("Farm") then 
            frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
        return
    end

        game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
        task.wait(0.4)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
        task.wait(0.5)
    end
    
    if detectPolice("Farm") then 
        frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
        return
    end

    if not collectMoney("Farm") then
        fixedY = -1.9
        frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
                return
            end

    farmlock = true
    farmLockTime = os.time()
    fixedY = -1.9
    frameTween(CFrame.new(-1132.73645, 7.11486721, -1582.22986, 0.0542224273, 0.0122450525, -0.998453796, 0.0222424176, 0.999661863, 0.0134677738, 0.998281121, -0.0229382813, 0.0539317355))
end

function BankRob()
    updateHealthTracking()

    if not checkBeforeRobbery() then
        return
    end

    local banktopframe = CFrame.new(
        -1301.02673, 6.98018074, 3141.53247,
        -0.383092284, 0.0222690497, -0.923441589,
         0.0259819776, 0.999573588, 0.0133262994,
         0.923344612, -0.0188876353, -0.38350752
    )
    frameTween(banktopframe)
    task.wait(1)

    if detectPolice("Bank") then return end

    LocalPlayer.Character.Humanoid.Sit = false
    task.wait(0.5)

    local bankdownframe = CFrame.new(
        -1243.18115, 7.72350025, 3147.96069,
        0.999983668, 0, -0.00571381487,
        0, 1, 0,
        0.00571381487, 0, 0.999983668
    )
    plrTween(bankdownframe)
    task.wait(0.3)

    LocalPlayer.Character.HumanoidRootPart.CFrame = bankdownframe
    task.wait(0.2)

    if detectPolice("Bank") then return end

    bombequip()
    task.wait(0.7)

    if not LocalPlayer.Character:FindFirstChild("Bomb") then
        return
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    hrp.Anchored = true

    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(
        -1243.31873, 9.965065, 3155.0752,
        0.999813199, 0.00202784431, -0.0192214325,
        0, 0.994481087, 0.104916885,
        0.0193281025, -0.10489729, 0.994295299
    )

    throwbomb()
    task.wait(0.6)

    cam.CameraType = Enum.CameraType.Custom
    hrp.Anchored = false

    if detectPolice("Bank") then return end

    local firePosition = CFrame.new(-1209.89954, 7.72350025, 3138.69678, -0.188089043, 6.68580213e-08, 0.982151985, 9.63088382e-08, 1, -4.96291648e-08, -0.982151985, 8.52552091e-08, -0.188089043)
    plrTween(firePosition)
    task.wait(0.6)

    firebomb()
    task.wait(3.2)

    if detectPolice("Bank") then return end

    local oldMaxZoom = LocalPlayer.CameraMaxZoomDistance
    LocalPlayer.CameraMaxZoomDistance = RobberyZoomValue

    local bankPositions = {
        CFrame.new(-1251.52, 7.72, 3126.01),
        CFrame.new(-1230.84, 7.72, 3122.70),
        CFrame.new(-1236.18, 7.72, 3102.31),
        CFrame.new(-1248.57, 7.72, 3101.89)
    }

    local goldFolder = workspace.Robberies.BankRobbery.Gold
    local moneyFolder = workspace.Robberies.BankRobbery.Money

    local Range = 20
    local CollectTime = 2.5

    local function collectRegion()
        local root = LocalPlayer.Character.HumanoidRootPart
        local batch = {}

        local function scan(folder, code)
            for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("MeshPart")
                and m.Transparency == 0
                and (m.Position - root.Position).Magnitude <= Range then
                    table.insert(batch, {item = m, code = code})
                end
            end
        end

        scan(goldFolder, GOLD_COLLECT_CODE)
        scan(moneyFolder, MONEY_COLLECT_CODE)

        if #batch == 0 then return end

        for _, v in ipairs(batch) do
            RemoteEvents.RobEvent:FireServer(v.item, v.code, true)
        end

        task.wait(CollectTime)

        for _, v in ipairs(batch) do
            RemoteEvents.RobEvent:FireServer(v.item, v.code, false)
        end
    end

    for _, pos in ipairs(bankPositions) do
        if detectPolice("Bank") then break end

        plrTween(pos)
        task.wait(0.5)

        if detectPolice("Bank") then break end

        collectRegion()

        task.wait(0.5)
    end

    LocalPlayer.CameraMaxZoomDistance = oldMaxZoom
    
    banklock = true
    bankLockTime = os.time()
end

_G.vendingRobberyEnabled = true

function findNearestRobbableVending()
    local vendingFolder = workspace:FindFirstChild("Robberies") and workspace.Robberies:FindFirstChild("VendingMachines")
    if not vendingFolder then return nil end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local nearestVending = nil
    local minDistance = math.huge
    local targetColor = Color3.fromRGB(73, 147, 0)

    for _, model in ipairs(vendingFolder:GetChildren()) do
        local light = model:FindFirstChild("Light")
        local glass = model:FindFirstChild("Glass")
        if light and glass and light:IsA("BasePart") and light.Color == targetColor then
            local dist = (glass.Position - root.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestVending = model
            end
        end
    end

    return nearestVending
end

function collectVendingDrops()
    local dropsFolder = workspace:FindFirstChild("Drops")
    if not dropsFolder then return end
    
    local myName = LocalPlayer.Name
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local range = 30
    local waitTime = 2.5
    local batch = {}
    
    for _, obj in ipairs(dropsFolder:GetChildren()) do
        if obj.Name == myName and obj:IsA("MeshPart") and obj.Transparency == 0 then
            if (obj.Position - root.Position).Magnitude <= range then
                table.insert(batch, obj)
            end
        end
    end
    
    if #batch > 0 then
        for _, item in ipairs(batch) do
            RemoteEvents.RobEvent:FireServer(item, VENDING_COLLECT_CODE, true)
        end
        
        task.wait(waitTime)
        
        for _, item in ipairs(batch) do
            RemoteEvents.RobEvent:FireServer(item, VENDING_COLLECT_CODE, false)
        end
    end
end

function VendingRob(targetVending, associatedRegionCFrame, nextRegionCFrame)
    if not targetVending then return false end
    
    local glass = targetVending:FindFirstChild("Glass")
    if not glass then return false end

    local targetPosition = glass.Position - glass.CFrame.LookVector * 12 + Vector3.new(0, 3, 0)
    local lookDirection = glass.CFrame.RightVector
    local vehicleCFrame = CFrame.lookAt(targetPosition, targetPosition + lookDirection)
    
    frameTween(vehicleCFrame)
    task.wait(0.8)
    
    if detectPolice("Vending") then
        if _G.vendingPriority == "After Main Robberys" then
            frameTween(nextRegionCFrame)
        else
            frameTween(associatedRegionCFrame)
        end
        return "Police"
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Sit = false
    end
    task.wait(0.9)

    local offsetPosition = glass.Position - glass.CFrame.LookVector * 1.6
    local charCFrame = CFrame.lookAt(offsetPosition, glass.Position)
    
    plrTween(charCFrame)
    task.wait(0.8)

    for i = 1, 7 do
        if detectPolice("Vending") then
            if _G.vendingPriority == "After Main Robberys" then
                frameTween(nextRegionCFrame)
            else
                frameTween(associatedRegionCFrame)
            end
            return "Police"
        end
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.4)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        task.wait(1)
    end
    
    task.wait(0.8)
    collectVendingDrops()
    task.wait(1.2)
    
    return true
end

function handleVendingRobbery(associatedRegionCFrame, nextRegionCFrame)
    if not _G.vendingRobberyEnabled then return end
    if not _G.gasRegionReached and _G.vendingPriority == "Before Main Robberys" then
        return 
    end
    
    local count = 0
    while true do
        local target = findNearestRobbableVending()
        if not target or (LocalPlayer.Character and (target.Glass.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 1500) then 
            break 
        end
        
        local result = VendingRob(target, associatedRegionCFrame, nextRegionCFrame)
        if result == "Police" then return "Stop" end
        if not result then break end
        
        count = count + 1
        task.wait(0.5)
    end
    
    if count > 0 then
        else
        end
end

function JewelleryRob()   
    local character = LocalPlayer.Character
    if not character then return end
    
    local jewtopframe = CFrame.new(-481.290802, 3.43016648, 3588.20068, -0.9988451, -0.0456783809, -0.0148961162, -0.0457027592, 0.998954237, 0.00130001642, 0.0148211559, 0.00197930867, -0.999888182)
    frameTween(jewtopframe)
    task.wait(1)
    task.wait(0.4)
    if detectPolice("Jewellery") then return end

    character:WaitForChild("Humanoid").Sit = false
    task.wait(0.3)
    if detectPolice("Jewellery") then return end
    
    local jewdownframe = CFrame.new(-454.291565, 5.47350025, 3590.7356, 0.939660847, 4.74632067e-08, -0.342107415, -2.46366287e-08, 1, 7.10687047e-08, 0.342107415, -5.83521107e-08, 0.939660847)
    plrTween(jewdownframe)
    task.wait(0.3)
    if detectPolice("Jewellery") then return end
    
    local jewrofframe = CFrame.new(-432.8013, 21.2489128, 3553.14917, -0.0300017595, -6.28074837e-09, 0.999549866, 2.38728326e-08, 1, 7.0001267e-09, -0.999549866, 2.40721025e-08, -0.0300017595)
    plrTween(jewrofframe)
    task.wait(0.3)
    if detectPolice("Jewellery") then return end
    task.wait(0.3)

    bombequip()
    task.wait(0.7)
    
    local hasBomb = false
    for i = 1, 5 do
        if character and character:FindFirstChild("Bomb") then
            hasBomb = true
            break
        end
        , tekrar deneniyor... (" .. i .. "/5)")
        bombequip()
        task.wait(0.6)
    end
    
    if not hasBomb then
        return
    end

    local hrp = character.HumanoidRootPart
    hrp.Anchored = true

    local cam = workspace.CurrentCamera
    local throwLoopActive = true
    
    task.spawn(function()
        while throwLoopActive do
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = jewrofframe
            end
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(-423.067627, 24.6382923, 3552.87402, -0.0282642469, -0.191288933, 0.981126726, 0, 0.981518865, 0.191365391, -0.99960047, 0.00540879881, -0.0277418923)
            task.wait()
        end
        cam.CameraType = Enum.CameraType.Custom
    end)
        
    throwbomb()
    task.wait(0.6)

    throwLoopActive = false
    hrp.Anchored = false
    
    if detectPolice("Jewellery") then return end
    
    plrTween(CFrame.new(-417.024048, 21.2234135, 3552.44507, -0.0595121533, 1.0978416e-07, 0.998227596, 7.88180401e-08, 1, -1.0528013e-07, -0.998227596, 7.24128952e-08, -0.0595121533))
    task.wait(1)
    
    if detectPolice("Jewellery") then return end
    
    firebomb()
    task.wait(2.8)
    
    if detectPolice("Jewellery") then return end
    
    plrTween(CFrame.new(-439.899506, 21.2234135, 3553.3667, -0.00728186127, -1.80085582e-08, 0.999973476, -5.53522383e-08, 1, 1.76059576e-08, -0.999973476, -5.52225679e-08, -0.00728186127))
    task.wait(0.3)
    
    if detectPolice("Jewellery") then return end

    local oldMaxZoom = LocalPlayer.CameraMaxZoomDistance
    LocalPlayer.CameraMaxZoomDistance = RobberyZoomValue

    local itemsFolder = workspace:WaitForChild("Robberies"):WaitForChild("Jeweler Safe Robbery"):WaitForChild("Jeweler"):WaitForChild("Items")
    local moneyFolder = workspace:WaitForChild("Robberies"):WaitForChild("Jeweler Safe Robbery"):WaitForChild("Jeweler"):WaitForChild("Money")
    
    local Collected = {}
    local Range = 40
    local ProximityPromptTimeBetjewellery = 2.5

    local function jewelleryLoot(folder)
        for _, m in ipairs(folder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and not Collected[m] and (m.Position - rootPart.Position).Magnitude <= Range then
                    Collected[m] = true
                    task.spawn(function()
                        local code = (folder == moneyFolder) and MONEY_COLLECT_CODE or GOLD_COLLECT_CODE
                        : " .. m.Name .. " | Transparency: " .. m.Transparency .. " | Code: " .. code)
                        RemoteEvents.RobEvent:FireServer(m, code, true)
                        task.wait(ProximityPromptTimeBetjewellery)
                        RemoteEvents.RobEvent:FireServer(m, code, false)
                        task.wait(0.5)
                        
                        if m and m.Parent and m.Transparency == 0 then
                            : " .. m.Name .. " (Transparency: 0) - Will retry")
                            Collected[m] = nil
                        else
                            : " .. m.Name .. " (Transparency: " .. (m and m.Transparency or 1) .. ")")
                        end
                    end)
                end
            end
        end
    end

    local startTime = tick()
    local maxDuration = 15
    
    while tick() - startTime < maxDuration do
        if detectPolice("Jewellery") then 
            break 
        end
        
        jewelleryLoot(itemsFolder)
        jewelleryLoot(moneyFolder)
        
        local visibleItems = 0
        for _, m in ipairs(itemsFolder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and (m.Position - rootPart.Position).Magnitude <= Range then
                    visibleItems = visibleItems + 1
                end
            end
        end
        for _, m in ipairs(moneyFolder:GetDescendants()) do
            if m:IsA("MeshPart") and m.Transparency == 0 then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart and (m.Position - rootPart.Position).Magnitude <= Range then
                    visibleItems = visibleItems + 1
                end
            end
        end
        
        if visibleItems == 0 then
            local elapsed = math.floor(tick() - startTime)
            ")
            break
        end
        
        task.wait(0.5)
    end

    if oldMaxZoom > 0 then
        game.Players.LocalPlayer.CameraMaxZoomDistance = oldMaxZoom
    end
   
    if detectPolice("Jewellery") then return end

    if _G.jewelerExtraSelections["Diamond"] then
        local diamondPodium = workspace.Robberies["Jeweler Robbery"].Robbables["Diamond Podium"].Collectables.Diamond
        
        if diamondPodium and diamondPodium.Transparency == 0 then
            if detectPolice("Jewellery") then return end
            
            local diamondCFrame = CFrame.new(-423.879089, 21.2489128, 3587.24756, 0.999997258, 1.02761692e-08, -0.00233996939, -1.03946416e-08, 1, -5.06175333e-08, 0.00233996939, 5.06417166e-08, 0.999997258)
            plrTween(diamondCFrame)
            task.wait(0.5)
            
            if detectPolice("Jewellery") then return end
            
            for i = 1, 7 do
                if detectPolice("Jewellery") then return end
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
                task.wait(0.4)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
                task.wait(0.5)
            end
            
            if detectPolice("Jewellery") then return end
            RemoteEvents.RobEvent:FireServer(diamondPodium, GOLD_COLLECT_CODE, true)
            task.wait(ProximityPromptTimeBetjewellery)
            RemoteEvents.RobEvent:FireServer(diamondPodium, GOLD_COLLECT_CODE, false)
            task.wait(0.5)
            else
            end
    else
        end
    
    if detectPolice("Jewellery") then return end

    if _G.jewelerExtraSelections["Jewelry"] then
        local showcasePaths = {
            {
                name = "Jewelry Showcase",
                path = workspace.Robberies["Jeweler Robbery"].Robbables["Jewelry Showcase"],
                cframe = CFrame.new(-406.561066, 21.2234135, 3581.77393, 0.0178751759, 1.05797939e-08, -0.9998402, -1.20152732e-08, 1, 1.03666746e-08, 0.9998402, 1.18280479e-08, 0.0178751759)
            },
            {
                name = "GetChildren 15",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[15],
                cframe = CFrame.new(-440.92984, 21.2234135, 3588.10767, 0.00606308132, -8.49699475e-08, 0.999981642, 2.00910328e-08, 1, 8.48496882e-08, -0.999981642, 1.95762127e-08, 0.00606308132)
            },
            {
                name = "GetChildren 13",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[13],
                cframe = CFrame.new(-406.395996, 21.2234135, 3588.01196, -0.0207704362, 9.39381692e-08, -0.999784291, -2.21126566e-08, 1, 9.44178282e-08, 0.999784291, 2.4068985e-08, -0.0207704362)
            },
            {
                name = "GetChildren 9",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[9],
                cframe = CFrame.new(-441.302094, 21.2234135, 3581.63452, -0.0207861494, -6.09569497e-08, 0.999783933, 8.53050039e-08, 1, 6.27436663e-08, -0.999783933, 8.65907737e-08, -0.0207861494)
            }
        }

        local validShowcases = {}
        for _, showcaseData in ipairs(showcasePaths) do
            if showcaseData.path and showcaseData.path:FindFirstChild("Collectables") then
                local collectables = showcaseData.path.Collectables
                local jewelryCount = 0
                local jewelryItems = {}
                
                for _, child in ipairs(collectables:GetChildren()) do
                    if child.Name == "Jewelry" and child:IsA("MeshPart") and child.Transparency == 0 then
                        jewelryCount = jewelryCount + 1
                        table.insert(jewelryItems, child)
                    end
                end
                
                if jewelryCount > 0 then
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local distance = rootPart and (showcaseData.path:GetPivot().Position - rootPart.Position).Magnitude or 999
                    table.insert(validShowcases, {
                        name = showcaseData.name,
                        path = showcaseData.path,
                        cframe = showcaseData.cframe,
                        jewelryCount = jewelryCount,
                        jewelryItems = jewelryItems,
                        distance = distance
                    })
                end
            end
        end

        table.sort(validShowcases, function(a, b)
            if a.jewelryCount ~= b.jewelryCount then
                return a.jewelryCount > b.jewelryCount
            end
            return a.distance < b.distance
        end)

        for _, model in ipairs(validShowcases) do
            if detectPolice("Jewellery") then return end
            ...")
            plrTween(model.cframe)
            task.wait(0.5)
            
            if detectPolice("Jewellery") then return end
            
            for i = 1, 7 do
                if detectPolice("Jewellery") then return end
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
                task.wait(0.4)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
                task.wait(0.5)
            end
            
            if detectPolice("Jewellery") then return end

            for _, jewelry in ipairs(model.jewelryItems) do
                if jewelry and jewelry.Parent and jewelry.Transparency == 0 then
                    RemoteEvents.RobEvent:FireServer(jewelry, GOLD_COLLECT_CODE, true)
                end
            end

            task.wait(ProximityPromptTimeBetjewellery)

            for _, jewelry in ipairs(model.jewelryItems) do
                if jewelry and jewelry.Parent then
                    RemoteEvents.RobEvent:FireServer(jewelry, GOLD_COLLECT_CODE, false)
                end
            end
            
            task.wait(0.3)
        end
    else
        end
    
    if detectPolice("Jewellery") then return end

    if _G.jewelerExtraSelections["Diamond"] then
        local extraDiamondParent = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[12]
        
        if extraDiamondParent and extraDiamondParent:FindFirstChild("Collectables") then
            local extraDiamond = extraDiamondParent.Collectables:FindFirstChild("Diamond")
            
            if extraDiamond and extraDiamond.Transparency == 0 then
                if detectPolice("Jewellery") then return end
                
                local extraCFrame = CFrame.new(-415.241364, 5.47350025, 3594.17798, 0.66206181, 5.78554404e-09, 0.749449253, -1.44117092e-08, 1, 5.01154407e-09, -0.749449253, -1.41187968e-08, 0.66206181)
                plrTween(extraCFrame)
                task.wait(0.5)
                
                if detectPolice("Jewellery") then return end
                
                for i = 1, 7 do
                    if detectPolice("Jewellery") then return end
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
                    task.wait(0.4)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
                    task.wait(0.5)
                end
                
                if detectPolice("Jewellery") then return end
                RemoteEvents.RobEvent:FireServer(extraDiamond, GOLD_COLLECT_CODE, true)
                task.wait(ProximityPromptTimeBetjewellery)
                RemoteEvents.RobEvent:FireServer(extraDiamond, GOLD_COLLECT_CODE, false)
                task.wait(0.5)
                else
                end
        end
    else
         end
    
    if detectPolice("Jewellery") then return end

    if _G.jewelerExtraSelections["Jewelry"] then
        local multiPaths = {
            {
                name = "GetChildren 10",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[10],
                cframe = CFrame.new(-433.89801, 5.47350025, 3585.26953, 0.000750784006, 7.01781602e-08, -0.999999702, -3.49757414e-08, 1, 7.01519198e-08, 0.999999702, 3.49230618e-08, 0.000750784006)
            },
            {
                name = "GetChildren 14",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[14],
                cframe = CFrame.new(-424.293701, 5.47350025, 3595.58618, 0.999185622, -1.99806607e-08, 0.0403493606, 1.97817176e-08, 1, 5.32977174e-09, -0.0403493606, -4.52725191e-09, 0.999185622)
            },
            {
                name = "GetChildren 5",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[5],
                cframe = CFrame.new(-413.953491, 5.47350025, 3585.53589, -0.022315478, 2.13919176e-08, 0.999750972, -1.07849134e-08, 1, -2.16379767e-08, -0.999750972, -1.12650893e-08, -0.022315478)
            },
            {
                name = "Jewelry Showdesk",
                path = workspace.Robberies["Jeweler Robbery"].Robbables["Jewelry Showdesk"],
                cframe = CFrame.new(-414.428345, 5.47350025, 3568.41504, -0.0168970674, 2.56097743e-09, 0.999857247, -1.07554676e-08, 1, -2.74310485e-09, -0.999857247, -1.08002824e-08, -0.0168970674)
            },
            {
                name = "GetChildren 11",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[11],
                cframe = CFrame.new(-423.935577, 5.47350025, 3558.4209, -0.9998613, 1.45381218e-08, -0.0166554824, 1.28150992e-08, 1, 1.03557504e-07, 0.0166554824, 1.03329697e-07, -0.9998613)
            },
            {
                name = "GetChildren 7",
                path = workspace.Robberies["Jeweler Robbery"].Robbables:GetChildren()[7],
                cframe = CFrame.new(-434.596832, 5.47350025, 3568.54126, 0.0263342224, -1.19114407e-09, -0.99965322, 3.06372994e-09, 1, -1.1108483e-09, 0.99965322, -3.03341396e-09, 0.0263342224)
            }
        }

        local validMultiModels = {}
        for _, modelData in ipairs(multiPaths) do
            if modelData.path and modelData.path:FindFirstChild("Collectables") then
                local collectables = modelData.path.Collectables
                local visibleCount = 0
                local visibleItems = {}
                
                for _, child in ipairs(collectables:GetChildren()) do
                    if child:IsA("MeshPart") and child.Transparency == 0 then
                        visibleCount = visibleCount + 1
                        table.insert(visibleItems, child)
                    end
                end
                
                if visibleCount > 0 then
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local distance = rootPart and (modelData.path:GetPivot().Position - rootPart.Position).Magnitude or 999
                    table.insert(validMultiModels, {
                        name = modelData.name,
                        path = modelData.path,
                        cframe = modelData.cframe,
                        visibleCount = visibleCount,
                        visibleItems = visibleItems,
                        distance = distance
                    })
                end
            end
        end

        table.sort(validMultiModels, function(a, b)
            if a.visibleCount ~= b.visibleCount then
                return a.visibleCount > b.visibleCount
            end
            return a.distance < b.distance
        end)

        for _, model in ipairs(validMultiModels) do
            if detectPolice("Jewellery") then return end
            ...")
            plrTween(model.cframe)
            task.wait(0.5)
            
            if detectPolice("Jewellery") then return end
            
            for i = 1, 7 do
                if detectPolice("Jewellery") then return end
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "F", false, game)
                task.wait(0.4)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "F", false, game)
                task.wait(0.5)
            end
            
            if detectPolice("Jewellery") then return end

            for _, item in ipairs(model.visibleItems) do
                if item and item.Parent and item.Transparency == 0 then
                    RemoteEvents.RobEvent:FireServer(item, GOLD_COLLECT_CODE, true)
                end
            end

            task.wait(ProximityPromptTimeBetjewellery)

            for _, item in ipairs(model.visibleItems) do
                if item and item.Parent then
                    RemoteEvents.RobEvent:FireServer(item, GOLD_COLLECT_CODE, false)
                end
            end
            
            task.wait(0.3)
        end
    else
        end
    
    if detectPolice("Jewellery") then return end
    
    jewellerylock = true
    jewelleryLockTime = os.time()
   
    end

local function lockCameraToTarget(target)
    local camera = workspace.CurrentCamera
    if target and target.Parent then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

function updateLocks()
    if clublock then
        local currentTime = os.time()
        if not clubLockTime then
            clubLockTime = currentTime
        elseif currentTime - clubLockTime >= locktime then
            clublock = false
            clubLockTime = nil
            end
    end

    if banklock then
        local currentTime = os.time()
        if not bankLockTime then
            bankLockTime = currentTime
        elseif currentTime - bankLockTime >= locktime then
            banklock = false
            bankLockTime = nil
            end
    end

    if jewellerylock then
        local currentTime = os.time()
        if not jewelleryLockTime then
            jewelleryLockTime = currentTime
        elseif currentTime - jewelleryLockTime >= locktime then
            jewellerylock = false
            jewelleryLockTime = nil
            end
    end
    
    if gasngolock then
        local currentTime = os.time()
        if not gasngoLockTime then
            gasngoLockTime = currentTime
        elseif currentTime - gasngoLockTime >= locktime then
            gasngolock = false
            gasngoLockTime = nil
            end
    end

    if containeronelock then
    local currentTime=os.time()
    if not containeroneLockTime then
        containeroneLockTime=currentTime
    elseif currentTime-containeroneLockTime>=locktime then
        containeronelock=false
        containeroneLockTime=nil
        end
end

if containertwolock then
    local currentTime=os.time()
    if not containertwoLockTime then
        containertwoLockTime=currentTime
    elseif currentTime-containertwoLockTime>=locktime then
        containertwolock=false
        containertwoLockTime=nil
        end
end

if containerthreelock then
    local currentTime=os.time()
    if not containerthreeLockTime then
        containerthreeLockTime=currentTime
    elseif currentTime-containerthreeLockTime>=locktime then
        containerthreelock=false
        containerthreeLockTime=nil
        end
end

if containerfourlock then
    local currentTime=os.time()
    if not containerfourLockTime then
        containerfourLockTime=currentTime
    elseif currentTime-containerfourLockTime>=locktime then
        containerfourlock=false
        containerfourLockTime=nil
        end
end

    if toollock then
        local currentTime = os.time()
        if not toolLockTime then
            toolLockTime = currentTime
        elseif currentTime - toolLockTime >= locktime then
            toollock = false
            toolLockTime = nil
            end
    end

    if clothinglock then
        local currentTime = os.time()
        if not clothingLockTime then
            clothingLockTime = currentTime
        elseif currentTime - clothingLockTime >= locktime then
            clothinglock = false
            clothingLockTime = nil
            end
    end

    if areslock then
        local currentTime = os.time()
        if not aresLockTime then
            aresLockTime = currentTime
        elseif currentTime - aresLockTime >= locktime then
            areslock = false
            aresLockTime = nil
            end
    end
    
    if farmlock then
        local currentTime = os.time()
        if not farmLockTime then
            farmLockTime = currentTime
        elseif currentTime - farmLockTime >= locktime then
            farmlock = false
            farmLockTime = nil
            end
    end
    
    if osolock then
        local currentTime = os.time()
        if not osoLockTime then
            osoLockTime = currentTime
        elseif currentTime - osoLockTime >= locktime then
            osolock = false
            osoLockTime = nil
            end

                end

            end

function checkBeforeRobbery()
    if isRespawning or not isHeaderRunning then
        .. ", Header: " .. tostring(isHeaderRunning))
        return false
    end
    
    if checkHealthAndReset() then
        return false
    end
    
    return true
end

task.spawn(header)

local OrionLib = loadstring(game:HttpGet("https://moon-hub.pages.dev/orion.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "Autorob", 
    HidePremium = false,
    Intro = false,
    SaveConfig = true, 
    ConfigFolder = "RobberConfig",
    Icon = "rbxassetid://4483345998"
})

_G.vehicleHeight = CurrentConfig.vehicleHeight or -1.9
_G.autoSellEnabled = CurrentConfig.autoSell
_G.autoServerChangerEnabled = CurrentConfig.autoServerChanger
_G.rejoinWhenDead = CurrentConfig.rejoinWhenDead
_G.rejoinWhenKicked = CurrentConfig.rejoinWhenKicked
_G.vendingPriority = CurrentConfig.vendingPriority
_G.saveMoneyBeforeRejoin = CurrentConfig.saveMoneyBeforeRejoin
_G.moneyToSaveValue = CurrentConfig.moneyToSaveValue
_G.selectedRobberies = {}
for _, v in ipairs(CurrentConfig.robberySelection or {}) do
    _G.selectedRobberies[v] = true
end
_G.jewelerExtraSelections = {["Diamond"] = false, ["Jewelry"] = false}
for _, v in ipairs(CurrentConfig.jewelerExtraRobSelection or {}) do
    _G.jewelerExtraSelections[v] = true
end
_G.gasRegionReached = false

local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lastServerId = nil

GuiService.ErrorMessageChanged:Connect(function()
    if not _G.autoServerChangerEnabled then return end

    local IsSingle = #Players:GetPlayers() <= 1
    local PlaceId = game.PlaceId
    local JobId = game.JobId

    if IsSingle or JobId == lastServerId then
        local servers = {}
        local success, result = pcall(function()
            local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
            return HttpService:JSONDecode(req)
        end)

        if success and result and result.data then
            for _, v in ipairs(result.data) do
                if type(v) == "table" and v.playing and v.maxPlayers and v.id and v.id ~= JobId and v.id ~= lastServerId then
                    if v.playing < v.maxPlayers then
                        table.insert(servers, v.id)
                    end
                end
            end
        end

        frameTween(CFrame.new(-882.8184204101562, 5.422455310821533, 3078.771728515625))
        task.wait(300)

        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            lastServerId = targetServer
            frameTween(CFrame.new(-977.154358, 7.05404186, -1901.20703, -0.306000233, 0.120990045, -0.944312036, -0.0297048111, 0.990195334, 0.136494562, 0.951567888, 0.0698179752, -0.299406022))
            TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, LocalPlayer)
        else
            frameTween(CFrame.new(-977.154358, 7.05404186, -1901.20703, -0.306000233, 0.120990045, -0.944312036, -0.0297048111, 0.990195334, 0.136494562, 0.951567888, 0.0698179752, -0.299406022))
            TeleportService:Teleport(PlaceId, LocalPlayer)
        end
    else

        frameTween(CFrame.new(-882.8184204101562, 5.422455310821533, 3078.771728515625))
        task.wait(300)

        lastServerId = JobId
        frameTween(CFrame.new(-977.154358, 7.05404186, -1901.20703, -0.306000233, 0.120990045, -0.944312036, -0.0297048111, 0.990195334, 0.136494562, 0.951567888, 0.0698179752, -0.299406022))
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
    end
end)

local Tab1 = Window:MakeTab({
	Name = "Autorob ",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local OptionsTab = Window:MakeTab({
    Name = "Rob Selections",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
	Name = "Settings",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local ConfigTab = Window:MakeTab({
	Name = "Config",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab1:AddToggle({
    Name = "Auto Sell",
    Default = CurrentConfig.autoSell,
    Save = true,
    Flag = "autoSell",
    Callback = function(Value)
        _G.autoSellEnabled = Value
        CurrentConfig.autoSell = Value
        SaveConfig()
    end    
})

Tab1:AddToggle({
    Name = "ServerHop",
    Default = CurrentConfig.autoServerChanger,
    Save = true,
    Flag = "autoServerChanger",
    Callback = function(Value)
        _G.autoServerChangerEnabled = Value
        CurrentConfig.autoServerChanger = Value
        SaveConfig()
    end    
})

OptionsTab:AddMultiSelect({
    Name = "Robbery Selection",
    Options = {"Bank", "Club", "Jewellery", "GasnGo", "Container 1", "Container 2", "Container 3", "Container 4", "Ares Fuel", "Tool Shop", "Farm Shop", "Osso Fuel", "Clothing Store"},
    Default = CurrentConfig.robberySelection,
    Flag = "robberySelection",
    Callback = function(Value)
        local newSelections = {}
        for _, v in ipairs(Value) do
            newSelections[v] = true
        end
        _G.selectedRobberies = newSelections
        CurrentConfig.robberySelection = Value
        SaveConfig()
    end    
})

OptionsTab:AddMultiSelect({
    Name = "Jeweler Extra Robbery Selection",
    Options = {"Diamond", "Jewelry"},
    Default = CurrentConfig.jewelerExtraRobSelection, 
    Flag = "jewelerExtraRobSelection", 
    Callback = function(Value)
        local newSelections = {["Diamond"] = false, ["Jewelry"] = false}
        for _, selected in ipairs(Value) do
            newSelections[selected] = true
        end
        _G.jewelerExtraSelections = newSelections
        CurrentConfig.jewelerExtraRobSelection = Value
        SaveConfig()
    end    
})

OptionsTab:AddToggle({
    Name = "Vending Machine Robbery",
    Default = CurrentConfig.vendingRobbery,
    Save = true,
    Flag = "vendingRobbery",
    Callback = function(Value)
        _G.vendingRobberyEnabled = Value
        CurrentConfig.vendingRobbery = Value
        SaveConfig()
    end    
})

OptionsTab:AddDropdown({
    Name = "Vending Machine Rob Priority",
    Default = CurrentConfig.vendingPriority,
    Options = {"After Main Robberys", "Before Main Robberys"},
    Save = true,
    Flag = "vendingPriority",
    Callback = function(Value)
        _G.vendingPriority = Value
        CurrentConfig.vendingPriority = Value
        SaveConfig()
    end    
})

ConfigTab:AddToggle({
    Name = "Load Saved Config",
    Default = CurrentConfig.useConfig,
    Save = true,
    Flag = "useConfig",
    Callback = function(Value)
        CurrentConfig.useConfig = Value
        SaveConfig(true)
    end
})

ConfigTab:AddButton({
    Name = "Reset Configs",
    Callback = function()
        OrionLib:ResetConfiguration()
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "Config Reseted",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

SettingsTab:AddToggle({
    Name = "SaveMoney Before Rejoin",
    Default = CurrentConfig.saveMoneyBeforeRejoin,
    Save = true,
    Flag = "saveMoneyBeforeRejoin",
    Callback = function(Value)
        _G.saveMoneyBeforeRejoin = Value
        CurrentConfig.saveMoneyBeforeRejoin = Value
        SaveConfig()
    end    
})

SettingsTab:AddSlider({
    Name = "Money to Save",
    Min = 10000,
    Max = 100000,
    Default = CurrentConfig.moneyToSaveValue,
    Color = Color3.fromRGB(255,255,255),
    Increment = 10000,
    ValueName = "k",
    Save = true,
    Flag = "moneyToSaveValue",
    Callback = function(Value)
        _G.moneyToSaveValue = Value
        CurrentConfig.moneyToSaveValue = Value
        SaveConfig()
    end    
})

SettingsTab:AddToggle({
    Name = "Rejoin when dead",
    Default = CurrentConfig.rejoinWhenDead,
    Save = true,
    Flag = "rejoinWhenDead",
    Callback = function(Value)
        _G.rejoinWhenDead = Value
        CurrentConfig.rejoinWhenDead = Value
        SaveConfig()
    end    
})

SettingsTab:AddToggle({
    Name = "Rejoin when kicked",
    Default = CurrentConfig.rejoinWhenKicked,
    Save = true,
    Flag = "rejoinWhenKicked",
    Callback = function(Value)
        _G.rejoinWhenKicked = Value
        CurrentConfig.rejoinWhenKicked = Value
        SaveConfig()
    end    
})

getgenv().RejoinScript = [[
    if getgenv()._REJOIN_LOADED then return end
    getgenv()._REJOIN_LOADED = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fluxgitscripts/wdsatwdsa/refs/heads/main/.lua"))()
   ]]

pcall(function()
    if queue_on_teleport then
        queue_on_teleport(getgenv().RejoinScript)
    end
end)
