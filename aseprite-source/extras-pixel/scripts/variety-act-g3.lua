-- variety-act-g3.lua : first-pass Do-tab act cards (144x108) for 11 rest-stop activities:
-- cast_a_line night_fishing ice_hole skim_stones pick_herbs herb_tea drying_day mushroom_rain tinker saw_planks dress_stone
-- Params: only=<slug> out=<dir for png> ase=<dir for .aseprite>   (--script-param BEFORE --script)
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/extras-pixel/scripts/variety-act-g3-lib.lua")
local C = L.C
local P = app.params
local ONLY = P.only
local OUT = P.out or (REPO .. "game/assets/img/acts")
local ASE = P.ase or (REPO .. "aseprite-source/extras-pixel/aseprite")

local SCENES = {}
local ORDER = { "cast_a_line", "night_fishing", "ice_hole", "skim_stones", "pick_herbs", "herb_tea", "drying_day",
  "mushroom_rain", "tinker", "saw_planks", "dress_stone" }

local function daysky(s)
  s:bands(5, 5, 67, 28, { C.sky1, C.sky1, C.sky2, C.sky2, C.sky3, C.sky4 })
end

-- bucket with two fish tails sticking out (x,y = top-left of the rim, 8 wide)
local function bucket(s, x, y)
  s:poly({ { x, y }, { x + 8, y }, { x + 7, y + 9 }, { x + 1, y + 9 } }, C.woodD)
  s:rect(x, y, x + 1, y + 9, C.wood)
  s:rect(x, y + 3, x + 8, y + 3, C.goldD); s:rect(x + 1, y + 7, x + 7, y + 7, C.goldD)
  s:rect(x - 1, y, x + 9, y, C.ol); s:line(x - 1, y, x, y + 9, C.ol); s:line(x + 9, y, x + 8, y + 9, C.ol); s:rect(x, y + 10, x + 8, y + 10, C.ol)
  s:line(x, y - 1, x + 3, y - 5, C.ol); s:line(x + 8, y - 1, x + 5, y - 5, C.ol)    -- handle
  -- fish tails
  s:rect(x + 1, y - 4, x + 1, y - 3, "#e0884a"); s:rect(x + 3, y - 4, x + 3, y - 3, "#e0884a"); s:rect(x + 2, y - 2, x + 2, y - 1, "#e0884a")
  s:rect(x + 5, y - 3, x + 5, y - 2, "#7a96b4"); s:rect(x + 7, y - 3, x + 7, y - 2, "#7a96b4"); s:rect(x + 6, y - 1, x + 6, y - 1, "#7a96b4")
  s:rect(x + 1, y, x + 3, y + 1, "#e0884a"); s:rect(x + 4, y, x + 7, y + 1, "#7a96b4")
end

SCENES.cast_a_line = function(s)
  daysky(s)
  s:cloud(16, 12, C.white); s:cloud(52, 10, C.white)
  s:ell(32, 9, 3, 3, C.gold)
  s:hill(26, 5, 7, 3, C.hill)
  s:hill(28, 3, 5, 10, C.hillL)
  -- water
  s:rect(5, 28, 67, 49, C.water)
  for _, g in ipairs({ { 8, 33, 5 }, { 24, 45, 6 }, { 48, 40, 7 }, { 56, 31, 4 }, { 14, 47, 4 }, { 60, 46, 5 } }) do s:rect(g[1], g[2], g[1] + g[3], g[2], C.waterL) end
  -- jetty piles and planks
  for _, px in ipairs({ 9, 24, 40 }) do s:rect(px, 40, px + 2, 48, C.woodDD); s:rect(px, 40, px, 48, C.woodD) end
  s:rect(5, 36, 47, 38, C.wood); s:rect(5, 36, 47, 36, C.woodL)
  s:rect(5, 39, 47, 40, C.woodD); s:rect(5, 41, 47, 41, C.ol)
  s:rect(5, 35, 47, 35, C.ol)
  for x = 11, 47, 8 do s:rect(x, 36, x, 40, C.woodDD) end
  -- bucket with a catch
  bucket(s, 12, 29)
  -- gnome seated at the end, legs over the edge
  s:gnome(32, 18, { sit = true })
  s:rect(40, 34, 46, 36, C.blueD); s:rect(40, 34, 46, 34, C.blue)
  s:rect(45, 37, 46, 40, C.blueD)
  s:rect(45, 41, 49, 42, C.boot); s:rect(45, 43, 49, 43, C.ol2)
  -- arm and rod
  s:line2(40, 28, 44, 29, C.blue); s:px(45, 29, C.skin); s:px(45, 30, C.skin)
  s:line2(44, 29, 61, 15, C.woodDD)
  s:line(61, 15, 61, 33, "#f4eee0")
  s:rect(60, 34, 62, 35, C.red); s:rect(60, 34, 62, 34, C.white)
  s:ring(61, 37, 3, 1, C.waterL)
end

