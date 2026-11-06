-- Gnome Venture "Hearth Pop" v3 : Watchtower rest stop, DESERT ADOBE look, GATE VIEW, 480x270 native
-- Geometry, layout spots, stand points and compass corner identical to here-stop-tower (same layout json);
-- only colours/ramps, sky, hills, flora, roof/wall style and quirk props differ.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-tower-desert_adobe"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin

local function hash(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function P(x, y, col) if x >= 0 and y >= 0 and x < W and y < H then c:put(floor(x), floor(y), col) end end
local function bb(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y) if x < x0 then x0 = x end if x > x1 then x1 = x end if y < y0 then y0 = y end if y > y1 then y1 = y end end)
  return x0, y0, x1, y1
end

-- ramps: 1 edge, 2 deep, 3 shade, 4 base, 5 hi
local STONE  = { "#4a2a26", "#7a4836", "#a86e56", "#cf9874", "#ecc49c" } -- adobe tower plaster
local PILLAR = { "#3e2a2c", "#6a4438", "#8e604a", "#b47e60", "#d6a47e" } -- sandstone
local WALLG  = { "#7a5048", "#a07060", "#bc8c74", "#d4a888", "#e8c8a4" } -- mud brick
local BEAM   = { "#2e1a1c", "#4a2a24", "#6a3c2c", "#8c5436", "#b07246" }
local CABIN  = { "#3e2018", "#5a3424", "#7f4a2e", "#a8653c", "#cf8a52" }
local LADDER = { "#5a3418", "#86552a", "#b07a3c", "#d9a660", "#f0c884" }
local ROOFR  = { "#4a1e1a", "#7a3424", "#a84e30", "#cc6c3e", "#ec9662" } -- terracotta
local BRASS  = { "#4a3014", "#6a4a22", "#a07030", "#d6a24a", "#f4d488" }
local IRON   = { "#1f1c2a", "#34303f", "#4a4558", "#635d74", "#857e94" }
local HONEY  = { "#5a3428", "#8a5a40", "#b88260", "#dcaa80", "#f0cca0" } -- adobe
local THATCH = { "#5a3a18", "#7a5422", "#a8782e", "#d4a444", "#efcf72" }
local LAV    = { "#6a5260", "#9a8288", "#c8b0a6", "#e8d6c2", "#f6e8d4" } -- limewash
local MOSSR  = { "#1f3628", "#2f4a36", "#476a44", "#628c52", "#8db66a" }
local TEAL   = { "#14363c", "#1f4a50", "#2e6a6e", "#3f8e8a", "#6cb8a8" }
local CORK   = { "#5a3420", "#7a4a2c", "#a0663a", "#c58a54", "#e0aa72" }
local RED    = { "#4a1420", "#6e1e28", "#a02c30", "#cc4438", "#ec7a58" }
local CLOTH  = { "#14444a", "#1e6468", "#2a8a88", "#3ab0a4", "#7ad6c4" } -- turquoise
local CREAM  = { "#8a7058", "#b49a7c", "#d8c4a2", "#f0e2c4", "#fbf2dc" }
local BARK   = { "#2a1810", "#3e2616", "#5a3820", "#7a4e2c", "#9c6a3e" }
local LEAF   = { "#2a3a2c", "#3e5238", "#5a6e44", "#7a8a52", "#a2aa6a" } -- dusty sage
local BOUG   = { "#4a1430", "#7a1e4a", "#a82a64", "#d4468a", "#f080b4" }
local CACT   = { "#1e3a30", "#2e5240", "#3e6e4c", "#56905a", "#86b474" }
local BLUEP  = { "#1e2c52", "#2c4478", "#3e60a4", "#5a84c8", "#88b0e4" }
local GL = { s = "#e8903c", b = "#f8c060", h = "#ffe6a0" }

local function paintTex(m, R, tex, o)
  o = o or {}
  local x0, y0, x1, y1 = bb(m)
  local w = max(1, x1 - x0)
  m:each(function(x, y)
    local l = tex and tex(x, y, x0, y0) or 4
    if o.dark then l = l - 1 end
    if not o.flat then
      local t = (x - x0) / w
      if o.shadeLeft then t = 1 - t end
      if t > (o.shadeAt or 0.76) then l = l - 1 end
      if t < 0.07 then l = l + 1 end
    end
    l = max(2, min(5, l))
    P(x, y, R[l])
  end)
  if o.edge ~= false then c:edgeIn(m, R[1]) end
end

local function stoneTex(bw, bh, seed)
  return function(x, y, x0, y0)
    local r = floor((y - y0) / bh)
    local off = (r % 2) * floor(bw / 2)
    local xx = x - x0 + off
    local col = floor(xx / bw)
    if (y - y0) % bh == bh - 1 or xx % bw == bw - 1 then return 2 end
    local hh = hash(col, r, seed or 7)
    local l = hh < 0.3 and 3 or (hh > 0.82 and 5 or 4)
    if (y - y0) % bh == 0 and xx % bw < bw - 2 and l < 5 then l = l + 1 end
    if hash(x, y, 3) < 0.07 then l = l - 1 end
    return l
  end
end
local function planksV(pw)
  return function(x, y, x0, y0)
    local col = floor((x - x0) / pw)
    if (x - x0) % pw == pw - 1 then return 2 end
    if (x - x0) % pw == 0 then return 5 end
    if hash(x, floor(y / 4) + col * 7, 5) < 0.14 then return 3 end
    return (col % 3 == 1) and 3 + (hash(col, 1, 2) < 0.5 and 1 or 0) or 4
  end
end
local function planksH(ph)
  return function(x, y, x0, y0)
    local row = floor((y - y0) / ph)
    if (y - y0) % ph == ph - 1 then return 2 end
    if (y - y0) % ph == 0 then return 5 end
    if hash(floor(x / 5) + row * 13, y, 6) < 0.16 then return 3 end
    return 4
  end
end
local function shingleTex(sh, sw)
  return function(x, y, x0, y0)
    local row = floor((y - y0) / sh)
    local off = (row % 2) * floor(sw / 2)
    if (y - y0) % sh == sh - 1 then return 2 end
    if (x - x0 + off) % sw == 0 then return 3 end
    if (y - y0) % sh == 0 then return 5 end
    return hash(floor((x - x0 + off) / sw), row, 9) < 0.25 and 3 or 4
  end
end
local function thatchTex(x, y, x0, y0)
  local row = floor((y - y0) / 5)
  if (y - y0) % 5 == 4 then return 3 end
  local hh = hash(x, row, 2)
  if hh < 0.28 then return 3 elseif hh > 0.8 then return 5 end
  return 4
end

local function window(x0, y0, x1, y1, frame, cross)
  local m = c:rect(x0, y0, x1, y1)
  m:each(function(x, y)
    local v = (y - y0) / max(1, y1 - y0)
    P(x, y, v < 0.35 and GL.h or (v < 0.75 and GL.b or GL.s))
  end)
  c:edgeIn(m, frame)
  if cross then
    for x = x0, x1 do P(x, floor((y0 + y1) / 2), frame) end
    for y = y0, y1 do P(floor((x0 + x1) / 2), y, frame) end
  end
  for x = x0 - 1, x1 + 1 do P(x, y1 + 1, frame) end
end

-- ===== SKY (golden late afternoon, big sky) =====
local SKYC = { "#a8849a", "#b88e92", "#c89a8c", "#d8a88a", "#e6b88e", "#eec694", "#f4d4a0", "#f8e0b0" }
c:stripes(0, 111, SKYC, { 3, 3, 3, 3, 3, 3, 3, 3 })
-- low golden sun near the vanishing point, banded disc + dithered halo
for y = 44, 92 do for x = 206, 262 do
  local d = ((x - 234) ^ 2 + (y - 68) ^ 2) ^ .5
  if d <= 9 then P(x, y, d <= 6 and "#fcefc4" or "#fae0a2")
  elseif d <= 14 and (x + y) % 2 == 0 then P(x, y, "#f6d8a4") end
end end
-- long thin haze streaks instead of clouds
for _, st in ipairs({ { 24, 30, 110 }, { 180, 22, 60 }, { 300, 34, 130 }, { 60, 50, 80 }, { 270, 52, 60 }, { 370, 62, 80 }, { 110, 72, 70 } }) do
  for x = st[1], st[1] + st[3] do P(x, st[2], "#f8e2c4") end
  for x = st[1] + 10, st[1] + st[3] - 14 do P(x, st[2] + 1, "#dcae9e") end
end

-- ===== FAR SCENERY (valley below the hilltop) =====
local function mesa(x)
  local m = 96 + 3 * sin(x / 13)
  local function block(a, b, top, sl)
    if x > a and x < b then
      local t = top
      if x < a + sl then t = top + (a + sl - x) * 2.2 end
      if x > b - sl then t = max(t, top + (x - (b - sl)) * 2.2) end
      m = min(m, t)
    end
  end
  block(150, 214, 76, 6) block(256, 330, 70, 10) block(330, 410, 80, 8) block(410, 480, 66, 9) block(0, 60, 74, 8)
  return floor(m)
end
local mz = c:terrain(mesa, "#d0a8a0", 117)
mz:each(function(x, y)
  local t = mesa(x)
  if y == t then P(x, y, "#e8c6b2") end
  if (y - t) % 6 == 3 and y > t + 2 and y < 98 then P(x, y, "#c29a96") end
end)
for x = 1, W - 1 do
  if mesa(x) - mesa(x - 1) > 1 then for y = mesa(x - 1), mesa(x) + 6 do if mz:has(x, y) then P(x, y, "#b88e8e"); P(x - 1, y, "#c09492") end end end
