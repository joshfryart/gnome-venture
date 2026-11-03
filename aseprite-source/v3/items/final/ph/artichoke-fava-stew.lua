-- artichoke-fava-stew (final pass, Opus). A shallow terracotta cazuela with two lug handles: honey glaze on the rim
-- and upper belly ending in an uneven drip line over the raw, speckled clay foot; bevelled rim with a bright lit lip.
-- Golden olive-oil broth (darker under the back wall, oil-bead glints), a halved artichoke standing in it showing its
-- cut face (green outer scales with pointed crown, nested pale leaf layers, purple fibrous choke, cream heart, pale
-- stem core), bright fava beans with dark hilum eyes, parsley flecks and a slim wooden spoon with grain.
-- quirk: one curl of steam rising in an S over the pot.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "artichoke-fava-stew"
local c = A.new(NAME)

local CLAY  = { "#4a2026", "#72302c", "#9a4632", "#be623c", "#d98954", "#f0b27a" }
local GLAZE = { "#3f1c1c", "#64301e", "#8c4a22", "#b46a2a", "#d8923c", "#f6c46c" }
local BROTH = { "#7a4618", "#a4661c", "#cc8c26", "#e6b23e", "#f6d468", "#fff0a8" }
local GR    = { "#1b332f", "#28503f", "#3b6f4a", "#578c55", "#7ea866", "#aac884" }
local FAVA  = { "#1f4a2c", "#2c6a34", "#46903e", "#68b44a", "#98d466", "#cff092" }
local WOOD  = { "#4a2c26", "#6e4430", "#946240", "#b98452", "#d8aa72", "#f0d29c" }
local PALE  = { "#9aa86a", "#c2cc84", "#e0e2a8", "#f4f0c8" }
local CHOKE = { "#3a2142", "#5c3466", "#84528a", "#a878aa" }
local STEAM = { "#bcb4c8", "#e2dce4", "#f8f2ea" }

c:groundShadow(32, 52, 19, 2)

-- spoon (behind everything in the pot): handle out to the upper right
local wtok = { r = { name = "spoon" } }
local spm, spn, SPT, SPS = A.stem(c, { { 43, 36 }, { 46, 29 }, { 50, 21 }, { 53, 13 } }, function(t) return 1.25 end, WOOD, { tok = wtok, amb = 0.12 })
spm:each(function(x, y) local k = K(x, y) if (SPT[k] * 26) % 7 < 1 and SPS[k] > -0.2 then c:put(x, y, WOOD[2], wtok) end end) -- grain dashes
c:put(53, 12, WOOD[5], wtok) c:put(52, 12, WOOD[6], wtok)  -- pale end grain

-- cazuela body
local CX, RY0 = 32, 35
local body = HP.mask()
for y = RY0, 50 do
  local t = (y - RY0) / 15
  local h = 22 - 4.5 * t ^ 1.6 - (t > 0.86 and (t - 0.86) * 14 or 0)
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end
end
local n = {}
body:each(function(x, y)
  local t = (y - RY0) / 15 local h = 22 - 4.5 * t ^ 1.6
  local sx = max(-0.96, min(0.96, (x - CX + 0.5) / (h + 0.6)))
  local sy = 0.35 + t * 0.55
  n[K(x, y)] = { A.norm(sx, sy, sqrt(max(0.05, 1 - sx * sx))) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local glaze, raw = HP.mask(), HP.mask()
body:each(function(x, y)
  local drip = 43 + floor(1.2 * sin(x * 0.9) + (X.hash(x, 0, 3) > 0.78 and 2 or 0) + 0.5)
  if y < drip then glaze:set(x, y) else raw:set(x, y) end
end)
local ctok = { r = { name = "pot" } }
local gb = {}
X.tone(c, glaze, v, GLAZE, { cuts = { 0.18, 0.34, 0.52, 0.7, 0.86 }, tok = ctok, bias = gb })
local rb = {}
raw:each(function(x, y) local k = K(x, y) if X.hash(x, y, 9) > 0.86 then rb[k] = -1 end end)
X.ao(rb, raw, glaze, 1, -1)
X.tone(c, raw, v, CLAY, { cuts = { 0.18, 0.34, 0.52, 0.7, 0.86 }, tok = ctok, bias = rb })
-- glaze specular streak on the left belly
for _, p in ipairs{ { 14, 38 }, { 14, 39 }, { 15, 40 } } do c:put(p[1], p[2], GLAZE[6], ctok) end

-- lug handles
local function lug(x0, dir)
  local m = HP.mask()
  for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 }, { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 }, { 0, 3 }, { 1, 3 }, { 2, 3 } } do
    m:set(x0 + dir * p[1], 36 + p[2]) end
  m:cut(body)
  m:each(function(x, y) local e = (dir < 0) and (y <= 37 and 5 or 4) or (y <= 37 and 3 or 2)
    if y == 39 then e = e - 1 end c:put(x, y, GLAZE[e], ctok) end)
  c:put(x0 + dir * 1, 37, GLAZE[1], ctok) -- finger hole shadow
  c:put(x0 + dir * 1, 38, GLAZE[2], ctok)