SCENES.night_fishing = function(s)
  s:bands(5, 5, 67, 30, { "#1c2450", "#1c2450", "#222d5e", "#263468", "#2c3a72", "#32427a" })
  for _, p in ipairs({ { 12, 8 }, { 30, 7 }, { 44, 11 }, { 56, 8 }, { 20, 16 }, { 38, 18 }, { 61, 20 }, { 8, 22 }, { 50, 24 }, { 26, 25 } }) do s:px(p[1], p[2], C.cream) end
  s:px(31, 7, "#fff1c8"); s:px(57, 8, "#fff1c8")
  -- moon: crescent
  s:ell(14, 14, 4, 4, "#fff1c8"); s:ell(16, 13, 3, 3, "#1c2450")
  s:hill(29, 6, 6, 5, "#1e3a3a")
  s:hill(31, 3, 4, 9, "#18302f")
  -- water and moon path
  s:rect(5, 31, 67, 49, "#22406e")
  s:bands(5, 40, 67, 49, { "#1d386a", "#1b3464" })
  for i, y in ipairs({ 33, 36, 39, 43, 47 }) do s:rect(12 - (i % 2), y, 15 + (i % 3), y, "#8fa8d8") end
  s:rect(44, 34, 48, 34, "#6a80b8"); s:rect(30, 44, 36, 44, "#2f5688"); s:rect(52, 46, 58, 46, "#2f5688")
  -- ripples and the leaping fish
  s:ring(24, 38, 8, 2, "#6a8ac0"); s:ring(24, 38, 4, 1, "#9ab4e0")
  s:ascii({
    "...ooooo...o",
    "..osssssowoo",
    ".osssssswsso",
    "ossdsssssswo",
    ".ossssssooo.",
    "..ossooo....",
    "...ooo......",
  }, 19, 22, { o = "#14203e", s = "#a8c4e0", w = "#e8f0fa", d = "#14203e" })
  s:px(18, 26, "#a8c4e0"); s:px(28, 30, "#a8c4e0"); s:px(15, 29, "#a8c4e0"); s:px(30, 25, "#a8c4e0")
  -- jetty on the right
  for _, px in ipairs({ 44, 56, 64 }) do s:rect(px, 41, px + 2, 48, "#3a2416") end
  s:rect(40, 37, 67, 39, "#8a5a32"); s:rect(40, 37, 67, 37, "#b07a45"); s:rect(40, 40, 67, 41, "#5e3a20"); s:rect(40, 36, 67, 36, "#2a1a10")
  for x = 46, 66, 8 do s:rect(x, 37, x, 41, "#3a2416") end
  -- lantern post with a glow
  s:ell(59, 24, 8, 7, "#3a4a80")
  s:ell(59, 24, 5, 4, "#4a5a8e")
  s:rect(65, 18, 66, 36, "#3a2416")
  s:rect(58, 17, 66, 18, "#3a2416")
  s:rect(59, 19, 59, 20, "#3a2416")
  s:ascii({ ".oo.", "oggo", "ogGo", "oggo", ".oo." }, 57, 21, { o = "ol2", g = "#fff1c8", G = "gold" })
  -- gnome facing left holding the rod
  s:gnome(46, 18, { dir = -1, night = 0.82 })
  s:line2(46, 31, 44, 30, C.blue)
  s:line2(44, 30, 32, 14, "#5e3a20")
  s:line(32, 14, 25, 20, "#c8d4ee"); s:line(25, 20, 26, 22, "#c8d4ee")
  s:px(45, 31, C.skin); s:px(45, 32, C.skin)
end



-- snowy pine: apex (x, y), h rows tall, widening by 1 every 2 rows
local function pine(s, x, y, h, snow)
  s:rect(x, y + h, x + 1, y + h + 2, C.woodDD)
  for i = 0, h - 1 do
    local w = i // 2 + 1
    s:rect(x - w + 1, y + i, x + w, y + i, "#2f5a3a")
    s:px(x - w + 1, y + i, "#244a30")
    if snow and i % 3 == 0 then s:rect(x - w + 2, y + i, x + w - 1, y + i, "#e8f0f2") end
  end
end

