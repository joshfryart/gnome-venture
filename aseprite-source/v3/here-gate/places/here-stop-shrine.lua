-- Gnome Venture "Hearth Pop" v3 -- here-stop-shrine: wayside Shrine rest stop, GATE VIEW, 480x270 native.
-- Dawn light, blossom tree with prayer ribbons, stepping-stone path to a small red-roofed stone shrine.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local P = dofile(ROOT .. "lib/palette.lua")
local OUT = (app.params and app.params.out) or (ROOT .. "here-gate/places/")
local NAME = "here-stop-shrine"
local W, Hh = 480, 270
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min

local function H(x, y, s)
  local n = (floor(x) * 374761393 + floor(y) * 668265263 + (s or 0) * 1442695041) % 2147483647
  n = (n ~ (n >> 13)) * 1274126177 % 2147483647
  n = n ~ (n >> 16)
  return (n % 10007) / 10007
end

-- custom ramps
local R = {
  grass = { hi = "#b8dc84", base = "#8cc36a", shade = "#5f9a5c", deep = "#3f6e57" },
  earth = { hi = "#ead2a8", base = "#d2b083", shade = "#a9845f", deep = "#6f5243" },
  bark  = { hi = "#9a6a52", base = "#6e4a3c", shade = "#51302b", deep = "#3a2420" },
  frame = { hi = "#8a6a58", base = "#6b4f45", shade = "#4e3a38", deep = "#2f2229" },
  thatch = { hi = "#ffe38a", base = "#e0b05a", shade = "#b8833a", deep = "#7a4d24" },
  plaster = { hi = "#fff4d6", base = "#f0dfb8", shade = "#c9b28f", deep = "#7d6650" },
  bronze = { hi = "#f2c66a", base = "#c98f3a", shade = "#8f5a2a", deep = "#55331f" },
  cork  = { hi = "#e3b07a", base = "#c48a58", shade = "#9a6440", deep = "#5e3a2e" },
}

-- surface painter: tone index 1..4 (deep..hi), texture deltas, light upper-left, shade lower-right, 1px deep edge
local function surf(m, r, o)
  o = o or {}
  local b = o.band or 3
  local cols = { r.deep, r.shade, r.base, r.hi }
  m:each(function(x, y)
    local i = 3
    if o.tex then i = i + (o.tex(x, y) or 0) end
    if (not o.noside and not m:has(x + b, y)) or not m:has(x, y + b) then i = i - 1 end
    if not m:has(x - 2, y) or not m:has(x, y - 2) then i = i + 1 end
    if not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1)) then i = 1 end
    c:put(x, y, cols[max(1, min(4, i))])
  end)
  return m
end
local function bricks(bw, bh, ox, oy)
  return function(x, y)
    local row = floor((y - oy) / bh)
    local xo = (row % 2) * floor(bw / 2)
    if (y - oy) % bh == 0 or (x - ox + xo) % bw == 0 then return -1 end
    if (y - oy) % bh == 1 and H(x, row) > .55 then return 1 end
    if H(x, y, 3) > .94 then return -1 end
    return 0
  end
end
local function planksV(sp, ox)
  return function(x, y)
    if (x - (ox or 0)) % sp == 0 then return -1 end
    if H(x, floor(y / 6), 5) > .86 then return -1 end
    if (x - (ox or 0)) % sp == 1 then return 1 end
    return 0
  end
end
local function planksH(sp, oy)
  return function(x, y)
    if (y - (oy or 0)) % sp == 0 then return -1 end
    if H(floor(x / 6), y, 6) > .86 then return -1 end
    if (y - (oy or 0)) % sp == 1 then return 1 end
    return 0
  end
end
local function thatchT(x, y)
  if (y + floor(H(x, 0, 8) * 5)) % 5 == 0 then return -1 end
  if H(x, y, 9) > .88 then return 1 end
  return 0
end
local function tilesT(x, y)
  if y % 4 == 0 then return -1 end
  if (x + (floor(y / 4) % 2) * 3) % 6 == 0 then return -1 end
  if y % 4 == 1 then return 1 end
  return 0
end
local function mossOn(m, dens)
  m:each(function(x, y)
    if m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y + 1) and m:has(x, y - 1)
      and H(floor(x / 4), floor(y / 3), 11) > (dens or .82) then
      c:put(x, y, m:has(x, y - 2) and P.moss.base or P.moss.hi)
      if H(x, y, 12) > .7 then c:put(x, y, P.moss.shade) end
    end
  end)
