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
---------------------------------------------------------------- finish4 gather art
local function cir(cx, cy, r) return HP.ellipse(cx, cy, r, r) end
local function lerp(a, b, t) return a + (b - a) * t end
-- shaded wood handle with leather grip bands
local function handle(p0, p1, wd)
  obj(ln({ p0, p1 }, wd), R.wood)
  local n = 5
  for i = 0, 3 do
    local t = .1 + i * .06
    local x, y = lerp(p0[1], p1[1], t), lerp(p0[2], p1[2], t)
    c:fillMask(ln({ { x - 1, y + 1 }, { x + 1, y - 1 } }, 1), R.leather.base)
  end
end

function S.forage()
  slotBase()
  -- knife: curved blade, gold bolster, wooden handle with rivets
  obj(ln({ {10, 42}, {19, 30} }, 6), R.wood)
  c:fillMask(HP.rect(14, 36, 14, 36), R.gold.hi); c:fillMask(HP.rect(12, 39, 12, 39), R.gold.hi)
  obj(HP.poly({ {16, 29}, {24, 26}, {26, 31}, {20, 35} }), R.gold)
  local blade = HP.poly({ {22, 27}, {26, 14}, {32, 6}, {40, 4}, {41, 12}, {37, 21}, {30, 30}, {26, 32} })
  obj(blade, R.iron)
  c:fillMask(ln({ {28, 24}, {33, 14}, {38, 8} }, 1), CREAM)      -- lit edge
  c:fillMask(ln({ {35, 24}, {39, 15} }, 1), R.iron.deep)        -- spine shade
  put(41, 5, CREAM)
  -- toadstool
  obj(HP.rect(31, 33, 36, 42), { hi = CREAM, base = "#f0dcb4", shade = "#c9b08a", deep = R.wood.deep })
  local cap = clipy(HP.ellipse(34, 34, 10, 8), 0, 34)
  obj(cap, R.ember)
  c:fillMask(HP.rect(25, 34, 43, 34), R.ember.deep)
  for _, p in ipairs({ {30, 29, 2}, {36, 27, 2}, {40, 31, 1}, {33, 32, 1} }) do c:fillMask(cir(p[1], p[2], p[3]), CREAM) end
  -- leaf + berry quirk
  obj(leafm(5, 14, -.5, 9, 3), R.moss)
  obj(cir(9, 18, 2), R.petal); put(8, 17, CREAM)
end

-- fish drawn in a local frame rotated by ang about (cx,cy); body length ~L
local function fish(cx, cy, ang, L)
  local function T(pts) local o = {} for i, p in ipairs(pts) do o[i] = { cx + (p[1] * cos(ang) - p[2] * sin(ang)) * L / 24, cy + (p[1] * sin(ang) + p[2] * cos(ang)) * L / 24 } end return o end
  local FR = { hi = "#ffd7a0", base = "#f48c4c", shade = "#c85a3c", deep = "#6e2038" }
  local FIN = { hi = "#ffb070", base = "#e0603c", shade = "#a8383c", deep = "#6e2038" }
  obj(HP.poly(T({ {-12, 0}, {-22, -8}, {-19, 0}, {-22, 8} })), FIN)                                -- tail
  obj(HP.poly(T({ {-2, -6}, {-6, -13}, {4, -8} })), FIN)                                            -- dorsal
  obj(HP.poly(T({ {14, 0}, {8, -6}, {-2, -7}, {-10, -3}, {-12, 0}, {-10, 3}, {-2, 6}, {8, 6} })), FR)  -- body
  local bel = HP.poly(T({ {12, 2}, {4, 5}, {-6, 4}, {-9, 1}, {4, 2} }))
  c:fillMask(bel, "#fff0cc")
  local px_, py_ = cx + (7 * cos(ang) + 1 * sin(ang)) * L / 24, cy + (7 * sin(ang) - 1 * cos(ang)) * L / 24
  put(floor(px_ + .5), floor(py_ + .5), INK); put(floor(px_ + .5) - 1, floor(py_ + .5) - 1, CREAM)
  for k = 0, 2 do local a = T({ {-1 - k * 3, -3} })[1]; put(floor(a[1] + .5), floor(a[2] + .5), FR.deep) end
  local g = T({ {4, 0}, {4, 3} })
  c:fillMask(ln({ { floor(g[1][1] + .5), floor(g[1][2] + .5) }, { floor(g[2][1] + .5), floor(g[2][2] + .5) } }, 1), FR.shade)
  obj(HP.poly(T({ {2, 4}, {-4, 9}, {-4, 4} })), FIN)                                                -- pectoral
