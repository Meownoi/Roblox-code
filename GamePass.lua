local GamepassID = 733544960 
local MarketlaceService = game:GetService("MarketplaceService")

game.Players.PlayerAdded:Connect(function(player)
	if (MarketlaceService:UserOwnsGamePassAsync(player.UserId, GamepassID)) then
		local Tags = {
			{
				TagText = "??VIP", 
				TagColor = Color3.fromRGB(31, 81, 255) 
			}
		}
		local TextChatService = require(game:GetService("ServerScriptService"):WaitForChild("ChatServiceRunner").ChatService)
		local Speaker = nil
		while Speaker == nil do
			Speaker = TextChatService:GetSpeaker(player.Name)
			if Speaker ~= nil then break end
			wait(0.01)
		end
		Speaker:SetExtraData("Tags",Tags)
		Speaker:SetExtraData("ChatColor",Color3.fromRGB(57, 255, 20))
	end
end)