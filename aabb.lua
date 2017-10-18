local aabb_helper = {}

collision_list = {}

gamedata = require "gamedata"
local gamearea = gamedata.gamearea

function aabb_helper.outOfScreen(self)
	if self.body == nil then return true end

	local x, y = self.body:getWorldCenter()
	return x + self.w < gamearea.x
		or x - self.w > gamearea.w
		or y + self.h < gamearea.y
		or y - self.h > gamearea.h
end

function aabb_helper.aabb(width, height)
	local aabb = {}
	aabb.w = width
	aabb.h = height
	aabb.outOfScreen = aabb_helper.outOfScreen

	aabb.type = "unknown"

	aabb.body = love.physics.newBody(world, 0, 0, "dynamic")
	aabb.shape = love.physics.newRectangleShape(0, 0, width, height)
	aabb.fixture = love.physics.newFixture(aabb.body, aabb.shape, 1)
	aabb.fixture:setSensor(true)
	-- Disable collisions (for performance testing)
	-- aabb.fixture:setFilterData(0, 0, -1)

	aabb.onCollision = function(self, other)
	-- print("Unhandled collision")
	-- nothing happens
	end

	aabb.setPos = function(self, x, y)
		self.body:setPosition(x, y)
	end

	aabb.setSpd = function(self, xs, ys)
		self.body:setLinearVelocity(xs, ys)
	end

	aabb.setAngl = function(self, angle)
		self.body:setAngle(angle)
		self.body:getAngularVelocity(0)
	end

	aabb.applyForce = function(self, x, y)
		self.body:applyLinearImpulse(x, y)
	end

	aabb.fixture:setUserData(aabb)
	return aabb
end

function beginContact(a, b, coll)
	local auser = a:getUserData()
	local buser = b:getUserData()

	--if auser.type == "enemy" or buser.type == "enemy" then
	--print("Collision: " .. auser.type .. " with " ..  buser.type)
	--end

	-- FIXME: there should be some important priority list
	-- who handles which collision
	if auser.type == "player" or auser.type == "enemy" or auser.type == "boss" then
		table.insert(collision_list, 0, {a = auser, b = buser})
	else
		table.insert(collision_list, 0, {a = buser, b = auser})
	end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

return aabb_helper
