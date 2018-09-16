local t = "angelblock_block.png"
local mn = "angelblock"
local nodename = mn..":node_raw"
local itemname = mn..":block"



-- node by itself, pretty ordinary really
minetest.register_node(nodename, {
	groups = {
		not_in_creative_inventory = 1,
		oddly_breakable_by_hand = 3,
	},
	tiles = { t },
	drop = itemname,
	
})

-- Countdown timer to auto-remove the node after some time;
-- this is to ensure blocks aren't left littered around in the sky.
-- Lifetime of node is ~ node.param2 * 5s.
-- If the user doesn't come to reclaim it, it gets deleted.
minetest.register_abm({
	label = "Angel block removal countdown",
	nodenames = { nodename },
	interval = 5.0,
	chance = 1,
	action = function(pos, node)
		local counter = node.param2
		if counter == 0 then
			minetest.remove_node(pos)
		else
			counter = counter - 1
			node.param2 = counter
			minetest.set_node(pos, node)
		end
	end,
})



-- Placer item to enable "hovering" placement.
-- Node lifetime: ~1min
local life = 12
local initial = { name=nodename, param2=life }
minetest.register_craftitem(itemname, {
	inventory_image = t,
	description = "Angel block\nright-click in empty air to place",
	on_secondary_use = function(itemstack, user, pointed)
		local pos = user:get_pos()
		local name = user:get_player_name()
		-- don't clobber protection...
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return nil
		end

		-- don't trash the floor, either
		local current = minetest.get_node(pos)
		if current.name ~= "air" then return nil end

		minetest.set_node(pos, initial)
		itemstack:take_item(1)
		return itemstack
	end,
})



