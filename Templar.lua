player = game.Players.LocalPlayer
plrgui = player:WaitForChild("PlayerGui")
plrname = player.Name

if plrgui:FindFirstChild("Templar") then
return
else

local parentDirectory = "../"
local folderName = "TWW_Templar"
local fullFolderPath = parentDirectory .. folderName

if not game.Workspace:FindFirstChild("Path") then
        folder = Instance.new("Folder")
        folder.Parent = game.Workspace
        folder.Name = "Path"
end

sortedOreIndex = {}

if isfolder(folderName) then
    print("Paths folder already exists.")
else
    if not pcall(function() makefolder(folderName) print("Path folder created at: " .. fullFolderPath) end) then
        print("Function makefolder not supported.")
    end
end

local settingsCfg = "TWW_Templar/settings.cfg"

local settingsText = [[
BasicPickaxe
-- File name
isAutoFarmRunning = false
pathFileRunning = nil
]]

if isfile(settingsCfg) then
    print("Settings config already exists.")
else
    if not pcall(function() writefile(settingsCfg, settingsText) print("Settings config created at: " .. fullFolderPath) end) then
        print("Function makefolder not supported.")
    end
end

local fileContent = readfile(settingsCfg)

local lines = {}
for line in fileContent:gmatch("[^\r\n]+") do
    table.insert(lines, line)
end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Servers = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

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

local smallestServer = nil
local smallestPlayers = math.huge
local Next = nil
local allServers = {}

