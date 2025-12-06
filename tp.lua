local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local tool = script.Parent
local chr
local hrp

local SAFE = 4
local MAX_DISTANCE = math.huge
local COOLDOWN = 0
local canTP = true

local banned = {
	"kill","dead","damage","lava","poison","trap",
	"danger","hurt","void","death","acid"
}

local function danger(p)
	if not p then return false end
	for _,n in ipairs(banned) do
		if p.Name:lower():find(n) then
			return true
		end
	end
	return false
end

tool.Equipped:Connect(function()
	chr = player.Character or player.CharacterAdded:Wait()
	hrp = chr:WaitForChild("HumanoidRootPart")
end)

local function drop(pos)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {chr}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local ray = workspace:Raycast(pos, Vector3.new(0, -9999, 0), params)
	if ray then
		if danger(ray.Instance) then
			return hrp.Position + Vector3.new(0, SAFE, 0)
		end
		return ray.Position + Vector3.new(0, SAFE, 0)
	end
	return pos + Vector3.new(0, SAFE, 0)
end

local function wallFix()
	local box = Region3.new(hrp.Position - Vector3.new(2,3,2), hrp.Position + Vector3.new(2,3,2))
	for _,p in ipairs(workspace:FindPartsInRegion3(box, chr, 100)) do
		if p.CanCollide then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, SAFE, 0)
		end
	end
end

local function antiVoid()
	if hrp.Position.Y < -20 then
		hrp.CFrame = CFrame.new(Vector3.new(0, 50, 0))
	end
end

RunService.Stepped:Connect(function()
	if hrp then
		antiVoid()
		wallFix()
	end
end)

local function blinkFX()
	local fx = Instance.new("ParticleEmitter")
	fx.Texture = "rbxassetid://258128463"
	fx.Rate = 300
	fx.Lifetime = NumberRange.new(0.1)
	fx.Speed = NumberRange.new(0)
	fx.Parent = hrp
	task.wait(0.1)
	fx.Enabled = false
	task.wait(0.05)
	fx:Destroy()
end

local function tp(pos)
	blinkFX()
	hrp.CFrame = CFrame.new(pos)
end

tool.Activated:Connect(function()
	if not canTP or not hrp then return end
	canTP = false

	local hit = mouse.Hit.Position
	local dist = (hit - hrp.Position).Magnitude
	if dist > MAX_DISTANCE then
		hit = hrp.Position + (hit - hrp.Position).Unit * MAX_DISTANCE
	end

	hit = drop(hit)

	tp(hit)

	task.wait(COOLDOWN)
	canTP = true
end)

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Q and canTP and hrp then
		canTP = false

		local dir = workspace.CurrentCamera.CFrame.LookVector
		local target = hrp.Position + dir * 999999
		target = drop(target)

		tp(target)

		task.wait(COOLDOWN)
		canTP = true
	end
end)
