-- trophies.lua: five 16x18 trophies, transparent bg, 1px ink rim. ASCII art -> png.
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local PAL = { o="#2b1c26", w="#fce67c", g="#f4cc4a", G="#e0aa2c", d="#bc8420",
  S="#d6cabc", s="#b8aca6", t="#9a8e90", e="#e08c62", b="#c66648", n="#a6483a",
  r="#c66648", q="#843230", u="#a8b8d4", v="#7e94bc", x="#46598a", P="#a290d0", Q="#5e4c9a",
  y="#c8b8ec", m="#a46e44", M="#70483a", c="#f8eacc" }
local function trophy(name, rows, extra)
  local c = HP.canvas{ w = 16, h = 18, scale = 1, name = name }
  local n = #rows
  local top = (18 - n) // 2
  for i, r in ipairs(rows) do
    assert(#r == 16, name .. " row " .. i .. " len " .. #r .. ": " .. r)
    for x = 1, 16 do local ch = r:sub(x, x); if ch ~= "." then c:put(x - 1, top + i - 1, PAL[ch]) end end
  end
  if extra then extra(c, top) end
  c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
end
trophy("tree-trophy-top-1", {
 "...oooooooooo...",
 "...owwggggGdo...",
 ".ooowwgggGGdooo.",
 ".o.owwggggGdo.o.",
 ".ooowwgggGGdooo.",
 "...owgggggGdo...",
 "....owgggGdo....",
 ".....ogggdo.....",
 "......ogdo......",
 "......ogdo......",
 "...oooooooooo...",
 "...owgggGGGdo...",
 "...ogGGGGGddo...",
 "...oooooooooo...",
})

trophy("tree-trophy-top-3", {
 "....oooooooo....",
 "....owgggGdo....",
 "..ooowgggGdooo..",
 "..o.owgggGdo.o..",
 "..ooowggGGdooo..",
 ".....oggGdo.....",
 "......ogdo......",
 "....oooooooo....",
 "....owgggGdo....",
 "ooooowgggGdo....",
 "oSssogggGGdooooo",
 "osstogggGGdoebno",
 "osstoGGGGddoebno",
 "oooooooooooooooo",
})
trophy("tree-trophy-expert-1", {
 ".....oooooo.....",
 "...oouuuuuuoo...",
 "..ouuuvvvvvxxo..",
 ".ouuvvvggvvvxxo.",
 ".ouvvwgggGdvvxo.",
 ".ouvvwgggGdggxo.",
 ".ouvvgggGGdggxo.",
 ".ouvvgggGGdvvxo.",
 ".oxvvgGGGddvxxo.",
 "..oxvvvvvvxxxo..",
 "...ooxxxxxxoo...",
 "....orrooqqo....",
 "....orrooqqo....",
 "...orrrooqqqo...",
 "...oooooooooo...",
})
-- two ribbons: blue rosette + violet rosette side by side
local ros = { "..oooo..", ".ouuvvo.", "ouuggvxo", "ouuggvxo", ".ovvxxo.", "..oooo..", ".orrqqo.", ".orrqqo.", ".orrqqo.", ".ooo.oo." }
local function stamp(grid, rows, c0, r0, map)
  for i, r in ipairs(rows) do for x = 1, #r do
    local ch = r:sub(x, x)
    if ch ~= "." then ch = map and map[ch] or ch
      local row = grid[r0 + i]; grid[r0 + i] = row:sub(1, c0 + x - 2) .. ch .. row:sub(c0 + x) end
  end end
end
local grid = {}
for i = 1, 13 do grid[i] = string.rep(".", 16) end
stamp(grid, ros, 1, 0)
stamp(grid, ros, 9, 3, { u = "y", v = "P", x = "Q", r = "v", q = "x" })
trophy("tree-trophy-expert-3", grid)
trophy("tree-trophy-expert-6", {
 ".....ooooo......",
 ".....owwgo......",
 "..oooowggoooo...",
 "..owwwggggGdo...",
 "..owwggggGGdoooo",
 "..owgggggggGGgdo",
 "..owggggggGGGgdo",
 "..owgggggggGGgdo",
 "..owgggGGGddoooo",
 "..ogGGGGGGddo...",
 "..oGGGGGGdddo...",
 "..ooooooooooo...",
 "......ogdo......",
 "...oooooooooo...",
 "...owggGGGddo...",
 "...ommmmmMMMo...",
 "...oooooooooo...",
})
