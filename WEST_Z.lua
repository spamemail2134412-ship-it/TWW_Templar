print("west z is an independently created autofarm script and is in no way related to west x.")

local player = game.Players.LocalPlayer
local plrgui = player:WaitForChild("PlayerGui")
local plrname = player.Name

local pickaxeSelected = "BasicPickaxe"
local pickaxeTiers = {"BasicPickaxe", "Tier1Pickaxe", "Tier2Pickaxe", "Tier3Pickaxe", "Tier4Pickaxe", "Tier5Pickaxe", "Tier6Pickaxe", "Tier7Pickaxe", "Tier8Pickaxe","Tier9Pickaxe"}

local old = {9, 137, 207}
local colourTheme = {255, 255, 255}
-- pickaxe tiers

Tier0 = {Coal, Copper}
Tier1 = {Coal, Copper}
Tier2 = {Coal, Copper, Zinc}
Tier3 = {Coal, Copper, Zinc, Iron, Limestone}
Tier4 = {Coal, Copper, Zinc, Iron, Limestone}
Tier5 = {Coal, Copper, Zinc, Iron, Limestone, Silver}
Tier6 = {Coal, Copper, Zinc, Iron, Limestone, Silver, Gold}
Tier7 = {Coal, Copper, Zinc, Iron, Limestone, Silver, Gold, Quartz, CoalVein, CopperVein, ZincVein}
Tier8 = {Coal, Copper, Zinc, Iron, Limestone, Silver, Gold, Quartz, CoalVein, CopperVein, ZincVein, SilverVein, GoldVein}
Tier9 = {Coal, Copper, Zinc, Iron, Limestone, Silver, Gold, Quartz, CoalVein, CopperVein, ZincVein, SilverVein, GoldVein}

if game.Workspace.WORKSPACE_Entities.Players[plrname].Humanoid.WalkSpeed == 30 then
return
else
    task.spawn(function()
    print(game.Workspace.WORKSPACE_Entities.Players[plrname].Humanoid.WalkSpeed)
    while true do
        wait(0.1)
    game.Workspace.WORKSPACE_Entities.Players[plrname].Humanoid.WalkSpeed = 30
        end
    end)
end

local wrkspceInt = game.Workspace.WORKSPACE_Interactables
local wrkspceEnt = game.Workspace.WORKSPACE_Entities

local mining = wrkspceInt.Mining
local oredeposits = mining.OreDeposits
local ores = oredeposits:GetDescendants()

if plrgui:FindFirstChild("WestZ") then
return
else

WestZ = Instance.new("ScreenGui")
WestZ.Parent = plrgui
WestZ.Name = "WestZ"

local draggable = Instance.new("Frame")
draggable.Parent = WestZ
draggable.Name = "Draggable"
draggable.Transparency = 1
draggable.Size = UDim2.new(0, 800, 0, 800)
draggable.Position = UDim2.new(0.5, -400, 0.5, -400)

local sliderFrame = Instance.new("Frame")
sliderFrame.Parent = draggable
sliderFrame.Transparency = 1
sliderFrame.Size = UDim2.new(0, 200, 0, 15)
sliderFrame.Position = UDim2.new(0.5, -300, 0, 250)
sliderFrame.Name = "SliderFrame"
sliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local sliderUI = Instance.new("UICorner")
sliderUI.Parent = sliderFrame

local slider = Instance.new("Frame")
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

local sliderText = Instance.new("TextLabel")
sliderText.Parent = draggable
sliderText.BackgroundTransparency = 1
sliderText.TextTransparency = 1
sliderText.Text = "Pickaxe Tier: BasicPickaxe"
sliderText.Size = UDim2.new(0, 300, 0, 50)
sliderText.TextSize = 25
sliderText.Font = Enum.Font.GothamBold
sliderText.Position = UDim2.new(0.5, -350, 0, 185)
sliderText.TextColor3 = Color3.fromRGB(unpack(colourTheme))

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

