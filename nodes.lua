-- vi: noexpandtab

local MODNAME = minetest.get_current_modname()
local MP      = minetest.get_modpath(MODNAME)
local S       = minetest.get_translator(MODNAME)

iamedusa.peepers = function(pos, radius, invert)--, puncher)
	assert(pos    ~= nil)
	assert(radius ~= nil)
	assert(invert ~= nil)
	local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, radius)
	local result = {}
	for _, obj in pairs(objs) do
		if (obj:is_player() or (obj:get_luaentity() ~= nil
    		--and (puncher == nil or obj:get_luaentity().name ~= puncher.name)
    		and obj:get_luaentity().name ~= "__builtin:item"))
            	--and ialazor.can_damage(obj)
		then
			local     objpos = obj:get_pos()
			local dir        = vector.direction(pos, objpos)
			local dis        = vector.distance(pos, objpos)
			print('dis  : '..dump(dis))
			print('dir 1: '..dump(dir))
			--dir = vector.divide(dir, dis)
			dir = vector.multiply(dir, dis)
			print('dir 2: '..dump(dir))
			--dir = vector.normalize(dir)
			local see,blkpos = minetest.line_of_sight(vector.add(pos,dir), objpos, 0.1)
			if see then
				local lookdir = obj:get_look_dir()
				local node_direction = vector.normalize(vector.subtract(pos, objpos))
				local dot_product = vector.dot(lookdir, node_direction)
				if dot_product > 0.5 then -- Adjust the threshold as needed
					if not invert then
						table.insert(result, obj)
					else
						print('looking: '..dump(objpos))
					end
				else
					if not invert then
						print('not looking: '..dump(objpos))
					else
						table.insert(result, obj)
					end
				end
			else
				print('medusa block: '..dump(blkpos)..', direction: '..dump(dir))
			end
		end
	end
	return result
end

iamedusa.punch_parade = function(vics, damage)
	for _,vic in ipairs(vics) do
		assert(vic ~= nil)
	    -- TODO medusa should insta kill player, don't drop inv
                vic:punch(vic, 1.0, {
                    full_punch_interval=1.0,
                    damage_groups={fleshy=damage},
                }, nil)
		local name = vic:get_player_name()
		if name ~= nil then
	    		print('punch: '..name)
			minetest.chat_send_player(name, S("You just lost the game."))
		else
			print('punch: non-player')
		end
	end
end

local damage = 10
iamedusa.register_statue = function(name, desc, image, on_timer)
	local def                        = minetest.registered_nodes["default:stone"]
	def                              = table.copy(def)
	local groups                     = def.groups
	groups.not_in_creative_inventory = 1
	def.description                  = S(desc.." Statue")
	def.drawtype                     = "plantlike"
	def.tiles                        = { image, }
	--def.drop                       = ""
	def.on_construct = function(pos)
		-- TODO maybe delay a little while to give the placer time to vacate
        	minetest.get_node_timer(pos):start(1)
	end
	def.after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			mode = math.random(1,2)
			meta:set_int("mode",   mode)
		end
	end
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int("mode")
		if mode == nil or mode == 0 then
			mode = math.random(1,2)
			meta:set_int("mode",   mode)
		elseif mode == 1 then
			mode = 2
		elseif mode == 2 then
			mode = 1
		end
		meta:set_int("mode", mode)
		-- TODO might be good to set the infotext
        end
        def.on_timer = on_timer
	minetest.register_node(name, def)
end
iamedusa.register_statue("iamedusa:medusa", "Medusa", "medusa.png", function(pos)
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("mode")
	if mode == nil or mode == 0 then
		mode = math.random(1,2)
		meta:set_int("mode",   mode)
	end
	local vics = iamedusa.peepers(pos, 15, mode == 1)--, nil)
	iamedusa.punch_parade(vics, damage)
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
	print('timer')
	return true
end)