end
local function shadow(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  local inner = c:ellipse(cx + 2, cy, max(1, rx - 4), max(1, ry - 1))
  c:fillMask(m, "#628a74"); c:fillMask(inner, "#557a6c")
end
local function wisp(x, y, len, col, ph)
  for i = 0, len do
    local xx = x + floor(3 * sin(i / 5 + (ph or 0)) + i * .25 + .5)
    c:put(xx, y - i, col)
    if i % 3 ~= 0 then c:put(xx + 1, y - i, col) end
  end
end
local function glowWin(x0, y0, x1, y1, wall)
  if wall then c:fillMask(c:rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), wall) end
  c:fillMask(c:rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1), P.wood.deep)
  c:fillMask(c:rect(x0, y0, x1, y1), P.gold.base)
  c:fillMask(c:rect(x0 + 1, y0 + 1, x1 - 2, y1 - 2), P.gold.hi)
  local mx, my = floor((x0 + x1) / 2), floor((y0 + y1) / 2)
  for x = x0, x1 do c:put(x, my, P.wood.shade) end
  for y = y0, y1 do c:put(mx, y, P.wood.shade) end
end

-- stand points (keep plain)
local STAND = { {240, 236}, {182, 176}, {302, 178}, {322, 232}, {90, 176}, {360, 182} }
local function nearStand(x, y, r)
  for _, s in ipairs(STAND) do if (x - s[1])^2 + (y - s[2])^2 < (r or 30)^2 then return true end end
  return false
end

------------------------------------------------------------------ SKY (dawn)
c:stripes(0, 111, { "#c9b2f0", "#d8bdee", "#e9c6e6", "#ffc4d8", "#ffd3c8", "#ffe0bf", "#ffeab8" }, { 3, 2, 2, 2, 2, 2, 2 })
-- soft sun glow band behind the shrine (a flat-topped haze, no disc)
for y = 70, 100 do
  local half = floor((y - 70) * 2.2) + 20
  for x = 240 - half, 240 + half do if H(x, y, 21) > .45 then c:put(x, y, "#fff0c4") end end
end
local function cl(x, y, w) c:cloud(x, y, w, P.cream, P.petal.hi) end
cl(30, 46, 44); cl(286, 34, 56); cl(372, 60, 40); cl(206, 28, 30); cl(96, 76, 30)

------------------------------------------------------------------ FAR SCENERY
c:terrain(function(x) return 76 + 10 * sin(x / 37) + 6 * sin(x / 13 + 1) end, "#b9a6dc", 111)
c:terrain(function(x) return 76 + 10 * sin(x / 37) + 6 * sin(x / 13 + 1) + 2 end, "#a893cf", 111)
c:terrain(function(x) return 90 + 7 * sin(x / 53 + 2) + 4 * sin(x / 19) end, "#9fb7b0", 111)
c:terrain(function(x) return 92 + 7 * sin(x / 53 + 2) + 4 * sin(x / 19) end, "#8aa8a2", 111)
c:terrain(function(x)
  local t = x % 11
  local spike = (H(floor(x / 11), 0, 4) > .25) and (6 - abs(t - 5)) * 1.6 or 0
  return 104 - spike
end, "#6f9a84", 111)
for y = 99, 108 do
  for x = 0, W - 1 do
    if H(floor(x / 9), y, 31) > .62 and (y % 3 ~= 0) then c:put(x, y, "#eae0f2") end
  end
end

------------------------------------------------------------------ GROUND
for y = 112, Hh - 1 do
  for x = 0, W - 1 do
    local col = R.grass.base
    if y < 128 then col = "#a6cf86" elseif y < 140 then col = "#98c978" end
    if (x - 240)^2 / 130^2 + (y - 150)^2 / 32^2 < 1 then col = "#a4d277" end
    local h = H(x, y, 41)
    if h > .965 then col = R.grass.hi elseif h < .035 then col = R.grass.shade end
    c:put(x, y, col)
  end
end
-- tufts
for i = 1, 520 do
  local x = floor(H(i, 1, 51) * W); local y = 116 + floor(H(i, 2, 51) * 152)
  local s = 1 + floor((y - 112) / 50)
  for k = 0, s do c:put(x, y - k, R.grass.shade); c:put(x + 1, y - k + 1, R.grass.hi) end
end
-- warm glow by the fire (people area)
for y = 222, 268 do for x = 70, 180 do
  if (x - 124)^2 / 46^2 + (y - 248)^2 / 16^2 < 1 and H(x, y, 61) > .35 then c:put(x, y, "#b6cf72") end
end end

------------------------------------------------------------------ PATH (stepping stones)
local function hw(y) return 8 + 72 * (y - 112) / 158 end
local path = c:poly{ {232, 112}, {248, 112}, {320, 269}, {160, 269} }
path:each(function(x, y)
  local h = H(x, y, 71)
  c:put(x, y, h > .9 and R.earth.hi or (h < .1 and R.earth.shade or R.earth.base))
end)
do
  local y, k = 268, 0
  while y > 118 do
    local u = (y - 112) / 158
    local h = max(2, floor(2 + 13 * u))
    local yc = y - h / 2
    local w = hw(yc) * 2
    local sw = floor(w * .5)
    local off = floor(w * .15) * ((k % 2 == 0) and -1 or 1)
    local x0 = floor(240 + off - sw / 2)
    local m = c:rrect(x0, y - h + 1, x0 + sw, y, max(1, floor(h / 3)))
    surf(m, P.stone, { band = max(1, floor(h / 4)), tex = function(x, yy)
      if H(floor(x / 3), floor(yy / 2), 77) > .88 then return 1 end
      if H(x, yy, 78) > .93 then return -1 end
      return 0 end })
    -- moss crumbs on the stone's lower lip
    for x = x0 + 2, x0 + sw - 2 do if H(x, y, 79) > .8 then c:put(x, y - 1, P.moss.base) end end
    y = y - h - max(2, floor(h * .6)); k = k + 1
  end
