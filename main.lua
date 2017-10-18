local menu = require('menu')
local shmup = require('shmup')
local piefiller = require("piefiller")

function love.load()
	-- print(package.cpath)
	if arg[#arg] == "-debug" then require("mobdebug").start() end

	flags = {
		vsync = true,
		resizable = true,
	}
	love.window.setMode(screen.w, screen.h, flags)
	-- love.keyboard.setKeyRepeat( enable )

	-- FIXME: come up with a name
	love.window.setTitle("Generic Space Shootan Game")
	love.physics.setMeter(32)

	menu.load()
	handler = menu

	Pie = piefiller:new()
end

function love.draw()
	--Pie:attach()
	scalex = love.graphics.getWidth()/screen.w
	scaley = love.graphics.getHeight()/screen.h

	love.graphics.scale( scalex, scaley )
	handler.draw()
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 0, 0)

	--Pie:detach()

	--[[
	love.graphics.push()
	love.graphics.translate( love.graphics.getWidth()/4, love.graphics.getHeight()/4)
	love.graphics.scale(0.7, 0.7)
	Pie:draw()
	love.graphics.pop()--]]
end

function love.keypressed(key)
	--Pie:keypressed(key)

	if key == "f1" then
		if easymode == true then
			easymode = false
			gamedata.difficulty = 3
			gamedata.pattern_speed = 2
		else
			easymode = true
			gamedata.difficulty = 1
			gamedata.pattern_speed = 1
		end
	end

	if key == "f2" then
		if godmode == true then
			godmode = false
		else
			godmode = true
		end
	end

	if key == 'escape' then
		love.event.quit()
	elseif key == 'g' then
		debug.debug()
	end

	if key == "return" then
		-- start game
		if handler ~= shmup then
			shmup.load()
			handler = shmup
		end
	end

	--if key == "r" and handler == shmup then
	--	shmup.load()
	--end

	if handler.keypressed ~= nil then handler.keypressed(key) end
end

function love.mousepressed(...)
--Pie:mousepressed(...)
end

local accumulator = 0
local timestep = 1 / 60

function love.update(dt)

	accumulator = accumulator + dt
	dt = timestep
	if accumulator >= dt then
		while accumulator >= dt * 2 do dt = dt * 2 end
		accumulator = accumulator - dt
		-- do stuff here with dt
		--Pie:attach()]]--
		if handler.update ~= nil then handler.update(dt) end
		--Pie:detach()
	end
end