iamedusa.fix_crosses = function(pos, cross_rad)
	local rad   = cross_rad
	local minp  = vector.subtract(pos, rad)
	local maxp  = vector.add     (pos, rad)
	local nps,_ = minetest.find_nodes_in_area(minp, maxp, {"group:church_cross",})
	for _,np in ipairs(nps) do
		local node = minetest.get_node(np)
		if      0 <= node.param2 and node.param2 <=  3 then
			-- already upward
		elseif  4 <= node.param2 and node.param2 <=  7 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 -  4})
		elseif  8 <= node.param2 and node.param2 <= 11 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 -  8})
		elseif 12 <= node.param2 and node.param2 <= 15 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 - 12})
		elseif 16 <= node.param2 and node.param2 <= 19 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 - 16})
		elseif 20 <= node.param2 and node.param2 <= 23 then
			local r = math.random(4,19)
			minetest.set_node(np, {name=node.name, param2 = r})
			minetest.after(1, minetest.set_node, np, {name=node.name, param2 = node.param2 - 20})
		end
	end
end

iamedusa.invert_crosses = function(pos, cross_rad)
	local rad   = cross_rad
	local minp  = vector.subtract(pos, rad)
	local maxp  = vector.add     (pos, rad)
	local nps,_ = minetest.find_nodes_in_area(minp, maxp, {"group:church_cross",})
	for _,np in ipairs(nps) do
		local node = minetest.get_node(np)
		if      0 <= node.param2 and node.param2 <=  3 then
			local r = math.random(4,19)
			minetest.set_node(np, {name=node.name, param2 = r})
			minetest.after(1, minetest.set_node, np, {name=node.name, param2 = node.param2 + 20})
		elseif  4 <= node.param2 and node.param2 <=  7 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 + 16})
		elseif  8 <= node.param2 and node.param2 <= 11 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 + 12})
		elseif 12 <= node.param2 and node.param2 <= 15 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 +  8})
		elseif 16 <= node.param2 and node.param2 <= 19 then
			minetest.set_node(np, {name=node.name, param2 = node.param2 +  4})
		elseif 20 <= node.param2 and node.param2 <= 23 then
			-- already downward
		end
	end
end

-- TODO statue to empty inventory; statue to give lodestones
iamedusa.register_statue("iamedusa:baphomet", "Baphomet", "baphomet.png", function(pos)
	local rad = 15
	local vics = iamedusa.peepers(pos, rad, true)--, nil)
	-- TODO get all nearby players and adjust their inventory, instead of punch parade ?
	iamedusa.punch_parade(vics, damage)
	iamedusa.invert_crosses(pos, rad)
	-- TODO don't play nice with holy statues
	print('timer')
	return true
end)

-- TODO statue to increase/decrease hp/mp/xp
iamedusa.register_statue("iamedusa:gargoyle", "Gargoyle", "gargoyle.png", function(pos)
	local rad = 15
	-- TODO get all nearby players and adjust attributes instead of punch parade ?
	local vics = iamedusa.peepers(pos, rad, true)--, nil)
	iamedusa.punch_parade(vics, damage)
	iamedusa.fix_crosses(pos, rad)
	-- TODO don't play nice with unholy statues
	print('timer')
	return true
end)



--    minetest.register_node("iamedusa:medusa", {
--        description = "Medusa Statue",
--        drawtype = "plantlike",
--        tiles = {
--		"medusa.png",
--	},
--        paramtype = "light",
--        --paramtype2 = "degrotate",
--        --paramtype2 = "facedir",
--        --sunlight_propagates = true,
--        --light_source = minetest.LIGHT_MAX,
--        walkable = false,
--        --pointable = false,
--        --diggable = false,
--	--diggable = true,
--        --buildable_to = true,
--        floodable = false,
--        drop = "",
--        --damage_per_second = 20,
--        --on_blast = function() end,
--
--        --groups = { stone=1, not_in_creative_inventory = 1}, -- TODO
--	groups = { dig_immediate = 2, },
--	on_construct = function(pos)
--        	minetest.get_node_timer(pos):start(1)
--	end,
--        on_timer = function(pos)
--		local vics = iamedusa.peepers(pos, 30)--, nil)
--		for _,vic in ipairs(vics) do
--			assert(vic ~= nil)
--                    vic:punch(vic, 1.0, {
--                        full_punch_interval=1.0,
--                        damage_groups={fleshy=damage},
--                    }, nil)
--		    local name = vic:get_player_name()
--		    if name ~= nil then
--		    	print('punch: '..name)
--			else
--				print('punch: non-player')
--			end
--		end
--		print('timer')
--		return true
--	end,
--
--	--on_rotate = function(pos, node, user, mode, new_param2)
--	--		end,
--    })
    
