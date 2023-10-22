local Players = game:GetService("Players")
local ScriptContext = game:GetService("ScriptContext")

local localPlr = Players.LocalPlayer

local ExternalSettings = {
    LastLootedOverlay = Enum.KeyCode.L,
    TemperatureLock = false,
    NoFallEnabled = false,
}
--error handling blah blah
do rconsoleclear(); ScriptContext.Error:Connect(function(Msg, Trace, Script)
        rconsoleprint("@@RED@@")
        rconsoleerr("\nSEND A SCREENSHOT OF THE FULL CONSOLE, AND SEND IT TO @vmdc")
        rconsoleprint("------------------------------------------------------")
        rconsoleprint("\n\nERROR: "..Msg.."\nLINE: "..Trace)
    end)
end

coroutine.wrap(function(_f)
    return _f()
end)(function()
    do local plrHumanoid = localPlr.Character and localPlr.Character:WaitForChild("Humanoid")
        if plrHumanoid then
            plrHumanoid.AnimationPlayed:Connect(function(playedAnim)
                if tonumber((playedAnim.Animation.AnimationId):match("%d+")) == 4595066903 then
                    localPlr:Kick("CLIENT BAN ATTEMPTED, YOU CAN REJOIN. CHECK IF THERE IS ANY OUTPUTS INSIDE CONSOLE.")
                end
            end)
        end
        localPlr.CharacterAdded:Connect(function(character)
            local existingHumanoid = character:WaitForChild("Humanoid")
            if existingHumanoid then
                existingHumanoid.AnimationPlayed:Connect(function(playedAnim)
                    if tonumber((playedAnim.Animation.AnimationId):match("%d+")) == 4595066903 then
                        localPlr:Kick("CLIENT BAN ATTEMPTED, YOU CAN REJOIN. CHECK IF THERE IS ANY OUTPUTS INSIDE CONSOLE.")
                    end
                end)
            end
        end)
    end
end)

local areaData = require(game.ReplicatedStorage.Info:FindFirstChild("AreaData"))
local Remotes = localPlr and localPlr.Character and localPlr.Character:FindFirstChild("CharacterHandler"):FindFirstChild("Remotes")

local Library = loadstring(game:HttpGet("https://github.com/kgukmz/updated/raw/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://github.com/kgukmz/updated/raw/main/Theme.lua"))()
local SaveManager = loadstring(game:HttpGet("https://github.com/kgukmz/updated/raw/main/Save.lua"))()

local Window = Library:CreateWindow({
    Title = 'Example Menu',
    Center = true,
    AutoShow = true,
    TabPadding = 0,
    MenuFadeTime = 0
})

local WindowTabs = {
    Main = Window:AddTab('Main'),
    Keybinds = Window:AddTab('Keybinds'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}; local GroupBoxes = {
    CharacterGroupBox = WindowTabs.Main:AddLeftGroupbox("Character");
}

do -- last looted from diff person idk who tho
    repeat wait(0.25) until game:IsLoaded() wait(0.5)
    if game.PlaceId == 3016661674 or game.GameId ~= 1087859240 then return end

    local snakeSpawnTime = workspace:WaitForChild("MonsterSpawns"):WaitForChild("Triggers"):WaitForChild("CastleRockSnake"):WaitForChild("LastSpawned")
    local Deep4SpawnTime = workspace:WaitForChild("MonsterSpawns"):WaitForChild("Triggers"):WaitForChild("evileye1"):WaitForChild("LastSpawned")
    local SunkenSpawnTime = workspace:WaitForChild("MonsterSpawns"):WaitForChild("Triggers"):WaitForChild("evileye2"):WaitForChild("LastSpawned")
    local SnakepitSpawnTime = workspace:WaitForChild("MonsterSpawns"):WaitForChild("Triggers"):WaitForChild("MazeSnakes"):WaitForChild("LastSpawned")

    local lb = Drawing.new("Text")
    function SecondsToClock(seconds)
        local seconds = tonumber(seconds)

        if seconds <= 0 then
            return "00:00:00";
        else
            hours = string.format("%02.f", math.floor(seconds/3600));
            mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
            secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
            return hours.."h "..mins.."m "..secs .. "s"
        end
    end
    local hidden = false

    game:GetService("UserInputService").InputBegan:Connect(function(key,typing)
        if key.KeyCode == ExternalSettings.LastLootedOverlay and not typing then 
            if hidden == true then
                hidden = false
                lb.Transparency = 0
            elseif hidden == false then 
                hidden = true
                lb.Transparency = 1
            end
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        local delta = os.time() - snakeSpawnTime.Value
        local delta4 = os.time() - SunkenSpawnTime.Value
        local delta3 = os.time() - Deep4SpawnTime.Value
        local delta2 = os.time() - SnakepitSpawnTime.Value
        local vf = workspace.CurrentCamera.ViewportSize
        lb.Text = "Castle Rock Spawned: " .. SecondsToClock(delta) .. " ago\nTundra 2 Spawned: " .. SecondsToClock(delta2) .. " ago\nDeepsunken Spawned: " .. SecondsToClock(delta3) .. " ago\nSunken Spawned: " .. SecondsToClock(delta4) 
        lb.Outline = true
        lb.Visible = true
        lb.Color = Color3.new(1,1,1)
        lb.ZIndex = 3
        lb.Size = 18
        lb.Position = Vector2.new(10, vf.Y - lb.TextBounds.Y - 100)
    end)
end

local old = nil
old = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    local Args = {...}
    -- temperature lock
    if (self.Parent == game.ReplicatedStorage.Requests) and (type(Args[1]) == "string") and (areaData[Args[1]]) and (ExternalSettings.TemperatureLock == true) then
        return
    end

    return old(self, ...)
end))

local Remotes = game.Players.LocalPlayer.Character:FindFirstChild("CharacterHandler"):FindFirstChild("Remotes")
local NoFall
NoFall = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    local Args = {...}
    if (self.Parent == Remotes) and (type(Args[1][1]) == "number") and (type(Args[1][2]) == "number") and (type(Args[2]) == "table") then
        return
    end
    return NoFall(self, ...)
end))

GroupBoxes.CharacterGroupBox:AddToggle('NoFallToggle', {
    Text = 'No Fall Damage',
    Default = false, -- Default value (true / false)
    Tooltip = 'Removes any type of fall damage', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ExternalSettings.NoFallEnabled = Value
    end
})
GroupBoxes.CharacterGroupBox:AddToggle('TemperatureLockToggle', {
    Text = 'Temperature Lock',
    Default = false, -- Default value (true / false)
    Tooltip = 'Locks temperature at the region you were in (eg if you turned this on in desert, youd still be hot even in tundra)', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ExternalSettings.TemperatureLock = Value
    end
})

Library:OnUnload(function()
    Library.Unloaded = true
end)

local MenuGroup = WindowTabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload(); end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('lightagee')
SaveManager:SetFolder('lightagee/rogue-lineage')

SaveManager:BuildConfigSection(WindowTabs['UI Settings'])

ThemeManager:ApplyToTab(WindowTabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
