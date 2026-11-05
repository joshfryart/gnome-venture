-- Gnome Venture "Hearth Pop" v3 : Watchtower rest stop, GATE VIEW, 480x270 native
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-tower"
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
local STONE  = { "#3e3040", "#5a4a52", "#7d6e72", "#a39490", "#c9bcb0" }
local PILLAR = { "#2f2a3c", "#4b4660", "#69657f", "#8a879e", "#adaabd" }
local WALLG  = { "#5a5070", "#7e7690", "#9c94a8", "#b7b0bf", "#d0cad4" }
local BEAM   = { "#2e1a1c", "#4a2a24", "#6a3c2c", "#8c5436", "#b07246" }
local CABIN  = { "#3e2018", "#5a3424", "#7f4a2e", "#a8653c", "#cf8a52" }
local LADDER = { "#5a3418", "#86552a", "#b07a3c", "#d9a660", "#f0c884" }
local ROOFR  = { "#3e1a2a", "#5a2c3a", "#8a3e45", "#b8544e", "#dd7a62" }
local BRASS  = { "#4a3014", "#6a4a22", "#a07030", "#d6a24a", "#f4d488" }
local IRON   = { "#1f1c2a", "#34303f", "#4a4558", "#635d74", "#857e94" }
local HONEY  = { "#4a3428", "#6a4c3a", "#9a7458", "#c49c74", "#e2c39a" }
local THATCH = { "#5a3a18", "#7a5422", "#a8782e", "#d4a444", "#efcf72" }
local LAV    = { "#2c3254", "#3e4870", "#56649a", "#7686c0", "#9fb0e0" }
local MOSSR  = { "#1f3628", "#2f4a36", "#476a44", "#628c52", "#8db66a" }
local TEAL   = { "#14363c", "#1f4a50", "#2e6a6e", "#3f8e8a", "#6cb8a8" }
local CORK   = { "#5a3420", "#7a4a2c", "#a0663a", "#c58a54", "#e0aa72" }
local RED    = { "#4a1420", "#6e1e28", "#a02c30", "#cc4438", "#ec7a58" }
local CLOTH  = { "#1f4a3a", "#2c6448", "#3e8656", "#5aa86a", "#8cce8a" }
local CREAM  = { "#8a7058", "#b49a7c", "#d8c4a2", "#f0e2c4", "#fbf2dc" }
local BARK   = { "#2a1810", "#3e2616", "#5a3820", "#7a4e2c", "#9c6a3e" }
local LEAF   = { "#1d3a2e", "#2a5038", "#3a6a40", "#4f8a48", "#78ad5a" }
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
c:stripes(0, 111, { "#5b6cb8", "#6f86c8", "#8ea3d8", "#b0bce2", "#d3c6dc", "#efcfc4", "#f8ddb4" }, { 3, 3, 3, 3, 2, 2, 2 })
c:cloud(26, 58, 76, "#fbefd8", "#d9b9cc")
c:cloud(312, 44, 96, "#fbefd8", "#d9b9cc")
c:cloud(196, 74, 48, "#fbefd8", "#e4c4cc")
c:cloud(392, 84, 58, "#fbefd8", "#e4c4cc")
c:cloud(250, 30, 40, "#fbefd8", "#d9b9cc")

-- ===== FAR SCENERY (valley below the hilltop) =====
c:terrain(function(x) return floor(84 + 8 * sin(x / 37) + 5 * sin(x / 13 + 1)) end, "#a7a6d0", 117)
local function ridge2(x) return floor(96 + 5 * sin(x / 29 + 2) + 3 * sin(x / 11)) end
c:terrain(ridge2, "#8fa9b8", 117)
local function ridge3(x) return floor(104 + 3 * sin(x / 23 + 4) + 2 * sin(x / 7)) end
c:terrain(ridge3, "#7e9f8c", 117)
for x = 0, W - 1 do
  P(x, ridge2(x), "#a9c0cc")
  P(x, ridge3(x), "#93b39c")
  if hash(x, 1, 21) < 0.18 then -- tiny far trees
    local ty = ridge3(x)
    P(x, ty - 1, "#5a7e68"); P(x, ty - 2, "#5a7e68"); P(x + 1, ty - 1, "#4a6c5a")
  end
end

