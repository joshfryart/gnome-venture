local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "firefly" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local ROCK = { hi = "#7a6aa4", base = "#4e4478", shade = "#342e58", deep = "#201c3c" }
local VIO  = { hi = "#a48ac8", base = "#6e5a9c", shade = "#483c76", deep = "#2c2650" }
local BUG  = { hi = "#b88a6a", base = "#74482e", shade = "#472c2c", deep = "#2a1a28" }
local GLO  = { hi = "#f6ffa0", base = "#c8e24a", shade = "#7ea838", deep = "#3e6a34" }
local WING = { hi = "#f0f4ff", base = "#b4c8ee", shade = "#7c90c8", deep = "#5468a4" }
local TEAL = { hi = "#b8fff0", base = "#38d0c4", shade = "#1e8aa0", deep = "#16506c" }
local PINK = { hi = "#ffc0e8", base = "#e458b4", shade = "#a42c8c", deep = "#5c1c5c" }
local WOOD = { hi = "#d09a5a", base = "#8c5438", shade = "#5c3436", deep = "#34202c" }
local GOLD = "#e8b84a"

---------------------------------------------------------------- backdrop cave dark
GX.bands(c, 0, 269, { "#1c2250", "#202a5a", "#243464", "#283c6c", "#2a4474" }, 3, .25)

---------------------------------------------------------------- lake
local LAKEY = 186
for y = LAKEY, 269 do for x = 0, 479 do
  local t = (y - LAKEY) / (270 - LAKEY) + (GX.vn(x * .35, y, 5, 9) - .5) * .35
  local cols = { "#2a5a84", "#224e78", "#1c4068", "#183458", "#142a48" }
  c:px(x, y, cols[max(1, min(5, floor(t * 5) + 1))])
end end
for i = 0, 60 do
  local x, y = floor(H(i, 1, 2) * 470), LAKEY + 3 + floor(H(i, 2, 2) * 78)
  c:fillMask(c:rect(x, y, x + 5 + floor(H(i, 3, 2) * 12), y), i % 3 == 0 and "#5a90b8" or "#1a3a60")
end

---------------------------------------------------------------- arch window (mountain scene)
local function archmask(cx, top, bot, hw)
  local m = mk(); E(m, cx, top + hw, hw, hw)
  for y = top + hw, bot do for x = cx - hw, cx + hw do m:set(x, y) end end
  return m
end
local ax, atop, abot, ahw = 240, 106, 188, 27
for i = 5, 1, -1 do   -- concentric halo rings
  local rm = archmask(ax, atop - i * 3, abot, ahw + i * 3); rm = GX.rough(rm, 20 + i, 1)
  c:fillMask(rm, ({ "#7ab0e8", "#648ed0", "#4e72b8", "#3a5aa0", "#2e4888" })[i])
end
local am = archmask(ax, atop, abot, ahw); am = GX.rough(am, 30, 1)
am:each(function(x, y)
  local t = (y - atop) / (abot - atop)
  local cols = { "#3a5aa8", "#5a80c8", "#86a8e0", "#bcd4f0", "#e8ecf4" }
  c:px(x, y, cols[max(1, min(5, floor(t * 5.6) + 1))])
end)
local moon = mk(); E(moon, ax + 4, atop + 26, 8, 8); moon = GX.rough(moon, 33, 1)
GX.lit(c, moon, GX.ramp6({ hi = "#fffbe0", base = "#f4ecc4", shade = "#d4c8b0", deep = "#a8a0b8" }), { R = 8, ink = false, tex = .2 })
for _, mt in ipairs{ { ax - 14, 186, 38, 1 }, { ax + 12, 186, 44, 2 } } do   -- mountains
  local cx, by, h, k = mt[1], mt[2], mt[3], mt[4]
  local mm = mk()
  for x = cx - h, cx + h do
    local top = by - floor(max(0, h - abs(x - cx) * .95) + (GX.vn(x, 0, 4, 40 + k) - .5) * 6)
    for y = top, by do if am:has(x, y) then mm:set(x, y) end end
  end
  GX.lit(c, mm, GX.ramp6({ hi = "#a4c0e0", base = "#506ca4", shade = "#34487c", deep = "#243060" }), { R = 12, ink = false, tex = .4, seed = k, amb = .2 })
  mm:each(function(x, y) if y < by - h * .78 + (GX.vn(x, y, 3, k) - .5) * 5 and x < cx + 3 then c:px(x, y, "#f0f4ff") elseif y < by - h * .78 + 3 then c:px(x, y, "#b8c8ec") end end)