end
-- grass tufts over the path edges
for y = 116, 268, 3 do
  local e = hw(y)
  for _, side in ipairs({ -1, 1 }) do
    local x = floor(240 + side * e + .5)
    local s = 1 + floor((y - 112) / 45)
    for k = 0, s do
      c:put(x - side * k, y - k, R.grass.base); c:put(x - side * k, y - k + 1, R.grass.shade)
    end
  end
end

------------------------------------------------------------------ BLOSSOM TREE with prayer ribbons (backdrop)
shadow(162, 143, 22, 3)
local trunk = c:poly{ {154,142}, {170,142}, {166,104}, {176,68}, {167,66}, {161,92}, {150,68}, {143,71}, {156,104} }
surf(trunk, R.bark, { band = 2, tex = function(x, y) if (x + floor(y / 7)) % 4 == 0 then return -1 end return 0 end })
local canopy = c:ellipse(158, 44, 32, 19)
canopy:add(c:ellipse(130, 55, 16, 11)):add(c:ellipse(184, 52, 14, 11)):add(c:ellipse(142, 28, 18, 12)):add(c:ellipse(174, 30, 16, 11))
surf(canopy, P.petal, { band = 4, tex = function(x, y)
  local h = H(floor(x / 4), floor(y / 3), 81)
  if h > .78 then return 1 end
  if h < .18 then return -1 end
  if H(x, y, 82) > .95 then return 1 end
  return 0 end })
canopy:each(function(x, y) if H(x, y, 83) > .975 and canopy:has(x, y - 2) and canopy:has(x, y + 2) then c:put(x, y, P.cream) end end)
-- branch peeking out
c:fillMask(c:line({ {150, 60}, {136, 52} }, 2), R.bark.shade)
-- prayer ribbons
local ribbons = { {130, 64, 14, P.sea}, {141, 62, 18, P.gold}, {178, 61, 16, P.dusk}, {121, 60, 11, P.ember} }
for _, rb in ipairs(ribbons) do
  local x, y0, len, r = rb[1], rb[2], rb[3], rb[4]
  for i = 0, len do
    local xx = x + floor(sin(i / 3) * 1.2 + .5)
    c:put(xx, y0 + i, r.deep); c:put(xx + 1, y0 + i, r.base); c:put(xx + 2, y0 + i, r.hi); c:put(xx + 3, y0 + i, r.deep)
  end
  c:put(x + 1, y0 + len + 1, r.deep); c:put(x + 2, y0 + len + 1, r.deep)
  c:put(x + 1, y0 - 1, R.bark.deep); c:put(x + 2, y0 - 1, R.bark.deep)
end
-- QUIRK: wind chime of spoons
c:fillMask(c:rect(184, 63, 196, 64), R.bark.base)
for i, sx in ipairs({ 185, 190, 195 }) do
  local len = 8 + i * 3
  for y = 65, 65 + len do c:put(sx, y, P.stone.shade) end
  local sp = c:ellipse(sx, 66 + len + 2, 1.5, 2.5)
  c:fillMask(sp, P.stone.base); c:fillMask(sp:edge(), P.stone.deep); c:put(sx - 1, 66 + len + 1, P.stone.hi)
end
-- QUIRK: mushrooms with a tiny ribbon by the roots
for _, mu in ipairs({ {174, 140, 4}, {181, 141, 3} }) do
  local x, y, s = mu[1], mu[2], mu[3]
  c:fillMask(c:rect(x - 1, y - s, x + 1, y), P.cream)
  local cap = c:poly{ {x - s - 1, y - s}, {x + s + 1, y - s}, {x + s - 1, y - s - 3}, {x - s + 1, y - s - 3} }
  surf(cap, P.ember, { band = 1 })
  c:put(x - 1, y - s - 2, P.cream)
end
c:put(176, 136, P.sea.base); c:put(177, 137, P.sea.hi); c:put(176, 138, P.sea.base)