SCENES.ice_hole = function(s)
  s:bands(5, 5, 67, 27, { "#b4c4d2", "#c0ceda", "#ccd8e2", "#d8e2ea", "#e4ecf0" })
  s:hill(27, 5, 8, 2, "#f0f4f6")
  s:hill(29, 3, 6, 5, "#e4ecf0")
  pine(s, 12, 17, 9, true); pine(s, 20, 20, 7, true); pine(s, 58, 16, 10, true); pine(s, 65, 21, 6, true)
  s:rect(5, 29, 67, 31, "#f0f4f6")                       -- snowy far bank
  s:bands(5, 32, 67, 49, { "#c4dcea", "#c4dcea", "#b8d6e6", "#b8d6e6", "#acd0e2", "#acd0e2" })
  s:line(8, 36, 16, 38, "#e8f4f8"); s:line(46, 34, 56, 36, "#e8f4f8"); s:line(56, 36, 62, 35, "#e8f4f8")
  s:line(10, 46, 18, 44, "#e8f4f8"); s:line(58, 47, 66, 45, "#e8f4f8")
  -- the hole
  s:ell(41, 43, 8, 3.4, "#f0f4f6")
  s:ell(41, 43, 6, 2.4, "#2a5a80")
  s:rect(37, 42, 42, 42, "#3f7aa0"); s:rect(40, 44, 45, 44, "#1f4468")
  -- stool and gnome
  s:rect(19, 40, 20, 46, C.woodDD); s:rect(30, 40, 31, 46, C.woodDD)
  s:rect(18, 38, 32, 40, C.wood); s:rect(18, 38, 32, 38, C.woodL); s:rect(18, 41, 32, 41, C.ol)
  s:gnome(20, 21, { sit = true })
  s:rect(25, 33, 25, 34, C.gold)
  s:rect(22, 31, 31, 31, C.gold); s:rect(22, 32, 31, 32, C.goldD)          -- scarf
  s:rect(20, 31, 21, 35, C.gold); s:rect(20, 36, 21, 36, C.goldD)
  s:rect(28, 36, 34, 37, C.blueD); s:rect(28, 36, 34, 36, C.blue)       -- thigh
  s:rect(33, 38, 34, 43, C.blueD)
  s:rect(33, 44, 37, 45, C.boot); s:rect(33, 46, 37, 46, C.ol2)
  -- arm, short rod, line
  s:line2(30, 33, 34, 32, C.blue); s:px(35, 32, C.skin); s:px(35, 33, C.skin)
  s:line2(35, 32, 41, 27, C.woodDD)
  s:line(42, 28, 41, 42, "#f4eee0")
  s:px(41, 42, C.red)
  -- fish on the ice and snow cap on the hat
  s:ascii({ "..oooo...o.o", ".osssssoosso", "ossdssssssso", ".ossssssoosso", "..oooo...o.o" }, 52, 42, { o = "ol", s = "#7a96b4", d = "ol2" })
  s:rect(55, 44, 58, 44, "#d8e4f0"); s:px(57, 43, "#e0884a")
  s:px(25, 22, C.white); s:px(26, 22, C.white); s:px(26, 23, C.white); s:px(25, 24, C.white)
  for _, p in ipairs({ { 9, 9 }, { 22, 12 }, { 35, 8 }, { 47, 14 }, { 62, 10 }, { 15, 24 }, { 40, 20 }, { 52, 26 }, { 28, 16 }, { 66, 30 }, { 7, 30 }, { 44, 30 }, { 36, 36 }, { 60, 40 } }) do
    s:px(p[1], p[2], C.white)
  end
end

SCENES.skim_stones = function(s)
  daysky(s)
  s:cloud(46, 10, C.white); s:cloud(14, 14, C.white)
  s:hill(26, 4, 6, 1, C.hill); s:hill(28, 3, 9, 6, C.hillL)
  -- trees on the far shore
  for _, x in ipairs({ 10, 17, 54, 62 }) do s:ell(x, 24, 3, 3, C.leaf); s:rect(x, 26, x, 28, C.woodDD) end
  s:rect(5, 29, 67, 40, C.water)
  s:rect(5, 29, 67, 30, C.waterD)
  for _, g in ipairs({ { 8, 34, 6 }, { 20, 38, 5 }, { 56, 36, 7 }, { 62, 32, 3 } }) do s:rect(g[1], g[2], g[1] + g[3], g[2], C.waterL) end
  -- skip ripples, growing nearer
  s:ring(61, 31, 2, 0.8, C.white); s:ring(54, 32, 3.5, 1, C.white); s:ring(46, 33, 5, 1.4, C.white); s:ring(36, 35, 6.5, 1.8, C.white)
  s:px(61, 28, C.white); s:px(54, 29, C.white); s:px(46, 30, C.white)
  -- beach
  s:rect(5, 41, 67, 49, "#d8c8a0")
  s:rect(5, 41, 67, 41, "#c0a878")
  for _, p in ipairs({ { 8, 46 }, { 16, 48 }, { 30, 47 }, { 38, 44 }, { 46, 48 }, { 52, 43 }, { 64, 46 }, { 58, 49 }, { 24, 44 }, { 12, 43 } }) do
    s:rect(p[1], p[2], p[1] + 1, p[2], "#a89868"); s:px(p[1], p[2] - 1, "#e8dcb8")
  end
  -- piles of flat stones, reeds
  s:ell(57, 46, 4, 1.4, C.stoneD); s:ell(57, 45, 3, 1.2, C.stone); s:ell(57, 43, 2, 1, C.stoneL)
  s:ell(27, 47, 3, 1.2, C.stoneD); s:ell(27, 46, 2.5, 1, C.stone)
  s:ell(65, 44, 2.5, 1, C.stone)
  for _, x in ipairs({ 6, 8, 10 }) do s:rect(x, 31, x, 38, C.leaf); s:rect(x, 29, x, 31, "#8a5a32") end
  -- gnome mid-throw, leaning, arm out
  s:gnome(9, 25, {})
  s:line2(18, 37, 26, 35, C.blue); s:px(27, 35, C.skin); s:px(27, 36, C.skin)
  s:line(10, 38, 7, 41, C.blue); s:px(6, 42, C.skin)
  s:rect(29, 34, 31, 35, C.stoneD); s:rect(29, 34, 30, 34, C.stone)
  s:px(33, 33, C.white); s:px(34, 32, C.white)
end

