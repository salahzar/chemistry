-- accumulate recipes in input[], out[][] and count
input = {}
out1 = {}
out2 = {}
out3 = {}
out4 = {}
out5 = {}
out6 = {}
out7 = {}
out8 = {}
out9 = {}
count = 0
-- the reactor node
minetest.register_craftitem("chemistry:reactor", {
    description = "Chemical reactor",
    inventory_image = "reactor.png"
})
-- how to craft
minetest.register_craft({
    output = "chemistry:reactor",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:steel_ingot", "default:chest", "default:steel_ingot"},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
    }
})
-- add recipe
-- from is the name of the recipe
-- to1 to9 are the explosion of components
function register_chemical_recipe(from, to1, to2, to3, to4, to5, to6, to7, to8,
                                  to9)
    table.insert(input, from)
    table.insert(out1, to1)
    table.insert(out2, to2)
    table.insert(out3, to3)
    table.insert(out4, to4)
    table.insert(out5, to5)
    table.insert(out6, to6)
    table.insert(out7, to7)
    table.insert(out8, to8)
    table.insert(out9, to9)
    count = count + 1
end
-- register crafting for all recipes
for index = 1, #input do
    minetest.register_craft({
        output = input[index],
        recipe = {
            {out1[index], out2[index], out3[index]},
            {out4[index], out5[index], out6[index]},
            {out7[index], out8[index], out9[index]}
        }
    })
end
-- formspec used 
-- from is 1x1 1 element
-- result 3x3 9 elements
-- main inventory player 8x4
-- listring enables shift click in a circular way
formspec = "size[10,10]" .. "list[current_name;from;4,0;1,1;]" ..
               "list[current_name;result;3,2;3,3;]" ..
               "listring[current_name;result]" ..
               "listring[current_player;main]" .. 
               "listring[current_name;from]" ..
               "list[current_player;main;1,6;8,4;]"
function where(it, arr)
    for index = 1, count do if arr[index] == it then return index end end
end
-- do reaction with the listname only if putting something 
function react(pos, listname)
    -- only reacts if something put in from cell
    if listname == "from" then
        minetest.log("action", "listname from")
        local meta = minetest.get_meta(pos)
        local inv = minetest.get_inventory({type = "node", pos = pos})
        if inv:is_empty("result") then
            minetest.log("result is empty")
            if not inv:is_empty("from") then
                minetest.log("action", "from is full")
                local from = inv:get_stack("from", 1)
                if from:get_count() > 0 and from:get_count() < 100 then
                    minetest.log("action", "from has elements")
                    numx = from:get_count()
                    local name = from:get_name()
                    local num = where(name, input)
                    if num ~= nil then
                        minetest.log("action", "found recipe, exploding")
                        local to1 = inv:get_stack("result", 1)
                        local to2 = inv:get_stack("result", 2)
                        local to3 = inv:get_stack("result", 3)
                        local to4 = inv:get_stack("result", 4)
                        local to5 = inv:get_stack("result", 5)
                        local to6 = inv:get_stack("result", 6)
                        local to7 = inv:get_stack("result", 7)
                        local to8 = inv:get_stack("result", 8)
                        local to9 = inv:get_stack("result", 9)
                        local item1 = out1[num]
                        local item2 = out2[num]
                        local item3 = out3[num]
                        local item4 = out4[num]
                        local item5 = out5[num]
                        local item6 = out6[num]
                        local item7 = out7[num]
                        local item8 = out8[num]
                        local item9 = out9[num]
                        stack1 = {name = item1, count = numx}
                        stack2 = {name = item2, count = numx}
                        stack3 = {name = item3, count = numx}
                        stack4 = {name = item4, count = numx}
                        stack5 = {name = item5, count = numx}
                        stack6 = {name = item6, count = numx}
                        stack7 = {name = item7, count = numx}
                        stack8 = {name = item8, count = numx}
                        stack9 = {name = item9, count = numx}
                        inv:set_stack("result", 1, stack1)
                        inv:set_stack("result", 2, stack2)
                        inv:set_stack("result", 3, stack3)
                        inv:set_stack("result", 4, stack4)
                        inv:set_stack("result", 5, stack5)
                        inv:set_stack("result", 6, stack6)
                        inv:set_stack("result", 7, stack7)
                        inv:set_stack("result", 8, stack8)
                        inv:set_stack("result", 9, stack9)
                        inv:set_stack("from", 1, {})
                        minetest.log("action", "recipe found and substituted")
                    end
                    --minetest.log("action", "pass1")
                end
                --minetest.log("action", "from getcount >0")
            end
            --minetest.log("action", "something in from ")
        end
        --minetest.log("action", "result empty")
    end
end
-- when removing something from result then should check if can
-- make another reaction
function retry(pos, listname) if listname == "result" then react(pos, "from") end end

-- this return true if the reactor is empty,meaning that from and result
-- must both be empty otherwise it is not diggable
function testit(pos)
    local inv = minetest.get_inventory({type = "node", pos = pos})
    if inv:is_empty("result") and inv:is_empty("from") then return true end
    return false
end
-- register new node reactor
--
minetest.register_node("chemistry:reactor", {
    description = "Chemical reactor",
    tiles = {"reactor.png"},
    -- what to do when putting something inside the inventory do react
    on_metadata_inventory_put = react,
    -- when removing from inventory do react if removes the result
    on_metadata_inventory_take = retry,
    groups = {cracky = 2},
    -- condition for being able to dig
    can_dig = testit
})
minetest.register_abm({
    nodenames = {"chemistry:reactor"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = minetest.get_meta(pos)
        local inv = minetest.get_inventory({type = "node", pos = pos})
        meta:set_string("formspec", formspec)
        if inv ~= nil then
            inv:set_size("from", 1)
            inv:set_size("result", 9)
            react(pos, "from")
        end
    end
})
hopper:add_container({
    {"top", "chemistry:reactor", "result"}, -- take cooked items from above into hopper below
    {"bottom", "chemistry:reactor", "from"} -- insert items below to be cooked from hopper above
})
minetest.log("action", "Chemistry!")
