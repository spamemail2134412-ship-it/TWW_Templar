print("west z is an independently created autofarm script and is in no way related to west x.")

local player = game.Players.LocalPlayer
local plrgui = player:WaitForChild("PlayerGui")
local plrname = player.Name

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Servers = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
local Server, Next = nil, nil
local function ListServers(cursor)
    local Raw = game:HttpGet(Servers .. ((cursor and "&cursor=" .. cursor) or ""))
    local success, errorMessage = pcall(function()
    	return HttpService:JSONDecode(Raw)
    end)
	if not success then
		warn("Your executor level is too low. Use another to use the script.")
		return nil
	else
	    return errorMessage
	end
end

repeat
    local Servers = ListServers(Next)
    Server = Servers.data[math.random(1, (#Servers.data / 3))]
    Next = Servers.nextPageCursor
until Server

local function tp()
    if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, game.Players.LocalPlayer)
    end
end

local exemption = {"startAutoFarm", "settingsFrame"}

local taskbarButtons = {}

-- pickaxeTiers used for pickaxe selection slider
local pickaxeSelected = "BasicPickaxe"
local pickaxeTiers = {"BasicPickaxe", "Tier1Pickaxe", "Tier2Pickaxe", "Tier3Pickaxe", "Tier4Pickaxe", "Tier5Pickaxe", "Tier6Pickaxe", "Tier7Pickaxe", "Tier8Pickaxe","Tier9Pickaxe"}

local old = {9, 137, 207}
local colourTheme = {255, 255, 255}
-- pickaxe tiers, planned to be used on the pathfinding update.

_G.Tier0 = {"Coal", "Copper"}
_G.Tier1 = {"Coal", "Copper"}
_G.Tier2 = {"Coal", "Copper", "Zinc"}
_G.Tier3 = {"Coal", "Copper", "Zinc", "Iron", "Limestone"}
_G.Tier4 = {"Coal", "Copper", "Zinc", "Iron", "Limestone"}
_G.Tier5 = {"Coal", "Copper", "Zinc", "Iron", "Limestone", "Silver"}
_G.Tier6 = {"Coal", "Copper", "Zinc", "Iron", "Limestone", "Silver", "Gold"}
_G.Tier7 = {"Coal", "Copper", "Zinc", "Iron", "Limestone", "Silver", "Gold", "Quartz", "CoalVein", "CopperVein", "ZincVein"}
_G.Tier8 = {"Coal", "Copper", "Zinc", "Iron", "Limestone", "Silver", "Gold", "Quartz", "CoalVein", "CopperVein", "ZincVein", "SilverVein", "GoldVein"}
_G.Tier9 = {"Coal", "Copper", "Zinc", "Iron", "Limestone", "Silver", "Gold", "Quartz", "CoalVein", "CopperVein", "ZincVein", "SilverVein", "GoldVein"}

local walkSpeedValue = plrgui:FindFirstChild("WalkSpeedValue")

if walkSpeedValue then  else
    WalkSpeedValue = Instance.new("BoolValue")
    WalkSpeedValue.Name = "WalkSpeedValue"
    WalkSpeedValue.Value = true
    WalkSpeedValue.Parent = plrgui

    task.spawn(function()
        print(game.Workspace.WORKSPACE_Entities.Players[plrname].Humanoid.WalkSpeed)
        while true do
            wait(0.1)
        game.Workspace.WORKSPACE_Entities.Players[plrname].Humanoid.WalkSpeed = 32
        end
    end)
end

local wrkspceInt = game.Workspace.WORKSPACE_Interactables
local wrkspceEnt = game.Workspace.WORKSPACE_Entities

local mining = wrkspceInt.Mining
local oredeposits = mining.OreDeposits
local ores = oredeposits:GetDescendants()

if plrgui:FindFirstChild("Templar") then
return
else

Templar = Instance.new("ScreenGui")
Templar.Parent = plrgui
Templar.Name = "Templar"

draggable = Instance.new("Frame")
draggable.Parent = Templar
draggable.Name = "Draggable"
draggable.Transparency = 1
draggable.Size = UDim2.new(0, 800, 0, 600)
draggable.Position = UDim2.new(0.5, -400, 0.5, -400)

sliderFrame = Instance.new("Frame")
sliderFrame.Parent = draggable
sliderFrame.Transparency = 1
sliderFrame.Size = UDim2.new(0, 200, 0, 15)
sliderFrame.Position = UDim2.new(0.5, -300, 0, 265)
sliderFrame.Name = "SliderFrame"
sliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local sliderUI = Instance.new("UICorner")
sliderUI.Parent = sliderFrame

slider = Instance.new("Frame")
slider.Parent = sliderFrame
slider.Transparency = 1
slider.Size = UDim2.new(0, 10, 0, 30)
slider.Position = UDim2.new(0,0,0.15,-10)
slider.Name = "Slider"
slider.BackgroundColor3 = Color3.fromRGB(0,0,0)
slider.BorderSizePixel = 2
slider.BorderColor3 = Color3.fromRGB(unpack(colourTheme))

local sliderUIDetector = Instance.new("UIDragDetector")
sliderUIDetector.Parent = slider
sliderUIDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
sliderUIDetector.DragAxis = Vector2.new(1,0)
sliderUIDetector.MinDragTranslation = UDim2.new(-0.5,0,0)
sliderUIDetector.MaxDragTranslation = UDim2.new(0.5,0,0)
sliderUIDetector.ReferenceUIInstance = sliderFrame

sliderText = Instance.new("TextLabel")
sliderText.Parent = draggable
sliderText.BackgroundTransparency = 1
sliderText.TextTransparency = 1
sliderText.Text = "Pickaxe Tier: BasicPickaxe"
sliderText.Size = UDim2.new(0, 300, 0, 50)
sliderText.TextSize = 25
sliderText.Font = Enum.Font.GothamBold
sliderText.Position = UDim2.new(0.5, -350, 0, 200)
sliderText.TextColor3 = Color3.fromRGB(unpack(colourTheme))
sliderText.Name = "sliderText"

sliderUIDetector.DragContinue:Connect(function()

    local totalWidth = sliderFrame.AbsoluteSize.X - slider.AbsoluteSize.X
    local intervalCount = 10
    local intervalWidth = totalWidth / (intervalCount - 1)

    local xPos = slider.Position.X.Offset

    local nearestIndex = math.floor((xPos + intervalWidth/2) / intervalWidth)
    local snappedX = nearestIndex * intervalWidth
    
    slider.Position = UDim2.new(0, snappedX, slider.Position.Y.Scale, slider.Position.Y.Offset)
    sliderText.Text = "Pickaxe Tier: " .. pickaxeTiers[nearestIndex + 1]

    pickaxeSelected = pickaxeTiers[nearestIndex + 1]

end)

local dragDetector = Instance.new("UIDragDetector")
dragDetector.Parent = draggable

Frame = Instance.new("Frame")
Frame.Parent = draggable
Frame.Size = UDim2.new(0, 800, 0, 600)
Frame.Position = UDim2.new(0.5, -400, 0.5, -300)
Frame.Transparency = 1
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.ZIndex = 0
Frame.ClipsDescendants = true

local uicornerFrame = Instance.new("UICorner")
uicornerFrame.Parent = Frame

tweenservice = game:GetService("TweenService")

local framebar = Instance.new("Frame")
framebar.Parent = draggable
framebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
framebar.Size = UDim2.new(0, 800, 0, 120)
framebar.Transparency = 1
framebar.ZIndex = 0

local uicornerFrameBar = Instance.new("UICorner")
uicornerFrameBar.Parent = framebar

local title = Instance.new("TextLabel")
title.Parent = framebar
title.Text = "Templar"
title.Size = UDim2.new(0, 800, 0, 100)
title.TextTransparency = 1
title.BackgroundTransparency = 1
title.TextSize = 30
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.Position = UDim2.new(0,-325,0,-20)

startAutoFarm = Instance.new("TextButton")
startAutoFarm.Parent = Frame
startAutoFarm.Text = "Nearest Ore"
startAutoFarm.Size = UDim2.new(0, 300, 0, 50)
startAutoFarm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
startAutoFarm.TextSize = 20
startAutoFarm.TextColor3 = Color3.fromRGB(255,255,255)
startAutoFarm.Font = Enum.Font.SourceSansBold
startAutoFarm.Transparency = 1
startAutoFarm.Position = UDim2.new(0.5, -350, 0, 140)
startAutoFarm.Name = "startAutoFarm"

local autofarmcorner = Instance.new("UICorner")
autofarmcorner.Parent = startAutoFarm

Exit = Instance.new("TextButton")
Exit.Parent = Frame
Exit.Text = "X"
Exit.Size = UDim2.new(0, 30, 0, 30)
Exit.BackgroundColor3 = Color3.fromRGB(50,50,50)
Exit.Font = Enum.Font.SourceSansBold
Exit.Transparency = 1
Exit.Position = UDim2.new(1, -40, 0, 5)
Exit.TextSize = 20
Exit.TextColor3 = Color3.fromRGB(255,255,255)
Exit.Name = "Exit"
Exit.BackgroundTransparency = 1
table.insert(taskbarButtons, Exit)

local ExitCorner = Instance.new("UICorner")
ExitCorner.Parent = Exit

minimise = Instance.new("TextButton")
minimise.Text = "-"
minimise.Size = UDim2.new(0, 30, 0, 30)
minimise.TextColor3 = Color3.fromRGB(255,255,255)
minimise.Position = UDim2.new(1, -75, 0, 5)
minimise.Parent = Frame
minimise.BackgroundTransparency = 1
minimise.TextSize = 20
table.insert(taskbarButtons, minimise)
minimise.BackgroundColor3 = Color3.fromRGB(50,50,50)
minimise.Transparency = 1

settings = Instance.new("ImageButton")
settings.Size = UDim2.new(0, 30, 0, 30)
settings.Position = UDim2.new(1, -110, 0, 5)
settings.Image = "rbxthumb://type=Asset&id=2484556387&w=420&h=420"
settings.Parent = Frame
settings.BackgroundTransparency = 1
settings.BackgroundColor3 = Color3.fromRGB(50,50,50)
table.insert(taskbarButtons, settings)
settings.ImageTransparency = 1

local settingsCorner = Instance.new("UICorner")
settingsCorner.Parent = settings

local minimiseCorner = Instance.new("UICorner")
minimiseCorner.Parent = minimise

overview = Instance.new("Frame")
overview.BackgroundColor3 = Color3.fromRGB(0,0,0)
overview.Position = UDim2.new(0,800,0,-57)
overview.Size = UDim2.new(0,800,0,100)
overview.Parent = Templar
overview.Name = "OverviewPanel"
overview.Visible = false

local overviewCorner = Instance.new("UICorner")
overviewCorner.Parent = overview

maximise = Instance.new("ImageButton")
maximise.Parent = overview
maximise.Size = UDim2.new(0, 30, 0, 30)
maximise.Position = UDim2.new(0,730,0,5)
table.insert(taskbarButtons,maximise)
maximise.BackgroundTransparency = 1
maximise.BackgroundColor3 = Color3.fromRGB(50,50,50)
maximise.Image = "rbxthumb://type=Asset&id=94060666841421&w=420&h=420"

local maximiseCorner = Instance.new("UICorner")
maximiseCorner.Parent = maximise

overviewExit = Instance.new("TextButton")
overviewExit.Parent = overview
overviewExit.Size = UDim2.new(0,30,0,30)
overviewExit.Position = UDim2.new(0,765,0,5)
overviewExit.BackgroundTransparency = 1
overviewExit.BackgroundColor3 = Color3.fromRGB(50,50,50)
overviewExit.Text = "X"
overviewExit.TextColor3 = Color3.fromRGB(255,255,255)
table.insert(taskbarButtons,overviewExit)
overviewExit.TextSize = 20
overviewExit.Font = Enum.Font.SourceSansBold

local overviewExitCorner = Instance.new("UICorner")
overviewExitCorner.Parent = overviewExit

local overviewDrag = Instance.new("UIDragDetector")
overviewDrag.Parent = overview

settingsFrame = Instance.new("Frame")
settingsFrame.Parent = Frame
settingsFrame.ZIndex = 0
settingsFrame.Size = UDim2.new(0, 800, 0, 600) 
settingsFrame.Position = UDim2.new(0.5, -400, 0.5, 500) 
settingsFrame.BackgroundColor3 = Color3.fromRGB(30,30,30) 
settingsFrame.Name = "settingsFrame"

local settingsFrameCorner = Instance.new("UICorner")
settingsFrameCorner.Parent = settingsFrame

automine = Instance.new("TextButton")
automine.Parent = Frame
automine.Size = UDim2.new(0,200,0,30)
automine.Position = UDim2.new(0,75,0,80)
automine.BackgroundColor3 = Color3.fromRGB(0,0,0)
automine.TextColor3 = Color3.fromRGB(255,255,255)
automine.Text = "Automine"
automine.TextSize = 25
automine.Font = Enum.Font.GothamBold
automine.Transparency = 1
automine.Name = "automine"
automine.BackgroundColor3 = Color3.fromRGB(50,50,50)
table.insert(taskbarButtons, automine)

local automineCorner = Instance.new("UICorner")
automineCorner.Parent = automine

mineconfig = Instance.new("TextButton")
mineconfig.Parent = Frame
mineconfig.Size = UDim2.new(0,190,0,30)
mineconfig.Position = UDim2.new(0,540,0,80)
mineconfig.BackgroundColor3 = Color3.fromRGB(0,0,0)
mineconfig.TextColor3 = Color3.fromRGB(255,255,255)
mineconfig.Text = "Config"
mineconfig.TextSize = 25
mineconfig.Font = Enum.Font.GothamBold
mineconfig.Transparency = 1
mineconfig.Name = "mineconfig"
mineconfig.BackgroundColor3 = Color3.fromRGB(50,50,50)
table.insert(taskbarButtons, mineconfig)

local mineConfigCorner = Instance.new("UICorner")
mineConfigCorner.Parent = mineconfig

webhook = Instance.new("TextButton")
webhook.Parent = Frame
webhook.Size = UDim2.new(0,200,0,30)
webhook.Position = UDim2.new(0,305,0,80)
webhook.BackgroundColor3 = Color3.fromRGB(0,0,0)
webhook.TextColor3 = Color3.fromRGB(255,255,255)
webhook.Text = "Webhooks"
webhook.TextSize = 25
webhook.Font = Enum.Font.GothamBold
webhook.Transparency = 1
webhook.Name = "webhook"
webhook.BackgroundColor3 = Color3.fromRGB(50,50,50)
table.insert(taskbarButtons, webhook)

local webhookCorner = Instance.new("UICorner")
webhookCorner.Parent = webhook

separationFrame = Instance.new("Frame")
separationFrame.Parent = Frame
separationFrame.BackgroundColor3 = Color3.fromRGB(unpack(colourTheme))
separationFrame.Transparency = 1
separationFrame.Size = UDim2.new(0,5,0,30)
separationFrame.Position = UDim2.new(0,60,0,80)

local separationFrameCorner = Instance.new("UICorner")
separationFrameCorner.Parent = separationFrame

numBars = 4
local startX = 60
local endX   = 745
local spacing = (endX - startX) / (numBars - 1)

separators = {}

for i = 1, numBars do
    local clone = separationFrame:Clone()
    clone.Position = UDim2.new(0, startX + spacing * i, 0, 80)
    clone.Parent = Frame
    separators[i] = clone
end

local tweenParts = draggable:GetDescendants()
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1)
isTweenFinished = false

local Mouse = player:GetMouse()

for i, element in pairs(tweenParts) do
    if element:IsA("Frame") or table.find(exemption, element.Name) then
        if table.find(exemption,element.Name) then finaltransparency = 0 else finaltransparency = 0.3 end

        local tween = tweenservice:Create(element, tweenInfo, {Transparency = finaltransparency})
        tween:Play()
    elseif element:IsA("TextLabel") or element:IsA("TextButton") then
        local textTween = tweenservice:Create(element, tweenInfo, {TextTransparency = 0})
        textTween:Play()
        if i == #tweenParts then
            wait(1)
            isTweenFinished = true
        end
    elseif element:IsA("ImageButton") then
        local textTween = tweenservice:Create(element, tweenInfo, {ImageTransparency = 0})
        textTween:Play()
    end
end
local pathfindingservice = game:GetService("PathfindingService")
character = wrkspceEnt.Players[plrname]
local humanoid = character.Humanoid
humanoidrootpart = character.HumanoidRootPart

path = pathfindingservice:CreatePath({
    AgentHeight = 7.459118,
    AgentRadius = 2.36565,
    AgentCanClimb = true,
    WaypointSpacing = 10,
    Costs = {Water = 20}
})

local function calcPathDistance(waypoints, i, ore) -- Calculates the overall distance by taking the distances between each waypoint and summing them.
    local localDistance = {}
    local waypointPos -- A variable that contains the distance between two points
    local lastWaypoint = nil -- previous waypoint so it can be subtracted from the current waypoint

    for i, waypoint in pairs(waypoints) do
        if lastWaypoint == nil then -- If there is no data to compare to, then it will skip over so that there is previous waypoint. (In order to measure the distance between them)
            lastWaypoint = waypoint
            else
            waypointPos = (waypoint.Position - lastWaypoint.Position).Magnitude -- Measures the distance between the current waypoint and the previous waypoint.
            table.insert(localDistance,waypointPos)
            lastWaypoint = waypoint
        end
    end
    local sum = 0
    for _, distance in pairs(localDistance) do
        sum = sum + distance
    end
    table.insert(nearestOres, sum)
    ore.Name = "Ore" .. i
    table.insert(oreIndex, ore)
end

local pickaxeIndex = table.find(pickaxeTiers, pickaxeSelected)

local function FindNearestOre()
nearestOres = {}
oreIndex = {}
closestOreDistance = math.huge
closestOre = nil
finalpos = nil
oreHierarchy = nil

local function collisionOff(ore)
    if ore:FindFirstChild("RockBase") then ore.RockBase.CanCollide = false end
    if ore:FindFirstChild("RockBaseL") then ore.RockBaseL.CanCollide = false end
    if ore:FindFirstChild("RockBaseVein") then ore.RockBaseVein.CanCollide = false end
    if ore:FindFirstChild("RockBaseLVein") then ore.RockBaseLVein.CanCollide = false end
end

    for i, ore in pairs(ores) do
        if ore:IsA("Model") and ore.DepositInfo.OreRemaining.Value > 0 and table.find(_G["Tier" .. pickaxeIndex - 1], ore.Parent.Name) then
            collisionOff(ore)
            local modifier = 0
            if string.find(ore.Parent.Name, "Vein") then
                for i, v in pairs(ore:GetChildren()) do
                    if v:IsA("MeshPart") then
                        modifier = 10
                    end
                end
            end
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(wrkspceEnt.Players[plrname].HumanoidRootPart.Position, ore.PrimaryPart.Position - Vector3.new(modifier,modifier,modifier))
                end)
                if success and path.Status == Enum.PathStatus.Success then
                    calcPathDistance(path:GetWaypoints(), i, ore)
                    print("Ore iteration " .. i .. " successful path creation.")
					
                elseif path.Status == Enum.PathStatus.NoPath then
                    print("Ore iteration " .. i .. " path failed, path not found.")
                else
                    print("Ore iteration " .. i .. " path failed, unknown error occurred.")
                end
        end
    end
    
    for i, distance in pairs(nearestOres) do
        print(distance)
        if distance < closestOreDistance then
            print(distance, "this is the distance")
            closestOreDistance = distance
            closestOre = oreIndex[i]
            print(closestOre)

        finalpos = closestOre.PrimaryPart.Position
        end
    end