------------------------------------------------------------------ HOMES: two keeper huts (right)
-- hut A: plank walls + golden thatch
shadow(336, 149, 36, 3)
local wallA = c:rect(308, 112, 362, 148)
surf(wallA, P.wood, { band = 3, tex = planksV(6, 308) })
local roofA = c:poly{ {300, 116}, {370, 116}, {362, 96}, {348, 80}, {322, 80}, {308, 96} }
surf(roofA, R.thatch, { band = 3, tex = thatchT })
mossOn(c:poly{ {312, 92}, {356, 92}, {348, 82}, {322, 82} }, .78)
for x = 302, 368 do c:put(x, 117, P.wood.deep) end -- eave shadow
local doorA = c:rrect(322, 124, 338, 148, 3)
surf(doorA, R.bark, { band = 2, tex = planksV(4, 322) })
c:put(335, 137, P.gold.hi); c:put(335, 136, P.gold.base)
glowWin(346, 123, 356, 132, P.wood.hi)
-- herb bundle by the door
c:fillMask(c:poly{ {315, 122}, {319, 122}, {320, 132}, {314, 132} }, P.moss.base)
c:put(316, 124, P.moss.hi); c:put(317, 128, P.moss.shade); c:fillMask(c:rect(315, 120, 319, 121), P.ember.base)
-- QUIRK: a tiny shrine-shaped birdhouse on the thatch peak
c:fillMask(c:rect(333, 72, 337, 79), R.bark.deep)
c:fillMask(c:rect(331, 68, 339, 74), P.stone.base); c:fillMask(c:rect(331, 68, 339, 74):edge(), P.stone.deep)
c:fillMask(c:poly{ {328, 68}, {342, 68}, {338, 64}, {332, 64} }, P.ember.base)
c:fillMask(c:rect(328, 68, 342, 68), P.ember.deep); c:put(333, 65, P.ember.hi)
c:put(335, 71, P.ink); c:put(335, 72, P.ink)

-- hut B: cream plaster + violet slate roof, chimney
shadow(424, 141, 36, 3)
local wallB = c:rect(392, 104, 452, 140)
surf(wallB, R.plaster, { band = 3, tex = function(x, y)
  if H(floor(x / 3), floor(y / 2), 91) > .9 then return -1 end
  if y > 134 and H(x, y, 92) > .5 then return -1 end
  return 0 end })
-- timber posts on corners
c:fillMask(c:rect(392, 104, 395, 140), P.wood.shade); c:fillMask(c:rect(449, 104, 452, 140), P.wood.shade)
local chim = c:rect(438, 66, 447, 86)
surf(chim, P.stone, { band = 2, tex = bricks(5, 4, 438, 66) })
local roofB = c:poly{ {384, 106}, {460, 106}, {442, 78}, {404, 78} }
surf(roofB, P.dusk, { band = 3, tex = tilesT })
mossOn(roofB, .86)
for x = 386, 458 do c:put(x, 107, P.dusk.deep) end
local doorB = c:rrect(408, 116, 424, 140, 3)
surf(doorB, P.sea, { band = 2, tex = planksV(4, 408) })
c:put(420, 128, P.gold.hi)
glowWin(432, 112, 444, 123, "#fff0c4")
c:fillMask(c:rect(430, 124, 446, 125), P.petal.shade) -- flower box
for x = 431, 445, 3 do c:put(x, 123, P.petal.hi); c:put(x + 1, 123, P.gold.hi) end
wisp(443, 62, 22, "#eadff3", 0); wisp(446, 58, 14, "#f3eaf5", 2)

------------------------------------------------------------------ DO: the wayside shrine (centre)
shadow(240, 149, 54, 4)
local step1 = c:rect(194, 138, 286, 148)
surf(step1, P.stone, { band = 2, tex = bricks(12, 5, 194, 138) })
mossOn(step1, .8)
local step2 = c:rect(204, 128, 276, 137)
surf(step2, P.stone, { band = 2, tex = bricks(10, 5, 206, 128) })
local body = c:rect(214, 96, 266, 127)
surf(body, P.stone, { band = 3, tex = bricks(10, 6, 214, 96) })
mossOn(body, .84)
-- niche with candle glow
local niche = c:rect(228, 106, 252, 125):add(c:poly{ {228, 106}, {240, 98}, {252, 106} })
c:fillMask(niche, "#6e2f3a")
c:fillMask(niche:shrink(2), P.gold.deep)
c:fillMask(c:ellipse(240, 116, 7, 8):clip(niche:shrink(3)), P.gold.shade)
c:fillMask(c:ellipse(240, 114, 4, 5):clip(niche:shrink(4)), P.gold.base)
c:fillMask(c:rect(238, 116, 242, 124), P.cream); c:fillMask(c:rect(241, 116, 242, 124), P.plaster and P.cream or P.cream)
c:fillMask(c:rect(241, 117, 242, 124), "#e8d6b0")
c:fillMask(c:poly{ {240, 108}, {242, 113}, {240, 115}, {238, 113} }, P.gold.hi); c:put(240, 112, P.cream)
c:fillMask(niche:edge(), P.stone.deep)
-- roof (vermilion, upturned eaves)
local roof = c:poly{ {198, 98}, {282, 98}, {274, 88}, {254, 74}, {226, 74}, {206, 88} }
roof:add(c:poly{ {190, 92}, {200, 92}, {204, 98}, {196, 98} }):add(c:poly{ {280, 92}, {290, 92}, {284, 98}, {276, 98} })
surf(roof, P.ember, { band = 3, tex = tilesT })
local ridge = c:rect(222, 70, 258, 74)
surf(ridge, R.bark, { band = 1 })
c:fillMask(c:rect(219, 68, 223, 71), R.bark.shade); c:fillMask(c:rect(257, 68, 261, 71), R.bark.shade)
mossOn(c:poly{ {214, 90}, {232, 90}, {232, 80}, {222, 82} }, .7)
for x = 200, 280 do c:put(x, 99, P.stone.deep) end
-- twisted straw rope with paper zigzags
for x = 214, 266 do
  local y = 101 + floor(3 * (1 - ((x - 240) / 26)^2) + .5)
  c:put(x, y, (x % 3 == 0) and R.thatch.shade or R.thatch.base); c:put(x, y + 1, R.thatch.deep)
