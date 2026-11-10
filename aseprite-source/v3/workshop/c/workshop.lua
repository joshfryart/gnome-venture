-- Workshop mockup C: "Garden barn, daylight". 480 x 270, one-point perspective toward (240,112).
-- Self-contained: paints the base picture, the "ready" animation layers and layout.json.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "craft-workshop" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin, abs, sqrt = math.floor, math.max, math.min, math.sin, math.abs, math.sqrt
local hash = S.hash

---------------------------------------------------------------- colour (ints 0xRRGGBB)
local function hex(s) return tonumber(s:sub(2), 16) end
local function RP(t) local o = {} for i, v in ipairs(t) do o[i] = hex(v) end return o end
local function mix(a, b, t)
  local ar, ag, ab = a >> 16, (a >> 8) & 255, a & 255
  local br, bg, bb = b >> 16, (b >> 8) & 255, b & 255
  return (floor(ar + (br - ar) * t + .5) << 16) | (floor(ag + (bg - ag) * t + .5) << 8) | floor(ab + (bb - ab) * t + .5)
end
local INK = 0x2b1c26
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, DIRT =
  RP(S.TIMB), RP(S.OAK), RP(S.CREAM), RP(S.ROSE), RP(S.GREEN), RP(S.LEAF), RP(S.BARN), RP(S.GOLD), RP(S.STONE),
  RP(S.TEAL), RP(S.VIOLET), RP(S.PINK), RP(S.IRON), RP(S.DIRT)
local BRICK  = RP{"#4a2030","#7a3434","#a84c3c","#c86a4a","#e08c60","#f2b684"}
local COPPER = RP{"#4a2028","#7c3a2c","#b05a30","#d8823c","#f0aa5a","#fcd894"}
local TERRA  = RP{"#5a2a2a","#8a4432","#b4603c","#d27e4c","#e8a06a","#f6c896"}
local WOOD   = RP{"#5c4450","#8a6652","#b48a60","#d0a870","#e4c288","#f2dca6"}
local WW     = RP{"#6e6478","#9c93a0","#c4bfbe","#ddd9cc","#ece8d6","#f8f4e2"}
local SAGE   = RP{"#28443e","#3e6650","#5c8a66","#84ae82","#aacba0","#d0e4c0"}
local DUCK   = RP{"#253848","#3a5a68","#56848a","#7cada6","#a6cebe","#d0e8d6"}
local BURLAP = RP{"#4e3a34","#7a5c40","#a07e50","#c09e68","#d8bc86","#ecd8a8"}
local SKYB   = RP{"#1e3552","#2e5a80","#4384ac","#62a8c8","#8cc8dc","#bfe4ea"}
local RED    = RP{"#4a1826","#7c2430","#b03a3a","#d8564a","#ee8266","#f8b294"}
local LIME   = RP{"#1e4a3a","#2e7a4c","#4aa85a","#7cd070","#b0ec8c","#dcfabc"}
local SHADE  = 0x3a2e58

---------------------------------------------------------------- target buffer
local function newT(x, y, w, h) return { ox = x, oy = y, w = w, h = h, d = {} } end
local BASE = newT(0, 0, W, H)
local T = BASE
local function P(x, y, col)
  x = x - T.ox; y = y - T.oy
  if x >= 0 and y >= 0 and x < T.w and y < T.h then T.d[y * T.w + x] = col end
end
local function G(x, y)
  x = x - T.ox; y = y - T.oy
  if x >= 0 and y >= 0 and x < T.w and y < T.h then return T.d[y * T.w + x] end
end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function tint(x0, y0, x1, y1, col, t)
  for y = y0, y1 do for x = x0, x1 do local g = G(x, y); if g then P(x, y, mix(g, col, t)) end end end
end
local function cl(i) return max(1, min(6, i)) end

---------------------------------------------------------------- masks
local function K(x, y) return (y + 500) * 2048 + (x + 500) end
local function mnew() return { s = {}, x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9 } end
local function mset(m, x, y)
  m.s[K(x, y)] = true
  if x < m.x0 then m.x0 = x end; if x > m.x1 then m.x1 = x end
  if y < m.y0 then m.y0 = y end; if y > m.y1 then m.y1 = y end
end
local function mhas(m, x, y) return m.s[K(x, y)] end
local function meach(m, f) for y = m.y0, m.y1 do for x = m.x0, m.x1 do if m.s[K(x, y)] then f(x, y) end end end end
local function mrect(x0, y0, x1, y1, m) m = m or mnew(); for y = y0, y1 do for x = x0, x1 do mset(m, x, y) end end return m end
local function mell(cx, cy, rx, ry, m, half)   -- half = "top" keeps y <= cy
  m = m or mnew()
  for y = floor(cy - ry), floor(cy + ry) do for x = floor(cx - rx), floor(cx + rx) do
    if ((x - cx) / (rx + .5)) ^ 2 + ((y - cy) / (ry + .5)) ^ 2 <= 1 and (half ~= "top" or y <= cy) then mset(m, x, y) end
  end end
  return m
end
local function mpoly(pts, m)   -- convex polygon, vertices are pixel centres
  m = m or mnew()
  local ymin, ymax = 1e9, -1e9
  for _, p in ipairs(pts) do ymin = min(ymin, p[2]); ymax = max(ymax, p[2]) end
  for y = floor(ymin), floor(ymax) do
    local xa, xb = 1e9, -1e9
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      local y1, y2 = a[2], b[2]
      if (y >= min(y1, y2)) and (y <= max(y1, y2)) then
        if y1 == y2 then xa = min(xa, a[1], b[1]); xb = max(xb, a[1], b[1])
        else local x = a[1] + (b[1] - a[1]) * (y - y1) / (y2 - y1); xa = min(xa, x); xb = max(xb, x) end
      end
    end
    for x = floor(xa + .5), floor(xb + .5) do mset(m, x, y) end
  end
  return m
end
local function fill(m, f) meach(m, function(x, y) local col = f; if type(f) == "function" then col = f(x, y) end; if col then P(x, y, col) end end) end
local function edge(m, col)
  meach(m, function(x, y)
    if not (mhas(m, x - 1, y) and mhas(m, x + 1, y) and mhas(m, x, y - 1) and mhas(m, x, y + 1)) then P(x, y, col) end
  end)
end

---------------------------------------------------------------- object helpers
local function box(x0, y0, x1, y1, ramp, b, o)
  o = o or {}; b = b or 4
  local lit, sh = o.lit or 1, o.shade or 1
  for y = y0, y1 do for x = x0, x1 do
    local col
    if x == x0 or x == x1 or y == y0 or y == y1 then col = o.rim or ramp[1]
    elseif (y1 - y) <= sh or x == x1 - 1 then col = ramp[cl(b - 1)]
    elseif (y - y0) <= lit or x == x0 + 1 then col = ramp[cl(b + 1)]
    else col = ramp[b] end
    P(x, y, col)
  end end
end
local function obj(m, ramp, b, o)   -- any mask: lit top rows, shaded bottom rows / right side, dark rim
  o = o or {}; b = b or 4
  fill(m, function(x, y)
    if not mhas(m, x, y - 1) or not mhas(m, x, y - 2) then return ramp[cl(b + 1)] end
    if not mhas(m, x, y + 2) or not mhas(m, x + 2, y) then return ramp[cl(b - 1)] end
    return ramp[b]
  end)
  edge(m, o.rim or ramp[1])
end
local function ball(cx, cy, rx, ry, ramp, o)
  o = o or {}
  local m = o.m or mell(cx, cy, rx, ry)
  fill(m, function(x, y)
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local v = .5 - .5 * (nx * .65 + ny * .75)
    return ramp[max(2, cl(floor(v * 5.2) + 1))]
  end)
  edge(m, o.rim or ramp[1])
  return m
end
local function shadow(cx, cy, rx, ry, t)
  fill(mell(cx, cy, rx, ry), function(x, y) local g = G(x, y); if g then return mix(g, SHADE, t or .3) end end)
end
local function line(x0, y0, x1, y1, col, th)   -- hard line, th px thick (horizontal thickness)
  th = th or 1
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    for k = 0, th - 1 do P(x + k, y, col) end
  end