end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.SharedModules.Global)

local bodyVelocity = nil
local bodyGyro = nil
local isRagdollFlying = false

local function enableRagdollFly()
    if isRagdollFlying then return end
    
    Global.PlayerCharacter:Ragdoll(nil, true)
    task.wait(0.5)
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("Motor6D") then
            part.Enabled = true -- Re-enable motors
        end
        if part:IsA("BallSocketConstraint") then
            part.Enabled = false -- Disable ragdoll constraints
        end
    end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 10000
    bodyVelocity.Parent = humanoidrootpart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.CFrame = CFrame.new()
    bodyGyro.Parent = humanoidrootpart
    
    local undergroundPos = humanoidrootpart.Position - Vector3.new(0, 3, 0)
    humanoidrootpart.CFrame = CFrame.new(undergroundPos)
    
    isRagdollFlying = true
end

local function disableRagdollFly()
    if not isRagdollFlying then return end
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    for _, weld in pairs(humanoidrootpart:GetChildren()) do
        if weld:IsA("WeldConstraint") then
            weld:Destroy()
        end
    end
    
    
    Global.PlayerCharacter:GetUp()
    task.wait(1.5)
    
    isRagdollFlying = false
end


local function ragdollMoveTo(targetPos)
    if not isRagdollFlying then 
        return false 
    end
    
    local speed = 75
    
    targetPos = Vector3.new(targetPos.X, targetPos.Y - 3, targetPos.Z)
    
    local stuckTimer = 0
    local lastPos = humanoidrootpart.Position
    
    while true do
        local currentPos = humanoidrootpart.Position
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude
        
        if (currentPos - lastPos).Magnitude < 0.1 then
            stuckTimer = stuckTimer + 1
            if stuckTimer > 30 then
                return false
            end
        else
            stuckTimer = 0
            lastPos = currentPos
        end
        
        if distance < 5 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            return true
        end
        
        bodyVelocity.Velocity = direction.Unit * speed
        local horizontalLook = Vector3.new(direction.X, 0, direction.Z)
        if horizontalLook.Magnitude > 0 then
            bodyGyro.CFrame = CFrame.lookAt(Vector3.new(0,0,0), horizontalLook)
        else
            bodyGyro.CFrame = CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
        end
        
        task.wait()
    end