end
for _, zx in ipairs({ 222, 240, 258 }) do
  local zy = 105 + ((zx == 240) and 0 or -1)
  c:fillMask(c:poly{ {zx - 2, zy}, {zx + 2, zy}, {zx + 2, zy + 3}, {zx, zy + 3}, {zx, zy + 6}, {zx - 2, zy + 6} }, P.cream)
  c:put(zx - 2, zy + 6, "#e0d2c0"); c:put(zx + 2, zy + 3, "#e0d2c0")
end
-- offering bowl with peaches
for _, f in ipairs({ {234, 124, P.ember}, {240, 122, P.gold}, {246, 124, P.petal} }) do
  local m = c:ellipse(f[1], f[2], 3.5, 3)
  surf(m, f[3], { band = 1 }); c:put(f[1] - 1, f[2] - 1, f[3].hi)
end
c:fillMask(c:rect(239, 117, 240, 119), P.moss.base)
local bowl = c:poly{ {226, 126}, {254, 126}, {249, 134}, {231, 134} }
surf(bowl, P.gold, { band = 2, tex = function(x, y) if y == 128 then return 1 end return 0 end })
c:fillMask(c:rect(234, 135, 246, 137), P.gold.deep)
-- QUIRK: a teapot left as an offering, still steaming
local pot = c:poly{ {270, 131}, {280, 131}, {282, 134}, {280, 138}, {270, 138}, {268, 134} }
surf(pot, P.sea, { band = 1 })
c:fillMask(c:line({ {282, 133}, {285, 130} }, 1), P.sea.deep)
c:fillMask(c:rect(273, 129, 277, 130), P.sea.shade); c:put(275, 128, P.sea.deep)
wisp(285, 128, 9, "#f3eaf5", 1)
-- stone lantern in a knitted scarf (QUIRK) to the left of the shrine
shadow(191, 149, 9, 2)
surf(c:rect(185, 142, 197, 148), P.stone, { band = 1 })
surf(c:rect(189, 124, 193, 141), P.stone, { band = 1 })
local fb = c:rect(184, 111, 198, 123)
surf(fb, P.stone, { band = 2 })
c:fillMask(c:rect(188, 114, 194, 120), P.gold.base); c:fillMask(c:rect(189, 115, 192, 118), P.gold.hi)
surf(c:poly{ {180, 111}, {202, 111}, {196, 104}, {186, 104} }, P.stone, { band = 1 })
c:fillMask(c:rect(190, 101, 192, 103), P.stone.shade)
local scarf = c:rect(188, 124, 194, 127):add(c:rect(193, 127, 196, 135))
surf(scarf, P.petal, { band = 1, tex = function(x, y) if (x + y) % 3 == 0 then return -1 end return 0 end })
-- incense haze drifting over the roof
wisp(258, 70, 24, "#efe4f6", 0); wisp(266, 66, 18, "#e6daf2", 1.5); wisp(226, 68, 14, "#efe4f6", 3)

------------------------------------------------------------------ STOP: notice board + stamp post (left)
shadow(72, 147, 46, 3)
for _, px in ipairs({ 34, 98 }) do surf(c:rect(px, 80, px + 5, 146), P.wood, { band = 2, tex = planksV(9, px) }) end
local board = c:rect(40, 86, 97, 124)
surf(board, R.cork, { band = 3, tex = function(x, y) if H(x, y, 101) > .9 then return -1 end if H(x, y, 102) > .93 then return 1 end return 0 end })
local nroof = c:poly{ {26, 84}, {110, 84}, {100, 68}, {36, 68} }
surf(nroof, P.sea, { band = 3, tex = tilesT })
for x = 28, 108 do c:put(x, 85, P.sea.deep) end
local function note(x0, y0, x1, y1, r)
  surf(c:rect(x0, y0, x1, y1), r, { band = 1, noside = true })
  c:put(floor((x0 + x1) / 2), y0 + 1, P.ember.base)
