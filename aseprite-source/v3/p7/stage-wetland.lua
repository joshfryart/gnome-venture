-- stage-wetland v3: clear-day base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK, mix = X.hash, GX.INK, GX.mix
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-wetland" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local PINE = { hi = "#7cc068", base = "#3a8a50", shade = "#256a48", deep = "#16423e" }
local ROCK = { hi = "#d0ccd8", base = "#9894ac", shade = "#6a6688", deep = "#3c3a58" }
local WOOD = { hi = "#d6b684", base = "#a8845a", shade = "#7a5a40", deep = "#4a3640" }
local MTN = { hi = "#d8ecf0", base = "#a8c8d8", shade = "#84a8c4", deep = "#6488ac" }
local HILL = { hi = "#c0e888", base = "#9cd070", shade = "#78b060", deep = "#5a9060" }
local GRASS = { hi = "#d0f070", base = "#92d048", shade = "#58a840", deep = "#2a7a44" }
local MUD = { hi = "#c8a46a", base = "#9a7248", shade = "#6e4e3a", deep = "#46303a" }
local BERRY = { hi = "#ff9a80", base = "#e8503c", shade = "#b03038", deep = "#6e2038" }

-- sky: plain gradient, small sun glare upper right
GX.bands(c, 0, 140, { "#7cc4ee", "#98d4f4", "#b4e4f6", "#cdf0f4", "#e4f6e0", "#f4f6c8" }, 3, .2)
do local s = mk(); E(s, 400, 22, 14, 9); c:fillMask(GX.rough(s, 5, 1), "#fffbd0")
   local s2 = mk(); E(s2, 400, 22, 7, 4); c:fillMask(GX.rough(s2, 6, 1), "#fffff0") end

-- distant mountains (bare of snow: pale blue-grey, lit from left)
local function ridge(x0, x1, pk, ph, base, seed)
  local m = mk()
  for x = x0, x1 do
    local t = (x < pk) and (x - x0) / max(1, pk - x0) or (x1 - x) / max(1, x1 - pk)
    local top = floor(base - ph * t + (GX.vn(x, 0, 7, seed) - .5) * 4)
    for y = top, base do m:set(x, y) end
  end
  return GX.rough(m, seed, 1)
end
local function mtn(x0, x1, pk, ph, seed)
  local m = ridge(x0, x1, pk, ph, 130, seed)
  GX.lit(c, m, R6(MTN), { R = 20, tex = .5, sc = 4, seed = seed, ink = false, amb = .35,
    fn = function(x, y) return (x < pk and .12 or -.14) + (y < 130 - ph * .75 and .1 or 0) end })