end

function loadWaypoints(waypoints)
    print("Loading path...")
    for i, waypoint in pairs(waypoints) do
        if i < #waypoints then
            
            local a = waypoints[i].Position
            local b = waypoints[i+1].Position
            local dir = b - a
            local dist = dir.Magnitude
            local mid = (a + b) / 2
            local thickness = 0.4

            local part = Instance.new("Part")
            part.Material = "Neon"
            part.Anchored = true
            part.CanCollide = false
            part.Shape = "Ball"
            part.Position = waypoint.Position
            part.Parent = game.Workspace:WaitForChild("Path")
            part.Name = "part"..i
            part.Size = Vector3.new(3, 1, 1)

            local connection = Instance.new("Part")
            connection.Shape = "Cylinder"
            connection.Material = "Neon"
            connection.Anchored = true
            connection.CanCollide = false
            connection.Parent = game.Workspace:WaitForChild("Path")
            connection.Size = Vector3.new(dist, thickness, thickness)
            connection.CFrame = CFrame.new(mid, b) * CFrame.Angles(math.rad(90), 0, 0)
            connection.Name = "Connection" .. i
            connection.Color = Color3.fromRGB(213, 115, 61)
            local up = Vector3.new(0,1,0)
            local rotation = CFrame.fromMatrix(mid, dir.Unit, up:Cross(dir.Unit), dir.Unit:Cross(up:Cross(dir.Unit)))
            connection.CFrame = rotation

            task.spawn(function() --remove if statement and just keep wait(0.25+i/2) and part:Destroy() if you want a quicker deletion
                if i == 0 then
                    wait(1)
                    part:Destroy()
                    connection:Destroy()
                else
                    wait(0.25 + i / 2)
                    part:Destroy()
                    connection:Destroy()
                end
            end)

        else

            local part = Instance.new("Part")
            part.Material = "Neon"
            part.Anchored = true
            part.CanCollide = false
            part.Shape = "Ball"
            part.Position = waypoint.Position
            part.Parent = game.Workspace:WaitForChild("Path")
            part.Name = "part"..i
            part.Size = Vector3.new(3, 1, 1)

            task.spawn(function() --remove if statement and just keep wait(0.25+i/2) and part:Destroy() if you want a quicker deletion
                if i == 0 then

                    wait(1)
                    part:Destroy()
                else
                    wait(0.25 + i / 2)
                    part:Destroy()
                end
            end)
        end
    end
    print("Path loaded")
