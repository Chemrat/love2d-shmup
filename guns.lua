local guns = {}

playerdata.gunspeed = 1000

bonus_in = 10

function guns.genericBullet(player)
	local bullet = aabb_helper.aabb(5, 10)
	bullet:setPos(player.x, player.y)
	bullet:setSpd(0, -300)
	bullet.type = "player_bullet"

	bullet.direction = "move"

	bullet.onCollision = function(self, other)
		if (other.type == "enemy" or other.type == "boss") and other.body then
			other.hp = other.hp - 1
			--sounds["hit"]:play()

			if other.hp <= 0 then
				enemy_mgr.explode(other)

				if other.type == "boss" then
					gameOver(true)
				end

				score = score + other.price * score_mp
				bonus_in = bonus_in - other.price
				if bonus_in <= 0 then
					bonus_in = bonus_in + 10
					local x, y = other.body:getWorldCenter()
					bonus_mgr.spawn(x, y)
				end

				destroyObj(other)
				return
			end

			destroyObj(self)
		end
	end

	return bullet
end

function guns.p_start(player)
	if player.nrg < 0.5 then return end
	player.nrg = 0

	sounds["shoot"]:play()

	local bullet = guns.genericBullet(player)
	gameobjects_new[bullet] = bullet
	bullet.sprite = "bullet"
end

function guns.p_dual(player)
	if player.nrg < 0.4 then return end
	player.nrg = 0

	sounds["shoot"]:play()

	local bullet = guns.genericBullet(player)
	bullet.x = player.x + 10
	gameobjects_new[bullet] = bullet
	bullet.sprite = "bullet2"

	local bullet2 = guns.genericBullet(player)
	bullet2.x = player.x + 2
	gameobjects_new[bullet2] = bullet2
	bullet2.sprite = "bullet2"
end

function guns.p_split(player)
	local px, py = player.body:getWorldCenter()
	if player.nrg < 0.2 then return end
	player.nrg = 0

	sounds["shoot"]:setPitch(0.5 + love.math.random(2))
	sounds["shoot"]:play()

	for i=-3,3 do
		local bullet = guns.genericBullet(player)
		bullet:setPos(px + i * 3, py - 15 + math.abs(i) * 5)
		bullet:setSpd(i * 10, -500)

		gameobjects_new[bullet] = bullet
		bullet.sprite = "bullet"
	end

	local bullet2 = guns.genericBullet(player)
	bullet2:setPos(px - player.w/2, py - 5)
	bullet2:setSpd(-100, -450)
	gameobjects_new[bullet2] = bullet2
	bullet2.sprite = "bullet"

	local bullet3 = guns.genericBullet(player)
	bullet3:setPos(px + player.w/2, py - 5)
	bullet3:setSpd(100, -450)
	gameobjects_new[bullet3] = bullet3
	bullet3.sprite = "bullet"
end

function guns.p_panic(player)
	if player.panictime <= 0 then return end
	if player.panicdelay <= 0 then return end

	local bullet = guns.genericBullet(player)
	bullet.w = 20
	bullet.h = 20
	bullet.x = player.x - 4
	bullet.y = player.y - 22
	gameobjects_new[bullet] = bullet
	bullet.sprite = "bullet5"
end

gundata = {
	guns.p_start,
	guns.p_dual,
	guns.p_split,
}

return guns
