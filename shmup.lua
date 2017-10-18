local shmup = {}

aabb_helper = require('aabb')

require('gameover')
require "util"

local gameoverTimer = 1

function spawnPlayer()
	local player = aabb_helper.aabb(12, 12)
	player.x = playerstart.x
	player.y = gamedata.gamearea.h - gamedata.gamearea.y - 50 --playerstart.y
	player.xoff = -6
	player.yoff = -6
	player.gun = guns.p_split
	player.power = 1
	player.nrg = 0
	player.panic = 1
	player.panictime = 0
	player.panicdelay = 0
	player.type = "player"
	player.alive = true

	player.onCollision = function(self, other)
		-- print("Player collision with " .. other.type)
		if other.type == "enemy" or other.type == "enemy_bullet" then
			sounds["death"]:play()
			print("You're dead")
			enemy_mgr.explode(self)
			self.fixture:setFilterData( 0, 0, -1 )
			player.alive = false
		end

		if other.type == "bonus" then
			other.apply()
			destroyObj(other)
		end
	end

	return player
end

local time = nil
local p = nil
local mapheight = 0
local mapwidth = 0

local floor = math.floor
local tremove = table.remove

local function scrollLevel(time)
	for i = #object_list, 1, - 1 do
		if (mapheight - screen.h - object_list[i].y) < floor(time * gamedata.map_scroll_speed) then
			local enemy = enemy_mgr.spawn(object_list[i].x, enemy_types[object_list[i].type], p)
			enemy.timer = tonumber(object_list[i].name) or 0
			tremove(object_list, i)
		end
	end
end

function shmup.load()
	print("Importing modules...")
	gamedata = require('gamedata')
	guns = require('guns')
	bonus_mgr = require('bonus')
	enemy_mgr = require('enemy')

	print("Game loaded...")
	loadMap()
	mapheight = map.height * map.tileheight
	mapwidth = map.width * map.tilewidth

	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	math.randomseed(os.time())
	gameobjects = {}
	gameobjects_new = {}

	shmup.nextgc = 0
	time = 0
	gameoverTimer = 2
	p = spawnPlayer()
	if godmode then
		p.fixture:setFilterData(0, 0, -1)
	end
	shmup.sprites = {}
	sounds = {}

	local spritelist = {
		"bg_stub.png",
		"bonus2.png",
		"bonus.png",
		"boss_core.png",
		"boss_sidearm.png",
		"bullet2.png",
		"bullet3.png",
		"bullet4.png",
		"bullet5.png",
		"bullet.png",
		"enemy.png",
		"enemy_tileset.png",
		"explosion2.png",
		"explosion.png",
		"hanger.png",
		"kamikaze.png",
		"menubg.png",
		"player_forward.png",
		"player_left.png",
		"player.png",
		"player_right.png",
		"shotgunner.png",
		"sprayer.png",
	}

	local soundlist = {
		"bonus1.wav",
		"bonus2.wav",
		"death.wav",
		"explosion.wav",
		"hit.wav",
		"shoot.wav",
	}
	for _,file in pairs(spritelist) do
		shmup.sprites[string.sub(file, 0, - 5)] = love.graphics.newImage("gfx/"..file)
	end

	for _,snd in pairs(soundlist) do
		sounds[string.sub(snd, 0, - 5)] = love.audio.newSource("snd/"..snd, "static")
	end

	sounds["explosion"]:setVolume(0.2)
	sounds["shoot"]:setVolume(0.5)
	sounds["bonus1"]:setVolume(0.5)
	sounds["bonus2"]:setVolume(0.5)

	score = 0
	score_mp = 1
end

