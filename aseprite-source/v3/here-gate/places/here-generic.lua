-- here-generic: Hearth Pop v3 gate view, fallback "plain place" crossroads clearing. 480x270 native.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local X = dofile(ROOT .. "lib/hpx.lua").init(HP)
local OUT = app.params.out or (ROOT .. "here-gate/places/")
local NAME = "here-generic"
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos
local hash = X.hash
local W, H, HZ = 480, 270, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
-- v2.5.40 polish: guarded painting. Nothing is ever changed near a stand point or in the compass corner.
local STAND = { { 196, 248 }, { 284, 248 }, { 240, 214 }, { 212, 180 }, { 268, 184 }, { 350, 206 } }
local function zok(x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return false end
  if x >= 378 and y >= 228 then return false end
  for _, s in ipairs(STAND) do if abs(x - s[1]) <= 16 and abs(y - s[2]) <= 16 then return false end end
  return true
end

---------------------------------------------------------------- colour helpers
local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function hex(r, g, b)
  local function cl(v) return max(6, min(249, floor(v + .5))) end
  return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  return hex(r1 + (r2-r1)*t, g1 + (g2-g1)*t, b1 + (b2-b1)*t)
end
local VIO, VIO2, WARM, WARM2 = "#3b2a52", "#4a3d6e", "#ffe7b0", "#fff3d2"
local function tones(base) return { mix(base, VIO, .55), mix(base, VIO2, .3), base, mix(base, WARM, .3), mix(base, WARM2, .55) } end
local function edgeOf(base) return mix(base, "#2b1c26", .6) end

local function gput(x, y, col) x, y = floor(x), floor(y) if zok(x, y) and c:get(x, y) then c:put(x, y, col) end end
local function gmix(x, y, col, t) x, y = floor(x), floor(y) if zok(x, y) then local cur = c:get(x, y) if cur then c:put(x, y, mix(cur, col, t)) end end end
local function gmask(m, col, t) m:each(function(x, y) if t then gmix(x, y, col, t) else gput(x, y, col) end end) end
local function gvec(x0, y0, x1, y1, col, t) -- guarded 1px line
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do local x, y = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n if t then gmix(x, y, col, t) else gput(x, y, col) end end
end
local function grect(x0, y0, x1, y1, col, t) for y = y0, y1 do for x = x0, x1 do if t then gmix(x, y, col, t) else gput(x, y, col) end end end end
local function bbox(m) return m:bbox() end
-- shade a mask: light from upper-left, optional texture fn(x,y,x0,y0) -> delta
local function shade(m, base, tex, o)
  o = o or {}
  local T = tones(base)
  local x0, y0, x1, y1 = bbox(m)
  if not x0 then return end
  local w, h = max(1, x1 - x0), max(1, y1 - y0)
  m:each(function(x, y)
    local v = 0.66 - 0.28 * (x - x0) / w - 0.22 * (y - y0) / h + (o.bias or 0)
    if tex then v = v + tex(x, y, x0, y0) end
    v = v + (hash(x, y, o.seed or 7) - 0.5) * 0.05
    local i = v < .2 and 1 or v < .37 and 2 or v < .58 and 3 or v < .74 and 4 or 5
    c:put(x, y, T[i])
  end)
  if o.edge ~= false then c:edgeIn(m, o.edgeCol or edgeOf(base)) end
end
local function darken(m, t, col)
  m:each(function(x, y) local cur = c:get(x, y) if cur then c:put(x, y, mix(cur, col or "#41365f", t)) end end)
end
local function shadowE(cx, cy, rx, ry, t) darken(c:ellipse(cx, cy, rx, ry), t or .32) end
local function glow(cx, cy, rx, ry, col, amt)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local d = ((x - cx) / rx)^2 + ((y - cy) / ry)^2
    if d < 1 then
      local g = d < .3 and amt or d < .65 and amt * .6 or amt * .3
      local cur = c:get(x, y) if cur then c:put(x, y, mix(cur, col, g)) end
    end
  end end
end

---------------------------------------------------------------- textures
local TX = {}
function TX.plank(p) return function(x, y, x0, y0)
  local r = (y - y0) % p local d = 0
  if r == p - 1 then d = -0.2 elseif r == 0 then d = 0.07 end
  if hash(floor((x + floor((y - y0) / p) * 5) / 9), floor((y - y0) / p), 3) > .8 and r > 0 and r < p - 1 then d = d - 0.08 end
  return d end end
function TX.vplank(p) return function(x, y, x0, y0)
  local r = (x - x0) % p local d = 0
  if r == p - 1 then d = -0.2 elseif r == 0 then d = 0.07 end
  if hash(floor((x - x0) / p), floor(y / 6), 13) > .78 and r > 0 and r < p - 1 then d = d - 0.08 end
  return d end end
function TX.stone(bw, bh) return function(x, y, x0, y0)
  local row = floor((y - y0) / bh) local off = (row % 2) * floor(bw / 2)
  local col = floor((x - x0 + off) / bw)
  local ry, rx = (y - y0) % bh, (x - x0 + off) % bw
  if ry == bh - 1 or rx == bw - 1 then return -0.24 end
  local d = (hash(col, row, 11) - 0.5) * 0.2
  if ry == 0 or rx == 0 then d = d + 0.1 end
  return d end end
function TX.shingle(bw, bh) return function(x, y, x0, y0)
  local row = floor((y - y0) / bh) local off = (row % 2) * floor(bw / 2)
  local ry, rx = (y - y0) % bh, (x - x0 + off) % bw
  if ry == bh - 1 then return -0.24 end
  if rx == 0 then return -0.14 end
  local d = (hash(floor((x - x0 + off) / bw), row, 17) - 0.5) * 0.16
  if ry == 0 then d = d + 0.1 end
  return d end end
function TX.leaf(s) return function(x, y)
  return (hash(floor(x / 3), floor(y / 3), s or 2) - 0.5) * 0.28 + (hash(x, y, 9) > .92 and 0.12 or 0) end end
function TX.plaster(x, y) return (hash(x, y, 31) > .93 and -0.1 or 0) + (hash(floor(x/4), floor(y/3), 32) > .85 and 0.06 or 0) end
function TX.bark(x, y, x0) return ((x - x0) % 3 == 0 and -0.1 or 0) + (hash(x, floor(y / 4), 41) > .8 and -0.1 or 0) end

---------------------------------------------------------------- sky + far scenery
c:stripes(0, HZ, { "#5a86c8", "#6593d0", "#729fd6", "#80acdc", "#90b9e0", "#a2c6e4", "#b6d3e6", "#cadee4", "#dde6dc","#efe6cc" },
  { 2, 2, 2, 2, 2, 2, 1.6, 1.4, 1.2, 1 })
c:cloud(60, 60, 46, "#f6f1e4", "#d9dcec")
c:cloud(150, 44, 34, "#f6f1e4", "#d9dcec")
c:cloud(300, 52, 52, "#f6f1e4", "#d9dcec")
c:cloud(390, 36, 30, "#f6f1e4", "#d9dcec")
c:cloud(220, 78, 22, "#f3ece0", "#dcd9e6")
-- far blue ridge
local ridge = c:terrain(function(x) return 82 + 7 * sin(x / 41) + 4 * sin(x / 13 + 1.3) + 3 * sin(x / 7.3) end, "#93abc4", HZ)
ridge:each(function(x, y) if not ridge:has(x, y - 1) then c:put(x, y, "#b4c6d6") end end)
-- rolling green hills, patchwork fields
local hillF = function(x) return 95 + 6 * sin(x / 53 + 2) + 4 * sin(x / 23) end
local hills = c:terrain(hillF, "#8fbe6c", HZ)
hills:each(function(x, y)
  local f = hillF(x)
  local band = floor((x + (y - f) * 3) / 34)
  local k = hash(band, floor((y - f) / 5), 51)
  local col = k > .66 and "#a3c977" or k < .25 and "#7cad5e" or "#8fbe6c"
  if k > .9 then col = "#c8c27a" end -- wheat field
  if y <= floor(f + .5) then col = "#b2d488" end
  c:put(x, y, col)
end)
-- hedgerows + distant trees (small chunky blobs)
for i = 0, 15 do
  local x = 18 + i * 29 + floor(hash(i, 2, 52) * 14)
  local y = floor(hillF(x) + 3 + hash(i, 3, 53) * 6)
  local m = c:ellipse(x, y - 3, 3 + floor(hash(i, 4, 54) * 2), 4)
  c:fillMask(m, "#5e8c55")
  c:fillMask(m:copy():clip(c:rect(x - 6, y - 8, x - 1, y - 3)), "#76a465")
  c:put(x, y + 1, "#6b5a4e")
end
for x = 0, W - 1 do if (x // 6) % 2 == 0 then c:put(x, floor(hillF(x) + 9 + sin(x / 30) * 2), "#6f9b57") end end

---------------------------------------------------------------- ground
for y = HZ, H - 1 do
  local t = (y - HZ) / (H - 1 - HZ)
  local tq = floor(t * 8) / 8
  local base = mix("#a9cf73", "#64a043", tq)
  for x = 0, W - 1 do
    local p = hash(floor(x / (6 + t * 22)), floor(y / (3 + t * 7)), 4)
    local col = base
    if p > .72 then col = mix(base, "#cfe08a", .3) elseif p < .18 then col = mix(base, "#4c7d44", .22) end
    c:put(x, y, col)
  end
end
-- grass tufts (bigger near)
for i = 0, 1400 do
  local x = floor(hash(i, 1, 61) * W)
  local y = HZ + 4 + floor(hash(i, 2, 62) ^ 0.8 * (H - HZ - 4))
  local t = (y - HZ) / (H - HZ)
  local hgt = 1 + floor(t * 3)
  local base = c:get(x, y)
  if base then
    local dk, lt = mix(base, "#2f5a33", .38), mix(base, "#e6f0a0", .35)
    for k = 0, hgt do c:put(x, y - k, k == hgt and lt or dk) end
    if t > .4 then c:put(x - 1, y - 1, dk) c:put(x + 1, y - 1, dk) c:put(x + 1, y - 2, lt) end
  end
end

-- paths: main road to VP, crossroad arms, wild trail to right edge
local VPX = 240
local road = c:poly{ { 233, HZ }, { 247, HZ }, { 336, H - 1 }, { 144, H - 1 } }
local armL = c:poly{ { 150, 128 }, { 224, 126 }, { 221, 139 }, { 150, 141 } }
local armR = c:poly{ { 256, 126 }, { 318, 128 }, { 318, 140 }, { 260, 139 } }
local trail = c:poly{ { 290, 188 }, { 340, 178 }, { 466, 160 }, { 466, 186 }, { 352, 206 }, { 304, 222 } }
local path = road:copy():add(armL):add(armR):add(trail)
path:each(function(x, y)
  local t = (y - HZ) / (H - HZ)
  local base = mix("#d9bd88", "#c49a62", floor(t * 6) / 6)
  local col = base
  local n = hash(floor(x / (2 + t * 6)), floor(y / (1 + t * 3)), 71)
  if n > .8 then col = mix(base, "#e8d4a6", .45) elseif n < .15 then col = mix(base, "#8f6a4c", .25) end
  c:put(x, y, col)
end)
-- ruts converging to VP
for y = HZ + 6, H - 1 do
  local t = (y - HZ) / (H - HZ)
  for _, s in ipairs{ -1, 1 } do
    local x = floor(VPX + s * (3 + t * 44) + .5)
    local cur = c:get(x, y)
    if cur and path:has(x, y) then
      c:put(x, y, mix(cur, "#7e5d48", .3))
      if t > .5 then c:put(x + s, y, mix(c:get(x + s, y), "#7e5d48", .2)) end
    end
  end
end
-- pebbles
for i = 0, 380 do
  local x = floor(hash(i, 5, 72) * W) local y = HZ + 3 + floor(hash(i, 6, 73) * (H - HZ - 3))
  if path:has(x, y) and path:has(x + 2, y + 1) then
    local t = (y - HZ) / (H - HZ)
    local pc = ({ "#b7aba0", "#c9b48f", "#a4998f" })[1 + floor(hash(i, 7, 74) * 3)]
    c:put(x, y, mix(pc, "#fff4d6", .35)) c:put(x + 1, y, pc)
    c:put(x, y + 1, mix(pc, VIO, .35)) c:put(x + 1, y + 1, mix(pc, VIO, .35))
    if t > .55 then c:put(x + 2, y, mix(pc, VIO2, .2)) c:put(x - 1, y + 1, mix(pc, VIO, .35)) end
  end
end
-- path edge: darker lip + grass blades over it
path:edge():each(function(x, y) local cur = c:get(x, y) c:put(x, y, mix(cur, "#7a6a4a", .28)) end)
for i = 0, 260 do
  local y = HZ + 6 + floor(hash(i, 8, 75) * (H - HZ - 8))
  local t = (y - HZ) / (H - HZ)
  for _, s in ipairs{ -1, 1 } do
    local x = floor(VPX + s * (7 + t * 89)) + (s < 0 and 1 or -1)
    local base = mix("#a9cf73", "#64a043", t)
    for k = 0, 1 + floor(t * 3) do c:put(x, y - k, k == 0 and mix(base, "#2f5a33", .3) or base) end
  end
end

---------------------------------------------------------------- v2.5.40 polish pass 1: ground variety
local nopath = path:copy():grow(3)
local function ongrass(x, y) return y > HZ + 6 and not nopath:has(x, y) end
-- dithered tone patches (lighter meadow / shaded clover) so no wide field stays one tone
for i = 0, 70 do
  local cx, cy = floor(hash(i, 1, 201) * W), HZ + 6 + floor(hash(i, 2, 202) ^ 0.9 * (H - HZ - 8))
  local t = (cy - HZ) / (H - HZ)
  local rx, ry = 6 + floor(t * 16) + floor(hash(i, 3, 203) * 6), 2 + floor(t * 6)
  local lightP = hash(i, 4, 204) > .45
  c:ellipse(cx, cy, rx, ry):each(function(x, y)
    if ongrass(x, y) and (x + y) % 2 == 0 and hash(x, y, 205) > .3 then
      gmix(x, y, lightP and "#dff0a0" or "#3f7a44", lightP and .3 or .25)
    end
  end)
end
-- worn dirt paths leading from each prop to the road
local function worn(x0, y0, x1, y1, w)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local x, y = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n
    y = y + sin(i / 6) * 1.2
    local ww = w + floor(hash(i, 1, 211) * 2)
    for k = -ww, ww do
      local px, py = floor(x), floor(y + k * .5)
      local edge = abs(k) == ww
      if not path:has(px, py) then
        if edge then if hash(px, py, 212) > .5 then gmix(px, py, "#b9a070", .5) end
        else gput(px, py, hash(px, py, 213) > .75 and "#e2c898" or hash(px, py, 214) < .2 and "#b88e5e" or "#d2b27c") end
      end
    end
  end
end
worn(199, 154, 214, 166, 2)    -- signpost -> road
worn(318, 153, 272, 158, 2)    -- noticeboard -> road
worn(170, 224, 152, 226, 2)    -- fire pit -> road
worn(432, 223, 372, 213, 2)    -- wild trail sign -> trail
worn(160, 149, 150, 150, 1)
-- flower clusters (several kinds)
local FL = { "#f6d45a", "#f07a9a", "#fff0d0", "#a07ad8", "#7ab0e8", "#f2904a" }
for i = 0, 34 do
  local cx, cy = floor(hash(i, 1, 221) * W), HZ + 10 + floor(hash(i, 2, 222) * (H - HZ - 14))
  local col = FL[1 + floor(hash(i, 3, 223) * 6)]
  local t = (cy - HZ) / (H - HZ)
  for k = 0, 4 + floor(hash(i, 4, 224) * 4) do
    local x, y = cx + floor((hash(i, k, 225) - .5) * 16), cy + floor((hash(i, k, 226) - .5) * 6)
    if ongrass(x, y) then
      gput(x, y + 1, "#4c8a3c")
      if t > .5 then gput(x, y + 2, "#3f7a38") gput(x - 1, y, col) gput(x + 1, y, col) gput(x, y - 1, col) gput(x, y, "#fff3d2")
      else gput(x, y, col) gput(x, y - 1, mix(col, "#fff3d2", .4)) end
    end
  end
end
-- fallen leaves, pebbles and clover on the grass
for i = 0, 150 do
  local x, y = floor(hash(i, 1, 231) * W), HZ + 8 + floor(hash(i, 2, 232) * (H - HZ - 10))
  if ongrass(x, y) then
    local k = hash(i, 3, 233)
    if k < .35 then gput(x, y, "#d29a4a") gput(x + 1, y, "#b8743a") gput(x, y - 1, "#e8c070")
    elseif k < .65 then gput(x, y, "#c4bcb0") gput(x + 1, y, "#9a92a0") gput(x, y + 1, "#7a7488")
    else gput(x, y, "#4c8a3c") gput(x - 1, y - 1, "#5a9a46") gput(x + 1, y - 1, "#5a9a46") gput(x, y - 1, "#7ab85a") end
  end
end

---------------------------------------------------------------- ground glows (warm light spots)
glow(123, 224, 50, 15, "#ffb550", .3)    -- fire pit
glow(299, 170, 22, 7, "#ffcf70", .22)    -- lantern pool
glow(54, 136, 14, 4, "#ffcf70", .2)      -- cottage A door
glow(130, 131, 12, 3, "#ffcf70", .2)     -- cottage B door

---------------------------------------------------------------- v2.5.40 polish pass 4a: far haze + long cast shadows (all fall lower-right)
do
  local HILL = {}
  for _, h in ipairs{ "#a3c977", "#7cad5e", "#8fbe6c", "#c8c27a", "#b2d488", "#5e8c55", "#76a465", "#6f9b57", "#6b5a4e", "#93abc4", "#b4c6d6" } do HILL[h] = true end
  for y = 70, HZ + 6 do
    local k = (HZ + 6 - y) / 36 -- stronger toward the far horizon
    for x = 0, W - 1 do
      local cur = c:get(x, y)
      if cur and HILL[cur] and (x + y) % 2 == 0 and hash(x, y, 401) < .55 then gmix(x, y, "#dce6e8", min(.34, .1 + (y > 96 and .16 or 0))) end
    end
  end
  local function cast(x0, y0, len, w, t) -- shadow strip falling to the lower right
    for i = 0, len do for k = 0, w do gmix(x0 + i + k, y0 + floor(i * .45) + (k > 0 and 1 or 0), "#41365f", t) end end
  end
  cast(191, 150, 18, 2, .3)    -- signpost
  cast(302, 168, 16, 2, .3)    -- lantern post
  cast(322, 150, 15, 3, .28) cast(362, 150, 14, 3, .28) -- noticeboard posts
  cast(410, 150, 8, 2, .26)    -- bench
  cast(282, 112, 14, 3, .24)   -- far tree
  cast(78, 130, 16, 3, .26) cast(152, 126, 16, 3, .26) -- cottages
  cast(155, 156, 22, 2, .26)   -- garden wall
end

---------------------------------------------------------------- objects (back to front)
-- leafy blob helper
local function canopy(cx, cy, rx, ry, base, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local lobes = {}
  for i = 0, 6 do
    local a = i / 7 * 6.283 + hash(i, seed, 81)
    local lx, ly = floor(cx + cos(a) * rx * .72), floor(cy + sin(a) * ry * .7)
    local lr = floor(min(rx, ry) * (.42 + hash(i, seed, 82) * .2))
    local lm = c:ellipse(lx, ly, lr, floor(lr * .9))
    m:add(lm) lobes[#lobes + 1] = { lx, ly, lr }
  end
  shade(m, base, TX.leaf(seed), { bias = .02 })
  local T = tones(base)
  table.sort(lobes, function(a, b) return a[2] < b[2] end)
  for _, l in ipairs(lobes) do -- lit crescents on upper-left of each clump, shade lower-right
    local e = c:ellipse(l[1], l[2], l[3] - 1, floor(l[3] * .8))
    local lit = e:copy():cut(e:shift(2, 2)):clip(m:shrink(1))
    local dk = e:copy():cut(e:shift(-2, -2)):clip(m:shrink(1))
    if l[1] - cx + l[2] - cy < 4 then c:fillMask(lit, T[4]) end
    if l[1] - cx + l[2] - cy > -4 then c:fillMask(dk, T[2]) end
  end
  return m
end

-- far tree on the right of the road (kite stuck in it)
shadowE(281, 112, 18, 3, .3)
local trunk = c:poly{ { 274, 112 }, { 277, 88 }, { 282, 88 }, { 286, 112 } }
shade(trunk, "#7b5a44", TX.bark)
canopy(279, 80, 22, 17, "#5f9a4e", 3)
-- kite quirk: diamond kite caught in the top of the tree, tail of bows
local kite = c:poly{ { 296, 56 }, { 304, 64 }, { 296, 76 }, { 288, 64 } }
shade(kite, "#e0574a", nil)
c:fillMask(c:poly{ { 296, 57 }, { 303, 64 }, { 296, 64 } }, "#f4c95a")
c:fillMask(c:poly{ { 289, 64 }, { 296, 64 }, { 296, 75 } }, "#f4c95a")
c:edgeIn(kite, "#7a2a2e")
for k = 0, 9 do c:put(296 + floor(sin(k / 2) * 2), 77 + k, "#5a4a5a") end
for _, b in ipairs{ { 297, 80 }, { 295, 84 } } do c:put(b[1] - 1, b[2], "#5d9ad8") c:put(b[1] + 1, b[2], "#5d9ad8") c:put(b[1], b[2], "#3e6fa8") end

-- cottage helper
local function cottage(x0, x1, yb, wh, rh, o)
  local cx = floor((x0 + x1) / 2)
  local wt = yb - wh
  shadowE(cx + 8, yb + 2, floor((x1 - x0) / 2) + 6, 4, .34)
  -- chimney behind roof
  local chx = o.chimL and x0 + 8 or x1 - 16
  local ch = c:rect(chx, wt - rh - 8, chx + 8, wt - 4)
  shade(ch, o.chim, TX.stone(5, 3))
  c:fillMask(c:rect(chx - 1, wt - rh - 10, chx + 9, wt - rh - 8), mix(o.chim, VIO, .3))
  local walls = c:rect(x0, wt, x1, yb)
  shade(walls, o.wall, o.wallTex)
  if o.timber then
    local tb = mix(o.wall, "#4a2e2a", .7)
    for _, xx in ipairs{ x0 + 1, x1 - 1, cx - 1 } do c:fillMask(c:rect(xx, wt, xx + 1, yb), tb) end
    c:fillMask(c:rect(x0, wt + 1, x1, wt + 2), tb)
    c:fillMask(c:line({ { x0 + 2, yb - 2 }, { cx - 2, wt + 4 } }, 2), tb)
  end
  -- roof
  local roof = c:poly{ { x0 - 3, wt + 2 }, { x0 + 9, wt - rh }, { x1 - 9, wt - rh }, { x1 + 3, wt + 2 } }
  shade(roof, o.roof, TX.shingle(6, 4))
  c:fillMask(c:rect(x0 + 9, wt - rh, x1 - 9, wt - rh + 1), mix(o.roof, VIO, .45)) -- ridge cap
  c:fillMask(c:rect(x0 - 2, wt + 3, x1 + 2, wt + 3), mix(o.wall, VIO, .5))         -- eave shadow
  -- door
  local dx = o.doorX
  local door = c:rrect(dx, yb - 19, dx + 11, yb + 4, 5):clip(c:rect(dx, yb - 19, dx + 11, yb))
  shade(door, o.door, TX.vplank(4))
  c:put(dx + 8, yb - 9, "#f2cf63") c:put(dx + 8, yb - 8, "#a7782e")
  local step = c:rect(dx - 2, yb + 1, dx + 13, yb + 2) shade(step, "#b6aca2", nil)
  -- windows (warm glow) with shutters + flower box
  for _, wx in ipairs(o.wins) do
    local wy = wt + 9
    local fr = c:rect(wx, wy, wx + 11, wy + 10)
    c:fillMask(fr, "#f0dfbc")
    local gl = c:rect(wx + 1, wy + 1, wx + 10, wy + 9)
    c:fillMask(gl, "#ffc85a")
    c:fillMask(c:rect(wx + 1, wy + 1, wx + 4, wy + 3), "#ffe7a0")
    c:fillMask(c:rect(wx + 7, wy + 6, wx + 10, wy + 9), "#f2a944")
    c:fillMask(c:rect(wx + 5, wy + 1, wx + 6, wy + 9), "#e9d3a8")
    c:fillMask(c:rect(wx + 1, wy + 5, wx + 10, wy + 5), "#e9d3a8")
    c:edgeIn(fr, mix(o.wall, "#2b1c26", .6))
    for _, sx in ipairs{ wx - 5, wx + 12 } do
      local sh = c:rect(sx, wy, sx + 4, wy + 10) shade(sh, o.shutter, TX.vplank(2))
    end
    local fb = c:rect(wx - 1, wy + 11, wx + 12, wy + 13) shade(fb, "#8a5a3a", nil)
    for k = 0, 5 do
      local fx = wx + k * 2 + 1
      c:put(fx, wy + 10, k % 2 == 0 and "#f07a9a" or "#f6d45a") c:put(fx, wy + 11 - 1 + 0, k % 2 == 0 and "#f07a9a" or "#f6d45a")
      c:put(fx + 1, wy + 10, "#5f9a4e")
    end
  end
  return wt
end

-- k=homes: two cottages
local wtA = cottage(22, 76, 130, 34, 22, { wall = "#ead7b0", wallTex = TX.plaster, timber = true, roof = "#c0583e",
  chim = "#a99a92", door = "#3f7fa8", shutter = "#5a8f6a", doorX = 46, wins = { 29 }, chimL = false })
-- house-icon plaque above A's door
local pq = c:rect(64, wtA + 8, 74, wtA + 17) shade(pq, "#8a5a3a", nil)
c:fillMask(c:poly{ { 65, wtA + 13 }, { 69, wtA + 9 }, { 73, wtA + 13 } }, "#f6e2b0")
c:fillMask(c:rect(67, wtA + 13, 71, wtA + 16), "#f6e2b0") c:put(69, wtA + 15, "#c0583e") c:put(69, wtA + 16, "#c0583e")
local wtB = cottage(96, 150, 126, 32, 20, { wall = "#b9bfcc", wallTex = TX.stone(7, 4), roof = "#3f8a86",
  chim = "#c08a6a", door = "#c4623a", shutter = "#d79a3a", doorX = 102, wins = { 125 }, chimL = true })
-- smoke from B's chimney
c:cloud(100, wtB - 28, 12, "#ecebf2", "#cfcfdf")
c:cloud(106, wtB - 38, 14, "#f1f0f4", "#d6d5e3")
c:cloud(114, wtB - 50, 12, "#f4f3f6", "#dcdbe8")

-- stone wall (between homes and do), boot planter quirk on it
local wall = c:poly{ { 16, 146 }, { 18, 142 }, { 152, 142 }, { 154, 146 }, { 154, 156 }, { 16, 156 } }
shadowE(88, 157, 72, 3, .3)
shade(wall, "#a8a29c", TX.stone(9, 5))
c:fillMask(c:rect(18, 142, 152, 142), "#cdc6bc")
for i = 0, 7 do -- moss tufts
  local mx = 22 + i * 17 + floor(hash(i, 1, 91) * 6)
  c:put(mx, 142, "#7fae5a") c:put(mx + 1, 142, "#93c062") c:put(mx + 1, 141, "#7fae5a")
end
-- boot planter
local boot = c:poly{ { 60, 134 }, { 67, 134 }, { 67, 140 }, { 73, 140 }, { 74, 142 }, { 60, 142 } }
shade(boot, "#8c5232", nil)
c:fillMask(c:rect(61, 135, 66, 135), "#d6a35a")
for _, f in ipairs{ { 61, 131, "#f07a9a" }, { 64, 129, "#f6d45a" }, { 66, 132, "#a07ad8" } } do
  c:put(f[1], f[2] + 1, "#5f9a4e") c:put(f[1], f[2] + 2, "#5f9a4e")
  c:put(f[1], f[2], f[3]) c:put(f[1] - 1, f[2], f[3]) c:put(f[1] + 1, f[2], f[3]) c:put(f[1], f[2] - 1, f[3])
end

-- k=stop: signpost at the crossroads
shadowE(194, 152, 14, 3, .34)
local stones = c:poly{ { 178, 152 }, { 181, 146 }, { 195, 146 }, { 198, 152 } }
shade(stones, "#a9a199", TX.stone(5, 3))
local post = c:rect(186, 94, 190, 149) shade(post, "#8a6040", TX.vplank(5))
local cap = c:poly{ { 184, 94 }, { 188, 89 }, { 192, 94 } } shade(cap, "#6d4a3a", nil)
local arms = {
  { pts = { { 166, 104 }, { 171, 98 }, { 186, 98 }, { 186, 110 }, { 171, 110 } }, col = "#c65a46", dir = -1, ix = 173, iy = 104 },
  { pts = { { 190, 112 }, { 207, 112 }, { 212, 118 }, { 207, 124 }, { 190, 124 } }, col = "#4a90a8", dir = 1, ix = 202, iy = 118 },
  { pts = { { 170, 128 }, { 174, 122 }, { 186, 122 }, { 186, 134 }, { 174, 134 } }, col = "#e0aa3e", dir = -1, ix = 177, iy = 128 },
}
for _, a in ipairs(arms) do
  local m = c:poly(a.pts) shade(m, a.col, TX.plank(4))
  local ic = mix(a.col, "#fff3d2", .75)
  for k = 0, 3 do c:put(a.ix + a.dir * k, a.iy - k, ic) c:put(a.ix + a.dir * k, a.iy + k, ic) end
  for k = 0, 6 do c:put(a.ix + a.dir * k, a.iy, ic) end
end
-- sock quirk hanging from the blue arm
c:fillMask(c:rect(200, 125, 200, 126), "#5a4a5a")
local sock = c:poly{ { 198, 127 }, { 202, 127 }, { 202, 135 }, { 205, 136 }, { 205, 139 }, { 198, 139 } }
shade(sock, "#e8584f", nil)
c:fillMask(c:rect(199, 130, 201, 130), "#fbe7c6") c:fillMask(c:rect(199, 133, 201, 133), "#fbe7c6")
-- giant spotted mushroom quirk at the post foot
local stalk = c:rect(170, 142, 174, 152) shade(stalk, "#efe1c4", nil)
local capM = c:ellipse(172, 141, 9, 6):clip(c:rect(162, 134, 182, 142))
shade(capM, "#d9483e", nil)
for _, s in ipairs{ { 168, 137 }, { 174, 136 }, { 177, 139 }, { 166, 140 } } do c:fillMask(c:rect(s[1], s[2], s[1] + 1, s[2] + 1), "#fbecd2") end

-- lantern post (decor) with birdhouse quirk
shadowE(305, 168, 11, 3, .34)
local lp = c:rect(297, 102, 300, 167) shade(lp, "#4c4a5e", nil)
c:fillMask(c:rect(295, 162, 302, 167), "#5d5a70") c:edgeIn(c:rect(295, 162, 302, 167), "#2f2c3c")
local arm = c:rect(297, 100, 310, 101) c:fillMask(arm, "#4c4a5e")
glow(306, 112, 14, 12, "#ffd77a", .25)
local lcap = c:poly{ { 301, 103 }, { 306, 99 }, { 311, 103 } } shade(lcap, "#3e3c50", nil)
local lglass = c:rect(302, 104, 310, 114)
c:fillMask(lglass, "#ffcf5a") c:fillMask(c:rect(303, 105, 305, 108), "#fff0b0")
c:edgeIn(lglass, "#2f2c3c") c:fillMask(c:rect(306, 104, 306, 114), "#2f2c3c")
c:fillMask(c:rect(303, 115, 309, 116), "#3e3c50")
local bh = c:rect(285, 126, 296, 138) shade(bh, "#5fa0c8", TX.vplank(4))
local bhr = c:poly{ { 283, 127 }, { 290, 120 }, { 298, 127 } } shade(bhr, "#d45a4a", nil)
c:fillMask(c:rect(289, 130, 291, 132), "#2f2a3a") c:put(290, 135, "#7a5a3a") c:put(289, 135, "#7a5a3a")

-- k=people: noticeboard + bench
shadowE(346, 150, 32, 4, .34)
for _, px in ipairs{ 318, 358 } do local p = c:rect(px, 96, px + 4, 149) shade(p, "#7d5a3e", TX.vplank(5)) end
local brd = c:rect(320, 102, 360, 134) shade(brd, "#c1925e", function(x, y) return (hash(x, y, 101) > .8 and -0.08 or 0) end)
c:edgeIn(c:rect(320, 102, 360, 134), "#6a4a32")
local papers = { { 324, 106, 336, 120, "#f6ecd6" }, { 339, 105, 356, 116, "#bfe0ee" }, { 340, 119, 354, 131, "#f6c4cc" }, { 325, 123, 336, 131, "#f7e08a" } }
for i, p in ipairs(papers) do
  local m = c:rect(p[1], p[2], p[3], p[4])
  c:fillMask(m:copy():shift(1, 1):cut(m), "#7a5236")
  shade(m, p[5], nil, { bias = .05 })
  for ly = p[2] + 3, p[4] - 2, 2 do
    for lx = p[1] + 2, p[3] - 2 do if hash(lx, ly, 110 + i) > .3 and (lx - p[1]) % 5 ~= 4 then c:put(lx, ly, mix(p[5], "#4a3a52", .45)) end end
  end
  c:put(floor((p[1] + p[3]) / 2), p[2] + 1, "#d8443c")
end
local nroof = c:poly{ { 312, 100 }, { 320, 90 }, { 360, 90 }, { 368, 100 } } shade(nroof, "#b8543e", TX.shingle(6, 3))
-- heart plaque on the roof
local hp = c:rect(333, 78, 347, 89) shade(hp, "#f2e2c0", nil)
c:fillMask(c:rect(340, 76, 340, 77), "#5a4a5a")
c:paint({ ".xx.xx.", "xxxxxxx", "xxxxxxx", ".xxxxx.", "..xxx..", "...x..." }, 337, 80, { x = "#e0485a" })
c:put(338, 81, "#f79aa6")
-- bench
shadowE(390, 149, 22, 3, .34)
for _, lx in ipairs{ 372, 404 } do local l = c:rect(lx, 128, lx + 2, 148) shade(l, "#3f5f4a", nil) end
for i, sy in ipairs{ 116, 122 } do local s = c:rect(368, sy, 408, sy + 3) shade(s, "#5aa46e", TX.vplank(8)) end
local seat = c:rect(366, 134, 410, 137) shade(seat, "#5aa46e", TX.vplank(8))
c:fillMask(c:rect(366, 138, 410, 138), "#2f5040")
-- knitted scarf left on the bench
local scarf = c:poly{ { 384, 128 }, { 392, 128 }, { 391, 137 }, { 389, 146 }, { 385, 146 }, { 386, 137 } }
shade(scarf, "#e8a23a", function(x, y) return (y % 3 == 0) and -0.14 or 0 end)

-- k=wild: branch arch + gap into the wild woods + signpost
local wood = c:poly{ { 430, 126 }, { 466, 112 }, { 466, 168 }, { 430, 176 } }
c:fillMask(wood, "#2f4f3c")
for i = 0, 6 do -- pine silhouettes in the gap
  local px = 432 + i * 6 local pt = 128 + floor(hash(i, 1, 121) * 10)
  local pm = c:poly{ { px - 4, 172 }, { px, pt }, { px + 4, 172 } }:clip(wood)
  c:fillMask(pm, i % 2 == 0 and "#3d6a4a" or "#467856")
  c:fillMask(c:line({ { px, pt + 1 }, { px - 3, 170 } }, 1):clip(pm), "#5a8c5e")
end
local branch = c:line({ { 424, 214 }, { 423, 186 }, { 424, 160 }, { 428, 142 }, { 436, 130 }, { 448, 122 }, { 466, 118 } }, 7)
shade(branch, "#7a5a44", TX.bark)
local twig = c:line({ { 428, 168 }, { 418, 152 } }, 3) shade(twig, "#7a5a44", nil)
canopy(432, 128, 10, 9, "#4f8f4a", 5)
canopy(452, 116, 12, 8, "#5a9a52", 6)
canopy(418, 150, 7, 6, "#4f8f4a", 7)
-- trail signpost with leaf icon pointing right
shadowE(444, 222, 12, 3, .34)
local wp = c:rect(436, 196, 439, 221) shade(wp, "#7a5a44", nil)
local wb = c:poly{ { 428, 194 }, { 452, 194 }, { 459, 200 }, { 452, 206 }, { 428, 206 } } shade(wb, "#6aa84f", TX.plank(4))
c:paint({ "..xx", ".xxx", "xxyx", "xyx.", "y..." }, 444, 197, { x = "#f4f0c8", y = "#3f6e3a" })
local bush = c:ellipse(418, 214, 8, 7) shade(bush, "#4f9a4f", TX.leaf(8))

-- k=do: log bench + fire pit with kettle tripod
shadowE(60, 226, 36, 4, .34)
for _, sx in ipairs{ 28, 70 } do local s = c:rect(sx, 210, sx + 10, 225) shade(s, "#8c6444", TX.bark) c:fillMask(c:rect(sx + 1, 210, sx + 9, 210), "#d6b07c") end
local log = c:rrect(20, 200, 88, 209, 3) shade(log, "#9a6a46", TX.plank(3))
c:fillMask(c:rect(21, 200, 87, 200), "#d6b07c")
local logEnd = c:ellipse(86, 205, 3, 4) shade(logEnd, "#e2c08a", function(x, y) return ((x + y) % 3 == 0) and -0.12 or 0 end)
-- picnic blanket draped + mug
local blanket = c:poly{ { 30, 198 }, { 50, 198 }, { 52, 214 }, { 46, 212 }, { 40, 215 }, { 34, 212 }, { 29, 214 } }
shade(blanket, "#d9524a", function(x, y) return (((x // 3) + (y // 3)) % 2 == 0) and 0.12 or 0 end)
local mug = c:rect(62, 193, 67, 199) shade(mug, "#6aa0d8", nil) c:fillMask(c:rect(68, 195, 69, 197), "#4a7ab0")
-- fire pit
shadowE(128, 233, 30, 4, .3)
local ring = c:rrect(96, 212, 150, 233, 8)
local inner = c:rrect(102, 216, 144, 229, 5)
c:fillMask(inner, "#4a3a42")
for i = 0, 14 do c:put(104 + floor(hash(i, 1, 131) * 38), 218 + floor(hash(i, 2, 132) * 10), "#ff8a3a") end
local ringM = ring:copy():cut(inner)
local stoneCols = { "#a8a29c", "#9c948e", "#b3aba2", "#968f9a" }
for k = 0, 8 do
  local seg = ringM:copy():clip(c:rect(96 + k * 6, 210, 96 + k * 6 + 5, 234))
  if seg:count() > 0 then shade(seg, stoneCols[1 + k % 4], nil) end
end
local l1 = c:line({ { 108, 227 }, { 138, 216 } }, 4) shade(l1, "#7a4e34", nil)
local l2 = c:line({ { 108, 216 }, { 138, 227 } }, 4) shade(l2, "#8c5a3c", nil)
glow(123, 196, 26, 26, "#ffcf6a", .18)
local fl = c:poly{ { 109, 224 }, { 112, 206 }, { 117, 212 }, { 120, 196 }, { 125, 210 }, { 129, 192 }, { 133, 208 }, { 137, 202 }, { 139, 224 } }
c:fillMask(fl, "#f0682e") c:edgeIn(fl, "#b8402a")
local fl2 = c:poly{ { 114, 224 }, { 118, 210 }, { 122, 216 }, { 128, 200 }, { 131, 214 }, { 135, 224 } } c:fillMask(fl2, "#f8a63a")
local fl3 = c:poly{ { 118, 224 }, { 123, 214 }, { 128, 210 }, { 131, 224 } } c:fillMask(fl3, "#ffe08a")
for _, s in ipairs{ { 116, 190 }, { 133, 186 }, { 124, 182 } } do c:put(s[1], s[2], "#ffd45a") end
-- tripod + kettle
local tri = c:line({ { 102, 230 }, { 123, 166 } }, 2):add(c:line({ { 145, 230 }, { 123, 166 } }, 2))
shade(tri, "#5a4436", nil)
c:fillMask(c:rect(123, 168, 123, 177), "#4a4458")
local kt = c:rrect(116, 178, 131, 190, 4) shade(kt, "#3f6f7a", nil)
c:fillMask(c:line({ { 131, 182 }, { 136, 178 } }, 2), "#3f6f7a")
c:fillMask(c:rect(121, 176, 126, 177), "#2f5560")
-- front stones of the ring redrawn over the logs/flames
local front = ringM:copy():clip(c:rect(96, 226, 150, 234))
for k = 0, 8 do
  local seg = front:copy():clip(c:rect(96 + k * 6, 226, 96 + k * 6 + 5, 234))
  if seg:count() > 0 then shade(seg, stoneCols[1 + (k + 1) % 4], nil, { bias = .06 }) end
end

---------------------------------------------------------------- v2.5.40 polish pass 2: material cues
do
  local MOSS, MOSS2 = "#6f9a52", "#8cb862"
  -- thatch/shingle moss on the north (upper-left) roof edges, plaster cracks, stone chips + lichen
  for _, r in ipairs{ { 22, 74, 3 }, { 96, 74, 3 } } do
    for k = 0, 9 do
      local x, y = r[1] + 4 + floor(hash(k, r[1], 301) * 12), r[2] + 3 + floor(hash(k, r[1], 302) * 14)
      c:put(x, y, MOSS) c:put(x + 1, y, MOSS2) c:put(x, y + 1, mix(MOSS, VIO, .35))
    end
  end
  for _, p in ipairs{ { 30, 108, 33, 114 }, { 58, 100, 56, 106 }, { 70, 118, 68, 124 } } do c:put(p[1], p[2], "#8a6a58") c:put(p[3], p[2] + 3, "#8a6a58") c:put(p[3] + 1, p[4], "#8a6a58") end
  for _, p in ipairs{ { 102, 100 }, { 112, 112 }, { 130, 104 }, { 140, 116 }, { 119, 120 } } do
    c:put(p[1], p[2], "#8a90a2") c:put(p[1] + 1, p[2], "#d6dae6") c:put(p[1] + 1, p[2] + 1, "#6a6e82")
  end
  for k = 0, 7 do c:put(97 + floor(hash(k, 1, 303) * 6), 100 + floor(hash(k, 2, 304) * 22), k % 2 == 0 and "#9cb478" or "#b8c48a") end -- lichen on north corner
  -- garden wall: chips, lichen, mortar cracks
  for k = 0, 11 do
    local x, y = 20 + floor(hash(k, 1, 305) * 130), 144 + floor(hash(k, 2, 306) * 11)
    c:put(x, y, "#7a746e") c:put(x + 1, y, "#d6cfc4") c:put(x + 1, y + 1, "#6a646a")
  end
  for k = 0, 8 do c:put(18 + k * 3, 143 + (k % 2), k % 3 == 0 and "#9cb478" or "#8aa86a") end
  -- signpost grain, nails, rope, rust
  for k = 0, 8 do c:put(187 + (k % 2) * 2, 98 + k * 6, "#6a4630") c:put(188, 101 + k * 6, "#a77a54") end
  c:fillMask(c:rect(186, 137, 190, 138), "#d2b27c") c:put(187, 139, "#b8975a") c:put(189, 140, "#b8975a")  -- rope twist lashing
  for _, a in ipairs{ { 168, 103 }, { 183, 103 }, { 192, 114 }, { 205, 117 }, { 173, 127 }, { 183, 127 } } do c:put(a[1], a[2], "#cdd0dc") c:put(a[1], a[2] + 1, "#6a5a6a") end
  for k = 0, 4 do c:put(171 + k * 3, 99 + (k % 2), "#8a3a2e") c:put(193 + k * 3, 113, "#2e6a82") end
  c:put(188, 91, "#d6c2a0") c:put(186, 93, "#4e3226")
  -- noticeboard: frame grain, pin heads, wood knots, rust nails on posts
  for k = 0, 9 do c:put(322 + k * 4, 103, "#8a6a42") c:put(323 + k * 4, 133, "#7a5a36") end
  for _, p in ipairs{ { 320, 110 }, { 360, 124 }, { 320, 126 }, { 360, 108 } } do c:put(p[1], p[2], "#a8a6b8") c:put(p[1], p[2] + 1, "#5a4a5a") end
  for _, px in ipairs{ 318, 358 } do c:put(px + 1, 120, "#4e3226") c:put(px + 2, 120, "#4e3226") c:put(px + 1, 121, "#b88e62") c:put(px + 3, 140, "#4e3226") c:put(px + 1, 108, "#d6b07c") end
  for k = 0, 8 do c:put(314 + k * 6, 94 + (k % 2), "#6a2e2e") end
  for k = 0, 4 do c:put(324 + k * 8, 91, "#d6805a") end
  -- bench: wood grain streaks and bolts
  for _, sy in ipairs{ 117, 123, 135 } do for k = 0, 6 do c:put(371 + k * 6 + (sy % 3), sy + 1, "#3f7a50") end end
  for _, bx in ipairs{ 372, 404 } do c:put(bx + 1, 135, "#cdd0dc") c:put(bx + 1, 136, "#4a4a5a") c:put(bx + 1, 140, "#7a5a3a") end
  -- fire pit stones: chips, soot above the flame, lichen; kettle bevel; blanket folds
  for _, p in ipairs{ { 100, 220 }, { 98, 226 }, { 146, 216 }, { 148, 224 }, { 120, 214 }, { 110, 231 }, { 136, 232 } } do c:put(p[1], p[2], "#6a6470") c:put(p[1] + 1, p[2], "#cfc9bd") end
  for k = 0, 5 do c:put(100 + k * 8, 213 + (k % 2), k % 2 == 0 and "#8aa86a" or "#9cb478") end
  c:fillMask(c:rect(118, 179, 119, 187), "#7aaab4") c:put(117, 180, "#cfeaee") c:fillMask(c:rect(129, 186, 130, 189), "#2f5560")
  c:put(124, 175, "#dfeaf0") c:put(124, 172, "#e6edf2") c:put(126, 169, "#e6edf2") c:put(122, 166, "#e6edf2") -- kettle steam
  for _, p in ipairs{ { 106, 217 }, { 107, 213 }, { 109, 208 }, { 141, 215 }, { 143, 220 } } do c:put(p[1], p[2], "#9a5a34") c:put(p[1] + 1, p[2], "#6a4228") end -- rust on the tripod legs
  for k = 0, 10 do c:put(31 + k, 205, "#7a4e34") end
  c:put(125, 168, "#d6b07c") c:put(124, 171, "#2e2a3a")
  for k = 0, 5 do c:put(34 + k * 3, 199 + k * 2, "#a8362e") c:put(44 - k, 200 + k * 2, "#a8362e") end -- cloth fold creases
  c:fillMask(c:line({ { 30, 211 }, { 50, 211 } }, 1), "#b8362e")
  -- logs: growth rings on the stumps, bark cracks
  for _, sx in ipairs{ 28, 70 } do for k = 0, 3 do c:put(sx + 3 + k, 211, "#b8905c") c:put(sx + 2 + k, 214 + (k % 2), "#6a4a30") c:put(sx + 7, 216 + k, "#6a4a30") end end
  c:put(86, 205, "#c49a64") c:put(85, 204, "#8a6040") c:put(86, 206, "#8a6040")
  -- wild branch: lichen on the north side, knots; trail sign grain; mug glint
  for k = 0, 9 do c:put(421 + (k % 2), 152 + k * 5, k % 3 == 0 and "#aac27a" or "#8ca868") end
  c:put(425, 175, "#3e2a22") c:put(426, 175, "#3e2a22") c:put(424, 196, "#3e2a22")
  for k = 0, 4 do c:put(430 + k * 5, 197 + (k % 2) * 3, "#4e8a3c") c:put(431 + k * 5, 203, "#c8e08a") end
  c:put(437, 205, "#c4c8d6") c:put(437, 206, "#4a4a5a") c:put(438, 215, "#4e3a2e")
  c:put(63, 194, "#d6ecf6") c:put(64, 194, "#d6ecf6")
end

---------------------------------------------------------------- v2.5.40 polish pass 3: lived-in props
do
  local function gshadow(cx, cy, rx, ry, t) gmask(c:ellipse(cx, cy, rx, ry), "#41365f", t or .32) end
  -- barrels by the signpost side (hooped, one with a ladle)
  local function barrel(x0, y0, x1, y1, col)
    gshadow((x0 + x1) // 2 + 3, y1 + 1, (x1 - x0) // 2 + 3, 2, .34)
    local b = c:rrect(x0, y0, x1, y1, 3) shade(b, col, TX.vplank(3))
    for _, hy in ipairs{ y0 + 3, y1 - 3 } do c:fillMask(c:rect(x0, hy, x1, hy + 1), "#4c4a5e") c:put(x0 + 1, hy, "#9c98b0") end
    c:fillMask(c:ellipse((x0 + x1) // 2, y0 + 1, (x1 - x0) // 2 - 1, 1), mix(col, WARM2, .45))
    c:put(x0 + 2, y0 + 6, "#e8d0a0") c:put(x0 + 2, y0 + 7, "#e8d0a0")
  end
  barrel(166, 168, 178, 184, "#8c5a38")
  barrel(181, 172, 193, 187, "#a06a40")
  c:fillMask(c:line({ { 188, 172 }, { 192, 163 } }, 1), "#5a4436") c:fillMask(c:rect(191, 161, 194, 163), "#7a7488") -- ladle
  -- hay bales stacked at the trail side, twine bands
  local function bale(x0, y0, x1, y1)
    gshadow(x1 - 4, y1 + 1, (x1 - x0) // 2 + 4, 2, .34)
    local m = c:rrect(x0, y0, x1, y1, 2)
    shade(m, "#d8b45a", function(x, y) return (hash(x, floor(y / 2), 311) > .62 and -0.1 or 0) + (y % 3 == 0 and 0.05 or 0) end)
    for _, bx in ipairs{ x0 + 5, x1 - 5 } do c:fillMask(c:rect(bx, y0, bx, y1), "#7a5a30") end
    for k = 0, 3 do c:put(x0 + 2 + k * 5, y0 - 1, "#e8c870") c:put(x1 - k * 4, y1 + 1, "#b89040") end
  end
  bale(372, 214, 394, 226)
  bale(376, 203, 392, 213)
  c:put(398, 224, "#e8c870") c:put(399, 225, "#d8b45a") c:put(397, 226, "#b89040") c:put(370, 222, "#e8c870")
  -- hand cart (two spoked wheels, hay load, shafts)
  gshadow(352, 264, 24, 3, .34)
  c:fillMask(c:line({ { 336, 252 }, { 322, 262 } }, 2), "#6a4a34")
  c:fillMask(c:line({ { 336, 256 }, { 322, 264 } }, 1), "#4e3226")
  local bedm = c:poly{ { 336, 242 }, { 366, 242 }, { 364, 255 }, { 338, 255 } }
  shade(bedm, "#a06a40", TX.plank(4))
  c:fillMask(c:rect(336, 242, 366, 242), "#d6b07c")
  local load = c:poly{ { 338, 242 }, { 342, 232 }, { 350, 228 }, { 358, 232 }, { 364, 242 } }
  shade(load, "#d8b45a", function(x, y) return (hash(x, floor(y / 2), 313) > .6 and -0.1 or 0) end)
  c:put(346, 231, "#e8c870") c:put(354, 230, "#e8c870") c:put(352, 227, "#e8c870") c:put(344, 229, "#c89a44")
  local sack = c:poly{ { 355, 236 }, { 362, 236 }, { 363, 243 }, { 354, 243 } } shade(sack, "#c4a888", nil)
  c:fillMask(c:rect(356, 236, 361, 236), "#7a5a40")
  local wheel = c:ellipse(346, 258, 8, 8)
  local rim = wheel:copy():cut(wheel:shrink(2)) shade(rim, "#7a5236", nil)
  for _, d in ipairs{ { 0, -6 }, { 0, 6 }, { -6, 0 }, { 6, 0 }, { 4, 4 }, { -4, -4 }, { 4, -4 }, { -4, 4 } } do c:put(346 + d[1] // 2, 258 + d[2] // 2, "#a77a54") c:put(346 + d[1] * 2 // 3, 258 + d[2] * 2 // 3, "#a77a54") end
  c:fillMask(c:ellipse(346, 258, 1, 1), "#cdd0dc")
  c:fillMask(c:ellipse(361, 259, 5, 5):cut(c:ellipse(361, 259, 3, 3)), "#5a4030")
  c:put(361, 259, "#cdd0dc")
  -- washing line between the cottages with three cloths
  c:fillMask(c:line({ { 77, 105 }, { 86, 108 }, { 96, 105 } }, 1), "#5a4a5a")
  for _, k in ipairs{ { 80, "#f4ecd8", 7 }, { 86, "#6aa0d8", 8 }, { 91, "#e8a23a", 6 } } do
    local cm = c:rect(k[1], 106 + (k[1] == 86 and 3 or 0), k[1] + 3, 106 + k[3] + (k[1] == 86 and 3 or 0)) shade(cm, k[2], function(x, y) return (x % 2 == 0) and -0.07 or 0 end)
    c:put(k[1] + 1, 106 + (k[1] == 86 and 3 or 0) - 1, "#d6a35a")
  end
  -- firewood pile against the garden wall
  gshadow(30, 173, 16, 2, .32)
  for row = 0, 2 do for k = 0, 3 - (row == 2 and 1 or 0) do
    local lx, ly = 16 + k * 5 + (row % 2) * 2 + (row == 2 and 3 or 0), 169 - row * 4
    local lg = c:ellipse(lx + 2, ly, 2, 2)
    shade(lg, "#9a6a46", nil)
    c:put(lx + 2, ly, "#e2c08a") c:put(lx + 1, ly - 1, "#c49a64")
  end end
  -- layered flame tongues with hot cores, embers and sparks
  local fl0 = c:poly{ { 109, 224 }, { 112, 206 }, { 117, 212 }, { 120, 196 }, { 125, 210 }, { 129, 192 }, { 133, 208 }, { 137, 202 }, { 139, 224 } }
  local core = fl0:copy():shrink(3)
  c:fillMask(core, "#f8a63a")
  c:fillMask(core:copy():shrink(2), "#ffd86a")
  c:fillMask(core:copy():shrink(4), "#fff0b0")
  for _, t in ipairs{ { 120, 197, 3 }, { 129, 193, 4 }, { 137, 203, 2 }, { 113, 207, 2 } } do
    for k = 0, t[3] do c:put(t[1] + (k % 2), t[2] + k, k < 2 and "#ffd86a" or "#f8a63a") end
  end
  for _, p in ipairs{ { 106, 221 }, { 142, 222 }, { 112, 228 }, { 134, 229 }, { 125, 231 } } do c:put(p[1], p[2], "#ff9a46") c:put(p[1] + 1, p[2], "#c8482a") end
  for _, p in ipairs{ { 114, 188 }, { 135, 190 }, { 127, 180 }, { 119, 183 } } do c:put(p[1], p[2], "#ffe08a") c:put(p[1] + 1, p[2] + 1, "#f8a63a") end
  glow(123, 214, 34, 12, "#ffcf6a", .12)
end

---------------------------------------------------------------- v2.5.40 polish pass 4b: rim light, warm spill, plant kinds, foreground frame
do
  local RIM = "#fff0c8"
  local function rim(x, y0, y1, t) for y = y0, y1 do gmix(x, y, RIM, t or .32) end end
  rim(186, 95, 148) rim(297, 103, 166) rim(318, 97, 148) rim(358, 97, 148) rim(320, 103, 133, .24)
  rim(22, 99, 128, .22) rim(96, 96, 124, .22) rim(166, 168, 184, .3) rim(181, 172, 186, .3) rim(336, 243, 254, .28)
  rim(372, 129, 146, .3) rim(424, 160, 210, .22) rim(436, 197, 220, .26) rim(20, 201, 208, .3) rim(28, 211, 225, .26)
  for x = 22, 76 do gmix(x, 98 + floor(max(0, 22 - (x - 22)) * 0 + 0), RIM, 0) end
  for x = 30, 88, 1 do gmix(x, 200, RIM, .2) end -- sunlit log top
  grect(76, 200, 87, 209, "#ffb550", .2)  -- fire spill on the log's right end
  grect(130, 214, 148, 232, "#ffb550", .1)
  gmask(c:rect(146, 213, 150, 232), "#ffb550", .16)
  -- sunflowers
  local function sunflower(x, y, h)
    for k = 0, h do gput(x, y - k, "#4c8a3c") gput(x + 1, y - k, "#3f7a38") end
    gput(x - 2, y - 3, "#5a9a46") gput(x - 3, y - 4, "#5a9a46") gput(x + 3, y - 2, "#5a9a46") gput(x + 4, y - 3, "#5a9a46")
    local hy = y - h - 1
    for _, d in ipairs{ { -3, 0 }, { 3, 0 }, { 0, -3 }, { 0, 3 }, { -2, -2 }, { 2, -2 }, { -2, 2 }, { 2, 2 } } do gput(x + d[1], hy + d[2], "#f6d45a") gput(x + d[1] // 2, hy + d[2] // 2, "#f2b43a") end
    grect(x - 1, hy - 1, x + 1, hy + 1, "#6a4228") gput(x, hy, "#4e3226") gput(x - 1, hy - 1, "#8a5a38")
  end
  sunflower(40, 266, 14) sunflower(52, 262, 10) sunflower(30, 262, 8)
  -- ferns
  local function fern(x, y, n)
    for i = 0, n do
      local a = -1.2 + i / n * 2.4
      for k = 1, 9 do
        local px, py = x + floor(sin(a) * k * 1.1), y - floor(cos(a) * k * .9)
        gput(px, py, k % 2 == 0 and "#3f8a48" or "#5aa655")
        if k > 2 and k % 2 == 1 then gput(px - 1, py + 1, "#2f6a3c") gput(px + 1, py, "#74c068") end
      end
    end
  end
  fern(18, 268, 4) fern(66, 268, 4) fern(150, 262, 3) fern(318, 268, 3) fern(112, 264, 3)
  -- lavender spikes along the garden wall foot
  for i = 0, 10 do
    local x = 22 + i * 12 + floor(hash(i, 1, 411) * 5)
    for k = 0, 5 do gput(x, 160 - k, k > 2 and "#9a78d0" or "#5a9a46") if k > 1 then gput(x + 1, 160 - k, "#b89ae0") end end
    gput(x - 1, 161, "#5a9a46") gput(x + 1, 161, "#5a9a46")
  end
  -- hollyhocks by the cottage B wall, cattail tufts in the wet spot by the road
  for i = 0, 3 do local x = 153 + (i % 2) * 3 for k = 0, 14 do gput(x, 128 - k, "#4c8a3c") if k > 5 and k % 2 == 0 then gput(x - 1, 128 - k, i % 2 == 0 and "#f07a9a" or "#e8d0f0") gput(x + 1, 128 - k + 1, "#f6b0c4") end end end
  for i = 0, 5 do local x, y = 306 + i * 3, 232 for k = 0, 9 do gput(x, y - k, "#6a8a3c") end gput(x, y - 7, "#7a4a32") gput(x, y - 8, "#7a4a32") gput(x + 1, y - 4, "#8aa84a") end
  -- berry bush at the wall end
  local bb = c:ellipse(146, 166, 7, 5) shade(bb, "#4f8a52", TX.leaf(14))
  for _, p in ipairs{ { 142, 164 }, { 147, 162 }, { 150, 167 }, { 144, 169 } } do c:put(p[1], p[2], "#d8384a") c:put(p[1], p[2] - 1, "#f08a96") end
  -- foreground grass frame along the bottom (does not touch the spots)
  for i = 0, 340 do
    local x = 14 + floor(hash(i, 1, 421) * 452)
    local y = 268 - floor(hash(i, 2, 422) * 4)
    local h = 4 + floor(hash(i, 3, 423) * 8)
    local lean = floor((hash(i, 4, 424) - .5) * 4)
    for k = 0, h do
      local px, py = x + floor(lean * k / h), y - k
      gput(px, py, k > h * .6 and "#8cc65a" or k > h * .3 and "#4c8a3c" or "#2f6a3a")
    end
  end
end

---------------------------------------------------------------- the gate frame: posts, beam, leaves, lanterns, teacup charm
local postL = c:rect(0, 0, 13, H - 1) shade(postL, "#8a6444", TX.vplank(7))
local postR = c:rect(466, 0, 479, H - 1) shade(postR, "#8a6444", TX.vplank(7))
for _, px in ipairs{ 0, 466 } do -- iron bands
  for _, by in ipairs{ 60, 160, 240 } do c:fillMask(c:rect(px, by, px + 13, by + 2), "#4c4a5e") c:put(px + 3, by + 1, "#9c98b0") c:put(px + 10, by + 1, "#9c98b0") end
end
local beam = c:rect(0, 0, W - 1, 11) shade(beam, "#8a6444", TX.plank(6))
-- leafy garland along the beam
for i = 0, 22 do
  local gx = 4 + i * 21 + floor(hash(i, 1, 141) * 8)
  local gy = 10 + floor(hash(i, 2, 142) * 6)
  if gx < 470 and not (gx > 200 and gx < 280) then
    local m = c:ellipse(gx, gy, 6 + floor(hash(i, 3, 143) * 3), 4)
    shade(m, i % 3 == 0 and "#6aa84f" or "#5a9a4a", TX.leaf(i))
    if i % 4 == 1 then c:fillMask(c:rect(gx, gy - 1, gx + 1, gy), "#f07a9a") end
  end
end
-- hanging lanterns
for _, lx in ipairs{ 34, 446 } do
  c:fillMask(c:rect(lx, 12, lx, 21), "#4c4a5e")
  glow(lx, 31, 13, 13, "#ffd77a", .22)
  local lc = c:poly{ { lx - 6, 25 }, { lx, 20 }, { lx + 6, 25 } } shade(lc, "#3e3c50", nil)
  local g = c:rect(lx - 5, 26, lx + 5, 37)
  c:fillMask(g, "#ffcf5a") c:fillMask(c:rect(lx - 4, 27, lx - 2, 30), "#fff0b0")
  c:edgeIn(g, "#2f2c3c") c:fillMask(c:rect(lx, 26, lx, 37), "#2f2c3c")
  c:fillMask(c:rect(lx - 3, 38, lx + 3, 39), "#3e3c50")
end
-- teacup charm on a string
c:fillMask(c:rect(178, 12, 178, 24), "#5a4a5a")
local cup = c:poly{ { 171, 25 }, { 185, 25 }, { 183, 33 }, { 173, 33 } } shade(cup, "#f2e6d8", nil)
c:fillMask(c:rect(173, 27, 183, 27), "#7ab0d8") c:put(176, 30, "#e0748a") c:put(180, 30, "#e0748a")
local hd = c:rect(186, 27, 188, 30):cut(c:rect(187, 28, 187, 29)) c:fillMask(hd, "#c9b8b0")
local sau = c:rect(169, 34, 187, 35) shade(sau, "#d8c8e0", nil)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

---------------------------------------------------------------- layout
local spots = {
  { "do", "Fire pit", 14, 160, 156, 238 },
  { "people", "Noticeboard", 312, 74, 412, 152 },
  { "stop", "Signpost", 160, 86, 214, 156 },
  { "homes", "Cottages", 16, 46, 156, 134 },
  { "wild", "Wild Trail", 410, 108, 466, 226 },
}
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], (s[3] + s[5]) // 2, (s[4] + s[6]) // 2, s[3], s[4], s[5], s[6])
end
local stand = { { 196, 248 }, { 284, 248 }, { 240, 214 }, { 212, 180 }, { 268, 184 }, { 350, 206 } }
local sp = {}
for _, p in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":' .. HZ .. ',"view":"gate","spots":[' .. table.concat(parts, ",") .. '],"stand":[' .. table.concat(sp, ",") .. '],"compass_clear":[380,230,480,270]}\n')
f:close()
