-- stage-forest v3: clear-day base backdrop (golden glade look, no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-forest" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local GOLD = { hi = "#ffe38a", base = "#f0b43a", shade = "#d0802a", deep = "#8f4a1f" }
local RED = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
local BARK = { hi = "#c89060", base = "#94603c", shade = "#6e4234", deep = "#442a2c" }
local DIRT = { hi = "#f0d090", base = "#d4a866", shade = "#a8784c", deep = "#7a5240" }
local HILL = { hi = "#c0e888", base = "#9cd070", shade = "#78b060", deep = "#5a9060" }
local GRASS = { hi = "#d8f880", base = "#9ce048", shade = "#58b040", deep = "#2a7a44" }
local STO = { hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }
local CREAM = { hi = "#ffffff", base = "#fff4d6", shade = "#d8c8a8", deep = "#a8987e" }
local FAR = "#8cc0a0"

-- clear sky with distant trunks in haze, one small sun glare behind the canopy
local function shaft(x, y)
  for i = 0, 6 do local x0 = 30 + i * 66; local t = y / 150
    if x >= x0 + t * 40 and x <= x0 + 24 + t * 50 then return true end end
  return false
end
GX.bands(c, 0, 150, { "#c8ecf8", "#d4f0e8", "#e4f6c8", "#d8f0a8", "#c0e498", "#a8d888" }, 3, .22, shaft, "#ffffd0")
for _, t in ipairs{ { 28, 22 }, { 150, 16 }, { 250, 20 }, { 340, 14 }, { 420, 18 }, { 96, 14 }, { 200, 12 }, { 300, 16 } } do
  local far = { hi = GX.mix(FAR, "#ffffd0", .25), base = FAR, shade = GX.mix(FAR, "#000000", .12), deep = GX.mix(FAR, "#000000", .25) }
  GX.trunk(c, t[1], t[1] + t[2] - 1, 28, 152, far, t[1], { noink = true })
end
local sun = mk(); E(sun, 232, 8, 22, 14); c:fillMask(sun, "#fffbd8"); local s2 = mk(); E(s2, 232, 8, 14, 9); c:fillMask(s2, "#ffffff")

-- rolling ground
GX.ground(c, function(x) return 126 + floor(5 * sin(x / 31)) end, HILL, 5, { top = .75, fall = .3, tex = .3 })
GX.ground(c, function(x) return 142 + floor(4 * sin(x / 23 + 2)) end, GRASS, 7, { top = .86, fall = .62, tex = .3, sc = 8 })
-- distant bushes on the ridge
for _, b in ipairs{ { 40, 138, 24, 8 }, { 118, 140, 20, 7 }, { 350, 136, 26, 8 }, { 430, 140, 22, 7 } } do
  local m = mk(); E(m, b[1], b[2], b[3], b[4]); m = GX.rough(m, b[1], 1)
  GX.lit(c, m, R6(GRN2), { R = 8, tex = .5, sc = 3, seed = b[1], ink = false })
end

-- canopy
local CL = { { 40, 14, 52, 24 }, { 110, 6, 46, 20 }, { 170, 18, 46, 22 }, { 236, 6, 48, 22 }, { 300, 18, 50, 24 }, { 362, 6, 46, 20 }, { 424, 16, 50, 24 }, { 474, 6, 34, 20 },
  { 14, 40, 32, 14 }, { 250, 42, 34, 12 }, { 372, 44, 34, 12 }, { 70, 44, 26, 10 } }
local CAN = { GRN1, GRN2, GOLD, GRN1, GRN2, GRN1, GRN1, GRN2, GOLD, GRN1, GRN2, GOLD }
for pass = 1, 2 do for i, g in ipairs(CL) do
  if (pass == 1) == (g[2] < 30) then GX.foliage(c, g[1], g[2], g[3], g[4], CAN[i], 100 + i * 17) end
end end

-- big trunks (left, right) kept to the sides
GX.trunk(c, 100, 126, 44, 160, BARK, 11, { moss = GRN2 })
GX.trunk(c, 356, 380, 44, 156, BARK, 12)
GX.trunk(c, 0, 18, 0, 182, BARK, 14, { moss = GRN2 })
GX.trunk(c, 452, 479, 0, 176, BARK, 13, { moss = GRN2 })

-- trail from the foreground up to the stump
local function pw(y) return 26 + (y - 170) * 0.95 end
local trail = mk()
for y = 168, 269 do local w = floor(pw(y) + (GX.vn(0, y, 9, 21) - .5) * 5); for x = 240 - w - floor((y - 168) * .1), 240 + w - floor((y - 168) * .1) do trail:set(x, y) end end
trail = GX.rough(trail, 31, 1)
GX.lit(c, trail, R6(DIRT), { R = 30, tex = .35, sc = 3, seed = 31, rimlight = false, amb = .5, ink = false,
  fn = function(x, y) return (H(x // 2, y // 2, 31) - .5) * .22 end })
for i = 0, 26 do   -- ruts and pebbles on the trail
  local y = 176 + floor(H(i, 5, 8) * 90); local x = 240 - floor((y - 168) * .1) + floor((H(i, 6, 8) - .5) * pw(y) * 1.4)
  if trail:has(x, y) and trail:has(x + 3, y) then c:px(x, y, DIRT.shade); c:px(x + 1, y, DIRT.shade); c:px(x + 2, y, DIRT.deep) end
end
for i = 0, 40 do   -- grass fringe nibbling the trail edge
  local y = 172 + floor(H(i, 9, 3) * 96); local w = floor(pw(y)) - floor((y - 168) * .1)
  local x = (i % 2 == 0) and 240 - w + 1 or 240 + w - 1
  if H(i, 4, 4) > .3 then GX.tuft(c, x, y, GRASS) end
end

-- hero stump with mossy top and rings
local st = mk()
for y = 112, 178 do local t = (y - 112) / 66; local fl = floor(t^3 * 14); for x = 190 - fl, 290 + fl do st:set(x, y) end end
E(st, 240, 112, 50, 8); st:cut(c:rect(120, 180, 360, 200))
st = GX.rough(st, 41, 1)
local sh = mk(); E(sh, 244, 180, 76, 7); sh = GX.rough(sh, 40, 1); c:fillMask(sh, GX.mix(GRASS.shade, GRASS.base, .35))
GX.lit(c, st, function(x, y) return y < 118 and R6({ hi = "#e8c890", base = "#c89060", shade = "#a8704a", deep = "#6e4234" }) or R6(BARK) end,
  { R = 40, tex = .3, sc = 2.2, seed = 41, rimlight = true, amb = .26,
    fn = function(x, y) return (GX.vn(x * .25, y, 2, 6) - .5) * .5 end })
for k = 1, 3 do for a = 0, 90 do   -- growth rings on the cut top
  local t = a / 90 * 6.2832; local x, y = 240 + floor(k * 12 * cos(t)), 112 + floor(k * 2.2 * sin(t))
  if y < 119 and st:has(x, y) then c:px(x, y, BARK.shade) end
end end
local mo = mk()
for x = 192, 288 do local top = 106 + floor(GX.vn(x, 2, 6, 7) * 3); for y = top, top + 6 + floor(GX.vn(x, 4, 5, 8) * 7) do if st:has(x, y) and (y < 114 or GX.vn(x, y, 4, 9) > .45) then mo:set(x, y) end end end
GX.lit(c, mo, R6(GRN1), { R = 6, tex = .6, sc = 2.6, seed = 44, rimlight = true })
c:fillMask(c:rect(231, 154, 234, 160), INK); c:fillMask(c:rect(232, 155, 233, 159), "#2a1820")   -- quirk: a knothole door slot
c:px(232, 155, "#ffe38a")

-- mushrooms
local function shroom(x, y, s)
  local stm = c:rect(x - s, y - 7 * s, x + s, y); GX.lit(c, stm, R6(CREAM), { R = 2, tex = 0, ink = INK })
  local cap = mk(); E(cap, x, y - 8 * s, 4 * s + 2, 3 * s + 1); cap:cut(c:rect(x - 20, y - 8 * s + 1 + 2 * s, x + 20, y + 20)); cap = GX.rough(cap, x, 1)
  GX.lit(c, cap, R6(RED), { R = 4 * s, tex = .1, seed = x, rimlight = true })
  c:px(x - 2, y - 9 * s, CREAM.base); c:px(x + 2, y - 8 * s, CREAM.base); c:px(x, y - 10 * s, CREAM.base)
end
shroom(206, 178, 2); shroom(190, 174, 1); shroom(280, 176, 1); shroom(300, 180, 2); shroom(240, 108, 1)

-- ferns flanking the stump
local function fern(x, y, dir, big)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir; local len = (big or 24) - abs(i - 3) * 3
    local ex, ey = x + floor(len * sin(ang / 57.3)), y - floor(len * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 - dir * 3, (y + ey) // 2 - 4
    local fr = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    GX.lit(c, fr, R6(i % 2 == 0 and GRN1 or GRN2), { R = 3, tex = .25, sc = 2, seed = i + x, rimlight = true })
  end
end
fern(166, 178, 1, 22); fern(318, 176, -1, 22); fern(20, 192, 1, 28); fern(462, 198, -1, 28)

-- calm foreground (y>180, trail kept clear): sparse stones, tufts, flowers, leaves
local function blocked(x, y) return abs(x - 240 + (y - 168) * .1) < pw(y) + 4 end
for _, s in ipairs{ { 84, 226, 9, 4 }, { 380, 236, 12, 4 }, { 148, 252, 7, 3 }, { 430, 254, 8, 3 } } do
  local m = mk(); E(m, s[1], s[2], s[3], s[4]); m = GX.rough(m, s[1], 1)
  GX.lit(c, m, R6(STO), { R = 4, tex = .3, sc = 3, seed = s[1], rimlight = true })
  for k = 0, 3 do c:px(s[1] - s[3] + 3 + k * 2, s[2] - s[4] + 1, GRN1.base) end
end
for i = 0, 34 do
  local x, y = 8 + floor(H(i, 61, 1) * 464), 186 + floor(H(i, 63, 1) * 82)
  if not blocked(x, y) then GX.tuft(c, x, y, y > 226 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep } or GRASS) end
end
local FL = { "#ff9fc0", "#fff4d6", "#ffd470", "#c9b2f0", "#ff8a5c" }
for i = 0, 18 do
  local x, y = 10 + floor(H(i, 41, 1) * 460), 186 + floor(H(i, 43, 1) * 78)
  if not blocked(x, y) then GX.flower(c, x, y, FL[1 + i % 5]) end
end
local LV = { "#f5d84a", "#f0a830", "#ffe38a", "#c4e07a" }
for i = 0, 70 do
  local x, y = floor(H(i, 31, 1) * 480), 186 + floor(H(i, 37, 1) * 82)
  if not blocked(x, y) and x > 20 and x < 455 then
    local col = LV[1 + i % 4]
    c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y + 1, GX.mix(col, "#000000", .3))
  end
end
c:save{ aseprite = d.."/out/stage-forest.aseprite", png = d.."/out/stage-forest.png", scale = 1 }