end
mtn(-20, 150, 70, 55, 11); mtn(100, 330, 205, 66, 12); mtn(280, 520, 390, 74, 13)
-- far treeline / marsh haze
GX.ground(c, function(x) return 116 + floor(4 * sin(x / 29) + 3 * sin(x / 9 + 1)) end, { hi = "#a8d8b0", base = "#88c0a0", shade = "#6ca898", deep = "#548888" }, 4, { top = .7, fall = .3, tex = .3, sc = 6 })
GX.ground(c, function(x) return 124 + floor(5 * sin(x / 31 + 2)) end, HILL, 5, { top = .75, fall = .3, tex = .3 })
-- far reed line
for x = 0, 479 do
  local y0 = 134 + floor(2 * sin(x / 23)); local h = 3 + floor(H(x // 2, 5, 1) * 5)
  for y = y0 - h, y0 do c:px(x, y, (H(x, 2, 3) < .5) and "#78b060" or "#8cc070") end
end
-- main ground
GX.ground(c, function(x) return 136 + floor(3 * sin(x / 23 + 2)) end, GRASS, 7, { top = .86, fall = .6, tex = .32, sc = 8 })
for _, m0 in ipairs{ { 90, 168, 36, 5 }, { 400, 160, 30, 4 }, { 430, 192, 22, 4 } } do
  local m = mk(); E(m, m0[1], m0[2], m0[3], m0[4]); m = GX.rough(m, m0[1], 1)
  GX.lit(c, m, R6(MUD), { R = 4, tex = .4, sc = 3, seed = m0[1], ink = false, amb = .5 })
end

-- pond (mid, behind the walking strip)
local pond = mk(); E(pond, 248, 158, 108, 17); pond = GX.rough(pond, 31, 2)
local shore = pond:copy():grow(2); shore:cut(pond)
shore:each(function(x, y) c:px(x, y, R6(MUD)[GX.idx(.45 + (GX.vn(x, y, 3, 8) - .5) * .8)]) end)
local WA = { "#4a8cba", "#5aa8cc", "#78c4d8", "#9ad8e0", "#bfe8e0", "#fff4c8" }
pond:each(function(x, y)
  local t = (y - 141) / 34
  local v = .15 + (1 - t) * .55 + (GX.vn(x * .35, y * 1.4, 4, 9) - .5) * .35
  if abs(x - 310) < 12 and (y // 2 + x // 6) % 3 == 0 then v = v + .3 end
  c:px(x, y, WA[max(1, min(6, 1 + floor(max(0, min(1, v)) * 5.99)))])
end)
for i = 0, 40 do
  local x, y = 145 + floor(H(i, 71, 1) * 205), 143 + floor(H(i, 73, 1) * 30)
  if pond:has(x, y) and pond:has(x + 6, y) then for k = 0, 3 + i % 4 do if pond:has(x + k, y) then c:px(x + k, y, (i % 2 == 0) and "#e8fbe8" or "#3e7aa8") end end end
end
-- lily pads on the pond
for i, p in ipairs{ { 190, 160, 8, 3 }, { 225, 168, 7, 3 }, { 290, 150, 9, 3 }, { 330, 164, 7, 2 }, { 160, 152, 6, 2 } } do
  local m = mk(); E(m, p[1], p[2], p[3], p[4]); m = GX.rough(m, 50 + i, 1)
  GX.lit(c, m, R6(i % 2 == 0 and GRN1 or GRN2), { R = 3, tex = .35, sc = 2, seed = i, rimlight = true })
  if i == 2 then c:px(p[1], p[2] - 1, "#ff9fc0"); c:px(p[1] - 1, p[2] - 2, "#fff4f8"); c:px(p[1] + 1, p[2] - 2, "#fff4f8"); c:px(p[1], p[2] - 2, "#ffe38a") end
end

-- inukshuk on a grassy knoll beyond the pond (hero)
do
  local kn = mk(); E(kn, 246, 134, 34, 6); kn = GX.rough(kn, 21, 1)
  GX.lit(c, kn, R6(HILL), { R = 6, tex = .4, sc = 3, seed = 21, ink = false, rimlight = true })
  local function stone(x0, y0, x1, y1, seed)
    local m = mk(); for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end
    m = GX.rough(m, seed, 1)
    GX.lit(c, m, R6(ROCK), { R = 4, tex = .5, sc = 2.5, seed = seed, rimlight = true, amb = .25 })
  end
  stone(228, 118, 237, 131, 22); stone(250, 118, 259, 131, 23)   -- legs
  stone(232, 104, 255, 118, 24)                                    -- torso
  stone(216, 92, 271, 103, 25)                                     -- arms
  stone(238, 80, 249, 91, 26)                                      -- head
  stone(243, 71, 246, 79, 27)                                      -- peak stone
  c:px(244, 85, INK); c:px(247, 85, INK)                           -- quirk: a face
  for k = 0, 5 do c:px(236 + k * 3, 100 + (k % 2), ROCK.deep) end
end

-- pines (left)
local function pine(x, yb, h, w, seed)
  local tw = 3
  GX.trunk(c, x - tw, x + tw - 1, yb - 16, yb, WOOD, seed, { noink = false })
  local tiers = floor(h / 14)
  for i = tiers, 0, -1 do
    local ty = yb - 14 - i * 12 - floor(h * .1)
    local tt = i / tiers
    local rw = floor(w * (1 - tt * .75)) + 4
    local m = mk()
    for y = 0, 17 do local hw = floor(rw * (y / 17)); for xx = x - hw, x + hw do m:set(xx, ty - 17 + 12 + y - 12 + 12) end end
    m = GX.rough(m, seed + i, 1)
    GX.lit(c, m, R6(PINE), { R = 8, tex = .6, sc = 2.6, seed = seed + i, rimlight = true, amb = .25 })
  end
end
pine(28, 190, 120, 24, 301); pine(70, 176, 84, 18, 311)
for i, p in ipairs{ { 106, 150, 36 }, { 130, 146, 44 }, { 150, 150, 30 } } do
  local m = mk()
  for y = 0, p[3] do local hw = floor(3 + 7 * (y / p[3])); for x = p[1] - hw, p[1] + hw do m:set(x, p[2] - p[3] + y) end end
  m = GX.rough(m, 320 + i, 1)
  GX.lit(c, m, R6({ hi = "#a0d8a0", base = "#6cb090", shade = "#4c8c80", deep = "#346868" }), { R = 8, tex = .5, sc = 2.6, seed = 320 + i, ink = false, rimlight = true })
end

-- boulders and berry bushes in the far corners (kept off the walking strip)
local function boulder(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); E(m, cx + rx // 3, cy + 2, rx * 2 // 3, ry); m = GX.rough(m, seed, 2)
  local sh = mk(); E(sh, cx + 3, cy + ry, rx + 6, 3); c:fillMask(GX.rough(sh, seed + 1, 1), "#58a840")
  GX.lit(c, m, R6(ROCK), { R = rx * .7, tex = .55, sc = 3.2, seed = seed, rimlight = true, amb = .22 })
  for k = 0, 3 do c:px(cx - rx // 2 + k * 5, cy - ry // 2 + (k * 7) % 5, "#d8c890") end
end
boulder(18, 262, 24, 12, 401); boulder(462, 262, 26, 13, 411)
local function bush(cx, cy, rw, seed)
  local m = mk(); E(m, cx, cy, rw, rw // 2 + 1); E(m, cx - rw // 2, cy - 2, rw // 2, rw // 2); m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(GRN2), { R = 5, tex = .6, sc = 2.5, seed = seed, rimlight = true })
  for k = 0, 6 do local bx, by = cx - rw + 2 + floor(H(k, seed, 1) * (rw * 2 - 4)), cy - 3 + floor(H(k, seed, 2) * 6)
    if m:has(bx, by) then c:px(bx, by, BERRY.base); c:px(bx + 1, by, BERRY.shade); c:px(bx, by - 1, BERRY.hi) end end
end
bush(52, 262, 13, 421); bush(430, 264, 13, 431)

-- calm foreground: scattered small details only
for i = 0, 40 do
  local x, y = 8 + floor(H(i, 61, 1) * 465), 186 + floor(H(i, 63, 1) * 82)
  if not ((x < 80 and y > 245) or (x > 400 and y > 245)) then
    GX.tuft(c, x, y, y > 230 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep } or GRASS)
  end
end
for i = 0, 14 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 190 + floor(H(i, 43, 1) * 72)
  local cols = { "#ff9fc0", "#fff4d6", "#ffe38a", "#c9b2f0" }
  if not ((x < 80 and y > 245) or (x > 400 and y > 245)) then GX.flower(c, x, y, cols[1 + i % 4]) end
end
for i = 0, 12 do
  local x, y = 30 + floor(H(i, 91, 2) * 420), 192 + floor(H(i, 93, 2) * 70)
  local m = mk(); E(m, x, y, 1 + i % 3, 1 + i % 2)
  GX.lit(c, m, R6({ hi = "#e8e4d0", base = "#b4b09c", shade = "#7e7a68", deep = "#4a4850" }), { R = 2, tex = .15, seed = i, rimlight = true })
end
-- cattails at the pond edge
for _, rx in ipairs{ 140, 150, 352, 360 } do
  local h = 18 + floor(H(rx, 1, 1) * 10)
  for k = 0, h do c:px(rx, 176 - k, INK); c:px(rx + 1, 176 - k, k % 5 == 0 and GRN1.hi or GRN1.base) end
  c:fillMask(c:rect(rx - 1, 176 - h - 7, rx + 2, 176 - h), INK); c:fillMask(c:rect(rx, 176 - h - 6, rx + 1, 176 - h - 1), "#7a4a34"); c:px(rx, 176 - h - 6, "#b97a4a")
end

c:save{ aseprite = d.."/out/stage-wetland.aseprite", png = d.."/out/stage-wetland.png", scale = 1 }