function shmup.draw()
	local atan2 = math.atan2

	love.graphics.push()
	love.graphics.translate((screen.w - mapwidth) / 2, 0)

	if time * gamedata.map_scroll_speed + screen.h < mapheight then
		map:draw((screen.w - mapwidth) / 2, - mapheight + time * gamedata.map_scroll_speed + screen.h, 1, 1)
	else
		map:draw((screen.w - mapwidth) / 2, 0, 1, 1)
	end

	p.body:setPosition(p.x + p.w/2, p.y + p.h/2)
	p.body:setLinearVelocity(0, 0)

	local px, py = p.body:getWorldCenter()
	if p.alive then
		love.graphics.draw(p.sprite, px - 25, py - 5)
	end

	local i = 1
	for _, o in pairs(gameobjects) do
		if o and o.body then

			local ox, oy = o.body:getWorldCenter()
			local oxs, oys = o.body:getLinearVelocity()
			local angle = 0
			local osw, osh = shmup.sprites[o.sprite]:getDimensions()

			if o.direction == "move" then
				local xs, ys = o.body:getLinearVelocity()
				angle = atan2(- xs, ys)
			elseif o.direction == "player" then
				angle = atan2(ox - p.x, p.y - oy)
			end

			if o.direction ~= "keep" then
				o:setAngl(angle)
			else
				angle = o.body:getAngle()
			end

			love.graphics.draw(shmup.sprites[o.sprite], ox, oy, angle, 1, 1, osw/2, osh/2)

			i = i + 1

			if o.type == "boss" then
				local offx = 20
				local offy = 20
				local thicc = 10
				love.graphics.setColor(84, 72, 110, 255)
				love.graphics.rectangle( "fill", offx - 3, offy - 3, 486, thicc + 6, 5, 5 )
				love.graphics.setColor(130, 131, 159, 255)
				love.graphics.rectangle( "fill", offx, offy, 480, thicc, 5, 5 )

				love.graphics.setColor(219, 234, 243, 255)
				love.graphics.rectangle( "fill", offx, offy, (o.hp / o.maxhp) * 480, thicc, 5,5 )

				love.graphics.setColor(255, 255, 255, 255)
				--	love.graphics.print(o.patternIdx, ox, oy)
			end
		end
	end

	--[[ render player hitbox
	love.graphics.setColor(255, 50, 255, 255)
	love.graphics.polygon("line", p.body:getWorldPoints(p.shape:getPoints()))
	love.graphics.setColor(255, 255, 255, 255)
	--]]

	--[[ render hitboxes
	for _, o in pairs(gameobjects) do
	if o and o.body then
	love.graphics.setColor(255, 50, 50, 255)
	love.graphics.polygon("line", o.body:getWorldPoints(o.shape:getPoints()))
	love.graphics.setColor(255, 255, 255, 255)
	end
	end
	--]]

	love.graphics.pop()

	love.graphics.print("Score:       " .. score .. " (x" .. score_mp .. ")", 10, 50)
	-- love.graphics.print("Objects: " .. i)
end

function shmup.keypressed(key)
	if key == "q" then
		gameOver(false)
	end
	--	if key == "z" then guns.panic(p) end
end

function shmup.handleInput(dt)
	if p.alive then

		local ismoving = false
		if love.keyboard.isDown("x") then
			mspeed = playerdata.movespeed / playerdata.slow_mp
		else
			mspeed = playerdata.movespeed
		end

		if love.keyboard.isDown("space") or love.keyboard.isDown("z") then p.gun(p) end

		if love.keyboard.isDown("down") and p.y < screen.h - p.h then
			ismoving = true
			p.y = p.y + mspeed * dt
			p.sprite = shmup.sprites["player"]
		elseif love.keyboard.isDown("up") and p.y > p.h then
			ismoving = true
			p.y = p.y - mspeed * dt
			p.sprite = shmup.sprites["player_forward"]
		end

		if love.keyboard.isDown("right") and p.x < mapwidth - p.w/2 then
			ismoving = true
			p.x = p.x + mspeed * dt
			p.sprite = shmup.sprites["player_right"]
		elseif love.keyboard.isDown("left") and p.x > 0 then
			ismoving = true
			p.x = p.x - mspeed * dt
			p.sprite = shmup.sprites["player_left"]
		end

		if ismoving == false then
			p.sprite = shmup.sprites["player"]
		end
	end
end

function shmup.update(dt)
	map:update(dt)
	world:update(dt)

	shmup.nextgc = shmup.nextgc + dt
	time = time + dt
	p.nrg = p.nrg + dt

	if p.alive == false then
		--print("dying in " .. gameoverTimer)
		gameoverTimer = gameoverTimer - dt
		if gameoverTimer < 0 then
			gameOver(false)
		end
	end

	for _, o in pairs(gameobjects) do
		if o and o.body and o.tick then o:tick(dt) end
	end

	for _, c in pairs(collision_list) do
		-- print("! Collision: " .. c.a.type .. " with " ..  c.b.type)
		c.b:onCollision(c.a)
		c.a:onCollision(c.b)
	end

	for _, o in pairs(gameobjects_new) do
		-- print("Spawned object: " .. o.type)
		gameobjects[o] = o
	end

	collision_list = {}
	gameobjects_new = {}

	if shmup.nextgc > 1 then
		gameobjects = CleanNils(gameobjects)
		shmup.nextgc = 0
	end

	if time * gamedata.map_scroll_speed < mapheight then
		scrollLevel(time)
	end
	--[[
	if p.panictime > 0 then
	p.panicdelay = p.panicdelay + dt
	if (p.panicdelay > 0.05) then
	guns.p_panic(p)
	p.panicdelay = 0
	p.panictime = p.panictime - dt
	end
	end
	--]]
	shmup.handleInput(dt)
end

return shmup