-- lavender / sage / tansy clump, base centred at (x, y)
local function herb(s, x, y, kind)
  s:ell(x, y, 4, 2.6, kind == "sage" and "#6a9a78" or C.leaf)
  s:ell(x - 1, y - 1, 2, 1.4, kind == "sage" and "#9cc4a4" or C.leafL)
  if kind == "lav" then
    for i = -3, 3, 2 do s:rect(x + i, y - 6 + (i % 4 == 0 and 1 or 0), x + i, y - 2, "#9a6ad0"); s:px(x + i, y - 6 + (i % 4 == 0 and 1 or 0), "#c0a0ec") end
  elseif kind == "tansy" then
    for _, d in ipairs({ { -2, -4 }, { 1, -5 }, { 3, -3 }, { -1, -3 } }) do s:rect(x + d[1], y + d[2], x + d[1] + 1, y + d[2] + 1, "#f4d84a") end
  end
end

SCENES.pick_herbs = function(s)
  s:bands(5, 5, 67, 22, { C.sky1, C.sky2, C.sky3, C.sky4 })
  s:cloud(48, 9, C.white)
  s:hill(22, 4, 7, 2, C.hill)
  s:rect(5, 24, 67, 30, C.grassL)
  for x = 6, 67, 4 do                                   -- picket fence
    s:rect(x, 23, x + 2, 31, C.woodL); s:px(x + 1, 22, C.woodL); s:rect(x + 3, 24, x + 3, 31, C.woodD)
  end
  s:rect(5, 26, 67, 26, C.woodD); s:rect(5, 30, 67, 30, C.woodD)
  s:rect(5, 32, 67, 49, C.grass)
  s:rect(5, 32, 67, 32, C.grassD)
  for _, y in ipairs({ 40, 46 }) do s:rect(30, y, 67, y + 1, "#6a4a2a") end
  for i, x in ipairs({ 36, 44, 52, 60 }) do herb(s, x, 39, ({ "lav", "sage", "tansy", "lav" })[i]) end
  for i, x in ipairs({ 34, 42, 50, 58, 66 }) do herb(s, x, 46, ({ "sage", "tansy", "lav", "sage", "tansy" })[i]) end
  -- gnome sniffing a sprig
  s:gnome(10, 25, {})
  s:line2(19, 38, 22, 35, C.blue)
  s:px(23, 35, C.skin); s:px(23, 34, C.skin)
  s:rect(23, 29, 23, 33, C.leaf); s:rect(21, 31, 22, 31, C.leafL); s:rect(24, 30, 25, 30, C.leafL); s:rect(22, 28, 24, 28, "#9a6ad0"); s:rect(23, 27, 23, 27, "#c0a0ec"); s:px(21, 29, "#9a6ad0"); s:px(25, 29, "#9a6ad0")
  s:line(18, 39, 16, 42, C.blue); s:px(15, 42, C.skin)
  -- basket of greens
  s:ell(27, 40, 3, 2, C.leafL); s:px(26, 37, "#9a6ad0"); s:px(28, 38, "#f4d84a"); s:px(30, 38, C.leaf)
  s:ascii({
    ".oooooooo.",
    "owwwwwwwwo",
    "owGwGwGwwo",
    "owwwwwwwwo",
    ".owGwGwwo.",
    "..oooooo..",
  }, 22, 39, { o = "ol", w = "#d9a660", G = "#a8702c" })
  s:ascii({ "o....o", ".o..o.", "..oo.." }, 24, 37, { o = "ol" })  -- handle ends
end

SCENES.herb_tea = function(s)
  s:bands(5, 5, 67, 26, { C.sky1, C.sky2, C.sky3, C.sky4 })
  s:hill(26, 4, 7, 3, C.hill)
  s:rect(5, 27, 67, 49, C.grass)
  -- blossom tree
  s:rect(11, 18, 12, 34, C.woodDD); s:rect(11, 18, 11, 34, C.woodD)
  s:ell(11, 14, 7, 6, "#f6b8cf"); s:ell(7, 17, 4, 3, "#f6b8cf"); s:ell(16, 17, 4, 3, "#f6b8cf")
  for _, p in ipairs({ { 8, 12 }, { 13, 10 }, { 15, 15 }, { 6, 17 }, { 11, 16 }, { 17, 18 } }) do s:rect(p[1], p[2], p[1] + 1, p[2], "#e46a9b") end
  for _, p in ipairs({ { 20, 24 }, { 24, 30 }, { 7, 28 }, { 15, 31 } }) do s:px(p[1], p[2], "#f6b8cf") end
  -- hedge with white flowers
  s:rect(44, 22, 67, 33, "#3e7a38"); s:rect(44, 22, 67, 23, C.leaf)
  for _, p in ipairs({ { 56, 29 }, { 62, 25 }, { 65, 30 }, { 52, 31 } }) do s:rect(p[1], p[2], p[1] + 1, p[2] + 1, C.white) end
  -- table
  s:rect(18, 49, 20, 49, C.ol)
  s:rect(19, 40, 21, 48, C.woodDD); s:rect(51, 40, 53, 48, C.woodDD)
  s:ell(36, 38, 24, 4.2, C.woodD); s:ell(36, 37, 24, 3.6, C.wood); s:ell(36, 36, 22, 2.6, C.woodL)
  s:rect(13, 39, 59, 40, C.woodD)
  -- gnome (front view) behind the table
  s:gnome(31, 17, { front = true })
  s:rect(27, 31, 29, 34, C.blue); s:rect(26, 34, 29, 35, C.skin)    -- left arm resting
  s:line2(42, 33, 45, 29, C.blue); s:rect(45, 27, 46, 28, C.skin)   -- right arm lifting the cup
  -- thimble cup in hand and steam
  s:ascii({ "owwwwwoo.", "owtttwo.o", "owwwwwo.o", ".owwwwoo.", "..ooooo.." }, 44, 23, { o = "ol", w = "white", t = "#7a9a3a" })
  s:px(46, 21, C.white); s:px(47, 20, C.white); s:px(46, 19, C.white); s:px(47, 18, C.white); s:px(49, 21, C.white); s:px(50, 20, C.white); s:px(49, 19, C.white)
  -- teapot
  s:ell(21, 33, 4.5, 3.5, "#f4eee0"); s:ring(21, 33, 4.5, 3.5, C.ol)
  s:rect(18, 32, 24, 32, C.blue); s:rect(19, 29, 22, 29, C.ol); s:rect(19, 30, 22, 30, "#f4eee0")
  s:px(20, 28, C.red); s:px(21, 28, C.red)
  s:line(16, 31, 14, 29, C.ol); s:line(26, 33, 28, 31, C.ol); s:rect(26, 31, 27, 33, C.ol)
  s:rect(14, 28, 15, 29, "#f4eee0")
  s:px(21, 26, C.white); s:px(22, 25, C.white); s:px(21, 24, C.white); s:px(20, 23, C.white); s:px(21, 22, C.white)
  -- sprig of mint on the table
  s:ell(53, 35, 2, 1, C.leaf); s:px(55, 34, C.leafL); s:px(51, 34, C.leafL)
  s:ell(31, 36, 3, 1, C.white); s:px(31, 35, "#7a9a3a")
