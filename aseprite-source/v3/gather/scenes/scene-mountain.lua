-- gather scene: MOUNTAIN (day palette). Thin air, steep paths and stone that remembers everything.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "scene-mountain" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end

local GRASS = { hi = "#d4ec7e", base = "#8cc858", shade = "#58a050", deep = "#2e6a50" }
local PINE = { hi = "#58a468", base = "#2e7c58", shade = "#1f5a4c", deep = "#123a3c" }
local BARK = { hi = "#b88058", base = "#8a5a3c", shade = "#6a4236", deep = "#40262c" }
local STONE = { hi = "#eae6f2", base = "#b4aec8", shade = "#807c9c", deep = "#4c4a6c" }
local STONEW = { hi = "#efe0d2", base = "#c0aca4", shade = "#8c7884", deep = "#56465e" }
local SHADOW = "#2e6a50"

---------------------------------------------------------------- sky
GX.bands(c, 0, 150, { "#5ea6ea", "#7cbcf0", "#9ccef4", "#b8dcf4", "#d4eaf4", "#eef2e8" }, 3, .2)
local function cloud(cx, cy, rw, seed)
  local m = mk()
  for i = 0, 5 do E(m, cx + floor((H(i, seed, 1) - .5) * rw * 1.4), cy + floor((H(i, seed, 2) - .5) * 4), 8 + floor(H(i, seed, 3) * 10), 3 + floor(H(i, seed, 4) * 3)) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffffff", base = "#f2f6fc", shade = "#d0def4", deep = "#aebfe8" }), { R = 5, tex = .25, sc = 4, seed = seed, ink = false })
end
cloud(70, 28, 40, 4); cloud(250, 20, 36, 5); cloud(376, 34, 40, 6); cloud(150, 84, 24, 7)

---------------------------------------------------------------- peaks
local function layer(peaks, cap, snowY, R, seed, haze)
  local R6 = GX.ramp6(R)
  local function ridge(x)
    local best = cap
    for _, p in ipairs(peaks) do best = min(best, p[2] + abs(x - p[1]) * p[3]) end
    return floor(best + (GX.vn(x, 0, 5, seed) - .5) * 6 + (GX.vn(x, 1, 2, seed) - .5) * 2)
  end
  for x = 0, 479 do
    local top = ridge(x)
    local sl = ridge(x + 3) - ridge(x - 3)
    for y = top, 150 do
      local dep = y - top
      local v = .55 - sl * .03 + (GX.vn(x, y, 6, seed + 1) - .5) * .5 + (GX.vn(x * .5, y, 3, seed + 2) - .5) * .3
      local col
      local edge = snowY + (GX.vn(x, y, 4, seed + 3) - .5) * 14
      local rib = GX.vn(x * .8, y * .35, 3, seed + 4)
      if y < edge and rib > .3 then
        col = v > .5 and "#fbfbff" or (v > .32 and "#dde3f8" or "#b4bcea")
      else
        col = R6[GX.idx(v)]
      end
      local t = min(1, dep / max(1, 150 - top)) * haze
      c:px(x, y, GX.mix(col, "#e4eef6", t))
    end
  end
end
layer({ { 70, 50, .95 }, { 150, 36, 1.0 }, { 235, 58, .85 }, { 330, 32, 1.1 }, { 418, 52, .9 }, { 482, 42, 1 } }, 118, 84,
  { hi = "#d0ccf0", base = "#aeaae0", shade = "#8e8acc", deep = "#7470b4" }, 11, .45)
layer({ { 14, 88, .8 }, { 112, 76, .9 }, { 200, 92, .75 }, { 292, 72, 1.0 }, { 382, 90, .85 }, { 458, 74, .9 } }, 130, 100,
  { hi = "#a4a2de", base = "#8482c8", shade = "#6c68b0", deep = "#545094" }, 21, .3)

-- marmot ledge on the mid range
do
  local lg = mk(); E(lg, 224, 114, 15, 4); E(lg, 232, 117, 12, 4); lg = GX.rough(lg, 31, 1)
  GX.lit(c, lg, GX.ramp6(STONEW), { R = 4, tex = .4, sc = 3, seed = 31, rimlight = true })
  local MAR = { hi = "#e6b684", base = "#b8804e", shade = "#865840", deep = "#503232" }
  local bd = mk(); E(bd, 225, 106, 3, 5); GX.lit(c, bd, GX.ramp6(MAR), { R = 3, tex = .2, seed = 5, rimlight = true })
  local hd = mk(); E(hd, 226, 100, 3, 2); GX.lit(c, hd, GX.ramp6(MAR), { R = 2, tex = .1, seed = 6, rimlight = true })
  c:px(227, 100, INK); c:px(229, 101, INK); c:px(222, 107, MAR.shade); c:px(226, 107, "#f0d4a8"); c:px(226, 108, "#f0d4a8")
end

