-- Gnome Venture "Hearth Pop" v3 -- here-stop-orchard-desert_adobe: DESERT ADOBE look of the orchard rest stop, GATE VIEW, hero scale, 480x270.
-- Geometry, layout spots, stand points and compass corner identical to here-stop-orchard (same layout json);
-- only colours/ramps, sky, hills, flora, roof/wall style and quirk props differ (citrus+pomegranate grove, adobe, palms).
local SRC = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(SRC .. "lib/hp.lua")
local OUT = (app.params and app.params.out) or (SRC .. "here-gate/places/")
local NAME = "here-stop-orchard-desert_adobe"
local W, Hh, VX, VY = 480, 270, 240, 112
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, max, min, abs, sin, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.sqrt

local function H(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 1) * 37.719) * 43758.5453 return n - floor(n) end
local function put(x, y, hex) if x >= 0 and y >= 0 and x < W and y < Hh then c:put(x, y, hex) end end
local function rect(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function poly(p) return c:poly(p) end
local function ell(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end

-- ramps: {edge, deep, shade, base, hi}
local R = {
  wood    = {"#3e2420", "#6a3e2c", "#8c5a3c", "#a8744c", "#c8955e"},
  pale    = {"#5a3a26", "#8a6040", "#b48a5a", "#d4aa72", "#ecca92"},
  thatch  = {"#5e3c1c", "#9a6a2c", "#c4903a", "#deb058", "#f4d27c"},
  plaster = {"#5c3430", "#a86a54", "#c88a68", "#deaa80", "#f0c89a"},   -- adobe render
  brick   = {"#4e2626", "#8e4a3a", "#b0644a", "#c87e5a", "#dc9c70"},   -- mud brick
  roof    = {"#4a1c22", "#8a3a2e", "#b4553a", "#d2744a", "#ec9a66"},   -- terracotta
  stone   = {"#5c3c3c", "#8c6050", "#b98762", "#dcae80", "#f4d8b0"},   -- sandstone
  metal   = {"#3a3a4a", "#5a5a6e", "#8a8a9c", "#b4b4c2", "#dcdce4"},
  blossom = {"#4a1a40", "#aa387e", "#d6509c", "#f48cc4", "#fcc8e2"},   -- bougainvillea
  leaf    = {"#203e36", "#36624e", "#4e8662", "#6caa7a", "#acd49e"},   -- dusty citrus green
  dleaf   = {"#263e28", "#406438", "#5e8a40", "#84ae4a", "#c0d878"},   -- palm green
  apple   = {"#4e1424", "#8e2230", "#c03634", "#e4564a", "#ff9a7e"},   -- pomegranate
  green   = {"#163e48", "#23646a", "#2e8a88", "#3eb4a8", "#8ae0d4"},   -- turquoise
  blue    = {"#1c3054", "#2c4c80", "#3a6aa8", "#4f8fd0", "#8ec4ee"},
  gold    = {"#5a2e0e", "#a0501a", "#d8742a", "#f49a3a", "#fcc870"},   -- orange fruit / brass
  glow    = {"#7a3e18", "#cc7a2c", "#f2a844", "#ffd274", "#fff0b0"},
  cork    = {"#5a3a22", "#8e6038", "#b0804c", "#c89c62", "#dcb87c"},
  cloth   = {"#4e1a26", "#963036", "#c4463e", "#e06654", "#f29480"},
  cream   = {"#6a5a50", "#c4b49a", "#e0d2b4", "#f2e6c8", "#fcf4de"},
  barrel  = {"#3e2418", "#704028", "#965834", "#b87444", "#d8985c"},
  wicker  = {"#5a3a1a", "#8e6230", "#b48644", "#d0a45a", "#e8c47a"},
  kite    = {"#2a3a5c", "#3e6aa8", "#e0a030", "#f4c84a", "#fde888"},
}

---------------------------------------------------------------- painter
local function bbox(m) return m:bbox() end
local function obj(m, Rp, o)
  o = o or {}
  local x0, y0, x1, y1 = bbox(m)
  if not x0 then return m end
  if o.rim ~= false then c:rim(m, o.rimc or Rp[1], o.clip) end
  local lx, ly = o.lx or 0.38, o.ly or 0.26
  m:each(function(x, y)
    local fx = (x - x0) / max(1, x1 - x0)
    local fy = (y - y0) / max(1, y1 - y0)
    local v = 0.66 - lx * fx - ly * fy + (o.lift or 0)
    v = v + (H(x, y, o.seed or 3) - 0.5) * (o.noise or 0.16)
    if o.tex then v = v + o.tex(x, y) end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then v = v + 0.22 end
    if not m:has(x + 1, y) or not m:has(x, y + 1) then v = v - 0.2 end
    local i = (v > 0.74 and 5) or (v > 0.42 and 4) or (v > 0.17 and 3) or 2
    put(x, y, Rp[i])
  end)
  return m
end
-- textures
local function planksH(step, s) return function(x, y) return (y % step == 0 and -0.38 or 0) + (H(x // 3, y // step, s or 5) > 0.82 and -0.12 or 0) end end
local function planksV(step, s) return function(x, y) return (x % step == 0 and -0.38 or 0) + (H(x // step, y // 4, s or 6) > 0.8 and -0.12 or 0) end end
local function thatchT(x, y) return ((y % 4 == 3) and -0.34 or 0) + (H(x, y // 4, 9) > 0.66 and 0.16 or 0) + (H(x, y, 4) > 0.9 and -0.2 or 0) end
local function tileT(x, y) local r = y // 4 return ((y % 4 == 3) or ((x + r * 3) % 7 == 0)) and -0.34 or 0 end
local function stoneT(x, y) local r = y // 6 return ((y % 6 == 5) or ((x + (r % 2) * 5) % 10 == 0)) and -0.42 or (H(x // 10, r, 2) - 0.5) * 0.25 end
local function clumpT(s) return function(x, y) return (H(x // 3, y // 3, s) - 0.5) * 0.5 end end

-- ground type map for shadows
local gtype = {}
local function shadowM(m)
  m:each(function(x, y)
    if x < 0 or y < 0 or x >= W or y >= Hh then return end
    local g = gtype[y * W + x]
    if g == "path" then put(x, y, ((x + y) % 7 == 0) and "#8a5a5a" or "#9a6a62")
    elseif g == "grass" then put(x, y, ((x + y) % 7 == 0) and "#a87a72" or "#b4867a") end
  end)
end
local function shadowEll(cx, cy, rx, ry) shadowM(ell(cx, cy, rx, ry)) end

---------------------------------------------------------------- sky (desert haze, golden hour)
c:stripes(0, VY, {"#b68c98", "#c4968e", "#d4a48c", "#e2b48c", "#ecc292", "#f2d09c", "#f6dcaa", "#f8e6bc"}, {3, 3, 3, 3, 3, 3, 3, 3})
-- low sun: banded disc + dithered halo, set right of the centre charm
for y = 30, 70 do for x = 300, 344 do
  local d = sqrt((x - 322) ^ 2 + (y - 50) ^ 2)
  if d <= 8 then put(x, y, d <= 5 and "#fdf0c4" or "#fae2a4")
  elseif d <= 12 and (x + y) % 2 == 0 then put(x, y, "#f6d8a4") end
end end
-- long thin haze streaks instead of clouds
for _, st in ipairs({{24, 26, 110}, {160, 20, 60}, {290, 30, 120}, {60, 44, 70}, {250, 42, 50}, {380, 52, 70}, {120, 60, 60}}) do
  for x = st[1], st[1] + st[3] do put(x, st[2], "#f8e2c4") end
  for x = st[1] + 10, st[1] + st[3] - 14 do put(x, st[2] + 1, "#e6b8a2") end
end
-- far mesas: flat tops, steep sides, strata, pale and cool
local function mesa(x)
  local m = 88 + 3 * sin(x / 13)
  local function blk(a, b, top, sl)
    if x > a and x < b then
      local t = top
      if x < a + sl then t = top + (a + sl - x) * 2.2 end
      if x > b - sl then t = max(t, top + (x - (b - sl)) * 2.2) end
      m = min(m, t)
    end
  end
  blk(-10, 70, 66, 8) blk(130, 196, 72, 6) blk(244, 300, 76, 5) blk(350, 470, 62, 12)
  return floor(m)
end
local mz = c:terrain(mesa, "#d6aea0", VY)
mz:each(function(x, y)
  local t = mesa(x)
  if y == t then put(x, y, "#ecc8b2") end
  if (y - t) % 7 == 3 and y > t + 2 and y < 92 then put(x, y, "#c89c94") end
end)
for x = 1, W - 1 do
  if mesa(x) - mesa(x - 1) > 1 then for y = mesa(x - 1), mesa(x) + 6 do if y < 94 and mz:has(x, y) then put(x, y, "#bc908c") put(x - 1, y, "#c49890") end end end
end
-- a lone butte spire (silhouette landmark)
c:terrain(function(x) return (x > 206 and x < 214) and 70 + abs(x - 210) // 3 * 0 or 120 end, "#c89c94", VY)
for y = 70, 92 do put(207, y, "#dcb4a4") end
-- dunes in front of the mesas (lit crests, shaded lee faces)
local function dune(x) return floor(94 + 5 * sin(x * 0.03 + 2) + 3 * sin(x * 0.09)) end
local dz = c:terrain(dune, "#e6bc8c", VY)
dz:each(function(x, y)
  if y == dune(x) then put(x, y, "#f4d8a8") end
  if dune(x + 1) > dune(x - 1) and y < dune(x) + 4 then put(x, y, "#d0a07a") end
end)
-- irrigated grove band: rows of tiny date palms and round citrus trees
c:terrain(function(x) return 101 + 2 * sin(x * 0.05) end, "#c8b07a", VY)
for x = 0, W - 1 do if (x // 3) % 2 == 0 then put(x, floor(101 + 2 * sin(x * 0.05) + .5), "#a8a46a") end end
for _, ry in ipairs({100, 104, 108}) do
  local step = ry == 100 and 7 or (ry == 104 and 9 or 12)
  for x = 4 + (ry % 5), W - 4, step do
    if abs(x - VX) > 10 then
      local s = ry == 108 and 2 or 1
      if H(x, ry, 3) > 0.6 then -- tiny palm
        for k = 0, 2 + s do put(x, ry - k, "#8a6e5a") end
        local ty = ry - 3 - s
        for k = -2 - s, 2 + s do put(x + k, ty + (abs(k) > 1 and 1 or 0), "#7a7858") end
        put(x, ty - 1, "#a9a874")
      else -- round citrus
        for dx = -s, s do put(x + dx, ry - 1, "#6e8a52") put(x + dx, ry, "#56704a") end
        put(x - s, ry - 2, "#86a05e") put(x, ry - 2, "#86a05e")
        if H(x, ry, 4) > 0.5 then put(x + s, ry - 1, "#f49a3a") end
        put(x, ry + 1, "#7a5a44")
      end
    end
  end
end

---------------------------------------------------------------- ground
local grassBands = {"#f0d6a6", "#eccc98", "#eac287", "#e4ba7e", "#deb276"}
for y = VY + 1, Hh - 1 do
  local t = (y - VY) / (Hh - VY)
  local bi = min(5, 1 + floor(t * 5))
  for x = 0, W - 1 do
    gtype[y * W + x] = "grass"
    local a = (x - VX) / (y - VY + 0.5)
    local stripe = floor(a * 3.2 + 100) % 2
    local col = grassBands[bi]
    if stripe == 1 then col = grassBands[min(5, bi + 1)] end
    local n = H(x, y, 11)
    if n > 0.94 then col = "#f6dca4" elseif n < 0.04 then col = "#d1a068" end
    local rp = (y + floor(3 * sin(x / 14 + y / 30))) % 11
    if y > VY + 10 and rp == 0 and H(x // 3, y, 8) > 0.3 then col = "#d9b07a" elseif y > VY + 10 and rp == 1 and H(x // 3, y, 8) > 0.3 then col = "#f6dca4" end
    put(x, y, col)
  end
end
-- grass tufts
for i = 1, 700 do
  local x, y = floor(H(i, 1, 21) * W), VY + 4 + floor(H(i, 2, 21) * (Hh - VY - 4))
  local s = (y - VY) > 60 and 1 or 0
  if H(i, 7, 21) > 0.7 then
    put(x, y, "#8c8a62") put(x, y - 1, "#a9a874") if s == 1 then put(x + 1, y - 2, "#c8c892") put(x - 1, y - 1, "#a9a874") end
  elseif H(i, 7, 21) < 0.15 then put(x, y, "#c8a08a") put(x + 1, y, "#a87e6a") end
end
-- path (packed earth), wide at the bottom, to the vanishing point
local function pathEdge(y)
  local t = (y - VY) / (Hh - 1 - VY)
  local half = 5 + 100 * t + 2 * sin(y * 0.15)
  return VX - half, VX + half + 2 * t
end
local pathM = HP.mask()
for y = VY + 1, Hh - 1 do
  local l, r = pathEdge(y)
  for x = floor(l + .5), floor(r + .5) do pathM:set(x, y) end
end
c:rim(pathM, "#b98a5c")
local P5 = {"#7a4a3a", "#a8684c", "#c4825c", "#d49a70", "#e4b488"}
pathM:each(function(x, y)
  gtype[y * W + x] = "path"
  local l, r = pathEdge(y)
  local fx = (x - l) / max(1, r - l)
  local v = 0.62 + (H(x, y, 13) - 0.5) * 0.24
  if fx > 0.78 then v = v - 0.14 end
  -- two soft cart ruts converging
  local a = (x - VX) / (y - VY + 0.5)
  if abs(abs(a) - 0.3) < 0.035 then v = v - 0.26 end
  if not pathM:has(x - 1, y) or not pathM:has(x + 1, y) then v = v - 0.3 end
  local col = (v > 0.78 and P5[5]) or (v > 0.5 and P5[4]) or (v > 0.28 and P5[3]) or P5[2]
  put(x, y, col)
end)
-- pebbles
for i = 1, 160 do
  local y = VY + 10 + floor(H(i, 5, 31) ^ 0.7 * (Hh - VY - 12))
  local l, r = pathEdge(y)
  local x = floor(l + 3 + H(i, 6, 31) * (r - l - 6))
  if pathM:has(x, y) and pathM:has(x + 2, y) then
    local big = (y - VY) > 70
    put(x, y, "#dcae80") put(x + 1, y, "#b98762") put(x, y + 1, "#8a5a44")
    if big then put(x + 1, y - 1, "#f4d8b0") put(x + 2, y, "#8c6050") put(x + 1, y + 1, "#8a5a44") end
  end
end
-- grass tufts overhanging the path edges
for y = VY + 8, Hh - 1, 3 do
  local l, r = pathEdge(y)
  if H(y, 1, 41) > 0.4 then put(floor(l + 1), y, "#e4ba7e") put(floor(l + 1), y - 1, "#eccc98") end
  if H(y, 2, 41) > 0.4 then put(floor(r - 1), y, "#d1a068") put(floor(r - 1), y - 1, "#e4ba7e") end
end

-- v2.5.40 polish pass 1: ground variety (tonal patches, worn path, stepping stones, flowers, leaves, pebbles)
local PL = {}
PL.STAND = {{190, 244}, {278, 250}, {240, 212}, {214, 178}, {262, 150}, {338, 254}}
function PL.free(x, y)
  if x < 14 or x >= W - 14 or y <= VY + 1 or y >= Hh then return false end
  if x >= 380 and y >= 230 then return false end
  for _, s in ipairs(PL.STAND) do if abs(x - s[1]) <= 17 and abs(y - s[2]) <= 17 then return false end end
  return true
end
function PL.grass(x, y) return PL.free(x, y) and gtype[y * W + x] == "grass" end
function PL.path(x, y) return PL.free(x, y) and gtype[y * W + x] == "path" end
function PL.patch(cx, cy, rx, ry, col)
  local inner = ell(cx, cy, max(1, rx - 3), max(1, ry - 2))
  ell(cx, cy, rx, ry):each(function(x, y)
    if PL.grass(x, y) and (inner:has(x, y) or ((x + y) % 2 == 0 and H(x, y, 5) > 0.35)) then put(x, y, col) end
  end)
end
-- tonal meadow patches: shaded clover (dark), sunlit (light), plus a cool haze near the horizon
for _, p in ipairs({{172, 205, 24, 8}, {118, 150, 14, 4}, {300, 168, 20, 6}, {340, 180, 22, 5}, {404, 172, 28, 7}, {444, 150, 22, 5},
  {60, 232, 18, 5}, {150, 238, 14, 6}, {312, 236, 14, 5}, {410, 214, 12, 4}, {208, 150, 12, 4}}) do PL.patch(p[1], p[2], p[3], p[4], "#d6aa74") end
for _, p in ipairs({{190, 192, 14, 5}, {150, 124, 22, 4}, {292, 124, 26, 4}, {384, 120, 22, 3}, {420, 186, 18, 4}, {312, 150, 16, 4}, {170, 168, 18, 5},
  {120, 128, 10, 3}, {354, 232, 12, 4}, {150, 252, 12, 4}}) do PL.patch(p[1], p[2], p[3], p[4], "#f4d8a8") end
for x = 0, W - 1 do for y = VY + 1, VY + 5 do -- horizon haze: far ground paler and bluer
  if gtype[y * W + x] == "grass" and ((x + y) % 2 == 0 or y == VY + 1) then put(x, y, (y <= VY + 2) and "#f2dcc0" or "#ecd0ac") end
end end
-- worn path: sandy streaks on the crown, crumbly dithered edges, dark scuffs in the ruts
pathM:each(function(x, y)
  if PL.free(x, y) then
    local l, r = pathEdge(y)
    local fx = (x - l) / max(1, r - l)
    local a = (x - VX) / (y - VY + 0.5)
    if H(x // 5, y // 2, 61) > 0.78 and fx > 0.25 and fx < 0.75 and abs(abs(a) - 0.3) > 0.05 then put(x, y, "#ecbc90") end
    if abs(abs(a) - 0.3) < 0.035 and H(x, y, 62) > 0.7 then put(x, y, "#8a5440") end
    if (not pathM:has(x - 2, y) or not pathM:has(x + 2, y)) and (x + y) % 2 == 0 then put(x, y, "#d8b080") end
    if H(x, y, 63) > 0.985 then put(x, y, "#6a3a30") end
  end
end)
-- soil spill out of the path into the grass (crumbs)
for y = VY + 12, Hh - 2 do
  local l, r = pathEdge(y)
  for _, sx in ipairs({floor(l) - 2, floor(r) + 3}) do
    if H(sx, y, 64) > 0.72 and PL.grass(sx, y) then put(sx, y, "#c88a64") put(sx + (sx < VX and -1 or 1), y + 1, "#b47658") end
  end
end
-- stepping stones leading from the road toward the three side spots
function PL.stones(x0, y0, x1, y1, n, sz)
  for i = 0, n - 1 do
    local t = i / max(1, n - 1)
    local x, y = floor(x0 + (x1 - x0) * t + (H(i, 1, 65) - 0.5) * 3), floor(y0 + (y1 - y0) * t + (H(i, 2, 65) - 0.5) * 2)
    local rx = sz + (i % 2)
    if PL.free(x, y) and PL.free(x + rx, y + 2) then
      for dy = -1, 2 do for dx = -rx, rx do
        local inside = abs(dx) <= rx - (abs(dy - 0.5) > 1 and 1 or 0)
        if inside and dy <= 1 and not (abs(dx) == rx and dy ~= 0) then
          put(x + dx, y + dy, (dy == -1 and "#f4d8b0") or (dy == 0 and "#dcae80") or "#b98762")
        end
      end end
      for dx = -rx, rx + 1 do put(x + dx, y + 2, "#a87a72") end
      put(x - rx - 1, y, "#8c6050") put(x + rx + 1, y, "#8c6050")
    end
  end
end
PL.stones(166, 224, 148, 232, 4, 3)   -- road -> orchard crates
PL.stones(286, 168, 312, 170, 4, 3)   -- road -> stamp post
PL.stones(396, 164, 380, 172, 3, 2)   -- wild trail sign -> picnic
-- wild flowers in drifts (kind by cluster)
function PL.flower(x, y, k)
  if not PL.grass(x, y) or not PL.grass(x + 1, y + 1) then return end
  local pal = {{"#f6c45a", "#d68a20"}, {"#f49a5a", "#c45a3a"}, {"#e8a0d8", "#aa387e"}, {"#fbe484", "#e0a030"}, {"#e8608c", "#8e2a4a"}, {"#c8a0e4", "#7a5ab0"}}
  local p = pal[k]
  put(x, y + 2, "#706e52") put(x, y + 1, "#8c8a62")
  put(x, y - 1, p[1]) put(x - 1, y, p[1]) put(x + 1, y, p[1]) put(x, y + 0, p[2]) put(x, y - 0, p[2])
end
for i = 1, 18 do -- cluster centres (sparser in the desert)
  local cx, cy = 18 + floor(H(i, 1, 66) * 440), VY + 12 + floor(H(i, 2, 66) * 140)
  local k = 1 + floor(H(i, 3, 66) * 6)
  for j = 1, 3 + floor(H(i, 4, 66) * 6) do
    PL.flower(cx + floor((H(j, i, 67) - 0.5) * 22), cy + floor((H(i, j, 68) - 0.5) * 9), (H(j, i, 69) > 0.7) and (1 + (k % 6)) or k)
  end
end
-- clover/dark grass clumps, pebbles and fallen leaves
for i = 1, 90 do
  local x, y = 16 + floor(H(i, 1, 70) * 448), VY + 6 + floor(H(i, 2, 70) * 150)
  if PL.grass(x, y) and PL.grass(x + 2, y + 1) then
    put(x, y, "#706e52") put(x + 1, y, "#8c8a62") put(x + 2, y, "#706e52") put(x + 1, y - 1, "#a9a874")
  end
end
for i = 1, 36 do
  local x, y = 16 + floor(H(i, 1, 71) * 448), VY + 20 + floor(H(i, 2, 71) * 140)
  if PL.grass(x, y) and PL.grass(x + 1, y + 1) then put(x, y, "#dcae80") put(x + 1, y, "#8c6050") put(x, y + 1, "#b4867a") end
end
for i = 1, 60 do
  local x, y = 16 + floor(H(i, 1, 72) * 448), VY + 14 + floor(H(i, 2, 72) * 140)
  if (PL.grass(x, y) or PL.path(x, y)) and PL.free(x + 1, y + 1) then
    local o = H(i, 3, 72) > 0.5
    put(x, y, o and "#c8a070" or "#a8a46a") put(x + 1, y, o and "#8a6040" or "#706e52")
  end
end

function PL.cast(pts) -- cast shadow (always falls lower-right), only on bare ground
  poly(pts):each(function(x, y)
    if x >= 0 and y >= 0 and x < W and y < Hh and gtype[y * W + x] and PL.free(x, y) then
      local h = c:get(x, y)
      if h then
        local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
        put(x, y, string.format("#%02x%02x%02x", floor(r * 0.72), floor(g * 0.78), floor(b * 0.9)))
      end
    end
  end)
end
-- flora variety (date palm, olive with oranges, agave tufts, saguaro/ocotillo) drawn behind the buildings
-- palm helper: leaning ringed trunk + drooping frond fan + date clusters
function PL.palm(bx, by, hgt, lean, sd)
  local tr = HP.mask()
  for i = 0, hgt do local x = floor(bx + lean * (i / hgt) ^ 1.5) tr:add(rect(x - 1, by - i, x + 1, by - i)) end
  obj(tr, {"#3e2620", "#6a4a34", "#8a6a4a", "#a8845c", "#c8a070"}, { tex = function(x, y) return (y % 3 == 0) and -0.4 or 0 end, lx = 0.8 })
  local tx, ty = floor(bx + lean), by - hgt
  local fr = HP.mask()
  for k = -4, 4 do
    local ang = k * 0.38
    local len = 13 - abs(k) % 3
    for j = 1, len do
      local fx = tx + floor(math.sin(ang) * j * 1.2)
      local fy = ty - floor(math.cos(ang) * j * 0.55) + floor(j * j * 0.06)
      fr:add(rect(fx, fy, fx, fy + (j < len - 2 and 1 or 0)))
    end
  end
  obj(fr, R.dleaf, { tex = clumpT(sd), lx = 0.6, noise = 0.2 })
  for _, d in ipairs({{-2, 3}, {2, 3}}) do
    put(tx + d[1], ty + d[2], R.gold[2]) put(tx + d[1] + 1, ty + d[2], R.gold[3]) put(tx + d[1], ty + d[2] + 1, R.gold[3])
  end
end
do
  -- slim date palm beside the cottages (replaces the poplar)
  PL.palm(161, 127, 34, 2, 81)
  -- olive tree beside the road: grey-green, twisted trunk, oranges hanging (no pears)
  local OLV = {"#2e3e30", "#4e6450", "#6e8662", "#90a676", "#b8c896"}
  PL.cast({{258, 126}, {276, 126}, {282, 129}, {262, 129}})
  obj(poly{{263, 125}, {268, 125}, {267, 118}, {269, 113}, {265, 113}, {264, 118}}, R.wood, { tex = planksV(2, 5) })
  obj(ell(265, 106, 9, 7):add(ell(258, 110, 5, 4)):add(ell(273, 109, 5, 4)), OLV, { tex = clumpT(83), lx = 0.5 })
  for _, q in ipairs({{260, 108}, {267, 111}, {271, 106}, {263, 103}}) do
    obj(rect(q[1], q[2], q[1] + 1, q[2] + 1), R.gold, { noise = 0, rimc = R.gold[1] }) put(q[1], q[2], R.gold[5])
  end
  -- small agave rosettes along both path edges
  for y = VY + 10, Hh - 14, 11 do
    local l, r = pathEdge(y)
    for _, sx in ipairs({floor(l) - 7 - (y % 4), floor(r) + 8 + (y % 5)}) do
      if PL.grass(sx, y) and PL.grass(sx + 3, y + 3) then
        local big = y > 180
        for k = -3, 3 do
          local hh = (big and 5 or 3) - abs(k) // 2
          for j = 0, hh do put(sx + k + floor(k * j * 0.3), y + 2 - j, (j == hh) and "#c8d8b0" or ((k < 0) and "#8aa890" or "#6e9478")) end
        end
        put(sx, y + 3, "#a87a72") put(sx + 1, y + 3, "#a87a72")
      end
    end
  end
  -- saguaro beside the cottage and an ocotillo between the houses (replace hollyhocks)
  local CAC = {"#203e36", "#36624e", "#4e8662", "#6caa7a", "#acd49e"}
  local sag = rect(24, 106, 28, 137):add(rect(19, 116, 21, 124)):add(rect(19, 124, 24, 126)):add(rect(29, 112, 31, 119)):add(rect(28, 119, 31, 121))
  obj(sag, CAC, { tex = function(x, y) return (x % 2 == 0) and -0.25 or 0 end, lx = 0.7 })
  put(26, 105, "#f48cc4") put(25, 105, "#fcc8e2")
  for _, oc in ipairs({{-3, 1}, {-1, 0}, {1, 0}, {3, 1}}) do
    for j = 0, 26 do
      local x, y = 96 + oc[1] + floor(oc[1] * j * 0.12), 137 - j - oc[2]
      put(x, y, (j % 4 == 0) and "#86a05e" or "#6a4a34")
    end
    put(96 + oc[1] + floor(oc[1] * 26 * 0.12), 110 - oc[2], "#e8602c") put(96 + oc[1] + floor(oc[1] * 25 * 0.12), 111 - oc[2], "#c45a3a")
  end
end

---------------------------------------------------------------- HOMES (far left): two-tier pueblo adobe + mud-brick dome hut
local function adobeT(x, y) return ((H(x // 2, y // 2, 8) > 0.86) and -0.22 or 0) + ((H(x // 5, y // 3, 18) > 0.8) and 0.12 or 0) end
local function brickT(x, y) local r = y // 4 return ((y % 4 == 3) or ((x + (r % 2) * 4) % 8 == 0)) and -0.4 or (H(x // 8, r, 2) - 0.5) * 0.3 end
shadowM(poly{{32, 136}, {100, 136}, {110, 141}, {40, 141}})
-- kiva chimney (rounded, on the upper tier)
local chim = rect(74, 50, 82, 62):add(rect(75, 49, 81, 49))
obj(chim, R.plaster, { tex = adobeT })
for x = 75, 81 do put(x, 49, R.plaster[2]) end
put(76, 46, "#ecd8c4") put(77, 45, "#ecd8c4") put(79, 42, "#e0ccc0") put(80, 41, "#e0ccc0") put(81, 41, "#e0ccc0") put(78, 38, "#ecd8c4")
-- upper tier (set back) with a stepped parapet = the "roof" silhouette
local roof = rect(40, 64, 84, 92):add(rect(38, 60, 86, 64)):add(rect(42, 57, 50, 59)):add(rect(62, 57, 70, 59))
obj(roof, R.plaster, { tex = adobeT, ly = 0.12 })
for x = 38, 86 do put(x, 64, R.plaster[2]) end
-- lower block
local wall = rect(30, 92, 92, 136):add(rect(28, 88, 94, 92))
obj(wall, R.plaster, { tex = adobeT })
for x = 28, 94 do put(x, 92, R.plaster[2]) put(x, 88, R.plaster[5]) end
-- vigas (log ends) under both roof lines
local beams = HP.mask()
for x = 42, 82, 8 do beams:add(rect(x, 66, x + 3, 68)) end
for x = 33, 89, 8 do beams:add(rect(x, 94, x + 3, 96)) end
obj(beams, R.wood, { lift = 0.05 })
beams:each(function(x, y) if not beams:has(x + 1, y) then put(x + 1, y + 1, R.plaster[2]) end end)
-- windows (warm glow), turquoise frames
local function window(x0, y0, x1, y1)
  obj(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1), R.green, { lift = -0.1 })
  local g = rect(x0, y0, x1, y1)
  g:each(function(x, y)
    local v = (y - y0) / max(1, y1 - y0)
    put(x, y, (v < 0.3 and R.glow[5]) or (v < 0.7 and R.glow[4]) or R.glow[3])
  end)
  local mx, my = (x0 + x1) // 2, (y0 + y1) // 2
  for y = y0, y1 do put(mx, y, R.green[2]) end
  for x = x0, x1 do put(x, my, R.green[2]) end
  for x = x0 - 1, x1 + 1 do put(x, y1 + 2, R.wood[3]) end -- wooden lintel/sill
end
window(38, 99, 52, 110) window(68, 99, 84, 110) window(72, 117, 84, 128) window(50, 72, 58, 82)
-- bougainvillea box under right window
obj(rect(70, 130, 86, 133), R.roof)
for x = 71, 85, 2 do put(x, 129, (x % 4 == 1) and R.blossom[4] or R.blossom[3]) put(x + 1, 129, R.leaf[4]) end
-- door: turquoise, arched top
local door = rect(42, 118, 54, 135):add(rect(43, 116, 53, 117)):add(rect(45, 115, 51, 115))
obj(door, R.green, { tex = planksV(3, 7) })
put(51, 127, R.gold[5]) put(51, 128, R.gold[3])
obj(rect(40, 136, 56, 138), R.stone)
-- ladder up to the upper tier (pueblo cue)
for _, lx in ipairs({86, 91}) do for y = 70, 90 do put(lx, y, R.wood[3]) put(lx + 1, y, R.wood[2]) end end
for y = 74, 88, 4 do for x = 87, 90 do put(x, y, R.wood[4]) end end
-- strings of red chiles hanging from the vigas
for _, rx in ipairs({35, 61}) do for k = 0, 6 do put(rx + (k % 2), 97 + k, (k % 2 == 0) and R.apple[4] or R.apple[3]) end put(rx, 97, R.leaf[3]) end
-- QUIRK: pomegranate weathervane on the parapet
for y = 47, 56 do put(52, y, R.metal[2]) end
for x = 46, 58 do put(x, 52, R.metal[2]) end
local av = poly{{50, 44}, {54, 44}, {56, 46}, {56, 50}, {54, 51}, {50, 51}, {48, 50}, {48, 46}}
obj(av, R.apple, { noise = 0.05 })
put(51, 43, R.apple[2]) put(52, 42, R.apple[3]) put(53, 43, R.apple[2])

-- mud-brick hut with a turquoise dome
shadowM(poly{{110, 136}, {148, 136}, {156, 141}, {118, 141}})
obj(rect(110, 108, 146, 136), R.brick, { tex = brickT })
obj(rect(108, 106, 148, 109), R.plaster, { lift = 0.1 })
local hroof = ell(128, 106, 16, 15)
hroof:cut(rect(100, 107, 160, 130))
obj(hroof, R.green, { tex = function(x, y) return ((x - 128) % 6 == 0) and -0.25 or 0 end, ly = 0.2 })
obj(rect(127, 86, 129, 91), R.gold) put(128, 85, R.gold[5])
local hdoor = rect(122, 119, 133, 136):add(rect(123, 117, 132, 118)):add(rect(125, 116, 130, 116))
obj(hdoor, R.blue, { tex = planksV(3, 8) })
put(130, 127, R.gold[5])
window(137, 116, 143, 124)
-- clay beehive (terracotta skep) beside the hut door
local skep = poly{{112, 126}, {114, 122}, {118, 121}, {120, 124}, {120, 135}, {111, 135}}
obj(skep, R.roof, { tex = function(x, y) return (y % 3 == 0) and -0.35 or 0 end })
put(115, 132, R.wood[1]) put(116, 132, R.wood[1])

---------------------------------------------------------------- CIDER PRESS (mid left decor)
shadowM(poly{{170, 145}, {206, 145}, {214, 150}, {178, 150}})
obj(rect(168, 112, 172, 145), R.wood, { tex = planksV(9) })
obj(rect(200, 112, 204, 145), R.wood, { tex = planksV(9) })
obj(rect(165, 110, 207, 116), R.wood, { tex = planksH(9) })
obj(rect(184, 116, 188, 128), R.stone, { tex = function(x, y) return (y % 2 == 0) and -0.3 or 0.1 end })
obj(rect(178, 104, 194, 107), R.stone) -- crank bar
obj(rect(185, 107, 187, 110), R.stone)
local vat = rect(175, 128, 197, 144)
obj(vat, R.barrel, { tex = planksV(4) })
for x = 175, 197 do put(x, 132, R.stone[2]) put(x, 140, R.stone[2]) end
obj(rect(176, 126, 196, 128), R.pale, { lift = 0.1 }) -- press plate
obj(rect(197, 138, 201, 140), R.wood) -- spout
put(201, 141, R.gold[4]) put(201, 142, R.gold[3]) -- drip
local jug = rect(198, 143, 204, 146)
obj(jug, R.cream, { rim = false })

---------------------------------------------------------------- STOP (mid right): notice board + stamp post
shadowM(poly{{306, 158}, {366, 158}, {378, 163}, {316, 163}})
obj(rect(312, 104, 318, 160), R.pale, { tex = planksV(7) })
obj(rect(350, 104, 356, 160), R.pale, { tex = planksV(7) })
local board = rect(300, 104, 368, 140)
obj(board, R.wood, { lift = -0.05 })
obj(rect(303, 107, 365, 137), R.cork, { tex = function(x, y) return (H(x, y, 17) > 0.86) and -0.25 or 0 end, rimc = R.wood[2] })
-- notes (no text: shapes only)
local function note(x0, y0, x1, y1, Rp, pin)
  obj(rect(x0, y0, x1, y1), Rp, { noise = 0.08, rimc = R.cork[1] })
  put((x0 + x1) // 2, y0 + 1, pin or R.apple[4]) put((x0 + x1) // 2 + 1, y0 + 1, R.apple[2])
end
note(306, 110, 324, 126, R.cream)
for y = 115, 123, 3 do for x = 308, 321 do if H(x, y, 19) > 0.25 then put(x, y, R.stone[2]) end end end
note(328, 109, 344, 123, R.blue, R.gold[5])
-- map note with dotted route
note(347, 111, 362, 133, R.cream, R.leaf[5])
for i = 0, 9 do put(349 + i, 130 - (i * 17) % 15 // 2 - i, R.apple[3]) end
put(359, 118, R.apple[2]) put(360, 118, R.apple[2]) put(359, 117, R.apple[2])
-- apple icon note
note(328, 126, 344, 136, R.cream, R.blue[4])
local ai = poly{{333, 129}, {339, 129}, {340, 131}, {339, 134}, {333, 134}, {332, 131}}
obj(ai, R.apple, { noise = 0.04, rim = false })
put(336, 128, R.leaf[3])
-- shingle roof
-- palm-frond (palapa) roof with a ragged fringe
local sroof = poly{{294, 105}, {304, 93}, {364, 93}, {374, 105}}
obj(sroof, R.thatch, { tex = thatchT })
for x = 295, 373, 2 do put(x, 106, R.thatch[3]) if x % 6 == 1 then put(x, 107, R.thatch[2]) end end
-- icon plaque on the roof peak: rubber stamp
obj(rect(324, 80, 344, 94), R.gold, { tex = function(x, y) return 0 end })
obj(rect(332, 82, 336, 86), R.wood, { rim = true })
obj(rect(328, 87, 340, 89), R.wood)
obj(rect(327, 90, 341, 91), R.apple)
-- stamp box hanging between posts
for y = 141, 144 do put(326, y, R.stone[2]) put(342, y, R.stone[2]) end
obj(rect(322, 145, 346, 156), R.apple, { tex = planksH(4) })
obj(rect(331, 148, 337, 153), R.gold, { noise = 0.05 })
-- QUIRK: boot planter at the post foot
local boot = poly{{358, 146}, {364, 146}, {364, 156}, {370, 156}, {371, 160}, {358, 160}}
obj(boot, R.wood, { lift = 0.05 })
-- a little prickly-pear in the boot
local pp = ell(361, 140, 3, 4):add(ell(357, 136, 2, 3)):add(ell(365, 135, 2, 3))
obj(pp, {"#203e36", "#36624e", "#4e8662", "#6caa7a", "#acd49e"}, { noise = 0.1 })
put(357, 132, "#f6c45a") put(365, 131, "#e8608c") put(360, 139, "#c8d8b0") put(362, 142, "#c8d8b0")

---------------------------------------------------------------- WILD TRAIL (far right): palm arch framing a red canyon trail + signpost
-- canyon view inside the arch: red rock walls, shaded floor
local inside = poly{{410, 76}, {460, 70}, {462, 156}, {410, 156}}
inside:each(function(x, y)
  local wallL = 418 + floor((y - 70) * 0.12) + floor(3 * sin(y / 7))
  local wallR = 452 - floor((y - 70) * 0.05) + floor(2 * sin(y / 5 + 1))
  local col
  if y < 100 and x > wallL + 2 and x < wallR - 2 then col = (y < 88) and "#f2d09c" or "#e2b48c" -- sky slot
  elseif x <= wallL then col = ((y // 6) % 2 == 0) and "#a8583e" or "#94483a"
  elseif x >= wallR then col = ((y // 5) % 2 == 0) and "#7a3a34" or "#6a3230"
  else col = (y > 118) and ((H(x // 3, y // 3, 23) > 0.6) and "#ecc292" or "#e4b488") or ((H(x // 3, y // 3, 23) > 0.6) and "#d49a70" or "#c88a64") end
  if x <= wallL and (y % 6 == 0) then col = "#c46a4a" end
  if x == wallL or x == wallR then col = "#5a2a2c" end
  put(x, y, col)
end)
for y = 76, 150, 7 do for x = 410, 462 do if inside:has(x, y) and H(x // 4, y, 29) > 0.55 and c:get(x, y) ~= "#f2d09c" and c:get(x, y) ~= "#e2b48c" then put(x, y, "#5a2a2c") end end end
-- trail through the arch bending off to the right edge
local trail = poly{{404, 158}, {438, 158}, {462, 132}, {462, 124}, {448, 128}, {420, 148}}
obj(trail, {"#7a4a3a", "#a8684c", "#c4825c", "#d49a70", "#e4b488"}, { rim = false, noise = 0.2 })
-- palm trunks (ringed)
local lt = poly{{404, 158}, {414, 158}, {412, 120}, {416, 86}, {408, 84}, {404, 120}}
local PT = {"#3e2620", "#6a4a34", "#8a6a4a", "#a8845c", "#c8a070"}
obj(lt, PT, { tex = function(x, y) return ((y + (x % 2)) % 4 == 0) and -0.4 or 0 end })
local rtr = poly{{446, 158}, {456, 158}, {458, 110}, {462, 80}, {454, 80}, {450, 110}}
obj(rtr, PT, { tex = function(x, y) return ((y + (x % 2)) % 4 == 0) and -0.4 or 0 end })
-- palm-frond arch canopy
local can = HP.mask()
for _, ctr in ipairs({{412, 78}, {456, 76}, {434, 60}}) do
  for k = -6, 6 do
    local ang = k * 0.3
    for j = 1, 22 - abs(k) do
      local fx = ctr[1] + floor(math.sin(ang) * j * 1.3)
      local fy = ctr[2] - floor(math.cos(ang) * j * 0.45) + floor(j * j * 0.045)
      can:add(rect(fx, fy, fx + 1, fy + 2))
    end
  end
end
can:add(ell(434, 66, 10, 4))
obj(can, R.dleaf, { tex = clumpT(31) })
-- date clusters hanging under the crowns
for _, d in ipairs({{410, 80}, {416, 80}, {456, 78}, {430, 69}, {438, 69}}) do
  for k = 0, 3 do put(d[1] + (k % 2), d[2] + k, (k % 2 == 0) and R.gold[2] or R.gold[3]) put(d[1] + (k % 2) + 1, d[2] + k, R.gold[1]) end
end
-- bougainvillea tumbling from the left crown
for i = 1, 26 do
  local x, y = 400 + floor(H(i, 1, 33) * 30), 66 + floor(H(i, 2, 33) * 26)
  if can:has(x, y) and can:has(x + 1, y + 1) then put(x, y, R.blossom[4]) put(x + 1, y, R.blossom[3]) put(x, y + 1, R.blossom[3]) end
end
-- signpost with arrow pointing right (into the wild)
shadowM(poly{{390, 156}, {398, 156}, {404, 159}, {394, 159}})
obj(rect(391, 104, 395, 158), R.pale, { tex = planksV(9) })
local arrow = poly{{386, 110}, {414, 110}, {422, 116}, {414, 122}, {386, 122}}
obj(arrow, R.green, { tex = planksH(4) })
-- cactus icon on the arrow
for y = 112, 120 do put(400, y, R.cream[4]) put(401, y, R.cream[4]) end
put(397, 114, R.cream[4]) put(397, 115, R.cream[4]) put(398, 116, R.cream[4]) put(399, 116, R.cream[4])
put(404, 113, R.cream[4]) put(404, 114, R.cream[4]) put(403, 115, R.cream[4]) put(402, 115, R.cream[4])
-- little tin lantern charm on the arch
for y = 86, 92 do put(426, y, R.metal[1]) end
obj(rect(423, 93, 429, 101), R.glow, { rimc = R.wood[1] })

---------------------------------------------------------------- DO (near left): apple tree, ladder, crates
-- tree shadow on grass
shadowM(poly{{24, 254}, {104, 254}, {124, 264}, {40, 264}})
-- trunk with roots and QUIRK tiny door
local trunk = poly{{50, 200}, {64, 200}, {66, 244}, {74, 258}, {40, 258}, {48, 244}}
obj(trunk, R.wood, { tex = planksV(3, 14), lx = 0.5 })
local tdoor = rect(53, 247, 59, 257):add(rect(54, 245, 58, 246))
obj(tdoor, R.green, { rimc = R.wood[1] })
put(58, 252, R.gold[5])
-- canopy
local canopy = ell(60, 182, 42, 26):add(ell(34, 170, 18, 14)):add(ell(84, 168, 20, 14)):add(ell(58, 162, 26, 11))
canopy:add(ell(28, 190, 14, 12)):add(ell(94, 190, 14, 12))
obj(canopy, R.leaf, { tex = clumpT(37) })
-- blossom clusters and apples
for i = 1, 40 do -- orange blossom (cream stars)
  local x, y = 18 + floor(H(i, 1, 43) * 92), 152 + floor(H(i, 2, 43) * 60)
  if canopy:has(x - 1, y - 1) and canopy:has(x + 2, y + 2) then
    put(x, y, R.cream[5]) put(x + 1, y, R.cream[4]) put(x, y + 1, R.cream[4]) put(x + 1, y + 1, R.gold[4])
  end
end
for i = 1, 30 do -- oranges and pomegranates hanging
  local x, y = 22 + floor(H(i, 3, 47) * 84), 166 + floor(H(i, 4, 47) * 46)
  if canopy:has(x - 1, y - 1) and canopy:has(x + 4, y + 4) then
    local a = rect(x, y, x + 3, y + 3)
    a:cut(rect(x, y, x, y)):cut(rect(x + 3, y, x + 3, y))
    local Rp = (H(i, 5, 47) > 0.4) and R.gold or R.apple
    obj(a, Rp, { noise = 0, rimc = R.leaf[1] })
    put(x + 1, y + 1, Rp[5]) put(x + 2, y - 1, (Rp == R.apple) and R.apple[2] or R.leaf[2])
  end
end
-- QUIRK: kite caught in the tree top
local kite = poly{{74, 148}, {80, 154}, {74, 162}, {68, 154}}
obj(kite, R.kite, { noise = 0.02 })
for y = 149, 161 do put(74, y, R.kite[2]) end
for x = 69, 79 do put(x, 154, R.kite[2]) end
for i = 0, 8 do put(80 + i, 162 + i + (i % 2), R.apple[3]) if i % 3 == 1 then put(81 + i, 162 + i, R.blossom[3]) end end
-- ladder leaning on the tree
local rails = c:line({{86, 258}, {100, 176}}, 2):add(c:line({{98, 258}, {112, 178}}, 2))
local rungs = HP.mask()
for k = 0, 7 do
  local t = 0.08 + k * 0.12
  local ya = floor(258 - t * 82)
  local xa, xb = floor(86 + t * 14) + 1, floor(98 + t * 14)
  rungs:add(rect(xa, ya, xb, ya + 1))
end
obj(rungs, R.pale, { lift = 0.1 })
obj(rails, R.pale, { lift = 0.1 })
-- crate shadows
shadowM(poly{{102, 258}, {152, 258}, {160, 263}, {110, 263}})
local function crate(x0, y0, x1, y1, s)
  obj(rect(x0, y0, x1, y1), R.pale, { tex = planksH(5, s) })
  for y = y0, y1 do put(x0 + 2, y, R.pale[2]) put(x1 - 2, y, R.pale[2]) end
  -- end mark: apple icon burned in
  local cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
  put(cx - 1, cy, R.wood[2]) put(cx, cy, R.wood[2]) put(cx + 1, cy, R.wood[2]) put(cx, cy - 1, R.wood[2]) put(cx, cy + 1, R.wood[2]) put(cx, cy - 2, R.leaf[3])
end
local function apples(x0, x1, ytop, s)
  for x = x0, x1 - 3, 4 do
    local yy = ytop - ((x // 4) % 2) * 2
    local a = rect(x, yy, x + 3, yy + 3) a:cut(rect(x, yy, x, yy)):cut(rect(x + 3, yy, x + 3, yy))
    local Rp = (H(x, s, 5) > 0.45) and R.gold or R.apple
    obj(a, Rp, { noise = 0, rimc = Rp[1] })
    put(x + 1, yy + 1, Rp[5])
  end
end
apples(106, 128, 236, 1) apples(130, 150, 236, 2)
crate(104, 238, 127, 258, 1)
crate(129, 238, 150, 258, 2)
apples(117, 141, 212, 3)
crate(114, 214, 140, 236, 3)
-- QUIRK: one big split pomegranate on top, seeds showing
local big = poly{{124, 202}, {132, 202}, {135, 205}, {135, 210}, {132, 213}, {124, 213}, {121, 210}, {121, 205}}
big:cut(ell(135, 207, 3, 3))
obj(big, R.apple, { noise = 0.03 })
for y = 205, 209 do put(132, y, R.cream[4]) put(131, y, R.cream[3]) end
put(131, 206, R.apple[5]) put(132, 208, R.apple[4]) put(131, 209, R.apple[5]) put(130, 207, R.apple[4])
put(126, 201, R.apple[2]) put(127, 200, R.apple[3]) put(128, 201, R.apple[2]) -- crown

---------------------------------------------------------------- PEOPLE (near right): picnic blanket, table, fire pit
-- blanket (gingham) in perspective
local blank = poly{{300, 226}, {314, 196}, {362, 196}, {360, 226}}
c:rim(blank, R.cloth[1])
blank:each(function(x, y)
  local a = floor((x - 240 - (y - 196) * 0.0) / 6) + floor((y - 196) / 5)
  local cx2, cy2 = floor(x / 6) % 2, floor((y - 196) / 5) % 2
  local col
  local band = floor((y - 196) / 5) % 4
  local dz = abs(((x + (band % 2) * 6) % 12) - 6) + abs(((y - 196) % 10) - 5)
  if band == 1 then col = R.green[4] elseif band == 3 then col = R.gold[4] else col = R.cloth[3] end
  if dz < 3 then col = R.cream[4] elseif dz == 3 then col = R.cloth[1] end
  if not blank:has(x, y + 1) then col = R.cloth[2] end
  put(x, y, col)
end)
for x = 302, 359, 3 do put(x, 227, R.cloth[3]) end -- fringe
-- wicker basket on blanket
shadowM(poly{{322, 220}, {344, 220}, {348, 223}, {326, 223}})
local bh = c:line({{322, 208}, {326, 200}, {338, 200}, {342, 208}}, 2)
obj(bh, R.wicker, { rim = true })
obj(rect(320, 207, 344, 219), R.wicker, { tex = function(x, y) return (((x + y) % 4 == 0) or ((x - y) % 4 == 0)) and -0.3 or 0 end })
put(324, 206, R.cloth[4]) put(325, 205, R.cloth[4]) put(326, 206, R.cloth[2]) -- napkin tip
-- table + benches
shadowM(poly{{372, 222}, {434, 222}, {444, 228}, {380, 228}})
obj(rect(376, 200, 380, 222), R.wood) obj(rect(424, 200, 428, 222), R.wood)
obj(rect(368, 194, 434, 200), R.pale, { tex = planksH(3, 21) })
obj(rect(370, 212, 432, 215), R.pale, { tex = planksV(8) })
obj(rect(374, 216, 377, 224), R.wood) obj(rect(426, 216, 429, 224), R.wood)
-- cider jug with handle
local jugM = poly{{386, 182}, {392, 182}, {394, 186}, {394, 193}, {384, 193}, {384, 186}}
obj(jugM, R.roof)
obj(c:line({{394, 186}, {397, 188}, {394, 191}}, 1), R.roof)
for x = 385, 393 do put(x, 189, R.green[4]) end
obj(rect(387, 179, 391, 181), R.wood)
-- mugs
obj(rect(400, 187, 405, 193), R.barrel) obj(rect(409, 187, 414, 193), R.barrel)
put(401, 187, R.gold[5]) put(410, 187, R.gold[5])
-- pie with a slice missing (wedge cut)
local pie = poly{{416, 189}, {430, 189}, {432, 193}, {414, 193}}
obj(pie, R.gold, { tex = function(x, y) return ((x + y) % 4 == 0) and -0.3 or 0 end })
for x = 418, 422 do put(x, 189, R.apple[3]) end
-- fire pit: square stone ring, logs, flames
shadowM(poly{{438, 224}, {460, 224}, {462, 228}, {442, 228}})
obj(rect(438, 210, 460, 224), R.stone, { tex = stoneT })
obj(rect(442, 208, 456, 211), R.barrel)
local flame = poly{{442, 208}, {444, 198}, {447, 203}, {449, 192}, {452, 202}, {454, 197}, {456, 208}}
flame:each(function(x, y)
  local v = (y - 192) / 16 + (H(x, y, 51) - 0.5) * 0.2
  put(x, y, (v < 0.35 and R.glow[5]) or (v < 0.6 and R.glow[4]) or (v < 0.85 and R.glow[3]) or R.glow[2])
end)
c:rim(flame, R.glow[2], HP.mask():add(rect(436, 190, 462, 207)))
-- warm glow sparks
put(446, 188, R.glow[4]) put(452, 185, R.glow[5]) put(449, 182, R.glow[4])
-- string of lights from fire post to table
for x = 380, 436 do
  local y = floor(176 + ((x - 408) ^ 2) / 160)
  put(x, y, R.wood[1])
  if x % 8 == 0 then put(x, y + 1, R.glow[4]) put(x, y + 2, R.glow[3]) end
end
obj(rect(434, 172, 436, 208), R.wood)
obj(rect(366, 172, 368, 193), R.wood)

-- v2.5.40 polish pass 2: material cues (moss/lichen north side, rust, rope, grain, nails, cracks, cloth folds)
PL.MOSS = {"#d8b48a", "#c09670", "#ecd0a6"}   -- blown sand / dust drifts
PL.RUST = {"#a8603a", "#8a4a2c", "#d08848"}
PL.LICH = {"#c8b890", "#a89c7a", "#e0d4b0"}
PL.STAIN = {"#b07a5e", "#9a6650", "#c89070"}
function PL.blob(m, cx, cy, rx, ry, cols, sd)
  ell(cx, cy, rx, ry):each(function(x, y)
    if m:has(x, y) then
      local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if d < 0.55 or (d < 1 and (x + y) % 2 == 0) then
        local h = H(x, y, sd or 3)
        put(x, y, h > 0.78 and cols[3] or (h > 0.28 and cols[1] or cols[2]))
      end
    end
  end)
end
function PL.rope(x0, y0, x1, y1)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do put(floor(x0 + (x1 - x0) * i / max(1, n) + .5), floor(y0 + (y1 - y0) * i / max(1, n) + .5), (i % 2 == 0) and "#dcc090" or "#8e6c44") end
end
function PL.nail(x, y, rust) put(x, y, "#d6d0d8") put(x, y + 1, rust and PL.RUST[1] or R.wood[1]) end
do
  -- thatch: moss on the shaded top edge, straw strands, ridge ties
  PL.blob(roof, 50, 63, 8, 4, PL.MOSS, 1) PL.blob(roof, 36, 76, 5, 6, PL.MOSS, 2) PL.blob(roof, 78, 62, 6, 3, PL.MOSS, 3)
  -- adobe: rain gutters (canales) with drip stains
  for _, gx in ipairs({44, 78}) do for x = gx, gx + 4 do put(x, 62, R.wood[3]) put(x, 63, R.wood[1]) end for y = 65, 76 do if y % 3 ~= 0 then put(gx + 2, y, PL.STAIN[2]) end end end
  -- chimney soot
  for x = 74, 82 do if (x % 2) == 0 then put(x, 50, R.stone[1]) end put(x, 51, ((x + 1) % 3 == 0) and R.stone[1] or R.stone[2]) end
  PL.blob(rect(73, 50, 83, 70), 75, 66, 3, 4, PL.MOSS, 4)
  -- plaster: damp streaks, base grime, hairline crack, beam grain and nails
  for _, d in ipairs({{40, 4}, {44, 3}, {48, 5}, {51, 2}, {72, 4}, {78, 3}, {82, 5}, {74, 3}}) do for k = 0, d[2] do put(d[1], 109 + k + (d[1] > 60 and 0 or 0), PL.STAIN[1 + k % 2]) end end
  for x = 31, 91 do for y = 131, 135 do if not (x > 40 and x < 56) and not (x > 68 and x < 88 and y < 134) and (x + y) % 3 == 0 and wall:has(x, y) and not beams:has(x, y) then put(x, y, R.plaster[2]) end end end
  for i, p2 in ipairs({{55, 112}, {56, 114}, {55, 116}, {56, 118}, {57, 120}, {64, 76}, {65, 78}, {64, 80}}) do put(p2[1], p2[2], R.plaster[1]) end
  beams:each(function(x, y) if (y % 5 == 2) and H(x, y, 9) > 0.35 then put(x, y, "#523022") end end)

  -- stone hut: quoins, chips, crack, lichen, moss; tile roof moss + patched tile
  -- brick hut: a few spalled bricks, dust at the foot, dome glaze highlights
  for _, q in ipairs({{117, 113}, {142, 119}, {116, 128}, {121, 133}, {139, 112}}) do put(q[1], q[2], R.brick[5]) put(q[1] + 1, q[2], R.brick[5]) put(q[1], q[2] + 1, R.brick[2]) end
  PL.blob(rect(110, 108, 146, 136), 143, 134, 6, 3, PL.MOSS, 6) PL.blob(rect(110, 108, 146, 136), 114, 134, 5, 2, PL.MOSS, 7)
  for _, q in ipairs({{120, 97}, {121, 96}, {122, 95}, {118, 99}}) do put(q[1], q[2], R.green[5]) end
  -- cider press: rusty hoops with drips, rope coil on the crank, grain, moss at the feet
  for x = 175, 197 do for _, y in ipairs({132, 140}) do if H(x, y, 7) > 0.5 then put(x, y, PL.RUST[1 + (x % 2)]) end end end
  for _, x in ipairs({178, 186, 193}) do put(x, 141, PL.RUST[2]) put(x, 142, PL.RUST[1]) end
  for _, x in ipairs({177, 181, 185, 190, 194}) do for y = 134, 139 do if H(x, y, 8) > 0.35 then put(x, y, R.barrel[2]) end end end
  for k = 0, 3 do put(180 + k * 2, 104, "#dcc090") put(181 + k * 2, 105, "#dcc090") put(180 + k * 2, 106, "#8e6c44") put(181 + k * 2, 107, "#8e6c44") end
  PL.rope(194, 108, 195, 119) put(194, 120, "#8e6c44") put(195, 120, "#8e6c44") put(194, 121, "#dcc090") put(195, 121, "#dcc090")
  for x = 166, 206 do if H(x, 3, 12) > 0.6 then put(x, 113, R.wood[2]) end end
  PL.blob(rect(165, 110, 207, 112), 170, 111, 6, 2, PL.MOSS, 10)
  PL.blob(rect(168, 138, 172, 145), 170, 144, 4, 3, PL.MOSS, 11) PL.blob(rect(200, 138, 204, 145), 202, 144, 4, 3, PL.MOSS, 12)
  -- notice board: tile moss, rusty nails, knot in the post
  PL.blob(sroof, 301, 97, 7, 3, PL.MOSS, 13) PL.blob(sroof, 330, 94, 5, 1, PL.MOSS, 14)
  for _, n in ipairs({{302, 106}, {366, 106}, {302, 137}, {366, 137}}) do PL.nail(n[1], n[2], true) end
  put(314, 128, R.wood[1]) put(315, 128, R.wood[1]) put(314, 129, R.pale[2]) put(315, 127, R.pale[2])
  PL.blob(rect(312, 150, 356, 160), 314, 158, 4, 3, PL.MOSS, 15) PL.blob(rect(312, 150, 356, 160), 353, 158, 4, 3, PL.MOSS, 16)
  for _, y in ipairs({148, 152}) do put(360, y, R.cream[4]) put(362, y, R.cream[4]) put(361, y + 1, R.cream[4]) end
  -- tree: bark crevices, lichen north-west, moss in the roots
  for _, x in ipairs({53, 57, 61}) do for y = 204, 242 do if trunk:has(x, y) and H(x, y // 6, 12) > 0.55 then put(x, y, R.wood[1]) put(x + 1, y, R.wood[2]) end end end
  PL.blob(trunk, 53, 214, 2, 3, {"#8aa890", "#6e9478", "#a8c4a0"}, 17) PL.blob(trunk, 47, 248, 5, 5, PL.MOSS, 18)
  -- ladder twine repair, crate nails and a split slat
  for _, x0 in ipairs({91, 103}) do for k = 0, 2 do for x = x0, x0 + 2 do put(x, 224 + k, (k % 2 == 0) and "#dcc090" or "#8e6c44") end end end
  for _, cr in ipairs({{104, 238, 127, 258}, {129, 238, 150, 258}, {114, 214, 140, 236}}) do
    PL.nail(cr[1] + 2, cr[2] + 2, false) PL.nail(cr[3] - 2, cr[2] + 2, false) PL.nail(cr[1] + 2, cr[4] - 3, false) PL.nail(cr[3] - 2, cr[4] - 3, false)
  end
  for y = 241, 246 do put(119, y, R.wood[1]) put(120, y + 1, R.pale[4]) end
  -- picnic: cloth folds and a turned corner, table grain/knots/rings, fire-ring soot and chips
  for y = 198, 225 do for _, x0 in ipairs({349, 305}) do
    local x = floor(x0 + (y - 198) * (x0 > 340 and 0.12 or -0.4))
    if blank:has(x, y) and blank:has(x + 1, y) then put(x, y, R.cloth[1 + (y % 3 == 0 and 1 or 0)]) put(x + 1, y, R.cloth[5]) end
  end end
  for _, t in ipairs({{301, 225}, {302, 224}, {303, 223}, {302, 225}, {303, 225}, {304, 225}, {303, 224}, {304, 224}, {305, 225}}) do put(t[1], t[2], R.cream[4]) end
  put(301, 226, R.cloth[1]) put(302, 226, R.cloth[1]) put(303, 226, R.cloth[1]) put(304, 226, R.cloth[1]) put(305, 226, R.cloth[1])
  for x = 369, 433 do if H(x // 5, 2, 9) > 0.45 then put(x, 197, R.pale[2]) end if H(x // 4, 5, 9) > 0.6 then put(x, 199, R.pale[2]) end end
  for _, k in ipairs({{398, 196}, {421, 197}}) do put(k[1], k[2], R.wood[2]) put(k[1] + 1, k[2], R.wood[2]) put(k[1], k[2] + 1, R.pale[2]) end
  for _, x in ipairs({371, 431}) do put(x, 195, "#d6d0d8") end
  for x = 439, 459 do if H(x, 2, 14) > 0.45 then put(x, 211, R.stone[1]) end if H(x, 4, 14) > 0.7 then put(x, 212, R.stone[1]) end end
  for _, q in ipairs({{444, 217}, {451, 221}, {456, 214}}) do put(q[1], q[2], R.stone[5]) put(q[1] + 1, q[2], R.stone[4]) end
  PL.blob(rect(438, 210, 460, 224), 441, 222, 4, 3, PL.MOSS, 20)
  -- signpost: weathering and nails; arrow board rust runs
  for y = 106, 156 do if H(393, y // 3, 15) > 0.62 then put(392, y, R.pale[2]) end end
  PL.nail(388, 112, true) PL.nail(388, 118, true) put(388, 114, PL.RUST[2]) put(388, 120, PL.RUST[2])
  PL.blob(rect(391, 148, 395, 158), 392, 156, 3, 3, PL.MOSS, 21)
end

-- v2.5.40 polish pass 3: lived-in orchard props (wheelbarrow, crate+sack stack, basket, windfall apples, saw on hook, bucket, woodpile)
function PL.dk(hex)
  local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format("#%02x%02x%02x", floor(r * 0.72), floor(g * 0.78), floor(b * 0.9))
end
function PL.apple3(x, y, gold)
  local a = rect(x, y, x + 2, y + 2) a:cut(rect(x, y, x, y))
  local Rp = gold and R.gold or R.apple
  obj(a, Rp, { noise = 0, rimc = Rp[1] }) put(x + 1, y + 1, Rp[5]) put(x + 2, y - 1, R.wood[2])
end
do
  -- wheelbarrow of apples (red tray, tyre, pale handles)
  PL.cast({{157, 190}, {184, 190}, {192, 194}, {164, 194}})
  apples(162, 180, 168, 7)
  obj(poly{{160, 173}, {181, 173}, {177, 183}, {164, 183}}, R.cloth, { tex = planksH(3, 6) })
  obj(rect(176, 183, 178, 190), R.wood) obj(rect(165, 183, 166, 190), R.wood)
  obj(c:line({{180, 176}, {191, 178}}, 2), R.pale, { lift = 0.1 })
  local tyre = ell(159, 187, 4, 4)
  c:rim(tyre, R.wood[1]) tyre:each(function(x, y) put(x, y, R.wood[1]) end)
  ell(159, 187, 2, 2):each(function(x, y) put(x, y, R.pale[3]) end) put(159, 187, R.stone[4]) put(158, 186, R.pale[5])
  -- crate stack and a fruit sack by the cider press
  PL.cast({{180, 168}, {200, 168}, {208, 172}, {188, 172}})
  crate(180, 156, 194, 166, 4) crate(184, 148, 193, 155, 5)
  local sack = poly{{197, 154}, {205, 154}, {207, 158}, {206, 162}, {197, 162}, {196, 158}}
  PL.cast({{198, 163}, {210, 163}, {214, 166}, {202, 166}})
  obj(sack, R.cream, { tex = function(x, y) return ((x + y) % 5 == 0) and -0.2 or 0 end })
  for x = 198, 204 do put(x, 153, "#8e6c44") end put(200, 152, "#8e6c44") put(202, 152, "#8e6c44") put(201, 154, R.cream[1])
  put(200, 158, R.apple[3]) put(201, 158, R.apple[4]) put(201, 159, R.apple[3])
  -- apple basket on the grass
  PL.cast({{156, 209}, {172, 209}, {178, 213}, {162, 213}})
  obj(c:line({{157, 202}, {160, 196}, {166, 196}, {169, 202}}, 2), R.wicker, { rim = true })
  obj(rect(155, 201, 169, 208), R.wicker, { tex = function(x, y) return (((x + y) % 4 == 0) or ((x - y) % 4 == 0)) and -0.3 or 0 end })
  apples(156, 168, 198, 8)
  PL.apple3(172, 206, false) PL.apple3(177, 208, true)
  -- windfall apples in the grass
  for _, a in ipairs({{28, 217, false}, {41, 229, true}, {74, 231, false}, {31, 249, false}, {77, 247, true}, {20, 237, false}, {119, 266, false},
      {164, 150, false}, {240, 172, true}, {300, 241, false}, {288, 205, false}, {236, 238, false}}) do
    if PL.free(a[1], a[2]) and PL.free(a[1] + 3, a[2] + 3) then PL.cast({{a[1] + 1, a[2] + 3}, {a[1] + 5, a[2] + 3}, {a[1] + 6, a[2] + 4}, {a[1] + 2, a[2] + 4}}) PL.apple3(a[1], a[2], a[3]) end
  end
  -- pruning saw on a hook at the cider press post
  obj(rect(162, 119, 167, 123), R.wood, { lift = 0.1 })
  obj(poly{{163, 124}, {167, 124}, {165, 138}, {164, 138}}, R.stone, { lift = 0.15, noise = 0.05 })
  for y = 125, 137, 2 do put(163 + floor((y - 124) * 0.12), y, R.stone[1]) end
  put(167, 121, "#d6d0d8") put(168, 121, R.stone[1]) put(164, 121, R.wood[1])
  -- water bucket with rope handle
  PL.cast({{208, 146}, {220, 146}, {224, 149}, {212, 149}})
  obj(poly{{208, 136}, {216, 136}, {215, 145}, {209, 145}}, R.barrel, { tex = planksV(3, 4) })
  for x = 208, 216 do put(x, 139, R.stone[2]) put(x, 143, R.stone[2]) end
  put(210, 136, "#a0bede") put(211, 136, "#d8e4e2") put(212, 136, "#a0bede")
  PL.rope(208, 136, 212, 131) PL.rope(212, 131, 216, 136)
  -- woodpile of pruned logs (end grain rings)
  PL.cast({{263, 135}, {284, 135}, {288, 138}, {267, 138}})
  for _, l in ipairs({{267, 131}, {273, 131}, {279, 131}, {270, 125}, {276, 125}}) do
    local lg = ell(l[1], l[2], 3, 3)
    obj(lg, R.pale, { lift = 0.1 })
    put(l[1], l[2], R.wood[2]) put(l[1] + 1, l[2], R.wood[3]) put(l[1], l[2] - 1, R.wood[3]) put(l[1] - 2, l[2] + 1, R.pale[2])
  end
  put(273, 121, R.leaf[4]) put(274, 120, R.leaf[5]) put(274, 121, R.leaf[3])
end

---------------------------------------------------------------- falling petals
for i = 1, 26 do -- a few drifting bougainvillea petals
  local x, y = 18 + floor(H(i, 7, 61) * 444), 16 + floor(H(i, 8, 61) * 230)
  if not (x >= 380 and y >= 230) then
    local s = H(i, 9, 61) > 0.5
    put(x, y, R.blossom[5]) put(x + 1, y + (s and 1 or 0), R.blossom[3])
  end
end

---------------------------------------------------------------- GATE FRAME (front): posts, beam, blossom garland, lanterns, charm
local fwood = {"#33221c", "#523828", "#714e32", "#946a42", "#c09060"} -- palm-wood beam
local lpost = rect(0, 0, 13, Hh - 1)
local rpost = rect(W - 14, 0, W - 1, Hh - 1)
obj(lpost, R.stone, { tex = function(x, y) local r = y // 9 return ((y % 9 == 0) or ((x + (r % 2) * 7) % 14 == 0)) and -0.42 or (H(x // 7, r, 2) - 0.5) * 0.25 end, ly = 0.05 })
obj(rpost, R.stone, { tex = function(x, y) local r = y // 9 return ((y % 9 == 0) or ((x + 3 + (r % 2) * 7) % 14 == 0)) and -0.42 or (H(x // 7, r, 3) - 0.5) * 0.25 end, ly = 0.05 })
local beam = rect(0, 0, W - 1, 11)
obj(beam, fwood, { tex = planksH(6, 73), lx = 0.05 })
for x = 0, W - 1 do put(x, 12, fwood[1]) end
-- corner braces
obj(poly{{14, 12}, {30, 12}, {14, 28}}, R.stone, { lift = 0.05 })
obj(poly{{W - 15, 12}, {W - 31, 12}, {W - 15, 28}}, R.stone, { lift = -0.05 })
for _, px in ipairs({6, 120, 240, 360, W - 8}) do put(px, 5, R.metal[4]) put(px + 1, 5, R.metal[2]) put(px, 6, R.metal[2]) put(px + 1, 6, R.metal[1]) end
-- blossom garland along the beam
local gar = HP.mask()
for x = 4, W - 5, 9 do
  local y = 12 + floor(3 * abs(sin(x * 0.05)))
  gar:add(ell(x, y, 5, 3))
end
gar:add(ell(8, 24, 6, 10)):add(ell(W - 9, 24, 6, 10)):add(ell(10, 40, 4, 6)):add(ell(W - 11, 40, 4, 6))
obj(gar, R.leaf, { tex = clumpT(75), ly = 0.4 })
for i = 1, 140 do
  local x, y = floor(H(i, 1, 77) * W), 6 + floor(H(i, 2, 77) * 40)
  if gar:has(x, y) and gar:has(x + 1, y + 1) then put(x, y, R.blossom[5]) put(x + 1, y, R.blossom[4]) put(x, y + 1, R.blossom[3]) put(x + 1, y + 1, R.blossom[2]) end
end
for i = 1, 16 do
  local x = 20 + floor(H(i, 3, 79) * 440)
  local y = 14 + floor(3 * abs(sin(x * 0.05)))
  if gar:has(x, y) then
    local a = rect(x, y + 2, x + 3, y + 5) a:cut(rect(x, y + 2, x, y + 2)):cut(rect(x + 3, y + 2, x + 3, y + 2))
    obj(a, R.apple, { noise = 0, rimc = R.leaf[1] }) put(x + 1, y + 3, R.apple[5])
  end
end
-- hanging lanterns
local function lantern(lx, top, len)
  for y = top, top + len do put(lx, y, ((y % 2) == 0) and R.stone[1] or R.stone[2]) end
  local y0 = top + len + 1
  obj(rect(lx - 4, y0, lx + 4, y0 + 2), R.wood)
  local body = rect(lx - 5, y0 + 3, lx + 5, y0 + 15)
  c:rim(body, R.wood[1])
  body:each(function(x, y)
    local e = (x == lx - 5 or x == lx + 5 or y == y0 + 3 or y == y0 + 15 or x == lx)
    local v = abs(x - lx) / 5 + (y - y0 - 3) / 24
    put(x, y, e and R.wood[2] or ((v < 0.4 and R.glow[5]) or (v < 0.8 and R.glow[4]) or R.glow[3]))
  end)
  obj(rect(lx - 3, y0 + 16, lx + 3, y0 + 17), R.wood)
  put(lx, y0 + 18, R.gold[4])
end
lantern(34, 13, 10) lantern(W - 35, 13, 10)
-- centre charm: wooden apple with a blossom
for y = 13, 18 do put(VX, y, R.stone[2]) end
local charm = poly{{235, 20}, {245, 20}, {248, 23}, {248, 29}, {245, 33}, {235, 33}, {232, 29}, {232, 23}}
charm:cut(rect(239, 19, 241, 21))
obj(charm, R.apple, { noise = 0.04 })
put(236, 23, R.apple[5]) put(237, 23, R.apple[5]) put(236, 24, R.apple[5])
put(239, 19, R.apple[2]) put(240, 18, R.apple[3]) put(241, 19, R.apple[2]) put(240, 17, R.apple[4])
for _, q in ipairs({{241, 27}, {243, 25}, {242, 29}}) do put(q[1], q[2], R.cream[4]) end
for x = 233, 247 do if (x % 3) == 0 then put(x, 34, (x % 2 == 0) and R.green[4] or R.gold[4]) end end

-- v2.5.40 polish pass 4b: light and depth (key light top-left, rim light, haze, warm glows, foreground frame)
function PL.mix(hex, to, t)
  local function ch(h, i) return tonumber(h:sub(i, i + 1), 16) end
  return string.format("#%02x%02x%02x", floor(ch(hex, 2) + (ch(to, 2) - ch(hex, 2)) * t + .5), floor(ch(hex, 4) + (ch(to, 4) - ch(hex, 4)) * t + .5), floor(ch(hex, 6) + (ch(to, 6) - ch(hex, 6)) * t + .5))
end
function PL.luma(h) return tonumber(h:sub(2, 3), 16) * 0.3 + tonumber(h:sub(4, 5), 16) * 0.59 + tonumber(h:sub(6, 7), 16) * 0.11 end
PL.BAYER = {{0, 8, 2, 10}, {12, 4, 14, 6}, {3, 11, 1, 9}, {15, 7, 13, 5}}
-- ordered-dither warm glow: brightens only, never over sky, never in the compass corner
function PL.glow(cx, cy, r, col, t, ry)
  ry = ry or r
  for y = floor(cy - ry), floor(cy + ry) do for x = floor(cx - r), floor(cx + r) do
    local d = sqrt(((x - cx) / r) ^ 2 + ((y - cy) / ry) ^ 2)
    if d < 1 and x >= 0 and y >= 0 and x < W and y < Hh and not (x >= 380 and y >= 230) and PL.BAYER[y % 4 + 1][x % 4 + 1] / 16 < (1 - d) * 0.95 then
      local h = c:get(x, y)
      if h then
        local rr, bb = tonumber(h:sub(2, 3), 16), tonumber(h:sub(6, 7), 16)
        if not (bb > rr + 6) or y > VY then
          local n = PL.mix(h, col, t)
          if PL.luma(n) > PL.luma(h) then put(x, y, n) end
        end
      end
    end
  end end
end
do
  -- atmospheric perspective: dithered cool mist over the far hills and orchard band
  local far = {["#e6bc8c"] = 1, ["#d0a07a"] = 1, ["#c8b07a"] = 1, ["#a8a46a"] = 1, ["#6e8a52"] = 1, ["#56704a"] = 1, ["#86a05e"] = 1, ["#7a7858"] = 1, ["#8a6e5a"] = 1, ["#7a5a44"] = 1}
  for y = 82, VY - 1 do for x = 0, W - 1 do
    local h = c:get(x, y)
    if h and far[h] and PL.BAYER[y % 4 + 1][x % 4 + 1] / 16 < ((y - 82) / 30) * 0.9 then put(x, y, PL.mix(h, "#f2dcc4", 0.4)) end
  end end
  -- rim light (warm, from the top-left) on the main silhouettes
  local function rimlight(m, top, t)
    m:each(function(x, y)
      if not m:has(x - 1, y) or (top and not m:has(x, y - 1)) then
        local h = c:get(x, y)
        if h and PL.luma(h) > 70 then put(x, y, PL.mix(h, "#fff0c0", t or 0.34)) end
      end
    end)
  end
  rimlight(roof, true) rimlight(hroof, true) rimlight(sroof, true) rimlight(canopy, true, 0.28) rimlight(board, false) rimlight(trunk, false)
  rimlight(vat, false) rimlight(blank, true, 0.2) rimlight(rect(165, 110, 207, 116), true) rimlight(rect(368, 194, 434, 200), true)
  -- warm glow from windows, lanterns, string lights, the fire and the arch lantern
  PL.glow(45, 103, 13, "#ffc870", 0.34) PL.glow(76, 103, 13, "#ffc870", 0.34) PL.glow(78, 122, 12, "#ffc870", 0.34)
  PL.glow(60, 143, 26, "#ffcf80", 0.3, 8) PL.glow(140, 120, 9, "#ffc870", 0.3)
  PL.glow(449, 212, 24, "#ffb050", 0.36, 17)
  PL.glow(426, 97, 10, "#ffd274", 0.4)
  for x = 384, 432, 8 do PL.glow(x, floor(176 + ((x - 408) ^ 2) / 160) + 2, 5, "#ffd274", 0.45) end
  -- foreground frame: dark leaf tufts at the bottom edge (outside the compass corner and the stand points)
  local function tuft(x, y, h, cols)
    for k = -3, 3 do
      local hh = h - abs(k) * 1 - floor(H(x + k, 1, 91) * 3)
      for j = 0, hh do
        local xx = x + k + floor(k * j * 0.12)
        if PL.free(xx, y - j) or (y - j) >= Hh - 6 and xx < 380 then put(xx, y - j, (j > hh - 2) and cols[3] or ((k <= 0) and cols[2] or cols[1])) end
      end
    end
  end
  local FG = {"#52503e", "#706e52", "#a9a874"}
  for _, t in ipairs({{19, 268, 7}, {30, 269, 6}, {44, 269, 5}, {120, 269, 6}, {134, 269, 5}, {300, 269, 6}, {314, 269, 7}, {360, 269, 5}}) do tuft(t[1], t[2], t[3], FG) end
  -- soft dithered vignette in the bottom-left corner
  for y = 240, Hh - 1 do for x = 14, 60 do
    local d = ((60 - x) / 46 + (y - 240) / 30) / 2
    local h = c:get(x, y)
    if h and gtype[y * W + x] and PL.BAYER[y % 4 + 1][x % 4 + 1] / 16 < d * 0.55 - 0.1 then put(x, y, PL.mix(h, "#7a4a3a", 0.35)) end
  end end
end

---------------------------------------------------------------- save
HP.assertClean(c)
c:finish{ outline = false }
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[
{"k":"do","name":"Orchard Rows","x":83,"y":205,"box":[16,146,150,264]},
{"k":"people","name":"Picnic Green","x":376,"y":203,"box":[296,176,462,230]},
{"k":"stop","name":"Stamp Post","x":334,"y":121,"box":[294,78,374,164]},
{"k":"homes","name":"Orchard Cottages","x":91,"y":95,"box":[22,40,158,142]},
{"k":"wild","name":"Wild Trail","x":424,"y":104,"box":[386,48,462,160]}],
"stand":[{"x":190,"y":244},{"x":278,"y":250},{"x":240,"y":212},{"x":214,"y":178},{"x":262,"y":150},{"x":338,"y":254}],
"compass_clear":[380,230,480,270]}]]
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write((layout:gsub("\n", ""))) f:close()
print("done " .. NAME)
