local menu = {}

local time = 0

easymode = true
godmode = false

function menu.load()
	menu.menubg = love.graphics.newImage("gfx/menubg.png")
end

function menu.draw()
	love.graphics.draw(menu.menubg, 0, 0)
	love.graphics.print("Arrows - move\nZ, Space - fire\nX - precise movement\nQ - suicide\nEscape - quit\n\nF1 - Toggle difficulty\nF2 - Toggle godmode", 150, 200)

	if easymode then
		if godmode then
			love.graphics.print("Difficulty: NORMAL (godmode enabled)", 230, 330)
		else
			love.graphics.print("Difficulty: NORMAL", 230, 330)
		end
	else
		if godmode then
			love.graphics.print("Difficulty: HARD (godmode enabled)", 230, 330)
		else
			love.graphics.print("Difficulty: HARD", 230, 330)
		end
	end

	if math.floor(time) % 2 == 1 then
		love.graphics.print("Press ENTER to start", 200, 350)
	end
end

function menu.update(dt)
	time = time + dt
end

function menu.keypressed(key)

end

return menu