end
lug(9, -1) lug(54, 1)

-- rim: elliptical lip, lit at the back-left
local rimO = c:ellipse(31.5, 34, 22.5, 6.5)
local rimI = c:ellipse(31.5, 34.4, 20.2, 5)
local lip = rimO:copy():cut(rimI)
lip:each(function(x, y)
  local a = math.atan(y - 34, x - 31.5)
  local lit = -cos(a + 2.2)                          -- 1 at back-left
  local front = y > 34
  local i = front and (y >= 39 and 3 or 4) or (lit > 0.5 and 6 or (lit > -0.2 and 5 or 4))
  if front and lit < -0.5 then i = 3 end
  c:put(x, y, GLAZE[i], ctok)
end)
-- inner back wall (in shade) and broth
local wall = rimI:copy()
wall:each(function(x, y) c:put(x, y, GLAZE[y < 33 and 2 or 3], ctok) end)
local broth = c:ellipse(31.5, 35, 19.6, 4.2):clip(rimI)
local btok = { r = { name = "broth" } }
broth:each(function(x, y)
  local i = 4
  if y <= 32 then i = 2 elseif y <= 33 then i = 3 end
  if y >= 38 then i = 5 end
  if x > 47 and y <= 35 then i = i - 1 end
  c:put(x, y, BROTH[i], btok)
end)
-- oil beads
for _, p in ipairs{ { 17, 36 }, { 36, 37 }, { 45, 38 }, { 29, 38 }, { 41, 34 } } do c:put(p[1], p[2], BROTH[6], btok) c:put(p[1] + 1, p[2], BROTH[3], btok) end

-- halved artichoke, cut face to the viewer, sunk into the broth
local atok = { r = { name = "art" } }
local AX, ATOP = 23, 11
-- outline: pointed crown at the top, widest at y 21, rounding into a 4 px stem
local function ahw(y)
  if y < ATOP then return -1 end
  local h
  if y < 22 then local t = (y - ATOP + 1) / 11 h = 9.4 * t ^ 0.8
  elseif y < 30 then local t = (y - 22) / 8 h = 2.8 + 6.6 * sqrt(max(0, 1 - t ^ 2.4))
  else h = 2.8 end
  if y < 28 and (y - ATOP) % 3 == 2 then h = h - 0.9 end      -- stepped scale tips along the sides
  return h
end
local am = HP.mask()
for y = ATOP, 36 do local h = ahw(y)
  for x = floor(AX - h + 0.5), floor(AX + h - 0.5) do am:set(x, y) end end