end
local function bricks(m, bw, bh, seed, ramp)
  ramp = ramp or BRICK
  local x0, y0, x1 = m.x0, m.y0, m.x1
  fill(m, function(x, y)
    local row = (y - y0) // bh
    local off = (row % 2) * (bw // 2)
    local k = (x - x0 + off) // bw
    if (y - y0) % bh == 0 or (x - x0 + off) % bw == 0 then return ramp[2] end
    local h1 = hash(k, row, seed)
    local tone = 4 + (h1 > .7 and 1 or 0) - (h1 < .22 and 1 or 0)
    if (y - y0) % bh == 1 then tone = tone + 1 end
    if x >= x1 - 2 then tone = tone - 1 end
    return ramp[cl(tone)]
  end)
  edge(m, ramp[1])
end
local function jar(x, yb, w, h, ramp, lid)
  local y0 = yb - h + 3
  for y = y0, yb do for xx = x, x + w - 1 do
    local col
    if xx == x or xx == x + w - 1 or y == yb or y == y0 then col = ramp[2]
    elseif y <= y0 + 2 then col = mix(ramp[6], 0xf2f6ea, .55)
    elseif xx == x + 1 then col = ramp[5]
    elseif xx == x + 2 and y < yb - 2 then col = ramp[6]
    elseif xx >= x + w - 3 then col = ramp[3]
    else col = ramp[4] end
    P(xx, y, col)
  end end
  box(x + 1, yb - h, x + w - 2, yb - h + 3, lid or OAK, 5)
end
local function pot(xc, yb, wt, wb, h, ramp)   -- tapered clay pot with a thick rim
  ramp = ramp or TERRA
  local ht = wt // 2
  for y = yb - h + 4, yb do
    local t = (y - (yb - h + 4)) / max(1, h - 4)
    local hw = floor(ht - 1 + (wb / 2 - ht + 1) * t + .5)
    for x = xc - hw, xc + hw do
      local col
      local r = (x - (xc - hw)) / max(1, 2 * hw)
      if x == xc - hw or x == xc + hw or y == yb then col = ramp[2]
      elseif y == yb - h + 4 then col = ramp[3]
      elseif r < .3 then col = ramp[5]
      elseif r > .7 then col = ramp[3]
      else col = ramp[4] end
      P(x, y, col)
    end
  end
  box(xc - ht - 1, yb - h, xc + ht + 1, yb - h + 3, ramp, 5, { rim = ramp[2] })
end
local function bottle(x, yb, w, h, ramp, cork)   -- glass bottle: neck, shoulders, liquid, glint
  local nx0, nx1 = x + w // 2 - 1, x + w // 2 + 1
  local sh = yb - h + 6
  for y = yb - h + 2, sh do for xx = nx0, nx1 do P(xx, y, (xx == nx0 or xx == nx1) and ramp[2] or mix(ramp[6], 0xf2f6ea, .5)) end end
  R(nx0, yb - h, nx1, yb - h + 2, cork or OAK[5]); R(nx0, yb - h, nx1, yb - h, OAK[3])
  for y = sh, yb do for xx = x, x + w - 1 do
    local col
    local corner = (y == sh and (xx == x or xx == x + w - 1))
    if not corner then
      if xx == x or xx == x + w - 1 or y == yb or y == sh then col = ramp[2]
      elseif y <= sh + 2 then col = mix(ramp[6], 0xf2f6ea, .5)
      elseif xx == x + 1 or (xx == x + 2 and y < yb - 2) then col = ramp[6]
      elseif xx >= x + w - 3 then col = ramp[3]
      else col = ramp[4] end
      P(xx, y, col)
    end
  end end
end
local function spark(x, y, big)   -- 4-point glint
  local a, b = 0xfff6c8, 0xfce67c
  P(x, y, a); P(x - 1, y, a); P(x + 1, y, a); P(x, y - 1, a); P(x, y + 1, a)
  P(x - 2, y, b); P(x + 2, y, b); P(x, y - 2, b); P(x, y + 2, b)
  if big then P(x - 3, y, b); P(x + 3, y, b); P(x, y - 3, b); P(x, y + 3, b); P(x - 1, y - 1, b); P(x + 1, y - 1, b); P(x - 1, y + 1, b); P(x + 1, y + 1, b) end
end

---------------------------------------------------------------- room geometry
local VX, VY = 240, 112
local BX0, BX1, BY0, BY1 = 40, 440, 22, 150     -- back wall
local GX0, GX1, GY0, GY1 = 180, 302, 32, 134    -- glass wall (outer frame)
local DX0, DX1, DY0, DY1 = 318, 366, 46, 150    -- door opening
local F, KK, SHX = 300, 1.9, 0.18               -- camera distance, sun: depth per height, sideways drift

local function inell(x, y, cx, cy, rx, ry) return ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end
local function outside(x, y)   -- soft, low-contrast garden view
  local col = (y < 62) and 0xbde0ee or ((y < 80) and 0xcbe8f0 or 0xd9f0ee)
  if inell(x, y, 204, 53, 15, 4) or inell(x, y, 214, 49, 9, 4) or inell(x, y, 266, 64, 13, 3)
     or inell(x, y, 340, 60, 11, 3) or inell(x, y, 348, 57, 6, 3) then col = 0xf0f6ea end
  local yh = 93 - 7 * sin((x - 150) / 55)
  if y >= yh then col = 0xa9d4c6 end
  local yh2 = 104 - 8 * sin((x - 210) / 42 + 1)
  if y >= yh2 then col = (y >= yh2 + 5) and 0x9ccc84 or 0xacd890 end
  -- trees on the hill
  if inell(x, y, 236, 88, 10, 9) then col = (x + y < 322) and 0x9ccc8a or 0x86bb7c end
  if x >= 235 and x <= 237 and y >= 97 and y <= 103 then col = 0xa88e78 end
  if inell(x, y, 332, 86, 8, 9) then col = (x + y < 416) and 0x9ccc8a or 0x86bb7c end
  if x >= 331 and x <= 333 and y >= 95 and y <= 102 then col = 0xa88e78 end
  if y >= 112 then
    col = 0xb6dc92
    -- garden beds (rows)
    local band = (y >= 118 and y <= 121) or (y >= 127 and y <= 131) or (y >= 138 and y <= 143)
    if band then col = 0xcdae8a end
    if (y == 117 or y == 116 or y == 126 or y == 125 or y == 137 or y == 136) and (x // 3) % 2 == 0 then col = 0x8cc474 end
    -- path to the door
    local t = (y - VY) / 38
    local cx = VX + (342 - VX) * t
    local hw = 13 * t
    if abs(x - cx) <= hw then col = (abs(x - cx) > hw - 1.5) and 0xd8cba2 or 0xeae0bc end
  end
  -- fence on the horizon
  if y >= 108 and y <= 113 and (x % 9 == 0 or y == 110) and not (y >= 112 and abs(x - (VX + (342 - VX) * (y - VY) / 38)) < 3) then col = 0xf0ecd8 end
  -- wheelbarrow outside the door
  if x >= 349 and x <= 362 and y >= 124 and y <= 129 and (x - 349) >= (y - 124) // 2 and (362 - x) >= (y - 124) // 2 then col = (y == 124) and 0xe8b4a0 or 0xd69884 end
  if inell(x, y, 352, 132, 2.6, 2.6) then col = 0x9a92a0 end
  if (y == 123 or y == 124) and x >= 362 and x <= 366 then col = 0xa88e78 end
  return col
end

-- glass panes (interiors)
local PANEX = { { 183, 209 }, { 213, 239 }, { 243, 269 }, { 273, 299 } }
local PANEY = { { 35, 65 }, { 69, 99 }, { 103, 131 } }
local function paneAt(wx, wy)   -- returns distance to pane edge if inside a pane
  for _, px in ipairs(PANEX) do if wx >= px[1] and wx <= px[2] + 1 then
    for _, py in ipairs(PANEY) do if wy >= py[1] and wy <= py[2] + 1 then
      return min(wx - px[1], px[2] + 1 - wx, wy - py[1], py[2] + 1 - wy)
    end end
  end end
end

---------------------------------------------------------------- paint the room
local function floorCoord(x, y)
  local s = (y - VY) / 38
  local X = (x - VX) / s
  local dep = F * (1 - 1 / s)
  return X, dep, s
end
local function floorCol(x, y)
  local X, dep = floorCoord(x, y)
  local k = floor(X / 16)
  local X2 = floorCoord(x - 1, y)
  local jo = hash(k, 3, 7) * 80
  local j = floor((dep + jo) / 80)
  local _, dep2 = floorCoord(x, y - 1)
  if floor(X2 / 16) ~= k then return WOOD[3] end
  if y > 151 and floor((dep2 + jo) / 80) ~= j then return WOOD[3] end
  local h1 = hash(k, j, 11)
  local tone = 4 + (h1 > .62 and 1 or 0) - (h1 < .2 and 1 or 0)
  -- long grain streaks that follow the perspective
  local g = floor(X * 1.5)
  if hash(g, j + k * 3, 17) > .93 and hash(g, floor(dep / 22), 19) > .45 then return WOOD[cl(tone - 1)] end
  return WOOD[tone]
end

for y = 0, H - 1 do for x = 0, W - 1 do
  local col
  local lw = x < BX0
  local rw = x > BX1
  local topL = lw and (4 + x * .45) or (rw and (4 + (W - 1 - x) * .45) or BY0)
  local botL = lw and (157.6 - x * .19) or (rw and (157.6 - (W - 1 - x) * .19) or BY1)
  if y < topL then
    -- ceiling: boards and rafters converging
    local s = (VY - y) / 90
    local X = (x - VX) / s
    local r = (X + 400) % 80
    if r < 4 or r > 76 then col = (r > 76 and r < 78) and TIMB[5] or TIMB[4]
    elseif r >= 4 and r < 6 then col = TIMB[2]
    elseif floor((X + 400) / 13) ~= floor(((x - 1 - VX) / s + 400) / 13) then col = WOOD[2]
    else col = WOOD[3] end
  elseif y <= botL then
    if lw or rw then
      local s = abs(x - VX) / 200
      local hY = (y - VY) / s
      local b = floor((hY + 300) / 14)
      local b2 = floor(((y - 1 - VY) / s + 300) / 14)
      local base = lw and 5 or 4
      col = (b ~= b2) and WW[base - 1] or WW[base]
      if y > botL - 5 * s then col = SAGE[lw and 4 or 3] end
    else
      -- back wall: whitewashed boards
      local k = (x - BX0) // 11
      col = ((x - BX0) % 11 == 0) and WW[4] or WW[5]
      if hash(k, y // 5, 31) > .96 and (x - BX0) % 11 > 2 then col = WW[4] end
      -- daylight bloom around the glass and door
      local dg = max(GX0 - x, x - GX1, GY0 - y, 0)
      local dd = max(DX0 - 4 - x, x - DX1 - 4, DY0 - 4 - y, 0)
      if (dg < 9 or dd < 7) and col == WW[5] then col = WW[6] end
      if y <= BY0 + 3 then col = (y == BY0 + 3) and TIMB[3] or ((y == BY0) and TIMB[6] or TIMB[5]) end
      if y >= 143 then col = (y == 143) and SAGE[5] or ((y == BY1) and SAGE[2] or SAGE[4]) end
      if x <= BX0 + 4 or x >= BX1 - 4 then col = (x == BX0 or x == BX1) and TIMB[3] or ((x == BX0 + 1 or x == BX1 - 4) and TIMB[6] or TIMB[5]) end
    end
  else
    col = floorCol(x, y)
  end
  P(x, y, col)
end end
-- corner edges (wall / floor / ceiling seams)
for x = 0, BX0 do P(x, floor(157.6 - x * .19 + .5), SAGE[2]); P(W - 1 - x, floor(157.6 - x * .19 + .5), SAGE[2]) end
for x = 0, BX0 do P(x, floor(4 + x * .45 + .5), TIMB[3]); P(W - 1 - x, floor(4 + x * .45 + .5), TIMB[3]) end

-- glass wall
for y = GY0 - 1, GY1 + 5 do for x = GX0 - 1, GX1 + 1 do
  local col
  if y > GY1 then   -- sill
    col = (y == GY1 + 1) and SAGE[6] or ((y == GY1 + 5) and SAGE[1] or ((y == GY1 + 4) and SAGE[3] or SAGE[5]))
  elseif x < GX0 or x > GX1 or y < GY0 then col = SAGE[1]
  else
    local e = paneAt(x, y)
    if e then
      col = mix(outside(x, y), 0xeef8f2, .14)
      local dg = (x + y * 2) % 58
      if dg < 5 or (dg > 9 and dg < 12) then col = mix(col, 0xf8fcf2, .42) end   -- glints: pale core
      if e < 1 then col = mix(col, SAGE[2], .32) end                             -- glass rim
    else
      -- frame bars: light / mid / dark
      local vx, hy = nil, nil
      for _, b in ipairs{ 180, 210, 240, 270, 300 } do if x >= b and x <= b + 2 then vx = x - b end end
      for _, b in ipairs{ 32, 66, 100, 132 } do if y >= b and y <= b + 2 then hy = y - b end end
      local q = hy or vx
      col = (q == 0) and SAGE[6] or ((q == 1) and SAGE[5] or SAGE[3])
      if vx and hy then col = SAGE[5] end
    end
  end
  P(x, y, col)
end end
R(GX0 - 3, GY1 + 1, GX0 - 1, GY1 + 4, SAGE[5]); R(GX1 + 1, GY1 + 1, GX1 + 3, GY1 + 4, SAGE[4])
R(GX0 - 3, GY1 + 5, GX1 + 3, GY1 + 5, SAGE[1])

-- open barn door: view, frame, leaf swung in
for y = DY0, DY1 do for x = DX0, DX1 do P(x, y, outside(x, y)) end end
box(DX0 - 5, DY0 - 5, DX0 - 1, DY1, TIMB, 5)
box(DX1 + 1, DY0 - 5, DX1 + 5, DY1, TIMB, 5)
box(DX0 - 5, DY0 - 5, DX1 + 5, DY0 - 1, TIMB, 5)
do
  local leaf = mpoly{ { 372, 45 }, { 386, 39 }, { 386, 158 }, { 372, 150 } }
  fill(leaf, function(x, y)
    if (x - 372) % 5 == 0 then return SAGE[3] end
    if (x - 372) % 5 == 1 then return SAGE[5] end
    return SAGE[4]
  end)
  for x = 373, 385 do
    local t = (x - 372) / 14
    for _, by in ipairs{ 58, 136 } do
      local y = floor(by + (by - VY) * t * .12 + .5)
      P(x, y, SAGE[2]); P(x, y + 1, SAGE[5]); P(x, y + 2, SAGE[5]); P(x, y + 3, SAGE[2])
    end
  end
  edge(leaf, SAGE[1])
  R(382, 98, 384, 103, IRON[2]); R(383, 99, 383, 102, IRON[5])
end

---------------------------------------------------------------- daylight on the floor (stepped, hard pixels)
for y = 151, H - 1 do for x = 0, W - 1 do
  if not (x >= 380 and y >= 228) then
    local X, dep = floorCoord(x, y)
    local h = dep / KK
    local wx, wy = VX + X + dep * SHX, BY1 - h
    local e
    if wy <= 92 then e = paneAt(wx, wy) end                      -- the bench blocks the lower panes
    if not e and wx >= DX0 and wx <= DX1 + 1 and wy >= DY0 and wy <= DY1 then
      e = min(wx - DX0, DX1 + 1 - wx, wy - DY0)
    end
    if e then
      local g = G(x, y)
      P(x, y, mix(g, 0xfff2b6, (e < 1.3) and .26 or .56))
    else
      P(x, y, mix(G(x, y), 0x8a7aa8, .17))                        -- cool ambient on the unlit boards
    end
  end
end end
-- doormat on the threshold
do
  local mat = mpoly{ { 324, 152 }, { 362, 152 }, { 366, 161 }, { 322, 161 } }
  fill(mat, function(x, y) return ((x // 4) % 2 == 0) and GREEN[5] or LEAF[5] end)
  edge(mat, GREEN[2])
end

---------------------------------------------------------------- ceiling tie beam + hanging garden
for y = 0, 8 do for x = 0, W - 1 do
  local col = TIMB[4]
  if y == 0 then col = TIMB[3] elseif y == 1 then col = TIMB[5] elseif y >= 7 then col = (y == 8) and INK or TIMB[2]
  elseif hash(x // 9, y, 41) > .88 then col = TIMB[3] end
  P(x, y, col)
end end
R(0, 9, W - 1, 9, mix(WOOD[2], INK, .4))
local function herb(x, len, ramp, tie)
  R(x, 9, x, 9 + 4, TIMB[2])
  for i = -3, 3 do
    local l = len - abs(i) * 2 + floor(hash(x, i, 3) * 3)
    R(x + i, 14 + abs(i), x + i, 14 + l, (i % 2 == 0) and ramp[4] or ramp[5])
    if i % 3 == 0 then R(x + i, 13 + l, x + i, 14 + l, ramp[6]) end
  end
  R(x - 4, 14, x - 4, 16 + len - 8, ramp[2]); R(x + 4, 14, x + 4, 16 + len - 8, ramp[2])
  R(x - 3, 13, x + 3, 15, tie or RED[4]); R(x - 3, 13, x + 3, 13, (tie or RED[4])); R(x - 3, 16, x + 3, 16, ramp[2])
end
local function hangpot(x, drop)
  line(x - 5, 9, x - 6, drop, TIMB[3]); line(x + 5, 9, x + 6, drop, TIMB[3])
  -- foliage
  local fol = mell(x, drop - 2, 10, 6)
  fill(fol, function(xx, yy)
    local v = hash(xx // 2, yy // 2, 51)
    if (xx - x) + (yy - drop) * 2 < -6 then return v > .4 and GREEN[6] or GREEN[5] end
    return v > .55 and GREEN[5] or GREEN[4]
  end)
  edge(fol, GREEN[2])
  -- bowl
  local bowl = mpoly{ { x - 7, drop + 3 }, { x + 7, drop + 3 }, { x + 4, drop + 10 }, { x - 4, drop + 10 } }
  obj(bowl, TERRA, 4)
  -- trailing vines
  for i, v in ipairs{ { -9, 14 }, { -7, 8 }, { 8, 18 }, { 10, 9 } } do
    local vx = x + v[1]
    for k = 0, v[2] do
      local xx = vx + ((k // 3) % 2)
      P(xx, drop + 1 + k, GREEN[3])
      if k % 4 == 2 then R(xx - 1 + (i % 2) * 1, drop + 1 + k, xx + (i % 2) * 1, drop + 2 + k, GREEN[5]) end
    end
  end
  P(x - 3, drop - 5, PINK[5]); P(x - 2, drop - 5, PINK[6]); P(x + 4, drop - 3, PINK[5]); P(x + 5, drop - 3, PINK[6])
end
hangpot(132, 22)
hangpot(286, 24)
herb(112, 16, LEAF)
herb(200, 14, GREEN)
herb(214, 17, LEAF, GOLD[4])
herb(342, 15, VIOLET, GOLD[4])
herb(410, 16, LEAF)
herb(424, 13, GREEN, GOLD[4])

---------------------------------------------------------------- QUIRK: gnome hat on a hook, boots below (168..184)
do
  R(176, 62, 177, 66, IRON[2]); P(176, 62, IRON[5])
  local hat = mpoly{ { 177, 64 }, { 182, 84 }, { 171, 84 } }
  fill(hat, function(x, y) return (x < 176) and RED[5] or ((x > 179) and RED[3] or RED[4]) end)
  edge(hat, RED[1])
  R(170, 84, 183, 86, RED[3]); R(170, 84, 183, 84, RED[5]); R(170, 87, 183, 87, RED[1])
  shadow(177, 186, 8, 2, .3)
  box(170, 172, 175, 185, RED, 4); box(170, 180, 178, 185, RED, 4); R(171, 173, 174, 174, RED[6])
  box(178, 175, 183, 185, RED, 3); R(179, 176, 182, 176, RED[5])
end

---------------------------------------------------------------- 1 COOKING: brick bread oven, copper pans  [6,10,90,186]
shadow(48, 186, 46, 5, .32)
do
  -- chimney up into the rafters, flared shoulders
  bricks(mrect(34, 10, 62, 64), 10, 5, 3)
  bricks(mpoly{ { 34, 62 }, { 62, 62 }, { 88, 78 }, { 10, 78 } }, 10, 5, 4)
  R(34, 10, 62, 11, BRICK[2])
  -- dome body
  bricks(mrect(10, 78, 88, 116), 10, 5, 5)
  -- arched mouth with a stone surround
  local mouth = mell(49, 100, 18, 17, nil, "top"); mrect(31, 100, 67, 114, mouth)
  local sur = mell(49, 100, 23, 22, nil, "top"); mrect(26, 100, 72, 114, sur)
  fill(sur, function(x, y)
    local a = math.atan(y - 100, x - 49)
    local seg = floor((a + 3.2) * 3.2)
    if y >= 100 then seg = 20 + (y - 100) // 7 + (x < 49 and 0 or 5) end
    local a2 = math.atan(y - 101, x - 48)
    if y < 100 and floor((a2 + 3.2) * 3.2) ~= seg then return STONE[3] end
    if y >= 100 and (y - 100) % 7 == 0 then return STONE[3] end
    return (seg % 2 == 0) and STONE[5] or STONE[6]
  end)
  edge(sur, STONE[2])
  fill(mouth, function(x, y)
    local dd = sqrt((x - 49) ^ 2 + ((y - 114) * 1.2) ^ 2)
    if dd < 9 then return 0xa8482a end
    if dd < 15 then return 0x7a3028 end
    return 0x4a2028
  end)
  edge(mouth, INK)
  -- embers and low flames
  for x = 34, 64 do
    local hgt = 3 + floor(4 * sin(x / 2.3) ^ 2)
    R(x, 113 - hgt, x, 113, 0xe0732e)
    local h2 = 1 + floor(3 * sin(x / 2.9 + 1) ^ 2)
    if x > 37 and x < 61 then R(x, 113 - h2, x, 113, 0xf4b040) end
  end
  R(44, 111, 54, 113, 0xfce07c)
  -- hearth ledge (stone slab) and base with wood store + iron door
  box(6, 116, 90, 122, STONE, 5, { lit = 2 })
  R(30, 117, 68, 118, mix(STONE[6], 0xf4b040, .45))
  bricks(mrect(9, 123, 88, 184), 10, 5, 6)
  local store = mell(34, 152, 15, 13, nil, "top"); mrect(19, 152, 49, 182, store)
  local ssur = mell(34, 152, 18, 16, nil, "top"); mrect(16, 152, 52, 182, ssur)
  fill(ssur, function(x, y) return ((x + y) // 6 % 2 == 0) and STONE[5] or STONE[4] end); edge(ssur, STONE[2])
  fill(store, 0x3c2632); edge(store, INK)
  for _, l in ipairs{ { 26, 177 }, { 35, 177 }, { 44, 177 }, { 30, 168 }, { 40, 168 }, { 35, 159 } } do
    local m = mell(l[1], l[2], 4, 4)
    fill(m, function(x, y) local dd = (x - l[1]) ^ 2 + (y - l[2]) ^ 2; return dd <= 2 and OAK[4] or (dd <= 9 and OAK[6] or OAK[5]) end)
    edge(m, TIMB[2])
  end
  box(58, 132, 84, 160, IRON, 3, { rim = INK })
  box(61, 135, 81, 157, IRON, 4)
  R(64, 139, 78, 140, IRON[2]); R(64, 143, 78, 144, IRON[2]); R(64, 147, 78, 148, IRON[2])
  R(74, 150, 79, 153, GOLD[4]); R(74, 150, 79, 150, GOLD[6]); R(74, 154, 79, 154, IRON[1])
  box(58, 166, 84, 174, IRON, 3, { rim = INK }); R(66, 169, 76, 170, GOLD[4])
  -- pan rails either side of the chimney, copper pans
  R(8, 42, 32, 43, IRON[2]); R(8, 42, 32, 42, IRON[5]); R(64, 44, 88, 45, IRON[2]); R(64, 44, 88, 44, IRON[5])
  local function pan(cx, top, r)
    R(cx - 1, top, cx, top + 9, COPPER[2]); R(cx, top + 1, cx, top + 8, COPPER[5])
    P(cx - 1, top, IRON[1]); P(cx, top, IRON[1])
    ball(cx, top + 9 + r, r, r, COPPER)
    R(cx - r + 2, top + 9 + r - 2, cx - r + 3, top + 9 + r - 1, COPPER[6])
  end
  pan(15, 43, 6); pan(27, 43, 4); pan(70, 45, 5); pan(82, 45, 6)
  -- copper pot on the ledge, loaf of bread
  local pm = mpoly{ { 67, 102 }, { 85, 102 }, { 86, 108 }, { 84, 115 }, { 68, 115 }, { 66, 108 } }
  fill(pm, function(x, y) local r = (x - 66) / 20; return (r < .25) and COPPER[5] or ((r > .7) and COPPER[3] or COPPER[4]) end)
  edge(pm, COPPER[1])
  R(69, 104, 70, 111, COPPER[6])
  box(65, 99, 87, 102, COPPER, 5); box(73, 95, 79, 99, COPPER, 4)
  R(63, 105, 65, 107, COPPER[2]); R(87, 105, 89, 107, COPPER[2])
  local loaf = mell(19, 111, 9, 5); mrect(10, 111, 28, 115, loaf)
  fill(loaf, function(x, y) return (y < 109) and GOLD[5] or ((y > 113) and OAK[4] or GOLD[4]) end)
  edge(loaf, GOLD[1])
  for i = 0, 2 do line(14 + i * 5, 108, 16 + i * 5, 111, OAK[6]) end
end

---------------------------------------------------------------- 2 PANTRY: tall dresser of jars  [100,52,168,184]
shadow(134, 185, 38, 4, .32)
do
  box(102, 180, 109, 184, DUCK, 3); box(159, 180, 166, 184, DUCK, 3)
  box(100, 56, 168, 180, DUCK, 4, { lit = 0 })
  box(100, 52, 168, 57, DUCK, 5)
  -- open shelves
  R(104, 60, 164, 126, DUCK[2])
  R(104, 60, 164, 62, DUCK[1]); R(104, 60, 104, 126, DUCK[1])
  local SH = { 80, 103, 126 }
  local JR = { RED, GOLD, LIME, VIOLET, SKYB, PINK, TERRA, TEAL, GREEN }
  for si, sy in ipairs(SH) do
    R(104, sy + 1, 164, sy + 2, DUCK[1])
    local x, n = 106, 0
    while x < 156 do
      n = n + 1
      local w = 9 + floor(hash(si, n, 61) * 4)
      if x + w > 163 then w = 163 - x end
      local hgt = 13 + floor(hash(si, n, 62) * 5)
      local ramp = JR[(si * 4 + n * 2 + floor(hash(si, n, 63) * 2)) % #JR + 1]
      if (si + n) % 5 == 0 then
        -- glazed crock with a gloss stripe
        box(x, sy - hgt + 3, x + w - 1, sy, CREAM, 5, { rim = CREAM[1] })
        R(x + 1, sy - hgt + 8, x + w - 2, sy - hgt + 9, SKYB[3]); R(x + 2, sy - hgt + 5, x + 2, sy - 3, WW[6])
        box(x + 1, sy - hgt, x + w - 2, sy - hgt + 3, CREAM, 4, { rim = CREAM[1] })
      else
        jar(x, sy, w, hgt, ramp, (n % 2 == 0) and GOLD or OAK)
        if n % 3 == 1 then R(x + 3, sy - 7, x + w - 3, sy - 4, CREAM[6]); R(x + 3, sy - 3, x + w - 3, sy - 3, CREAM[4]) end
      end
      x = x + w + 2
    end
    R(103, sy, 165, sy, DUCK[6]); R(103, sy + 1, 165, sy + 1, DUCK[3])
  end
  -- counter and cupboard doors
  box(100, 127, 168, 133, OAK, 5, { lit = 2 })
  for _, dx in ipairs{ 104, 136 } do
    box(dx, 137, dx + 28, 176, DUCK, 4)
    box(dx + 4, 141, dx + 24, 172, DUCK, 5, { rim = DUCK[2] })
    R(dx + 7, 144, dx + 9, 160, DUCK[6])
  end
  R(129, 154, 131, 158, GOLD[2]); R(129, 154, 130, 156, GOLD[5]); R(137, 154, 139, 158, GOLD[2]); R(137, 154, 138, 156, GOLD[5])
end

---------------------------------------------------------------- 3 GARDEN: potting bench in front of the glass  [186,100,304,184]
do
  local g = 4
  tint(190 + g, 148, 292 + g, 184, SHADE, .34)             -- cool shade under the bench
  shadow(245, 186, 60, 4, .3)
  box(186 + g, 147, 193 + g, 184, OAK, 4, { lit = 0 }); box(289 + g, 147, 296 + g, 184, OAK, 3, { lit = 0 })
  -- lower shelf and what sits on it
  box(186 + g, 167, 296 + g, 172, OAK, 4)
  for i = 0, 2 do pot(207 + g + i * 2, 166 - i * 4, 14, 10, 12) end
  box(224 + g, 153, 254 + g, 166, OAK, 4); R(226 + g, 158, 252 + g, 158, OAK[2]); R(226 + g, 162, 252 + g, 162, OAK[2])
  for i = 0, 3 do
    local m = mell(229 + g + i * 7, 151, 3, 3); fill(m, (i % 2 == 0) and GOLD[4] or TERRA[4]); edge(m, GOLD[1]); P(228 + g + i * 7, 150, GOLD[6])
    R(229 + g + i * 7, 145, 229 + g + i * 7, 147, GREEN[5])
  end
  pot(270 + g, 166, 16, 12, 14, TERRA)
  pot(283 + g, 166, 10, 8, 10, SKYB)
  -- top
  box(182 + g, 140, 300 + g, 146, OAK, 5, { lit = 2 })
  R(183 + g, 141, 299 + g, 141, OAK[6]); R(183 + g, 142, 299 + g, 142, WOOD[6])
  box(186 + g, 146, 296 + g, 151, OAK, 3)
  -- compost sack (open, dark soil, trowel)
  local sack = mpoly{ { 187 + g, 139 }, { 186 + g, 121 }, { 190 + g, 114 }, { 205 + g, 114 }, { 209 + g, 121 }, { 208 + g, 139 } }
  fill(sack, function(x, y)
    local r = (x - 186 - g) / 23
    local t = (r < .3) and 5 or ((r > .72) and 3 or 4)
    if ((x // 2) + (y // 2)) % 2 == 0 and r >= .3 and r <= .72 then t = 5 end
    return BURLAP[t]
  end)
  edge(sack, BURLAP[1])
  local soil = mell(197 + g, 114, 8, 3); fill(soil, function(x, y) return (y < 114) and DIRT[2] or DIRT[1] end); edge(soil, BURLAP[1])
  R(199 + g, 103, 201 + g, 112, OAK[6]); R(201 + g, 103, 201 + g, 112, OAK[4]); R(198 + g, 102, 202 + g, 102, OAK[2])
  R(198 + g, 110, 202 + g, 113, IRON[5]); R(202 + g, 110, 202 + g, 113, IRON[3])
  -- leaf mark on the sack (no letters)
  local lm = mell(197 + g, 128, 4, 5); fill(lm, GREEN[4]); R(197 + g, 124, 197 + g, 132, GREEN[6]); edge(lm, GREEN[2])
  -- big pot with a bushy plant
  pot(219 + g, 139, 16, 11, 15)
  local bush = mell(219 + g, 113, 10, 10)
  fill(bush, function(x, y)
    local v = hash(x // 3, y // 3, 71)
    if (x - 219 - g) + (y - 113) < -5 then return v > .45 and LEAF[5] or GREEN[6] end
    if (x - 219 - g) + (y - 113) > 7 then return v > .5 and GREEN[3] or GREEN[4] end
    return v > .5 and GREEN[5] or GREEN[4]
  end)
  edge(bush, GREEN[2])
  for _, f in ipairs{ { 213, 108 }, { 222, 105 }, { 225, 114 }, { 216, 117 } } do
    R(f[1] + g, f[2], f[1] + g + 2, f[2] + 2, PINK[5]); P(f[1] + g + 1, f[2] + 1, GOLD[5]); P(f[1] + g, f[2], PINK[6])
  end
  -- seed tray with rows of sprouts
  box(231 + g, 131, 263 + g, 139, OAK, 5)
  R(232 + g, 132, 262 + g, 133, DIRT[1]); R(232 + g, 132, 262 + g, 132, DIRT[2])
  for i = 0, 5 do
    local x = 235 + g + i * 5
    local hgt = 5 + (i * 3) % 4
    R(x, 131 - hgt, x + 1, 131, GREEN[3]); R(x, 131 - hgt, x, 131, GREEN[5])
    R(x - 2, 129 - hgt, x - 1, 131 - hgt, GREEN[5]); R(x + 2, 128 - hgt, x + 3, 130 - hgt, GREEN[6])
    R(x - 2, 129 - hgt, x - 2, 129 - hgt, GREEN[6]); P(x + 1, 130 - hgt, GREEN[6])
  end
  -- watering can
  local spout = mpoly{ { 284 + g, 130 }, { 284 + g, 135 }, { 296 + g, 120 }, { 294 + g, 117 } }
  fill(spout, SKYB[4]); edge(spout, SKYB[1])
  box(293 + g, 113, 299 + g, 120, SKYB, 5)
  for y = 123, 133 do for x = 262 + g, 268 + g do
    if x == 262 + g or y == 123 or y == 133 then P(x, y, SKYB[1]) elseif x == 263 + g or y == 124 or y == 132 then P(x, y, SKYB[5]) end
  end end
  box(268 + g, 120, 285 + g, 139, SKYB, 4, { lit = 2, shade = 2 })
  R(270 + g, 123, 271 + g, 135, SKYB[6]); R(269 + g, 129, 284 + g, 129, SKYB[3])
  R(269 + g, 118, 284 + g, 120, SKYB[2]); R(270 + g, 119, 283 + g, 119, SKYB[6])
end

---------------------------------------------------------------- 4 TOOLS: bench, vice, pegboard  [394,64,474,186]
do
  tint(405, 149, 463, 185, SHADE, .34)
  shadow(434, 187, 42, 4, .3)
  -- pegboard
  box(396, 66, 472, 139, OAK, 5, { rim = TIMB[2] })
  box(396, 64, 472, 68, TIMB, 5)
  for y = 74, 134, 7 do for x = 402, 468, 7 do P(x, y, OAK[3]); P(x + 1, y, OAK[3]) end end
  -- hammer
  box(408, 76, 412, 100, OAK, 5, { rim = TIMB[1] })
  box(401, 72, 419, 80, IRON, 5, { rim = INK }); R(403, 74, 417, 74, IRON[6])
  -- wrench
  box(423, 78, 427, 99, IRON, 5, { rim = INK })
  box(421, 72, 429, 79, IRON, 5, { rim = INK }); R(424, 72, 426, 75, OAK[5]); R(423, 72, 423, 75, INK); R(427, 72, 427, 75, INK)
  -- saw
  local blade = mpoly{ { 440, 73 }, { 458, 76 }, { 458, 83 }, { 440, 86 } }
  fill(blade, function(x, y) return (y < 78) and IRON[6] or IRON[5] end); edge(blade, INK)
  for x = 441, 457, 2 do P(x, floor(86 - (x - 440) * 3 / 18 + .5), IRON[6]) end
  box(432, 71, 441, 88, TIMB, 5); R(435, 76, 438, 82, OAK[5]); R(435, 76, 438, 76, TIMB[2]); R(435, 76, 435, 82, TIMB[2])
  -- chisels and a try-square (the left of this row stays free for the busy hammer)
  for i, rp in ipairs{ RED, GOLD, SKYB } do
    local x = 426 + i * 8
    box(x, 106, x + 4, 119, rp, 4)
    box(x + 1, 119, x + 3, 132, IRON, 5, { rim = INK })
  end
  box(458, 104, 463, 132, OAK, 4); box(463, 104, 470, 108, IRON, 5, { rim = INK })
  -- bench top, apron drawer, legs
  box(396, 148, 404, 185, OAK, 4, { lit = 0 }); box(464, 148, 472, 185, OAK, 3, { lit = 0 })
  box(404, 148, 464, 160, OAK, 4)
  box(410, 151, 458, 158, OAK, 5, { rim = OAK[2] }); R(430, 154, 438, 155, IRON[3]); R(430, 154, 438, 154, IRON[6])
  box(394, 140, 474, 147, OAK, 5, { lit = 2 })
  R(395, 141, 473, 141, WOOD[6])
  -- vice with a clamped offcut
  box(406, 113, 411, 130, WOOD, 5, { rim = OAK[1] }); R(408, 116, 408, 121, WOOD[3])
  box(399, 124, 406, 139, IRON, 4, { rim = INK }); box(411, 124, 418, 139, IRON, 4, { rim = INK })
  R(400, 125, 405, 126, IRON[6]); R(412, 125, 417, 126, IRON[6])
  box(418, 130, 427, 134, IRON, 5, { rim = INK })
  box(426, 123, 429, 141, IRON, 3, { rim = INK }); R(427, 124, 428, 125, IRON[6])
  -- plane, shavings, nail tin
  box(438, 133, 458, 139, TIMB, 5); box(442, 128, 447, 133, TIMB, 4); box(452, 126, 456, 133, OAK, 5)
  for i = 0, 3 do R(431 + i * 2, 138 - (i % 2), 432 + i * 2, 139 - (i % 2), CREAM[6]) end
  box(462, 130, 470, 139, TEAL, 4); R(463, 131, 469, 132, IRON[5])
  -- red toolbox under the bench
  box(414, 166, 446, 184, RED, 4, { lit = 2, shade = 2 })
  R(415, 172, 445, 172, RED[2]); box(426, 162, 434, 166, IRON, 4, { rim = INK }); R(428, 174, 432, 177, GOLD[4]); R(428, 174, 432, 174, GOLD[6])
end

---------------------------------------------------------------- QUIRK: veg basket by the door, floor sprout
do
  shadow(380, 181, 10, 2, .3)
  for _, v in ipairs{ { 375, 166, RED }, { 381, 164, GOLD }, { 386, 167, RED } } do
    ball(v[1], v[2], 3, 3, v[3]); P(v[1], v[2] - 4, GREEN[4]); P(v[1] + 1, v[2] - 4, GREEN[5])
  end
  local bk = mpoly{ { 371, 168 }, { 389, 168 }, { 387, 180 }, { 373, 180 } }
  fill(bk, function(x, y) return (((x // 3) + (y // 2)) % 2 == 0) and BURLAP[5] or BURLAP[3] end)
  edge(bk, BURLAP[1]); R(371, 168, 389, 169, BURLAP[6]); R(371, 167, 389, 167, BURLAP[1])
  -- a seedling that found a gap in the boards
  R(138, 196, 138, 201, GREEN[3]); R(135, 193, 137, 195, GREEN[5]); R(139, 191, 141, 194, GREEN[6]); P(135, 193, GREEN[6])
  R(136, 202, 140, 202, WOOD[2])
end

---------------------------------------------------------------- 5 POTIONS: copper still on a brazier  [16,196,112,262]
shadow(62, 261, 50, 5, .34)
do
  -- brazier
  for _, lx in ipairs{ 33, 66 } do box(lx, 249, lx + 4, 261, IRON, 3, { rim = INK }) end
  box(49, 249, 53, 259, IRON, 2, { rim = INK })
  local bowl = mpoly{ { 28, 240 }, { 74, 240 }, { 67, 251 }, { 35, 251 } }
  obj(bowl, IRON, 4, { rim = INK })
  for x = 31, 71 do
    local v = hash(x // 3, 1, 81)
    R(x, 238, x, 240, v > .6 and 0xf4b040 or (v > .25 and 0xe0732e or 0x8a3028))
    if v > .75 then P(x, 237, 0xfce07c) end
  end
  for x = 30, 72 do if (x // 4) % 2 == 0 then R(x, 243, x + 1, 247, 0xe0732e); P(x, 244, 0xf4b040) end end
  -- pot belly
  local body = ball(50, 221, 28, 18, COPPER, { rim = COPPER[1] })
  for x = 23, 77 do if mhas(body, x, 222) then P(x, 222, COPPER[2]); P(x, 223, COPPER[6]) end end
  for x = 28, 72, 7 do R(x, 218, x + 1, 219, COPPER[6]); P(x + 1, 219, COPPER[2]) end
  for x = 36, 64 do P(x, 237, 0xf8c070) end
  R(33, 209, 37, 212, COPPER[6]); R(30, 212, 33, 217, COPPER[6])
  -- helmet, swan neck, coil, receiving flask
  local helm = mell(51, 205, 12, 7, nil, "top"); mrect(39, 205, 63, 207, helm)
  obj(helm, COPPER, 5)
  box(47, 196, 55, 199, COPPER, 4)
  box(56, 198, 99, 202, COPPER, 5)
  box(94, 198, 99, 229, COPPER, 4)
  for _, cy in ipairs{ 207, 213, 219 } do
    box(90, cy, 103, cy + 3, COPPER, 5)
  end
  -- round flask of tonic
  local fl = mell(96, 245, 10, 10)
  fill(fl, function(x, y)
    if y < 241 then return mix(LIME[6], 0xf2f6ea, .5) end
    local nx = (x - 96) / 10
    return (nx < -.45) and LIME[5] or ((nx > .45) and LIME[3] or LIME[4])
  end)
  edge(fl, LIME[1])
  R(90, 241, 102, 241, LIME[6]); R(90, 243, 91, 248, LIME[6])
  for y = 228, 236 do P(93, y, LIME[1]); P(99, y, LIME[1]); R(94, y, 98, y, mix(LIME[6], 0xf2f6ea, .5)) end
  R(92, 227, 100, 228, LIME[1])
  R(90, 256, 102, 258, OAK[3]); R(90, 256, 102, 256, OAK[5]); R(89, 259, 103, 259, OAK[1])
  -- bottles
  bottle(17, 260, 9, 26, VIOLET)
  bottle(76, 260, 8, 16, GOLD)
  bottle(106, 260, 7, 20, PINK)
end

---------------------------------------------------------------- 6 BUILDING: sawhorse + planks, stone, rope, bricks  [150,200,268,262]
shadow(212, 261, 64, 5, .34)
do
  -- sawhorse
  local function leg(xt, xb)
    local m = mpoly{ { xt, 224 }, { xt + 4, 224 }, { xb + 4, 260 }, { xb, 260 } }
    fill(m, function(x, y) return TIMB[4] end); edge(m, TIMB[1])
    meach(m, function(x, y) if mhas(m, x - 1, y) and not mhas(m, x - 2, y) then P(x, y, TIMB[6]) end end)
  end
  leg(160, 166); leg(194, 188)
  box(160, 240, 198, 244, TIMB, 3)
  leg(155, 150); leg(199, 202)
  box(152, 219, 206, 225, TIMB, 5)
  -- planks
  local pl = { { 150, 214, 206, 219, 5 }, { 153, 209, 204, 214, 4 }, { 151, 204, 200, 209, 5 }, { 158, 200, 206, 204, 4 } }
  for i, p in ipairs(pl) do
    box(p[1], p[2], p[3], p[4], WOOD, p[5], { lit = 1, shade = 0, rim = WOOD[1] })
    for k = 0, 3 do R(p[1] + 6 + k * 12 + i * 3, p[2] + 2, p[1] + 10 + k * 12 + i * 3, p[2] + 2, WOOD[3]) end
    box(p[1], p[2], p[1] + 3, p[4], WOOD, 6, { rim = WOOD[1] })
  end
  -- stone blocks
  local function stone(x0, y0, x1, y1, b, s)
    box(x0, y0, x1, y1, STONE, b, { lit = 2, shade = 2, rim = STONE[1] })
    for i = 1, 5 do
      local x, y = x0 + 3 + floor(hash(i, s, 91) * (x1 - x0 - 7)), y0 + 5 + floor(hash(i, s, 92) * (y1 - y0 - 9))
      R(x, y, x + 1, y, STONE[cl(b - 1)])
    end
  end
  stone(210, 238, 230, 260, 4, 1); stone(230, 238, 250, 260, 5, 2); stone(215, 217, 245, 238, 5, 3)
  line(238, 221, 235, 227, STONE[3]); line(235, 227, 237, 232, STONE[3])
  -- coil of rope on the top block
  for i = 0, 1 do
    local cy = 214 - i * 4
    local ring = mell(230, cy, 12, 4)
    fill(ring, function(x, y) return ((x + (y % 2)) // 2 % 2 == 0) and BURLAP[6] or BURLAP[4] end)
    edge(ring, BURLAP[1])
  end
  local hole = mell(230, 209, 6, 1); fill(hole, BURLAP[1])
  for y = 216, 231 do local x = 240 + ((y // 4) % 2); P(x, y, BURLAP[1]); P(x + 1, y, (y % 2 == 0) and BURLAP[6] or BURLAP[4]); P(x + 2, y, BURLAP[1]) end
  R(240, 232, 243, 234, BURLAP[5]); R(240, 235, 243, 235, BURLAP[1])
  -- bricks
  local function brick(x, y, w, b) box(x, y, x + w - 1, y + 5, BRICK, b, { rim = BRICK[1] }) end
  brick(253, 255, 10, 4); brick(263, 255, 10, 5)
  brick(253, 250, 5, 5); brick(258, 250, 10, 4); brick(268, 250, 5, 4)
  brick(253, 245, 10, 5); brick(263, 245, 10, 4)
  brick(253, 240, 5, 4); brick(258, 240, 10, 5); brick(268, 240, 5, 4)
  brick(256, 235, 10, 4)
end

---------------------------------------------------------------- 7 DECOR: loom with bright cloth, paints  [284,196,372,262]
shadow(328, 261, 46, 5, .34)
do
  tint(295, 205, 345, 256, SHADE, .3)
  -- warp threads
  for y = 205, 217 do for x = 296, 344 do P(x, y, (x % 2 == 0) and CREAM[6] or CREAM[4]) end end
  -- woven cloth: bright bands with a chunky weave
  local bands = { PINK, GOLD, SKYB, LIME, VIOLET, RED, GOLD }
  for y = 218, 240 do for x = 296, 344 do
    local bi = (y - 218) // 4 + 1
    local rp = bands[min(#bands, bi)]
    local t = ((x // 2 + y // 2) % 2 == 0) and 5 or 4
    if (y - 218) % 4 == 3 then t = 3 end
    P(x, y, rp[t])
  end end
  R(296, 218, 344, 218, CREAM[6])
  -- frame
  box(284, 257, 298, 261, OAK, 4); box(342, 257, 356, 261, OAK, 4)
  box(288, 198, 294, 258, OAK, 5, { lit = 0 }); box(346, 198, 352, 258, OAK, 4, { lit = 0 })
  box(286, 197, 354, 204, OAK, 5, { lit = 2 })
  for x = 298, 342, 4 do R(x, 199, x + 1, 202, CREAM[5]) end
  box(293, 212, 347, 217, WOOD, 5, { rim = OAK[1] })
  box(286, 240, 354, 246, OAK, 4)
  -- cloth end draped over the front beam, with a fringe
  for y = 241, 254 do for x = 322, 344 do
    local rp = bands[((y - 241) // 3) % #bands + 1]
    P(x, y, (x == 322 or x == 344) and rp[2] or rp[((x // 2 + y // 2) % 2 == 0) and 5 or 4])
  end end
  for x = 322, 344, 2 do R(x, 255, x, 257, CREAM[6]) end
  R(322, 240, 344, 240, INK)
  -- yarn basket
  for _, b in ipairs{ { 304, 245, PINK }, { 311, 243, SKYB }, { 317, 246, GOLD } } do
    ball(b[1], b[2], 4, 4, b[3]); line(b[1] - 2, b[2] + 1, b[1] + 2, b[2] - 2, b[3][6])
  end
  local bk = mpoly{ { 299, 248 }, { 321, 248 }, { 319, 260 }, { 301, 260 } }
  fill(bk, function(x, y) return (((x // 3) + (y // 2)) % 2 == 0) and BURLAP[5] or BURLAP[3] end)
  edge(bk, BURLAP[1]); R(299, 248, 321, 249, BURLAP[6]); R(299, 247, 321, 247, BURLAP[1])
  -- paint tins and a brush
  box(358, 248, 371, 261, PINK, 4, { lit = 2, shade = 2 }); R(359, 249, 370, 250, PINK[6]); R(362, 251, 363, 255, PINK[6])
  box(359, 236, 370, 248, SKYB, 4, { lit = 2, shade = 2 }); R(360, 237, 369, 238, SKYB[6]); R(366, 239, 367, 243, SKYB[6])
  R(363, 224, 365, 235, OAK[1]); R(364, 225, 364, 235, OAK[6]); R(363, 221, 365, 224, GOLD[4]); R(363, 221, 365, 221, GOLD[2])
end

---------------------------------------------------------------- flush base picture
for y = 0, H - 1 do for x = 0, W - 1 do
  local v = BASE.d[y * W + x]
  c:put(x, y, string.format("#%06x", v or 0xff00ff))
end end
c:save{ aseprite = d .. "/craft-workshop.aseprite", png = d .. "/craft-workshop.png", scale = 1 }

---------------------------------------------------------------- "ready" animation layers
local ANIM = {}
local function layer(k, sec, fx, x, y, w, h, draw)
  T = newT(x, y, w, h)
  draw()
  local img = Image(w, h, ColorMode.RGB)
  for yy = 0, h - 1 do for xx = 0, w - 1 do
    local v = T.d[yy * w + xx]
    if v then img:drawPixel(xx, yy, app.pixelColor.rgba(v >> 16, (v >> 8) & 255, v & 255, 255)) end
  end end
  img:saveAs(d .. "/craft-anim-" .. k .. ".png")
  ANIM[#ANIM + 1] = string.format('{"k":"%s","for":"%s","fx":"%s","x":%d,"y":%d,"w":%d,"h":%d}', k, sec, fx, x, y, w, h)
  T = BASE
end

-- cooking: tall flames in the oven mouth (flicker) + steam over the copper pot (bob)
layer("cooking", "cooking", "flicker", 32, 86, 35, 28, function()
  for x = 33, 65 do
    local a = 8 + floor(13 * sin((x - 30) / 5.5) ^ 2 * (1 - abs(x - 49) / 22))
    local b = 5 + floor(9 * sin((x - 28) / 4.2 + 1) ^ 2 * (1 - abs(x - 49) / 20))
    local e = 2 + floor(5 * sin((x - 30) / 3.1 + 2) ^ 2)
    R(x, 113 - a, x, 113, 0xe0732e)
    if x > 35 and x < 63 then R(x, 113 - b, x, 113, 0xf4b040) end
    if x > 40 and x < 58 then R(x, 113 - e, x, 113, 0xfce07c) end
  end
  for _, s in ipairs{ { 38, 92 }, { 47, 88 }, { 58, 91 } } do R(s[1], s[2], s[1] + 1, s[2] + 1, 0xfce07c) end
end)
layer("cooking2", "cooking", "bob", 64, 74, 26, 22, function()
  for _, p in ipairs{ { 72, 90, 4, 3 }, { 78, 84, 5, 3 }, { 73, 79, 3, 2 }, { 82, 78, 3, 2 } } do
    local m = mell(p[1], p[2], p[3], p[4]); fill(m, WW[6]); edge(m, WW[4])
  end
end)
-- pantry: glints on the jars (twinkle)
layer("pantry", "pantry", "twinkle", 102, 58, 64, 70, function()
  spark(112, 70, true); spark(150, 68); spark(131, 92, true); spark(158, 95); spark(116, 116); spark(144, 114, true)
end)
-- tools: a raised mallet over the vice (bob) + sparks (twinkle)
layer("tools", "tools", "bob", 397, 90, 34, 24, function()
  local hd = mpoly{ { 400, 100 }, { 412, 94 }, { 416, 102 }, { 404, 108 } }
  fill(hd, function(x, y) return (y < 99) and WOOD[6] or ((y > 104) and WOOD[3] or WOOD[5]) end); edge(hd, OAK[1])
  for i = 0, 14 do
    local x, y = 411 + i, floor(101 + i * .55 + .5)
    P(x, y - 1, OAK[1]); P(x, y, OAK[6]); P(x, y + 1, OAK[4]); P(x, y + 2, OAK[1])
  end
end)
layer("tools2", "tools", "twinkle", 392, 104, 36, 22, function()
  spark(398, 114, true); spark(419, 110); spark(409, 108)
  R(394, 121, 395, 122, GOLD[5]); R(423, 119, 424, 120, GOLD[5])
end)
-- garden: a tall new shoot nodding in the seed tray (sway) + drops from the can (twinkle)
layer("garden", "garden", "sway", 240, 100, 21, 32, function()
  for y = 108, 131 do local x = 250 + ((y < 116) and 1 or 0); P(x, y, GREEN[3]); P(x + 1, y, GREEN[5]) end
  local l1 = mell(245, 119, 4, 2); fill(l1, GREEN[5]); edge(l1, GREEN[2])
  local l2 = mell(256, 114, 4, 2); fill(l2, GREEN[6]); edge(l2, GREEN[2])
  local bud = mell(251, 105, 4, 4); fill(bud, function(x, y) return (x + y < 355) and GOLD[6] or GOLD[4] end); edge(bud, GOLD[2])
  R(250, 104, 252, 106, 0xfff0b0); P(251, 105, GOLD[3])
end)
layer("garden2", "garden", "twinkle", 294, 121, 12, 18, function()
  for _, p in ipairs{ { 296, 123 }, { 300, 126 }, { 297, 130 }, { 302, 133 }, { 299, 136 } } do
    R(p[1], p[2], p[1] + 1, p[2] + 2, SKYB[5]); P(p[1], p[2], SKYB[6]); P(p[1] + 1, p[2] + 2, SKYB[3])
  end
end)
-- potions: the flask glows (pulse) + bubbles rise (bob)
layer("potions", "potions", "pulse", 84, 233, 25, 25, function()
  local fl = mell(96, 245, 10, 10)
  fill(fl, function(x, y)
    if y < 239 then return nil end
    local dd = sqrt((x - 95) ^ 2 + (y - 246) ^ 2)
    return (dd < 4) and 0xf4ffd0 or ((dd < 7) and LIME[6] or LIME[5])
  end)
  edge(fl, LIME[6])
  spark(92, 240)
end)
layer("potions2", "potions", "bob", 76, 208, 14, 30, function()
  for _, b in ipairs{ { 80, 232, 2 }, { 85, 224, 3 }, { 80, 215, 2 }, { 86, 211, 1 } } do
    local m = mell(b[1], b[2], b[3], b[3]); fill(m, LIME[5]); edge(m, LIME[2]); P(b[1] - 1, b[2] - 1, LIME[6])
  end
end)
-- building: the top plank teeters (sway) + fresh-cut glints (twinkle)
layer("building", "building", "sway", 156, 198, 52, 8, function()
  box(158, 200, 206, 204, WOOD, 5, { lit = 1, shade = 0, rim = WOOD[1] })
  for k = 0, 3 do R(170 + k * 10, 202, 174 + k * 10, 202, WOOD[3]) end
  box(158, 200, 161, 204, WOOD, 6, { rim = WOOD[1] })
end)
layer("building2", "building", "twinkle", 152, 202, 118, 52, function()
  spark(176, 207, true); spark(222, 226); spark(240, 248, true); spark(262, 243); spark(160, 216)
end)
-- decor: the shuttle slides across the cloth (drift) + the brush dips (bob)
layer("decor", "decor", "drift", 312, 219, 16, 6, function()
  local sh = mpoly{ { 313, 221 }, { 316, 219 }, { 323, 219 }, { 326, 221 }, { 323, 224 }, { 316, 224 } }
  fill(sh, function(x, y) return (y < 221) and OAK[6] or OAK[5] end); edge(sh, TIMB[1])
  R(317, 221, 322, 222, RED[4]); R(317, 221, 322, 221, RED[6])
end)
layer("decor2", "decor", "bob", 361, 216, 7, 20, function()
  R(363, 222, 365, 235, OAK[1]); R(364, 223, 364, 235, OAK[6]); R(363, 218, 365, 222, GOLD[4]); R(363, 218, 365, 218, GOLD[2])
  P(364, 217, SKYB[5])
end)

---------------------------------------------------------------- layout.json
local spots = {
  { "cooking", "Cooking", 6, 10, 90, 186 }, { "pantry", "Pantry", 100, 52, 168, 184 },
  { "tools", "Tools", 394, 64, 474, 186 }, { "garden", "Garden", 186, 100, 304, 184 },
  { "potions", "Potions", 16, 196, 112, 262 }, { "building", "Building", 150, 200, 272, 262 },
  { "decor", "Decor", 284, 196, 372, 262 },
}
local sp = {}
for i, s in ipairs(spots) do
  sp[i] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], (s[3] + s[5]) // 2, (s[4] + s[6]) // 2, s[3], s[4], s[5], s[6])
end
local f = io.open(d .. "/layout.json", "w")
f:write('{"w":480,"h":270,\n "spots":[\n  ' .. table.concat(sp, ",\n  ") .. '\n ],\n "anim":[\n  ' .. table.concat(ANIM, ",\n  ") .. '\n ]}\n')
f:close()
