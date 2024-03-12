local teddy = script.Parent
local humanoid = teddy.Humanoid

local function getHumPos()
	return (teddy.HumanoidRootPart.Position)
end

local function attack(target, teddyPart)
	local distance = (teddyPart.Position - getHumPos()).Magnitude
	if distance < 4 and game.Players:GetPlayerFromCharacter(target) then
		target.Humanoid.Health = 0
		local plr = game.Players:GetPlayerFromCharacter(target)
		-- jumpscare
		if plr.GettingChasedBy.Value == script.Parent then
			plr.GettingChased.Value = false
			plr.GettingChasedBy.Value = nil
		end
		game.ReplicatedStorage.Jumpscare:FireClient(plr)
	end
end

script.Parent.Reached.Event:Connect(function(target)
	if target.Character then
		if target.Character.Humanoid.Health > 0 then
			target.Character.Humanoid.Health = 0
			local plr = target
			-- jumpscare
			if plr.GettingChasedBy.Value == script.Parent then
				plr.GettingChased.Value = false
				plr.GettingChasedBy.Value = nil
			end
			game.ReplicatedStorage.Jumpscare:FireClient(plr)
		end
	end
end)
local function detection(part, teddyPart)
	if part.Parent:FindFirstChild("Humanoid") then
		local character = part.Parent
		if game.Players:GetPlayerFromCharacter(character) then
			--Check the player is still alive (And it's not our own character)
			if character.Humanoid.Health > 0 and character ~= teddy then
				attack(character, teddyPart)
			end
		end
	end
end

for i,v in pairs(script.Parent:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
		if not string.find(v.Name, "cloth") then
			v.Touched:Connect(function(hit)
				detection(hit, v)
			end)
		end
	end
end