local function tp()
    
    repeat
    local ServerList = ListServers(Next)
    
    if ServerList and ServerList.data then
        for _, server in pairs(ServerList.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(allServers, server)
                if server.playing < smallestPlayers then
                    smallestPlayers = server.playing
                    smallestServer = server
                end
            end
        end
        
        Next = ServerList.nextPageCursor
    else
        break
    end

until not Next or smallestServer
    
    if smallestServer then
        print("Teleporting to server with " .. smallestPlayers .. " players")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, smallestServer.id, game.Players.LocalPlayer)
    else
        local randomServer = allServers[math.random(1, #allServers)]
        warn("Could not find lowest player server. Joining random server...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, game.Players.LocalPlayer)
    end
end

local attributeSet = game.Workspace:FindFirstChild("attributeSet")

if not attributeSet then
    attributeSet = Instance.new("BoolValue")
    attributeSet.Parent = game.Workspace
    attributeSet.Name = "attributeSet"
    attributeSet = game.Workspace:WaitForChild("attributeSet")
end

local function generateUniqueID(ore)
    local primary = ore.PrimaryPart or ore:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil end
    
    local pos = primary.Position
    local size = primary.Size
    
    local id = string.format("%s_%.0f_%.0f_%.0f_%.1f_%.1f_%.1f_%d",
        ore.Parent.Name,
        math.floor(pos.X),
        math.floor(pos.Y),
        math.floor(pos.Z),
        size.X, size.Y, size.Z,
        #ore:GetChildren()
    )
    
    return id
end

if attributeSet.Value == false then
    attributeSet.Value = true
    local oreFolder = workspace.WORKSPACE_Interactables.Mining.OreDeposits
    for _, model in ipairs(oreFolder:GetDescendants()) do
        if model:IsA("Model") then
            local id = generateUniqueID(model)
            if id then
                model:SetAttribute("UniqueOreID", id)
                print("Assigned:", id)
            end
        end
    end
end

exemption = {"startAutoFarm", "settingsFrame", "pathedAutoFarm", "pathSelector", "pathrecButton"}
fullExemption = {"automineTab", "webhooksTab", "configTab"}
tweenExemption = {"automine", "webhook", "mineconfig"}

taskbarButtons = {}

pickaxeSelected = lines[1]
local pickaxeTiers = {"BasicPickaxe", "Tier1Pickaxe", "Tier2Pickaxe", "Tier3Pickaxe", "Tier4Pickaxe", "Tier5Pickaxe", "Tier6Pickaxe", "Tier7Pickaxe", "Tier8Pickaxe","Tier9Pickaxe"}

local old = {9, 137, 207}
local colourTheme = {255, 255, 255}

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

local function toggleWalkSpeed()
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
end

wrkspceInt = game.Workspace.WORKSPACE_Interactables
wrkspceEnt = game.Workspace.WORKSPACE_Entities

local mining = wrkspceInt.Mining
local oredeposits = mining.OreDeposits
local ores = oredeposits:GetDescendants()

Templar = Instance.new("ScreenGui")
Templar.Parent = plrgui
Templar.Name = "Templar"

draggable = Instance.new("Frame")
draggable.Parent = Templar
draggable.Name = "Draggable"
draggable.Transparency = 1
draggable.Size = UDim2.new(0, 800, 0, 600)
draggable.Position = UDim2.new(0.5, -400, 0.5, -400)

automineTab = Instance.new("Frame")
automineTab.Parent = draggable
automineTab.Name = "automineTab"
automineTab.Size = UDim2.new(0, 800, 0, 600)
automineTab.Position = UDim2.new(0.5, -400, 0.5, -300)
automineTab.BackgroundTransparency = 1
automineTab.ZIndex = 0
automineTab.ClipsDescendants = true

webhooksTab = Instance.new("Frame")
webhooksTab.Parent = draggable
webhooksTab.Name = "webhooksTab"
webhooksTab.Size = UDim2.new(0, 800, 0, 600)
webhooksTab.Position = UDim2.new(0.5, -400, 0.5, -300)
webhooksTab.BackgroundTransparency = 1
webhooksTab.ZIndex = 0
webhooksTab.ClipsDescendants = true
webhooksTab.Visible = false

configTab = Instance.new("Frame")
configTab.Parent = draggable
configTab.Name = "configTab"
configTab.Size = UDim2.new(0, 800, 0, 600)
configTab.Position = UDim2.new(0.5, -400, 0.5, -300)
configTab.BackgroundTransparency = 1
configTab.ZIndex = 0
configTab.ClipsDescendants = true
configTab.Visible = false

sliderFrame = Instance.new("Frame")
sliderFrame.Parent = automineTab
sliderFrame.Transparency = 1
sliderFrame.Size = UDim2.new(0, 200, 0, 15)
sliderFrame.Position = UDim2.new(0.5, -300, 0, 265)
sliderFrame.Name = "SliderFrame"
sliderFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)

local sliderUI = Instance.new("UICorner")
sliderUI.Parent = sliderFrame

slider = Instance.new("Frame")
slider.Parent = automineTab
slider.Transparency = 1
slider.Size = UDim2.new(0, 10, 0, 30)
slider.Position = UDim2.new(0,105,0,256)
slider.Name = "Slider"
slider.BackgroundColor3 = Color3.fromRGB(0,0,0)
slider.BorderSizePixel = 2
slider.BorderColor3 = Color3.fromRGB(unpack(colourTheme))

local sliderUIDetector = Instance.new("UIDragDetector")
sliderUIDetector.Parent = slider
sliderUIDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
sliderUIDetector.DragAxis = Vector2.new(1,0)
sliderUIDetector.MinDragTranslation = UDim2.new(-0.501,0,0)
sliderUIDetector.MaxDragTranslation = UDim2.new(0.50,0,0)
sliderUIDetector.ReferenceUIInstance = sliderFrame

sliderText = Instance.new("TextLabel")
sliderText.Parent = automineTab
sliderText.BackgroundTransparency = 1
sliderText.TextTransparency = 1
sliderText.Text = "Pickaxe Tier: " .. pickaxeSelected
sliderText.Size = UDim2.new(0, 300, 0, 50)
sliderText.TextSize = 25
sliderText.Font = Enum.Font.GothamBold
sliderText.Position = UDim2.new(0.5, -350, 0, 200)
sliderText.TextColor3 = Color3.fromRGB(unpack(colourTheme))
sliderText.Name = "sliderText"

local function updateSliderPos()
    local totalWidth = sliderFrame.AbsoluteSize.X - slider.AbsoluteSize.X
    local intervalCount = #pickaxeTiers
    local intervalWidth = totalWidth / (intervalCount - 1)

    local index = table.find(pickaxeTiers, pickaxeSelected)

    local pos = (index - 1) * 21

    slider.Position = UDim2.new(0, 105 + pos, 0, 256)
end

updateSliderPos()

sliderUIDetector.DragContinue:Connect(function()

    local totalWidth = sliderFrame.AbsoluteSize.X - slider.AbsoluteSize.X - 1
    local intervalCount = 10
    local intervalWidth = totalWidth / (intervalCount - 1)

    local xPos = slider.Position.X.Offset

    local nearestIndex = math.floor((xPos + intervalWidth/2) / intervalWidth)
    local snappedX = nearestIndex * intervalWidth
    
    slider.Position = UDim2.new(0, snappedX, slider.Position.Y.Scale, slider.Position.Y.Offset)
    
    local currentPos = slider.Position
    local difference = currentPos.X.Offset - 105
    
    local text = nil
    
    if difference == 0 then
        text = pickaxeTiers[1]
    else
        multiplier = difference / 21
        text = pickaxeTiers[multiplier + 1]
    end
    sliderText.Text = "Pickaxe Tier: " .. text

end)

sliderUIDetector.DragEnd:Connect(function()
    local currentPos = slider.Position
    local difference = currentPos.X.Offset - 105
    
    local text = nil
    
    if difference == 0 then
        text = pickaxeTiers[1]
    else
        multiplier = difference / 21
        text = pickaxeTiers[multiplier + 1]
    end
    pickaxeSelected = pickaxeTiers[multiplier + 1]
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
Frame.Name = "backgroundFrame"

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
startAutoFarm.Parent = automineTab
startAutoFarm.Text = "Nearest Ore (deprecated)"
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

pathedAutoFarm = Instance.new("TextButton")
pathedAutoFarm.Parent = automineTab
pathedAutoFarm.Text = "Premade Route"
pathedAutoFarm.Size = UDim2.new(0, 300, 0, 50)
pathedAutoFarm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
pathedAutoFarm.TextSize = 20
pathedAutoFarm.TextColor3 = Color3.fromRGB(255,255,255)
pathedAutoFarm.Font = Enum.Font.SourceSansBold
pathedAutoFarm.Transparency = 1
pathedAutoFarm.Position = UDim2.new(0.5, 50, 0, 140)
pathedAutoFarm.Name = "pathedAutoFarm"

local pathedAutoFarmCorner = Instance.new("UICorner")
pathedAutoFarmCorner.Parent = pathedAutoFarm

pathSelector = Instance.new("TextBox")
pathSelector.Text = "-- File name"
pathSelector.Parent = automineTab
pathSelector.Size = UDim2.new(0, 250, 0, 40)
pathSelector.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
pathSelector.BorderSizePixel = 1
pathSelector.BorderColor3 = Color3.fromRGB(unpack(colourTheme))
pathSelector.TextSize = 20
pathSelector.TextColor3 = Color3.fromRGB(255,255,255)
pathSelector.Font = Enum.Font.SourceSansBold
pathSelector.Transparency = 1
pathSelector.Position = UDim2.new(0.5, 75, 0, 215)
pathSelector.Name = "pathSelector"

pathRecorder = Instance.new("Frame")
pathRecorder.Parent = Templar
pathRecorder.AnchorPoint = Vector2.new(0.5, 0.5)
pathRecorder.Position = UDim2.new(0.5,0,0.5,0)
pathRecorder.Size = UDim2.new(0,601,0,500)
pathRecorder.Visible = false
pathRecorder.BackgroundColor3 = Color3.fromRGB(0,0,0)
pathRecorder.BackgroundTransparency = 0.3
pathRecorder.Name = "PathRecorder"

pathRecorderCorner = Instance.new("UICorner")
pathRecorderCorner.Parent = pathRecorder

pthRecDragDetector = Instance.new("UIDragDetector")
pthRecDragDetector.Parent = pathRecorder

recPosButton = Instance.new("TextButton")
recPosButton.Parent = pathRecorder
recPosButton.Text = "Record Position"
recPosButton.Size = UDim2.new(0, 159, 0, 50)
recPosButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recPosButton.TextSize = 20
recPosButton.TextColor3 = Color3.fromRGB(255,255,255)
recPosButton.Font = Enum.Font.SourceSansBold
recPosButton.Position = UDim2.new(1.187, -350, -0.106, 140)
recPosButton.Name = "recPosButton"

recPosButtonCorner = Instance.new("UICorner")
recPosButtonCorner.Parent = recPosButton

recSellPosButton = Instance.new("TextButton")
recSellPosButton.Parent = pathRecorder
recSellPosButton.Text = "Record Sell Position"
recSellPosButton.Size = UDim2.new(0, 159, 0, 50)
recSellPosButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recSellPosButton.TextSize = 20
recSellPosButton.TextColor3 = Color3.fromRGB(255,255,255)
recSellPosButton.Font = Enum.Font.SourceSansBold
recSellPosButton.Position = UDim2.new(0.723, -350, -0.106, 140)
recSellPosButton.Name = "recSellPosButton"

recSellPosButtonCorner = Instance.new("UICorner")
recSellPosButtonCorner.Parent = recSellPosButton

recBronze = Instance.new("TextButton")
recBronze.Parent = pathRecorder
recBronze.Text = "Bronze Spawn"
recBronze.Size = UDim2.new(0, 159, 0, 50)
recBronze.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recBronze.TextSize = 20
recBronze.TextColor3 = Color3.fromRGB(255,255,255)
recBronze.Font = Enum.Font.SourceSansBold
recBronze.Position = UDim2.new(0.633, -350, 0.144, 140)
recBronze.Name = "recBronze"

recBronzeCorner = Instance.new("UICorner")
recBronzeCorner.Parent = recBronze

recPuerto = Instance.new("TextButton")
recPuerto.Parent = pathRecorder
recPuerto.Text = "Puerto Dorado Spawn"
recPuerto.Size = UDim2.new(0, 159, 0, 50)
recPuerto.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recPuerto.TextSize = 20
recPuerto.TextColor3 = Color3.fromRGB(255,255,255)
recPuerto.Font = Enum.Font.SourceSansBold
recPuerto.Position = UDim2.new(0.949, -350, 0.144, 140)
recPuerto.Name = "recPuerto"

recPuertoCorner = Instance.new("UICorner")
recPuertoCorner.Parent = recPuerto

recReservation = Instance.new("TextButton")
recReservation.Parent = pathRecorder
recReservation.Text = "Reservation Spawn"
recReservation.Size = UDim2.new(0, 159, 0, 50)
recReservation.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recReservation.TextSize = 20
recReservation.TextColor3 = Color3.fromRGB(255,255,255)
recReservation.Font = Enum.Font.SourceSansBold
recReservation.Position = UDim2.new(1.267, -350, 0.144, 140)
recReservation.Name = "recReservation"

recReservationCorner = Instance.new("UICorner")
recReservationCorner.Parent = recReservation

recDelores = Instance.new("TextButton")
recDelores.Parent = pathRecorder
recDelores.Text = "Delores' Ranch Spawn"
recDelores.Size = UDim2.new(0, 159, 0, 50)
recDelores.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recDelores.TextSize = 20
recDelores.TextColor3 = Color3.fromRGB(255,255,255)
recDelores.Font = Enum.Font.SourceSansBold
recDelores.Position = UDim2.new(0.632, -350, 0.278, 140)
recDelores.Name = "recDelores"

recDeloresCorner = Instance.new("UICorner")
recDeloresCorner.Parent = recDelores

recHowling = Instance.new("TextButton")
recHowling.Parent = pathRecorder
recHowling.Text = "Howling Peak Spawn"
recHowling.Size = UDim2.new(0, 159, 0, 50)
recHowling.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recHowling.TextSize = 20
recHowling.TextColor3 = Color3.fromRGB(255,255,255)
recHowling.Font = Enum.Font.SourceSansBold
recHowling.Position = UDim2.new(0.949, -350, 0.278, 140)
recHowling.Name = "recHowling"

recHowlingCorner = Instance.new("UICorner")
recHowlingCorner.Parent = recHowling

recOutlaws = Instance.new("TextButton")
recOutlaws.Parent = pathRecorder
recOutlaws.Text = "Outlaw's Perch Spawn"
recOutlaws.Size = UDim2.new(0, 159, 0, 50)
recOutlaws.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recOutlaws.TextSize = 20
recOutlaws.TextColor3 = Color3.fromRGB(255,255,255)
recOutlaws.Font = Enum.Font.SourceSansBold
recOutlaws.Position = UDim2.new(1.267, -350, 0.278, 140)
recOutlaws.Name = "recOutlaws"

recOutlawsCorner = Instance.new("UICorner")
recOutlawsCorner.Parent = recOutlaws

recWindmill = Instance.new("TextButton")
recWindmill.Parent = pathRecorder
recWindmill.Text = "Windmill Camp Spawn"
recWindmill.Size = UDim2.new(0, 159, 0, 50)
recWindmill.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
recWindmill.TextSize = 20
recWindmill.TextColor3 = Color3.fromRGB(255,255,255)
recWindmill.Font = Enum.Font.SourceSansBold
recWindmill.Position = UDim2.new(0.949, -350, 0.414, 140)
recWindmill.Name = "recWindmill"

recWindmillCorner = Instance.new("UICorner")
recWindmillCorner.Parent = recWindmill

pathrecLabel = Instance.new("TextLabel")
pathrecLabel.Parent = pathRecorder
pathrecLabel.BackgroundTransparency = 1
pathrecLabel.TextSize = 30
pathrecLabel.Size = UDim2.new(0,200,0,50)
pathrecLabel.Position = UDim2.new(0.333,0,0.028,0)
pathrecLabel.TextColor3 = Color3.fromRGB(255,255,255)
pathrecLabel.Text = "Path Recorder"

pathrecSpawnLabel = Instance.new("TextLabel")
pathrecSpawnLabel.Parent = pathRecorder
pathrecSpawnLabel.BackgroundTransparency = 1
pathrecSpawnLabel.TextSize = 30
pathrecSpawnLabel.Size = UDim2.new(0,200,0,50)
pathrecSpawnLabel.Position = UDim2.new(0.333, 0, 0.304, 0)
pathrecSpawnLabel.TextColor3 = Color3.fromRGB(255,255,255)
pathrecSpawnLabel.Text = "Spawns:"

pathrecButton = Instance.new("TextButton")
pathrecButton.Parent = configTab
pathrecButton.Text = "Path Recorder"
pathrecButton.Size = UDim2.new(0, 300, 0, 50)
pathrecButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
pathrecButton.TextSize = 20
pathrecButton.TextColor3 = Color3.fromRGB(255,255,255)
pathrecButton.Font = Enum.Font.SourceSansBold
pathrecButton.Position = UDim2.new(0.5, -350, 0, 140)
pathrecButton.Name = "pathrecButton"

local pathrecButtonCorner = Instance.new("UICorner")
pathrecButtonCorner.Parent = pathrecButton

recExit = Instance.new("TextButton")
recExit.Parent = pathRecorder
recExit.Text = "X"
recExit.Size = UDim2.new(0, 30, 0, 30)
recExit.BackgroundColor3 = Color3.fromRGB(50,50,50)
recExit.Font = Enum.Font.SourceSansBold
recExit.Position = UDim2.new(0.92, 0, 0.028, 0)
recExit.TextSize = 20
recExit.TextColor3 = Color3.fromRGB(255,255,255)
recExit.Name = "Exit"
recExit.BackgroundTransparency = 1
table.insert(taskbarButtons, recExit)

local recExitCorner = Instance.new("UICorner")
recExitCorner.Parent = recExit

nameSelector = Instance.new("TextBox")
nameSelector.Text = "-- Select a file name"
nameSelector.Parent = draggable
nameSelector.Size = UDim2.new(0, 250, 0, 40)
nameSelector.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nameSelector.BorderSizePixel = 1
nameSelector.BorderColor3 = Color3.fromRGB(unpack(colourTheme))
nameSelector.TextSize = 20
nameSelector.TextColor3 = Color3.fromRGB(255, 255, 255)
nameSelector.Font = Enum.Font.SourceSansBold
nameSelector.Position = UDim2.new(0.5, 75, 0, 215)
nameSelector.Name = "nameSelector"
nameSelector.AnchorPoint = Vector2.new(0.5, 0.5)
nameSelector.Position = UDim2.new(0.5,0,0.5,0)
nameSelector.Visible = false

local function updateConfig(path, autoFarmVal, fileRunningVal)
    if not isfile(path) then return end

    local content = readfile(path)
    local newLines = {}

    for line in content:gmatch("[^\r\n]+") do
        if line:match("^%s*isAutoFarmRunning%s*=") then
            table.insert(newLines, "isAutoFarmRunning = " .. tostring(autoFarmVal))
        elseif line:match("^%s*pathFileRunning%s*=") then
            table.insert(newLines, "pathFileRunning = " .. tostring(fileRunningVal))
        else
            table.insert(newLines, line)
        end
    end

    writefile(path, table.concat(newLines, "\n"))
end

function lineFormatter()
    fileContent = readfile("TWW_Templar/" .. pathSelector.Text)
    parseLines = {}
    for line in fileContent:gmatch("[^\r\n]+") do
        table.insert(parseLines, line)
    end
    updateConfig(settingsCfg, true, pathSelector.Text)
    return parseLines
end

local UserInputService = game:GetService("UserInputService")

local function waitForEnter()
    local connection
    local pressed = Instance.new("BindableEvent")

    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return then
            connection:Disconnect()
            pressed:Fire()
        end
    end)

    pressed.Event:Wait()
end

function createTXTFile()
    local userInputName = nil
    nameSelector.Visible = true
    
    while true do
        waitForEnter()

        if nameSelector.Text:match("^%s*$") then
            print("No name was entered. Please enter a valid name.")
        else
            userInputName = nameSelector.Text
            local fileName = userInputName .. ".dat"
            fullPath = folderName .. "/" .. fileName

            writefile(fullPath, "")

            print("File created at:", fullPath)
            nameSelector.Visible = false
            return fullPath
        end
    end
end

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
    if element:IsA("Frame") and not table.find(fullExemption, element.Name) or table.find(exemption, element.Name) then
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
    if i == #tweenParts then
        wait(1)
        isTweenFinished = true
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

local pickaxeIndex = table.find(pickaxeTiers, pickaxeSelected)

local function collisionOff(ore)
    if ore:FindFirstChild("RockBase") then ore.RockBase.CanCollide = false end
    if ore:FindFirstChild("RockBaseL") then ore.RockBaseL.CanCollide = false end
    if ore:FindFirstChild("RockBaseVein") then ore.RockBaseVein.CanCollide = false end
    if ore:FindFirstChild("RockBaseLVein") then ore.RockBaseLVein.CanCollide = false end
end

waypointTable = {}

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
    table.insert(waypointTable, waypoints)
end

local function calculatePaths()
    local successes = 0
    local failures = 0
    local unknown = 0
    
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
                    successes = successes + 1

                elseif path.Status == Enum.PathStatus.NoPath then
                    failures = failures + 1

                else
                    unknown = unknown + 1
                end
        end
    end
    print("Paths found: ", successes)
    print("Paths failed: ", failures)
    print("Paths unknown: ", unknown)
    return successes
end

local nearestWaypoints = {}

waypointOrder = {}

function FindNearestOre()
    nearestOres = {}
    oreIndex = {}
    closestOreDistance = math.huge
    closestOre = nil
    finalpos = nil
    oreHierarchy = nil
    oreCheckpoints = {}
    sortedOreIndex = {}

    calculatePaths()
    
    local sortedOres = {}
    for i, distance in ipairs(nearestOres) do
        table.insert(sortedOres, {index = i, distance = distance})
    end
    
    table.sort(sortedOres, function(a, b)
        return a.distance < b.distance
    end)
    
    for _, data in ipairs(sortedOres) do
        local i = data.index
        local ore = oreIndex[i]
        local pos = ore.PrimaryPart.Position

        table.insert(oreCheckpoints, pos)
        table.insert(nearestWaypoints, waypointTable[i])
        table.insert(sortedOreIndex, ore)
    end

    if #sortedOres > 0 then
        local closestIndex = sortedOres[1].index
        closestOre = sortedOreIndex[1]
        closestOreDistance = sortedOres[1].distance
        finalpos = closestOre.PrimaryPart.Position
    end
end

local function pathCalculator()
    local index = 0
    for i, waypoints in pairs(nearestWaypoints) do
        index = index + 1
        if i == 1 then
            table.insert(waypointOrder, waypoints)
        else
            local success, errorMessage = pcall(function()
                path:ComputeAsync(oreCheckpoints[index - 1], oreCheckpoints[index])
            end)
            if success then
                table.insert(waypointOrder, path:GetWaypoints())
            else
                index = index - 1
            end
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
Global = require(ReplicatedStorage.SharedModules.Global)

local bodyVelocity = nil
local bodyGyro = nil
isRagdollFlying = false

isRagdollEnabled = false

function enableRagdollFly()
    isRagdollEnabled = true
    if isRagdollFlying then return end

    Global.PlayerCharacter:Ragdoll(nil, true)
    task.wait(0.5)
    
    character = wrkspceEnt.Players[plrname]
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("Motor6D") then
            part.Enabled = true
        end
        if part:IsA("BallSocketConstraint") then
            part.Enabled = false
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

function disableRagdollFly()
    isRagdollEnabled = false
    if not isRagdollFlying then return end

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    hrp = wrkspceEnt.Players[plrname].HumanoidRootPart
    
    for _, weld in pairs(hrp:GetChildren()) do
        if weld:IsA("WeldConstraint") then
            weld:Destroy()
        end
    end
    Global.PlayerCharacter:Ragdoll()
    wait(0.1)
    Global.PlayerCharacter:GetUp()
    task.wait(1.5)

    isRagdollFlying = false
end

moveComplete = false

function ragdollMoveTo(targetPos)
    if not isRagdollFlying then
        return false 
    end
    hrp = wrkspceEnt.Players[plrname].HumanoidRootPart
    
    bodyVelocity.Parent = hrp
    bodyGyro.Parent = hrp

    local speed = 75

    targetPos = Vector3.new(targetPos.X, targetPos.Y - 3, targetPos.Z)

    local stuckTimer = 0
    local lastPos = hrp.Position

    while true do
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos)
        local distance = direction.Magnitude
        
        if (currentPos - lastPos).Magnitude < 0.1 then
            stuckTimer = stuckTimer + 1
            if stuckTimer > 100 then
                return false
            end
        else
            stuckTimer = 0
            lastPos = currentPos
        end

        if distance < 1 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            moveComplete = true
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

function waypointVisualizer()
    pathCalculator()
    print("Loading path...")
    for i, waypoints in pairs(waypointOrder) do
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

            end
        end
    end
    print("Path loaded")
end

function pathfind(index)
closestOre = sortedOreIndex[index]
finalpos = oreCheckpoints[index]
print("Closest ore found: " .. closestOreDistance)
pathfindSuccess = nil
print(path.Status)

	if nearestWaypoints[1] then

    	enableRagdollFly()

    	print("Moving to pos: ", finalpos)

    	for i, waypoint in ipairs(waypointOrder[index]) do
	    	local waypoints = path:GetWaypoints()
	    	local finished = false
	    	local maxTime = 10
	    	local jumpTime = 5
	    	local timeElapsed = 0

        	ragdollMoveTo(waypoint.Position + Vector3.new(0,10,0))
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

local function input(inputType, inputButton, timeInterval, amount)
    task.defer(function()
        if inputType == "leftclick" then
            local camera = workspace.CurrentCamera
            local centerX = camera.ViewportSize.X / 2
            local centerY = camera.ViewportSize.Y / 2
            virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,true,game,1)
            wait(0.2)
            virtualinputmanager:SendMouseButtonEvent(centerX,centerY,0,false,game,1)
        elseif inputType == "pressbutton" then
            for i = 1, amount do
                virtualinputmanager:SendKeyEvent(true, inputButton, false, game)
                wait(timeInterval)
                virtualinputmanager:SendKeyEvent(false, inputButton, false, game)
            end
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
local slotItem = slot.HotbarSlot_Utility_1.Container.Slot.ViewportFrame:GetChildren()[1].Name

local function nearestOreFarm()
        pathfindSuccess = nil
        FindNearestOre()
        waypointVisualizer()
    for i,v in ipairs(waypointOrder) do
        pathfind(i)
        while pathfindSuccess == nil do -- waits until path is complete
            wait(0.1)
        end
        print("Closest ore: ", closestOre)
        if pathfindSuccess == true then
            if slotItem == pickaxeSelected and character:FindFirstChild("LoadoutItem/" .. slotItem) then
                print("Pickaxe not selected!")
                wait(1)
                input("pressbutton", Enum.KeyCode.Four, 1)
                local playerChar = require(game:GetService("ReplicatedStorage").Modules.Character.PlayerCharacter)
                local equippeditem = playerChar:GetEquippedItem()
                local pickaxeItem = playerChar:GetItem(pickaxeSelected)
                pickaxeItem.CameraFreeLook = true
                task.spawn(function()
                    while closestOre.DepositInfo.OreRemaining.Value > 0 do
                        wait(0.1)
                        humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                        pickaxeItem:Swing()
                    end
                end)
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    input("pressbutton", Enum.KeyCode.E, 1, 1)
                    wait(1)
                end
                input("pressbutton", Enum.KeyCode.Four, 1)
            elseif slotItem == nil then print("No pickaxe found in slot 4.")
            elseif string.find(slotItem, "Pickaxe") then warn("The selected pickaxe was not found in slot 4.", pickaxeSelected)
            else
                task.spawn(function()
                    while closestOre.DepositInfo.OreRemaining.Value > 0 do
                        wait(0.1)
                        humanoidrootpart.CFrame = CFrame.lookAt(humanoidrootpart.Position, Vector3.new(finalpos.X, humanoidrootpart.Position.Y, finalpos.Z))
                        pickaxeItem:Swing()
                    end
                end)
                while closestOre.DepositInfo.OreRemaining.Value > 0 do
                    input("pressbutton", Enum.KeyCode.E, 1, 1)
                    wait(1)
                end
                input("abortLeftClick")
                input("pressbutton", Enum.KeyCode.Four)
                virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
            end
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

buttonsDeleted = {startAutoFarm,sliderFrame,sliderText,slider,separationFrame,automine,webhook,mineconfig,pathedAutoFarm,pathSelector,pathrecButton}

local UserInputService = game:GetService("UserInputService")

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {character} -- ignore the player

local recording = false

local oreType = nil
local oreID = nil

local function recordMine()
    local oreType = oreType.Name
    local text = "mine, " .. oreType .. ", " .. oreID .. [[

]]

    appendfile(fullPath, text)

end

local camera = workspace.CurrentCamera

local function onClick(input, gameProcessed)
    if not recording then return end
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)

        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if result then
            local part = result.Instance

            if part.Parent and part.Parent:IsA("Model") and string.find(part.Name, "Rock") then
                print("Ore: ", part.Parent.Name)
                print("Ore Type: ", part.Parent.Parent.Name)
                oreType = part.Parent.Parent
                orePart = part.Parent.PrimaryPart
                oreID = part.Parent:GetAttribute("UniqueOreID")
                print(oreID)
                recordMine()
            end
        else
            print("Nothing clicked, data not recorded.")
        end
    end