end


function pathfind()
FindNearestOre() -- the rest from this point onwards needs to be in the button. cya.
finalpos = finalpos - Vector3.new(2,2,2)
print("Closest ore found: " .. closestOreDistance)
pathfindSuccess = nil
local success, errorMessage = pcall(function()
path:ComputeAsync(wrkspceEnt.Players[plrname].HumanoidRootPart.Position, finalpos)
end)
print(path.Status)
if game.Workspace:FindFirstChild("Path") then

    else
        folder = Instance.new("Folder")
        folder.Parent = game.Workspace
        folder.Name = "Path"
end   

if success then
	print("Closest ore: ", closestOre)
	
    print("Waypoints found: " .. #path:GetWaypoints())
    
    enableRagdollFly()
    
    loadWaypoints(path:GetWaypoints())
    
    print("Moving to pos: ", finalpos)
    
    for i, waypoint in ipairs(path:GetWaypoints()) do
	    local waypoints = path:GetWaypoints()
	    local finished = false
	    local maxTime = 10
	    local jumpTime = 5
	    local timeElapsed = 0
        
        ragdollMoveTo(waypoint.Position)
        
    end
else
    if path.Status == Enum.PathStatus.NoPath then print("No path calculated! Please try again.") return else print("Unknown error occurred! Please try again.") end
    pathfindSuccess = false
    disableRagdollFly()
end
    pathfindSuccess = true
    disableRagdollFly()
    return pathfindSuccess
end
end

local virtualinputmanager = game:GetService("VirtualInputManager")

local function input(inputType, inputButton, timeInterval)
    task.defer(function()
        if inputType == "leftclick" then
            local camera = workspace.CurrentCamera
            local centerX = camera.ViewportSize.X / 2
            local centerY = camera.ViewportSize.Y / 2
            virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,true,game,1)
            wait(0.2)
            virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,false,game,1)
        elseif inputType == "pressbutton" then
            virtualinputmanager:SendKeyEvent(true, inputButton, false, game)
            wait(timeInterval)
            virtualinputmanager:SendKeyEvent(false, inputButton, false, game)
        elseif inputType == "holdLeftClick" then
            virtualinputmanager:SendMouseButtonEvent(0,0,0,true,game,1)
        elseif inputType == "abortLeftClick" then
            virtualinputmanager:SendMouseButtonEvent(0,0,0,false,game,1)
        end
    end)