end


SCENES.drying_day = function(s)
  s:bands(5, 5, 67, 29, { "#9fd2e8", "#b2dcea", "#c8e8e6", "#dcf0d8", "#ecf4c8" })
  -- big hot sun with rays
  s:ell(57, 13, 5, 5, C.gold); s:ell(56, 12, 3, 3, "#ffe27a")
  for _, r in ipairs({ { 57, 5, 57, 6 }, { 57, 20, 57, 21 }, { 48, 13, 49, 13 }, { 65, 13, 66, 13 }, { 51, 7, 52, 8 }, { 62, 8, 63, 7 }, { 51, 19, 52, 18 }, { 62, 18, 63, 19 } }) do s:line(r[1], r[2], r[3], r[4], C.gold) end
  -- wind streaks
  s:line(10, 9, 22, 9, C.white); s:line(22, 9, 24, 11, C.white); s:line(30, 14, 40, 14, C.white); s:line(40, 14, 42, 12, C.white)
  s:hill(29, 4, 7, 1, C.hill)
  for _, x in ipairs({ 12, 20, 30, 38, 58, 65 }) do s:rect(x, 29, x, 31, C.woodDD); s:ell(x, 27, 3, 3, C.leaf); s:px(x - 1, 26, C.leafL) end
  s:rect(5, 32, 67, 49, C.grass); s:rect(5, 32, 67, 32, C.grassD)
  -- straw mat under the rack
  s:rect(8, 41, 47, 47, "#d8b868"); s:rect(8, 41, 47, 41, "#b89848")
  for x = 12, 47, 6 do s:rect(x, 42, x, 47, "#c8a858") end
  -- rack
  s:rect(8, 18, 9, 44, C.woodD); s:rect(44, 18, 45, 44, C.woodD); s:rect(8, 18, 8, 44, C.wood); s:rect(44, 18, 44, 44, C.wood)
  s:rect(7, 17, 47, 19, C.wood); s:rect(7, 17, 47, 17, C.woodL); s:rect(7, 20, 47, 20, C.ol)
  s:line(9, 28, 14, 20, C.woodD); s:line(44, 28, 39, 20, C.woodD)
  local cols = { { "#7ab55c", "#4e8a3c" }, { "#9a78c8", "#6a48a0" }, { "#e8c85a", "#c89a2a" }, { "#e46a9b", "#b0406a" }, { "#9ab07a", "#6a8858" }, { "#d0583a", "#8e2e1e" }, { "#7ab55c", "#4e8a3c" } }
  for i, c in ipairs(cols) do
    local x = 11 + (i - 1) * 5
    s:rect(x + 1, 21, x + 2, 22, C.red)
    s:poly({ { x, 23 }, { x + 4, 23 }, { x + 4, 30 }, { x + 2, 33 }, { x, 30 } }, c[1])
    s:rect(x + 3, 24, x + 3, 30, c[2]); s:px(x + 1, 25, C.white)
    s:px(x + 1, 31, c[2])
  end
  -- gnome reaching up with the last bundle
  s:gnome(50, 26, { dir = -1 })
  s:line2(52, 36, 49, 31, C.blue); s:line2(49, 31, 47, 26, C.blue); s:rect(46, 24, 47, 25, C.skin)
  s:rect(46, 21, 50, 22, C.red); s:poly({ { 46, 23 }, { 51, 23 }, { 51, 28 }, { 49, 31 }, { 46, 28 } }, "#f0a050"); s:rect(50, 24, 50, 28, "#c07828")
  s:line(60, 37, 62, 40, C.blue); s:px(62, 41, C.skin)
  -- basket of cut herbs
  s:ascii({ ".oooooooo.", "owGwGwGwwo", "owwwwwwwwo", ".owGwGwwo.", "..oooooo.." }, 12, 41, { o = "ol", w = "#d9a660", G = "#a8702c" })
  s:ell(16, 40, 4, 2, "#7ab55c"); s:px(14, 38, "#9a78c8"); s:px(18, 38, "#e8c85a")
