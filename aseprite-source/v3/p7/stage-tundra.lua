-- stage-tundra v3: clear-day base backdrop (thawing tundra, no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-tundra" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local SNOW = { hi = "#fffaf4", base = "#eef0f6", shade = "#bcc8e4", deep = "#8c9cc8" }
local SN6 = R6(SNOW)
local STONE = { hi = "#c4c8d0", base = "#8c92a4", shade = "#60667e", deep = "#3a3e58" }
local SPR = { hi = "#5a9a70", base = "#2e7058", shade = "#1f4c4a", deep = "#163040" }
local WATER = { hi = "#a8e4f4", base = "#58b0d8", shade = "#3a82bc", deep = "#2a5a98" }
local GRS = { hi = "#c4dc78", base = "#92b852", shade = "#648e46", deep = "#3c6444" }
local DRY = { hi = "#e0d088", base = "#b49c58", shade = "#826e48", deep = "#524238" }
local RED = { hi = "#ff9a80", base = "#e8503c", shade = "#b03038", deep = "#6e2038" }
local MTN = { hi = "#d8ecf8", base = "#a8c4e0", shade = "#7c9cc8", deep = "#6a84b4" }
local HILL = { hi = "#c4d4bc", base = "#9ab4a0", shade = "#7c9a94", deep = "#647e84" }

-- sky
GX.bands(c, 0, 128, { "#7cbcee", "#98ccf2", "#b4dcf4", "#cfeaf2", "#e4f4f0", "#f4f8e8" }, 3, .2)
-- distant mountains (lit, snowcaps)
local peaks = { { 62, 86, .55 }, { 122, 62, .8 }, { 196, 96, .5 }, { 292, 80, .7 }, { 368, 58, .9 }, { 442, 84, .6 }, { 6, 98, .5 } }
local mt = mk()
for x = 0, 479 do
  local top = 140
  for _, p in ipairs(peaks) do top = min(top, p[2] + floor(abs(x - p[1]) * p[3] * 1.15)) end
  top = top + floor((GX.vn(x, 0, 6, 12) - .5) * 4)
  for y = top, 134 do mt:set(x, y) end
end
GX.lit(c, mt, function(x, y)
  local cap = 999
  for _, p in ipairs(peaks) do if abs(x - p[1]) < 50 then cap = min(cap, p[2] + 14 + floor(abs(x - p[1]) * .35) + floor((GX.vn(x, y, 4, 9) - .5) * 8)) end end
  return y < cap and SN6 or R6(MTN)
end, { R = 40, tex = .5, sc = 4, seed = 5, ink = false, amb = .35,
  fn = function(x, y) return (x % 120 > 60 and -.12 or .08) end })
-- rolling blue-green hills
local function hillf(x) return 120 + floor(5 * sin(x / 41 + 2) + 3 * sin(x / 15)) end
GX.ground(c, hillf, HILL, 4, { top = .8, fall = .3, tex = .3, sc = 8 })
for i = 0, 7 do   -- far snow patches on the hills
  local x = 20 + i * 62 + floor(H(i, 2, 2) * 20); local y = hillf(x) + 6 + floor(H(i, 3, 2) * 6)
  local m = mk(); E(m, x, y, 12 + i % 3 * 4, 2); m = GX.rough(m, i, 1); c:fillMask(m, "#e4ecf4")
end

-- tundra meadow
local function gnd(x) return 134 + floor(3 * sin(x / 33 + 1) + 2 * sin(x / 12)) end
GX.ground(c, gnd, GRS, 7, { top = .86, fall = .62, tex = .36, sc = 9 })
for x = 0, 479 do c:px(x, gnd(x), "#d8e4a0") end
for y = 150, 269 do for x = 0, 479 do   -- peaty dry patches and moss mottling
  local n = GX.vn(x, y, 12, 21)
  if n > .72 and y % 2 == 0 and GX.vn(x, y, 3, 22) > .4 then c:px(x, y, GRS.hi) end
  if n < .1 and GX.vn(x, y, 3, 23) > .45 then c:px(x, y, DRY.base) end
end end

-- pond
local pm = mk(); E(pm, 240, 154, 76, 18); pm = GX.rough(pm, 31, 2)
local bank = pm:copy():grow(2); bank = GX.rough(bank, 33, 1); c:fillMask(bank, DRY.base)
local bk2 = pm:copy():grow(1); c:fillMask(bk2, DRY.hi)
GX.lit(c, pm, R6(WATER), { R = 14, tex = .3, sc = 4, seed = 8, amb = .4, wrap = .5, ink = false,
  fn = function(x, y) return (GX.vn(x * .25, y, 4, 14) - .5) * .25 + (y < 150 and -.1 or .06) end })
for _, f in ipairs{ { 218, 146, 17, 3 }, { 266, 144, 13, 3 }, { 192, 158, 10, 2 }, { 252, 162, 15, 3 }, { 290, 156, 9, 2 } } do
  local m = mk(); E(m, f[1], f[2], f[3], f[4]); m = GX.rough(m, f[1], 1)
  m:cut(m:copy()) -- noop guard
  local fm = mk(); E(fm, f[1], f[2], f[3], f[4]); fm = GX.rough(fm, f[1], 1)
  local clipped = mk(); fm:each(function(x, y) if pm:has(x, y) then clipped:set(x, y) end end)
  GX.lit(c, clipped, SN6, { R = 4, tex = .25, seed = f[1], ink = false, rimlight = false })
end
for i = 0, 40 do   -- glints
  local x, y = 170 + floor(H(i, 5, 7) * 140), 140 + floor(H(i, 6, 7) * 28)
  if pm:has(x, y) and pm:has(x + 3, y) and c:get(x, y) ~= SN6[4] then c:fillMask(c:rect(x, y, x + 2 + i % 3, y), WATER.hi) end
end

-- inukshuk on a low mound
local mound = mk(); E(mound, 242, 130, 46, 8); mound = GX.rough(mound, 41, 2)
mound:cut(c:rect(0, 138, 479, 200))
GX.lit(c, mound, R6(GRS), { R = 10, tex = .4, sc = 4, seed = 41, ink = false, amb = .3 })
local function stone(x0, y0, x1, y1, seed)
  local m = mk()
  for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(STONE), { R = 4, tex = .5, sc = 2.4, seed = seed, rimlight = true, amb = .25 })