end
local function ridge2(x) return floor(98 + 4 * sin(x / 29 + 2) + 2 * sin(x / 11)) end
c:terrain(ridge2, "#dcb498", 117)
local function ridge3(x) return floor(105 + 3 * sin(x / 23 + 4) + 2 * sin(x / 9)) end
c:terrain(ridge3, "#e4bc90", 117)
for x = 0, W - 1 do
  P(x, ridge2(x), "#eccaa8")
  P(x, ridge3(x), "#f2d4a6")
  if ridge3(x + 1) > ridge3(x - 1) then P(x, ridge3(x) + 1, "#d2a684") end
  if hash(x, 1, 21) < 0.06 then -- tiny far saguaros
    local ty = ridge3(x)
    for k = 1, 4 do P(x, ty - k, "#8a8a6a") end
    P(x - 1, ty - 2, "#8a8a6a"); P(x - 1, ty - 3, "#8a8a6a"); P(x + 1, ty - 1, "#7a7a5c")
  end
end

-- ===== LAWN (windswept hilltop) =====
local function crest(x) return floor(112 + ((x - 240) / 240) ^ 2 * 6) end
local function lawnCol(y)
  if y < 130 then return "#f0d6a6", "#f8e4bc", "#dcb888" end
  if y < 165 then return "#ecc896", "#f6dcac", "#d4ac7a" end
  if y < 215 then return "#e6bc88", "#f2d4a0", "#cca070" end
  return "#deb07c", "#eccb94", "#c29466"
end
for x = 0, W - 1 do
  for y = crest(x), H - 1 do
    local b = lawnCol(y)
    P(x, y, b)
  end
end
for x = 0, W - 1 do
  for y = crest(x) + 1, H - 1 do
    local _, hi, sh = lawnCol(y)
    local hv = hash(x, y, 11)
    local calm = (x >= 376 and y >= 228)
    local rate = calm and 0.012 or 0.035
    if hv < rate then
      local L = y > 200 and 4 or (y > 150 and 3 or 2)
      for i = 0, L - 1 do P(x + i, y - floor(i / 2), hi) end
    elseif hv > 1 - rate * 0.6 then
      P(x, y, sh); P(x + 1, y, sh)
    end
  end
end
-- far drystone wall along the crest (gap for the road)
local function farWall(xa, xb)
  local m = c:poly{ { xa, crest(xa) - 5 }, { xb, crest(xb) - 5 }, { xb, crest(xb) }, { xa, crest(xa) } }
  paintTex(m, WALLG, stoneTex(6, 3, 4), { flat = true })
end
farWall(20, 202)
farWall(280, 460)

-- ===== ROAD (flagstones, one-point to 240,112) =====
local function hw(y) return 3 + (y - 113) / 156 * 90 end
local function isPath(x, y) return y >= 113 and abs(x - 240) <= hw(y) end
local function prow(y) return floor(15 * ((y - 113) / 156) ^ 0.62) end
local function pcol(x, y) local u = (x - 240) / hw(y); return floor((u + 1) * 3 + (prow(y) % 2) * 0.5) end
local STONES = { "#c49478", "#d0a284", "#b8886c", "#dcb090", "#c89a7c" }
local pathMask = c:poly{ { 237, 113 }, { 243, 113 }, { 333, 269 }, { 147, 269 } }
pathMask:each(function(x, y)
  local r, j = prow(y), pcol(x, y)
  local col
  if prow(y + 1) ~= r or pcol(x + 1, y) ~= j then col = "#86584a"
  elseif prow(y - 1) ~= r or pcol(x - 1, y) ~= j then col = "#e8c4a0"
  else
    col = STONES[1 + floor(hash(r, j, 13) * 5)]
    if (x - 240) / hw(y) > 0.55 and hash(x, y, 4) < 0.5 then col = "#ae806a" end
    if hash(x, y, 17) < 0.03 then col = "#9e7460" end
    if hash(x, y, 18) < 0.05 and (x - 240) / hw(y) < -0.3 then col = "#e8c494" end -- drifted sand
  end
  P(x, y, col)
end)
c:edgeIn(pathMask, "#74503f")
-- grass tufts nibbling the road edges
for y = 140, 268, 7 do
  local h = hw(y)
  for _, s in ipairs({ -1, 1 }) do
    local x = floor(240 + s * h)
    local _, hi, sh = lawnCol(y)
    P(x, y, sh); P(x, y - 1, hi); P(x - s, y, sh); P(x - s, y - 1, hi); P(x - s, y - 2, hi)
  end
end

-- trail branching right to the wild gap
local trail = c:poly{ { 268, 168 }, { 276, 182 }, { 404, 214 }, { 462, 214 }, { 462, 201 }, { 404, 200 } }
trail:each(function(x, y)
  if isPath(x, y) then return end
  local col = "#c48a62"
  local hv = hash(x, y, 31)
  if hv < 0.08 then col = "#a06a48" elseif hv > 0.93 then col = "#dca878" end
  P(x, y, col)
end)
trail:edge():each(function(x, y) if not isPath(x, y) then P(x, y, "#8a5a40") end end)

-- lawn / road cast shadow helper (to lower right)
local function shadow(pts)
  local m = c:poly(pts)
  m:each(function(x, y)
    if isPath(x, y) then P(x, y, "#a07a68")
    else P(x, y, y < 165 and "#c69a88" or "#b88a78") end
  end)
end

-- ===== HOMES (far right tier) =====
shadow{ { 296, 128 }, { 358, 132 }, { 372, 136 }, { 300, 134 } }
shadow{ { 380, 129 }, { 442, 132 }, { 456, 136 }, { 384, 135 } }
-- Home A: stone cottage, thatch roof
do
  local plaster = function(x, y) local hv = hash(x, y, 47); return hv < 0.06 and 3 or (hv > 0.95 and 5 or 4) end
  local side = c:poly{ { 296, 96 }, { 308, 92 }, { 308, 132 }, { 296, 129 } }
  paintTex(side, HONEY, plaster, { dark = true, flat = true })
  local front = c:rect(308, 92, 358, 132)
  paintTex(front, HONEY, plaster)
  -- second storey block, set back, with a stepped parapet
  local up = c:poly{ { 316, 80 }, { 322, 80 }, { 322, 77 }, { 334, 77 }, { 334, 80 }, { 348, 80 }, { 348, 92 }, { 316, 92 } }
  paintTex(up, HONEY, plaster)
  for x = 317, 347 do P(x, (x >= 323 and x <= 333) and 78 or 81, HONEY[5]) end
  for x = 309, 357 do P(x, 93, HONEY[5]) end
  -- vigas (beam ends) with short cool shadows
  for vx = 312, 352, 9 do c:fillMask(c:rect(vx, 96, vx + 2, 97), BEAM[4]); P(vx, 96, BEAM[5]); P(vx + 2, 97, BEAM[2]); P(vx + 1, 98, HONEY[3]); P(vx + 2, 98, HONEY[3]) end
  for vx = 320, 344, 8 do c:fillMask(c:rect(vx, 83, vx + 1, 84), BEAM[4]); P(vx, 83, BEAM[5]); P(vx + 1, 85, HONEY[3]) end
  -- mud-brick showing where the plaster has fallen away
  for _, b in ipairs({ { 340, 118, 12, 8 }, { 312, 100, 8, 5 } }) do
    for y = b[2], b[2] + b[4] do for x = b[1], b[1] + b[3] do
      local d = ((x - b[1] - b[3] / 2) / (b[3] / 2)) ^ 2 + ((y - b[2] - b[4] / 2) / (b[4] / 2)) ^ 2
      if d < 1 - 0.3 * hash(x, y, 48) then P(x, y, (((y - b[2]) % 3 == 2) or ((x + floor((y - b[2]) / 3) * 3) % 7 == 0)) and HONEY[2] or HONEY[3]) end
    end end
  end
  window(326, 84, 336, 90, HONEY[1], true)
  -- kiva chimney with a terracotta pot cap (quirk)
  local ch = c:poly{ { 340, 80 }, { 340, 72 }, { 342, 70 }, { 347, 70 }, { 349, 72 }, { 349, 80 } }
  paintTex(ch, HONEY, plaster)
  local cap = c:poly{ { 339, 70 }, { 341, 65 }, { 344, 64 }, { 348, 65 }, { 350, 70 } }
  paintTex(cap, ROOFR, function(x, y) return (y == 67) and 3 or 4 end)
  P(342, 66, ROOFR[5]); P(343, 65, ROOFR[5])
  -- smoke drifting right with the wind
  for i, p in ipairs({ { 352, 58, 3 }, { 359, 53, 4 }, { 368, 49, 4 } }) do
    local m = c:rect(p[1], p[2], p[1] + p[3], p[2] + p[3] - 1)
    c:fillMask(m, "#f2e2d4"); for x = p[1], p[1] + p[3] do P(x, p[2] + p[3] - 1, "#d4b4ae") end
  end
  window(316, 106, 330, 117, HONEY[1], true)
  local door = c:rect(338, 110, 350, 132)
  paintTex(door, TEAL, planksV(3))
  P(347, 121, BRASS[5]); P(347, 122, BRASS[3])
  -- boot planter (quirk)
  local boot = c:poly{ { 359, 122 }, { 364, 122 }, { 364, 129 }, { 368, 129 }, { 368, 132 }, { 359, 132 } }
  paintTex(boot, CORK, nil)
  c:fillMask(c:ellipse(362, 118, 3, 4), CACT[4]); for y = 115, 121 do P(361, y, CACT[3]); P(363, y, CACT[3]) end
  P(361, 115, CACT[5]); P(360, 117, CACT[5]); c:edgeIn(c:ellipse(362, 118, 3, 4), CACT[1])
  P(361, 113, "#e8608c"); P(362, 113, "#f6c45a"); P(363, 113, "#e8608c")