end

SCENES.mushroom_rain = function(s)
  s:bands(5, 5, 67, 24, { "#8a9aa8", "#96a6b2", "#a2b0ba", "#aebac2" })
  s:rect(5, 24, 67, 34, "#4e7a58"); s:hill(26, 5, 8, 4, "#4e7a58")
  -- dark trees
  for _, x in ipairs({ 8, 24, 48, 62 }) do
    s:rect(x, 14, x + 2, 36, "#3a2a1c"); s:rect(x, 14, x, 36, "#54402c")
    s:ell(x + 1, 11, 7, 6, "#2f5a3a"); s:ell(x - 2, 14, 4, 3, "#2f5a3a"); s:ell(x + 4, 15, 4, 3, "#356a40")
  end
  s:rect(5, 33, 67, 49, "#5e8a56"); s:rect(5, 33, 67, 33, "#4a7a48")
  s:bands(5, 40, 67, 49, { "#558050", "#4e7a4a", "#4a7646" })
  -- puddle
  s:ell(22, 46, 9, 2.4, "#7a9cb4"); s:ell(22, 46, 7, 1.6, "#9ab8cc"); s:ring(26, 46, 2.5, 0.8, "#d6e4ec")
  -- toadstools: red with white spots, and brown ones
  local function toad(x, y, r, capc, dots)
    s:rect(x - 1, y - 1, x + 1, y + 3, "#e8dcc0")
    s:ell(x, y - 2, r, r * 0.7, capc); s:rect(x - r, y - 1, x + r, y - 1, L.dim(capc, 0.75))
    if dots then s:px(x - 1, y - 3, C.white); s:px(x + 2, y - 2, C.white); s:px(x, y - 4, C.white) end
  end
  toad(10, 42, 4, "#c8382a", true); toad(17, 44, 3, "#c8382a", true); toad(8, 47, 3, "#b88a52", false); toad(47, 36, 2, "#b88a52", false)
  toad(35, 47, 3, "#c8382a", true); toad(60, 47, 3, "#b88a52", false)
  -- rain
  local rx = { 8, 18, 28, 38, 48, 58, 65 }
  for r = 0, 4 do for i, x in ipairs(rx) do
    local y = 6 + r * 9 + ((i * 3) % 6)
    local xx = x + ((r % 2) * 3)
    if not (xx > 31 and xx < 48 and y > 20 and y < 44) then s:line(xx, y, xx - 1, y + 2, "#d0dfe8") end
  end end
  -- gnome: holds a big mushroom up, basket on the arm
  s:gnome(34, 25, { dir = -1 })
  s:line2(35, 37, 29, 31, C.blue); s:rect(27, 29, 28, 30, C.skin)
  s:rect(26, 25, 28, 28, "#e8dcc0"); s:ell(27, 24, 5, 3, "#b88a52"); s:rect(22, 25, 32, 25, "#8e6a3a"); s:px(25, 23, "#d8b078"); s:px(28, 22, "#d8b078")
  s:line(46, 37, 49, 40, C.blue); s:px(50, 40, C.skin)
  s:ascii({ ".oooooooo.", "owGwGwGwwo", "owwwwwwwwo", ".owGwGwwo.", "..oooooo.." }, 49, 39, { o = "ol", w = "#d9a660", G = "#a8702c" })
  s:ell(52, 38, 2, 1.5, "#c8382a"); s:px(51, 37, C.white); s:ell(56, 38, 2, 1.5, "#b88a52")
  for _, p in ipairs({ { 41, 30 }, { 46, 22 }, { 56, 28 }, { 62, 40 } }) do s:line(p[1], p[2], p[1] - 1, p[2] + 2, "#dce8f0") end
end