end
note(44, 90, 58, 105, R.plaster)    -- footprint-trail icon
for i, p in ipairs({ {47, 102}, {50, 98}, {53, 101}, {55, 95} }) do c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), P.wood.shade) end
note(62, 91, 77, 108, P.sky)        -- map icon
c:fillMask(c:line({ {64, 104}, {68, 98}, {72, 101}, {75, 94} }, 1), P.sea.deep); c:fillMask(c:rect(74, 95, 75, 96), P.ember.base)
note(81, 89, 94, 102, P.petal)      -- bell icon (ring for the shrine)
c:fillMask(c:poly{ {85, 99}, {91, 99}, {90, 94}, {88, 92}, {86, 94} }, P.gold.base); c:put(88, 100, P.gold.deep)
note(46, 109, 60, 121, R.plaster)   -- teacup icon
c:fillMask(c:rect(50, 114, 55, 118), P.sea.base); c:put(56, 115, P.sea.deep); c:put(56, 116, P.sea.deep)
c:put(51, 112, "#d8c8e8"); c:put(53, 111, "#d8c8e8")
note(65, 111, 93, 121, P.gold)      -- stamp card: three stamp slots
for i = 0, 2 do
  local sx = 68 + i * 8
  c:fillMask(c:rect(sx, 113, sx + 5, 119), P.cream)
  if i < 2 then c:fillMask(c:poly{ {sx + 1, 118}, {sx + 4, 118}, {sx + 4, 115}, {sx + 2, 114}, {sx + 1, 115} }, P.ember.shade) end
end
-- stamp post
surf(c:rect(110, 104, 115, 146), P.wood, { band = 2 })
local sbox = c:rect(104, 92, 121, 105)
surf(sbox, P.ember, { band = 2 })
surf(c:rect(103, 89, 122, 92), R.bark, { band = 1 })
c:fillMask(c:rect(110, 97, 115, 100), P.gold.base); c:put(110, 97, P.gold.hi)
for y = 106, 110 do c:put(119, y, P.wood.deep) end
surf(c:rect(117, 111, 121, 116), P.wood, { band = 1 })
surf(c:rect(116, 117, 122, 121), P.gold, { band = 1 })

-- QUIRK: cairn wearing a little gnome hat
do
  local stones = { {136, 157, 8, 3, P.stone}, {137, 151, 6, 3, R.plaster}, {136, 146, 5, 2, P.stone}, {137, 142, 3, 2, P.sky} }
  shadow(137, 160, 10, 2)
  for _, s in ipairs(stones) do surf(c:ellipse(s[1], s[2], s[3], s[4]), s[5], { band = 1 }) end
  local hat = c:poly{ {133, 140}, {141, 140}, {139, 134}, {137, 129}, {135, 133} }
  surf(hat, P.ember, { band = 1 }); c:put(137, 128, P.gold.hi)
end

------------------------------------------------------------------ WILD: branch arch leaving to the right
shadow(426, 227, 38, 3)
local inside = c:rect(406, 178, 450, 226):add(c:ellipse(428, 180, 22, 10))
c:fillMask(inside, P.moss.deep)
inside:each(function(x, y) if H(floor(x / 3), floor(y / 3), 111) > .7 then c:put(x, y, "#2f6650") end end)
local trail = c:poly{ {412, 226}, {446, 226}, {440, 200}, {450, 186}, {446, 184}, {432, 198} }
trail:clip(inside)
trail:each(function(x, y) c:put(x, y, H(x, y, 112) > .85 and R.earth.base or R.earth.shade) end)
-- far light at the end of the trail
c:fillMask(c:rect(444, 182, 450, 188):clip(inside), "#f5e3a8")
-- ferns inside
for _, f in ipairs({ {414, 212}, {442, 216}, {418, 196} }) do
  for k = -3, 3 do c:fillMask(c:line({ {f[1], f[2]}, {f[1] + k * 2, f[2] - 6 + abs(k)} }, 1), P.moss.shade) end