local Frame = Instance.new("Frame")
Frame.Parent = draggable
Frame.Size = UDim2.new(0, 800, 0, 800)
Frame.Position = UDim2.new(0.5, -400, 0.5, -400)
Frame.Transparency = 1
Frame.BackgroundColor3 = Color3.fromRGB(53,53,53)

local uicornerFrame = Instance.new("UICorner")
uicornerFrame.Parent = Frame

local tweenservice = game:GetService("TweenService")

local framebar = Instance.new("Frame")
framebar.Parent = draggable
framebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
framebar.Size = UDim2.new(0, 800, 0, 100)
framebar.Transparency = 1

local uicornerFrameBar = Instance.new("UICorner")
uicornerFrameBar.Parent = framebar

local title = Instance.new("TextLabel")
title.Parent = framebar
title.Text = "West Z"
title.Size = UDim2.new(0, 800, 0, 100)
title.TextTransparency = 1
title.BackgroundTransparency = 1
title.TextSize = 60
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.GothamBold

startAutoFarm = Instance.new("TextButton")
startAutoFarm.Parent = Frame
startAutoFarm.Text = "Start Auto Farm - Nearest Ore"
startAutoFarm.Size = UDim2.new(0, 300, 0, 50)
startAutoFarm.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
startAutoFarm.TextSize = 17
startAutoFarm.TextColor3 = Color3.fromRGB(255,255,255)
startAutoFarm.Font = Enum.Font.SourceSansBold
startAutoFarm.Transparency = 1
startAutoFarm.Position = UDim2.new(0.5, -350, 0, 120)
local autofarmcorner = Instance.new("UICorner")
autofarmcorner.Parent = startAutoFarm

Exit = Instance.new("TextButton")
Exit.Parent = Frame
Exit.Text = "X"
Exit.Size = UDim2.new(0, 25, 0, 25)
Exit.BackgroundColor3 = Color3.fromRGB(200,0,0)
Exit.Font = Enum.Font.SourceSansBold
Exit.Transparency = 1
Exit.Position = UDim2.new(1, -30, 0, 5)
Exit.TextSize = 20
Exit.TextColor3 = Color3.fromRGB(0,0,0)

local ExitCorner = Instance.new("UICorner")
ExitCorner.Parent = Exit

local tweenParts = draggable:GetDescendants()
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1)
isTweenFinished = false

local Mouse = player:GetMouse()

for i, element in pairs(tweenParts) do
    if element:IsA("Frame") or element:IsA("TextButton") then
        if element.Name == "Slider" then finaltransparency = 0 else finaltransparency = 0.3 end

        local tween = tweenservice:Create(element, tweenInfo, {Transparency = finaltransparency})
        tween:Play()
        elseif element:IsA("TextLabel") then
            local textTween = tweenservice:Create(element, tweenInfo, {TextTransparency = 0})
            textTween:Play()
            if i == #tweenParts then
                wait(1)
                isTweenFinished = true
            end
    end
end
local pathfindingservice = game:GetService("PathfindingService")
character = wrkspceEnt.Players[plrname]
local humanoid = character.Humanoid
local humanoidrootpart = character.HumanoidRootPart

path = pathfindingservice:CreatePath({
    AgentCanClimb = true,
    WaypointSpacing = 3,
    Costs = {Water = 20}
})

local function calcPathDistance(waypoints, i, ore) -- Calculates the overall distance by taking the distances between each waypoint and summing them.
    local localDistance = {}
    local waypointPos -- A variable that contains the distance between two points
    local lastWaypoint = nil -- previous waypoint so it can be subtracted from the current waypoint

    for i, waypoint in pairs(waypoints) do
        if lastWaypoint == nil then
            lastWaypoint = waypoint
            else
            waypointPos = (waypoint.Position - lastWaypoint.Position).Magnitude
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