end
am:each(function(x, y) if y > LAKEY and y < LAKEY + 4 then c:px(x, y, "#86a8e0") end end)
c:rim(am, "#1c2250")
-- arch reflection on lake
for i = 0, 9 do c:fillMask(c:rect(ax - 12 + (i % 3) * 3, abot + 3 + i * 3, ax + 12 - (i % 4) * 2, abot + 3 + i * 3), i % 2 == 0 and "#4e78b8" or "#3a5e9c") end

---------------------------------------------------------------- glows (behind rock + bugs)
local FFS = { { 96, 106, 1 }, { 352, 98, 2 }, { 408, 150, 3 } }
local function glow(cx, cy, r)
  local cols = { "#3a6a3c", "#4a8040", "#5e9a42", "#7cb448", "#a0d052", "#c8e870" }
  for i = 1, 6 do
    local m = mk(); E(m, cx, cy, r - (i - 1) * 4, floor((r - (i - 1) * 4) * 1.05)); m = GX.rough(m, 50 + i + cx, 1)
    c:fillMask(m, cols[i])
  end
end
for _, f in ipairs(FFS) do glow(f[1], f[2] + 26, 36) end
for _, f in ipairs(FFS) do   -- lake reflections of glow
  for i = 0, 6 do local y = LAKEY + 8 + i * 5
    if y < 262 then c:fillMask(c:rect(f[1] - 11 + (i % 2) * 2, y, f[1] + 9 - (i % 3) * 2, y), i < 3 and "#a0c050" or "#5a8a48") end end
end

---------------------------------------------------------------- rock mass
local rock = mk()
local function wl(y) return 26 + floor(y * .13) + floor((GX.vn(0, y, 14, 60) - .5) * 14) end
local function wr(y) return 456 - floor(y * .1) + floor((GX.vn(0, y, 14, 61) - .5) * 14) end
local function ceil(x) return 30 + floor((GX.vn(x, 0, 30, 62) - .5) * 26) - floor(abs(x - 240) / 240 * 10) + floor(abs(x - 240) / 240 * 12) end
for y = 0, 270 do for x = 0, 479 do
  local inrock = y < ceil(x) or x < wl(y) or x > wr(y)
  if x < 90 and y > 210 + floor((GX.vn(x, 0, 12, 64) - .5) * 8) - floor(x * .05) then inrock = true end
  if x > 336 and y > 208 + floor((GX.vn(x, 0, 12, 65) - .5) * 10) + floor((470 - x) * .22 - 20) then inrock = true end
  if inrock then rock:set(x, y) end