SCENES.tinker = function(s)
  -- wooden workshop wall
  s:rect(5, 5, 67, 36, "#c9945a")
  for x = 5, 67, 7 do s:rect(x, 5, x, 36, "#a06a3a") end
  s:rect(5, 5, 67, 6, "#8a5a32")
  -- window
  s:rect(56, 9, 66, 20, C.ol); s:rect(57, 10, 65, 19, "#a8d4e0"); s:rect(57, 10, 65, 13, "#bcdde4"); s:rect(61, 10, 61, 19, C.ol); s:rect(57, 15, 65, 15, C.ol)
  s:px(58, 11, C.white); s:px(59, 11, C.white)
  -- pegboard with tools
  s:rect(7, 9, 24, 26, "#a87a48"); s:rect(7, 9, 24, 9, C.ol); s:rect(7, 26, 24, 26, C.ol); s:rect(7, 9, 7, 26, C.ol); s:rect(24, 9, 24, 26, C.ol)
  s:rect(10, 12, 10, 21, C.woodDD); s:rect(9, 11, 12, 12, C.stoneD)        -- hammer
  s:ring(16, 14, 2.5, 2.5, C.stoneD); s:rect(16, 16, 16, 22, C.stoneD)    -- spanner
  s:rect(20, 11, 20, 20, C.stone); s:rect(19, 20, 21, 23, C.red)           -- screwdriver
  s:ell(13, 24, 1.5, 1.5, C.goldD)
  -- bench
  s:rect(5, 36, 67, 38, C.woodL); s:rect(5, 36, 67, 36, "#f0cf90"); s:rect(5, 39, 67, 39, C.ol)
  s:rect(5, 40, 67, 49, C.woodDD); s:rect(5, 40, 67, 40, C.woodD)
  s:rect(10, 42, 24, 48, C.woodD); s:rect(10, 42, 24, 42, C.ol); s:rect(15, 45, 19, 45, C.gold)
  -- the clock with its back open
  s:ell(26, 28, 8, 8, C.goldD); s:ell(26, 28, 7, 7, C.gold)
  s:ell(26, 28, 5.5, 5.5, "#3a2a1c")
  for y = 22, 34 do for x = 20, 26 do if (x - 26) ^ 2 + (y - 28) ^ 2 <= 28 then s:px(x, y, "#f4eee0") end end end
  s:px(21, 28, C.ol); s:px(26, 23, C.ol); s:px(26, 33, C.ol); s:px(23, 24, C.ol); s:px(23, 32, C.ol)
  s:line(26, 28, 26, 24, C.red); s:line(26, 28, 23, 29, C.ol)
  s:ell(30, 27, 2.5, 2.5, C.stone); s:px(30, 27, "#3a2a1c"); s:px(30, 24, C.stone); s:px(33, 27, C.stone); s:px(30, 30, C.stone)
  s:ell(30, 32, 1.5, 1.5, C.gold); s:px(30, 32, "#3a2a1c")
  s:rect(21, 36, 23, 36, C.woodDD); s:rect(29, 36, 31, 36, C.woodDD)
  -- springs bouncing out
  for i = 0, 5 do s:rect(34 + (i % 2) * 2, 15 + i, 36 + (i % 2) * 2, 15 + i, C.stoneL) end
  s:px(33, 14, "#fff1c8"); s:px(38, 13, "#fff1c8"); s:px(40, 18, "#fff1c8")
  for i = 0, 3 do s:rect(41 + (i % 2), 31 + i, 42 + (i % 2), 31 + i, C.stoneL) end
  s:ell(15, 34, 2, 2, C.goldD); s:px(15, 34, "#3a2a1c")
  -- gnome behind the bench with a tiny screwdriver
  s:gnome(46, 19, { dir = -1 })
  s:line2(47, 31, 41, 30, C.blue); s:px(40, 30, C.skin); s:px(40, 31, C.skin)
  s:line(39, 30, 35, 24, C.stone); s:px(34, 23, C.red)
end

SCENES.saw_planks = function(s)
  daysky(s)
  s:cloud(40, 11, C.white); s:cloud(18, 8, C.white)
  s:hill(25, 4, 6, 4, C.hill)
  -- shed behind on the right
  s:rect(44, 18, 67, 33, C.wood)
  for x = 44, 67, 4 do s:rect(x, 18, x, 33, C.woodD) end
  s:poly({ { 41, 19 }, { 67, 19 }, { 67, 11 }, { 56, 8 } }, "#a8582f"); s:rect(41, 19, 67, 19, C.ol)
  for x = 44, 66, 4 do s:line(x, 19, x + 2, 12, "#8a4f2a") end
  s:rect(52, 24, 58, 33, "#3a2416")
  -- stacked log ends on the left
  for _, p in ipairs({ { 8, 31 }, { 14, 31 }, { 11, 26 } }) do
    s:ell(p[1], p[2], 3, 3, C.woodD); s:ell(p[1], p[2], 2, 2, "#e0b070"); s:px(p[1], p[2], C.woodD)
  end
  s:rect(5, 34, 67, 49, "#b89868"); s:rect(5, 34, 67, 34, "#a08050")
  s:rect(5, 41, 67, 49, "#a98c5c")
  for _, p in ipairs({ { 8, 44 }, { 30, 47 }, { 20, 43 }, { 40, 48 } }) do s:rect(p[1], p[2], p[1] + 2, p[2], "#d8c090") end
  -- sawhorses and the log
  for _, x in ipairs({ 34, 54 }) do s:line2(x - 3, 47, x, 38, C.woodDD); s:line2(x + 3, 47, x, 38, C.woodDD) end
  s:rect(30, 34, 58, 40, "#8a4f2a"); s:rect(30, 34, 58, 34, "#b07a45"); s:rect(30, 41, 58, 41, C.ol); s:rect(30, 33, 58, 33, C.ol)
  s:ell(58, 37, 2, 3.6, "#e0b070"); s:ring(58, 37, 2, 3.6, C.ol); s:px(58, 37, "#a06a3a"); s:px(57, 36, "#c08a52")
  s:line(34, 36, 38, 36, "#6a3a1c"); s:line(50, 38, 54, 38, "#6a3a1c")
  -- the cut and the saw
  s:rect(44, 34, 45, 40, "#3a2416")
  s:line2(34, 27, 46, 35, C.stoneL); s:line(34, 29, 46, 37, C.stone)
  s:rect(31, 24, 34, 28, C.red); s:rect(31, 24, 31, 28, "#e0583a")
  -- sawdust
  for _, p in ipairs({ { 42, 31 }, { 46, 30 }, { 48, 33 }, { 40, 34 }, { 47, 42 }, { 43, 44 }, { 49, 32 } }) do s:px(p[1], p[2], "#f0dcb0") end
  -- cut plank on the ground and the stack
  s:rect(48, 44, 56, 45, "#e0b070"); s:rect(48, 44, 56, 44, "#f0cf90"); s:rect(48, 46, 56, 46, C.ol)
  for i = 0, 2 do s:rect(58, 43 + i * 2, 67, 44 + i * 2, "#e0b070"); s:rect(58, 43 + i * 2, 67, 43 + i * 2, "#f0cf90"); s:rect(58, 45 + i * 2, 67, 45 + i * 2, "#a06a3a") end
  s:rect(58, 49, 67, 49, C.ol)
  -- gnome sawing
  s:gnome(16, 24, {})
  s:line2(25, 36, 31, 31, C.blue); s:rect(31, 29, 32, 30, C.skin)
  s:line(17, 38, 15, 41, C.blue); s:px(14, 41, C.skin)