am:cut(broth:copy():cut(c:rect(0, 0, 63, 35)))   -- broth laps over the bottom
local dmap = X.dist(am)
local an = X.pillow(am, 2.5)
local av = X.light(an, { amb = 0.12, wrap = 0.3 })
local aidx = X.tone(c, am, av, GR, { cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 }, tok = atok })
local CHY = 26          -- choke base line
am:each(function(x, y) local k = K(x, y) local d = dmap[k]
  local dx, dy = x - AX + 0.5, y - CHY
  if d >= 2.4 and y < 31 then
    -- nested inner bracts: thin layer lines paralleling the outline (chevrons converging to the crown)
    local band = (d - 2.4) % 2.0
    local i = band < 0.8 and 1 or 3
    if d > 6 then i = band < 0.8 and 2 or 4 end
    if dx > 3 then i = max(1, i - 1) end
    c:put(x, y, PALE[i], atok)
  end
  -- choke: rounded fibrous dome, purple, fibres fanning from the base centre
  local q = (dx * dx) / 22 + (dy * dy) / 16
  if dy <= 0 and q <= 1 and d >= 3.4 then
    local ang = math.atan(dy, dx)
    local f = (ang * 7.5) % 1
    local j = f < 0.45 and 3 or 2
    if q > 0.6 and dy < -1 then j = 4 end                  -- pale fringe at the top of the dome
    if dx > 2.5 then j = j - 1 end
    c:put(x, y, CHOKE[max(1, min(4, j))], atok)
  end
  -- heart: cream cup under the choke, narrowing into the stem core
  if dy > 0 and d >= 2.4 and abs(dx) < 4.6 - dy * 0.75 then c:put(x, y, (dx > 1.5 and PALE[3]) or PALE[4], atok) end
end)
for y = 30, 35 do c:put(AX, y, PALE[3], atok) end
c:put(AX - 1, 30, PALE[4], atok)
-- purple flush on the crown tip scales
am:each(function(x, y) local d = dmap[K(x, y)] if y <= 14 and d < 2.4 then c:put(x, y, CHOKE[(x < AX) and 3 or 2], atok) end end)
-- contact ring where it meets the broth
for x = AX - 3, AX + 3 do if broth:has(x, 36) and not am:has(x, 36) then c:put(x, 36, BROTH[2], btok) end end
c:put(AX - 6, 17, GR[6], atok) c:put(AX - 6, 18, GR[6], atok)

-- fava beans
local ftok = { r = { name = "fava" } }
local favas = { { 35, 37, 3.0, 1.9, 0.15 }, { 41, 35.5, 3.0, 1.8, -0.3 }, { 31.5, 34, 2.8, 1.8, 0.4 }, { 46, 37, 2.6, 1.7, 0.1 }, { 15, 37, 2.6, 1.7, -0.2 } }
for i, f in ipairs(favas) do
  local m, fn = A.oval(f[1], f[2], f[3], f[4], f[5], 0.8)
  m:cut(am)
  local bias = {}
  for j = i + 1, #favas do local o = favas[j] X.ao(bias, m, A.oval(o[1], o[2], o[3], o[4], o[5]), 1, -1) end
  local idx = A.shade(c, m, fn, FAVA, { tok = ftok, bias = bias, amb = 0.1, wrap = 0.3 })
  -- dark hilum eye on the right end + 1 px glint upper-left
  local ex, ey = floor(f[1] + f[3] * 0.7 * cos(f[5]) + 0.5), floor(f[2] + f[3] * 0.7 * sin(f[5]) + 0.5)
  if m:has(ex, ey) then c:put(ex, ey, FAVA[1], ftok) end
  local gx, gy = A.specAt(m, fn, 30) if gx then c:put(gx, gy, FAVA[6], ftok) end
  -- contact shadow on the broth
  m:shift(1, 1):each(function(x, y) if broth:has(x, y) and not m:has(x, y) and not am:has(x, y) then c:put(x, y, BROTH[2], btok) end end)
end
-- parsley flecks
for _, p in ipairs{ { 19, 38, 3 }, { 27, 37, 4 }, { 38, 38, 3 }, { 44, 34, 4 }, { 50, 36, 3 } } do c:put(p[1], p[2], GR[p[3]], btok) end

-- quirk: steam curl (S) rising right of the artichoke
local stm = { { 37, 31 }, { 36, 30 }, { 36, 29 }, { 37, 28 }, { 38, 27 }, { 38, 26 }, { 37, 25 }, { 36, 24 }, { 36, 23 }, { 37, 22 }, { 38, 21 }, { 38, 20 }, { 37, 19 } }
for i, p in ipairs(stm) do
  if i > 1 and i < #stm then c:put(p[1], p[2], STEAM[3], btok) c:put(p[1] + 1, p[2], STEAM[i < 7 and 2 or 1], btok)
  else c:put(p[1], p[2], STEAM[2], btok) end
end

A.save(c, NAME)