end
stone(228, 112, 236, 132, 51); stone(246, 112, 254, 132, 52)   -- legs
stone(230, 100, 254, 113, 53)                                 -- body
stone(214, 90, 270, 99, 54)                                   -- arms
stone(233, 74, 251, 89, 55)                                   -- head
stone(232, 64, 241, 73, 56)
-- snow dusting on top of the stones, small quirk: a tiny red scarf of lichen
for x = 216, 268 do if H(x, 4, 7) > .3 then c:px(x, 91, SN6[5]) end end
for x = 234, 249 do c:px(x, 75, SN6[6]) end
for _, p in ipairs{ { 243, 69 }, { 244, 69 }, { 244, 70 } } do c:px(p[1], p[2], RED.base) end
c:px(243, 68, RED.hi)
local sh = mk(); E(sh, 248, 133, 30, 3); c:fillMask(GX.rough(sh, 6, 1), GRS.deep)

-- snow patches (thaw leftovers), above the walkway
local function patch(x, y, rx, ry, s)
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, s, 1)
  GX.lit(c, m, SN6, { R = 4, tex = .3, seed = s, ink = false, amb = .3 })
  local edge = mk(); m:each(function(px, py) if not m:has(px, py + 1) then edge:set(px, py + 1) end end)
  edge:each(function(px, py) c:px(px, py, GRS.shade) end)
end
patch(40, 188, 26, 4, 61); patch(130, 172, 22, 4, 62); patch(350, 178, 30, 4, 63); patch(430, 160, 24, 3, 64); patch(90, 152, 14, 3, 65); patch(330, 146, 16, 3, 66)
patch(160, 224, 8, 2, 67); patch(402, 236, 7, 2, 68)

-- spruces
local function spruce(cx, base, h, hw, seed)
  local sh = mk(); E(sh, cx + 6, base, hw * .6, 3); c:fillMask(GX.rough(sh, seed, 1), GRS.deep)
  local tr = c:rect(cx - 2, base - 12, cx + 2, base)
  GX.lit(c, tr, R6({ hi = "#a07858", base = "#6c4a3c", shade = "#4a3238", deep = "#2e2030" }), { R = 2, tex = .3, seed = seed })
  local n = 6
  for i = n, 1, -1 do
    local ytop = base - h + floor((i - 1) * h * .8 / n)
    local ybot = min(base - 8, ytop + floor(h / n * 1.8))
    local bw = hw * (.38 + .62 * i / n)
    local m = mk()
    for x = cx - floor(bw) - 1, cx + floor(bw) + 1 do
      local lim = ybot - floor(abs(sin((x - cx) * .55 + seed + i)) * 3)
      for y = ytop, lim do
        local t = (y - ytop) / max(1, ybot - ytop)
        if abs(x - cx) <= bw * t ^ .85 + 1 then m:set(x, y) end
      end
    end
    m = GX.rough(m, seed + i, 1)
    GX.lit(c, m, R6(SPR), { R = 6, tex = .55, sc = 3, seed = seed + i, amb = .25 })
    m:each(function(x, y)
      local t = (y - ytop) / max(1, ybot - ytop)
      if t < .4 + (GX.vn(x, y, 4, seed) - .5) * .7 then
        local s = (x - cx) / max(1, bw)
        local k = s < -.25 and 6 or (s < .35 and 5 or 4)
        if GX.vn(x, y, 2, seed + 9) < .15 then k = k - 1 end
        c:px(x, y, SN6[k])
      end
    end)
  end
  c:px(cx, base - h - 1, SN6[6]); c:px(cx, base - h, SN6[6])
