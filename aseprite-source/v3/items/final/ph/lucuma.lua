-- lucuma (aC21_3, Opus single pass). An upright, egg-shaped lucuma tapering to its pointed apex (dried style tip at the
-- bottom). Thin olive-to-bronze skin: 6-tone per-pixel light, waxy bloom specks, russet freckles round the shoulder,
-- one bright specular, cool reflected light on the lower right. Short woody stalk sunk in a dimple, one long glossy
-- elliptic leaf with midrib and pinnate veins.
-- quirk: a scalloped bite out of the right side shows the dry golden flesh (mealy speckle, dark rind row) and the edge
-- of the polished brown stone.
local NAME = "lucuma"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local SKIN = { "#2a3418", "#43511f", "#647028", "#8a9033", "#b2ae48", "#d8d280" }
local COOL, BLOOM, RUSS = "#4f7a6a", "#d4dca4", "#7a5a2a"
local FLESH = { "#a85a14", "#d08222", "#eca630", "#fbc84a", "#ffe07a", "#fff2b0" }
local STONE = { "#3a1a14", "#6a3420", "#a0582e", "#e0a070" }
local WOOD = { "#3e2622", "#5e3a2a", "#86583a", "#ad7a50" }
local LEAF = { "#132f2c", "#1b4a38", "#256640", "#3a8548", "#5ea75a", "#94cc78" }
local VEIN = "#b8dc8c"
local btok, ftok, wtok, ltok = { r = { name = "body" } }, { r = { name = "flesh" } }, { r = { name = "stalk" } }, { r = { name = "leaf" } }

-- body: egg, narrow end down, drawn out to a point
local CX, CY = 30, 38
local body = HP.mask()
for y = 18, 60 do for x = 10, 50 do
  local dy = y - CY
  local ry = dy < 0 and 15.5 or 17.5
  local taper = dy > 0 and (1 - 0.32 * (dy / ry) ^ 1.6) or 1
  local rx = 12.6 * taper
  if ((x - CX) / (rx + .5)) ^ 2 + (dy / (ry + .5)) ^ 2 <= 1 then body:set(x, y) end
end end
for y = 54, 58 do for x = CX - 1, CX + 1 do if abs(x - CX) <= (58 - y) * 0.5 then body:set(x, y) end end end
-- the bite: two overlapping round tooth arcs on the right shoulder
local bite = c:ellipse(45, 31, 6, 6):add(c:ellipse(44.5, 39, 5.5, 5.5))
body:cut(bite)
local bn = X.pillow(body, 9.5)
local bias = {}
local fl = HP.mask()                        -- exposed flesh band inside the bite
local bg = bite:grow(5)
body:each(function(x, y) if bg:has(x, y) and (x > CX + 3) then fl:set(x, y) end end)
local sidx = A.toneN(c, body, bn, SKIN, { bias = bias, tok = btok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.8 }, amb = 0.1, wrap = 0.28 })
-- skin cues: bloom specks on the lit face, russet freckles on the shoulder, cool bounce lower right
body:each(function(x, y) local k = K(x, y)
  local i = sidx[k]
  local nn = bn[k]
  if nn and nn[1] > 0.35 and nn[2] > 0.15 and i and i <= 3 then c:put(x, y, COOL, btok)
  elseif i and i >= 4 and X.hash(x, y, 3) > 0.92 then c:put(x, y, BLOOM, btok)
  elseif y < CY - 6 and X.hash(x, y, 8) > 0.9 and i and i >= 2 then c:put(x, y, i >= 4 and SKIN[3] or RUSS, btok) end
end)
-- flesh: lit flat face facing the viewer, mealy speckle, rind row against the skin
local fidx = {}
fl:each(function(x, y) local k = K(x, y)
  local d = 0
  for r = 1, 5 do if bite:grow(r):has(x, y) then d = r break end end
  local i
  if d <= 1 then i = 4 elseif d <= 3 then i = 5 else i = 3 end
  if y > 40 then i = i - 1 end
  if X.hash(x, y, 21) > 0.82 then i = i + (X.hash(x, y, 22) > 0.5 and 1 or -1) end
  i = max(1, min(6, i))
  fidx[k] = i
  c:put(x, y, FLESH[i], ftok)
end)
-- rind: flesh pixels touching skin get a dark skin row; then a pale cambium row where flesh is deepest
fl:each(function(x, y)
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    local nx, ny = x + d[1], y + d[2]
    if body:has(nx, ny) and not fl:has(nx, ny) then c:put(x, y, SKIN[2], btok) return end
  end
end)
-- bite edge: tooth ridges (lighter top lip on each scallop)
for _, q in ipairs{ { 40, 27 }, { 39, 28 }, { 39, 35 }, { 38, 36 } } do if fl:has(q[1], q[2]) then c:put(q[1], q[2], FLESH[6], ftok) end end
-- the stone peeks out at the deepest point of the bite
local stoneM = c:ellipse(38, 33, 1.6, 2.5):clip(fl)
stoneM:each(function(x, y)
  local i = (x <= 37 and y <= 32) and 3 or ((x >= 39 or y >= 35) and 1 or 2)
  c:put(x, y, STONE[i], ftok)
end)
c:put(37, 32, STONE[4], ftok)

-- apex: dried style tip
c:put(CX, 58, WOOD[1], btok) c:put(CX, 57, WOOD[2], btok)

-- stalk in a dimple
local stm, stn = X.cyl(29.5, 22, 31.5, 15, function(t) return 1.2 end)
stm:cut(body)
X.tone(c, stm, X.light(stn, { amb = 0.12, wrap = 0.3 }), WOOD, { cuts = { 0.3, 0.55, 0.78 }, tok = wtok })
c:put(31, 15, WOOD[4], wtok)            -- pale cut end grain
for _, q in ipairs{ { 28, 23 }, { 29, 23 }, { 30, 23 }, { 31, 23 }, { 32, 24 } } do if body:has(q[1], q[2]) then c:put(q[1], q[2], SKIN[1], btok) end end
for _, q in ipairs{ { 27, 24 }, { 33, 24 } } do if body:has(q[1], q[2]) then c:put(q[1], q[2], SKIN[2], btok) end end

-- leaf: long elliptic, sweeping up-left
local lm, lnn, LT, LS, len = A.blade(30, 18, 22, 8, 9, 12, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 4.0 * sin(pi * min(1, t * 0.94 + 0.06)) ^ 0.75)
end, { fold = 0.4 })
lm:cut(stm):cut(body)
local lidx = A.toneN(c, lm, lnn, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t > 0.04 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local f = ((t * len - abs(s) * 4) / 3.4) % 1
  if f < 0.2 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
local lx, ly = A.specAt(lm, lnn, 30)
c:put(lx, ly, LEAF[6], ltok)
-- contact shadow of the leaf base on the fruit shoulder
for _, q in ipairs{ { 26, 24 }, { 25, 25 } } do if body:has(q[1], q[2]) then c:put(q[1], q[2], SKIN[2], btok) end end

-- one specular on the skin
local gx, gy = A.specAt(body, bn, 60)
c:put(gx, gy, A.CREAM, btok) c:put(gx + 1, gy, SKIN[6], btok) c:put(gx, gy + 1, SKIN[6], btok)

A.save2(c, NAME)