-- ===== LAWN (windswept hilltop) =====
local function crest(x) return floor(112 + ((x - 240) / 240) ^ 2 * 6) end
local function lawnCol(y)
  if y < 130 then return "#b7c972", "#cfdc8c", "#98ad5c" end
  if y < 165 then return "#a4c262", "#c2d87c", "#86a64e" end
  if y < 215 then return "#93b955", "#b6d470", "#749c44" end
  return "#86ae4c", "#a9cc66", "#6a9240"
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
local STONES = { "#cdb48e", "#d9c29c", "#c4a883", "#e2cfaa", "#d4ba92" }
local pathMask = c:poly{ { 237, 113 }, { 243, 113 }, { 333, 269 }, { 147, 269 } }
pathMask:each(function(x, y)
  local r, j = prow(y), pcol(x, y)
  local col
  if prow(y + 1) ~= r or pcol(x + 1, y) ~= j then col = "#8c7560"
  elseif prow(y - 1) ~= r or pcol(x - 1, y) ~= j then col = "#efe0bf"
  else
    col = STONES[1 + floor(hash(r, j, 13) * 5)]
    if (x - 240) / hw(y) > 0.55 and hash(x, y, 4) < 0.5 then col = "#b89c78" end
    if hash(x, y, 17) < 0.03 then col = "#a88c6c" end
  end
  P(x, y, col)
end)
c:edgeIn(pathMask, "#7a624f")
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
  local col = "#c99f6e"
  local hv = hash(x, y, 31)
  if hv < 0.08 then col = "#a87c54" elseif hv > 0.93 then col = "#e0bf8c" end
  P(x, y, col)
end)
trail:edge():each(function(x, y) if not isPath(x, y) then P(x, y, "#8a6444") end end)

-- lawn / road cast shadow helper (to lower right)
local function shadow(pts)
  local m = c:poly(pts)
  m:each(function(x, y)
    if isPath(x, y) then P(x, y, "#a08a72")
    else P(x, y, y < 165 and "#7d9a5a" or "#6c8a4c") end
  end)
end

-- ===== HOMES (far right tier) =====
shadow{ { 296, 128 }, { 358, 132 }, { 372, 136 }, { 300, 134 } }
shadow{ { 380, 129 }, { 442, 132 }, { 456, 136 }, { 384, 135 } }
-- Home A: stone cottage, thatch roof
do
  local side = c:poly{ { 296, 100 }, { 308, 96 }, { 308, 132 }, { 296, 129 } }
  paintTex(side, HONEY, stoneTex(6, 5, 3), { dark = true, flat = true })
  local front = c:rect(308, 96, 356, 132)
  paintTex(front, HONEY, stoneTex(8, 6, 5))
  local roof = c:poly{ { 292, 101 }, { 332, 72 }, { 362, 98 }, { 310, 99 } }
  paintTex(roof, THATCH, thatchTex)
  for x = 294, 360 do if hash(x, 4, 44) < 0.5 then P(x, (x < 310) and 101 or 99, THATCH[3]) end end
  -- chimney with a mushroom-cap pot (quirk)
  local ch = c:rect(344, 74, 351, 90)
  paintTex(ch, HONEY, stoneTex(4, 3, 8))
  local cap = c:poly{ { 340, 74 }, { 342, 69 }, { 347, 67 }, { 353, 69 }, { 355, 74 } }
  paintTex(cap, RED, nil)
  P(344, 70, CREAM[5]); P(349, 69, CREAM[5]); P(351, 72, CREAM[5])
  -- smoke drifting right with the wind
  for i, p in ipairs({ { 357, 64, 3 }, { 364, 59, 4 }, { 373, 55, 4 } }) do
    local m = c:rect(p[1], p[2], p[1] + p[3], p[2] + p[3] - 1)
    c:fillMask(m, "#e2dae6"); for x = p[1], p[1] + p[3] do P(x, p[2] + p[3] - 1, "#bcb0cc") end
  end
  window(316, 106, 330, 117, HONEY[1], true)
  local door = c:rect(338, 110, 350, 132)
  paintTex(door, TEAL, planksV(3))
  P(347, 121, BRASS[5]); P(347, 122, BRASS[3])
  -- boot planter (quirk)
  local boot = c:poly{ { 359, 122 }, { 364, 122 }, { 364, 129 }, { 368, 129 }, { 368, 132 }, { 359, 132 } }
  paintTex(boot, CORK, nil)
  for _, p in ipairs({ { 360, 120 }, { 362, 118 }, { 361, 116 }, { 363, 120 } }) do P(p[1], p[2], CLOTH[3]) end
  P(360, 115, "#f07aa0"); P(362, 115, "#f8c060"); P(361, 114, "#f07aa0")