end

function S.vigrod()
  sky({ "#f0a884", "#f8c896", "#fde4b0" }, { 18, 36 })
  c:fillMask(HP.ellipse(112, 30, 13, 13), R.gold.shade); c:fillMask(HP.ellipse(112, 30, 11, 11), R.gold.base); c:fillMask(HP.ellipse(110, 28, 7, 7), R.gold.hi)
  cloud(30, 14, 26)
  hill(46, 4, .05, 2, "#7aa88a", 64)
  hill(54, 3, .08, 1, "#4f8a6e", 66)
  for y = 62, 106 do for x = 0, 143 do
    local t = (y < 78) and R.sea.shade or R.sea.base
    if y % 6 == 0 and hs(x, y, 6) > .55 then t = (y < 78) and R.sea.base or R.sea.hi end
    if y > 96 and hs(x, y, 7) > .8 then t = R.sea.shade end
    put(x, y, t)
  end end
  for y = 64, 80, 2 do for x = 98, 128 do if hs(x, y, 3) > .55 then put(x, y, R.gold.hi) end end end   -- sun glints
  for _, p in ipairs({ {70, 98}, {96, 90}, {124, 100} }) do c:fillMask(ln({ {p[1], p[2]}, {p[1] + 8, p[2]} }, 1), R.sea.hi) end
  -- clean rounded bank
  local bank = HP.ellipse(-4, 98, 50, 28):add(HP.rect(0, 96, 40, 107))
  bank:clip(HP.rect(0, 62, 143, 107))
  c:rim(bank, INK)
  bank:each(function(x, y)
    local t = R.moss.base
    if hs(x, y, 5) > .93 then t = R.moss.hi elseif hs(x, y, 6) < .05 then t = R.moss.shade end
    put(x, y, t)
  end)
  bank:each(function(x, y) if not bank:has(x + 1, y + 1) then put(x, y, R.moss.shade) end if not bank:has(x, y + 1) or not bank:has(x + 1, y) then put(x, y, R.moss.deep) elseif not bank:has(x - 1, y - 1) then put(x, y, R.moss.hi) end end)
  for _, p in ipairs({ {12, 80}, {30, 92}, {8, 100}, {26, 102} }) do put(p[1], p[2], R.moss.hi); put(p[1] + 1, p[2], R.moss.hi); put(p[1], p[2] - 1, R.moss.hi) end
  -- reeds at the shore
  for i, x in ipairs({ 44, 48, 52 }) do
    local top = 64 - i * 3
    c:fillMask(ln({ {x, 86}, {x + (i - 2) * 2, top} }, 1), R.moss.deep)
    obj(HP.rect(x + (i - 2) * 2 - 1, top - 3, x + (i - 2) * 2, top + 3), R.wood)
  end
  -- forked rest + rod
  obj(ln({ {20, 96}, {26, 76} }, 3), R.dirt); obj(ln({ {32, 96}, {26, 76} }, 3), R.dirt)
  obj(ln({ {10, 104}, {70, 20} }, 3), R.wood)
  obj(ln({ {12, 100}, {18, 92} }, 4), R.ember)
  obj(HP.ellipse(23, 83, 3, 3), R.iron); put(22, 82, CREAM)
  -- line: dark under-line + cream line, sagging from tip to bobber
  local tipx, tipy, bx, by = 70, 20, 96, 74
  local prev
  for i = 0, 60 do
    local t = i / 60
    local x = tipx + (bx - tipx) * t
    local y = tipy + (by - tipy) * t + 10 * sin(t * pi) * (1 - t * .3)
    x, y = floor(x + .5), floor(y + .5)
    put(x + 1, y + 1, "#7a4a52"); put(x, y, CREAM)
    prev = { x, y }
  end
  -- bobber + ripples
  obj(HP.ellipse(96, 75, 3, 3), R.ember); c:fillMask(HP.rect(94, 75, 98, 76), CREAM); put(95, 73, CREAM)
  for _, e in ipairs({ {96, 80, 8, 2}, {96, 82, 15, 3} }) do ring(e[1], e[2], e[3], e[4], 1):each(function(x, y) if (x + y) % 2 == 0 then put(x, y, R.sea.hi) end end) end
  -- whole jumping fish inside the frame
  fish(102, 46, -.7, 34)
  for _, p in ipairs({ {106, 62, 1}, {112, 66, 1}, {128, 64, 1}, {124, 58, 1}, {101, 52, 1} }) do obj(cir(p[1], p[2], p[3]), R.sea) end
  ring(116, 80, 10, 3, 1):each(function(x, y) if (x + y) % 2 == 0 then put(x, y, CREAM) end end)
  -- lily pad + dragonfly
  obj(HP.ellipse(64, 92, 12, 4), R.moss)
  c:fillMask(HP.poly({ {64, 92}, {76, 89}, {76, 94} }), R.sea.base)
  obj(HP.rect(80, 40, 90, 41), R.sea); put(76, 40, R.sea.deep); put(77, 40, R.sea.deep)
  c:fillMask(HP.ellipse(81, 37, 3, 1), R.sea.hi); c:fillMask(HP.ellipse(86, 37, 3, 1), R.sea.hi)
  frame()