end end
rock = GX.rough(rock, 66, 1)
GX.lit(c, rock, GX.ramp6(ROCK), { R = 14, tex = .8, sc = 4, seed = 5, amb = .28,
  fn = function(x, y) return (H(x // 3, y // 5, 8) - .5) * .18 end })
rock:each(function(x, y)   -- cracks
  if H(x // 4, y // 2, 12) < .02 and rock:has(x + 3, y) then c:px(x, y, ROCK.deep); c:px(x + 1, y, ROCK.deep); c:px(x + 2, y + 1, ROCK.deep) end
end)
-- inner edge ink + mossy glow tint where fireflies shine
-- rock sparkle
for i = 0, 40 do local x, y = floor(H(i, 5, 5) * 478), floor(H(i, 6, 5) * 270)
  if rock:has(x, y) and rock:has(x + 1, y) and rock:has(x, y + 1) then c:px(x, y, ROCK.hi) end end

---------------------------------------------------------------- stalactites
local function stal(cx, y0, len, hw, seed)
  local m = mk()
  for y = y0, y0 + len do
    local t = (y - y0) / len
    local w = floor(hw * (1 - t) ^ .8 + .5)
    for x = cx - w, cx + w do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(VIO), { R = hw, tex = .5, sc = 3, seed = seed, rimlight = true })
  c:px(cx, y0 + len + 1, "#a8e070")   -- drip-glow tip
end
for _, s in ipairs{ { 78, 26, 26, 8 }, { 124, 28, 22, 7 }, { 164, 34, 18, 6 }, { 196, 34, 30, 8 }, { 236, 32, 14, 5 }, { 284, 36, 34, 7 }, { 322, 32, 20, 7 }, { 386, 28, 18, 6 }, { 424, 26, 24, 7 } } do
  stal(s[1], s[2], s[3], s[4], s[1])
end
-- little stalagmites in lake
for _, s in ipairs{ { 214, 270, 20, 9 }, { 276, 270, 14, 7 } } do
  local m = mk()
  for y = s[2] - s[3], 269 do local t = (y - (s[2] - s[3])) / s[3]; for x = s[1] - floor(s[4] * t), s[1] + floor(s[4] * t) do m:set(x, y) end end
  m = GX.rough(m, s[1], 1); GX.lit(c, m, GX.ramp6(VIO), { R = 8, tex = .5, seed = s[1], rimlight = true })
end

---------------------------------------------------------------- fireflies
local function part(m, seed, R, o)
  o = o or {}; o.R = o.R or 8; o.tex = o.tex or .35; o.sc = 2.6; o.seed = seed; o.rimlight = true
  return GX.lit(c, m, GX.ramp6(R), o)
end
local function firefly(cx, cy, flip, seed)
  local f = flip and -1 or 1
  -- antennae
  for _, a in ipairs{ -1, 1 } do
    for i = 1, 8 do c:px(cx + a * (5 + i * 1), cy - 12 - i * 2 + (i > 5 and 1 or 0), INK) end
    local tx, ty = cx + a * 14, cy - 29
    c:fillMask(c:rect(tx - 1, ty - 1, tx + 1, ty + 1), "#c8e870"); c:px(tx, ty, "#f6ffa0")
    c:px(tx, ty - 2, "#7cb448"); c:px(tx - 2, ty, "#7cb448"); c:px(tx + 2, ty, "#7cb448"); c:px(tx, ty + 2, "#7cb448")
  end
  -- wings
  for _, a in ipairs{ -1, 1 } do
    local w = mk(); E(w, cx + a * 17, cy + 1, 8, 6); w = GX.rough(w, seed + a + 3, 1)
    part(w, seed + a, WING, { R = 8, amb = .4 })
    for i = 0, 3 do c:px(cx + a * (12 + i * 3), cy + 1 - (i % 2), WING.deep) end
  end
  -- abdomen
  local ab = mk(); E(ab, cx, cy + 25, 13, 14); ab = GX.rough(ab, seed + 5, 2)
  part(ab, seed + 5, GLO, { R = 12, amb = .5, wrap = .5, tex = .3, fn = function(x, y) return .22 - ((x - cx) ^ 2 + (y - cy - 26) ^ 2) / 700 * -.3 end })
  for i = 0, 3 do   -- segment bands
    local y = cy + 17 + i * 5
    for x = cx - 12, cx + 12 do if ab:has(x, y) and (x + i) % 2 == 0 then c:px(x, y, GLO.shade) end end
  end
  local core = mk(); E(core, cx - 3, cy + 28, 4, 4); c:fillMask(core, GLO.hi); c:px(cx - 2, cy + 28, "#ffffd0"); c:px(cx - 3, cy + 27, "#ffffd0")
  -- thorax
  local th = mk(); E(th, cx, cy + 10, 11, 7); th = GX.rough(th, seed + 7, 1); part(th, seed + 7, BUG, { R = 8 })
  -- head
  local hd = mk(); E(hd, cx, cy - 2, 12, 11); hd = GX.rough(hd, seed + 9, 1); part(hd, seed + 9, BUG, { R = 12, amb = .3 })
  for _, a in ipairs{ -1, 1 } do   -- eyes
    local ex, ey = cx + a * 5, cy - 3
    c:fillMask(c:rect(ex - 2, ey - 2, ex + 2, ey + 2), "#f6ecd0"); c:px(ex - 2, ey - 2, BUG.base); c:px(ex + 2, ey - 2, BUG.base); c:px(ex - 2, ey + 2, "#d8c8a8"); c:px(ex + 2, ey + 2, "#d8c8a8")
    c:px(ex + 1 * f, ey, INK); c:px(ex + 1 * f, ey + 1, INK); c:px(ex + 1 * f + (f > 0 and 0 or -1) , ey, INK)
    c:px(ex - 1 * f, ey - 1, "#ffffff" == "" and "" or "#fff8e0")
  end
  for i = -2, 2 do c:px(cx + i, cy + 4 + (abs(i) == 2 and -1 or 0), INK) end   -- smile
  c:px(cx - 7, cy + 2, "#d06c7a"); c:px(cx + 7, cy + 2, "#d06c7a")             -- blush
  -- little legs
  for _, a in ipairs{ -1, 1 } do for i = 0, 3 do c:px(cx + a * (9 + i), cy + 14 + i, INK) end end
end
for _, f in ipairs(FFS) do firefly(f[1], f[2], f[3] == 2, f[3] * 11) end

-- loose fireflies and motes
for i = 0, 34 do
  local x, y = 20 + floor(H(i, 31, 3) * 440), 40 + floor(H(i, 33, 3) * 190)
  local free = not rock:has(x, y)
  for _, f in ipairs(FFS) do if abs(x - f[1]) < 28 and y > f[2] - 34 and y < f[2] + 44 then free = false end end
  if free and not (abs(x - ax) < 31 and y > atop - 14 and y < abot) then
    if i % 5 == 0 then
      c:px(x, y, "#f6ffa0"); c:px(x - 1, y, "#a0d052"); c:px(x + 1, y, "#a0d052"); c:px(x, y - 1, "#a0d052"); c:px(x, y + 1, "#a0d052")
    else c:px(x, y, "#a0d052") end
  end
end

---------------------------------------------------------------- boat + lantern bulb
local boat = mk()
for x = 100, 214 do
  local t = (x - 100) / 114
  local top = 232 - floor(10 * (t > .75 and (t - .75) / .25 or 0)) + floor(3 * (t < .1 and (.1 - t) / .1 or 0))
  local bot = 244 - floor(6 * (t > .85 and (t - .85) / .15 or 0)) - floor(4 * (t < .08 and (.08 - t) / .08 or 0))
  for y = top, bot do boat:set(x, y) end
end
boat = GX.rough(boat, 70, 1)
GX.lit(c, boat, GX.ramp6(WOOD), { R = 9, tex = .55, sc = 3, seed = 7, rimlight = true,
  fn = function(x, y) return (y % 5 == 0) and -.2 or 0 end })
c:fillMask(c:rect(106, 235, 200, 236), "#a43c48"); c:fillMask(c:rect(106, 236, 200, 236), "#6c2440")   -- red stripe
for x = 112, 196, 14 do c:px(x, 240, WOOD.deep); c:px(x, 241, WOOD.deep) end
c:fillMask(c:rect(88, 252, 126, 254), WOOD.shade); c:fillMask(c:rect(90, 252, 124, 252), WOOD.base)   -- oar
c:fillMask(c:rect(80, 255, 92, 257), WOOD.base)
for i = 0, 5 do c:fillMask(c:rect(96 - i * 3, 247 + i, 206 + i * 3, 247 + i), i % 2 == 0 and "#1a3a60" or "#3a6890") end
-- lantern pole & bulb
for y = 216, 233 do c:px(139, y, INK); c:px(140, y, WOOD.base) end
c:px(139, 216, INK)
for i = 0, 4 do c:px(140 + i, 216 - (i > 2 and 1 or 0), INK) end
local bulb = mk(); E(bulb, 146, 224, 5, 7); bulb = GX.rough(bulb, 72, 1)
GX.lit(c, bulb, GX.ramp6({ hi = "#fffbc0", base = "#f8d850", shade = "#d89a38", deep = "#a05c34" }), { R = 6, amb = .6, tex = .15, rimlight = false })
c:px(144, 221, "#ffffe8"); c:px(145, 221, "#ffffe8"); c:px(144, 222, "#ffffe8")
for _, p in ipairs{ { 141, 224 }, { 151, 224 }, { 146, 216 }, { 146, 232 }, { 140, 218 }, { 152, 218 } } do c:px(p[1], p[2], "#f8d850") end
c:px(143, 233, "#f8d850"); c:px(149, 233, "#f8d850")
for i = 0, 3 do c:fillMask(c:rect(140 + (i % 2) * 2, 258 + i * 2 - 2, 152 - (i % 2), 258 + i * 2 - 2), "#d8b850") end

---------------------------------------------------------------- crystals + mushrooms
local function crystal(cx, cy, rx, ry, R, seed)
  local sh = mk(); E(sh, cx, cy + ry, rx + 3, 3); c:fillMask(sh, ROCK.deep)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  GX.lit(c, m, GX.ramp6(R), { R = max(rx, ry) * .9, amb = .45, tex = .35, seed = seed, rimlight = true })
  c:px(cx - rx // 2, cy - ry // 2, "#ffffff" == "" and "" or "#f8ffff"); c:px(cx - rx // 2 + 1, cy - ry // 2, R.hi); c:px(cx - rx // 2, cy - ry // 2 + 1, R.hi)
  for _, p in ipairs{ { -rx - 3, 0 }, { rx + 3, -1 }, { 0, -ry - 3 } } do c:px(cx + p[1], cy + p[2], R.hi) end
end
crystal(24, 196, 10, 8, TEAL, 81); crystal(46, 206, 8, 6, PINK, 82); crystal(78, 198, 9, 7, TEAL, 83); crystal(446, 194, 10, 8, TEAL, 84)
crystal(16, 224, 5, 4, PINK, 85)
-- glow mushrooms
local function mush(x, y, h, R, seed)
  for i = 0, h do c:px(x, y - i, "#d8c8e0"); c:px(x + 1, y - i, "#a898c4") end
  local m = mk(); E(m, x, y - h - 1, 4, 3); m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R), { R = 4, amb = .5, tex = .2, seed = seed, rimlight = true })
  c:px(x - 1, y - h - 2, R.hi)
end
mush(62, 222, 5, GLO, 90); mush(70, 226, 3, GLO, 91); mush(420, 214, 6, GLO, 92); mush(432, 222, 4, GLO, 93)
-- cave grass, bottom corners
for _, b in ipairs{ { 6, 270 }, { 14, 270 }, { 466, 270 }, { 458, 270 }, { 472, 270 } } do
  for i = 0, 18 do local x = b[1] + floor(sin(i * .5 + b[1]) * 3 * i / 18); c:px(x, 268 - i, i > 12 and "#5aa860" or (i > 5 and "#2e7a5c" or "#1e5a4e")) end
end
for i = 0, 18 do local x = 22 + floor(i * .35); c:px(x, 268 - i, "#2e7a5c"); c:px(480 - 22 - floor(i * .35), 268 - i, "#2e7a5c") end

---------------------------------------------------------------- gold stitched hem (top and bottom)
for _, y in ipairs{ 2, 267 } do
  for x = 0, 479 do
    if x % 6 < 4 then c:px(x, y, GOLD); c:px(x, y + (y < 100 and 1 or -1), "#a8762c") end
  end
end

c:save{ aseprite = d.."/out/delve-firefly-caves.aseprite", png = d.."/out/delve-firefly-caves.png", scale = 1 }
