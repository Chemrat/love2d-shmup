local gamedata = {}

gamedata.map_scroll_speed = 50
gamedata.difficulty = 1
gamedata.pattern_speed = 1

collision_categories = {
	player = 1,
	player_bullet = 2,
	enemy = 3,
	enemy_bullet = 4,
}

collision_masks = {
	player = 12,
	enemy = 2,
}

playerdata = {
	movespeed = 300,
	slow_mp = 3,
}

screen = {
	w = 640,
	h = 480,
	scale = 1,
}

gamedata.gamearea = {
	x = 0,
	y = 0,
	w = 640,
	h = 480,
}

hull_types = {}
hull_types["normal"] = { hp = 5, sprite = "enemy", w = 24, h = 25 }
hull_types["hanger"] = { hp = 10, sprite = "hanger", w = 32, h = 32, price = 3 }
hull_types["shotgunner"] = { hp = 15, sprite = "shotgunner", w = 32, h = 32, price = 4 }
hull_types["sprayer"] = { hp = 7, sprite = "sprayer", w = 32, h = 32, price = 2 }
hull_types["kamikaze"] = { hp = 3, sprite = "kamikaze", w = 24, h = 25 }

hull_types["boss"] = { hp = 200, sprite = "boss_core", w = 134, h = 60, price = 10 }
hull_types["bossgun"] = { hp = 50, sprite = "boss_sidearm", w = 32, h = 72, price = 10 }

patterns = {}

patterns["normal"] = {
	{ x = 0, y = 150, t = 0 },

	{ x = 0, y = 150, t = 1, gun = "atplayer", rate = 1 },
	{ x = 0, y = 150, t = 10 },

	{ x = 0, y = 150, t = 12 }, -- dummy
}

patterns["normal_gunfree"] = {
	{ x = 0, y = 150, t = 0 },

	{ x = 0, y = 150, t = 1 },
	{ x = 0, y = 150, t = 10 },

	{ x = 0, y = 150, t = 12 }, -- dummy
}

patterns["normal_gunfree_flee"] = {
	{ x = 0, y = 150, t = 0 },

	{ x = 150, y = 150, t = 1, special = "away", dir = "move" },
	{ x = 150, y = 150, t = 10, special = "away", dir = "move" },

	{ x = 0, y = 150, t = 12 }, -- dummy
}

patterns["discrete_sine"] = {
	{x = 0, y = 100, t = 0},
	{x = 100, y = 100, t = 1, gun = "atplayer", rate = 1},
	{x = -100, y = 100, t = 2, gun = "atplayer", rate = 1},
	{x = 0, y = 100, t = 3, special = "away"},
	{x = 0, y = 100, t = 400, special = "away"},
	{x = 0, y = 100, t = 500},
}

patterns["hanger"] = {
	{x = 0, y = 100, t = 0, dir = "player"},
	{x = 0, y = 50, t = 3, gun = "atplayer", rate = 0.5},
	{x = 50, y = 100, t = 6, special = "away"},
	{x = 50, y = 100, t = 200, special = "away"},

	{x = 0, y = 0, t = 400}
}

patterns["hanger_shotgun"] = {
	{x = 0, y = 100, t = 0, dir = "player"},
	{x = 0, y = 0, t = 2, gun = "shotgun", rate = 1},
	{x = 50, y = 100, t = 4, special = "away"},
	{x = 50, y = 100, t = 200, special = "away"},

	{x = 0, y = 0, t = 400}
}

patterns["suicide"] = {
	{x = 0, y = 100, t = 0.5, dir = "player"},
	{x = 200, y = 200, t = 2, special = "suicide", gun = "atplayer_fast"},
	{x = 0, y = 0, t = 555, dir = "move", special = "float"},
	{x = 0, y = 100, t = 500, dir = "move", special = "float"},
}

patterns["spray"] = {
	{x = 0, y = 100, t = 0.5, dir = "player"},
	{x = 50, y = 50, t = 2, special = "suicide", gun = "spray", rate = 1},
	{x = 0, y = 0, t = 5, dir = "move", special = "float"},

	{x = 0, y = 100, t = 500, dir = "move", special = "float"}, -- dummy
}

patterns["boss_core"] = {
	{ x = 0, y = 60, t = 1 }, -- entry
	{ x = 0, y = 0, t = 2 },
	{ x = -100, y = 50, t = 3 },
	{ x = 0, y = -50, t = 4 },
	{ x = 0, y = 0, t = 5, gun = "spray", rate = 0.5 },
	{ x = 100, y = 50, t = 6 },
	{ x = 0, y = -50, t = 7 },
	{ x = 0, y = 0, t = 8, gun = "spray", rate = 0.5 },
	{ x = 0, y = 0, t = 9},
	{ x = 0, y = 0, t = 20 } -- dummy entry, loops from here
}

patterns["boss"] = {
	{ x = 0, y = 60, t = 1 }, -- entry
	{ x = 0, y = 0, t = 2 },
	{ x = -100, y = 50, t = 3, dir = "player", gun = "shotgun", rate = 0.1 },
	{ x = 0, y = -50, t = 4, dir = "player", gun = "atplayer_fast", rate = 0.2 },
	{ x = 0, y = 0, t = 5, dir = "keep" }, --, dir = "keep", gun = "beam", rate = 0.1 },
	{ x = 100, y = 50, t = 6, dir = "player", gun = "shotgun", rate = 0.1 },
	{ x = 0, y = -50, t = 7, dir = "player", gun = "atplayer_fast", rate = 0.2 },
	{ x = 0, y = 0, t = 8, dir = "keep" }, --, dir = "keep", gun = "beam", rate = 0.1 },
	{ x = 0, y = 0, t = 9},
	{ x = 0, y = 0, t = 20 } -- dummy entry, loops from here
}

enemy_types = {
	["flee"] = { hull = "normal", pattern = "normal_gunfree_flee" },
	["popcorn"] = { hull = "normal", pattern = "normal_gunfree" },
	["normal"] = { hull = "normal", pattern = "normal" },
	["sine"] = { hull = "normal", pattern = "discrete_sine" },
	["hanger"] = { hull = "hanger", pattern = "hanger" },
	["bosscore"] = { hull = "boss", pattern = "boss_core"},
	["boss"] = { hull = "bossgun", pattern = "boss"},
	["suicide"] = { hull = "kamikaze", pattern = "suicide" },
	["shotgun"] = { hull = "shotgunner", pattern = "hanger_shotgun" },
	["spray"] = { hull = "sprayer", pattern = "spray" }
}

function loadMap()
	local sti = require "sti"

	map = sti("lvl/level1.lua")
	object_list = map.layers["Objects"].objects

	for i = #object_list, 1, - 1 do
		if object_list[i].name == "player" then
			playerstart = object_list[i]
			table.remove(object_list, i)
		end
	end
end

return gamedata
