local DiscordLib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt")()

local win = DiscordLib:Window("whizzbang")
local serv = win:Server("Preview", "")
local tgls = serv:Channel("Toggles")


local npcConnections = {}
local npcHighlights = {}
local crosshairGui = nil
local crosshairConnection = nil

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
