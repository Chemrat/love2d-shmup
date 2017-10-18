local gameover = {}

function gameOver(victory)
	if victory ~= true then
		gameOverMessage = "Game over, you lose\nScore: " .. score .. "\nPress ENTER to restart, ESCAPE to quit"
	else
		gameOverMessage = "A winner is you\nScore: " .. score .. "\nPress ENTER to restart, ESCAPE to quit"
	end
	handler = gameover
end

function gameover.load()

end

function gameover.draw()
	love.graphics.print(gameOverMessage, 300, 250)
end

function gameover.update(dt)

end

return gameover
