-- stage-mountain v3: clear-day base backdrop (no clouds, no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-mountain" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local GRASS = { hi = "#d4ec7e", base = "#8cc858", shade = "#58a050", deep = "#2e6a50" }
local PINE = { hi = "#58a468", base = "#2e7c58", shade = "#1f5a4c", deep = "#123a3c" }
local BARK = { hi = "#b88058", base = "#8a5a3c", shade = "#6a4236", deep = "#40262c" }
local STONE = { hi = "#eae6f2", base = "#b4aec8", shade = "#807c9c", deep = "#4c4a6c" }
local STONEW = { hi = "#efe0d2", base = "#c0aca4", shade = "#8c7884", deep = "#56465e" }
local DIRT = { hi = "#f0d09c", base = "#d0a468", shade = "#a8784c", deep = "#7a5440" }
local FARP = { hi = "#6aa678", base = "#4a8a68", shade = "#38705c", deep = "#285048" }

-- sky: plain gradient, small sun
GX.bands(c, 0, 150, { "#5ea6ea", "#7cbcf0", "#9ccef4", "#b8dcf4", "#d4eaf4", "#eef2e8" }, 3, .03)
do local m = mk(); E(m, 392, 54, 12, 12); m = GX.rough(m, 3, 1)
  GX.lit(c, m, R6({ hi = "#fffbe0", base = "#fff0a0", shade = "#ffe070", deep = "#f8c850" }), { R = 12, tex = .1, seed = 3, ink = false }) end

-- peaks
local function layer(peaks, cap, snowY, R, seed, haze)
  local RR = R6(R)
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
        col = v > .5 and "#fbf8f0" or (v > .32 and "#dde3f8" or "#b4bcea")
      else col = RR[GX.idx(v)] end
      local t = min(1, dep / max(1, 150 - top)) * haze
      c:px(x, y, GX.mix(col, "#e4eef6", t))
    end
  end
end
layer({ { 70, 50, .95 }, { 150, 36, 1.0 }, { 235, 58, .85 }, { 300, 32, 1.1 }, { 418, 52, .9 }, { 482, 42, 1 } }, 118, 84,
  { hi = "#d0ccf0", base = "#aeaae0", shade = "#8e8acc", deep = "#7470b4" }, 11, .45)
layer({ { 14, 88, .8 }, { 112, 76, .9 }, { 200, 92, .75 }, { 360, 72, 1.0 }, { 440, 90, .85 }, { 470, 74, .9 } }, 130, 100,
  { hi = "#a4a2de", base = "#8482c8", shade = "#6c68b0", deep = "#545094" }, 21, .3)

-- waterfall on the far range
for y = 78, 128 do local x = 330 + floor(sin(y / 9) * .8)
  c:px(x, y, "#d4f2ff"); c:px(x + 1, y, y % 5 == 0 and "#ffffff" or "#9ad8f4"); c:px(x + 2, y, "#5cb4ec") end
for x = 324, 338 do if H(x, 1, 7) > .3 then c:px(x, 129, "#e8f8ff"); c:px(x, 130, "#b4e4f8") end end

-- meadow
GX.ground(c, function(x) return 140 + floor(4 * sin(x / 27 + 1)) end, GRASS, 7, { top = .84, fall = .6, tex = .32, sc = 8 })
local function pine(cx, top, base, w, seed, R, trunk)
  if trunk ~= false then
    local tr = c:rect(cx - 2, base - 16, cx + 1, base)
    GX.lit(c, tr, R6(BARK), { R = 2, tex = .2, seed = seed })
  end
  local m = mk()
  local h = base - 12 - top
  for y = top, base - 12 do
    local t = (y - top) / h
    local tier = floor(t * 6); local tt = t * 6 - tier
    local hw = w * (0.1 + 0.9 * t) * (0.55 + 0.45 * tt) + (H(y, seed, 1) - .5) * 2
    for x = floor(cx - hw), floor(cx + hw) do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R), { R = 8, tex = .6, sc = 3, seed = seed, amb = .25, rimlight = true,
    fn = function(x, y) return (H(x // 2, y // 2, seed) - .5) * .2 end })
end
-- far treeline
for i = 0, 26 do
  local x = 6 + i * 18 + floor(H(i, 5, 5) * 8)
  if x < 150 or x > 330 or i % 2 == 0 then pine(x, 112 + floor(H(i, 6, 5) * 8), 146 + floor(H(i, 7, 5) * 3), 6 + floor(H(i, 8, 5) * 3), 40 + i, FARP) end
end
-- big framing pines (left and right edges, above the walkable strip)
for _, t in ipairs{ { 22, 188, 30, 4 }, { 460, 192, 28, 4 } } do
  local m = mk(); E(m, t[1], t[2], t[3], t[4]); m = GX.rough(m, t[1], 1); c:fillMask(m, GX.mix(GRASS.shade, GRASS.base, .3))
end
pine(22, 6, 188, 36, 71, PINE)
pine(462, -2, 192, 34, 73, PINE)
pine(120, 100, 158, 14, 72, PINE)
pine(410, 96, 156, 13, 74, PINE)
GX.foliage(c, 40, 4, 32, 14, PINE, 301)
GX.foliage(c, 446, 0, 30, 14, PINE, 302)

-- dirt path to the cairn
for y = 160, 269 do
  local cx = 258 + floor(sin(y / 22) * 6) + floor((y - 160) * .08)
  local w = 5 + floor((y - 160) * .22)
  for x = cx - w, cx + w do
    local e = min(x - (cx - w), (cx + w) - x)
    local col = (e == 0) and DIRT.shade or (GX.vn(x, y, 3, 9) > .78 and DIRT.hi or (GX.vn(x, y, 5, 10) < .2 and DIRT.shade or DIRT.base))
    if e == 0 and x < cx then col = DIRT.hi end
    c:px(x, y, col)
  end
end

-- boulders (corner, above the walkable strip) and scree
local function boulder(x, y, rx, ry, seed, R)
  local sh = mk(); E(sh, x + 2, y + ry - 1, rx + 2, 3); c:fillMask(sh, GX.mix(GRASS.shade, GRASS.deep, .3))
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R or STONE), { R = max(3, rx - 1), tex = .45, sc = 3, seed = seed, rimlight = true })
  for yy = y - ry, y - ry + 3 do for xx = x - rx, x + rx do
    if m:has(xx, yy) and GX.vn(xx, yy, 3, seed) > .5 and H(xx, yy, seed) > .3 then c:px(xx, yy, GRASS.base) end
  end end
end
boulder(78, 190, 14, 8, 51); boulder(396, 176, 10, 6, 52, STONEW); boulder(176, 172, 8, 5, 53, STONEW)
for i = 0, 40 do
  local x, y = floor(H(i, 81, 1) * 480), 168 + floor(H(i, 83, 1) * 100)
  if abs(x - 258) > 40 or y < 190 then
    local R = (i % 2 == 0) and STONE or STONEW
    c:px(x, y, R.hi); c:px(x + 1, y, R.base); c:px(x, y + 1, R.shade); c:px(x + 1, y + 1, R.deep)
  end
end
for i = 0, 42 do
  local x, y = 6 + floor(H(i, 61, 1) * 468), 170 + floor(H(i, 63, 1) * 96)
  if abs(x - 258) > 36 then GX.tuft(c, x, y, y > 214 and { hi = GRASS.base, base = GRASS.shade, shade = GRASS.deep } or GRASS) end
end
for i = 0, 30 do
  local x, y = 10 + floor(H(i, 41, 1) * 460), 170 + floor(H(i, 43, 1) * 94)
  if abs(x - 258) > 36 then
    if i % 3 == 0 then GX.flower(c, x, y, "#fffaf0", "#e8b830")
    elseif i % 3 == 1 then GX.flower(c, x, y, "#3a5ee0", "#d8e4ff")
    else GX.flower(c, x, y, "#8a5ae0", "#ffe8a0") end
  end
end

-- hero cairn
do
  local sh = mk(); E(sh, 256, 170, 38, 4); sh = GX.rough(sh, 61, 1); c:fillMask(sh, GX.mix(GRASS.shade, GRASS.deep, .35))
  local st = {
    { 254, 162, 26, 8, STONE }, { 280, 165, 10, 6, STONEW }, { 232, 164, 9, 5, STONEW },
    { 254, 151, 20, 8, STONEW }, { 256, 140, 16, 7, STONE }, { 253, 130, 12, 6, STONEW },
    { 255, 121, 8, 5, STONE }, { 254, 114, 5, 4, STONEW } }
  for i, s in ipairs(st) do
    local m = mk(); E(m, s[1], s[2], s[3], s[4]); m = GX.rough(m, 60 + i, 1)
    GX.lit(c, m, R6(s[5]), { R = max(3, s[4]), tex = .5, sc = 3, seed = 60 + i, rimlight = true })
    for k = 0, 3 do
      local lx, ly = s[1] - s[3] + 4 + floor(H(k, i, 5) * (s[3] * 2 - 8)), s[2] - s[4] + 2 + floor(H(k, i, 6) * (s[4] * 2 - 4))
      if m:has(lx, ly) and m:has(lx + 1, ly) then c:px(lx, ly, "#d8c868"); c:px(lx + 1, ly, "#b8a850") end
    end
  end
  -- quirk: tiny red ribbon on top
  c:px(254, 109, INK); c:px(254, 108, "#e8493b"); c:px(255, 108, "#e8493b"); c:px(256, 109, "#b52e3f")
end

c:save{ aseprite = d.."/out/stage-mountain.aseprite", png = d.."/out/stage-mountain.png", scale = 1 }
