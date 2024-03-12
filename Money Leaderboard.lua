game.Players.PlayerAdded:connect(function(p)
	local stats = Instance.new("IntValue", p)
	stats.Name = "leaderstats"
	local money = Instance.new("IntValue", stats)
	money.Name = "??Baht??"
	money.Value = 0
	while true do
		wait(60)
		if game:GetService("BadgeService"):UserHasBadge(p.userId, 733544960) then
			money.Value = money.Value + 100
		else
			money.Value = money.Value + 200
		end	
	end
end)