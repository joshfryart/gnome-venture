-- gsmall.lua: Gather page small art. Param: name=<picture name> (or all)
-- slot-*, vig-*, flourish-*, badge-*, felt-*, ribbon-*   -> out/<name>.png/.aseprite
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, abs, pi = math.floor, math.max, math.min, math.sin, math.cos, math.abs, math.pi
local INK = "#2b1c26"
local CREAM = "#fff4d6"
local P = HP.P
local mix = GX.mix
local R = {
  wood = P.wood, gold = P.gold, moss = P.moss, sea = P.sea, stone = P.stone, ember = P.ember, petal = P.petal, dusk = P.dusk, sky = P.sky,
  straw = { hi = "#f8dc92", base = "#dba65c", shade = "#a8733c", deep = "#6b4428" },
  olive = { hi = "#c2cf84", base = "#93ab5c", shade = "#63804a", deep = "#3b5238" },
  crys  = { hi = "#d2f0ff", base = "#74b8f2", shade = "#4180d2", deep = "#2a4a7a" },
  felt  = { hi = "#f8d99a", base = "#e2a65f", shade = "#bb7c40", deep = "#7a4a2a" },
  dirt  = { hi = "#c99a68", base = "#9a6a44", shade = "#6e4630", deep = "#472c28" },
  leather = { hi = "#a8683e", base = "#7e4a2e", shade = "#5e3626", deep = "#3a2220" },
  iron  = { hi = "#b9b8c6", base = "#8a8a9e", shade = "#5c5d78", deep = "#3a3b55" },
}
local c
local function hs(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.7) * 43758.5453 return v - floor(v) end
local function put(x, y, col) c:put(x, y, col) end

-- shaded fill, light from upper left
local function fillm(m, r)
  local big = m:count() > 260
  m:each(function(x, y)
    local t = r.base
    if not m:has(x + 1, y + 1) or (big and not m:has(x + 2, y + 2)) then t = r.shade
    elseif not m:has(x - 1, y - 1) or (big and not m:has(x - 2, y - 2) and hs(x, y, 3) > .3) then t = r.hi end
    put(x, y, t)
  end)
end
local function obj(m, r) c:rim(m, INK); fillm(m, r); return m end
local function ring(cx, cy, rx, ry, t) return HP.ellipse(cx, cy, rx, ry):cut(HP.ellipse(cx, cy, rx - t, ry - t)) end
local function clipy(m, y0, y1) local n = HP.mask() m:each(function(x, y) if y >= y0 and y <= y1 then n:set(x, y) end end) return n end
local function ln(pts, w) return HP.line(pts, w) end
local function rot(pts, a, ox, oy)
  local o = {}
  for i, p in ipairs(pts) do o[i] = { ox + p[1] * cos(a) - p[2] * sin(a), oy + p[1] * sin(a) + p[2] * cos(a) } end
  return o