end

local function closestVender()
    local currentPos = humanoidrootpart.Position
    local closestVenderDistance = math.huge
    local finalVenderPos = nil
    local venders = {}
    

end

local slot = plrgui.Hotbar.Container.HotbarList.Body
if slot.HotbarSlot_Utility_1.Container.Slot.ViewportFrame:GetChildren()[1] == nil then print("No item in slot 4.") Templar:Destroy() return end
local slotItem = slot.HotbarSlot_Utility_1.Container.Slot.ViewportFrame:GetChildren()[1].Name

print(slotItem)
print(("LoadoutItem/" .. pickaxeSelected))
print(character)

local function closestOreFarm()
    --put in a while loop tomorrow, it has to check if your inventory is 30/30 and then it will stop and go to sell it all.
    pathfindSuccess = nil
    pathfind()
    while pathfindSuccess == nil do -- waits until path is complete
        wait(0.1)
    end
    print(closestOre)
    if pathfindSuccess == true then
        if slotItem == pickaxeSelected and character:FindFirstChild("LoadoutItem/" .. slotItem) then
            print("Pickaxe not selected!")
            wait(1)
            input("pressbutton", Enum.KeyCode.Four)
            local playerChar = require(game:GetService("ReplicatedStorage").Modules.Character.PlayerCharacter)
            local equippeditem = playerChar:GetEquippedItem()
            equippeditem.CameraFreeLook = true
            local pickaxeItem = playerChar:GetItem(pickaxeSelected)
            task.spawn(function()
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    wait(0.1)
                    humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                    equippeditem.CameraFreeLook = true
                    pickaxeItem:Swing()
                end
            end)
             while closestOre.DepositInfo.OreRemaining.Value > 0 do
                input("pressbutton", Enum.KeyCode.E, 1)
                wait(1)
            end
            input("pressbutton", Enum.KeyCode.Four)
        elseif slotItem == nil then print("No pickaxe found in slot 4.")
        elseif string.find(slotItem, "Pickaxe") then print("The selected pickaxe was not found in slot 4.", pickaxeSelected) return
        else
            task.spawn(function()
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    wait(0.1)
                    humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                    local playerChar = require(game:GetService("ReplicatedStorage").Modules.Character.PlayerCharacter)
                    local equippeditem = playerChar:GetEquippedItem()
                    equippeditem.CameraFreeLook = true
                    pickaxeItem:Swing()
                end
            end)
            while closestOre.DepositInfo.OreRemaining.Value > 0 do
                input("pressbutton", Enum.KeyCode.E, 1)
                wait(1)
            end
            input("abortLeftClick")
            input("pressbutton", Enum.KeyCode.Four)
            virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
        end
    end