end
local arch = c:rect(398, 176, 407, 226):add(c:rect(449, 176, 458, 226))
arch:add(c:line({ {402, 182}, {408, 170}, {418, 163}, {428, 161}, {438, 163}, {448, 170}, {454, 182} }, 7))
surf(arch, R.bark, { band = 2, tex = function(x, y) if (y + floor(x / 3)) % 5 == 0 then return -1 end return 0 end })
local leaves = c:ellipse(406, 168, 9, 6):add(c:ellipse(428, 158, 12, 5)):add(c:ellipse(451, 168, 9, 6)):add(c:ellipse(398, 190, 4, 6)):add(c:ellipse(459, 196, 4, 7))
surf(leaves, P.moss, { band = 2, tex = function(x, y) local h = H(floor(x / 3), floor(y / 2), 113) if h > .7 then return 1 elseif h < .2 then return -1 end return 0 end })
-- hanging arrow sign (right-pointing) with a leaf icon
for y = 173, 184 do c:put(418, y, R.bark.deep); c:put(438, y, R.bark.deep) end
local sign = c:poly{ {412, 185}, {440, 185}, {447, 190}, {440, 195}, {412, 195} }
surf(sign, P.gold, { band = 2, tex = planksH(4, 185) })
c:fillMask(c:poly{ {418, 192}, {424, 187}, {428, 188}, {422, 193} }, P.moss.shade); c:put(423, 190, P.moss.hi)
c:fillMask(c:poly{ {431, 188}, {437, 190}, {431, 192} }, P.wood.deep)

------------------------------------------------------------------ PEOPLE: pilgrims' bench + fire with kettle (near left)
shadow(60, 245, 40, 4)
for _, lx in ipairs({ 28, 88 }) do surf(c:rect(lx, 214, lx + 5, 244), P.wood, { band = 2 }) end
local back = c:rect(22, 208, 98, 216)
surf(back, P.wood, { band = 2, tex = planksH(4, 208) })
local seat = c:rect(20, 226, 100, 233)
surf(seat, P.wood, { band = 2, tex = planksH(4, 226) })
for _, lx in ipairs({ 26, 90 }) do surf(c:rect(lx, 234, lx + 5, 248), P.wood, { band = 2 }) end
-- cushion + folded travel blanket
surf(c:poly{ {34, 220}, {54, 220}, {56, 226}, {32, 226} }, P.dusk, { band = 1 })
surf(c:rect(64, 221, 82, 226), P.sea, { band = 1, tex = function(x, y) if x % 4 == 0 then return 1 end return 0 end })
-- fire pit (octagon stone ring)
shadow(124, 255, 20, 3)
local ring = c:poly{ {108, 242}, {113, 237}, {135, 237}, {140, 242}, {140, 251}, {135, 255}, {113, 255}, {108, 251} }
surf(ring, P.stone, { band = 2, tex = function(x, y) if (x + floor(y / 4) * 3) % 7 == 0 then return -1 end return 0 end })
local ash = c:poly{ {114, 241}, {134, 241}, {136, 244}, {134, 248}, {114, 248}, {112, 244} }
c:fillMask(ash, "#5b4552")
surf(c:rect(116, 244, 132, 247), R.bark, { band = 1 })
local fire = c:poly{ {116, 245}, {132, 245}, {131, 238}, {127, 232}, {125, 236}, {123, 228}, {120, 237}, {117, 236} }
c:fillMask(fire, P.ember.base)
c:fillMask(c:poly{ {119, 245}, {129, 245}, {128, 239}, {124, 233}, {121, 239} }, P.gold.base)
c:fillMask(c:poly{ {122, 245}, {127, 245}, {126, 241}, {124, 238} }, P.gold.hi)
-- tripod + kettle
c:fillMask(c:line({ {110, 256}, {124, 212} }, 2), R.bark.base)
c:fillMask(c:line({ {138, 256}, {124, 212} }, 2), R.bark.shade)
for y = 214, 219 do c:put(124, y, P.stone.deep) end
local kettle = c:poly{ {116, 222}, {132, 222}, {134, 227}, {130, 230}, {118, 230}, {114, 227} }
surf(kettle, P.stone, { band = 2 })
c:fillMask(c:rect(121, 219, 127, 221), P.stone.shade); c:put(124, 218, P.stone.deep)
c:fillMask(c:line({ {134, 225}, {138, 222} }, 1), P.stone.deep)
wisp(139, 220, 12, "#f3eaf5", .5)

-- QUIRK: an old boot planted with flowers (near, right of the path)
shadow(363, 256, 11, 2)
local boot = c:poly{ {356, 240}, {364, 240}, {364, 249}, {372, 251}, {372, 256}, {354, 256}, {355, 248} }
surf(boot, R.bark, { band = 2, tex = function(x, y) if y == 252 then return -1 end return 0 end })
for _, fl in ipairs({ {357, 235, P.petal}, {361, 233, P.gold}, {365, 236, P.sky} }) do
  c:fillMask(c:rect(fl[1], fl[2] + 2, fl[1], 240), P.moss.shade)
  c:fillMask(c:rect(fl[1] - 1, fl[2] - 1, fl[1] + 1, fl[2] + 1), fl[3].base)
  c:put(fl[1], fl[2], P.gold.hi); c:put(fl[1] - 1, fl[2] - 1, fl[3].hi)
end

