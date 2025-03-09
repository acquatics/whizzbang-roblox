local DiscordLib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt")()

local win = DiscordLib:Window("whizzbang")
local serv = win:Server("Main", "")
local tgls = serv:Channel("Toggles")


local npcConnections = {}
local npcHighlights = {}
local crosshairGui = nil
local crosshairConnection = nil
local woundedConnections = {}
local woundedGui = nil
local woundedHighlights = {}

tgls:Toggle("Highlight NPCs", false, function(bool)
    if bool then
        local aiModelsToHighlight = {
            "ai_arsonist", "ai_bombardier", "ai_medic", "ai_officer",
            "ai_raider", "ai_rat", "ai_rifleman", "ai_sniper",
            "ai_stormtrooper", "ai_tank"
        }

        local function createHighlight(model)
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 165, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = model
            table.insert(npcHighlights, highlight)
        end

        local workspace = game:GetService("Workspace")
        
        for _, modelName in ipairs(aiModelsToHighlight) do
            local connection = workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") and descendant.Name == modelName then
                    createHighlight(descendant)
                end
            end)
            table.insert(npcConnections, connection)
            
            for _, model in ipairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model.Name == modelName then
                    createHighlight(model)
                end
            end
        end
    else
        
        for _, connection in pairs(npcConnections) do
            connection:Disconnect()
        end
        for _, highlight in pairs(npcHighlights) do
            highlight:Destroy()
        end
        table.clear(npcConnections)
        table.clear(npcHighlights)
    end
end)

tgls:Toggle("Gun Crosshair", false, function(bool)
    if bool then
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")

        crosshairGui = Instance.new("ScreenGui")
        crosshairGui.Name = "CustomCrosshair"
        crosshairGui.ResetOnSpawn = false
        crosshairGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        local function createCrosshairPart(size, position)
            local part = Instance.new("Frame")
            part.Size = size
            part.Position = position
            part.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            part.BorderSizePixel = 0
            part.Parent = crosshairGui
            return part
        end

        local vertical = createCrosshairPart(UDim2.new(0, 2, 0, 12), UDim2.new(0, 0, 0, 0))
        local horizontal = createCrosshairPart(UDim2.new(0, 12, 0, 2), UDim2.new(0, 0, 0, 0))

        local yOffset = 59
        local xOffset = 1

        crosshairConnection = RunService.RenderStepped:Connect(function()
            local mouseLocation = UserInputService:GetMouseLocation()
            vertical.Position = UDim2.new(0, mouseLocation.X - 1 - xOffset, 0, mouseLocation.Y - 6 - yOffset)
            horizontal.Position = UDim2.new(0, mouseLocation.X - 6 - xOffset, 0, mouseLocation.Y - 1 - yOffset)
        end)
    else
        
        if crosshairConnection then
            crosshairConnection:Disconnect()
            crosshairConnection = nil
        end
        if crosshairGui then
            crosshairGui:Destroy()
            crosshairGui = nil
        end
    end
end)

tgls:Toggle("Wounded ESP", false, function(bool)
    if bool then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        woundedGui = Instance.new("ScreenGui")
        woundedGui.Name = "HealthHighlightGui"
        woundedGui.ResetOnSpawn = false
        woundedGui.Parent = player.PlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 150, 0, 50)
        frame.Position = UDim2.new(1, -170, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 2
        frame.Active = true
        frame.Draggable = true
        frame.Parent = woundedGui

        local refreshButton = Instance.new("TextButton")
        refreshButton.Size = UDim2.new(0.8, 0, 0.6, 0)
        refreshButton.Position = UDim2.new(0.1, 0, 0.2, 0)
        refreshButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        refreshButton.Text = "Refresh"
        refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshButton.Parent = frame

        local function setupCharacter(char)
            local humanoid = char:WaitForChild("Humanoid")
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.Enabled = false
            table.insert(woundedHighlights, highlight)
            
            local connection = humanoid.HealthChanged:Connect(function(health)
                if health < 100 then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.Enabled = true
                else
                    highlight.Enabled = false
                end
            end)
            table.insert(woundedConnections, connection)
        end

        local playerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(setupCharacter)
        end)
        table.insert(woundedConnections, playerAddedConnection)

        local characterAddedConnection = player.CharacterAdded:Connect(setupCharacter)
        table.insert(woundedConnections, characterAddedConnection)

        local refreshConnection = refreshButton.MouseButton1Click:Connect(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    local highlight = plr.Character:FindFirstChild("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    setupCharacter(plr.Character)
                end
            end
        end)
        table.insert(woundedConnections, refreshConnection)

        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                setupCharacter(plr.Character)
            end
            local charAddedConn = plr.CharacterAdded:Connect(setupCharacter)
            table.insert(woundedConnections, charAddedConn)
        end
    else
        
        for _, connection in pairs(woundedConnections) do
            connection:Disconnect()
        end
        for _, highlight in pairs(woundedHighlights) do
            highlight:Destroy()
        end
        if woundedGui then
            woundedGui:Destroy()
        end
        table.clear(woundedConnections)
        table.clear(woundedHighlights)
        woundedGui = nil
    end
end)
