if not game:IsLoaded() then
    game.Loaded:Wait()
end

local loadingGate = game.Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingGate")

if loadingGate then
    while loadingGate.Enabled do
        wait()
    end
end

player = game.Players.LocalPlayer
plrgui = player:WaitForChild("PlayerGui")
plrname = player.Name

local successes = {}

if plrgui:FindFirstChild("Templar") then
	return
else

local settingsText = [[
BasicPickaxe
-- File name
isAutoFarmRunning = false
pathFileRunning = nil
firstStartUp = true
-- Webhook URL
webhookEnabled = false
]]

local files = {
		{path = "TWW_Templar", type = "folder"},
		{path = "TWW_Templar/settings.cfg", type = "file", contents = settingsText}
	}

if not game.Workspace:FindFirstChild("Path") then
	folder = Instance.new("Folder")
	folder.Parent = game.Workspace
	folder.Name = "Path"
end

local function newFolder(path)
	if not
		pcall(function()
			makefolder(path)
			print("Path folder created at: " .. path)
			return true -- successes[6]
		end) 
	then
		print("Function makefolder not supported.")
		return false -- successes[6]
	end
end

local function newFile(path)
	if not
		pcall(function()
			writefile(path, settingsText)
			print("Settings config created at: " .. path)
			return true -- successes[3] and successes[2]
		end)
	then
		return false -- successes[3] and successes[2]	
	end
end

local function createFile(file)
	if file.type == "folder" then
		newFolder(file.path)
	elseif file.type == "file" then
		newFile(file.path)
	end
end

local function initialiseComponents()
	for _, item in ipairs(files) do
		createFile(item)
	end
end

initialiseComponents()

sortedOreIndex = {}

local success, errorMessage = pcall(function()
    local fileContent = readfile("TWW_Templar/settings.cfg")
    lines = {}
    for line in fileContent:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    firstStartUp = lines[5]:match("=%s*(.+)")
    webhookEnabled = lines[7]:match("=%s*(.+)")
    webhookURL = lines[6]

end)

if success then
    successes[4] = true
	local settingsLines = string.split(settingsText, "\n")
	for i = 1, #lines do
		if lines[i] == nil then
    		lines[i] = settingsLines[i]
    		writefile(settingsCfg, table.concat(lines, "\n"))
		end
	end
else
    successes[4] = false
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

local ok,d=pcall(game:GetService("HttpService").JSONDecode,game:GetService("HttpService"),'{"a":1,"b":2,"c":[3,4,5]}')
if ok then successes[7] = true else successes[7] = false end

local smallestServer = nil
local smallestPlayers = math.huge
local Next = nil
local allServers = {}