end

local function recordPosition()
    local pos = wrkspceEnt.Players[plrname].HumanoidRootPart.Position
    local posString = tostring(pos)
    local text = "move, " .. posString .. [[

]]

    appendfile(fullPath, text)
end

local function recordSellPosition()
    local pos = humanoidrootpart.Position
    local posString = tostring(pos)
    local text = "sell, " .. posString .. [[

]]

    appendfile(fullPath, text)
end

local function recordSpawn(spawnLocation)
    local text = spawnLocation .. [[

]]

    appendfile(fullPath, text)
end

local function startRecording()
    recording = not recording
    UserInputService.InputBegan:Connect(onClick)
end

local recordSpawns = {
    {button = recBronze, string = "Bronze"},
    {button = recPuerto, string = "Dorado"},
    {button = recReservation, string = "Tribal"},
    {button = recDelores, string = "Delores"},
    {button = recHowling, string = "Howling"},
    {button = recOutlaws, string = "CanyonCamp"},
    {button = recWindmill, string = "WindmillCamp"}
}

local function automineSpawn(spawnLocation)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UI = require(ReplicatedStorage.Modules.UI.NewUI.UI)
    local Network = require(ReplicatedStorage.SharedModules.Global.Network)

    local success, errorMessage

    repeat
        success, errorMessage = pcall(function()
            Network:FireServer("RespawnTriggered")
        end)

        if not success then
            task.wait(0.5)
        end
    until success

    Network:InvokeServer("Respawn", spawnLocation)
