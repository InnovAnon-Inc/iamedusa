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

iamedusa.classroom_look_at = function(player, target)
	local pos = player:get_pos()
	local delta = vector.subtract(target, pos)
	player:set_look_horizontal(math.atan2(delta.z, delta.x) - math.pi / 2)
end

--iamedusa.classroom_look = function(runner, players)
--iamedusa.classroom_look = function(pos, players)
--	--local pos = runner:get_pos()
--
--	for _, name in pairs(players) do
--		local player = minetest.get_player_by_name(name)
--		iamedusa.classroom_look_at(player, pos)
--	end
--end
iamedusa.force_peep = function(pos, radius)
	local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, radius)
	local result = {}
	for _, obj in pairs(objs) do
		if (obj:is_player() or (obj:get_luaentity() ~= nil
    		--and (puncher == nil or obj:get_luaentity().name ~= puncher.name)
    		and obj:get_luaentity().name ~= "__builtin:item"))
            	--and ialazor.can_damage(obj)
		then
			iamedusa.classroom_look_at(obj, pos)
		end
	end
end


local damage = 10
iamedusa.register_statue = function(name, desc, image, on_timer, after_place_node, on_punch)
	local def                        = minetest.registered_nodes["default:stone"]
	def                              = table.copy(def)
	local groups                     = def.groups
	groups.not_in_creative_inventory = 1
	def.description                  = S(desc.." Statue")
	def.drawtype                     = "plantlike"
	def.tiles                        = { image, }
	--def.drop                       = ""
	def.on_construct                 = function(pos)
		-- TODO maybe delay a little while to give the placer time to vacate
        	minetest.get_node_timer(pos):start(1)
	end
	def.after_place_node             = after_place_node
	def.on_punch                     = on_punch
        def.on_timer                     = on_timer
	minetest.register_node(name, def)
end

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

    
