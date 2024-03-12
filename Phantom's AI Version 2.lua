local TeddyAI = script.Parent

local chasing = false
local followingTarget = nil
local SimplePath = require(game.ServerStorage.SimplePath)
local path = nil
local reached = false
local reached2 = false
local hipHeight = script.Parent.Humanoid.HipHeight

local pathParams = {
	["AgentHeight"] = ((hipHeight > 0 and hipHeight) or 4),
	["AgentRadius"] = script.Parent.HumanoidRootPart.Size.X,
	["AgentCanJump"] = true
}

script.Parent.HumanoidRootPart:SetNetworkOwner(nil)

local function getHumPos()
	return (TeddyAI.HumanoidRootPart.Position - Vector3.new(0,hipHeight,0))
end

local function displayPath(waypoints)
	local color = BrickColor.Random()
	for index, waypoint in pairs(waypoints) do
		local part = Instance.new("Part")
		part.BrickColor = color
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(5,5,5)
		part.Position = waypoint.Position
		part.Parent = workspace
		local Debris = game:GetService("Debris")
		Debris:AddItem(part, 6)
	end
end


local function findPotentialTarget()
	local players = game.Players:GetPlayers()
	local maxDistance = 10000
	local nearestTarget

	for index, player in pairs(players) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Character.Humanoid.Health > 0 then
				local target = player.Character
				local distance = (TeddyAI.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude

				if distance < maxDistance then
					nearestTarget = player
					maxDistance = distance
				end
			end
		end
	end

	return nearestTarget
end

local function canSeeTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local origin = TeddyAI.HumanoidRootPart.Position
		local direction = (target.HumanoidRootPart.Position - TeddyAI.HumanoidRootPart.Position).unit * 10000
		local ray = Ray.new(origin, direction)
		local ignoreList = {TeddyAI}

		local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

		-- check if it exists
		if hit then
			-- check if it hit
			if hit:IsDescendantOf(target) then
				-- check health
				if target.Humanoid.Health > 0 then
					-- check if target is safe or not
					if not game.Players:GetPlayerFromCharacter(target).Safe.Value then
						-- check if monster can see
						local unit = (target.HumanoidRootPart.Position - getHumPos()).Unit
						local lv = TeddyAI.HumanoidRootPart.CFrame.LookVector
						local dp = unit:Dot(lv)

						if dp > 0 then
							return true
						end		
					end			
				end
			end
		else
			return false
		end	
	end
end

local function getPath(destination)
	local PathfindingService = game:GetService("PathfindingService")

	local path = PathfindingService:CreatePath(pathParams)

	path:ComputeAsync(getHumPos(), destination.Position)

	return path
end

local function blockToBlock()
	if path and not reached then
		coroutine.wrap(function()
			path.Reached:Wait()
			reached2 = true
			print("Set")
		end)()
		repeat wait() if path == nil then break end until reached2 == true
	end
	reached = false
	reached2 = false
	path = nil
	coroutine.wrap(function()
		wait(1)
		if followingTarget and chasing == false then
			-- disable stuff for all targets
			print("disable things for all targets")
			for i, v in pairs(game.Players:GetPlayers()) do
				if v.GettingChasedBy.Value == script.Parent then
					v.GettingChased.Value = false
					v.GettingChasedBy.Value = nil
				end
			end
			TeddyAI.Chasing.Value = false
			followingTarget = nil
		end
	end)()
	print("now going to path")
	local goal = workspace.LoopPoints:GetChildren()[Random.new():NextInteger(1,#workspace.LoopPoints:GetChildren())]
	local path = getPath(goal)
	if path.Status == Enum.PathStatus.Success then
		--displayPath(path:GetWaypoints())
		for i, v in pairs(path:GetWaypoints()) do
			if findPotentialTarget() then
				if canSeeTarget(findPotentialTarget().Character) then
					break
				end
			end
			TeddyAI.Humanoid:MoveTo(v.Position)
			TeddyAI.Humanoid.MoveToFinished:Wait()
		end
	else
		print("nope")
	end
end

TeddyAI.Chasing.Changed:Connect(function()
	print(TeddyAI.Chasing.Value)
end)

script.Parent.Teleport.Event:Connect(function()
	path = nil
end)
while true do
	local target = findPotentialTarget()
	if target and canSeeTarget(target.Character) and target.Character.Humanoid.Health > 0 then
		print("found player")
		path = SimplePath.new(script.Parent,pathParams)
		--path.Visualize = true
		local connection = path.Reached:Connect(function()
			reached = true
			script.Parent.Reached:Fire(target)
		end)
		repeat
			chasing = true
			followingTarget = target
			-- enable stuff for target
			target.GettingChased.Value = true
			target.GettingChasedBy.Value = script.Parent
			TeddyAI.Chasing.Value = true
			path:Run(target.Character.HumanoidRootPart.Position)
		until not path or path.LastError == "ComputationError" or not target.Character or target.Character:FindFirstChild("HumanoidRootPart") == nil or target.Character.Humanoid.Health < 1 or target.Safe.Value or findPotentialTarget() ~= target or reached
		if connection then
			connection:Disconnect()
		end
		if findPotentialTarget() ~= target then
			if path and path._moveConnection then
				path:Stop()
			end
		end
		print("stopped")
		chasing = false
	else
		print("block to block")
		blockToBlock()
	end
	game:GetService("RunService").Heartbeat:Wait()
end