end

local function tabCycle(tab)
    if tab ~= automineTab and automineTab.Visible == true then
        automineTab.Visible = false
    elseif tab ~= configTab and configTab.Visible == true then
        configTab.Visible = false
    else
        webhooksTab.Visible = false
    end
    tab.Visible = true
end

local isAFRunning = false

local function sell()
    disableRagdollFly()
    input("pressbutton", Enum.KeyCode.F, 1, 3)
end

local function pathMine(ore)
    hrp = wrkspceEnt.Players[plrname].HumanoidRootPart
    disableRagdollFly()
    wait(0.1)
    input("pressbutton", Enum.KeyCode.Four, 1, 1)
    local playerChar = require(game:GetService("ReplicatedStorage").Modules.Character.PlayerCharacter)
    local equippeditem = playerChar:GetEquippedItem()
    local pickaxeItem = playerChar:GetItem("BasicPickaxe")
    wait(0.5)
    pickaxeItem.CameraFreeLook = true
    local orePos = ore.PrimaryPart.Position
    task.spawn(function()
        while ore.DepositInfo.OreRemaining.Value > 0 do
            wait(0.1)
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(orePos.X, hrp.Position.Y, orePos.Z))
            pickaxeItem:Swing()
        end
    end)
    while ore.DepositInfo.OreRemaining.Value > 0 do
        input("pressbutton", Enum.KeyCode.E, 1, 1)
        wait(1)
    end
    input("pressbutton", Enum.KeyCode.Four, 1, 1)