end
local function leafm(x, y, a, len, wid) return HP.poly(rot({ {0,0}, {len * .35, -wid}, {len, 0}, {len * .35, wid} }, a, x, y)) end
local function starm(cx, cy, r, ri)
  local pts = {}
  for i = 0, 9 do local a = -pi / 2 + i * pi / 5; local rr = (i % 2 == 0) and r or (ri or r * .45); pts[#pts + 1] = { cx + rr * cos(a), cy + rr * sin(a) } end
  return HP.poly(pts)
end
local function spark(x, y, col) put(x, y, col); put(x - 1, y, col); put(x + 1, y, col); put(x, y - 1, col); put(x, y + 1, col) end
local function stitchRect(x0, y0, x1, y1, col, on, off)
  on, off = on or 2, off or 1
  local function run(a, b, f) local i = a while i <= b do for k = 0, on - 1 do if i + k <= b then f(i + k) end end i = i + on + off end end
  run(x0, x1, function(x) put(x, y0, col) put(x, y1, col) end)
  run(y0 + 1, y1 - 1, function(y) put(x0, y, col) put(x1, y, col) end)
end
local L = {}   -- layer list for ornaments
local function lay(m, r) L[#L + 1] = { m, r } end
local function flush() for _, e in ipairs(L) do c:rim(e[1], INK) end for _, e in ipairs(L) do fillm(e[1], e[2]) end L = {} end

---------------------------------------------------------------- slots (48x48)
local function slotBase(dark)
  local m = HP.rrect(1, 1, 46, 46, 6)
  c:rim(m, INK)
  local lr = dark and { hi = R.leather.shade, base = R.leather.deep, shade = "#2f1c1c", deep = INK } or R.leather
  fillm(m, lr)
  local inner = HP.rrect(5, 5, 42, 42, 4)
  inner:each(function(x, y)
    local t = dark and "#4a2c27" or mix(R.wood.base, R.wood.hi, .22)
    if hs(x, y, 1) > .93 then t = dark and "#3f2623" or R.wood.base end
    if not inner:has(x, y - 1) or not inner:has(x - 1, y) then t = dark and "#2f1c1c" or R.wood.deep      -- inset shadow top/left
    elseif not inner:has(x, y + 1) or not inner:has(x + 1, y) then t = dark and "#5e3c33" or R.wood.hi end
    put(x, y, t)
  end)
  stitchRect(3, 3, 44, 44, R.gold.base, 3, 2)
end
local S = {}
function S.axe()
  slotBase()
  obj(ln({ {13, 41}, {31, 12} }, 4), R.wood)
  obj(ln({ {15, 38}, {18, 33} }, 4), R.ember)
  obj(HP.poly({ {25, 8}, {33, 5}, {41, 8}, {41, 22}, {33, 24}, {29, 18} }), R.stone)
  put(40, 10, CREAM); put(40, 11, CREAM); put(40, 12, CREAM)
end
function S.pick()
  slotBase()
  obj(ln({ {14, 42}, {30, 15} }, 4), R.wood)
  obj(HP.poly({ {6, 20}, {13, 10}, {24, 6}, {35, 8}, {42, 17}, {38, 18}, {33, 13}, {24, 11}, {15, 14}, {10, 23} }), R.iron)
  obj(ln({ {27, 16}, {31, 14} }, 4), R.stone)
end
function S.rod()
  slotBase()
  obj(ln({ {9, 42}, {36, 8} }, 3), R.wood)
  obj(ln({ {14, 36}, {17, 32} }, 3), R.ember)
  for y = 9, 30 do put(37, y, CREAM) end
  obj(HP.ellipse(37, 33, 3, 3), R.ember)
  put(36, 32, CREAM); put(37, 32, CREAM)
  put(37, 38, INK); put(38, 39, INK); put(37, 40, INK); put(36, 39, INK)
end
function S.net()
  slotBase()
  obj(ln({ {11, 42}, {27, 24} }, 3), R.wood)
  local rm = ring(31, 17, 10, 11, 3)
  local mesh = HP.ellipse(31, 17, 8, 9)
  c:rim(HP.ellipse(31, 17, 10, 11), INK)
  mesh:each(function(x, y) put(x, y, ((x + y) % 3 == 0) and R.straw.shade or CREAM) end)
  fillm(rm, R.wood)
end
function S.bucket()
  slotBase()
  local hd = clipy(ring(24, 17, 13, 13, 3), 0, 19)
  obj(hd, R.stone)
  local body = HP.poly({ {10, 19}, {38, 19}, {35, 41}, {13, 41} })
  obj(body, R.sea)
  body:each(function(x, y) if y == 25 or y == 26 or y == 35 or y == 36 then put(x, y, R.stone.base) end end)
  obj(HP.ellipse(24, 19, 14, 3), R.stone)
  HP.ellipse(24, 19, 11, 2):each(function(x, y) put(x, y, y == 18 and R.sea.hi or R.sea.shade) end)
end
function S.basket()
  slotBase()
  obj(clipy(ring(24, 23, 14, 15, 3), 0, 22), R.wood)
  local body = HP.poly({ {9, 24}, {39, 24}, {35, 41}, {13, 41} })
  obj(body, R.straw)
  body:each(function(x, y) if y > 26 and ((floor(x / 3) + floor(y / 3)) % 2 == 0) then put(x, y, R.straw.shade) end end)
  obj(HP.rrect(7, 21, 40, 25, 2), R.straw)
  obj(HP.ellipse(18, 19, 3, 3), R.ember); obj(HP.ellipse(27, 18, 3, 3), R.gold); put(17, 18, CREAM)
  obj(leafm(21, 20, -.6, 8, 3), R.moss)
end
function S.forage()
  slotBase()
  obj(ln({ {12, 41}, {21, 29} }, 5), R.wood)
  obj(HP.rect(18, 27, 24, 29), R.gold)
  obj(HP.poly({ {21, 27}, {32, 6}, {38, 9}, {38, 18}, {29, 28} }), R.iron)
  obj(HP.rect(32, 36, 35, 41), { hi = CREAM, base = "#f0dcb4", shade = "#c9b08a", deep = R.wood.deep })
  obj(HP.ellipse(33.5, 35, 6, 4), R.ember)
  put(31, 33, CREAM); put(35, 35, CREAM); put(33, 31, CREAM)
end
function S.locked()
  slotBase(true)
  obj(clipy(ring(24, 17, 9, 10, 4), 0, 22), R.iron)
  obj(HP.rrect(12, 21, 35, 41, 3), R.gold)
  c:fillMask(HP.ellipse(23.5, 29, 2, 2), INK)
  c:fillMask(HP.rect(23, 30, 24, 35), INK)
end

---------------------------------------------------------------- vignettes (144x108)
local function hill(base, amp, f, ph, col, bottom)
  for x = 0, 143 do
    local y0 = floor(base + amp * sin(x * f + ph) + amp * .4 * sin(x * f * 2.3 + ph * 2))
    for y = y0, bottom do put(x, y, col) end
  end
end
local function sky(cols, ys)
  for y = 0, 107 do
    local col = cols[#cols]
    for i, yy in ipairs(ys) do if y < yy then col = cols[i] break end end
    put(0, y, col)
    for x = 0, 143 do put(x, y, col) end
  end
end
local function cloud(x, y, w) for i = 0, 2 do c:fillMask(HP.ellipse(x + i * w / 3, y - (i == 1 and 3 or 0), w / 3, 3), "#fff4e0") end end
local function grass(y0, y1, base, dark, hi, seed)
  for y = y0, y1 do for x = 0, 143 do
    local t = base
    local h = hs(x, y, seed)
    if h > .96 then t = hi elseif h < .05 then t = dark end
    put(x, y, t)
  end end
  for x = 3, 140, 9 do local y = y0 + 3 + floor(hs(x, 1, seed) * (y1 - y0 - 6)); put(x, y, dark); put(x, y - 1, hi); put(x + 2, y, dark); put(x + 2, y - 1, hi) end
end
local function frame()
  for y = 0, 107 do for x = 0, 143 do
    local e = min(x, y, 143 - x, 107 - y)
    if e == 0 or e == 3 then put(x, y, INK)
    elseif e == 1 then put(x, y, (x < 72 and y < 54) and R.wood.hi or R.wood.base)
    elseif e == 2 then put(x, y, R.wood.shade) end
  end end
end
local function tree(cx, y, h, col, trunk)
  c:fillMask(HP.rect(cx - 2, y - h * .45, cx + 1, y), trunk)
  c:fillMask(HP.ellipse(cx, y - h * .7, h * .32, h * .38), col)
end
local function bird(x, y)   -- robin
  obj(HP.ellipse(x, y, 5, 4), R.ember)
  c:fillMask(HP.ellipse(x - 1, y - 1, 4, 3), "#7a5a48")
  c:fillMask(HP.ellipse(x + 2, y + 1, 2, 2), R.ember.hi)
  obj(HP.ellipse(x - 4, y - 4, 3, 3), "#7a5a48" and { hi = "#a08068", base = "#7a5a48", shade = "#5a4034", deep = INK })
  put(x - 5, y - 5, INK); put(x - 8, y - 4, R.gold.base); put(x - 7, y - 4, R.gold.base)
  put(x + 5, y - 1, "#5a4034"); put(x + 6, y, "#5a4034")
end
function S.vigaxe()
  sky({ "#bfe6ee", "#d4f0e8", "#e7f6e0" }, { 22, 42 })
  cloud(26, 16, 24)
  hill(46, 4, .05, 1, "#7fb890", 70)
  for i, x in ipairs({ 12, 36, 62, 92, 126 }) do tree(x, 62 + (i % 2) * 3, 34 + (i % 3) * 5, (i % 2 == 0) and "#4f9a58" or "#3f8650", "#6a4a38") end
  grass(62, 106, R.moss.base, R.moss.shade, R.moss.hi, 5)
  -- log
  c:rim(HP.rrect(34, 70, 120, 94, 9), INK)
  local body = HP.rrect(34, 70, 120, 94, 9)
  fillm(body, R.wood)
  body:each(function(x, y) if x > 44 and (x % 6 == 2) and hs(x, y, 2) > .35 then put(x, y, R.wood.shade) end end)
  local endg = HP.ellipse(40, 82, 7, 12)
  obj(endg, { hi = "#f4d8a8", base = "#e8b982", shade = "#c98f5c", deep = R.wood.deep })
  ring(40, 82, 4, 8, 1):each(function(x, y) put(x, y, "#c98f5c") end)
  put(40, 82, R.wood.shade)
  -- axe stuck in top
  obj(ln({ {104, 22}, {86, 66} }, 4), R.wood)
  obj(HP.poly({ {76, 56}, {91, 54}, {94, 70}, {80, 72} }), R.iron)
  c:fillMask(ln({ {78, 71}, {94, 70} }, 1), INK)
  -- chips
  obj(HP.poly({ {66, 56}, {71, 52}, {72, 57} }), R.wood)
  obj(HP.poly({ {100, 56}, {105, 60}, {99, 62} }), R.wood)
  bird(105, 20)
  -- tuft
  put(26, 98, R.moss.deep); put(27, 97, R.moss.deep); put(124, 100, R.moss.deep); put(125, 99, R.moss.deep)
  frame()
end
function S.vigbucket()
  sky({ "#9fd4e8", "#c4e8f0", "#f0f0d4" }, { 20, 40 })
  cloud(104, 14, 22)
  hill(44, 5, .04, 2, "#7ab88a", 66)
  hill(54, 4, .07, 0, "#5fa070", 70)
  grass(66, 106, R.moss.base, R.moss.shade, R.moss.hi, 8)
  -- pond
  local pond = HP.ellipse(98, 86, 40, 17)
  c:rim(pond, INK)
  pond:each(function(x, y)
    local t = (y < 80) and R.sea.shade or R.sea.base
    if y % 5 == 0 and hs(x, y, 4) > .5 then t = R.sea.hi end
    put(x, y, t)
  end)
  -- lily pad + frog
  obj(HP.ellipse(104, 88, 11, 4), R.moss)
  c:fillMask(HP.poly({ {104, 88}, {116, 85}, {116, 90} }), R.sea.base)
  obj(HP.ellipse(103, 84, 5, 4), { hi = "#d6f08a", base = "#8fd24f", shade = "#4aa04c", deep = "#24544a" })
  obj(HP.ellipse(100, 80, 2, 2), { hi = "#d6f08a", base = "#8fd24f", shade = "#4aa04c", deep = "#24544a" })
  obj(HP.ellipse(106, 80, 2, 2), { hi = "#d6f08a", base = "#8fd24f", shade = "#4aa04c", deep = "#24544a" })
  put(100, 80, INK); put(106, 80, INK); put(104, 85, R.ember.base); put(103, 85, R.ember.base)
  -- reeds
  for _, x in ipairs({ 58, 62, 66 }) do c:fillMask(ln({ {x, 76}, {x + (x - 62) // 2, 56} }, 1), R.moss.deep); obj(HP.rect(x - 1 + (x - 62) // 2, 52, x + (x - 62) // 2, 57), R.wood) end
  -- bucket on the bank with rope + drops
  local hd = clipy(ring(34, 60, 15, 14, 2), 0, 62)
  obj(hd, R.iron)
  local body = HP.poly({ {17, 62}, {51, 62}, {47, 90}, {21, 90} })
  obj(body, R.wood)
  body:each(function(x, y) if y == 70 or y == 71 or y == 82 or y == 83 then put(x, y, R.iron.base) end end)
  obj(HP.ellipse(34, 62, 17, 4), R.iron)
  HP.ellipse(34, 62, 14, 3):each(function(x, y) put(x, y, y < 62 and R.sea.hi or R.sea.base) end)
  for _, p in ipairs({ {55, 66}, {58, 74}, {54, 80}, {60, 60} }) do obj(HP.ellipse(p[1], p[2], 1, 2), R.sea) end
  c:fillMask(ln({ {52, 90}, {70, 96}, {76, 92} }, 1), R.straw.base)
  frame()
end
local function mushroom(x, y, w, h)   -- base at (x,y)
  obj(HP.rect(x - w // 4, y - h, x + w // 4, y), { hi = CREAM, base = "#f0dcb4", shade = "#c9b08a", deep = R.wood.deep })
  obj(HP.poly({ {x - w // 2, y - h + 3}, {x - w // 3, y - h - w // 2}, {x + w // 3, y - h - w // 2}, {x + w // 2, y - h + 3} }), R.ember)
  put(x - w // 4, y - h - w // 4, CREAM); put(x + w // 6, y - h - w // 3, CREAM); put(x + w // 4 - 1, y - h - w // 8, CREAM)
end
function S.vigforage()
  sky({ "#b4dff0", "#d8efe4", "#f2f2d0" }, { 20, 38 })
  cloud(30, 14, 26)
  hill(42, 5, .05, 3, "#82bc84", 62)
  hill(52, 3, .09, 1, "#5fa56c", 68)
  grass(60, 106, "#6fb85a", "#3f9150", R.moss.hi, 11)
  -- trees back
  for _, x in ipairs({ 16, 128 }) do tree(x, 64, 26, "#3f8650", "#6a4a38") end
  mushroom(98, 96, 18, 14); mushroom(116, 90, 12, 10); mushroom(84, 88, 10, 8)
  -- knife stuck in ground
  obj(ln({ {60, 96}, {66, 78} }, 5), R.wood)
  obj(HP.rect(60, 70, 70, 73), R.gold)
  obj(HP.poly({ {62, 72}, {72, 48}, {78, 52}, {76, 62}, {68, 72} }), R.iron)
  -- snail
  obj(HP.ellipse(26, 94, 8, 3), R.skinA or R.petal)
  obj(HP.ellipse(29, 88, 6, 6), R.gold)
  ring(29, 88, 3, 3, 1):each(function(x, y) put(x, y, R.gold.deep) end)
  put(19, 90, INK); put(21, 90, INK); put(18, 89, R.petal.deep); put(22, 89, R.petal.deep)
  for _, p in ipairs({ {10, 80}, {44, 98}, {132, 100} }) do c:fillMask(HP.ellipse(p[1], p[2], 2, 2), R.petal.base); put(p[1], p[2], R.gold.hi) end
  frame()
end
local function butterfly(x, y, ca, cb)
  obj(HP.ellipse(x - 4, y - 2, 4, 4), ca); obj(HP.ellipse(x + 4, y - 2, 4, 4), ca)
  obj(HP.ellipse(x - 3, y + 3, 3, 3), cb); obj(HP.ellipse(x + 3, y + 3, 3, 3), cb)
  c:fillMask(HP.rect(x, y - 3, x, y + 5), INK)
  put(x - 1, y - 5, INK); put(x + 1, y - 5, INK); put(x - 2, y - 6, INK); put(x + 2, y - 6, INK)
end
function S.vignet()
  sky({ "#8ccaf0", "#b6e2f6", "#e4f6ff" }, { 24, 46 })
  cloud(110, 14, 22); cloud(22, 30, 18)
  hill(52, 5, .04, 1, "#8cc89a", 72)
  grass(66, 106, "#82c85a", "#4aa04c", "#d6f08a", 15)
  for x = 6, 138, 12 do local y = 76 + floor(hs(x, 2, 7) * 26); local col = ({ R.petal.base, R.gold.base, CREAM, R.dusk.hi })[1 + floor(hs(x, 3, 1) * 4)]; put(x, y, col); put(x + 1, y, col); put(x, y + 1, R.moss.deep) end
  -- net: handle in the ground, hoop high
  obj(ln({ {48, 102}, {74, 50} }, 3), R.wood)
  c:rim(HP.ellipse(82, 36, 17, 19), INK)
  HP.ellipse(82, 36, 14, 16):each(function(x, y) put(x, y, ((x + y) % 3 == 0) and R.straw.shade or CREAM) end)
  fillm(ring(82, 36, 17, 19, 3), R.wood)
  obj(HP.rect(72, 52, 76, 56), R.ember)
  butterfly(112, 44, R.petal, R.dusk)
  butterfly(26, 52, R.gold, R.ember)
  butterfly(118, 78, R.sea, R.moss)
  put(40, 88, R.gold.hi)
  frame()
end
function S.vigpick()
  sky({ "#c8c0e8", "#e4cce0", "#f6dcc8" }, { 20, 38 })
  cloud(28, 15, 24)
  hill(46, 5, .05, 4, "#9a90c0", 70)
  grass(70, 106, "#7aa86a", "#4f8460", "#b6d484", 17)
  -- boulder
  local rock = HP.poly({ {64, 100}, {62, 68}, {74, 48}, {94, 36}, {116, 40}, {134, 56}, {138, 100} })
  c:rim(rock, INK)
  rock:each(function(x, y)
    local t = R.stone.base
    if x < 84 and y < 70 then t = R.stone.hi elseif x > 112 or y > 88 then t = R.stone.shade end
    if hs(x, y, 9) > .9 then t = R.stone.shade elseif hs(x, y, 8) > .96 then t = R.stone.hi end
    put(x, y, t)
  end)
  c:fillMask(ln({ {96, 40}, {100, 56}, {94, 66} }, 1), R.stone.deep)
  c:fillMask(ln({ {120, 60}, {112, 78} }, 1), R.stone.deep)
  for _, p in ipairs({ {104, 76}, {124, 88}, {82, 86} }) do obj(HP.poly({ {p[1], p[2] - 6}, {p[1] + 4, p[2]}, {p[1], p[2] + 5}, {p[1] - 4, p[2]} }), R.sea) end
  -- pick embedded
  obj(ln({ {20, 20}, {82, 58} }, 4), R.wood)
  obj(HP.poly({ {72, 40}, {86, 42}, {96, 60}, {92, 62}, {84, 50}, {70, 48} }), R.iron)
  spark(90, 46, R.gold.hi); spark(98, 58, CREAM); put(76, 36, R.gold.base); put(104, 50, R.gold.base)
  -- rubble
  for _, p in ipairs({ {56, 96, 5}, {48, 100, 3}, {144, 98, 4} }) do obj(HP.ellipse(p[1], p[2], p[3], p[3] - 1), R.stone) end
  -- mole on mound
  local mound = HP.ellipse(26, 98, 17, 7)
  obj(mound, R.dirt)
  obj(HP.ellipse(26, 88, 7, 7), { hi = "#7a7488", base = "#5a566c", shade = "#3f3c55", deep = INK })
  obj(HP.ellipse(26, 92, 3, 2), R.petal)
  put(22, 86, CREAM); put(30, 86, CREAM); put(22, 87, INK); put(30, 87, INK)
  obj(HP.rect(15, 91, 18, 94), R.petal)
  obj(HP.rect(34, 91, 37, 94), R.petal)
  frame()
end
function S.vigrod()
  sky({ "#f0a884", "#f8c896", "#fde4b0" }, { 18, 36 })
  c:fillMask(HP.ellipse(112, 34, 11, 11), R.gold.base); c:fillMask(HP.ellipse(110, 32, 8, 8), R.gold.hi)
  hill(46, 4, .05, 2, "#7aa88a", 64)
  hill(54, 3, .08, 1, "#4f8a6e", 66)
  -- pond
  for y = 64, 106 do for x = 0, 143 do
    local t = (y < 80) and R.sea.shade or R.sea.base
    if y % 6 == 0 and hs(x, y, 6) > .55 then t = (y < 80) and R.sea.base or R.sea.hi end
    put(x, y, t)
  end end
  for y = 66, 78, 2 do for x = 100, 124 do if hs(x, y, 3) > .5 then put(x, y, R.gold.hi) end end end   -- sun glints
  -- bank
  local bank = HP.poly({ {0, 70}, {26, 68}, {40, 80}, {46, 96}, {30, 107}, {0, 107} })
  c:rim(bank, INK)
  grass(66, 107, R.moss.base, R.moss.shade, R.moss.hi, 21)
  bank:each(function(x, y) put(x, y, hs(x, y, 5) > .94 and R.moss.hi or R.moss.base) end)
  fillm(bank, R.moss)
  -- forked stick + rod
  obj(ln({ {22, 90}, {26, 70} }, 3), R.dirt); obj(ln({ {30, 90}, {26, 70} }, 3), R.dirt)
  obj(ln({ {12, 98}, {70, 22} }, 3), R.wood)
  obj(ln({ {14, 94}, {18, 89} }, 4), R.ember)
  for y = 23, 70 do put(70 + floor((y - 23) * .55), y, CREAM) end
  obj(HP.ellipse(96, 72, 3, 3), R.ember); put(95, 71, CREAM); put(96, 71, CREAM)
  for _, e in ipairs({ {96, 76, 9, 2}, {96, 78, 15, 3} }) do ring(e[1], e[2], e[3], e[4], 1):each(function(x, y) if (x + y) % 2 == 0 then put(x, y, R.sea.hi) end end) end
  -- jumping fish
  obj(HP.poly({ {114, 56}, {124, 50}, {132, 58}, {124, 66} }), { hi = "#ffc890", base = "#f08a4c", shade = "#c85a3c", deep = "#6e2038" })
  obj(HP.poly({ {132, 58}, {140, 52}, {140, 64} }), R.ember)
  put(120, 56, INK); put(119, 56, CREAM)
  for _, p in ipairs({ {112, 70}, {118, 74}, {127, 72} }) do obj(HP.ellipse(p[1], p[2], 1, 1), R.sea) end
  -- lily pad + dragonfly
  obj(HP.ellipse(60, 92, 12, 4), R.moss)
  obj(HP.rect(80, 44, 90, 45), R.sea); put(76, 44, R.sea.deep); put(77, 44, R.sea.deep)
  c:fillMask(HP.ellipse(81, 41, 3, 1), R.sea.hi); c:fillMask(HP.ellipse(86, 41, 3, 1), R.sea.hi)
  frame()
end

---------------------------------------------------------------- flourishes (384x96)
local function mirror()
  for y = 0, 95 do for x = 0, 191 do
    local v = c.pix[y * c.w + x]
    if v then put(383 - x, y, v) end
  end end
end
local function wave(x0, x1, y0, amp, per, ph) local pts = {} for x = x0, x1, 2 do pts[#pts + 1] = { x, y0 + amp * sin((x - x0) / per * 2 * pi + (ph or 0)) } end return pts end
local function at(pts, x) for i = 1, #pts - 1 do if pts[i][1] <= x and pts[i + 1][1] >= x then return pts[i][2] end end return pts[#pts][2] end
local F = {}
function F.common()
  local st = wave(10, 176, 48, 5, 48)
  lay(ln(st, 3), R.wood)
  for i, x in ipairs({ 24, 44, 64, 84, 104, 124, 144, 164 }) do
    local y, up = at(st, x), (i % 2 == 0)
    lay(leafm(x, y, up and -.9 or .9, 14, 5), R.olive)
    lay(leafm(x + 8, y, up and .9 or -.9, 10, 4), R.olive)
  end
  lay(ring(12, 46, 5, 5, 2), R.wood)
  lay(leafm(9, 50, 2.4, 9, 3), R.olive)
  flush(); mirror()
  lay(HP.ellipse(191.5, 48, 9, 9), R.wood); lay(HP.ellipse(191.5, 48, 5, 5), R.straw); flush()
  put(190, 46, CREAM)
end
function F.uncommon()
  local st = wave(10, 176, 48, 9, 60)
  lay(ln(st, 4), R.moss)
  for i, x in ipairs({ 22, 38, 54, 70, 86, 102, 118, 134, 150, 166 }) do
    local y, up = at(st, x), (i % 2 == 0)
    lay(leafm(x, y, up and -1.1 or 1.1, 17, 7), R.moss)
  end
  for _, x in ipairs({ 30, 78, 126 }) do
    local y = at(st, x) + ((x == 78) and 15 or -15)
    lay(ring(x, y, 5, 5, 2), R.olive)
  end
  for _, x in ipairs({ 62, 110, 158 }) do
    local y = at(st, x) - 10
    for k = 0, 4 do local a = k * 2 * pi / 5; lay(HP.ellipse(x + 4 * cos(a), y + 4 * sin(a), 2, 2), R.petal) end
    lay(HP.ellipse(x, y, 2, 2), R.gold)
  end
  lay(ring(12, 46, 5, 5, 2), R.moss)
  flush(); mirror()
  for k = 0, 5 do local a = k * pi / 3 + .3; lay(leafm(191.5, 48, a, 22, 7), R.moss) end
  lay(ring(191.5, 48, 11, 11, 3), R.olive)
  lay(HP.ellipse(191.5, 48, 6, 6), R.gold); flush()
  put(189, 46, R.gold.hi); put(190, 46, R.gold.hi)
end
local function crystal(x, y, a, len, wid, r)
  local m = HP.poly(rot({ {0, 0}, {len * .25, -wid}, {len, 0}, {len * .25, wid} }, a, x, y))
  lay(m, r)
  return m
end
function F.rare()
  local st = wave(10, 176, 48, 4, 40)
  lay(ln(st, 2), R.crys)
  for i, x in ipairs({ 22, 38, 54, 70, 86, 102, 118, 134, 150, 166 }) do
    local y, up = at(st, x), (i % 2 == 0)
    local big = (i % 3 == 0)
    crystal(x, y, up and -pi / 2 + .12 * ((i % 2) * 2 - 1) or pi / 2 - .12, big and 30 or 20, big and 8 or 6, (i % 4 == 1) and R.dusk or R.crys)
  end
  for _, x in ipairs({ 30, 78, 126 }) do lay(ring(x, at(st, x) + ((x == 78) and 11 or -11), 4, 4, 1), R.sea) end
  lay(ring(12, 46, 5, 5, 1), R.sea)
  flush(); mirror()
  crystal(191.5, 48, -pi / 2, 42, 11, R.crys); crystal(191.5, 48, pi / 2, 36, 10, R.crys)
  crystal(185, 52, -pi / 2 - .6, 30, 7, R.sea); crystal(198, 52, -pi / 2 + .6, 30, 7, R.sea)
  crystal(185, 46, pi / 2 + .6, 24, 6, R.dusk); crystal(198, 46, pi / 2 - .6, 24, 6, R.dusk)
  flush()
  for y = 12, 44 do put(191, y, R.crys.hi); put(192, y, R.crys.shade) end
  for _, p in ipairs({ {60, 22}, {110, 74}, {150, 24}, {232, 74}, {274, 22}, {324, 72}, {176, 14}, {207, 80} }) do spark(p[1], p[2], R.crys.hi) end
end
function F.legendary()
  local st = wave(10, 150, 48, 5, 44)
  lay(ln(st, 3), R.gold)
  for i, x in ipairs({ 24, 44, 64, 84, 104, 124 }) do
    local y, up = at(st, x), (i % 2 == 0)
    lay(leafm(x, y, up and -.9 or .9, 14, 5), R.gold)
    lay(HP.poly({ {x + 8, y - 12 * (up and 1 or -1) - 3}, {x + 11, y - 12 * (up and 1 or -1)}, {x + 8, y - 12 * (up and 1 or -1) + 3}, {x + 5, y - 12 * (up and 1 or -1)} }), R.ember)
  end
  lay(ring(12, 46, 5, 5, 2), R.gold)
  for _, p in ipairs({ {150, 22, 4}, {164, 17, 5}, {178, 12, 6} }) do lay(starm(p[1], p[2], p[3]), R.gold) end
  flush(); mirror()
  for k = 0, 15 do
    local a = k * pi / 8
    local long = (k % 2 == 0)
    local r1, r2 = 12, long and 34 or 24
    lay(HP.poly({ {191.5 + 12 * cos(a - .2), 48 + 12 * sin(a - .2)}, {191.5 + r2 * cos(a), 48 + r2 * sin(a)}, {191.5 + 12 * cos(a + .2), 48 + 12 * sin(a + .2)} }), long and R.gold or R.gold)
  end
  lay(HP.ellipse(191.5, 48, 13, 13), R.gold)
  flush()
  c:fillMask(HP.ellipse(191.5, 48, 8, 8), R.gold.hi)
  c:fillMask(HP.ellipse(192, 49, 5, 5), R.gold.base)
  put(188, 44, CREAM); put(189, 44, CREAM)
  lay(starm(191.5, 8, 8, 3.6), R.gold); flush()
  c:fillMask(HP.ellipse(191.5, 9, 1, 1), R.ember.base)
end

---------------------------------------------------------------- badges / felt / ribbons
local B = {}
function B.done()
  local o = HP.ellipse(14.5, 14.5, 13.5, 13.5)
  c:rim(o, INK); fillm(o, R.gold)
  local i = HP.ellipse(14.5, 14.5, 10.5, 10.5)
  c:rim(i, R.gold.deep); fillm(i, R.moss)
  c:fillMask(ln({ {8, 15}, {13, 20}, {22, 9} }, 5), INK)
  c:fillMask(ln({ {8, 15}, {13, 19}, {22, 9} }, 3), CREAM)
  put(9, 14, CREAM)
end
function B.lock()
  obj(clipy(ring(13, 12, 8, 9, 3), 0, 16), R.iron)
  obj(HP.rrect(2, 14, 23, 30, 3), R.gold)
  c:fillMask(HP.ellipse(12.5, 21, 2, 2), INK); c:fillMask(HP.rect(12, 22, 13, 26), INK)
end
function B.sel()
  local m = ring(14.5, 14.5, 13.5, 13.5, 4)
  c:rim(m, INK); fillm(m, R.gold)
  for _, p in ipairs({ {14, 2}, {15, 27}, {2, 14}, {27, 15} }) do put(p[1], p[2], R.gold.hi) end
  spark(24, 5, CREAM)
end
local function felt(r, stitch, gold)
  local m = HP.rrect(1, 1, 34, 34, 4)
  c:rim(m, INK)
  m:each(function(x, y)
    local t = r.base
    local h = hs(x, y, 2)
    if h > .88 then t = r.hi elseif h < .1 then t = r.shade end
    if not m:has(x, y - 1) or not m:has(x - 1, y) then t = r.hi
    elseif not m:has(x, y + 1) or not m:has(x + 1, y) then t = r.shade end
    put(x, y, t)
  end)
  if gold then
    local inner = HP.rrect(3, 3, 32, 32, 3)
    local rg = m:copy():cut(inner)
    rg:each(function(x, y)
      local t = R.gold.base
      if x + y < 14 then t = R.gold.hi elseif x + y > 55 then t = R.gold.shade end
      put(x, y, t)
    end)
    inner:each(function(x, y) if not inner:has(x, y - 1) or not inner:has(x - 1, y) then put(x, y, R.gold.deep) end end)
    spark(28, 7, CREAM)
    stitchRect(6, 6, 29, 29, stitch, 2, 2)
  else
    stitchRect(4, 4, 31, 31, stitch, 2, 1)
  end
end
function B.felt_idle() felt(R.felt, "#fff0c4") end
function B.felt_off() felt({ hi = "#d4d2d6", base = "#aeabb3", shade = "#85838f", deep = "#555566" }, "#cfcdd4") end
function B.felt_sel() felt(R.felt, "#fff0c4", true) end
local function ribbon(r, emblem)
  local top = HP.rrect(1, 1, 26, 6, 1)
  local body = HP.poly({ {4, 6}, {24, 6}, {24, 22}, {14, 17}, {4, 22} })
  obj(body, r); obj(top, r)
  for x = 6, 22 do put(x, 7, r.deep) end
  for y = 8, 17 do put(7, y, r.hi) end
  for x = 3, 24, 3 do put(x, 3, r.deep) end
  emblem()
end
function B.ribbon_idle() ribbon(R.ember, function() put(13, 12, R.gold.base); put(14, 12, R.gold.base); put(13, 13, R.gold.base); put(14, 13, R.gold.shade) end) end
function B.ribbon_off() ribbon({ hi = "#e2e0e6", base = "#aaa9b8", shade = "#74758c", deep = "#444663" }, function() put(13, 12, "#e2e0e6"); put(14, 12, "#e2e0e6") end) end
function B.ribbon_sel() ribbon(R.gold, function() c:fillMask(starm(14, 12, 4, 1.8), R.ember.base); put(13, 11, R.ember.hi) end) end

---------------------------------------------------------------- table
local T = {}
for _, n in ipairs({ "axe", "basket", "bucket", "forage", "locked", "net", "pick", "rod" }) do T["slot-" .. n] = { 48, 48, S[n] } end
for _, n in ipairs({ "axe", "bucket", "forage", "net", "pick", "rod" }) do T["vig-" .. n] = { 144, 108, S["vig" .. n] } end
for _, n in ipairs({ "common", "uncommon", "rare", "legendary" }) do T["flourish-" .. n] = { 384, 96, F[n] } end
T["badge-done"] = { 30, 30, B.done }; T["badge-lock"] = { 26, 32, B.lock }; T["badge-sel"] = { 30, 30, B.sel }
for _, n in ipairs({ "idle", "off", "sel" }) do T["felt-" .. n] = { 36, 36, B["felt_" .. n] }; T["ribbon-" .. n] = { 28, 24, B["ribbon_" .. n] } end
local want = app.params.name or "all"
for n, e in pairs(T) do
  if want == "all" or want == n then
    c = HP.canvas{ w = e[1], h = e[2], scale = 1, name = n }
    e[3]()
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
