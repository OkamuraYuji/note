-- ⚡ Yjing AutoChest + Hop (No GUI)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ⚡ Config bằng getgenv()
getgenv().auto = getgenv().auto or true
getgenv().hopEnabled = getgenv().hopEnabled or true

-- ⚡ States
local chestThread = nil

-- ⚡ Hàm lưu trạng thái khi teleport
local function teleportWithSave(callback)
    local SavedMinimal = {
        AutoChest = getgenv().auto,
        Hop = getgenv().hopEnabled,
    }

    getgenv().SavedStates = SavedMinimal
    getgenv().SavedStatesJSON = HttpService:JSONEncode(SavedMinimal)

    local savedStr = getgenv().SavedStatesJSON and
        (string.format("game:GetService('HttpService'):JSONDecode([[%s]])", getgenv().SavedStatesJSON))
        or "nil"

    queue_on_teleport([[
        getgenv().SavedStates = ]]..savedStr..[[

        loadstring(game:HttpGet("https://raw.githubusercontent.com/OkamuraYuji/note/refs/heads/main/auto.lua"))()

        if getgenv().SavedStates then
            local s = getgenv().SavedStates
            if s.AutoChest then
                getgenv().auto = true
                getgenv().hopEnabled = s.Hop
                -- AutoChest sẽ tự chạy lại sau khi load
            end
        end
    ]])

    callback()
end

-- ⚡ AutoChest Loop
if getgenv().auto then
    if chestThread then task.cancel(chestThread) end
    chestThread = task.spawn(function()
        while getgenv().auto do
            local chests = workspace:FindFirstChild("Chests")
            local found = false
            if chests and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, chest in ipairs(chests:GetChildren()) do
                    if not getgenv().auto then break end
                    if chest:IsA("Model") and chest.PrimaryPart then
                        found = true
                        player.Character.HumanoidRootPart.CFrame = chest.PrimaryPart.CFrame + Vector3.new(0,3,0)
                        task.wait(0.1)
                    end
                end
            end

            -- Nếu không có chest nào và hopEnabled thì hop server
            if not found and getgenv().hopEnabled then
                teleportWithSave(function()
                    local servers = HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                    ))
                    for _,srv in ipairs(servers.data) do
                        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
                            break
                        end
                    end
                end)
            end

            task.wait(0.3)
        end
    end)
end