end
-- Home B: painted lavender board hut, mossy shingle roof
do
  local plaster = function(x, y) local hv = hash(x, y, 57); return hv < 0.05 and 3 or (hv > 0.96 and 5 or 4) end
  local side = c:poly{ { 380, 100 }, { 388, 96 }, { 388, 132 }, { 380, 129 } }
  paintTex(side, LAV, plaster, { dark = true, flat = true })
  local front = c:rect(388, 96, 444, 132)
  paintTex(front, LAV, plaster)
  -- rounded parapet corners + turquoise band
  P(388, 96, LAV[1]); P(444, 96, LAV[1])
  for x = 389, 443 do P(x, 97, LAV[5]); P(x, 101, CLOTH[3]); P(x, 102, CLOTH[2]) end
  -- turquoise tiled dome on a drum, brass finial
  local drum = c:rect(400, 88, 428, 96); paintTex(drum, LAV, plaster)
  for x = 401, 427 do P(x, 89, LAV[5]) end
  local dome = c:ellipse(414, 88, 16, 13):clip(c:rect(396, 70, 432, 88))
  paintTex(dome, CLOTH, function(x, y)
    if (y - 76) % 4 == 0 then return 3 end
    if (x - 414 + (floor((y - 76) / 4) % 2) * 2) % 5 == 0 then return 3 end
    return ((x - 414) + (y - 88) < -12) and 5 or 4 end)
  for x = 404, 410 do P(x, 78, CLOTH[5]) end
  c:fillMask(c:rect(413, 70, 414, 75), BRASS[3]); P(413, 70, BRASS[5]); c:fillMask(c:ellipse(413, 70, 1, 1), BRASS[4]); P(413, 68, BRASS[5])
  for _, wx in ipairs({ 405, 413, 421 }) do c:fillMask(c:rect(wx, 91, wx + 2, 94), GL.b); P(wx + 1, 91, GL.h) end
  window(395, 108, 407, 118, TEAL[2], true)
  local door = c:rect(418, 112, 430, 132)
  paintTex(door, RED, planksV(3))
  P(420, 122, BRASS[5])
  -- line of tiny socks under the eave (quirk)
  for x = 389, 443 do P(x, 104, CREAM[2]) end
  local sc = { RED[4], "#f8c060", CLOTH[4], "#e8608c", BLUEP[4] }
  for i = 0, 4 do
    local sx = 391 + i * 10
    local m = c:poly{ { sx, 105 }, { sx + 3, 105 }, { sx + 3, 109 }, { sx + 5, 109 }, { sx + 5, 111 }, { sx, 111 } }
    c:fillMask(m, sc[i + 1]); P(sx, 105, CREAM[4]); P(sx + 1, 105, CREAM[4])
  end
end

-- ===== WATCHTOWER (k=do, far-left hero) =====
shadow{ { 142, 176 }, { 152, 174 }, { 196, 186 }, { 186, 192 }, { 140, 186 } }
do
  -- stone shaft front + side face toward the vanishing point
  local side = c:poly{ { 138, 64 }, { 150, 70 }, { 154, 175 }, { 142, 182 } }
  paintTex(side, STONE, stoneTex(7, 7, 12), { dark = true, flat = true })
  local front = c:poly{ { 86, 64 }, { 138, 64 }, { 142, 182 }, { 82, 182 } }
  paintTex(front, STONE, stoneTex(10, 7, 2))
  -- moss at the foot
  front:each(function(x, y) if y > 170 and hash(x, y, 51) < (y - 170) / 18 then P(x, y, hash(x, y, 52) < 0.5 and "#e6bc88" or "#f2d4a0") end end)
  -- arched (pointed) door
  local door = c:poly{ { 96, 152 }, { 105, 143 }, { 114, 152 }, { 114, 182 }, { 96, 182 } }
  paintTex(door, CABIN, planksV(3))
  for x = 97, 113 do P(x, 160, IRON[3]); P(x, 172, IRON[3]) end
  P(111, 166, BRASS[5]); P(111, 167, BRASS[3])
  local step = c:rect(92, 182, 118, 184)
  paintTex(step, STONE, nil, { flat = true })
  -- glowing slit windows
  window(91, 96, 96, 112, STONE[1], false)
  window(108, 82, 113, 98, STONE[1], false)
  -- glow spill on the stone under the slits
  for x = 91, 96 do P(x, 114, "#d6b090") end
  -- deck + struts
  c:fillMask(c:line({ { 88, 76 }, { 74, 61 } }, 3), BEAM[3]); c:fillMask(c:line({ { 136, 76 }, { 154, 61 } }, 3), BEAM[3])
  c:edgeIn(c:line({ { 88, 76 }, { 74, 61 } }, 3), BEAM[1]); c:edgeIn(c:line({ { 136, 76 }, { 154, 61 } }, 3), BEAM[1])
  local deck = c:rect(68, 54, 160, 62)
  paintTex(deck, BEAM, planksH(3))
  -- cabin
  local cside = c:poly{ { 134, 34 }, { 142, 37 }, { 142, 54 }, { 134, 54 } }
  paintTex(cside, CABIN, planksV(3), { dark = true, flat = true })
  local cab = c:rect(88, 34, 134, 54)
  paintTex(cab, CABIN, planksV(4))
  window(98, 38, 122, 48, CABIN[1], true)
  -- roof
  local roof = c:ellipse(112, 36, 33, 18):clip(c:rect(78, 17, 146, 36))
  paintTex(roof, ROOFR, function(x, y)
    if (y - 18) % 4 == 3 then return 3 end
    if (x - 112 + (floor((y - 18) / 4) % 2) * 3) % 6 == 0 then return 3 end
    return ((x - 112) * 0.7 + (y - 36) < -14) and 5 or 4 end)
  for x = 80, 144 do P(x, 36, ROOFR[2]) end
  c:fillMask(c:rect(111, 12, 112, 18), BRASS[3]); c:fillMask(c:ellipse(111, 12, 1, 1), BRASS[4]); P(111, 10, BRASS[5]); P(110, 12, BRASS[5])
  for _, tx in ipairs({ 90, 104, 118, 132 }) do P(tx, 34, CLOTH[4]); P(tx + 1, 34, CLOTH[4]); P(tx, 35, CLOTH[2]); P(tx + 1, 35, CLOTH[2]) end
  -- railing
  for x = 70, 158, 11 do local p = c:rect(x, 42, x + 1, 54); c:fillMask(p, LADDER[3]); P(x, 42, LADDER[5]) end
  local rail = c:rect(68, 42, 160, 43); paintTex(rail, LADDER, nil, { flat = true, edge = false })
  for x = 68, 160 do P(x, 48, LADDER[3]); P(x, 44, LADDER[2]) end
  -- beacon bowl on a post (left corner) with fire
  local bp = c:rect(71, 34, 74, 42); paintTex(bp, IRON, nil)
  local bowl = c:poly{ { 62, 27 }, { 84, 27 }, { 80, 35 }, { 66, 35 } }
  paintTex(bowl, IRON, function(x, y) return ((x + y) % 4 == 0) and 3 or 4 end)
  for x = 62, 84 do P(x, 27, IRON[5]) end
  local f1 = c:poly{ { 64, 26 }, { 66, 17 }, { 69, 22 }, { 72, 14 }, { 75, 21 }, { 78, 16 }, { 82, 26 } }
  c:fillMask(f1, "#e8622c")
  local f2 = c:poly{ { 67, 26 }, { 69, 20 }, { 72, 24 }, { 74, 18 }, { 77, 26 } }
  c:fillMask(f2, "#f6a43a")
  c:fillMask(c:poly{ { 70, 26 }, { 72, 22 }, { 74, 26 } }, "#ffe08a")
  P(70, 12, "#f6a43a"); P(77, 13, "#e8622c"); P(74, 10, "#f8c060")
  -- flag pole + signal flag
  local pole = c:rect(156, 16, 157, 54); c:fillMask(pole, BEAM[2]); for y = 16, 54 do P(156, y, BEAM[4]) end
  P(156, 15, BRASS[5]); P(157, 15, BRASS[4])
  local flag = c:poly{ { 158, 17 }, { 170, 19 }, { 184, 17 }, { 180, 23 }, { 186, 29 }, { 170, 28 }, { 158, 30 } }
  paintTex(flag, RED, function(x, y) return (y >= 22 and y <= 24) and 5 or 4 end)
  -- quirk: a kite tangled on the pole
  local kite = c:poly{ { 160, 38 }, { 166, 32 }, { 172, 38 }, { 166, 46 } }
  paintTex(kite, BLUEP, function(x, y) return (x < 166) == (y < 38) and 5 or 4 end)
  for i, p in ipairs({ { 166, 47 }, { 167, 49 }, { 166, 51 }, { 168, 53 }, { 169, 55 }, { 171, 56 } }) do P(p[1], p[2], (i % 2 == 0) and "#f8c060" or RED[4]) end
  -- ladder leaning on the front
  local rl = c:line({ { 120, 184 }, { 125, 58 } }, 2)
  local rr = c:line({ { 133, 184 }, { 138, 58 } }, 2)
  for y = 64, 180, 9 do
    local t = (184 - y) / 126
    local xl, xr = floor(120 + 5 * t), floor(133 + 5 * t)
    local r = c:rect(xl + 1, y, xr, y + 1); c:fillMask(r, LADDER[4]); for x = xl + 1, xr do P(x, y + 1, LADDER[2]) end
  end
  paintTex(rl, LADDER, nil, { flat = true }); paintTex(rr, LADDER, nil, { flat = true })
  -- telescope on a tripod post, with a knitted cap (quirk)
  c:fillMask(c:line({ { 168, 160 }, { 158, 182 } }, 2), BEAM[3])
  c:fillMask(c:line({ { 168, 160 }, { 179, 182 } }, 2), BEAM[3])
  local post = c:rect(166, 146, 170, 182); paintTex(post, BEAM, planksV(5))
  local tube = c:line({ { 152, 150 }, { 180, 136 } }, 6)
  paintTex(tube, BRASS, function(x, y) return (x % 9 == 0) and 3 or 4 end)
  local eye = c:line({ { 146, 154 }, { 153, 150 } }, 3); paintTex(eye, BRASS, nil, { flat = true })
  local capm = c:poly{ { 178, 131 }, { 186, 128 }, { 188, 137 }, { 182, 141 } }
  paintTex(capm, CLOTH, function(x, y) return ((x + y) % 4 < 2) and 5 or 4 end)
  c:fillMask(c:rect(186, 125, 188, 127), CREAM[5])
  local mnt = c:rect(164, 142, 172, 146); paintTex(mnt, IRON, nil)
