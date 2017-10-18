local bonus_mgr = {}

local btype = 0

local function add_score()
	sounds["bonus1"]:play()
	score_mp = score_mp + 1
end

local function add_multiplier()
	sounds["bonus2"]:play()
	score = score + 10 * score_mp
end

function bonus_mgr.spawn(x, y)
	local bonus = aabb_helper.aabb(30, 30)
	bonus:setPos(x, y)
	bonus:setSpd(0, 150)
	gameobjects_new[bonus] = bonus
	bonus.type = "bonus"

	btype = btype + 1
	if (btype % 2 == 1) then
		bonus.sprite = "bonus2"
		bonus.apply = add_score
	else
		bonus.sprite = "bonus"
		bonus.apply = add_multiplier
	end

	return bonus
end

return bonus_mgr
