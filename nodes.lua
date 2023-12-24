-- vi: noexpandtab

local MODNAME = minetest.get_current_modname()
local MP      = minetest.get_modpath(MODNAME)
local S       = minetest.get_translator(MODNAME)


local damage = 10
iamedusa.register_statue("iamedusa:medusa", "Medusa", "medusa.png",
function(pos) -- on_timer
	local rad = 15
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("mode")
	if mode == nil or mode == 0 then
		mode = math.random(1,2,3)
		meta:set_int("mode",   mode)
	end
	if mode == 1 or mode == 2 then
		local vics = iamedusa.peepers(pos, rad, mode == 1)--, nil)
		iamedusa.punch_parade(vics, damage)
	elseif mode == 3 then
		iamedusa.force_peep(pos, rad)
	else assert(false)
	end
	--for _,vic in ipairs(vics) do
	--	assert(vic ~= nil)
	--    -- TODO kill player, don't drop inv
        --        vic:punch(vic, 1.0, {
        --            full_punch_interval=1.0,
        --            damage_groups={fleshy=damage},
        --        }, nil)
	--	local name = vic:get_player_name()
	--	if name ~= nil then
	--    		print('punch: '..name)
	--		minetest.chat_send_player(name, S("You just lost the game."))
	--	else
	--		print('punch: non-player')
	--	end
	--end
	--print('timer')
	return true
end,
function(pos, placer, itemstack, pointed_thing) -- after_place_node
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			mode = math.random(1,3)
			meta:set_int("mode",   mode)
		end
end,
function(pos, node, puncher, pointed_thing) -- on_punch
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			mode = math.random(1,3)
			meta:set_int("mode",   mode)
		elseif mode == 1 then
			mode = 2
		elseif mode == 2 then
			mode = 3
		elseif mode == 3 then
			mode = 1
		end
		meta:set_int("mode", mode)
		-- TODO might be good to set the infotext
end)

-- TODO statue to empty inventory; statue to give lodestones
iamedusa.register_statue("iamedusa:baphomet", "Baphomet", "baphomet.png",
function(pos) -- on_timer
	local rad = 15
	local vics = iamedusa.peepers(pos, rad, true)--, nil)
	-- TODO get all nearby players and adjust their inventory, instead of punch parade ?
	iamedusa.punch_parade(vics, damage)
	iamedusa.invert_crosses(pos, rad)
	-- TODO don't play nice with holy statues
	--print('timer')
	return true
end
-- TODO after_place_node
-- TODO on_punch
)

-- TODO statue to increase/decrease hp/mp/xp
iamedusa.register_statue("iamedusa:gargoyle", "Gargoyle", "gargoyle.png",
function(pos) -- on_timer
	local rad = 15
	-- TODO get all nearby players and adjust attributes instead of punch parade ?
	local vics = iamedusa.peepers(pos, rad, true)--, nil)
	iamedusa.punch_parade(vics, damage)
	iamedusa.fix_crosses(pos, rad)
	-- TODO don't play nice with unholy statues
	--print('timer')
	return true
end
-- TODO after_place_node
-- TODO on_punch
)

minetest.register_node("iamedusa:lamp", {
	description                  = S("Magick Lamp"),
	groups = { not_in_creative_inventory = 1, }, -- TODO
	drawtype                     = "plantlike",
	tiles                        = { "lamp.png", },
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			meta:set_int("mode", 1)
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			meta:set_int("mode", 1)
		end
		
		if mode == 1 then
			-- TODO adjust look position
			-- TODO make player invisible
			iamedusa.freeze(puncher, pos)
			meta:set_int("mode", 2)
		elseif mode == 2 then
			-- TODO kill nearby players
			meta:set_int("mode", 1)
		else assert(false)
		end
        end,
})

