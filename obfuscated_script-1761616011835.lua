print("west z is an independently created autofarm script and is in no way related to west x.")

local player = game.Players.LocalPlayer
local plrgui = player.PlayerGui
local plrname = player.Name

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
startAutoFarm.TextColor3 = Color3.fromRGB(0, 0, 0)
startAutoFarm.Font = Enum.Font.SourceSansBold
startAutoFarm.Transparency = 1
startAutoFarm.Position = UDim2.new(0.5, -147, 0, 120)
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
        

        local tween = tweenservice:Create(element, tweenInfo, {Transparency = 0.5})
        tween:Play()
        elseif element:IsA("TextLabel") then
            local textTween = tweenservice:Create(element, tweenInfo, {TextTransparency = 0.5})
            textTween:Play()
            if i == #tweenParts then
                wait(1)
                isTweenFinished = true
            end
    end
end
local pathfindingservice = game:GetService("PathfindingService")
local character = wrkspceEnt.Players[plrname]
local humanoid = character.Humanoid
local nearestOres = {}
local oreIndex = {}
local humanoidrootpart = character.HumanoidRootPart

local closestOreDistance = nil
local closestOre = nil

path = pathfindingservice:CreatePath({
    AgentCanJump = true,
    AgentCanClimb = true,
    Costs = {Water = 20}
})

local function calcNearestOre(waypoints, i, ore)
    local waypoints = waypoints
    local localDistance = {}
    local waypointPos


    for i, waypoint in pairs(waypoints) do
            waypointPos = (waypoint.Position - humanoidrootpart.Position).Magnitude
            table.insert(localDistance,waypointPos)
    end
    local sum = 0
    for _, distance in pairs(localDistance) do
        sum = sum + distance
    end
    table.insert(nearestOres, sum)
    table.insert(oreIndex, ore.i)

end

local function FindNearestOre()
    for i, ore in pairs(ores) do
        if ore:IsA("Model") and ore.DepositInfo.OreRemaining.Value > 0 then
                success, errorMessage = pcall(function()
                    path:ComputeAsync(character.PrimaryPart.Position, ore.Position)
                end)
            ore.Name = "Ore" .. i
            calcNearestOre(path:GetWaypoints(), i, ore)
            closestOreDistance = nearestOres[i]
        end
    end
    
    print(closestOreDistance)
    for i, distance in pairs(nearestOres) do

        if distance < closestOreDistance then
            closestOreDistance = distance
            local oreHierarchy = oreIndex[i]

        closestOre = oreHierarchy
        finalpos = closestOre.PrimaryPart.Position
        end
    end

end

local function pathfind()
FindNearestOre() -- the rest from this point onwards needs to be in the button. cya.
finalpos = finalpos - Vector3.new(2,2,2)
print(closestOreDistance, "okay")
print(closestOre)
pathfindSuccess = nil
print(character.PrimaryPart.Position)
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
	
	local stuck = false

    print("Waypoints found: " .. #path:GetWaypoints())
    for i, waypoint in ipairs(path:GetWaypoints()) do
          
        local part = Instance.new("Part")
        part.Material = "Neon"
        part.Anchored = true
        part.CanCollide = false
        part.Shape = "Ball"
        part.Position = waypoint.Position
        part.Parent = game.Workspace:WaitForChild("Path")
        part.Name = "part"..i
        local actualpos = character:GetAttribute("finalpos")
	
	local waypoints = path:GetWaypoints()
	local finished = false
	local maxTime = 10
	local jumpTime = 5
	local timeElapsed = 0

        if actualpos ~= finalpos then return end
        humanoid:MoveTo(waypoint.Position)

		end
        end)
	
        task.spawn(function() --remove if statement and just keep wait(0.25+i/2) and part:Destroy() if you want a quicker deletion
            if i == 0 then

                wait(1)
                part:Destroy()
                else
                    wait(0.25 + i / 2)
                    part:Destroy()
            end
        end)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        humanoid.MoveToFinished:Wait()

    end
else
    if path.Status == path.NoPath then print("No path calculated! Please try again.") else print("Unknown error occurred! Please try again.") end
    pathfindSuccess = false
end
    pathfindSuccess = true
    task.spawn(function()
    while closestOre.DepositInfo.OreRemaining.Value > 0 do
    humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
    end
    end)
    return pathfindSuccess
end

end

local virtualinputmanager = game:GetService("VirtualInputManager")

local function input(inputType)
    if inputType == "leftclick" then
    local camera = workspace.CurrentCamera
    local centerX = camera.ViewportSize.X / 2
    local centerY = camera.ViewportSize.Y / 2
    virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,true,game,1)

    virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,false,game,1)
    elseif inputType == "pressF" then
        virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

local function closestOreFarm()
    --put in a while loop tomorrow, it has to check if your inventory is 30/30 and then it will stop and go to sell it all.
    pathfindSuccess = nil
    pathfind()
    while pathfindSuccess == nil do
        wait(0.1)
    end
    if pathfindSuccess == true then
        while closestOre.DepositInfo.OreRemaining.Value > 0 do
            wait(0.1)
            input("leftclick")
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