end

-- ===== WILD TRAIL (right edge) =====
do
  local function clump(cx, cy, rx, ry, R, s)
    for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
      local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if d < 1 - 0.35 * hash(x, y, s) then
        local l = 4
        if (x - cx) + (y - cy) > rx * 0.4 then l = 3 end
        if (x - cx) + (y - cy) < -rx * 0.7 then l = 5 end
        if hash(x, y, s + 1) < 0.12 then l = l - 1 end
        if d > 0.8 then l = 2 end
        P(x, y, R[max(2, l)])
      end
    end end
  end
  -- dim wild beyond the gap
  local back = c:rect(404, 160, 461, 214); c:fillMask(back, "#8a4a3e")
  back:each(function(x, y)
    if (y + floor(2 * sin(x / 6))) % 7 == 0 then P(x, y, "#a85e48")
    elseif hash(x, y, 61) < 0.12 then P(x, y, "#74403a") end
  end)
  clump(414, 176, 12, 10, LEAF, 70); clump(452, 172, 12, 12, LEAF, 71)
  -- saguaro in the gap
  local sg = c:rect(428, 156, 435, 204):add(c:rect(420, 172, 423, 186)):add(c:rect(420, 184, 430, 187)):add(c:rect(440, 164, 443, 180)):add(c:rect(434, 178, 443, 181))
  paintTex(sg, CACT, function(x, y) return (x % 3 == 0) and 3 or 4 end)
  for y = 158, 202, 4 do P(431, y, CACT[5]) end
  P(430, 155, "#e8608c"); P(432, 155, "#f6c45a"); P(441, 163, "#e8608c")
  -- agave rosettes
  for _, a in ipairs({ { 446, 200 }, { 412, 198 } }) do
    for k = -3, 3 do for j = 0, 7 - abs(k) do P(a[1] + k * j // 2 + k, a[2] - j + abs(k), (j % 3 == 0) and CACT[5] or LEAF[4]) end end
  end
  -- trail continuing into the wild
  local tr = c:poly{ { 404, 200 }, { 461, 198 }, { 461, 214 }, { 404, 214 } }
  tr:each(function(x, y) P(x, y, (x > 440) and "#a06a48" or "#c48a62") end)
  -- low drystone wall stubs
  local w1 = c:rect(390, 194, 401, 214); paintTex(w1, WALLG, stoneTex(6, 4, 9))
  -- stone gate posts
  local pl = c:rect(400, 170, 410, 216); paintTex(pl, PILLAR, stoneTex(6, 6, 14))
  local pr = c:rect(450, 170, 460, 216); paintTex(pr, PILLAR, stoneTex(6, 6, 15))
  for x = 400, 410 do if hash(x, 1, 81) < 0.6 then P(x, 170, CLOTH[4]) end end
  -- twig arch with leaves, flowers and a hanging twig-star charm
  local arch = c:line({ { 405, 171 }, { 410, 158 }, { 422, 150 }, { 438, 150 }, { 450, 158 }, { 455, 171 } }, 5)
  paintTex(arch, BARK, function(x, y) return hash(x, y, 90) < 0.3 and 3 or 4 end, { flat = true })
  clump(412, 156, 6, 4, BOUG, 91); clump(446, 154, 7, 4, BOUG, 92); clump(428, 149, 6, 3, BOUG, 93)
  for _, p in ipairs({ { 411, 154 }, { 445, 153 }, { 429, 148 }, { 449, 157 } }) do P(p[1], p[2], LEAF[4]); P(p[1] + 1, p[2], LEAF[5]) end
  for y = 153, 160 do P(430, y, CREAM[2]) end
  local star = c:poly{ { 430, 160 }, { 432, 164 }, { 436, 165 }, { 432, 167 }, { 430, 171 }, { 428, 167 }, { 424, 165 }, { 428, 164 } }
  paintTex(star, BRASS, nil, { flat = true })
  -- signpost with a right arrow + leaf icon
  local sp = c:rect(391, 180, 394, 220); paintTex(sp, BEAM, planksV(4))
  local arrow = c:poly{ { 386, 182 }, { 416, 182 }, { 423, 189 }, { 416, 196 }, { 386, 196 } }
  paintTex(arrow, LADDER, planksH(4))
  local leaf = c:poly{ { 394, 189 }, { 400, 185 }, { 408, 186 }, { 403, 192 }, { 396, 192 } }
  paintTex(leaf, CLOTH, nil, { flat = true })
  for x = 397, 405 do P(x, 189, CLOTH[2]) end
  -- ferns at the post feet
  for i = 0, 12 do local x = 402 + i * 4; P(x, 215, "#a87e6a"); P(x + 1, 214, "#c8a08a"); if i % 3 == 0 then P(x, 213, LEAF[4]); P(x, 212, LEAF[5]) end end
end

-- ===== STOP: notice board + stamp post (near right) =====
shadow{ { 346, 250 }, { 378, 250 }, { 384, 258 }, { 350, 258 } }
do
  local p1 = c:rect(293, 210, 297, 254); paintTex(p1, BEAM, planksV(5))
  local p2 = c:rect(341, 210, 345, 254); paintTex(p2, BEAM, planksV(5))
  local frame = c:rect(288, 214, 350, 242); paintTex(frame, BEAM, planksH(4))
  local cork = c:rect(292, 218, 346, 238)
  paintTex(cork, CORK, function(x, y) return hash(x, y, 33) < 0.18 and 3 or (hash(x, y, 34) > 0.92 and 5 or 4) end, { flat = true })
  -- pinned map
  local map = c:rect(295, 220, 310, 234); paintTex(map, CREAM, nil, { flat = true })
  for _, p in ipairs({ { 297, 230 }, { 299, 228 }, { 301, 229 }, { 303, 226 }, { 305, 224 }, { 307, 225 } }) do P(p[1], p[2], CLOTH[2]) end
  for x = 296, 309 do if x % 3 == 0 then P(x, 232, BLUEP[3]) end end
  P(306, 223, RED[4]); P(307, 224, RED[4]); P(305, 224, RED[4])
  P(302, 220, RED[3])
  -- poster with a star icon
  local pos = c:rect(314, 220, 326, 236); paintTex(pos, BLUEP, nil, { flat = true })
  local st = c:poly{ { 320, 223 }, { 322, 227 }, { 325, 228 }, { 322, 230 }, { 323, 233 }, { 320, 231 }, { 317, 233 }, { 318, 230 }, { 315, 228 }, { 318, 227 } }
  c:fillMask(st, "#f8c060")
  P(320, 220, "#f8c060")
  -- big postage stamp (serrated)
  local stamp = c:rect(330, 221, 343, 234)
  stamp:each(function(x, y)
    local edge = x == 330 or x == 343 or y == 221 or y == 234
    if edge and (x + y) % 2 == 0 then return end
    P(x, y, edge and CREAM[3] or CREAM[4])
  end)
  local sq = c:rect(333, 224, 340, 231); paintTex(sq, RED, nil, { flat = true })
  P(335, 226, "#f8c060"); P(336, 227, "#f8c060"); P(337, 226, "#f8c060")
  -- gable roof
  local roof = c:poly{ { 284, 216 }, { 319, 199 }, { 354, 216 } }
  paintTex(roof, TEAL, shingleTex(4, 6))
  -- stamp post (red box with a giant rubber stamp on top)
  local sp = c:rect(362, 230, 368, 254); paintTex(sp, BEAM, planksV(4))
  local box = c:rect(356, 216, 374, 232); paintTex(box, RED, planksH(4))
  local slot = c:rect(360, 222, 370, 223); c:fillMask(slot, RED[1])
  local base = c:rect(359, 211, 371, 215); paintTex(base, CREAM, nil, { flat = true })
  local stem = c:rect(363, 204, 367, 210); paintTex(stem, CABIN, nil)
  local knob = c:poly{ { 361, 204 }, { 363, 199 }, { 367, 199 }, { 369, 204 } }
  paintTex(knob, BRASS, nil)
  local ink = c:rect(359, 215, 371, 215); c:fillMask(ink, BLUEP[3])
end

-- ===== PEOPLE: canopy table + hearth (near left) =====
shadow{ { 60, 252 }, { 140, 252 }, { 150, 262 }, { 68, 262 } }
do
  -- hearth (square stone fire box) with a teapot on top (quirk)
  local hb = c:rect(26, 224, 60, 252); paintTex(hb, STONE, stoneTex(8, 6, 21))
  local mouth = c:rect(33, 233, 53, 247); c:fillMask(mouth, "#3a2028")
  c:fillMask(c:poly{ { 35, 247 }, { 38, 238 }, { 41, 242 }, { 44, 235 }, { 47, 241 }, { 50, 237 }, { 52, 247 } }, "#e8622c")
  c:fillMask(c:poly{ { 38, 247 }, { 41, 241 }, { 44, 238 }, { 47, 243 }, { 49, 247 } }, "#f6a43a")
  c:fillMask(c:poly{ { 41, 247 }, { 44, 242 }, { 47, 247 } }, "#ffe08a")
  c:edgeIn(mouth, STONE[1])
  local slab = c:rect(23, 219, 63, 224); paintTex(slab, STONE, planksH(6))
  local pot = c:poly{ { 36, 218 }, { 35, 211 }, { 38, 207 }, { 48, 207 }, { 51, 211 }, { 50, 218 } }
  paintTex(pot, BLUEP, nil)
  local spout = c:line({ { 51, 213 }, { 57, 208 } }, 2); paintTex(spout, BLUEP, nil, { flat = true })
  local lid = c:rect(40, 204, 46, 206); paintTex(lid, BLUEP, nil, { flat = true })
  P(43, 203, BRASS[5]); P(43, 202, BRASS[4])
  c:fillMask(c:line({ { 35, 210 }, { 31, 213 }, { 35, 216 } }, 1), BLUEP[2])
  P(39, 210, CREAM[5]); P(40, 209, CREAM[5])
  for i, p in ipairs({ { 58, 205 }, { 59, 203 }, { 58, 201 }, { 59, 199 }, { 61, 198 } }) do P(p[1], p[2], "#e6e0ec") end
  -- warm glow on the ground in front of the fire
  for y = 253, 262 do for x = 30, 58 do if hash(x, y, 41) < 0.35 then P(x, y, "#f8d29c") end end end
  -- canopy posts
  local cp1 = c:rect(68, 200, 71, 252); paintTex(cp1, BEAM, planksV(5))
  local cp2 = c:rect(132, 200, 135, 252); paintTex(cp2, BEAM, planksV(5))
  -- bench behind, table, bench in front
  local bb1 = c:rect(78, 216, 128, 219); paintTex(bb1, LADDER, planksH(4))
  local top = c:poly{ { 76, 222 }, { 128, 222 }, { 132, 232 }, { 72, 232 } }
  paintTex(top, CABIN, function(x, y) return (x % 9 == 0) and 3 or ((y == 222) and 5 or 4) end)
  for _, lx in ipairs({ 78, 124 }) do local l = c:rect(lx, 233, lx + 3, 246); paintTex(l, CABIN, nil) end
  -- things on the table: mugs, a pie, a lantern
  for i, col in ipairs({ RED, BLUEP, CLOTH }) do
    local mx = 80 + (i - 1) * 9
    local mug = c:rect(mx, 214, mx + 4, 221); paintTex(mug, col, nil, { flat = true })
    P(mx + 5, 216, col[1]); P(mx + 6, 217, col[1]); P(mx + 5, 218, col[1]); P(mx + 1, 215, col[5])
  end
  local pie = c:poly{ { 108, 221 }, { 110, 216 }, { 122, 216 }, { 124, 221 } }
  paintTex(pie, THATCH, function(x, y) return ((x + y) % 5 == 0) and 3 or 4 end)
  P(114, 214, "#ece4ee"); P(115, 212, "#ece4ee"); P(116, 210, "#ece4ee")
  local fb = c:rect(70, 238, 134, 242); paintTex(fb, LADDER, planksH(5))
  for _, lx in ipairs({ 74, 128 }) do local l = c:rect(lx, 243, lx + 2, 252); paintTex(l, LADDER, nil) end
  -- striped canopy (green and cream)
  local can = c:poly{ { 60, 194 }, { 142, 194 }, { 146, 206 }, { 56, 206 } }
  can:each(function(x, y)
    local band = floor((x - 56) / 9) % 2
    local R = band == 0 and CLOTH or CREAM
    local l = (y < 197) and 5 or 4
    if x > 128 then l = l - 1 end
    P(x, y, R[l])
  end)
  c:edgeIn(can, CLOTH[1])
  for x = 56, 146 do if floor((x - 56) / 4) % 2 == 0 then P(x, 207, floor((x - 56) / 9) % 2 == 0 and CLOTH[3] or CREAM[3]) end end
  -- sock windsock on the canopy corner (quirk)
  local pole = c:rect(141, 186, 142, 195); c:fillMask(pole, BEAM[2])
  local sock = c:poly{ { 143, 186 }, { 158, 188 }, { 158, 192 }, { 162, 192 }, { 162, 195 }, { 154, 195 }, { 143, 191 } }
  sock:each(function(x, y) P(x, y, (floor((x - 143) / 3) % 2 == 0) and RED[4] or CREAM[4]) end)
  c:edgeIn(sock, RED[1])
end

-- ===== v2.5.40 polish ===== helpers + pass 1 (ground variety)
local LAWNSET = {}
for _, yy in ipairs({ 120, 150, 200, 230 }) do for _, v in ipairs({ lawnCol(yy) }) do LAWNSET[v] = true end end
local STANDS = { { 190, 252 }, { 250, 250 }, { 220, 204 }, { 240, 165 }, { 170, 214 }, { 320, 166 } }
local function okG(x, y, pad)
  pad = pad or 15
  if x < 0 or y < 0 or x >= W or y >= H then return false end
  if x >= 378 and y >= 228 then return false end
  for _, s in ipairs(STANDS) do if abs(x - s[1]) < pad and abs(y - s[2]) < pad then return false end end
  return true
end
local function onLawn(x, y)
  local v = c:get(floor(x), floor(y))
  return v and LAWNSET[v] and okG(x, y)
end
local function LP(x, y, col) if onLawn(x, y) then P(x, y, col) end end
-- dithered tonal patches on the lawn (sun-warm and shade-cool)
local function patch(cx, cy, rx, ry, col, s, dense)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
    if d < 1 and y > crest(x) + 2 then
      local keep = (d < 0.45 and (x + y) % 2 == 0) or (d >= 0.45 and (x % 2 == 0 and y % 2 == 0)) or (dense and d < 0.2)
      if keep and hash(x, y, s) < 0.9 then LP(x, y, col) end
    end
  end end
end
for i = 0, 22 do
  local cx = floor(hash(i, 1, 201) * 470) + 5
  local cy = 122 + floor(hash(i, 2, 201) * 142)
  local rx, ry = 12 + floor(hash(i, 3, 201) * 16), 4 + floor(hash(i, 4, 201) * 6)
  if i % 3 == 0 then patch(cx, cy, rx, ry, "#f8e4b8", 210 + i) -- sun
  elseif i % 3 == 1 then patch(cx, cy, rx, ry, "#cfa284", 210 + i) -- cool shade
  else patch(cx, cy, rx, ry, "#d8ac7c", 210 + i) end
end
-- worn dirt tracks from the road to each stop
local function track(pts, w, seed)
  local m = c:line(pts, w)
  m:each(function(x, y)
    if onLawn(x, y) then
      local hv = hash(x, y, seed)
      P(x, y, hv < 0.12 and "#a8744e" or (hv > 0.9 and "#dcae80" or "#c69468"))
    end
  end)
  m:shrink(0):edge():each(function(x, y) if onLawn(x, y) and hash(x, y, seed + 1) < 0.55 then P(x, y, "#b88c66") end end)
end
track({ { 166, 238 }, { 156, 241 }, { 144, 240 }, { 138, 243 } }, 4, 230)
track({ { 197, 194 }, { 178, 191 }, { 160, 193 }, { 140, 189 }, { 122, 190 } }, 3, 232)
track({ { 313, 232 }, { 304, 236 }, { 294, 238 }, { 284, 244 } }, 4, 234)
-- flowers: five kinds, clustered
local FL = { { "#e8608c", "#f6c45a" }, { "#f6d860", "#d68a20" }, { "#e8602c", "#ff9a5a" }, { "#d6509c", "#f48cc4" }, { "#f6c45a", "#e8903c" } }
for i = 0, 40 do
  local cx = floor(hash(i, 5, 220) * 460) + 10
  local cy = 120 + floor(hash(i, 6, 220) * 146)
  local f = FL[1 + i % 5]
  for k = 0, 3 do
    local x, y = cx + floor(hash(i, k, 221) * 9) - 4, cy + floor(hash(i, k, 222) * 5) - 2
    if onLawn(x, y) and onLawn(x, y + 1) then P(x, y, f[1]); P(x, y - 1, f[1]); P(x, y + 1, "#7a7858"); if k % 2 == 0 then P(x + 1, y, f[2]) end end
  end
end
-- pebbles and fallen golden leaves
for i = 0, 50 do
  local x, y = floor(hash(i, 7, 230) * 470) + 4, 118 + floor(hash(i, 8, 230) * 150)
  if onLawn(x, y) and onLawn(x + 2, y + 1) then
    if i % 2 == 0 then P(x, y, "#b4a8a0"); P(x + 1, y, "#9a8c8a"); P(x, y + 1, "#7d6e72"); P(x + 1, y + 1, "#7d6e72"); P(x, y - 1, "#d8cdc0")
    else P(x, y, "#a87e6a"); P(x + 1, y, "#8c6050"); P(x - 1, y, "#c8a08a") end
  end
end
-- scattered leaves and pebbles on the road itself
for i = 0, 26 do
  local y = 130 + floor(hash(i, 9, 240) * 138)
  local x = floor(240 + (hash(i, 10, 240) * 2 - 1) * hw(y) * 0.9)
  if okG(x, y, 15) and isPath(x, y) then
    if i % 2 == 0 then P(x, y, "#ecc894"); P(x + 1, y, "#e2b884") else P(x, y, "#a8957c"); P(x + 1, y, "#8c7560") end
  end
end
-- dandelion tufts and clover along the road shoulders
for y = 150, 266, 5 do
  for _, s in ipairs({ -1, 1 }) do
    local x = floor(240 + s * (hw(y) + 3 + hash(y, s, 250) * 6))
    if onLawn(x, y) then P(x, y, "#7a7858"); P(x + 1, y, "#8c8a62"); P(x, y - 1, "#a9a874") ; if hash(y, s, 251) < 0.4 then P(x, y - 2, "#f6c45a") end end
  end
end

-- ===== v2.5.40 polish pass 2: material cues =====
do
  local function chip(x, y) P(x, y, STONE[1]); P(x + 1, y, STONE[2]); P(x, y + 1, STONE[5]); P(x + 1, y + 1, STONE[4]) end
  -- tower: chipped blocks, hairline cracks, lichen on the shaded north (left) edge
  for _, p in ipairs({ { 121, 74 }, { 98, 122 }, { 126, 128 }, { 100, 90 }, { 128, 150 }, { 118, 106 }, { 94, 134 } }) do chip(p[1], p[2]) end
  for _, p in ipairs({ { 104, 68 }, { 105, 69 }, { 105, 70 }, { 106, 71 }, { 106, 72 }, { 126, 138 }, { 127, 139 }, { 127, 140 }, { 128, 141 }, { 99, 150 }, { 99, 151 }, { 100, 152 } }) do P(p[1], p[2], STONE[1]) end
  for y = 70, 166 do
    local lx = 86 + floor((y - 64) * 4 / 118)
    for k = 0, 4 do
      if hash(y, k, 301) < (0.55 - k * 0.11) then P(lx + k, y, hash(y, k, 302) < 0.5 and "#8a5640" or "#c89068") end
    end
  end
  for i = 0, 18 do local x, y = 100 + floor(hash(i, 1, 303) * 30), 66 + floor(hash(i, 2, 303) * 100)
    local v = c:get(x, y); if v and (v == STONE[4] or v == STONE[3]) then P(x, y, "#e0b48c"); P(x + 1, y, "#b8805e") end end
  -- side face: darker courses, moss drip under the deck
  for x = 139, 148 do if hash(x, 2, 304) < 0.7 then P(x, 66 + floor(hash(x, 3, 304) * 4), "#7a4a38") end end
  -- deck planks: nails and a split
  for x = 70, 158, 6 do P(x, 58, IRON[3]) end
  for x = 100, 108 do P(x, 60, BEAM[1]) end
  -- cabin planks: knots and weathered bands
  for _, p in ipairs({ { 92, 50 }, { 128, 46 }, { 106, 51 }, { 118, 36 } }) do P(p[1], p[2], CABIN[1]); P(p[1] + 1, p[2], CABIN[2]); P(p[1] - 1, p[2], CABIN[2]); P(p[1], p[2] - 1, CABIN[2]); P(p[1], p[2] + 1, CABIN[2]) end
  -- roof: missing-shingle gaps and lighter patch tiles
  for _, p in ipairs({ { 100, 28 }, { 118, 30 }, { 108, 24 }, { 126, 32 } }) do for dx = 0, 2 do P(p[1] + dx, p[2], ROOFR[1]); P(p[1] + dx, p[2] + 1, ROOFR[3]) end end
  for dx = 0, 3 do P(94 + dx, 31, ROOFR[5]); P(94 + dx, 32, ROOFR[4]) end
  -- beacon bowl: rust streaks and soot
  for _, p in ipairs({ { 65, 31 }, { 66, 33 }, { 77, 30 }, { 79, 33 }, { 72, 32 } }) do P(p[1], p[2], "#a85a28"); P(p[1], p[2] + 1, "#c8742c") end
  for x = 64, 82 do if hash(x, 5, 305) < 0.4 then P(x, 28, IRON[1]) end end
  -- flag folds: wind ripples
  for _, p in ipairs({ { 164, 19 }, { 165, 20 }, { 164, 26 }, { 172, 19 }, { 173, 20 }, { 172, 27 }, { 177, 19 }, { 178, 20 } }) do P(p[1], p[2], RED[3]) end
  for _, p in ipairs({ { 168, 21 }, { 169, 22 }, { 175, 22 }, { 176, 23 } }) do P(p[1], p[2], RED[5]) end
  -- ladder: rope lashing at the rungs and worn wood
  for _, y in ipairs({ 100, 140 }) do local xl = floor(120 + 5 * (184 - y) / 126); for x = xl, xl + 1 do P(x, y, "#d8c4a2"); P(x, y + 1, "#8a7058") end end
  -- door: iron studs and rusty hinge streaks
  for _, p in ipairs({ { 99, 163 }, { 105, 163 }, { 111, 163 }, { 99, 169 }, { 105, 169 } }) do P(p[1], p[2], IRON[5]) end
  for y = 161, 167 do P(98, y, "#a85a28") end
  -- huts: thatch tufts hanging at the eave, cracked plaster
  -- roof ladder poking up from the lower roof (kiva style)
  for _, lx in ipairs({ 310, 315 }) do for y = 80, 93 do P(lx, y, LADDER[3]) end; P(lx, 79, LADDER[5]) end
  for y = 82, 92, 3 do for x = 311, 314 do P(x, y, LADDER[4]) end end
  for x = 300, 306 do P(x, 98 - floor((x - 300) / 2), HONEY[2]) end
  for _, p in ipairs({ { 312, 124 }, { 326, 128 }, { 346, 126 } }) do P(p[1], p[2], HONEY[1]); P(p[1] + 1, p[2] + 1, HONEY[1]) end
  for x = 309, 357 do if hash(x, 8, 307) < 0.4 then P(x, 131, "#f2d4a0") end end -- sand drift at the foot
  for _, p in ipairs({ { 396, 124 }, { 404, 128 }, { 424, 122 } }) do for dy = 0, 2 do P(p[1], p[2] + dy, LAV[2]) end end -- peeling paint streaks
  -- stamp post board: nail heads, woodgrain on frame, moss on roof north slope
  for _, p in ipairs({ { 290, 216 }, { 348, 216 }, { 290, 240 }, { 348, 240 }, { 358, 218 }, { 372, 218 }, { 358, 229 }, { 372, 229 } }) do P(p[1], p[2], IRON[5]) end
  for x = 289, 349 do if hash(x, 9, 308) < 0.2 then P(x, 227, BEAM[2]) end end
  for _, p in ipairs({ { 292, 213 }, { 295, 211 }, { 300, 208 }, { 304, 206 } }) do P(p[1], p[2], "#c89068"); P(p[1] + 1, p[2], "#8a5640") end
  -- hearth: soot above the mouth, chips, tea-stain on slab
  for x = 33, 53 do if hash(x, 2, 309) < 0.8 then P(x, 232, "#2f2430") end end
  for _, p in ipairs({ { 30, 228 }, { 55, 240 }, { 28, 246 }, { 57, 230 } }) do chip(p[1], p[2]) end
  -- table: wine rings and plank gaps; canopy folds and a patch
  for x = 74, 130 do if hash(x, 3, 310) < 0.2 then P(x, 227, CABIN[2]) end end
  for x = 60, 142, 9 do P(x, 200, CLOTH[3]); P(x + 1, 201, CLOTH[3]) end
  for dx = 0, 3 do for dy = 0, 2 do P(100 + dx, 198 + dy, (dx == 0 or dy == 2 or dx == 3) and CREAM[2] or CREAM[5]) end end
  -- gate posts & arch: moss and lichen
  for y = 172, 214, 3 do P(400, y, "#c89068"); P(401, y + 1, "#8a5640"); P(459, y, "#8a5640") end
  -- far wall: moss caps
  for x = 20, 460, 4 do if hash(x, 4, 311) < 0.5 then local y = crest(x) - 5; if c:get(x, y) then P(x, y, "#c89068") end end end
end

-- ===== v2.5.40 polish pass 3: lived-in props =====
do
  local INK = "#2b1c26"
  local function prop(m, R, tex, o) o = o or {}; o.edge = false; paintTex(m, R, tex, o); c:edgeIn(m, INK); return m end
  local function cast(pts) local m = c:poly(pts); m:each(function(x, y) if onLawn(x, y) then P(x, y, y < 165 and "#c69a88" or "#b88a78") end end) end
  local function crate(x, y, w, h, R)
    local m = c:rect(x, y, x + w, y + h)
    prop(m, R, function(px, py, x0, y0)
      if px - x0 == py - y0 or (px - x0) == (w - (py - y0)) then return 3 end
            return (py - y0) % 4 == 0 and 5 or 4 end, { flat = true })
    for xx = x + 1, x + w - 1 do P(xx, y + 1, R[5]) end
    c:rect(x + 2, y + 2, x + w - 2, y + h - 2):edge():each(function(px, py) P(px, py, R[2]) end)
    P(x + 1, y + 1, IRON[5]); P(x + w - 1, y + h - 1, IRON[5])
  end
  -- (1) crate stack + sack + barrel on the far-left lawn
  cast{ { 22, 164 }, { 56, 164 }, { 64, 169 }, { 30, 169 } }
  crate(24, 142, 18, 18, CABIN)
  crate(26, 124, 14, 16, CORK)
  local sack = c:poly{ { 44, 156 }, { 54, 152 }, { 57, 158 }, { 55, 164 }, { 44, 164 } }
  prop(sack, CREAM, function(x, y) return (y == 153 or x == 50 and y < 160) and 3 or 4 end)
  for x = 49, 52 do P(x, 154, "#8a7058") end
  local bar = c:rect(60, 148, 72, 164)
  prop(bar, BEAM, function(x, y, x0, y0) return ((x - x0) % 4 == 3) and 3 or 4 end)
  for _, y in ipairs({ 151, 160 }) do for x = 60, 72 do P(x, y, IRON[3]) end end
  for x = 61, 71 do P(x, 148, BEAM[5]) end
  -- (2) rope coil
  cast{ { 36, 190 }, { 56, 190 }, { 62, 194 }, { 40, 194 } }
  for r = 0, 2 do
    local m = c:ellipse(44, 182, 10 - r * 3, 5 - r)
    local cols = { "#d8c4a2", "#b49a7c", "#f0e2c4" }
    m:each(function(x, y) P(x, y, ((x + y) % 3 == 0) and "#8a7058" or cols[1 + r]) end)
  end
  c:ellipse(44, 182, 10, 5):edge():each(function(x, y) P(x, y, INK) end)
  c:fillMask(c:ellipse(44, 182, 2, 1), "#3a2a3a")
  for x = 52, 62 do P(x, 183 + floor((x - 52) / 4), "#b49a7c") end
  -- (3) standard on a pole: swallowtail pennant against the sky
  local pole = c:rect(26, 78, 27, 118); prop(pole, BEAM, nil, { flat = true })
  P(26, 76, BRASS[5]); P(27, 76, BRASS[4]); P(26, 77, BRASS[3]); P(27, 77, BRASS[3])
  local pen = c:poly{ { 28, 80 }, { 52, 82 }, { 46, 87 }, { 54, 93 }, { 28, 92 } }
  prop(pen, BLUEP, function(x, y) return (y < 84) and 5 or ((x + y) % 7 == 0 and 3 or 4) end, { flat = true })
  for x = 32, 44 do P(x, 86, "#f8c060") end
  c:fillMask(c:poly{ { 30, 85 }, { 33, 87 }, { 30, 89 } }, "#f8c060")
  cast{ { 24, 118 }, { 29, 118 }, { 40, 124 }, { 32, 124 } }
  -- (4) bunting string from the deck to a post
  local pb = c:rect(212, 92, 214, 140); prop(pb, BEAM, nil, { flat = true })
  local pcols = { RED[4], "#f8c060", CLOTH[4], BLUEP[4], "#f07aa0" }
  for x = 159, 212 do
    local t = (x - 159) / 53
    local y = floor(52 + t * 40 + 5 * sin(t * math.pi))
    P(x, y, CREAM[2])
    if (x - 159) % 7 == 3 then
      local col = pcols[1 + floor((x - 159) / 7) % 5]
      P(x - 1, y + 1, col); P(x, y + 1, col); P(x + 1, y + 1, col); P(x, y + 2, col); P(x, y + 3, col)
      P(x - 1, y + 1, col)
    end
  end
  cast{ { 210, 140 }, { 216, 140 }, { 232, 146 }, { 222, 146 } }
  -- (5) map table with a pinned map and compass, east lawn
  cast{ { 270, 160 }, { 300, 160 }, { 308, 165 }, { 276, 165 } }
  for _, lx in ipairs({ 273, 296 }) do local l = c:rect(lx, 150, lx + 2, 161); prop(l, BEAM, nil, { flat = true }) end
  local top = c:poly{ { 271, 142 }, { 301, 142 }, { 305, 151 }, { 267, 151 } }
  prop(top, CABIN, function(x, y) return (y == 142) and 5 or ((x % 7 == 0) and 3 or 4) end)
  local mp = c:poly{ { 275, 144 }, { 292, 144 }, { 294, 149 }, { 273, 149 } }
  prop(mp, CREAM, nil, { flat = true })
  for _, p in ipairs({ { 277, 147 }, { 280, 146 }, { 283, 147 }, { 286, 145 } }) do P(p[1], p[2], CLOTH[2]) end
  P(289, 147, RED[4]); P(290, 146, RED[4]); P(288, 146, RED[4])
  c:fillMask(c:ellipse(297, 145, 2, 1), BRASS[4]); P(297, 145, RED[4])
  -- (6) signal brazier on a tripod, layered flame + sparks, warm glow on grass
  cast{ { 340, 176 }, { 366, 176 }, { 376, 182 }, { 346, 182 } }
  for _, d in ipairs({ { 346, 160, 340, 178 }, { 358, 160, 366, 178 }, { 352, 160, 352, 180 } }) do
    c:fillMask(c:line({ { d[1], d[2] }, { d[3], d[4] } }, 2), BEAM[3])
  end
  c:edgeIn(c:line({ { 346, 160 }, { 340, 178 } }, 2), INK); c:edgeIn(c:line({ { 358, 160 }, { 366, 178 } }, 2), INK)
  local bowl = c:poly{ { 340, 152 }, { 364, 152 }, { 360, 162 }, { 344, 162 } }
  prop(bowl, IRON, function(x, y) return ((x + y) % 4 == 0) and 3 or 4 end)
  for x = 340, 364 do P(x, 152, IRON[5]) end
  for _, p in ipairs({ { 343, 158 }, { 355, 160 } }) do P(p[1], p[2], "#a85a28"); P(p[1], p[2] + 1, "#c8742c") end
  local fl = c:poly{ { 342, 151 }, { 344, 142 }, { 347, 146 }, { 350, 134 }, { 354, 145 }, { 357, 138 }, { 360, 146 }, { 363, 151 } }
  c:fillMask(fl, "#d8481e")
  local fl2 = fl:shrink(2); c:fillMask(fl2, "#f6a43a")
  local fl3 = fl2:shrink(2); c:fillMask(fl3, "#ffe08a")
  for _, p in ipairs({ { 347, 130 }, { 358, 131 }, { 352, 127 }, { 362, 134 }, { 344, 135 } }) do P(p[1], p[2], "#f8c060") end
  P(354, 124, "#ffe6a0")
  for y = 164, 182 do for x = 332, 372 do
    local d = ((x - 352) / 20) ^ 2 + ((y - 174) / 9) ^ 2
    if d < 1 and (x + y) % 2 == 0 and d > 0.15 then LP(x, y, "#f8d49a") end
  end end
  -- (7) wheelbarrow with turnips beside the road (left)
  cast{ { 192, 154 }, { 216, 154 }, { 222, 158 }, { 198, 158 } }
  local tub = c:poly{ { 192, 140 }, { 214, 140 }, { 210, 150 }, { 196, 150 } }
  prop(tub, CABIN, function(x, y) return ((y == 140) and 5) or ((x % 5 == 0) and 3 or 4) end)
  for x = 194, 212 do P(x, 146, IRON[3]) end
  for _, p in ipairs({ { 198, 138 }, { 204, 137 }, { 209, 138 } }) do
    c:fillMask(c:ellipse(p[1], p[2], 2, 2), CACT[4]); P(p[1] - 1, p[2] - 1, CACT[5]); P(p[1], p[2], CACT[2]); P(p[1] + 1, p[2] + 1, CACT[3])
  end
  c:fillMask(c:line({ { 213, 143 }, { 222, 138 } }, 2), BEAM[3]); P(222, 137, BEAM[1])
  c:fillMask(c:ellipse(200, 152, 3, 3), IRON[3]); c:edgeIn(c:ellipse(200, 152, 3, 3), INK); P(200, 152, BRASS[4])
  c:fillMask(c:line({ { 198, 150 }, { 192, 156 } }, 1), BEAM[2])
  -- (8) wooden bucket + lantern on the table-side post
  local bk = c:poly{ { 148, 232 }, { 158, 232 }, { 156, 244 }, { 150, 244 } }
  prop(bk, CABIN, function(x, y) return ((x % 3 == 0) and 3 or 4) end)
  for x = 149, 157 do P(x, 236, IRON[3]) end
  for x = 149, 157 do P(x, 233, "#8fb8d8") end
  cast{ { 148, 246 }, { 160, 246 }, { 168, 250 }, { 156, 250 } }
end

-- ===== v2.5.40 polish pass 4: light, depth, flora, frame =====
do
  local INK = "#2b1c26"
  local SKY = {}
  for _, v in ipairs(SKYC) do SKY[v] = true end; SKY["#f8e2c4"] = true; SKY["#dcae9e"] = true
  local function SP(x, y, col) local v = c:get(x, y); if v and SKY[v] then P(x, y, col) end end
  local function glow(cx, cy, rx, ry, col, onFn)
    for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
      local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if d < 1 and d > 0.12 and (x + y) % 2 == 0 and (d < 0.55 or (x % 2 == 0)) then onFn(x, y, col) end
    end end
  end
  -- atmospheric haze: far lawn paler and cooler near the crest, far hills softly misted
  for x = 0, W - 1 do
    local cy = crest(x)
    for k = 1, 7 do
      if (x + cy + k) % 2 == 0 and (k < 4 or x % 2 == 0) then LP(x, cy + k, k < 4 and "#f8e4c0" or "#f4dab0") end
    end
  end
  for x = 0, W - 1, 2 do local y = ridge2(x) + 3; if c:get(x, y) == "#dcb498" then P(x, y, "#e6c2a8") end end
  -- distant poplars (cool, light) with a soft warm rim on the left
  -- distant date palms near the road end (hazy, cool), heights and leans vary
  for i, t in ipairs({ { 196, 18, 2 }, { 204, 13, -1 }, { 264, 20, -2 }, { 272, 14, 1 }, { 281, 17, 2 }, { 214, 11, -1 } }) do
    local bx, h, lean = t[1], t[2], t[3]
    for k = 0, h do P(floor(bx + lean * k / h), 112 - k, (k % 3 == 0) and "#8a7462" or "#9c8470") end
    local tx, ty = floor(bx + lean), 112 - h
    for k = -3, 3 do
      local len = 5 + (k * k) % 3
      for j = 1, len do
        P(tx + floor(k * j / 3) + (k > 0 and 1 or (k < 0 and -1 or 0)), ty + floor(j * j * 0.14) - ((k == 0) and 1 or 0), (k < 0) and "#8e9672" or "#727a5e")
      end
    end
    P(tx, ty - 1, "#a8ae84"); P(tx - 1, ty + 1, "#b0683c"); P(tx + 1, ty + 1, "#b0683c")
  end
  -- warm glow: beacon fire, gate lanterns, hut window, hearth, brazier
  glow(73, 22, 20, 14, "#f8d890", SP)
  glow(46, 38, 12, 14, "#f8e0a8", SP)
  glow(434, 38, 12, 14, "#f8e0a8", SP)
  glow(323, 112, 14, 12, "#e8c070", function(x, y, col) local v = c:get(x, y); if v and (v == HONEY[4] or v == HONEY[3] or v == HONEY[5]) then P(x, y, col) end end)
  glow(401, 113, 12, 10, "#f0d890", function(x, y, col) local v = c:get(x, y); if v and (v == LAV[4] or v == LAV[3]) then P(x, y, col) end end)
  glow(44, 244, 24, 10, "#e8a860", function(x, y, col) local v = c:get(x, y); if v and (v == STONE[4] or v == STONE[3] or v == STONE[5]) then P(x, y, col) end end)
  glow(110, 44, 20, 8, "#f8d890", function(x, y, col) local v = c:get(x, y); if v and (v == CABIN[4] or v == CABIN[3]) then P(x, y, col) end end)
  -- warm bounce under the cabin onto the deck and the tower top
  for x = 90, 134 do if x % 2 == 0 then P(x, 56, BEAM[5]) end end
  -- rim light: bright pixel on the upper-left edge of main props
  local function rim(m, col, only)
    m:each(function(x, y)
      if not m:has(x - 1, y) or not m:has(x, y - 1) then
        local v = c:get(x, y)
        if v and v ~= INK and v ~= ROOFR[1] and v ~= STONE[1] and v ~= BEAM[1] and v ~= CABIN[1] and v ~= IRON[1] and v ~= TEAL[1] then
          if not only or only(v) then P(x, y, col) end
        end
      end
    end)
  end
  rim(c:ellipse(112, 36, 33, 18):clip(c:rect(78, 17, 146, 35)), "#f6b07a")
  rim(c:rect(88, 34, 134, 54), "#e4a068")
  rim(c:poly{ { 86, 64 }, { 138, 64 }, { 142, 182 }, { 82, 182 } }:shrink(0), "#d8ccc0")
  rim(c:poly{ { 284, 216 }, { 319, 199 }, { 354, 216 } }, "#8ad0b8")
  rim(c:rect(356, 216, 374, 232), "#f09070")
  rim(c:ellipse(414, 88, 16, 13):clip(c:rect(396, 70, 432, 87)), "#a4ecd8")
  rim(c:rect(308, 94, 358, 132), "#f8dcb0")
  rim(c:rect(316, 81, 348, 92), "#f8dcb0")
  rim(c:rect(26, 224, 60, 252), "#d8ccc0")
  rim(c:rect(166, 146, 170, 182), "#d09060")
  -- extra cast shadows on the road from the posts (long, to the lower right)
  -- flora: berry bush, sunflowers, ivy, ferns (each different)
  local function blob(cx, cy, rx, ry, R, s)
    for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
      local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if d < 1 - 0.3 * hash(x, y, s) then
        local l = 4
        if (x - cx) + (y - cy) > rx * 0.3 then l = 3 end
        if (x - cx) + (y - cy) < -rx * 0.6 then l = 5 end
        if hash(x, y, s + 1) < 0.14 then l = l - 1 end
        if d > 0.75 then l = 2 end
        P(x, y, R[max(2, l)])
      end
    end end
  end
  -- berry bush on the east lawn
  for x = 362, 392 do if hash(x, 1, 401) < 0.9 then LP(x, 191, "#b88a78") end end
  for i, pd in ipairs({ { 372, 184, 6, 5 }, { 365, 176, 4, 4 }, { 379, 175, 5, 4 }, { 372, 171, 3, 3 }, { 384, 183, 4, 4 } }) do
    local m = c:ellipse(pd[1], pd[2], pd[3], pd[4])
    paintTex(m, CACT, function(x, y) return (hash(x, y, 411 + i) < 0.1) and 5 or 4 end, { edge = false })
    c:edgeIn(m, CACT[1])
    for k = 0, 2 do P(pd[1] - 2 + k * 2, pd[2] - 1 + (k % 2), "#e8d8b4") end
  end
  for _, p in ipairs({ { 365, 171 }, { 379, 170 }, { 372, 167 }, { 384, 178 } }) do P(p[1], p[2], "#c0305a"); P(p[1], p[2] - 1, "#e8608c") end
  -- sunflowers by the standard
  for i, p in ipairs({ { 46, 124, 100 }, { 60, 124, 104 } }) do
    -- spiky rosette
    for k = -4, 4 do for j = 0, 9 - abs(k) do P(p[1] + floor(k * j / 3), p[2] - j + abs(k) // 2, (j > 6 - abs(k) // 2) and LEAF[5] or (k < 0 and LEAF[4] or LEAF[3])) end end
    -- bloom stalk with cream bells
    for y = p[3], p[2] - 8 do P(p[1], y, "#7a6a4a") end
    for y = p[3], p[3] + 9, 2 do P(p[1] - 1, y, "#f4e4c0"); P(p[1] + 1, y + 1, "#e8d2a8"); P(p[1] - 2, y + 1, "#d8bc94") end
  end
  -- ivy and hanging leaves from the beam, top left and right
  for _, s in ipairs({ { 18, 1, 30 }, { 444, 1, 41 } }) do
    for k = 0, 17 do
      local x = s[1] + k * (s[1] < 100 and 1 or 1) 
      local len = 8 + floor(hash(k, 1, 420 + s[1]) * 18)
      if (s[1] > 100 and k > 8) or s[1] < 100 and k < 20 then
        for y = 15, 15 + len do
          local dy = floor((x - s[1]) * 0.15)
          if (y + x) % 3 ~= 0 then P(x + ((y % 4 < 2) and 0 or 1), y + dy, y % 2 == 0 and LEAF[5] or LEAF[4]) else P(x, y + dy, LEAF[3]) end
          if y == 15 + len then P(x, y + dy, LEAF[2]) end
        end
      end
    end
  end
  for _, p in ipairs({ { 22, 34 }, { 30, 30 }, { 454, 38 }, { 458, 32 } }) do P(p[1], p[2], "#b0683c"); P(p[1] + 1, p[2], "#8a4a2c"); P(p[1], p[2] + 1, "#c88048") end
  -- ferns climbing the right pillar and tufts at the left pillar foot
  for y = 100, 104 do P(470, y, CREAM[2]) end
  for k = 0, 11 do
    local y = 105 + k * 3
    local cx = 470 + ((k % 2 == 0) and -2 or 1)
    c:fillMask(c:rect(cx, y, cx + 2, y + 2), RED[4]); P(cx, y, RED[5]); P(cx + 2, y + 2, RED[2]); P(cx + 1, y + 3, RED[3])
  end
  P(470, 141, LEAF[4]); P(469, 142, LEAF[4])
  for k = -3, 3 do for j = 0, 9 - abs(k) * 2 do P(14 + k * j // 2 + k, 268 - j + abs(k), (j % 3 == 0) and LEAF[5] or LEAF[4]) end end
end

-- ===== GATE FRAME (stone pillars, timber beam, lanterns, bell) =====
do
  local lp = c:rect(0, 0, 17, H - 1); paintTex(lp, PILLAR, stoneTex(9, 8, 41))
  local rp = c:rect(462, 0, 479, H - 1); paintTex(rp, PILLAR, stoneTex(9, 8, 42), { shadeLeft = true })
  for y = 0, H - 1 do if hash(1, y, 77) < 0.25 then P(17, y, PILLAR[2]) end end
  local beam = c:rect(0, 0, 479, 13); paintTex(beam, BEAM, planksH(7), { flat = true })
  for x = 0, 479 do P(x, 14, "#3a2a3a") end
  for x = 30, 470, 48 do c:fillMask(c:rect(x, 4, x + 1, 5), IRON[4]); P(x, 4, IRON[5]) end
  local br1 = c:poly{ { 18, 14 }, { 38, 14 }, { 18, 34 } }; paintTex(br1, BEAM, nil)
  local br2 = c:poly{ { 442, 14 }, { 461, 14 }, { 461, 34 } }; paintTex(br2, BEAM, nil)
  local function lantern(cx)
    for y = 15, 25 do P(cx, y, (y % 2 == 0) and IRON[3] or IRON[5]) end
    local cap = c:poly{ { cx - 5, 30 }, { cx - 2, 26 }, { cx + 2, 26 }, { cx + 5, 30 } }; paintTex(cap, IRON, nil)
    window(cx - 5, 31, cx + 5, 42, IRON[2], false)
    for y = 31, 42 do P(cx, y, IRON[3]) end
    local bot = c:rect(cx - 6, 43, cx + 6, 45); paintTex(bot, IRON, nil)
    P(cx, 46, IRON[2])
  end
  lantern(46); lantern(434)
  -- a little brass bell charm
  for y = 15, 21 do P(262, y, (y % 2 == 0) and IRON[3] or IRON[5]) end
  local bell = c:poly{ { 258, 31 }, { 259, 25 }, { 261, 22 }, { 263, 22 }, { 265, 25 }, { 266, 31 } }
  paintTex(bell, BRASS, nil)
  P(262, 32, BRASS[2]); P(262, 33, BRASS[3])
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate",
"spots":[
{"k":"do","name":"Watchtower","x":124,"y":100,"box":[62,16,186,184]},
{"k":"people","name":"Travellers' Table","x":80,"y":227,"box":[20,192,140,262]},
{"k":"stop","name":"Stamp Post","x":331,"y":227,"box":[286,198,376,256]},
{"k":"homes","name":"Hilltop Huts","x":373,"y":101,"box":[292,70,454,133]},
{"k":"wild","name":"Wild Trail","x":427,"y":184,"box":[388,146,466,222]}],
"stand":[{"x":190,"y":252},{"x":250,"y":250},{"x":220,"y":204},{"x":240,"y":165},{"x":170,"y":214},{"x":320,"y":166}],
"compass_clear":[380,230,480,270]}
]]
local f = io.open(OUT .. NAME .. ".layout.json", "w"); f:write(layout); f:close()
print("ok " .. NAME)
