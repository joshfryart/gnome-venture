-- stage-coast v3: clear-day base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-coast" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local SAND = { hi = "#fff0b8", base = "#f2cf80", shade = "#d9a45e", deep = "#a8704a" }
local WOOD = { hi = "#e8c890", base = "#b88a5c", shade = "#835e4c", deep = "#4e3640" }
local ROCK = { hi = "#c8c0d0", base = "#8e88a4", shade = "#605c80", deep = "#363452" }
local GRASS = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local RED = { hi = "#ff9a80", base = "#e8503c", shade = "#b03038", deep = "#6e2038" }
local WHITE = { hi = "#fffaf0", base = "#f4ead8", shade = "#d0c0c0", deep = "#9a8aa0" }
local BLUE = { hi = "#8ae0f0", base = "#3c9cd0", shade = "#2a64a8", deep = "#1f3c70" }
local MOSS = { hi = "#b4d060", base = "#6a9a38", shade = "#46703c", deep = "#2a4a3c" }

-- sky and sea
GX.bands(c, 0, 92, { "#7cc4ee", "#98d4f4", "#b4e4f6", "#cdf0f4", "#e4f8ec", "#fff0cc" }, 3, .2)
local SEA6 = { "#8ae8e0", "#5cd0d4", "#3cb8c8", "#34a0c0", "#2a84b0", "#2670a8" }
GX.bands(c, 90, 156, SEA6, 9, .16)
for y = 91, 155 do for x = 0, 479 do
  local n = GX.vn(x * .45, y, 3, 14)
  if n > .76 and y % 3 == 0 then c:px(x, y, y < 112 and "#d8fff4" or "#7ae0e0") end
  if n < .12 and y % 4 == 1 then c:px(x, y, "#2a84b0") end
end end
-- far island
local isl = mk(); E(isl, 120, 91, 36, 5); E(isl, 100, 88, 14, 4); isl = GX.rough(isl, 8, 1)
GX.lit(c, isl, R6({ hi = "#a8d8c0", base = "#7cb8a8", shade = "#5a98a0", deep = "#487890" }), { R = 4, tex = .3, seed = 2, ink = false })
-- sailboats
local function sailboat(x, y, s)
  local sail = c:poly{ { x, y - 24 * s }, { x, y - 2 }, { x + 13 * s, y - 2 } }
  GX.lit(c, sail, R6(WHITE), { R = 8, tex = .2, seed = x, ink = false })
  local jib = c:poly{ { x - 2, y - 18 * s }, { x - 2, y - 2 }, { x - 10 * s, y - 2 } }
  GX.lit(c, jib, R6({ hi = "#ffd0b8", base = "#f0a090", shade = "#c87078", deep = "#8a4858" }), { R = 6, tex = .2, seed = x + 1, ink = false })
  local hull = c:poly{ { x - 11 * s, y - 1 }, { x + 15 * s, y - 1 }, { x + 11 * s, y + 3 }, { x - 7 * s, y + 3 } }
  GX.lit(c, hull, R6(WOOD), { R = 3, tex = .2, seed = x + 2, rimlight = true })
  for k = -9, 11 do if H(k, x, 4) > .4 then c:px(x + k, y + 4, "#e8fff8") end end
end
sailboat(150, 112, 1); sailboat(268, 100, .75)