end

local function buttonHover()
    for _,button in pairs(taskbarButtons) do
        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = 0
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = 1
        end)
    end
end
local clockwise = true
local isRunning = false

buttonsDeleted = {startAutoFarm,sliderFrame,sliderText,slider,separationFrame,automine,webhook,mineconfig}
buttonsDeletedTabAutomine = {startAutoFarm,sliderFrame,sliderText,slider}
buttonsDeletedTabConfig = {}
buttonsDeletedTabWebhooks = {}

local isAMon = true
local isWHon = false
local isCon = false

local function showTab(tab)
    automineFrame.Visible = false
    webhooksFrame.Visible = false
    configFrame.Visible = false

    tab.Visible = true
end

local function applyButtonFunctionality()

-- Automine tab

mineconfig.MouseButton1Down:Connect(function()
    if isCon then
        return
    else
        
        for i,v in pairs(buttonsDeletedTabConfig) do
            v.Visible = true
        end
        
        for i, v in pairs(buttonsDeletedTabAutomine) do
            v.Visible = false
        end
        
        for i,v in pairs(buttonsDeletedTabWebhooks) do
            v.Visible = false
        end
        
        isAMon = false
        isWHon = false
        isCon = true
    end
end)


webhook.MouseButton1Down:Connect(function()
    if isWHon == true then
        return
    else
        
        for i,v in pairs(buttonsDeletedTabWebhooks) do
            v.Visible = true
        end
        
        for i,v in pairs(buttonsDeletedTabAutomine) do
            v.Visible = false
        end
        
        for i,v in pairs(buttonsDeletedTabConfig) do
            v.Visible = false
        end
        
        isAMon = false
        isWHon = true
        isCon = false
    end
end)