end

SCENES.dress_stone = function(s)
  s.mirror = true                       -- drawn left-to-right, shown flipped: gnome on the right
  daysky(s)
  s:cloud(14, 10, C.white); s:cloud(36, 7, C.white)
  s:hill(26, 5, 6, 2, C.hill)
  -- tower base behind: blocks with a slit and battlements
  s:rect(46, 10, 67, 33, C.stoneL)
  for y = 12, 33, 4 do s:rect(46, y, 67, y, "#a8a49c") end
  for r = 0, 5 do for x = 46 + (r % 2) * 4, 67, 8 do s:rect(x, 11 + r * 4, x, 14 + r * 4, "#a8a49c") end end
  for x = 46, 67, 6 do s:rect(x, 7, x + 3, 10, C.stoneL) end
  s:rect(46, 10, 67, 10, "#a8a49c")
  s:rect(55, 16, 56, 23, "#3a3a46")
  s:rect(46, 10, 46, 33, "#a8a49c")
  s:rect(5, 34, 67, 49, "#b0a078"); s:rect(5, 34, 67, 34, "#9a8a64")
  s:rect(5, 43, 67, 49, "#a09068")
  -- rough block becoming a squared block: front face, lit top, shaded end
  s:poly({ { 50, 32 }, { 55, 29 }, { 55, 41 }, { 50, 44 } }, C.stoneD)
  s:poly({ { 28, 32 }, { 33, 29 }, { 55, 29 }, { 50, 32 } }, C.stoneL)
  s:rect(28, 32, 50, 44, C.stone)
  s:rect(28, 32, 50, 32, "#d8d4cc")
  for _, p in ipairs({ { 28, 35 }, { 29, 39 }, { 28, 42 } }) do s:rect(p[1], p[2], p[1] + 3, p[2] + 2, C.stoneD) end
  s:rect(31, 36, 33, 37, "#a4a8b0"); s:rect(30, 41, 32, 42, "#a4a8b0")
  s:rect(37, 35, 49, 35, "#a4a8b0"); s:rect(37, 39, 49, 39, "#a4a8b0")
  s:rect(28, 44, 55, 45, C.ol)
  -- dressed block stacked at the far right
  s:rect(56, 40, 66, 46, C.stoneL); s:rect(56, 40, 66, 40, "#e6e2da"); s:rect(56, 44, 66, 44, "#a8a49c"); s:rect(56, 47, 66, 47, C.ol)
  -- gnome with raised hammer and a chisel
  s:gnome(10, 25, {})
  s:line2(19, 36, 22, 28, C.blue); s:rect(22, 26, 23, 27, C.skin)
  s:line(24, 26, 29, 20, C.woodDD); s:line(25, 26, 30, 20, C.woodDD); s:rect(26, 15, 33, 18, C.stoneD); s:rect(26, 15, 33, 15, C.stone)
  s:line2(18, 38, 26, 34, C.blue); s:rect(27, 33, 28, 34, C.skin)
  s:rect(30, 29, 30, 33, C.stoneL); s:px(30, 34, "#fff1c8")
  -- chips and sparks
  for _, p in ipairs({ { 36, 26 }, { 41, 23 }, { 33, 23 } }) do s:rect(p[1], p[2], p[1] + 1, p[2] + 1, C.stoneL) end
  s:px(38, 28, "#fff1c8"); s:px(34, 30, C.gold); s:px(37, 25, C.gold); s:px(31, 28, C.gold)
end

local want = {}
for _, slug in ipairs(ORDER) do if (not ONLY or ONLY == slug) and SCENES[slug] then want[#want+1] = slug end end
for _, slug in ipairs(want) do
  local s = L.new()
  SCENES[slug](s)
  s:save(slug, OUT, ASE)
end
