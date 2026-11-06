-- chicha (final, Opus single pass). Tall slender terracotta jug of purple-corn chicha: flared lip, narrow neck tied
-- with a twisted red cord and gold tassel, round belly painted with a cream band of stepped maroon triangles, strap
-- handle on the right; lilac foam domes over the lip; a little gourd cup of dark purple chicha stands beside it.
-- quirk: one purple drip has run down the neck and stopped at the cord.
local NAME = "chicha"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)
local CLAY = { "#4e2228", "#7a3329", "#a44a30", "#c8663a", "#e08a52", "#f4b67a" }
local CRM = { "#7a5a4a", "#b08a6a", "#d4b48a", "#ead0a0", "#f6e2b8", "#fff4d6" }
local MAR = { "#3e1626", "#5a1e2e", "#74263a", "#8e3046", "#a63e52", "#bc5664" }
local FOAM = { "#7e5a8c", "#a68ab2", "#c8b0d0", "#e2d2e6", "#f4e8f0", "#fff4ec" }
local PUR = { "#2a1438", "#3e1c52", "#5a2a72", "#7a3e92" }
local GOURD = { "#5a3420", "#82502c", "#a87038", "#c8904a", "#e2b266", "#f4d28c" }
local CORD = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

local CX = 31
local function hw(y)
  if y < 16 or y > 50 then return -1 end
  local b = 9.5 * sqrt(max(0, 1 - ((y - 40) / 11.2) ^ 2))
  if y >= 49 then b = max(b, 5) end
  if y <= 17 then return 5.5 elseif y == 18 then return 4.6 end
  if y <= 30 then b = max(b, 3.5) end
  return b
end
c:groundShadow(31, 51, 13, 2)
c:groundShadow(14, 51, 6, 1)

-- handle (behind the jug)
local htok = { r = { name = "handle" } }
local hm, hn = A.tube({ { 35, 29 }, { 44, 28 }, { 45, 41 }, { 38, 44 } }, function() return 1.4 end)
local jug = HP.mask()
for y = 16, 50 do local w = hw(y) for x = CX - 10, CX + 10 do if abs(x - CX) <= w then jug:set(x, y) end end end
hm:cut(jug)
local hb = {} X.ao(hb, hm, jug, 1, -1)
X.tone(c, hm, X.light(hn, { amb = 0.1, wrap = 0.3 }), CLAY, { cuts = A.CUTS6, tok = htok, bias = hb })

-- jug body: per-row cylinder normals + belly curvature
do
  local tok = { r = { name = "jug" } }
  local n, bias = {}, {}
  jug:each(function(x, y) local w = hw(y)
    local nx = max(-0.96, min(0.96, (x - CX) / (w + 0.6)))
    local ny = 0
    if y >= 30 then ny = (y - 40) / 11.2 * 0.6 elseif y <= 17 then ny = -0.35 end
    local q = 1 - nx * nx - ny * ny
    n[K(x, y)] = { A.norm(nx, ny, sqrt(max(q, 0.03))) }
    if y == 18 or y == 19 or y == 49 or y == 50 then bias[K(x, y)] = -1 end   -- under lip, foot
  end)
  X.ao(bias, jug, hm, 1, -1)
  local v = X.light(n, { amb = 0.1, wrap = 0.28 })
  local idx = X.tone(c, jug, v, CLAY, { cuts = A.CUTS6, tok = tok, bias = bias })
  -- painted band: cream ground, stepped maroon triangles, maroon border lines (shading carried through idx)
  jug:each(function(x, y) local k = K(x, y) local i = idx[k]
    if y == 33 or y == 40 then c:put(x, y, MAR[max(1, i - 1)], tok)
    elseif y >= 34 and y <= 39 then
      local m = (x + 60) % 6
      if m <= (y - 34) and m < 5 then c:put(x, y, MAR[i], tok) else c:put(x, y, CRM[i], tok) end
    elseif y == 44 and (x + 60) % 3 == 0 then c:put(x, y, CRM[max(1, i - 1)], tok) end
  end)
  -- burnished specular streak on the belly + lip glint
  for _, p in ipairs{ { 25, 42 }, { 25, 43 }, { 25, 45 }, { 26, 46 } } do c:put(p[1], p[2], CLAY[6], tok) end
  c:put(25, 31, CLAY[6], tok) c:put(26, 30, A.CREAM, tok)
  -- cool bounce on the lower right
  jug:edge():each(function(x, y) if x > CX + 4 and y > 41 and y < 49 then c:put(x, y, "#6a3a52", tok) end end)
