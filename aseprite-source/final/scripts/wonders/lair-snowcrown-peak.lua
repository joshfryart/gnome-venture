-- lair-snowcrown-peak.lua : Boss lair (ESA, zone 2). The Mountain Lion of the Snowpeak, on a rock below a snow-crowned African peak. Bright day. Params out= ase=
-- v2 (polish): craggy irregular peak painted per pixel (spur ridges, lit west faces, rock strata, snowcap with a lit edge),
-- far blue range for depth, real flat-topped acacias in the foreground. The lion and his rock are unchanged.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local function hash(x, y, s) local v = sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453 return v - floor(v) end
local INK = "#2b1c26"

L.sky(c, "day", 92)
for _, cl in ipairs({ {36,26,16},{206,20,18},{170,46,14},{70,50,12} }) do L.cloud(c, cl[1], cl[2], cl[3]) end

-- piecewise-linear profile helper
local function prof(pts, x)
  if x <= pts[1][1] then return pts[1][2] end
  for i = 2, #pts do
    local a, b = pts[i - 1], pts[i]
    if x <= b[1] then return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1]) end
  end
  return pts[#pts][2]
end

-- far range (air-blue, low contrast) with small snow tips
local FAR = { {0,74},{14,66},{24,70},{36,60},{46,66},{58,72},{180,72},{192,62},{202,66},{214,56},{226,64},{240,60} }
for x = 0, W - 1 do
  local top = floor(prof(FAR, x) + (hash(floor(x / 2), 3) - 0.5) * 1.6)
  for y = top, 98 do
    local col = ((x + y) % 2 == 0 and y - top < 3) and "#c7d2e6" or "#a6b3d0"
    if y - top < 4 and y < 66 then col = (x % 3 == 0) and "#d9e0ee" or "#e6eaf4" end
    if y - top > 9 then col = "#97a4c4" end
    c:px(x, y, col)
  end
  c:px(x, top - 1, "#8c98ba")
end

-- the main peak: irregular skyline, summit right of centre-ish, a notch, a sub-peak east
local SKY = { {0,104},{14,98},{30,88},{44,78},{56,70},{66,66},{76,60},{84,54},{90,56},{96,48},{104,40},{110,32},{116,24},{121,18},{125,13},{128,11},{131,14},{134,13},{138,19},{143,25},{148,29},{154,31},{160,32},{165,30},{169,26},{173,21},{176,17},{179,19},{183,26},{188,33},{192,31},{197,28},{201,32},{206,40},{214,52},{222,64},{230,78},{240,92} }
local function skyline(x) return prof(SKY, x) + (hash(floor(x / 2), 7) - 0.5) * 2.2 + ((x % 9 == 4) and -1 or 0) end
-- spur ridges (they make the faces): {x,y} polylines from crest down
local SPURS = {
  { {128,11},{118,30},{106,50},{94,72},{84,104} },
  { {128,11},{138,30},{142,50},{140,72},{136,104} },
  { {176,17},{168,36},{162,56},{160,80},{158,104} },
  { {176,17},{186,40},{196,62},{204,84},{210,104} },
  { {197,28},{208,50},{220,72},{228,104} },
  { {90,56},{80,74},{66,90},{54,104} },
  { {116,24},{112,44},{116,64},{118,104} },
}
local function segd(px, py, ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  local t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
  local qx, qy = ax + dx * t, ay + dy * t
  return sqrt((px - qx) ^ 2 + (py - qy) ^ 2)
end
local function height(x, y)
  local best = -1e9
  for si, s in ipairs(SPURS) do
    for i = 2, #s do
      local d = segd(x, y, s[i - 1][1], s[i - 1][2], s[i][1], s[i][2])
      d = d + (hash(floor(x / 4) + si, floor(y / 3), 11) - 0.5) * 1.8   -- crags
      local hv = 40 - d - y * 0.08 * (si > 4 and 1.4 or 1)
      if hv > best then best = hv end
    end
  end
  return best
end
local ROCK = { "#3f3550", "#54485f", "#6c5f72", "#887a86", "#a6979c", "#c2b2a8" }   -- deep .. sunlit
local SNOW = { "#7f86ae", "#a3aacb", "#c6cce2", "#e2e5f0", "#f4f1e6", "#fbf7ea" }
local function snowline(x) return 40 + 5 * sin(x * 0.11 + 1.3) + 3 * sin(x * 0.31) + (hash(floor(x / 2), 21) - 0.5) * 4 end
local inM, tone, isSnow = {}, {}, {}
for x = 0, W - 1 do
  local top = floor(skyline(x) + 0.5)
  for y = max(0, top), 104 do
    local k = y * W + x
    inM[k] = true
    local g = height(x + 1, y) - height(x - 1, y)                      -- >0: rises to the east, the face looks west into the sun
    local gy = height(x, y + 1) - height(x, y - 1)
    local L = g * 1.1 - gy * 0.2 + (hash(floor(x / 2), y, 5) - 0.5) * 0.18
    local t = L > 0.9 and 5 or (L > 0.2 and 4 or (L > -0.5 and 3 or (L > -1.2 and 2 or 1)))
    -- snow: the crown, plus fingers down the gullies and along the spur crests
    local sl = snowline(x)
    local crest = height(x, y) > 37.2
    local saddle = x >= 144 and x <= 172 and y < 46 + floor(2 * sin(x * 0.5))
    local snow = saddle or y < sl or (crest and y < sl + 16 and hash(floor(x / 2), floor(y / 3), 4) > 0.25) or (y < sl + 7 and t <= 2 and hash(x, floor(y / 2), 9) > 0.55)
    if snow then
      isSnow[k] = true
      tone[k] = min(6, t + 1)
    else
      -- rock strata: tilted bands, broken here and there
      local band = (y + x * 0.22 + 2 * sin(x * 0.09)) % 7
      if band < 1 and hash(floor(x / 5), floor(y / 7), 13) > 0.12 then t = max(1, t - 1)
      elseif band >= 1 and band < 2 and t >= 3 and hash(floor(x / 5), floor(y / 7), 14) > 0.3 then t = min(6, t + 1) end
      if y > 84 then t = max(1, t - ((y > 94) and 2 or 1)) end            -- the foot sinks into haze/shadow
      tone[k] = t
    end
  end
end
for k in pairs(inM) do
  local x, y = k % W, k // W
  local t = tone[k]
  local col = isSnow[k] and SNOW[t] or ROCK[t]
  if isSnow[k] then
    -- snow over rock: 1 px cold blue lip under the snow, so the cap reads with a clear edge
    local below = (y + 1) * W + x
    if inM[below] and not isSnow[below] then col = SNOW[1] end
    -- lit edge: top of the cap against sky on the west-facing side
    if not inM[k - W] and t >= 3 then col = SNOW[6] end
    if not inM[k - W] and t < 3 then col = SNOW[3] end
  else
    if isSnow[k - W] then col = ROCK[1] end                                 -- crevice shadow under the snow line
    if not inM[k - W] and t >= 4 then col = ROCK[6] end
  end
  c:px(x, y, col)
end
-- skyline rim (1 px dark violet so the peak cuts cleanly from the sky)
for x = 0, W - 1 do
  local top = floor(skyline(x) + 0.5)
  if top - 1 >= 0 and top <= 104 then c:px(x, top - 1, "#4a3c5e") end
  local tl, tr = floor(skyline(x - 1) + 0.5), floor(skyline(x + 1) + 0.5)
  for y = top, min(tl, tr) - 2 do if not inM[y * W + x - 1] or not inM[y * W + x + 1] then c:px(x, y, "#4a3c5e") end end
end
-- a few wind-blown snow plumes off the summit
for i, p in ipairs({ {132,10},{135,11},{138,12},{142,13},{137,9},{145,14},{180,16},{183,17},{186,18} }) do c:px(p[1], p[2], i % 2 == 0 and "#e6eaf4" or "#d9e0ee") end

-- cloud belt around the peak
L.cloud(c, 150, 82, 20, "#f4f0e0", "#cfd8e4"); L.cloud(c, 214, 86, 18, "#f4f0e0", "#cfd8e4"); L.cloud(c, 20, 92, 12, "#f4f0e0", "#cfd8e4")
-- foothill heath and savanna
c:part(L.below(c, function(x) return 98 + math.sin(x * 0.05 + 1) * 5 end), GV.ramp("#6a9a3a"), { outline = false, gloss = false, cres = 3, deep = 4 })
c:part(L.below(c, function(x) return 108 + math.sin(x * 0.06) * 3 end), GV.ramp("#c9a96e"), { outline = false, gloss = false, cres = 3, deep = 4 })
-- savanna texture: dry grass strokes and darker tussocks
for i = 0, 140 do
  local x = floor(hash(i, 1, 30) * W); local y = 110 + floor(hash(i, 2, 30) * 24)
  c:px(x, y, (i % 3 == 0) and "#a8864e" or "#dcbf86"); if i % 2 == 0 then c:px(x, y - 1, "#b8965c") end
end
for i = 0, 40 do
  local x = floor(hash(i, 3, 31) * W); local y = 100 + floor(hash(i, 4, 31) * 7)
  c:px(x, y, "#4e7a2e"); c:px(x + 1, y, "#5a8a34")
end

-- ===== acacias: forked tapering trunk, spreading limbs, flat layered crown (4 tones, lit top-left edge, ink rim)
local BARK = { "#3a2418", "#5a3824", "#7a4e30", "#9a6a44" }
local LEAF = { "#2e4a1e", "#43662a", "#5c8234", "#7aa044", "#a4c060" }
local function limb(m, x0, y0, x1, y1, w0, w1)
  local n = max(abs(x1 - x0), abs(y1 - y0)) * 2 + 1
  for i = 0, n do
    local t = i / n
    local cx, cy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    local r = (w0 + (w1 - w0) * t) / 2
    for yy = floor(cy - r), floor(cy + r) do for xx = floor(cx - r), floor(cx + r) do
      if (xx + 0.5 - cx) ^ 2 + (yy + 0.5 - cy) ^ 2 <= r * r + 0.3 then m:set(xx, yy) end
    end end
  end
end
local function acacia(x, yb, s, seed)
  -- wood
  local wood = c:mask()
  local fy = yb - floor(22 * s)
  limb(wood, x, yb, x + 1 * s, fy, 5 * s, 3 * s)
  local tops = {}
  for i, a in ipairs({ { -16, -14 }, { -3, -18 }, { 12, -16 }, { 22, -10 } }) do
    local tx, ty = x + a[1] * s + (hash(seed, i) - 0.5) * 3, fy + a[2] * s
    limb(wood, x + s, fy, tx, ty, 3 * s, 1.2)
    tops[i] = { tx, ty }
  end
  -- root flare
  limb(wood, x - 3 * s, yb, x - 6 * s, yb + 1, 2.5 * s, 1); limb(wood, x + 3 * s, yb, x + 7 * s, yb + 1, 2.5 * s, 1)
  local wx0, wy0, wx1, wy1 = wood:bbox()
  wood:each(function(px, py)
    local lit = not wood:has(px - 1, py)
    local dark = not wood:has(px + 1, py)
    local col = lit and BARK[4] or (dark and BARK[1] or BARK[2])
    if not lit and not dark and hash(px, floor(py / 2), seed) > 0.75 then col = BARK[3] end
    c:px(px, py, col)
  end)
  -- crown: two flat layers of lumpy pads
  local crownM = c:mask()
  local pads = {}
  for i = 1, 7 do
    local px = x + (-24 + (i - 1) * 8 + (hash(seed, i, 2) - 0.5) * 4) * s
    local py = fy - 18 * s - (1 - abs(i - 4) / 4) * 3 * s + (hash(seed, i, 3) - 0.5) * 2
    pads[#pads + 1] = { px, py, (7 + hash(seed, i, 4) * 4) * s, (3 + hash(seed, i, 5) * 1.5) * s }
  end
  for i = 1, 4 do
    pads[#pads + 1] = { x + (-14 + (i - 1) * 9 + (hash(seed, i, 6) - 0.5) * 3) * s, fy - 22 * s - (hash(seed, i, 7)) * 2 * s, (6 + hash(seed, i, 8) * 3) * s, 2.6 * s }
  end
  local owner = {}
  for pi, p in ipairs(pads) do
    for yy = floor(p[2] - p[4] - 1), floor(p[2] + p[4] + 1) do for xx = floor(p[1] - p[3] - 1), floor(p[1] + p[3] + 1) do
      local nx, ny = (xx + 0.5 - p[1]) / p[3], (yy + 0.5 - p[2]) / p[4]
      local wob = 1 + 0.18 * sin(xx * 1.7 + pi) * (ny < 0 and 1 or 0.4)
      if nx * nx + ny * ny <= wob then
        crownM:set(xx, yy)
        local v = -(nx * 0.45 + ny * 0.9) + (hash(floor(xx / 2), yy, seed + pi) - 0.5) * 0.5
        local t = v > 0.55 and 4 or (v > -0.1 and 3 or (v > -0.7 and 2 or 1))
        owner[yy * W + xx] = { pi, t }
      end
    end end
  end
  -- ink rim around the crown (outside), then fill with tones, lit edges, inner pad edges
  local g = crownM:grow(1)
  g:each(function(px, py) if not crownM:has(px, py) then c:px(px, py, INK) end end)
  crownM:each(function(px, py)
    local o = owner[py * W + px]
    local t = o[2]
    local up, lf = owner[(py - 1) * W + px], owner[py * W + px - 1]
    if not up and (px - x) < 10 * s then t = 5
    elseif up and up[1] < o[1] and (pads[o[1]][2] > pads[up[1]][2] + 0.5) then t = min(4, t + 1)
    elseif not owner[(py + 1) * W + px] then t = 1 end
    if lf and lf[1] ~= o[1] and t > 1 and (pads[lf[1]][2] < pads[o[1]][2]) then t = t - 1 end
    c:px(px, py, LEAF[t])
  end)
  -- wood ink rim where wood meets non-wood below the crown
  wood:grow(1):each(function(px, py)
    if not wood:has(px, py) and not crownM:has(px, py) and not g:has(px, py) and py > fy - 18 * s + 3 * s then c:px(px, py, INK) end
  end)
  wood:each(function(px, py) if py > fy - 18 * s + 4 * s and not crownM:has(px, py) then
    local lit = not wood:has(px - 1, py); local dark = not wood:has(px + 1, py)
    local col = lit and BARK[4] or (dark and BARK[1] or BARK[2])
    if not lit and not dark and hash(px, floor(py / 2), seed) > 0.75 then col = BARK[3] end
    c:px(px, py, col) end end)
  -- cast shadow on the grass, falling right (sun upper left)
  for xx = floor(x - 4 * s), floor(x + 14 * s) do c:px(xx, yb + 1, "#9a7a48"); if (xx % 2 == 0) then c:px(xx + 1, yb + 2, "#9a7a48") end end
end
-- distant small ones on the heath, then the two big foreground trees
acacia(64, 108, 0.42, 7); acacia(182, 107, 0.5, 8); acacia(198, 104, 0.32, 9)

-- giant lobelia on the slopes
for _, p in ipairs({ {40,100},{46,104},{196,102} }) do c:fill(c:rect(p[1], p[2] - 8, p[1] + 1, p[2]), "#4a8a3e"); c:part(c:ellipse(p[1] + 0.5, p[2] - 10, 2.5, 4), GV.ramp("#a4b86a"), { flat = true }) end

acacia(160, 133, 0.72, 3)
acacia(214, 131, 0.95, 4)

local D = -52   -- lion and rock sit left of centre so the summits show to his right
-- the lion's rock
c:part(c:poly({ {D+64,H},{D+72,118},{D+90,106},{D+150,106},{D+168,118},{D+176,H} }), GV.ramp("#a89a82"), { cres = 8, deep = 11, gloss = false })
c:seam({ {D+82,120},{D+96,116},{D+104,122} }, { free = true, on = 3, off = 0, gap = "#4a3a2a" }); c:seam({ {D+140,118},{D+154,120},{D+160,126} }, { free = true, on = 3, off = 0, gap = "#4a3a2a" })
-- rock strata and lichen
for _, ln in ipairs({ { D+74, 124, D+92 }, { D+148, 126, D+164 }, { D+70, 130, D+86 }, { D+156, 131, D+172 } }) do
  for xx = ln[1], ln[3] do c:px(xx, ln[2] + ((xx // 5) % 2), "#8a7c66") end
end
for _, p in ipairs({ {D+94,110},{D+98,111},{D+152,112},{D+80,118},{D+166,124} }) do c:px(p[1], p[2], "#a4b86a"); c:px(p[1] + 1, p[2], "#c8d77a") end
-- the Mountain Lion
local CX = 120 + D
local TAWNY, MANE = GV.ramp("#d9a660"), GV.ramp("#8a4f2a")
c:part(c:line({ {CX + 22, 108}, {CX + 34, 100}, {CX + 32, 84} }, 4), TAWNY, { cres = 2, deep = 3, gloss = false })   -- tail
c:part(c:ellipse(CX + 32, 80, 4, 5), MANE, { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(CX, 96, 22, 14), TAWNY, { cres = 5, deep = 7 })                                  -- body
for _, sx in ipairs({ -9, 9 }) do c:part(c:rrect(CX + sx - 4, 100, CX + sx + 3, 112, 2), TAWNY, { cres = 2, deep = 3, gloss = false }); c:part(c:ellipse(CX + sx, 112, 5, 3), GV.ramp("#f2e4c0"), { flat = true }) end
c:part(c:ellipse(CX, 66, 28, 25), MANE, { cres = 6, deep = 9 })                                   -- mane
for _, a in ipairs({ -22, -12, 12, 22 }) do c:part(c:poly({ {CX + a - 4, 86}, {CX + a, 94}, {CX + a + 4, 86} }), MANE, { flat = true, outline = false }) end
for _, s in ipairs({ -1, 1 }) do c:part(c:ellipse(CX + s * 17, 48, 5, 5), TAWNY, { flat = true }); c:part(c:ellipse(CX + s * 17, 48, 2, 2), GV.ramp("#d9885a"), { flat = true, outline = false }) end
c:part(c:ellipse(CX, 68, 17, 15), TAWNY, { cres = 4, deep = 6 })                                  -- face
c:part(c:ellipse(CX, 76, 9, 6), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(CX - 3, 69, CX + 2, 72), "#2a1a10"); c:px(CX - 2, 73, "#2a1a10"); c:px(CX + 1, 73, "#2a1a10")
c:fill(c:rect(CX - 5, 77, CX - 1, 77), "#2a1a10"); c:fill(c:rect(CX + 0, 77, CX + 4, 77), "#2a1a10")
c:eye(CX - 12, 60); c:eye(CX + 7, 60)
for k = 0, 4 do c:px(CX - 13 + k, (k < 3) and 58 or 59, "#2a1a10"); c:px(CX + 13 - k, (k < 3) and 58 or 59, "#2a1a10") end
-- a little snow crown the lion has stolen: tiny pale zig-zag circlet on the mane
c:fill(c:poly({ {CX - 8, 44}, {CX - 6, 39}, {CX - 3, 43}, {CX, 38}, {CX + 3, 43}, {CX + 6, 39}, {CX + 8, 44} }), "#eef0f8")
c:px(CX, 39, "#fff1c8")
-- birds and grass
for _, g in ipairs({ {14,44},{186,62},{212,30} }) do c:px(g[1], g[2], "#2a1a10"); c:px(g[1] + 1, g[2] + 1, "#2a1a10"); c:px(g[1] + 2, g[2], "#2a1a10"); c:px(g[1] + 3, g[2] + 1, "#2a1a10"); c:px(g[1] + 4, g[2], "#2a1a10") end
for _, x in ipairs({ 8, 132, 150, 176, 200, 228 }) do c:px(x, 126 + x % 4, "#a4b86a"); c:px(x + 1, 125 + x % 4, "#c8d77a"); c:px(x + 2, 126 + x % 4, "#a4b86a") end
c:ground(CX, 113, 24, 2)
L.finish(c, "lair-snowcrown-peak")
