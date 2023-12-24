function iamedusa.is_frozen(player)
	return minetest.is_yes(player:get_meta():get_string("iamedusa:frozen"))
end

minetest.register_entity("iamedusa:freeze", {
	-- This entity needs to be visible otherwise the frozen player won't be visible.
	initial_properties = {
		visual = "sprite",
		visual_size = { x = 0, y = 0 },
		textures = { "blank.png" },
		physical = false, -- Disable collision
		pointable = false, -- Disable selection box
		makes_footstep_sound = false,
	},

	on_step = function(self, dtime)
		local player = self.pname and minetest.get_player_by_name(self.pname)
		if not player or not iamedusa.is_frozen(player) then
			self.object:remove()
			return
		end
	end,

	set_frozen_player = function(self, player)
		self.pname = player:get_player_name()
		player:set_attach(self.object, "", {x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })

		--local meta = player:get_meta()
		--local pos  = player:get_pos()
		--meta:set_string("spawn_at", minetest.serialize(pos))
	end,
})

function iamedusa.freeze(player, pos)
	player:get_meta():set_string("iamedusa:frozen", "true")

	local parent = player:get_attach()
	if parent and parent:get_luaentity() and
			parent:get_luaentity().set_frozen_player then
		-- Already attached
		return
	end

	if pos == nil then
		pos = player:get_pos()
	end
	local obj = minetest.add_entity(pos, "iamedusa:freeze")
	obj:get_luaentity():set_frozen_player(player)
end

function iamedusa.unfreeze(player)
	player:get_meta():set_string("iamedusa:frozen", "")

	local pname = player:get_player_name()
	local objects = minetest.get_objects_inside_radius(player:get_pos(), 2)
	for i=1, #objects do
		local entity = objects[i]:get_luaentity()
		if entity and entity.set_frozen_player and entity.pname == pname then
			objects[i]:remove()
		end
	end
end

minetest.register_on_joinplayer(function(player)
	if iamedusa.is_frozen(player) then
		iamedusa.freeze(player)
	end
end)