end
-- Home B: painted lavender board hut, mossy shingle roof
do
  local side = c:poly{ { 380, 104 }, { 388, 100 }, { 388, 132 }, { 380, 129 } }
  paintTex(side, LAV, planksV(3), { dark = true, flat = true })
  local front = c:rect(388, 100, 440, 132)
  paintTex(front, LAV, planksV(4))
  local roof = c:poly{ { 376, 105 }, { 414, 76 }, { 452, 102 }, { 390, 103 } }
  paintTex(roof, MOSSR, shingleTex(4, 6))
  window(395, 108, 407, 118, LAV[1], true)
  local door = c:rect(418, 112, 430, 132)
  paintTex(door, RED, planksV(3))
  P(420, 122, BRASS[5])
  -- line of tiny socks under the eave (quirk)
  for x = 389, 439 do P(x, 104, CREAM[2]) end
  local sc = { RED[4], "#f8c060", CLOTH[4], "#f07aa0", BLUEP[4] }
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
  front:each(function(x, y) if y > 168 and hash(x, y, 51) < (y - 168) / 22 then P(x, y, hash(x, y, 52) < 0.5 and "#5f8a3e" or "#7aa64c") end end)
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
  local roof = c:poly{ { 78, 36 }, { 111, 17 }, { 146, 36 } }
  paintTex(roof, ROOFR, shingleTex(4, 7))
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
  paintTex(capm, RED, function(x, y) return ((x + y) % 4 < 2) and 5 or 4 end)
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
  local back = c:rect(404, 160, 461, 214); c:fillMask(back, "#2a4a3a")
  back:each(function(x, y) if hash(x, y, 61) < 0.15 then P(x, y, "#345a42") end end)
  clump(414, 172, 14, 14, LEAF, 70); clump(450, 168, 16, 16, LEAF, 71); clump(432, 160, 14, 12, LEAF, 72)
  clump(440, 190, 10, 8, LEAF, 73)
  -- trail continuing into the wild
  local tr = c:poly{ { 404, 200 }, { 461, 198 }, { 461, 214 }, { 404, 214 } }
  tr:each(function(x, y) P(x, y, (x > 440) and "#a07850" or "#c99f6e") end)
  -- low drystone wall stubs
  local w1 = c:rect(390, 194, 401, 214); paintTex(w1, WALLG, stoneTex(6, 4, 9))
  -- stone gate posts
  local pl = c:rect(400, 170, 410, 216); paintTex(pl, PILLAR, stoneTex(6, 6, 14))
  local pr = c:rect(450, 170, 460, 216); paintTex(pr, PILLAR, stoneTex(6, 6, 15))
  for x = 400, 410 do if hash(x, 1, 81) < 0.6 then P(x, 170, CLOTH[4]) end end
  -- twig arch with leaves, flowers and a hanging twig-star charm
  local arch = c:line({ { 405, 171 }, { 410, 158 }, { 422, 150 }, { 438, 150 }, { 450, 158 }, { 455, 171 } }, 5)
  paintTex(arch, BARK, function(x, y) return hash(x, y, 90) < 0.3 and 3 or 4 end, { flat = true })
  clump(412, 156, 6, 4, CLOTH, 91); clump(446, 154, 7, 4, CLOTH, 92); clump(428, 149, 6, 3, CLOTH, 93)
  for _, p in ipairs({ { 411, 154 }, { 445, 153 }, { 429, 148 }, { 449, 157 } }) do P(p[1], p[2], "#f07aa0"); P(p[1] + 1, p[2], "#f8c060") end
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
  for i = 0, 12 do local x = 402 + i * 4; P(x, 215, LEAF[4]); P(x + 1, 214, LEAF[5]); P(x - 1, 214, LEAF[3]) end
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
  for y = 253, 262 do for x = 30, 58 do if hash(x, y, 41) < 0.35 then P(x, y, "#c2c45a") end end end
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

-- ===== GATE FRAME (stone pillars, timber beam, lanterns, bell) =====
do
  local lp = c:rect(0, 0, 17, H - 1); paintTex(lp, PILLAR, stoneTex(9, 8, 41))
  local rp = c:rect(462, 0, 479, H - 1); paintTex(rp, PILLAR, stoneTex(9, 8, 42), { shadeLeft = true })
  for y = 0, H - 1 do if hash(1, y, 77) < 0.25 then P(17, y, LEAF[3]) end end
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