end
-- far small spruces (flat, no ink)
local function farspruce(cx, base, h)
  for y = base - h, base do
    local hw = floor((y - (base - h)) / h * h * .24) + 1
    if y % 4 ~= 0 then hw = hw - 1 end
    for x = cx - hw, cx + hw do c:px(x, y, x < cx and "#6c9c88" or "#4c7c76") end
  end
end
for _, t in ipairs{ { 90, 142, 22 }, { 102, 144, 28 }, { 114, 141, 18 }, { 400, 140, 16 }, { 412, 141, 22 } } do farspruce(t[1], t[2], t[3]) end
spruce(30, 178, 104, 32, 71)
spruce(66, 174, 66, 22, 73)

-- boulders in the bottom corners (small, low)
local function boulder(cx, cy, rx, ry, seed)
  local sh = mk(); E(sh, cx + 4, cy + ry - 1, rx + 3, 3); c:fillMask(GX.rough(sh, seed, 1), GRS.deep)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  GX.lit(c, m, R6(STONE), { R = max(rx, ry) * .8, tex = .5, sc = 3, seed = seed, rimlight = true })
  m:each(function(x, y)
    local t = (y - (cy - ry)) / (ry * 2)
    local nz = GX.vn(x, y, 3, seed + 4)
    if t < .3 + (nz - .5) * .4 and x < cx + rx * .4 then c:px(x, y, SN6[x < cx and 6 or 5]) end
    if H(x, y, seed) < .025 and t > .3 then c:px(x, y, "#e8b038") end   -- lichen
  end)
end
boulder(10, 262, 22, 11, 81); boulder(472, 260, 24, 12, 83)

-- berry bushes
local function bush(x, y, s)
  local m = mk(); E(m, x, y, 9, 5); m = GX.rough(m, s, 1)
  GX.lit(c, m, R6({ hi = "#a8c860", base = "#5c8c44", shade = "#3c6a40", deep = "#254a3c" }), { R = 5, tex = .5, sc = 2, seed = s, rimlight = true })
  for _, p in ipairs{ { -4, -1 }, { 0, -2 }, { 4, 0 }, { -1, 1 }, { 2, -1 } } do
    c:px(x + p[1], y + p[2], RED.base); c:px(x + p[1] + 1, y + p[2], RED.shade); c:px(x + p[1], y + p[2] - 1, RED.hi)
  end
end
bush(14, 236, 91); bush(462, 232, 92); bush(300, 190, 93)

-- calm foreground: tufts, cotton grass, pebbles, lichen, tracks
for i = 0, 26 do
  local x, y = 8 + floor(H(i, 61, 1) * 465), 184 + floor(H(i, 63, 1) * 82)
  if (x > 40 and x < 440) or y < 225 then GX.tuft(c, x, y, i % 3 == 0 and DRY or GRS) end
end
for i = 0, 7 do   -- cotton grass
  local x, y = 40 + floor(H(i, 71, 1) * 400), 196 + floor(H(i, 73, 1) * 60)
  for k = 0, 6 do c:px(x, y - k, GRS.base) end
  c:px(x, y - 8, SN6[6]); c:px(x - 1, y - 7, SN6[5]); c:px(x + 1, y - 7, SN6[5]); c:px(x, y - 7, SN6[6]); c:px(x, y - 6, SN6[4])
end
local PEB = { hi = "#d8dce4", base = "#a4a8bc", shade = "#747898", deep = "#484c68" }
for i = 0, 22 do
  local x, y = 50 + floor(H(i, 21, 5) * 380), 186 + floor(H(i, 22, 5) * 80)
  local m = mk(); E(m, x, y, 1 + i % 2, 1); GX.lit(c, m, R6(PEB), { R = 2, tex = .15, seed = i, rimlight = true })
end
for i = 0, 40 do   -- lichen flecks
  local x, y = floor(H(i, 91, 1) * 480), 186 + floor(H(i, 93, 1) * 84)
  c:px(x, y, i % 2 == 0 and "#d8b448" or "#b8c890"); c:px(x + 1, y, "#d8b448")
end

c:save{ aseprite = d.."/out/stage-tundra.aseprite", png = d.."/out/stage-tundra.png", scale = 1 }