-- sprinkle a few wildflowers (never on stand points, compass corner or spots)
for i = 1, 70 do
  local x = floor(H(i, 7, 121) * 440) + 20; local y = 150 + floor(H(i, 8, 121) * 115)
  local inPath = abs(x - 240) < hw(y) + 4
  local busy = (x < 150 and y > 200) or (x > 340 and y > 228) or (x > 385 and y > 150) or (x < 125 and y < 150)
  if not inPath and not busy and not nearStand(x, y, 31) then
    local col = ({ P.petal.hi, P.gold.hi, P.cream, P.dusk.hi })[1 + floor(H(i, 9, 121) * 4)]
    c:put(x, y, col); c:put(x, y + 1, R.grass.shade)
  end
end

------------------------------------------------------------------ GATE FRAME: weathered timber posts + beam, straw rope, lantern, bell
local lpost = c:rect(0, 0, 15, Hh - 1)
local rpost = c:rect(464, 0, 479, Hh - 1)
surf(lpost, R.frame, { band = 4, tex = planksV(5, 0) })
surf(rpost, R.frame, { band = 4, tex = planksV(5, 464) })
local beam = c:rect(0, 0, 479, 13)
surf(beam, R.frame, { band = 3, tex = planksH(5, 0) })
surf(c:rect(10, 13, 19, 20), R.frame, { band = 2 }); surf(c:rect(460, 13, 469, 20), R.frame, { band = 2 }) -- brackets
mossOn(c:rect(0, 248, 15, Hh - 1), .55); mossOn(c:rect(464, 248, 479, Hh - 1), .55)
mossOn(c:rect(20, 0, 460, 6), .9)
-- blossom sprigs on beam corners
for _, b in ipairs({ {24, 12}, {34, 15}, {452, 12}, {444, 16}, {14, 22} }) do
  local m = c:ellipse(b[1], b[2], 5, 3)
  surf(m, P.petal, { band = 1 }); c:put(b[1] - 1, b[2] - 1, P.cream)
end
-- straw rope with paper zigzag charms along the top
for x = 16, 463 do
  local y = 15 + floor(8 * (1 - ((x - 240) / 224)^2) + .5)
  c:put(x, y, (x % 4 < 2) and R.thatch.base or R.thatch.shade); c:put(x, y + 1, R.thatch.deep)
  if x % 56 == 40 then
    c:fillMask(c:poly{ {x - 2, y + 2}, {x + 2, y + 2}, {x + 2, y + 5}, {x, y + 5}, {x, y + 9}, {x - 2, y + 9} }, P.cream)
    c:put(x + 2, y + 5, "#e0d2c0"); c:put(x - 2, y + 9, "#e0d2c0")
  end
end
-- hanging paper lantern (left)
for y = 14, 27 do c:put(40, y, R.frame.deep) end
local lan = c:rrect(32, 28, 48, 48, 4)
surf(lan, P.ember, { band = 3, tex = function(x, y) if (y - 28) % 5 == 0 then return -1 end return 0 end })
c:fillMask(c:rect(36, 33, 43, 43), P.gold.base); c:fillMask(c:rect(37, 34, 40, 40), P.gold.hi)
for y = 33, 43 do if (y - 28) % 5 == 0 then for x = 36, 43 do c:put(x, y, P.gold.shade) end end end
surf(c:rect(34, 26, 46, 28), R.frame, { band = 1 }); surf(c:rect(34, 48, 46, 50), R.frame, { band = 1 })
for y = 51, 56 do c:put(39 + (y % 2), y, P.gold.shade) end
-- bronze bell with rope and ribbon (right)
for y = 14, 27 do c:put(438, y, R.frame.deep) end
surf(c:rect(434, 26, 442, 28), R.frame, { band = 1 })
local bell = c:poly{ {432, 29}, {444, 29}, {446, 38}, {451, 46}, {425, 46}, {430, 38} }
surf(bell, R.bronze, { band = 3, tex = function(x, y) if y == 41 then return -1 end if y == 33 then return 1 end return 0 end })
c:fillMask(c:rect(436, 47, 440, 50), R.bronze.deep)
for y = 47, 62 do c:put(438 + floor(sin(y / 3) + .5), y, P.petal.base); c:put(439 + floor(sin(y / 3) + .5), y, P.petal.shade) end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

-- layout
local spots = {
  { k = "do", name = "Wayside Shrine", box = { 180, 58, 296, 152 } },
  { k = "people", name = "Pilgrims' Bench", box = { 16, 204, 150, 262 } },
  { k = "stop", name = "Shrine Notice Post", box = { 24, 62, 124, 150 } },
  { k = "homes", name = "Keeper Huts", box = { 298, 60, 462, 152 } },
  { k = "wild", name = "Wild Trail", box = { 388, 156, 462, 228 } },
}
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}',
    s.k, s.name, floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, s in ipairs(STAND) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":112,"view":"gate","spots":[' .. table.concat(parts, ",") ..
  '],"stand":[' .. table.concat(st, ",") .. '],"compass_clear":[380,230,480,270]}')
f:close()
print("ok " .. NAME)