end
-- twisted cord around the neck + tassel
do
  local tok = { r = { name = "cord" } }
  for x = CX - 4, CX + 4 do
    for y = 24, 25 do
      local t = ((x + y) % 3 == 0) and 1 or (((x + y) % 3 == 1) and 3 or 2)
      if x >= CX + 2 then t = max(1, t - 1) end
      if x <= CX - 3 and t == 3 then t = 4 end
      c:put(x, y, CORD[t], tok)
    end
  end
  -- tassel hanging on the left
  for y = 26, 30 do c:put(26, y, GOLD[(y % 2 == 0) and 3 or 4], tok) c:put(27, y, GOLD[(y % 2 == 0) and 2 or 3], tok) end
  c:put(26, 31, GOLD[2], tok) c:put(27, 31, GOLD[1], tok) c:put(27, 26, CORD[2], tok)
end
-- quirk: purple drip down the neck, stopping on the cord
do
  local tok = { r = { name = "drip" } }
  for y = 19, 23 do c:put(33, y, PUR[(y < 22) and 3 or 2], tok) end
  c:put(34, 19, PUR[2], tok) c:put(33, 23, PUR[3], tok) c:put(33, 24, PUR[2], tok) c:put(33, 20, PUR[4], tok)
end
-- foam dome over the lip
do
  local tok = { r = { name = "foam" } }
  local fm = c:ellipse(31, 14, 5.5, 2.6)
  fm:add(c:ellipse(28.5, 12, 2.6, 2.2)):add(c:ellipse(32.5, 11, 2.8, 2.4)):add(c:ellipse(35, 13, 2, 1.8))
  fm:clip(c:rect(0, 0, 63, 16))
  local n = X.pillow(fm, 2.4)
  local b = {}
  fm:each(function(x, y) if y >= 16 then b[K(x, y)] = -1 end end)
  X.tone(c, fm, X.light(n, { amb = 0.15, wrap = 0.35 }), FOAM, { cuts = A.CUTS6, tok = tok, bias = b })
  -- bubbles
  for _, p in ipairs{ { 30, 13 }, { 34, 14 }, { 27, 14 }, { 33, 10 } } do c:put(p[1], p[2], FOAM[3], tok) end
  c:put(29, 10, A.CREAM, tok)
  -- foam spills over the lip front
  c:put(33, 17, FOAM[4], tok) c:put(34, 17, FOAM[3], tok) c:put(33, 18, FOAM[3], tok)
end
-- gourd cup
do
  local tok = { r = { name = "cup" } }
  local cm = c:ellipse(14, 47, 5.5, 4.5) cm:clip(c:rect(0, 45, 63, 63))
  local n = X.sphere(14, 46, 5.5, cm)
  local b = {} X.ao(b, cm, jug, 1, -1)
  X.tone(c, cm, X.light(n, { amb = 0.1, wrap = 0.3 }), GOURD, { cuts = A.CUTS6, tok = tok, bias = b })
  local top = c:ellipse(14, 45, 5.5, 1.5)
  local rim = top:edge()
  top:each(function(x, y) c:put(x, y, rim:has(x, y) and (x < 14 and GOURD[6] or GOURD[3]) or (x > 15 and PUR[1] or PUR[2]), tok) end)
  c:put(12, 45, PUR[4], tok) c:put(13, 45, FOAM[3], tok)
  -- carved groove line on the gourd
  for x = 10, 18 do if cm:has(x, 48) then c:put(x, 48, GOURD[2], tok) end end
  c:put(11, 46, GOURD[6], tok) c:put(12, 46, GOURD[6], tok)
end
A.save(c, NAME)