end

function S.vigpick()
  sky({ "#c8c0e8", "#e4cce0", "#f6dcc8" }, { 20, 38 })
  cloud(28, 15, 24); cloud(112, 22, 18)
  hill(46, 5, .05, 4, "#9a90c0", 70)
  hill(56, 3, .08, 2, "#7c78a8", 72)
  grass(70, 106, "#7aa86a", "#4f8460", "#b6d484", 17)
  -- boulder with lit top-left and ore veins
  local rock = HP.poly({ {60, 100}, {58, 70}, {66, 52}, {82, 38}, {104, 32}, {124, 38}, {138, 54}, {140, 100} })
  c:rim(rock, INK)
  local RK = { hi = "#b4a8a8", base = "#867a80", shade = "#625668", deep = "#42384c" }   -- darker, warmer rock so the steel head pops
  rock:each(function(x, y)
    local t = RK.base
    local lx = (x - 100) * .6 + (y - 60) * .8
    if lx < -22 then t = RK.hi elseif lx > 28 then t = RK.shade end
    if lx > 46 then t = RK.deep end
    if hs(x, y, 9) > .92 then t = (t == RK.hi) and RK.base or RK.shade end
    if not rock:has(x - 1, y - 1) or not rock:has(x, y - 1) then t = RK.hi end
    put(x, y, t)
  end)
  for _, ln_ in ipairs({ { {96, 38}, {100, 54}, {94, 66}, {98, 80} }, { {122, 54}, {114, 72}, {118, 90} }, { {72, 62}, {80, 74} } }) do c:fillMask(ln(ln_, 1), RK.deep) end
  -- crystal ore + gold flecks
  for _, p in ipairs({ {108, 70, 7}, {126, 84, 6}, {80, 86, 5} }) do obj(HP.poly({ {p[1], p[2] - p[3]}, {p[1] + 4, p[2]}, {p[1], p[2] + p[3] - 1}, {p[1] - 4, p[2]} }), R.sea); put(p[1] - 1, p[2] - 2, CREAM) end
  for _, p in ipairs({ {90, 52}, {114, 48}, {130, 66} }) do put(p[1], p[2], R.gold.base); put(p[1] + 1, p[2], R.gold.hi) end
  -- pick: wood handle up to a socketed iron head; crescent head, both ends drawn to sharp points that curve back
  -- toward the handle; the lower point bites the rock. Dark steel ramp so it separates from the grey stone.
  local STEEL = { hi = "#f6faff", base = "#b8c4e0", shade = "#7884ac", deep = "#3c4268" }
  local d = { .87, .49 }        -- handle direction (towards the head)
  local pv = { -.49, .87 }      -- head axis (perpendicular)
  local C0 = { 90, 52 }         -- eye of the head
  handle({ 14, 12 }, { C0[1] + d[1] * 3, C0[2] + d[2] * 3 }, 4)
  obj(HP.rect(10, 8, 14, 12), R.leather)
  local function cpt(t) return C0[1] + pv[1] * t * 27 - d[1] * (t * t * 9), C0[2] + pv[2] * t * 27 - d[2] * (t * t * 9) end
  local function wd(t) return max(.4, 4.6 * (1 - abs(t) ^ 1.8) + .4) end
  local up, dn = {}, {}
  for i = -12, 12 do
    local t = i / 12
    local x, y = cpt(t)
    local w = wd(t)
    up[#up + 1] = { x - d[1] * w, y - d[2] * w }
    dn[#dn + 1] = { x + d[1] * w * 1.1, y + d[2] * w * 1.1 }
  end
  local pts = {}
  for i = 1, #up do pts[#pts + 1] = up[i] end
  for i = #dn, 1, -1 do pts[#pts + 1] = dn[i] end
  local head = HP.poly(pts)
  -- cast shadow on the rock, offset down-right
  head:each(function(x, y) if not head:has(x + 2, y + 2) and rock:has(x + 2, y + 2) then put(x + 2, y + 2, RK.deep) end end)
  c:rim(head:grow(1), INK); c:rim(head, INK)
  head:each(function(x, y)
    -- signed distance across the head: negative = upper-left (lit) face
    local best, bs = 1e9, 0
    for i = -12, 12 do
      local px_, py_ = cpt(i / 12)
      local dx, dy = x + .5 - px_, y + .5 - py_
      local dd = dx * dx + dy * dy
      if dd < best then best = dd; bs = (dx * d[1] + dy * d[2]) / wd(i / 12) end
    end
    local t = STEEL.base
    if bs < -.45 then t = STEEL.hi elseif bs < -.05 then t = mix(STEEL.base, STEEL.hi, .45) elseif bs > .55 then t = STEEL.deep elseif bs > .2 then t = STEEL.shade end
    if bs < -.2 and (not head:has(x - 1, y) or not head:has(x, y - 1)) then t = STEEL.hi end   -- bright lit edge
    put(x, y, t)
  end)
  head:each(function(x, y) if not head:has(x + 1, y + 1) and not head:has(x + 1, y) then put(x, y, STEEL.deep) end end)
  -- socket collar around the eye, wedge, rivet
  local col = HP.poly({ { C0[1] - 6, C0[2] - 2 }, { C0[1] - 1, C0[2] - 9 }, { C0[1] + 6, C0[2] - 4 }, { C0[1] + 2, C0[2] + 4 } })
  obj(col, { hi = "#ffe38a", base = "#e0a83a", shade = "#a8682a", deep = "#6e4020" })   -- gold socket
  for _, q in ipairs({ { -2, -4, "#8a4a1f" }, { -1, -4, "#8a4a1f" }, { 0, -4, "#8a4a1f" }, { -2, -3, "#fff2a0" }, { -1, -3, "#f5cf6a" }, { 0, -3, "#d98322" }, { -1, -2, "#d98322" }, { 0, -2, "#8a4a1f" } }) do put(C0[1] + q[1], C0[2] + q[2], q[3]) end
  -- glints on the lit edge and the biting point
  local gx, gy = cpt(-.55); put(floor(gx - d[1] * 2), floor(gy - d[2] * 2), CREAM)
  local tx, ty = cpt(1); spark(floor(tx) + 1, floor(ty) + 3, CREAM)
  spark(100, 66, R.gold.hi); spark(112, 80, CREAM); put(96, 74, R.gold.base); put(106, 58, R.gold.base)
  -- chips flying
  obj(HP.poly({ {64, 76}, {69, 72}, {70, 78} }), R.stone); obj(HP.poly({ {108, 54}, {113, 52}, {112, 58} }), R.stone)
  -- rubble
  for _, p in ipairs({ {54, 97, 5}, {46, 101, 3}, {142, 99, 4}, {64, 103, 3} }) do obj(HP.ellipse(p[1], p[2], p[3], p[3] - 1), R.stone) end
  -- mole on mound, facing the rock
  obj(HP.ellipse(26, 98, 19, 7), R.dirt)
  obj(HP.ellipse(26, 87, 8, 7), { hi = "#8a84a0", base = "#5a566c", shade = "#3f3c55", deep = INK })
  obj(HP.ellipse(31, 91, 4, 3), R.petal)
  put(24, 85, CREAM); put(29, 85, CREAM); put(24, 86, INK); put(29, 86, INK)
  obj(HP.rect(15, 92, 19, 96), R.petal); obj(HP.rect(34, 92, 38, 96), R.petal)
  frame()
end

---------------------------------------------------------------- flourishes (384x96 = 4 frames of 96x96 sparkle ring, transparent)
local F = {}
local FC = { ox = 0 }
local function fput(x, y, col) x = floor(x + .5); y = floor(y + .5); if x >= 0 and x < 96 then put(FC.ox + x, y, col) end end
local function fmask(m, ox, oy, col) m:each(function(x, y) fput(x + ox, y + oy, col) end) end
-- 4-point star of arm length n (n>=1), colours: tip/arm/centre, dark outline
local function star4(x, y, n, arm, centre, deep, diag)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.mask()
  m:set(0, 0)
  for k = 1, n do m:set(k, 0); m:set(-k, 0); m:set(0, k); m:set(0, -k) end
  if diag then m:set(1, 1); m:set(-1, 1); m:set(1, -1); m:set(-1, -1) end
  fmask(m:grow(1), x, y, deep)
  fmask(m, x, y, arm)
  fput(x, y, centre); if n >= 2 then fput(x - 1, y, centre); fput(x, y - 1, centre) end
end
local function diamond(x, y, rx, ry, base, hi, deep, shade)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.mask()
  for j = -ry, ry do local w = floor(rx * (1 - abs(j) / (ry + .5)) + .5); for i = -w, w do m:set(i, j) end end
  fmask(m:grow(1), x, y, deep)
  m:each(function(i, j) fput(x + i, y + j, (i + j < -rx * .3) and hi or ((i + j > rx * .3) and shade or base)) end)
end
local function dot(x, y, r, base, hi, deep)
  x, y = floor(x + .5), floor(y + .5)
  local m = HP.ellipse(0, 0, r, r)
  fmask(m:grow(1), x, y, deep); fmask(m, x, y, base); fput(x - 1, y - 1, hi)
end
local function leafsp(x, y, a, len, wid, base, hi, deep, shade)
  local pts = {}
  for i, p in ipairs({ {0, 0}, {len * .4, -wid}, {len, 0}, {len * .4, wid} }) do pts[i] = { p[1] * cos(a) - p[2] * sin(a), p[1] * sin(a) + p[2] * cos(a) } end
  local m = HP.poly(pts)
  local ox, oy = floor(x + .5), floor(y + .5)
  fmask(m:grow(1), ox, oy, deep)
  m:each(function(i, j) fput(ox + i, oy + j, ((i * cos(a - pi / 2) + j * sin(a - pi / 2)) > 0) and shade or base) end)
  fput(ox + floor(len * .35 * cos(a)), oy + floor(len * .35 * sin(a)), hi)
end

-- ring generator: N slots, step per frame, radius pulse
local function ringFrames(o)
  for f = 0, 3 do
    FC.ox = f * 96
    local rot = f * o.step
    local rr = o.r + o.pulse[f + 1]
    o.draw(f, rot, rr)
  end
end

function F.common()
  local P = { hi = "#fff4d6", base = "#e9e2c4", deep = "#8b7a5a", shade = "#c4b98e" }
  ringFrames({ step = (2 * pi / 6) / 4, r = 36, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 5 do
      local a = rot + i * 2 * pi / 6
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      local tw = ((i + f) % 3 == 0)
      if tw then star4(x, y, 4, P.base, P.hi, P.deep, true) else dot(x, y, 3, P.base, P.hi, P.deep) end
    end
    for i = 0, 5 do
      local a = rot + (i + .5) * 2 * pi / 6
      dot(48 + (rr - 7) * cos(a), 48 + (rr - 7) * sin(a), 1, P.hi, P.hi, P.deep)
    end
  end })
end
function F.uncommon()
  local G = { hi = "#d6f08a", base = "#7ab55c", shade = "#4f8f44", deep = "#25503e" }
  ringFrames({ step = (2 * pi / 8) / 4, r = 36, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 7 do
      local a = rot + i * 2 * pi / 8
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      leafsp(x - cos(a + pi / 2) * 6, y - sin(a + pi / 2) * 6, a + pi / 2 - .35, 15, 4, G.base, G.hi, G.deep, G.shade)
    end
    for i = 0, 3 do
      local a = rot + (i * 2 + 1) * 2 * pi / 8
      local x, y = 48 + (rr + 1) * cos(a), 48 + (rr + 1) * sin(a)
      if (i + f) % 2 == 0 then star4(x, y, 4, "#fff4d6", "#fffbe8", "#8a7a4a", true) else dot(x, y, 3, "#ffe38a", "#fff4d6", "#9a6a2a") end
    end
  end })
end
function F.rare()
  local B = { hi = "#e8fcff", base = "#a9d6ea", shade = "#5aa0d4", deep = "#2a4a7a" }
  local V = { hi = "#e0d0ff", base = "#a98ae0", shade = "#6c52b0", deep = "#2e2a66" }
  ringFrames({ step = (2 * pi / 10) / 4, r = 37, pulse = { 0, 1, 2, 1 }, draw = function(f, rot, rr)
    for i = 0, 9 do
      local a = rot + i * 2 * pi / 10
      local x, y = 48 + rr * cos(a), 48 + rr * sin(a)
      local P = (i % 2 == 0) and B or V
      local big = (i % 2 == 0)
      if math.abs(cos(a)) > math.abs(sin(a)) then diamond(x, y, 3, big and 8 or 6, P.base, P.hi, P.deep, P.shade) else diamond(x, y, big and 8 or 6, 3, P.base, P.hi, P.deep, P.shade) end
    end
    for i = 0, 4 do
      local a = rot + (i * 2 + 1) * 2 * pi / 10
      local x, y = 48 + (rr - 6) * cos(a), 48 + (rr - 6) * sin(a)
      if (i + f) % 2 == 0 then star4(x, y, 5, B.hi, "#ffffff" == "" and "" or "#fffdf0", B.deep, true) else star4(x, y, 3, B.base, B.hi, B.deep, true) end
    end
  end })
end
function F.legendary()
  local G = { hi = "#fff2a0", base = "#f5c43a", shade = "#e8a317", deep = "#7a4a14" }
  ringFrames({ step = (2 * pi / 12) / 4, r = 31, pulse = { 0, 1, 3, 1 }, draw = function(f, rot, rr)
    for i = 0, 11 do                       -- rays
      local a = rot + i * 2 * pi / 12
      local long = (i % 2 == 0)
      local x, y = 48 + (rr - 3) * cos(a), 48 + (rr - 3) * sin(a)
      local ex, ey = 48 + (rr + (long and 11 or 6)) * cos(a), 48 + (rr + (long and 11 or 6)) * sin(a)
      local m = HP.line({ { 0, 0 }, { ex - x, ey - y } }, 3)
      fmask(m:grow(1), floor(x + .5), floor(y + .5), G.deep)
      fmask(m, floor(x + .5), floor(y + .5), long and G.base or G.shade)
    end
    for i = 0, 11 do
      local a = rot + i * 2 * pi / 12
      if i % 2 == 0 then dot(48 + (rr - 9) * cos(a), 48 + (rr - 9) * sin(a), 2, G.hi, G.hi, G.deep) end
    end
    for i = 0, 3 do                         -- four big stars between
      local a = rot + (i * 3 + 1.5) * 2 * pi / 12
      local x, y = 48 + (rr + 1) * cos(a), 48 + (rr + 1) * sin(a)
      star4(x, y, ((i + f) % 2 == 0) and 6 or 3, G.base, "#fffbe0", G.deep, true)
    end
  end })
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
local WANT = { ["vig-rod"] = 1, ["vig-pick"] = 1, ["slot-forage"] = 1, ["flourish-common"] = 1, ["flourish-uncommon"] = 1, ["flourish-rare"] = 1, ["flourish-legendary"] = 1 }
local want = app.params.name or "all"
for n, e in pairs(T) do
  if (want == "all" and WANT[n]) or want == n then
    c = HP.canvas{ w = e[1], h = e[2], scale = 1, name = n }
    e[3]()
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