function tp()
    
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
        local success, errorMsg = pcall(function()
            local randomServer = allServers[math.random(1, #allServers)]
        end)
        if errorMsg then
            endLoop = false
            while not endLoop do
                wait(5)
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
                    local success, errorMsg = pcall(function()
                        local randomServer = allServers[math.random(1, #allServers)]
                    end)
                end
                if success then break end
            end
        end
        warn("Could not find lowest player server. Joining random server...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, game.Players.LocalPlayer)
        endLoop = true
    end
end

attributeSet = game.Workspace:FindFirstChild("attributeSet")

if not attributeSet then
    attributeSet = Instance.new("BoolValue")
    attributeSet.Parent = game.Workspace
    attributeSet.Name = "attributeSet"
    attributeSet = game.Workspace:WaitForChild("attributeSet")
end

function generateUniqueID(ore)
    if not ore or not ore:IsA("Model") then return nil end
    local primary = ore.PrimaryPart or ore:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil end
    local pos = primary.Position
    local x, y, z = math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
    local id = string.format("%s_%d_%d_%d", ore.Parent.Name, x, y, z)
    if not ore:GetAttribute("UniqueOreID") then
        ore:SetAttribute("UniqueOreID", id)
    end
    return id
end

function setAttributes(forced)
    if forced or attributeSet.Value == false then
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
end

exemption = {"startAutoFarm", "settingsFrame", "pathedAutoFarm", "pathSelector", "pathrecButton", "executorBenchmark", "webhookSelector", "webhookTXTLabel", "webhookActive"}
fullExemption = {"automineTab", "webhooksTab", "configTab", "notifFrame"}
tweenExemption = {"automine", "webhook", "mineconfig"}
txtLabelExemption = {"webhookTXTLabel"}

taskbarButtons = {}

pickaxeSelected = lines[1]
pickaxeTiers = {"BasicPickaxe", "Tier1Pickaxe", "Tier2Pickaxe", "Tier3Pickaxe", "Tier4Pickaxe", "Tier5Pickaxe", "Tier6Pickaxe", "Tier7Pickaxe", "Tier8Pickaxe","Tier9Pickaxe"}

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
Templar.DisplayOrder = 999

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
        multiplier = 0
    else
        multiplier = difference / 21
        text = pickaxeTiers[multiplier + 1]
    end
    pickaxeSelected = pickaxeTiers[multiplier + 1]
    lines[1] = pickaxeTiers[multiplier + 1]
    writefile(settingsCfg, table.concat(lines, "\n"))
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
pathSelector.Text = lines[2]
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
pathSelector.ClipsDescendants = true

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

loadingScreen = Instance.new("Frame")
loadingScreen.Parent = Templar
loadingScreen.BackgroundColor3 = Color3.fromRGB(0,0,0)
loadingScreen.Size = UDim2.new(0,800,0,600)
loadingScreen.Position = UDim2.new(0.5, -400, 0.5, -300)
loadingScreen.ZIndex = 1
loadingScreen.Name = "loadingScreen"
loadingScreen.BackgroundTransparency = 0.3

local loadingScreenUICorner = Instance.new("UICorner")
loadingScreenUICorner.Parent = loadingScreen

printToLabel = Instance.new("TextLabel")
printToLabel.Parent = loadingScreen
printToLabel.TextColor3 = Color3.fromRGB(255,255,255)
printToLabel.RichText = true
printToLabel.TextSize = 14
printToLabel.TextWrapped = true
printToLabel.Size = UDim2.new(0, 775, 0, 466)
printToLabel.Position = UDim2.new(0, 15, 0.025, 0.18)
printToLabel.BackgroundTransparency = 1
printToLabel.Text = ""
printToLabel.TextXAlignment = "Left"
printToLabel.TextYAlignment = "Top"

lsExit = Instance.new("TextButton")
lsExit.Parent = loadingScreen
lsExit.Text = "X"
lsExit.Size = UDim2.new(0, 30, 0, 30)
lsExit.BackgroundColor3 = Color3.fromRGB(30,30,30)
lsExit.Font = Enum.Font.SourceSansBold
lsExit.Position = UDim2.new(1, -40, 0, 5)
lsExit.TextSize = 20
lsExit.TextColor3 = Color3.fromRGB(255,255,255)
lsExit.Name = "lsExit"
lsExit.BackgroundTransparency = 1

local lsExitCorner = Instance.new("UICorner")
lsExitCorner.Parent = lsExit

local lsDragDetect = Instance.new("UIDragDetector")
lsDragDetect.Parent = loadingScreen

executorBenchmark = Instance.new("TextButton")
executorBenchmark.Parent = settingsFrame
executorBenchmark.Text = "Test Executor Compatability"
executorBenchmark.Size = UDim2.new(0, 300, 0, 50)
executorBenchmark.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
executorBenchmark.TextSize = 20
executorBenchmark.TextColor3 = Color3.fromRGB(255,255,255)
executorBenchmark.Font = Enum.Font.SourceSansBold
executorBenchmark.Transparency = 1
executorBenchmark.Position = UDim2.new(0.5, -350, 0, 140)
executorBenchmark.Name = "executorBenchmark"

local executorBenchmarkCorner = Instance.new("UICorner")
executorBenchmarkCorner.Parent = executorBenchmark

notifFrame = Instance.new("Frame")
notifFrame.Name = "notifFrame"
notifFrame.Parent = Templar
notifFrame.AnchorPoint = Vector2.new(1, 1)
notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
notifFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
notifFrame.Position = UDim2.new(1, 0, 2, 0)
notifFrame.Size = UDim2.new(0, 169, 0, 90)

notifDescription = Instance.new("TextLabel")
notifDescription.Name = "notifDescription"
notifDescription.Parent = notifFrame
notifDescription.AnchorPoint = Vector2.new(1, 1)
notifDescription.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
notifDescription.Position = UDim2.new(1,0,1,0)
notifDescription.Size = UDim2.new(0, 169, 0, 64)
notifDescription.ZIndex = 1
notifDescription.Font = Enum.Font.GothamBold
notifDescription.Text = ""
notifDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
notifDescription.TextSize = 14.000
notifDescription.TextXAlignment = Enum.TextXAlignment.Left
notifDescription.TextYAlignment = Enum.TextYAlignment.Top
notifDescription.TextWrapped = true

notifTitle = Instance.new("TextLabel")
notifTitle.Name = "notifTitle"
notifTitle.Parent = notifFrame
notifTitle.AnchorPoint = Vector2.new(1, 1)
notifTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
notifTitle.Position = UDim2.new(1,0,0.25,0)
notifTitle.Size = UDim2.new(0, 169, 0, 26)
notifTitle.ZIndex = 1
notifTitle.Font = Enum.Font.GothamBold
notifTitle.Text = ""
notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
notifTitle.TextSize = 14.000
notifTitle.TextXAlignment = Enum.TextXAlignment.Left
notifTitle.TextYAlignment = Enum.TextYAlignment.Top
notifTitle.TextWrapped = true

notifFrameCorner = Instance.new("UICorner")
notifFrameCorner.Parent = notifFrame

notifDescriptionCorner = Instance.new("UICorner")
notifDescriptionCorner.Parent = notifDescription

notifTitleCorner = Instance.new("UICorner")
notifTitleCorner.Parent = notifTitle

webhookSelector = Instance.new("TextBox")
webhookSelector.Text = lines[6]
webhookSelector.Parent = webhooksTab
webhookSelector.Size = UDim2.new(0, 250, 0, 40)
webhookSelector.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
webhookSelector.BorderSizePixel = 1
webhookSelector.BorderColor3 = Color3.fromRGB(unpack(colourTheme))
webhookSelector.TextSize = 20
webhookSelector.TextColor3 = Color3.fromRGB(255,255,255)
webhookSelector.Font = Enum.Font.SourceSansBold
webhookSelector.Transparency = 1
webhookSelector.Position = UDim2.new(0.5, -350, 0, 140)
webhookSelector.Name = "webhookSelector"
webhookSelector.ClipsDescendants = true

webhookTXTLabel = Instance.new("TextLabel")
webhookTXTLabel.Parent = webhooksTab
webhookTXTLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
webhookTXTLabel.Text = "Enable Webhooks:"
webhookTXTLabel.Size = UDim2.new(0, 200, 0, 30)
webhookTXTLabel.Position = UDim2.new(0.5, -340, 0, 200)
webhookTXTLabel.Name = "webhookTXTLabel"
webhookTXTLabel.TextColor3 = Color3.fromRGB(255,255,255)
webhookTXTLabel.TextSize = 14
webhookTXTLabel.Font = "GothamBold"

local webhookLabelCorner = Instance.new("UICorner")
webhookLabelCorner.Parent = webhookTXTLabel

webhookActive = Instance.new("TextButton")
webhookActive.Parent = webhooksTab
webhookActive.BackgroundColor3 = Color3.fromRGB(30,30,30)
webhookActive.TextColor3 = Color3.fromRGB(0,150,0)
webhookActive.Size = UDim2.new(0,30,0,30)
webhookActive.Position = UDim2.new(0.5, -130, 0, 200)
if webhookEnabled == "true" then webhookActive.Text = "X" else webhookActive.Text = "" end
webhookActive.Font = "Gotham"
webhookActive.TextSize = 25
webhookActive.Name = "webhookActive"

webhookActiveUICorner = Instance.new("UICorner")
webhookActiveUICorner.Parent = webhookActive

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
        end
            return fullPath
        end
    end
end

local txtSuccess = {
	"Global module required successfully.",
	"Settings.cfg file successfully created.",
	"Method writefile is active.",
	"Method readfile is active.",
	"Method getrawmetatable is active.",
	"Method makefolder is active.",
	"Method request is active."
}
local txtFail = {
	"Global module required unsuccessfully.",
	"Settings.cfg file creation unsuccessful.",
	"Method writefile is not active.",
	"Method readfile is not active.",
	"Method getrawmetatable is not active.",
	"Method makefolder is not active.",
	"Method request is not active."
}

local errorMsgs = {
	"Your executor does not support the setthreadidentity method. This is script breaking, a level 8 executor is recommended.",
	"ignore",
	"Your executor does not support the writefile method. You will have to manually create files for the script to work.",
	"Your executor does not support the readfile method. This is script breaking, a level 8 executor is recommended for complete functionality.",
	"Your executor does not support the getrawmetatable method. The script will work, however will use clicks instead of calling the swing function directly.",
	"Your executor does not support the makefolder method. This script will work, however you will have to manually create the TWW_Templar folder.",
	"Your executor does not support the request method. The script will (kind of) work, however it will not server hop."
}

loadInitiated = false

isLoading = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local success, errorMessage = pcall(function()
    Global = require(ReplicatedStorage.SharedModules.Global)
end)

if success then
    print("Global module required successfully.")
    successes[1] = true
else
    warn("Your executor does not support the require function, the autofarm will not work without the setthreadidentity method. A level 8 executor is recommended for complete functionality.")
    successes[1] = false
end

local canGetMeta = false

local testMetatable = { __test = true }
local testObject = setmetatable({}, testMetatable)
local success, returnedMetatable = pcall(getrawmetatable, testObject)

if success then
    canGetMeta = true
    successes[5] = true
else 
    successes[5] = false
end

function initiateLoading()
    isLoading = true
    local RunService = game:GetService("RunService")

    local line = 1
    local char = 1
    local interval = 0.01
    local acc = 0

    local randomChars = {}
    for i = 33, 126 do
	    local char = string.char(i)
	    if char ~= "<" and char ~= ">" and char ~= "&" and char ~= '"' and char ~= "'" then
		    table.insert(randomChars, char)
	    end
    end

    local function getRandomChar()
	    return randomChars[math.random(1, #randomChars)]
    end

    local completedLines = ""

    local successesValue = 0

    for _,v in successes do
	    if v then
		    successesValue = successesValue + 1
	    end
    end

    local connection

    connection = RunService.Heartbeat:Connect(function(dt)
	    acc = acc + dt
	    if acc < interval then return end
	    acc = acc - interval

	    if line > #txtSuccess then 
		    local text = ""

		    if not successes[1] or not successes[4] then
			    text = "EXECUTOR LEVEL TOO LOW."
            else
                text = "EXECUTOR LEVEL IS OPTIMAL"
		    end

		    printToLabel.Text = printToLabel.Text .. "\n" .. "Summary: " .. successesValue .. "/" .. #txtSuccess .. " tests passed. " .. text
		    for i,v in errorMsgs do
			    if not successes[i] and i ~= 2 then
				    printToLabel.Text = printToLabel.Text .. "\n\n" .. v
			    end
		    end
            isLoading = false
		    connection:Disconnect()
		    return
	    end

	local currentText = (successes[line] and txtSuccess[line] or txtFail[line])
	local color = successes[line] and "0,255,0" or "255,0,0"

	if char > #currentText then
		completedLines = completedLines .. string.format('<font color="rgb(%s)">%s</font>\n', color, currentText)
		printToLabel.Text = completedLines
		line = line + 1
		char = 1
		return
	end

	local confirmed = currentText:sub(1, char - 1)
	local nextChar = currentText:sub(char, char)
	local randomChar = (char < #currentText) and getRandomChar() or ""
	local displayChar = (randomChar ~= "" and randomChar or nextChar)

	printToLabel.Text = completedLines .. string.format('<font color="rgb(%s)">%s%s</font>', color, confirmed, displayChar)

	char = char + 1
    end)
end

if firstStartUp == "true" or nil then
    initiateLoading()
else
    loadingScreen.Visible = false
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

function guiTween()
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
end

lsExit.MouseEnter:Connect(function()
    lsExit.BackgroundTransparency = 0
end)

lsExit.MouseLeave:Connect(function()
    lsExit.BackgroundTransparency = 1
end)

lsExit.MouseButton1Down:Connect(function()
    loadInitiated = true 
    loadingScreen.Visible = false
    isLoading = false
    draggable.Visible = true
end)

if firstStartUp == "true" then
    task.spawn(function()
        repeat task.wait() until loadInitiated == true
        lines[5] = "firstStartUp = false"
        writefile(settingsCfg, table.concat(lines, "\n"))
        guiTween()
    end)
else
    guiTween()
end

local pathfindingservice = game:GetService("PathfindingService")

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

-- deprecated
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

local function calculatePaths() -- deprecated
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

function FindNearestOre() -- deprecated
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

local function pathCalculator() -- deprecated
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

local bodyVelocity = nil
local bodyGyro = nil
isRagdollFlying = false

isRagdollEnabled = false

function enableRagdollFly()
    isRagdollEnabled = true
    if isRagdollFlying then return end

    Global.PlayerCharacter:Ragdoll(nil, true)
    task.wait(0.25)
    
    character = wrkspceEnt.Players[plrname]
    hrp = character.HumanoidRootPart

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

    local undergroundPos = hrp.Position - Vector3.new(0, 3, 0)
    hrp.CFrame = CFrame.new(undergroundPos)

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

function pathfind(index) -- deprecated
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


local virtualinputmanager = game:GetService("VirtualInputManager")

finishedKeypress = false

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
        finishedKeypress = true
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

local function nearestOreFarm() -- deprecated
        local slot = plrgui.Hotbar.Container.HotbarList.Body
        local slotItem = slot.HotbarSlot_Utility_1.Container.Slot.ViewportFrame:GetChildren()[1].Name
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

buttonsDeleted = {startAutoFarm,sliderFrame,sliderText,slider,separationFrame,automine,webhook,mineconfig,pathedAutoFarm,pathSelector,pathrecButton,webhookSelector,webhookTXTLabel,webhookActive}

local UserInputService = game:GetService("UserInputService")

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {character} -- ignore the player

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
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if input.UserInputState ~= Enum.UserInputState.Begin then return end

    local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if not result then return end

    local part = result.Instance
    if part.Parent and part.Parent:IsA("Model") and string.find(part.Name, "Rock") then
        oreType = part.Parent.Parent
        orePart = part.Parent.PrimaryPart
        oreID = part.Parent:GetAttribute("UniqueOreID")
        if not oreID then
            setAttributes(true)
        end
        recordMine()
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
    hrp = wrkspceEnt.Players[plrname].HumanoidRootPart
    local pos = hrp.Position
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

UISConnection = nil

local function startRecording()
    UISConnection = UserInputService.InputBegan:Connect(onClick)
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
    input("pressbutton", Enum.KeyCode.F, 0.5, 3)
end

local function oreScan()
    for i,v in pairs(wrkspceInt.DroppedItems:GetChildren()) do
        if string.find(v.Name, "Ore") then
            return true
        end
    end
end

local function pathMine(ore)
    pd = require(game.ReplicatedStorage.Modules.System.PlayerData)
    currentItems = #pd.InventoryContainer.Items
    if ore.DepositInfo.OreRemaining.Value == 0 or currentItems == 30 then return end
    hrp = wrkspceEnt.Players[plrname].HumanoidRootPart
    disableRagdollFly()
    wait(0.1)
    input("pressbutton", Enum.KeyCode.Four, 1, 1)
    local playerChar = require(game:GetService("ReplicatedStorage").Modules.Character.PlayerCharacter)
    local equippeditem = playerChar:GetEquippedItem()
    local pickaxeItem = playerChar:GetItem(pickaxeSelected)
    wait(0.25)
    pickaxeItem.CameraFreeLook = true
    local orePos = ore.PrimaryPart.Position
    task.spawn(function()
        while ore.DepositInfo.OreRemaining.Value > 0 and #pd.InventoryContainer.Items < 30 do
            wait(0.1)
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(orePos.X, hrp.Position.Y, orePos.Z))
                pickaxeItem:Swing()
        end
    end)
    while ore.DepositInfo.OreRemaining.Value > 0 and #pd.InventoryContainer.Items < 30 do
        input("pressbutton", Enum.KeyCode.E, 1, 1)
        wait(1)
    end
    getOre = oreScan()
    if getOre then
        input("pressbutton", Enum.KeyCode.E, 1, 1)
        wait(1)
    end
    input("pressbutton", Enum.KeyCode.Four, 1, 1)
end

local function oreSearch(oreName, oreID)
    local ores = workspace.WORKSPACE_Interactables.Mining.OreDeposits[oreName]:GetChildren()
    oreFetched = false

    for _,ore in pairs(ores) do
        if ore:GetAttribute("UniqueOreID") == oreID then
            print(id)
            targetOre = ore
            oreFetched = true
            break
        end
    end

    return oreFetched, targetOre
end

local function mineOre(oreName, oreID)
    oreFetched, targetOre = oreSearch(oreName, oreID)

    if oreFetched then
        print("i did indeed fetch")
        pathMine(targetOre)
    else
        setAttributes(true)
        oreFetched, targetOre = oreSearch(oreName, oreID)
        pathMine(targetOre)
    end
end

local spawnLookup = {}
for _, spawn in ipairs(recordSpawns) do
    spawnLookup[spawn.string] = true
end

local notifActive = false

local function callNotif(title, extra, description)
    notifActive = false
    local time = 0.5

    local tweeninfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
    local tweenservice = game:GetService("TweenService")

    local tweenIn = game:GetService("TweenService"):Create(notifFrame, tweeninfo, {Position = UDim2.new(1,0,1,0)})
    tweenIn:Play()

    notifTitle.Text = title .. extra
    notifDescription.Text = description

    task.wait(3.5)
	
    local tweenOut = tweenservice:Create(notifFrame, tweeninfo, {Position = UDim2.new(1, 0, 2, 0)})
    tweenOut:Play()
    task.wait(0.5)
    notifActive = false
    notifTitle.Text = ""
    notifDescription.Text = ""
end

local HttpService = game:GetService("HttpService")
local req = request or http_request or syn.request

local function callWebhook(title, extra, description, infoTitle, info, extra2)
    local HttpService = game:GetService("HttpService")

    local webhookUrl = lines[6]

local fields = {
    {
        name = "Time",
        value = os.date("%Y-%m-%d %H:%M:%S"),
        inline = true
    }
}

if infoTitle ~= nil then
        table.insert(fields, {
        name = infoTitle,
        value = info,
        inline = true
    })
end

    local data = {
	    embeds = {
	    	{
			    title = title,
			    description = description,
			    color = 0x00FF00, -- green
	    		fields = fields,
	    		},
			    footer = {
				    text = "TWW_Templar"
			    }
	        }
	    }

req({
    Url = webhookUrl,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode(data)
})

end

local function preProcessor(lines)
	local isFirst = true
    local lastWaypointPos = nil
    local trackMoves = 0
	for i, line in ipairs(lines) do
		line = line:match("^%s*(.-)%s*$")
		local action, x, y, z = line:match("^(%w+),%s*([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
		
		if action and not isFirst then
			local position = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
            print(position)
			if action == "move" then
                trackMoves = trackMoves + 1
                local a = lastWaypointPos
                local b = position
                local dir = b - a
                local dist = dir.Magnitude
                local mid = (a + b) / 2
                local thickness = 0.4

                local checkpoint = Instance.new("Part")
                checkpoint.Material = "Neon"
                checkpoint.Anchored = true
                checkpoint.CanCollide = false
                checkpoint.Shape = "Ball"
                checkpoint.Position = position
                checkpoint.Parent = game.Workspace:WaitForChild("Path")
                checkpoint.Name = "part".. trackMoves
                checkpoint.Size = Vector3.new(3, 1, 1)

                local connection = Instance.new("Part")
                connection.Shape = "Cylinder"
                connection.Material = "Neon"
                connection.Anchored = true
                connection.CanCollide = false
                connection.Parent = game.Workspace:WaitForChild("Path")
                connection.Size = Vector3.new(dist, thickness, thickness)
                connection.CFrame = CFrame.new(mid, b) * CFrame.Angles(math.rad(90), 0, 0)
                connection.Name = "Connection" .. trackMoves
                connection.Color = Color3.fromRGB(213, 115, 61)
                local up = Vector3.new(0,1,0)
                local rotation = CFrame.fromMatrix(mid, dir.Unit, up:Cross(dir.Unit), dir.Unit:Cross(up:Cross(dir.Unit)))
                connection.CFrame = rotation
				
                lastWaypointPos = position
			end
		elseif action and isFirst then
            trackMoves = trackMoves + 1
			local position = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
			isFirst = false
			lastWaypointPos = position
            local checkpoint = Instance.new("Part")
            checkpoint.Material = "Neon"
            checkpoint.Anchored = true
            checkpoint.CanCollide = false
            checkpoint.Shape = "Ball"
            checkpoint.Position = position
            checkpoint.Parent = game.Workspace:WaitForChild("Path")
            checkpoint.Name = "part".. trackMoves
            checkpoint.Size = Vector3.new(3, 1, 1)
		end
	end
    return trackMoves
end

local function parsePath(lines)
    setAttributes()
    task.spawn(function()
        pd = require(game.ReplicatedStorage.Modules.System.PlayerData)
        currentMoney = pd.Data.Bucks
    end)
	local totalCheckpoints = preProcessor(lines)
    moneyEarnt = 0
    first = true
    pathCompleted = false
	lastCheckpoint = nil
	checkpointIndex = 0
    for i, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$")

        local action, x, y, z = line:match("^(%w+),%s*([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
        if action then
            local position = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
            if action == "sell" then
                pcall(function() sell() end)
				callNotif("Selling...", "", line)
                if webhookEnabled == "true" then pcall(function() callWebhook("Selling...", "", "Selling loot - About to server hop.", "", nil, nil) end) end
            elseif action == "move" then
                if checkpointIndex >= totalCheckpoints then
                    break
                end
				checkpointIndex = checkpointIndex + 1
                if first then
				    lastCheckpoint = game.Workspace.Path:FindFirstChild("part" .. checkpointIndex)
                    lastCheckpoint.Color = Color3.fromRGB(13, 105, 172)
                elseif checkpointIndex ~= trackMoves then
                    lastCheckpoint.Color = Color3.fromRGB(100,100,100)
				    lastCheckpoint = game.Workspace.Path:FindFirstChild("part" .. checkpointIndex)
                    game.Workspace.Path:FindFirstChild("part" .. checkpointIndex).Color = Color3.fromRGB(13, 105, 172)                 
                end
                wrkspceEnt.Players:WaitForChild(plrname)
                pcall(function()
                    if first == true or isRagdollEnabled == false then enableRagdollFly() Global.PlayerCharacter:Ragdoll(nil, true) end
                    if first == true or isRagdollEnabled == false then repeat wait() until isRagdollFlying == true end
                end)
                    moveComplete = false
                    ragdollMoveTo(position + Vector3.new(0,5,0))
                    repeat task.wait() until moveComplete == true
    				lastCheckpoint.Color = Color3.fromRGB(0,150,0)
                    first = false
            else
                warn("Unknown action with coordinates:", line)
            end

        else
            local oreName, oreID = line:match("^mine,%s*([^,]+)%s*,%s*([^,]+)%s*$")
            if oreName and oreID then
                print(oreName)
                print(oreID)
				lastCheckpoint.Color = Color3.fromRGB(0,150,0)
                pcall(function() mineOre(oreName, oreID) end)
            elseif spawnLookup[line] then
                pcall(function() automineSpawn(line) end)
                callNotif("Spawning at ", line, line)
                if webhookEnabled == "true" then 
                    print("Spawned")
                    pcall(function()
                        callWebhook(
                        "Spawning at " .. line,
                        "Beginning path at " .. line,
                        line
                    )
                    end)
                end
            else
                warn("Unknown line:", line)
				callNotif("Unknown line.", "", line)
            end
        end
    end
    local success, errorMsg = pcall(function()
        money = pd.Data.Bucks
        moneyEarnt = money - currentMoney
    end)
    if errorMsg then
        moneyEarnt = "ERROR: moneyEarnt is nil."
    end
    pathCompleted = true
end

local promptOverlay = game.CoreGui.RobloxPromptGui.promptOverlay

local function updateSettings()
    local line = lines[3]
    if line then
        local value = line:match("=%s*(.+)%s*$")
        if value == "true" then
            isAutoFarmRunning = true
        elseif value == "false" then
            isAutoFarmRunning = false
        elseif value == "nil" then
            isAutoFarmRunning = nil
        end
    end

    line = lines[4]
    if line then
        local value = line:match("=%s*(.+)%s*$")
        if value == "nil" then
            pathFileRunning = nil
        else
            pathFileRunning = value
        end
    end
end

local function pathAutomine(customCall)
    updateSettings()
    if isAutoFarmRunning or customCall == true then
        promptOverlay.ChildAdded:Connect(function()
            tp()
        end)
        lineFormatter()

        task.spawn(function()
            parsePath(parseLines)
        end)

        repeat
            task.wait()
            local pc = require(game.ReplicatedStorage.Modules.Character.PlayerCharacter)
            if pc.IsDead then
				callNotif("Server hopping...", "", "Reason: Player death.")
				if webhookEnabled == "true" then
					pcall(function()
						callWebhook("Server hopping...", "", "Reason: Player death.", "", "", "") 
					end) 
				end 
				tp()
                elseif pc.CanBreakFree{} then
                callNotif("Server hopping...", "", "Reason: Player lassoed.")
				if webhookEnabled == "true" then
					pcall(function()
						callWebhook("Server hopping...", "", "Reason: Player lassoed.", "", "", "") 
					end) 
				end
                tp()
			end
        until pathCompleted == true and finishedKeypress == true
        wait(1)
        updateSettings()
        if isAutoFarmRunning then
			callNotif("Server hopping...", "", "Reason: End of path.") 
			if webhookEnabled == "true" then 
				pcall(function()
					callWebhook(
                    "Server hopping...",
                    "",
                    "Reason: End of path.",
                    "Money earnt (from path)",
                    "$" .. moneyEarnt
                    )
				end) 
			end 
			tp()
		end
    end
end

local function intervalRecord() -- unused, theoretical update.
    abortRecord = false
    interval = 0.1
    
    task.spawn(function()
        while abortRecord == false do
            recordPosition()
            wait(interval)
        end
    end)
end

task.spawn(function()
    pathAutomine()
end)

if isAutoFarmRunning then
    pathedAutoFarm.BackgroundColor3 = Color3.fromRGB(0,75,0)
end

local function applyButtonFunctionality()

webhookActive.MouseButton1Down:Connect(function()
    if webhookEnabled == "true" then
        lines[7] = "webhookEnabled = false"
        writefile(settingsCfg, table.concat(lines, "\n"))
        webhookActive.Text = ""
        webhookEnabled = "false"
    else
        lines[7] = "webhookEnabled = true"
        writefile(settingsCfg, table.concat(lines, "\n"))
        webhookActive.Text = "X"
        webhookEnabled = "true"
    end
end)

executorBenchmark.MouseButton1Down:Connect(function()
    printToLabel.Text = ""
    loadInititated = false
    if isLoading == false then
        draggable.Visible = false
        loadingScreen.Visible = true
        initiateLoading()
    end
end)
pathedAutoFarm.MouseButton1Down:Connect(function()

    lines[6] = webhookSelector.Text
    writefile(settingsCfg, table.concat(lines, "\n"))

    lines[2] = pathSelector.Text
    writefile(settingsCfg, table.concat(lines, "\n"))

    local currentContent = readfile(settingsCfg)
    local currentState = currentContent:match("isAutoFarmRunning%s*=%s*(%a+)")

    if currentState == "false" or currentState == "nil" then
        pcall(function() callWebhook("Starting Path...", "", "Path started: " .. pathSelector.Text, "", "", "") end)
        pathedAutoFarm.BackgroundColor3 = Color3.fromRGB(0,75,0)

        lines[3] = "isAutoFarmRunning = true"
        writefile(settingsCfg, table.concat(lines, "\n"))

        task.spawn(function()
            pathAutomine(true)
        end)
    else
        pathedAutoFarm.BackgroundColor3 = Color3.fromRGB(25,25,25)
        print("Autofarm stopped. Finishing last path.")
        
        lines[3] = "isAutoFarmRunning = false"
        writefile(settingsCfg, table.concat(lines, "\n"))
    end
end)

for _,table in pairs(recordSpawns) do
    table.button.MouseButton1Click:Connect(function()
        recordSpawn(table.string)
    end)
end

pathrecButton.MouseButton1Down:Connect(function()
    setAttributes()
    local pathBool = pathRecorder.Visible
    isPathRecOn = false
    
    if not pathBool then
        createTXTFile()
        startRecording()
        pathRecorder.Visible = true
        isPathRecOn = true
    else
        UISConnection:Disconnect()
        pathRecorder.Visible = false
        isPathRecOn = false
    end
end)

recExit.MouseButton1Down:Connect(function()
    pathRecorder.Visible = false
    UISConnection:Disconnect()
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
    lines[2] = pathSelector.Text
    writefile(settingsCfg, table.concat(lines, "\n"))
    Templar:Destroy()
    UISConnection:Disconnect()
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
                if button:IsA("TextLabel") and not table.find(txtLabelExemption, button.Name) then
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 1})
                    tween:Play()
                elseif not table.find(tweenExemption, button.Name) then
                    tween = tweenservice:Create(button,tweeninfo,{Transparency = 1})
                    tween:Play()
                else
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 1})
                    tween:Play()
                end
                task.spawn(function()
                    wait(1)
                    button.Visible = false
                end)
            end
        else
            for _,button in pairs(buttonsDeleted) do
                if button:IsA("TextLabel") and not table.find(txtLabelExemption, button.Name) then 
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 0})
                elseif button:IsA("TextButton") and not table.find(exemption, button.Name) then
                    tween = tweenservice:Create(button,tweeninfo,{TextTransparency = 0})
                else
                    tween = tweenservice:Create(button,tweeninfo,{Transparency = 0})
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
    lines[2] = pathSelector.Text
    writefile(settingsCfg, table.concat(lines, "\n"))
    lines[6] = webhookSelector.Text
    writefile(settingsCfg, table.concat(lines, "\n"))
    if isPathRecOn == true then
        UISConnection:Disconnect()
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