automine.MouseButton1Down:Connect(function()
    if isAMon == true then
        return
    else
        for i,v in pairs(buttonsDeletedTabAutomine) do
            v.Visible = true
        end
        
        for i,v in pairs(buttonsDeletedTabConfig) do
            v.Visible = false
        end
        
        for i,v in pairs(buttonsDeletedTabWebhooks) do
            v.Visible = false
        end
        
        isAMon = true
        isWHon = false
        isCon = false
    end
end)

-- OverviewPanel exit button
overviewExit.MouseButton1Down:Connect(function()
    Templar:Destroy()
end)

local isAFRunning = false

-- Settings button
settings.MouseButton1Down:Connect(function()
    if isRunning == false then
        isRunning = true
	    tweeninfo = TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
        local part = settingsFrame
        local tweeninfoSlide = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
        local tweeninfoTransparency = TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
        local pos = nil
        local transparency = nil
        local visible = nil
	    local openTween = tweenservice:Create(settings, tweeninfo, {Rotation = 90})
        local closeTween = tweenservice:Create(settings, tweeninfo, {Rotation = -90})
	    if clockwise == true then
	        openTween:Play()
	        clockwise = false
	    else
            closeTween:Play()
            clockwise = true
        end
        if settingsFrame.Position.Y.Offset == 500 then
            visible = true
            pos = UDim2.new(0.5,-400,0.5,-300)
            transparency = 0.3
        else
            visible = false
            pos = UDim2.new(0.5,-400,0.5,500)
            transparency = 1
        end
        local tweenSlide = tweenservice:Create(part, tweeninfoSlide, {Position = pos})
        tweenSlide:Play()
        local tweenTransparency = tweenservice:Create(part, tweeninfoTransparency, {Transparency = transparency})
        tweenTransparency:Play()
        
        for i = 1, numBars do
            table.insert(buttonsDeleted, separators[i])
        end
        if visible == true then
            for _,button in pairs(buttonsDeleted) do
                local part = button
                if button:IsA("TextLabel") then 
                    tween = tweenservice:Create(part,tweeninfo,{TextTransparency = 1})
                    tween:Play()
                else
                    tween = tweenservice:Create(part,tweeninfo,{Transparency = 1})
                    tween:Play()
                end
                task.spawn(function()
                wait(1)
                button.Visible = false
                end)
            end
        else
            for _,button in pairs(buttonsDeleted) do
                local part = button
                if button:IsA("TextLabel") then 
                    tween = tweenservice:Create(part,tweeninfo,{TextTransparency = 0})
                elseif button:IsA("TextButton") and button.Name ~= "startAutoFarm" then
                    tween = tweenservice:Create(part,tweeninfo,{TextTransparency = 0})
                else
                    tween = tweenservice:Create(part,tweeninfo,{Transparency = 0})
                end
                tween:Play()
                button.Visible = true
            end
        end
        wait(1)
        isRunning = false
    end
    
end)

-- OverviewPanel maximise button
maximise.MouseButton1Down:Connect(function()
    overview.Visible = false
    draggable.Visible = true
end)

-- Minimise button
minimise.MouseButton1Down:Connect(function()
    overview.Visible = not overview.Visible
    draggable.Visible = not draggable.Visible
end)

-- Exit button.
Exit.MouseButton1Down:Connect(function()
    Templar:Destroy()
end)

-- Autofarm button.
startAutoFarm.MouseButton1Down:Connect(function()
    if isAFRunning == false then
        isAFRunning = true
        startAutoFarm.BackgroundColor3 = Color3.fromRGB(0,75,0)
        closestOreFarm()
    else
        warn("Autofarm already running. To turn off the autofarm, please leave the game.")
    end
end)

buttonHover()

end

if isTweenFinished == true then
    applyButtonFunctionality()
end