-- shoreline and sand
local function shore(x) return 156 + floor(2.5 * sin(x / 31 + 1) + 1.5 * sin(x / 11)) end
GX.ground(c, shore, SAND, 7, { top = .86, fall = .5, tex = .24, sc = 9 })
for x = 0, 479 do
  local y0 = shore(x)
  for y = y0, y0 + 7 do
    local t = (y - y0) / 7
    if GX.vn(x, y, 4, 33) > t * .9 + .1 then c:px(x, y, (y - y0 < 3) and "#c8a068" or "#e0b878") end
  end
  c:px(x, y0 - 1, "#f4fffa"); if H(x, 1, 5) > .35 then c:px(x, y0 - 2, "#ffffff") end
  if H(x // 3, 2, 5) > .5 then c:px(x, y0, "#e8fff8") end
end
for y = 172, 269 do for x = 0, 479 do   -- ripples
  local w = sin((y + GX.vn(x, y, 22, 41) * 9) * .85)
  if w > .94 and GX.vn(x, y, 6, 42) > .45 then c:px(x, y, SAND.shade)
  elseif w < -.97 and GX.vn(x, y, 6, 43) > .5 then c:px(x, y, SAND.hi) end
end end

-- headland with lighthouse (right)
local function top(x) return 136 - floor(max(0, x - 322) * .24) + floor((GX.vn(x, 0, 12, 3) - .5) * 5) end
local hl = mk()
for x = 322, 479 do for y = min(top(x), 128), 166 + floor((GX.vn(x, 1, 10, 4)) * 4) do if y >= top(x) then hl:set(x, y) end end end
hl = GX.rough(hl, 61, 2)
local function hland(x, y) return (y > top(x) + 15 + floor(GX.vn(x, 0, 9, 8) * 4)) and R6(ROCK) or R6(GRASS) end
GX.lit(c, hl, hland, { R = 16, tex = .6, sc = 3.2, seed = 61, rimlight = true, amb = .24,
  fn = function(x, y) return (H(x // 3, y // 3, 61) - .5) * .2 end })
for i = 0, 40 do   -- rock cracks and grass tufts
  local x = 330 + floor(H(i, 1, 9) * 145)
  if hl:has(x, top(x) + 1) then GX.tuft(c, x, top(x) + 4 + floor(H(i, 2, 9) * 8), { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }) end
end
-- lighthouse tower
local tw = mk()
for y = 40, 128 do
  local hw = 8 + floor((y - 40) * .1)
  for x = 446 - hw, 446 + hw do tw:set(x, y) end
end
tw = GX.rough(tw, 71, 1)
GX.lit(c, tw, function(x, y) return ((y - 40) // 11) % 2 == 0 and R6(RED) or R6(WHITE) end,
  { R = 9, tex = .3, sc = 3, seed = 71, rimlight = true, amb = .22 })
-- gallery, lantern, roof
local gal = c:rect(433, 36, 459, 40); GX.lit(c, gal, R6({ hi = "#8a8aa0", base = "#5c5878", shade = "#3c3858", deep = "#2a2440" }), { R = 3, tex = .2, seed = 5 })
local lan = c:rect(438, 24, 454, 35); GX.lit(c, lan, R6({ hi = "#fff8c0", base = "#ffe070", shade = "#e0a850", deep = "#a06a40" }), { R = 6, tex = .15, seed = 6 })
for _, x in ipairs{ 438, 446, 454 } do c:fillMask(c:rect(x, 24, x, 35), INK) end
local roof = c:poly{ { 435, 24 }, { 457, 24 }, { 446, 12 } }
GX.lit(c, roof, R6(RED), { R = 8, tex = .2, seed = 7, rimlight = true })
c:px(446, 9, INK); c:px(446, 10, INK); c:px(446, 11, INK)
local dr = c:rect(443, 112, 449, 128); GX.lit(c, dr, R6(WOOD), { R = 4, tex = .2, seed = 8 })
for _, y in ipairs{ 62, 84 } do c:fillMask(c:rect(444, y, 448, y + 5), INK); c:fillMask(c:rect(445, y + 1, 447, y + 4), "#7cc4ee") end
-- house
local hs = c:rect(374, 108, 412, 134); GX.lit(c, hs, R6({ hi = "#fffaf0", base = "#f4e4cc", shade = "#d0b0a0", deep = "#8a6a78" }), { R = 12, tex = .3, seed = 9, rimlight = true })
local hr = c:poly{ { 369, 109 }, { 417, 109 }, { 405, 92 }, { 381, 92 } }
GX.lit(c, hr, R6(RED), { R = 12, tex = .35, sc = 2.4, seed = 10, rimlight = true })
c:fillMask(c:rect(380, 116, 388, 124), INK); c:fillMask(c:rect(381, 117, 387, 123), "#7cc4ee"); c:px(381, 117, "#e8fffa"); c:px(384, 117, INK); c:px(384, 118, INK); c:px(384, 119, INK)
local dh = c:rect(398, 118, 405, 134); GX.lit(c, dh, R6(WOOD), { R = 4, tex = .2, seed = 11 })
c:px(399, 126, "#ffe070")
-- hillside flowers by the house
for i = 0, 5 do local x = 340 + i * 5 + floor(H(i, 2, 2) * 4); if hl:has(x, top(x) + 6) then GX.flower(c, x, top(x) + 6, i % 2 == 0 and "#ff9fc0" or "#fff4d6") end end

-- rock with moss (left)
local rk = mk(); E(rk, 44, 152, 30, 15); E(rk, 26, 156, 16, 11); rk = GX.rough(rk, 81, 2)
rk:cut(c:rect(0, 160, 120, 175))
local sh = mk(); E(sh, 50, 168, 42, 4); c:fillMask(sh, "#c8985c")
GX.lit(c, rk, R6(ROCK), { R = 14, tex = .55, sc = 3.2, seed = 81, rimlight = true, amb = .22 })
local mm = mk(); E(mm, 62, 140, 14, 6); E(mm, 40, 138, 9, 4); mm = GX.rough(mm, 82, 1)
for y = 120, 170 do for x = 0, 100 do if mm:has(x, y) and rk:has(x, y) then
  local m6 = R6(MOSS); c:px(x, y, m6[2 + floor(GX.vn(x, y, 3, 5) * 3 + (140 - y) * -.05)] or m6[3]) end end end
for i = 0, 8 do local x = 50 + floor(H(i, 3, 3) * 22); if rk:has(x, 140) or rk:has(x, 143) then c:px(x, 139 + i % 3, MOSS.hi) end end
c:fillMask(c:rect(14, 160, 70, 160), "#b88c5c")

-- rowing boat (hero)
local bsh = mk(); E(bsh, 238, 190, 66, 5); c:fillMask(GX.rough(bsh, 5, 1), "#c8985c")
local hull = mk()
for y = 150, 186 do
  local t = (y - 150) / 36
  local x0 = floor(174 + t * 20 + (t^2) * 4); local x1 = floor(298 - t * 22 - (t^2) * 4)
  if t > .8 then x0 = x0 + floor((t - .8) * 20); x1 = x1 - floor((t - .8) * 20) end
  for x = x0, x1 do hull:set(x, y) end
end
hull = GX.rough(hull, 91, 1)
GX.lit(c, hull, function(x, y)
  if y < 158 then return R6(WOOD) elseif y < 163 then return R6(WHITE) elseif y < 168 then return R6(BLUE) elseif y < 171 then return R6(WHITE) else return R6(BLUE) end
end, { R = 22, tex = .35, sc = 3, seed = 91, rimlight = true, amb = .24,
  fn = function(x, y) return (GX.vn(x * .12, y, 2, 6) - .5) * .25 end })
local gw = mk(); for x = 172, 300 do for y = 149, 154 do gw:set(x, y) end end; gw = GX.rough(gw, 92, 1)
GX.lit(c, gw, R6(WOOD), { R = 3, tex = .3, sc = 2, seed = 93, rimlight = true })
for x = 180, 292, 14 do c:px(x, 155, WOOD.deep); c:px(x + 1, 155, WOOD.deep) end
c:fillMask(c:rect(200, 188, 276, 188), "#a8704a")
-- oar resting across
local oar = c:poly{ { 222, 151 }, { 226, 148 }, { 296, 118 }, { 292, 114 } }
GX.lit(c, oar, R6(WOOD), { R = 3, tex = .2, seed = 94, rimlight = true })
local bl = c:poly{ { 288, 120 }, { 296, 110 }, { 306, 118 }, { 298, 128 } }
GX.lit(c, bl, R6(WOOD), { R = 5, tex = .3, seed = 95, rimlight = true })
-- quirk: a tiny green bottle with a note in the boat
c:fillMask(c:rect(252, 144, 254, 150), INK); c:fillMask(c:rect(253, 146, 253, 149), "#6cc050"); c:px(253, 145, "#fffaf0")

-- calm foreground: pebbles, shells, tufts, flowers (kept sparse, y>180)
local PEB = { hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }
for i = 0, 44 do
  local x, y = 8 + floor(H(i, 21, 5) * 465), 182 + floor(H(i, 22, 5) * 84)
  local m = mk(); E(m, x, y, 1 + i % 3, 1 + (i % 2))
  local pr = (i % 4 == 0) and { hi = "#ffd8c0", base = "#e8a090", shade = "#b87078", deep = "#7a4658" } or PEB
  GX.lit(c, m, R6(pr), { R = 2, tex = .15, seed = i, rimlight = true })
end
local function shell(x, y, col)
  local m = c:poly{ { x - 5, y }, { x - 4, y - 3 }, { x - 2, y - 5 }, { x + 2, y - 5 }, { x + 4, y - 3 }, { x + 5, y } }
  GX.lit(c, m, R6(col), { R = 3, tex = .1, seed = x, rimlight = true })
  for k = -3, 3, 2 do c:px(x + k, y - 1, col.shade) end
end
shell(110, 222, { hi = "#fff0e8", base = "#f4b8a8", shade = "#d08088", deep = "#80485a" })
shell(352, 240, { hi = "#fff8e0", base = "#f0d8a0", shade = "#c0985c", deep = "#7a5a48" })
for i = 0, 12 do
  local x, y = 6 + floor(H(i, 61, 1) * 470), 196 + floor(H(i, 63, 1) * 70)
  GX.tuft(c, x, y, { hi = "#d8e888", base = "#a8c060", shade = "#6c9050", deep = "#486a46" })
end
for i = 0, 5 do GX.flower(c, 30 + floor(H(i, 41, 1) * 420), 200 + floor(H(i, 43, 1) * 60), i % 2 == 0 and "#ff9fc0" or "#fff4d6") end
for _, k in ipairs{ { 40, 248, 22, 1 }, { 400, 232, 18, -1 } } do   -- washed-up kelp
  for i = 0, k[3] do
    local x, y = k[1] + i * k[4], k[2] + floor(sin(i / 3.2) * 2)
    c:px(x, y - 1, MOSS.hi); c:px(x, y, MOSS.base); c:px(x, y + 1, MOSS.shade)
  end
end

c:save{ aseprite = d.."/out/stage-coast.aseprite", png = d.."/out/stage-coast.png", scale = 1 }