end

local function mineOre(oreName, oreID)
    local ores = workspace.WORKSPACE_Interactables.Mining.OreDeposits[oreName]:GetChildren()
    
    for _,ore in pairs(ores) do
        if ore:GetAttribute("UniqueOreID") == oreID then
            print(id)
            targetOre = ore
            break
        end
    end
    pathMine(targetOre)
end

local spawnLookup = {}
for _, spawn in ipairs(recordSpawns) do
    spawnLookup[spawn.string] = true
end

local function parsePath(lines)
    first = true
    pathCompleted = false
    for i, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$")

        local action, x, y, z = line:match("^(%w+),%s*([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
        if action then
            local position = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
            if action == "sell" then
                sell()
            elseif action == "move" then
                
                wrkspceEnt.Players:WaitForChild(plrname)
                if first == true or isRagdollEnabled == false then enableRagdollFly() end
                if first == true or isRagdollEnabled == false then repeat task.wait() until isRagdollFlying == true end
                moveComplete = false
                ragdollMoveTo(position)
                repeat task.wait() until moveComplete == true
                first = false
            else
                warn("Unknown action with coordinates:", line)
            end

        else
            local oreName, oreID = line:match("^mine,%s*([^,]+)%s*,%s*([^,]+)%s*$")
            if oreName and oreID then
                print(oreName)
                print(oreID)
                mineOre(oreName, oreID)
            elseif spawnLookup[line] then
                automineSpawn(line)
            else
                warn("Unknown line:", line)
            end
        end
    end
    pathCompleted = true
end

local function pathAutomine(customCall)
    local key, value = line:match("^%s*([%w_]+)%s*=%s*(.+)%s*$")
    if key and value then

        if value == "true" then
            value = true
        elseif value == "false" then
            value = false
        elseif value == "nil" then
            value = nil
        end

        if key == "isAutoFarmRunning" then
            isRunning = value
        elseif key == "pathFileRunning" then
            pathFileRunning = value
        end
    end
    if isAutoFarmRunning == true or customCall == true then
        lineFormatter()
        parsePath(parseLines)
        repeat task.wait() until pathCompleted == true
        tp()
    end
end

wait(5)

pathAutomine(true)

local function applyButtonFunctionality()

for _,table in pairs(recordSpawns) do
    table.button.MouseButton1Click:Connect(function()
        recordSpawn(table.string)
    end)
end

pathrecButton.MouseButton1Down:Connect(function()
    local pathBool = pathRecorder.Visible
    isPathRecOn = false
    
    if pathBool == false then
        createTXTFile()
        startRecording()
        pathRecorder.Visible = true
        isPathRecOn = true
    else
        startRecording()
        pathRecorder.Visible = false
        isPathRecOn = false
    end
end)

recExit.MouseButton1Down:Connect(function()
    pathRecorder.Visible = false
    startRecording()
end)

recPosButton.MouseButton1Down:Connect(function()
    recordPosition()
end)

recSellPosButton.MouseButton1Down:Connect(function()
    recordSellPosition()
end)

	-- Config tab
mineconfig.MouseButton1Down:Connect(function()
    tabCycle(configTab)
end)
	-- Webhooks tab
webhook.MouseButton1Down:Connect(function()
    tabCycle(webhooksTab)
end)
	-- Automine tab
automine.MouseButton1Down:Connect(function()
    tabCycle(automineTab)
end)

-- OverviewPanel exit button
overviewExit.MouseButton1Down:Connect(function()
    Templar:Destroy()
end)

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
        tweeninfo = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
        if visible == true then
            for _,button in pairs(buttonsDeleted) do
                if button:IsA("TextLabel") then 
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 1})
                    tween:Play()
                elseif not table.find(tweenExemption, button.Name) then
                    tween = tweenservice:Create(button,tweeninfo,{Transparency = 1})
                    tween:Play()
                    print(button)
                else
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 1})
                    tween:Play()
                end
                task.spawn(function()
                wait(1)
                print(button)
                button.Visible = false
                end)
            end
        else
            for _,button in pairs(buttonsDeleted) do
                if button:IsA("TextLabel") then 
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 0})
                elseif button:IsA("TextButton") and not table.find(exemption, button.Name) then
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 0})
                    print(button, "yo")
                else
                    tween = tweenservice:Create(button,tweeninfo,{Transparency = 0})
                    print(button)
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
    if isPathRecOn == true then
        startRecording()
    end
end)

-- Autofarm button.
startAutoFarm.MouseButton1Down:Connect(function()
    if isAFRunning == false then
        isAFRunning = true
        startAutoFarm.BackgroundColor3 = Color3.fromRGB(0,75,0)
        nearestOreFarm()
    else
        warn("Autofarm already running. To turn off the autofarm, please leave the game.")
    end
end)

buttonHover()

end

if isTweenFinished == true then
    applyButtonFunctionality()
else 
    while isTweenFinished == false do
        wait(0.1)
    end
    applyButtonFunctionality()
end