local function FindNearestOre()
nearestOres = {}
oreIndex = {}
closestOreDistance = math.huge
closestOre = nil
finalpos = nil
oreHierarchy = nil

    for i, ore in pairs(ores) do
        if ore:IsA("Model") and ore.DepositInfo.OreRemaining.Value > 0 then
            local modifier = 0
            if string.find(ore.Parent.Name, "Vein") then
                for i, v in pairs(ore:GetChildren()) do
                    if v:IsA("MeshPart") then
                        modifier = 10
                    end
                end
            end
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(character.PrimaryPart.Position, ore.PrimaryPart.Position - Vector3.new(modifier,modifier,modifier))
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

function pathfind()
FindNearestOre() -- the rest from this point onwards needs to be in the button. cya.
finalpos = finalpos - Vector3.new(2,2,2)
print(closestOreDistance, "okay")
print(closestOre)
print(closestOre)
pathfindSuccess = nil
local success, errorMessage = pcall(function()
path:ComputeAsync(character.PrimaryPart.Position, finalpos)
end)
print(path.Status)
if game.Workspace:FindFirstChild("Path") then

    else
        folder = Instance.new("Folder")
        folder.Parent = game.Workspace
        folder.Name = "Path"
end   

character:SetAttribute("finalpos", finalpos)

print(humanoidrootpart.Position)
if success then
	print(closestOre)
	local stuck = false

    print("Waypoints found: " .. #path:GetWaypoints())
    for i, waypoint in pairs(path:GetWaypoints()) do
        local waypoints = path:GetWaypoints()
        if i < #path:GetWaypoints() then
            
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
            print(part.Size, "less than number")
            part.Size = Vector3.new(3, 1, 1)
            local actualpos = character:GetAttribute("finalpos")

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
            print(part.Size, "equal to ore more than")
            part.Size = Vector3.new(3, 1, 1)
            local actualpos = character:GetAttribute("finalpos")

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

    for i, waypoint in ipairs(path:GetWaypoints()) do
        print("ok so we got here ig?")
	    local waypoints = path:GetWaypoints()
	    local finished = false
	    local maxTime = 10
	    local jumpTime = 5
	    local timeElapsed = 0

        --if actualpos ~= finalpos then return end
        humanoid:MoveTo(waypoint.Position)


        humanoid.MoveToFinished:Wait()

    end

else
    if path.Status == Enum.PathStatus.NoPath then print("No path calculated! Please try again.") return else print("Unknown error occurred! Please try again.") end
    pathfindSuccess = false
end
    pathfindSuccess = true
    
    return pathfindSuccess
end

end

local virtualinputmanager = game:GetService("VirtualInputManager")

local function input(inputType, inputButton)
    if inputType == "leftclick" then
    local camera = workspace.CurrentCamera
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,true,game,1)
    wait(0.1)
    virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,false,game,1)
    elseif inputType == "pressbutton" then
        virtualinputmanager:SendKeyEvent(true, inputButton, false, game)
        wait(0.1)
        virtualinputmanager:SendKeyEvent(false, inputButton, false, game)
    end
end

local slot = plrgui.Hotbar.Container.HotbarList.Body
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
            input("pressbutton", Enum.KeyCode.Four)

            task.spawn(function()
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    wait(0.1)
                    humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                end
            end)
            
             while closestOre.DepositInfo.OreRemaining.Value > 0 do
                wait(0.1)
                input("leftclick")
            end
            input("pressbutton", Enum.KeyCode.Four)
        elseif slotItem == nil then print("No pickaxe found in slot 4.")
        elseif string.find(slotItem, "Pickaxe") then print("The selected pickaxe was not found in slot 4.", pickaxeSelected) return
        else

            task.spawn(function()
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    wait(0.1)
                    humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                end
            end)

            while closestOre.DepositInfo.OreRemaining.Value > 0 do
                wait(0.1)
                input("leftclick")
            end
            input("pressbutton", Enum.KeyCode.Four)
        end
    end
end

local function applyButtonFunctionality()

-- Exit button.
Exit.MouseButton1Down:Connect(function()
    WestZ:Destroy()
end)

-- Autofarm button.
startAutoFarm.MouseButton1Down:Connect(function()
    closestOreFarm()
end)

end

if isTweenFinished == true then
    applyButtonFunctionality()
end
