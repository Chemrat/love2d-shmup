local util = {}

function CleanNils(t)
	local ans = {}
	for k, v in pairs(t) do
		if aabb_helper.outOfScreen(v) then
			-- print("Out of screen: " .. v.type)
			destroyObj(v)
			v = nil
		end

		if v ~= nil then
			ans[k] = v;
		end
	end
	return ans
end

function destroyObj(obj)
	--print("Removing object " .. obj.type)

	if obj.shape and obj.shape.destroy then obj.shape:destroy() end
	obj.shape = nil

	if obj.fixture and obj.fixture.destroy then
		obj.fixture:setUserData(nil)
		obj.fixture:destroy()
	end
	obj.fixture = nil

	if obj.body and obj.body.destroy then obj.body:destroy() end
	obj.body = nil

	gameobjects[obj] = nil
end

return util
