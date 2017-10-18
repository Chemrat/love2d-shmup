local enemy_mgr = {}

local function spawnBullet(enemy)
	local enemyBullet = aabb_helper.aabb(2, 4)

	local x, y = enemy.body:getWorldCenter()
	enemyBullet:setPos(x, y)
	enemyBullet:setSpd(0, 100)

	enemyBullet.sprite = "bullet3"
	enemyBullet.type = "enemy_bullet"

	enemyBullet.direction = "move"
	enemyBullet.onCollision = function(self, other)
	--print ("enemy bullet collision with " .. other.type)
	--if other.type == "player" then
	--        death()
	--end
	end

	gameobjects_new[enemyBullet] = enemyBullet
	return enemyBullet
end

local function spawnBulletAimed(enemy)
	local enemyBullet = spawnBullet(enemy)
	local x, y = enemy.body:getWorldCenter()
	local px = enemy.p.x
	local py = enemy.p.y

	local distance = math.sqrt(
		(px - x) * (px - x) + (py - y) * (py - y))

	enemyBullet:setSpd(
		300 * (px - x) / distance,
		300 * (py - y) / distance
	)

	return enemyBullet
end

local function spawnBulletAimedFast(enemy)
	local enemyBullet = spawnBullet(enemy)
	local x, y = enemy.body:getWorldCenter()
	local px = enemy.p.x
	local py = enemy.p.y

	local distance = math.sqrt(
		(px - x) * (px - x) + (py - y) * (py - y))

	enemyBullet:setSpd(
		450 * (px - x) / distance,
		450 * (py - y) / distance
	)

	return enemyBullet
end

local function spawnShotgunBlast(enemy)
	local x, y = enemy.body:getWorldCenter()
	local px = enemy.p.x
	local py = enemy.p.y

	local enemyBullet
	for i = 3,10 do
		enemyBullet = spawnBullet(enemy)
		local angle = math.atan2(px - x, py - y) + i % 3 - 1
		enemyBullet:setSpd(
			i / 3 * 100 * math.sin(angle),
			i / 3 * 100 * math.cos(angle))
	end

	--	return enemyBullet
end

local function spawnSpray(enemy)
	local x, y = enemy.body:getWorldCenter()
	local px = enemy.p.x
	local py = enemy.p.y

	local enemyBullet
	for i = 1,12 do
		enemyBullet = spawnBullet(enemy)
		local angle = math.atan2(x - px, py - y) + i/2
		enemyBullet:setSpd(
			250 * math.cos(angle),
			250 * math.sin(angle))
	end

	return enemyBullet
end

local function spawnBeam(enemy)
	local w = 12
	local h = 100
	local enemyBullet = aabb_helper.aabb(w, h)

	local x, y = enemy.body:getWorldCenter()
	local angle = enemy.body:getAngle()

	enemyBullet:setPos(x + w * math.sin(angle), y + h * math.cos(angle))

	--[[local px = enemy.p.x
	local py = enemy.p.y

	local angle = math.atan2(px - x, py - y)
	local distance = math.sqrt(
	(px - x) * (px - x) + (py - y) * (py - y))

	enemyBullet:setSpd(
	300 * (px - x) / distance,
	300 * (py - y) / distance
	)--]]

	enemyBullet:setSpd(
		- 500 * math.cos(angle),
		500 * math.sin(angle)
	)

	enemyBullet.sprite = "bullet4"
	enemyBullet.type = "enemy_bullet"

	enemyBullet.direction = "move"
	enemyBullet.onCollision = function(other)
		if other.type == "player" then
			death()
		end
	end

	gameobjects_new[enemyBullet] = enemyBullet
	return enemyBullet
end

enemy_mgr.enemyguns = {
	["forward"] = spawnBullet,
	["atplayer"] = spawnBulletAimed,
	["atplayer_fast"] = spawnBulletAimedFast,
	["shotgun"] = spawnShotgunBlast,
	["spray"] = spawnSpray,
	["beam"] = spawnBeam,
}