-- eagle
do
  local col = "#3a2838"
  local body = mk(); E(body, 178, 38, 3, 2); c:fillMask(body, col)
  c:fillMask(c:poly{ { 178, 37 }, { 168, 31 }, { 158, 33 }, { 150, 39 }, { 160, 36 }, { 170, 39 } }, col)
  c:fillMask(c:poly{ { 178, 37 }, { 188, 31 }, { 198, 33 }, { 206, 39 }, { 196, 36 }, { 186, 39 } }, col)
  c:fillMask(c:poly{ { 176, 40 }, { 180, 40 }, { 181, 46 }, { 175, 46 } }, col)
  c:px(176, 36, "#f4ecd8"); c:px(177, 36, "#f4ecd8"); c:px(175, 36, "#f4ecd8")
  c:px(160, 34, "#6a5068"); c:px(167, 33, "#6a5068"); c:px(196, 34, "#6a5068")
end

---------------------------------------------------------------- meadow
GX.ground(c, function(x) return 134 + floor(4 * sin(x / 27 + 1)) end, GRASS, 7, { top = .84, fall = .6, tex = .32, sc = 8 })
-- low far treeline (edges only / left of the satchel zone)
local function pine(cx, top, base, w, seed, R)
  local tr = c:rect(cx - 2, base - 16, cx + 1, base)
  GX.lit(c, tr, GX.ramp6(BARK), { R = 2, tex = .2, seed = seed })
  local m = mk()
  local h = base - 12 - top
  for y = top, base - 12 do
    local t = (y - top) / h
    local tier = floor(t * 6); local tt = t * 6 - tier
    local hw = w * (0.1 + 0.9 * t) * (0.55 + 0.45 * tt) + (H(y, seed, 1) - .5) * 2
    for x = floor(cx - hw), floor(cx + hw) do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R), { R = 8, tex = .6, sc = 3, seed = seed, amb = .25, rimlight = true,
    fn = function(x, y) return (H(x // 2, y // 2, seed) - .5) * .2 end })
end
local FARP = { hi = "#6aa678", base = "#4a8a68", shade = "#38705c", deep = "#285048" }
for i, p in ipairs{ { 176, 120, 138, 7 }, { 190, 124, 140, 6 }, { 206, 118, 138, 7 }, { 256, 122, 140, 6 }, { 270, 119, 138, 7 }, { 452, 100, 138, 8 }, { 20, 112, 140, 8 } } do
  pine(p[1], p[2], p[3], p[4], 40 + i, FARP)
end

-- rocky slope shoulder behind the cairn
do
  local m = mk()
  for x = 0, 170 do
    local top = 146 - floor(14 * sqrt(max(0, 1 - ((x - 60) / 110) ^ 2))) + floor((GX.vn(x, 0, 6, 8) - .5) * 5)
    for y = top, 160 do m:set(x, y) end
  end
  m = GX.rough(m, 9, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#a8a4c4", base = "#7e7aa4", shade = "#605c88", deep = "#464270" }), { R = 10, tex = .55, sc = 4, seed = 9, rimlight = true })
end

---------------------------------------------------------------- big framing pines
local function blocked(x, y)
  return (x < 156 and y > 112 and y < 204) or (x > 280 and x < 440 and y > 60 and y < 220) or (abs(x - 357) < 80 and abs(y - 213) < 10)
end
-- shadows of pines
for _, t in ipairs{ { 28, 202, 34, 5 }, { 466, 206, 30, 5 } } do
  local m = mk(); E(m, t[1], t[2], t[3], t[4]); m = GX.rough(m, t[1], 1); c:fillMask(m, GX.mix(GRASS.shade, GRASS.base, .3))
end
pine(24, 4, 202, 38, 71, PINE)
pine(140, 78, 164, 20, 72, PINE)
pine(468, -4, 208, 36, 73, PINE)
pine(430, 118, 156, 10, 74, FARP)
GX.foliage(c, 44, 2, 34, 16, PINE, 301)
GX.foliage(c, 448, 0, 30, 14, PINE, 302)

---------------------------------------------------------------- ground detail
-- stream trickle
local function sx(y) return floor(224 + (y - 140) * .34 + 8 * sin((y - 140) / 14)) end
for y = 141, 269 do
  local w = 1 + floor((y - 141) / 34)
  local cx = sx(y)
  for x = cx - w - 1, cx + w + 1 do
    local dx = abs(x - cx)
    local col
    if dx > w then col = "#2c6a70"
    elseif dx == w then col = "#3f8aa8"
    else
      col = "#5cb4ec"
      if H(x, y // 2, 9) > .86 or (x == cx - w + 1 and H(x, y, 3) > .5) then col = "#d4f2ff" end
    end
    c:px(x, y, col)
  end
end
for _, y in ipairs{ 160, 190, 224, 250 } do   -- stones in the stream
  local m = mk(); E(m, sx(y) + 1, y, 3, 2)
  GX.lit(c, m, GX.ramp6(STONE), { R = 2, tex = .3, seed = y, rimlight = true })
end

-- boulders and scree
local function boulder(x, y, rx, ry, seed, R)
  local sh = mk(); E(sh, x + 2, y + ry - 1, rx + 2, 3); c:fillMask(sh, GX.mix(GRASS.shade, GRASS.deep, .3))
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R or STONE), { R = max(3, rx - 1), tex = .45, sc = 3, seed = seed, rimlight = true })
  local mo = mk(); E(mo, x - 2, y - ry + 1, rx - 3, 2)
  for yy = y - ry, y - ry + 3 do for xx = x - rx, x + rx do
    if m:has(xx, yy) and GX.vn(xx, yy, 3, seed) > .5 and H(xx, yy, seed) > .3 then c:px(xx, yy, GRASS.base) end
  end end
end
boulder(176, 176, 14, 9, 51); boulder(250, 160, 9, 6, 52, STONEW); boulder(36, 236, 16, 9, 53); boulder(168, 242, 11, 7, 54, STONEW)
boulder(300, 252, 8, 5, 55); boulder(472, 240, 12, 7, 56)
for i = 0, 70 do   -- scree pebbles
  local x, y = floor(H(i, 81, 1) * 480), 150 + floor(H(i, 83, 1) * 118)
  if not blocked(x, y) and (x < 280 or y > 224 or x > 440) then
    local R = (i % 2 == 0) and STONE or STONEW
    c:px(x, y, R.hi); c:px(x + 1, y, R.base); c:px(x, y + 1, R.shade); c:px(x + 1, y + 1, R.deep)
    if i % 3 == 0 then c:px(x + 2, y + 1, R.shade) end
  end
end
-- scree sweep below the cairn
for i = 0, 40 do
  local x, y = 40 + floor(H(i, 91, 1) * 120), 196 + floor(H(i, 93, 1) * 22)
  c:px(x, y, STONE.base); c:px(x + 1, y, STONE.shade)
end
for i = 0, 55 do   -- grass tufts
  local x, y = 6 + floor(H(i, 61, 1) * 468), 150 + floor(H(i, 63, 1) * 116)
  if not blocked(x, y) and (y < 224 or x < 300 or x > 440 or i % 3 == 0) then
    GX.tuft(c, x, y, y > 214 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep } or GRASS)
  end
end
for i = 0, 40 do   -- gentian and edelweiss
  local x, y = 10 + floor(H(i, 41, 1) * 460), 152 + floor(H(i, 43, 1) * 112)
  if not blocked(x, y) then
    if i % 3 == 0 then GX.flower(c, x, y, "#fffaf0", "#e8b830")
    elseif i % 3 == 1 then GX.flower(c, x, y, "#3a5ee0", "#d8e4ff")
    else GX.flower(c, x, y, "#8a5ae0", "#ffe8a0") end
  end
end
-- edelweiss clumps by the cairn
for _, p in ipairs{ { 112, 196 }, { 116, 199 }, { 48, 200 }, { 52, 203 } } do GX.flower(c, p[1], p[2], "#fffaf0", "#e8b830") end

---------------------------------------------------------------- hero cairn
do
  local sh = mk(); E(sh, 86, 200, 46, 5); sh = GX.rough(sh, 61, 1); c:fillMask(sh, GX.mix(GRASS.shade, GRASS.deep, .35))
  local st = {
    { 82, 190, 30, 10, STONE }, { 112, 194, 12, 7, STONEW }, { 56, 193, 11, 6, STONEW },
    { 80, 177, 24, 9, STONEW }, { 86, 165, 19, 8, STONE }, { 80, 154, 15, 7, STONEW },
    { 84, 144, 11, 6, STONE }, { 81, 136, 7, 5, STONEW }, { 82, 130, 4, 3, STONE } }
  for i, s in ipairs(st) do
    local m = mk(); E(m, s[1], s[2], s[3], s[4]); m = GX.rough(m, 60 + i, 1)
    GX.lit(c, m, GX.ramp6(s[5]), { R = max(3, s[4]), tex = .5, sc = 3, seed = 60 + i, rimlight = true })
    for k = 0, 3 do   -- lichen flecks
      local lx, ly = s[1] - s[3] + 4 + floor(H(k, i, 5) * (s[3] * 2 - 8)), s[2] - s[4] + 2 + floor(H(k, i, 6) * (s[4] * 2 - 4))
      if m:has(lx, ly) and m:has(lx + 1, ly) then c:px(lx, ly, "#d8c868"); c:px(lx + 1, ly, "#b8a850") end
    end
  end
  c:px(82, 126, "#fffaf0"); c:px(82, 125, "#e8493b"); c:px(83, 125, "#e8493b"); c:px(84, 126, "#b52e3f")   -- tiny ribbon on top
end

---------------------------------------------------------------- contact shadow for the satchel
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, SHADOW)

c:save{ aseprite = d .. "/../out/scene-mountain.aseprite", png = d .. "/../out/scene-mountain.png", scale = 1 }