local function enemyTick(self, dt)
	local atan2 = math.atan2
	local sin = math.sin
	local cos = math.cos
	self.nrg = self.nrg + dt

	if self.nrg > self.maxnrg / gamedata.difficulty and self.gun ~= nil then
		self.gun(self)
		self.nrg = 0
	end

	local ptrn = self.pattern[self.patternIdx]
	local ptrn_changed = false
	if self.patternIdx < #self.pattern then
		self.timer = self.timer + dt
		if (self.patternIdx == 0 or self.timer > self.pattern[self.patternIdx].t / gamedata.pattern_speed) then
			self.patternIdx = self.patternIdx + 1
			ptrn_changed = true
		end
	else
		self.patternIdx = 2
		ptrn = self.pattern[self.patternIdx]
		ptrn_changed = true
		self.timer = self.pattern[1].t / gamedata.pattern_speed
	end

	if ptrn then
		if ptrn.special == "suicide" then
			local ox, oy = self.body:getWorldCenter()
			local angle = atan2(ox - self.p.x, oy - self.p.y)
			self:setSpd(- ptrn.x * sin(angle), - ptrn.y * cos(angle))
		end

		if ptrn_changed then

			if ptrn.special == "suicide" then
			-- handled separately
			elseif ptrn.special == "float" then
			-- do not set speed
			elseif ptrn.special == "away" then
				local ox, oy = self.body:getWorldCenter()
				local dx = -1
				if (self.p.x - ox) < 0 then dx = 1 end
				self:setSpd(ptrn.x * dx, ptrn.y)
			else
				self:setSpd(ptrn.x, ptrn.y)
			end

			self.gun = enemy_mgr.enemyguns[ptrn.gun]
			self.direction = ptrn.dir or self.direction
			self.maxnrg = ptrn.rate or self.maxnrg
		end
	end
end

function enemy_mgr.spawn(x, enemytype, p)
	local enemy = aabb_helper.aabb(hull_types[enemytype.hull].w, hull_types[enemytype.hull].h)
	enemy:setPos(x, 0)

	enemy.hp = hull_types[enemytype.hull].hp
	enemy.maxhp = hull_types[enemytype.hull].hp

	enemy:setSpd(0, 100)

	enemy.tick = enemyTick
	enemy.price = hull_types[enemytype.hull].price or 1

	enemy.nrg = 0
	enemy.maxnrg = 0.5

	enemy.timer = 0
	enemy.patternIdx = 0
	enemy.pattern = patterns[enemytype.pattern]
	enemy.sprite = hull_types[enemytype.hull].sprite
	enemy.p = p

	if enemytype.pattern ~= "boss_core" then
		enemy.type = "enemy"
	else
		enemy.type = "boss"
	end

	enemy.onCollision = function(other)
	--		if other.type == "player" then
	--			death()
	--		end
	end

	gameobjects_new[enemy] = enemy
	return enemy
end

function enemy_mgr.explosion_tick(self, dt)
	self.ttl = self.ttl - dt
	if self.ttl < self.ttl_max/2 then self.sprite = "explosion2" end
	if self.ttl < 0 then destroyObj(self) end
end

function enemy_mgr.explode(enemy)
	local x, y = enemy.body:getWorldCenter()
	local xs, ys = enemy.body:getLinearVelocity()

	sounds["explosion"]:setPitch(0.5 + love.math.random(1))
	if sounds["explosion"]:isPlaying() then
		sounds["explosion"]:rewind()
	else
		sounds["explosion"]:play()
	end

	for i=0,love.math.random(2) do
		local explosion = aabb_helper.aabb(3, 3)
		explosion:setPos(x, y)
		explosion:setSpd(xs + love.math.random(50) - love.math.random(50),
			ys - 50 - love.math.random(50))
		explosion.sprite = "explosion"
		explosion.type = "explosion"
		explosion.ttl_max = 0.2 + love.math.random(0.5)
		explosion.ttl = explosion.ttl_max
		explosion.tick = enemy_mgr.explosion_tick
		gameobjects_new[explosion] = explosion
	end
end

return enemy_mgr
