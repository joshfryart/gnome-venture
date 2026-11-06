-- fiddlehead-fry (final, Opus aB31_2). A small cast-iron skillet seen from three-quarters: bevelled rim with a bright
-- upper-left edge, dark well with a butter sheen, slim handle with a bevel and a hanging hole. Four sauteed fiddlehead
-- coils (glossy olive-green, browned sear spots, butter specular, contact shadows) and two garlic slices.
-- Ground shadow under the pan. quirk: a curl of steam rising from the pan.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local NAME = "fiddlehead-fry"
local c = A.new(NAME)
local IRON = { "#1b1722", "#2a2534", "#3d384b", "#575268", "#7a7690", "#aaa7bf" }
local FRY = { "#26341c", "#3d5222", "#5a7428", "#7f9832", "#a7b846", "#d4dc7a" }
local SEAR = { "#5a3420", "#8a5a2a", "#b8843c" }
local GAR = { "#c9b48c", "#efe2bc", "#fff4d6" }
local STEAM = { "#bdb8d0", "#dedbe9" }

local CX, CY, RX, RY, DEP = 27, 38, 17, 10.5, 4
local function inE(x, y, cx, cy, rx, ry) local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry return dx*dx + dy*dy <= 1 end
-- masks
local rimO, inner, body = HP.mask(), HP.mask(), HP.mask()
for y = 20, 60 do for x = 0, 63 do
  if inE(x, y, CX, CY, RX, RY) then rimO:set(x, y) end
  if inE(x, y, CX, CY + 0.4, RX - 2.6, RY - 2.4) then inner:set(x, y) end
  for d = 0, DEP do if inE(x, y, CX, CY + d, RX - d * 0.35, RY - d * 0.2) then body:set(x, y) break end end
end end
body:cut(rimO)
local floorM = HP.mask()
inner:each(function(x, y) if inE(x, y, CX, CY + 2, RX - 3, RY - 2.8) then floorM:set(x, y) end end)
floorM:clip(inner)
local wall = inner:copy():cut(floorM)
local rim = rimO:copy():cut(inner)

-- handle: bevelled bar to the upper right with an end loop + hole
local hm, hn = A.tube({ {42, 35}, {47, 33}, {51, 31.5}, {54, 30} }, function(t) return 1.6 end)
local knob = HP.ellipse(54, 30, 2.6, 2.6)
local hole = HP.mask() hole:set(54, 30) hole:set(55, 30) hole:set(54, 29)
hm:add(knob):cut(rimO):cut(hole)
local htok = A.tok("handle")
local hv = X.light(hn, { amb = 0.1, wrap = 0.3 })
local hpn = X.pillow(knob, 1.5)
hm:each(function(x, y) local k = K(x, y)
  local v = hv[k] or X.light({ [k] = hpn[k] or { 0, 0, 1 } })[k]
  local i = A.q(v, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  c:put(x, y, IRON[i], htok)
end)
hole:each(function(x, y) end)
c:put(53, 29, IRON[6], htok) c:put(52, 30, IRON[5], htok) c:put(55, 31, IRON[2], htok)
-- ambient where handle meets rim
for _, p in ipairs{ {43, 34}, {43, 35}, {43, 36}, {44, 35} } do if hm:has(p[1], p[2]) then c:put(p[1], p[2], IRON[1], htok) end end

-- ground shadow
c:groundShadow(CX + 1, CY + RY + DEP - 0.5, RX - 1, 2)

-- pan body (outer wall): lit as a vertical cylinder
local ptok = A.tok("pan")
body:each(function(x, y)
  local s = (x + 0.5 - CX) / (RX + 0.5)
  local n = { s, 0.25, sqrt(max(0.05, 1 - s*s)) }
  local L = X.L
  local v = max(0, n[1]*L[1] + n[2]*L[2] + n[3]*L[3])
  local i = A.q(v, { 0.12, 0.3, 0.48, 0.66 })
  if inE(x, y, CX, CY + DEP, RX - DEP * 0.35, RY - DEP * 0.2) and not inE(x, y - 1, CX, CY + DEP, RX - DEP * 0.35, RY - DEP * 0.2) then i = i - 1 end
  c:put(x, y, IRON[max(1, min(6, i))], ptok)
end)
-- rim top: bevel, bright upper-left edge, shade lower-right
rim:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - CY) / RY
  local ang = math.atan(dy, dx)
  local v = -(cos(ang) * 0.6 + sin(ang) * 0.8)    -- +1 at upper left
  local i = A.q(v, { -0.6, -0.15, 0.25, 0.65 }) + 1
  c:put(x, y, IRON[max(1, min(6, i))], ptok)
end)
rim:edge():each(function(x, y)
  if not rimO:edge():has(x, y) then return end
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  if dx < -4 and dy < 0 then c:put(x, y, IRON[6], ptok) end
end)
-- inner rim lip (dark ring just inside)
inner:edge():each(function(x, y) local dy = y + 0.5 - CY if dy < 1 then c:put(x, y, IRON[1], ptok) end end)
-- inner wall (back, lit from front-right... facing viewer) and floor
wall:each(function(x, y) if not inner:edge():has(x, y) or y + 0.5 - CY >= 1 then
  local dx = (x + 0.5 - CX) / RX c:put(x, y, IRON[dx > 0.2 and 4 or 3], ptok) end end)
floorM:each(function(x, y)
  local i = 2
  local dx, dy = x + 0.5 - (CX - 4), y + 0.5 - (CY + 1)
  if abs(dy - dx * 0.22) < 0.8 and dx > -9 and dx < 4 then i = 4 end   -- butter sheen streak
  c:put(x, y, IRON[i], ptok)
end)
-- glint on the rim
c:put(14, 31, "#fff4d6", ptok) c:put(15, 31, IRON[6], ptok)

-- sauteed coils on the floor
local SJ = 0.2
local coils = {
  { p = { {22, 44}, {21, 43}, {20.5, 42}, {20.4, 39.5} }, dir = 1, R = 3.5 },
  { p = { {33, 44}, {33, 43}, {33.5, 42}, {33.6, 40} }, dir = -1, R = 3.5 },
  { p = { {32, 43}, {31, 42}, {30.5, 40}, {30.4, 37.5} }, dir = 1, R = 3.4 },
}
local cm = {}
for i, d in ipairs(coils) do
  local sm = A.crozier(d.p, d.dir, d.R, 1.15, function(t) if t < SJ then return 1.0 else return 1.35 - 0.45 * (t - SJ) / (1 - SJ) end end, 10, 60)
  local m, n, T, S = A.ptube(sm)
  cm[i] = { m = m, n = n, T = T, S = S }
end
-- garlic slices (under the coils)
local gtok = A.tok("garlic")
for _, g in ipairs{ { 25, 44 }, { 37, 36 } } do
  local m = A.rell(g[1], g[2], 1, -0.2, 2.2, 1.4)
  m:each(function(x, y) c:put(x, y, (x + y < g[1] + g[2]) and GAR[2] or GAR[1], gtok) end)
  c:put(g[1] - 1, g[2], GAR[3], gtok)
  c:put(g[1] + 1, g[2] + 1, "#9a8a6a", gtok)
end
for i, cr in ipairs(cm) do
  local tok = A.tok("coil" .. i)
  local vis = cr.m:copy()
  local bias = {}
  for j = i + 1, #cm do vis:cut(cm[j].m) X.ao(bias, cr.m, cm[j].m, 1, -1) end
  -- contact shadow on the pan floor
  cr.m:shift(1, 1):each(function(x, y) if floorM:has(x, y) and not cr.m:has(x, y) then
    local occ = false for j = i + 1, #cm do if cm[j].m:has(x, y) then occ = true end end
    if not occ then c:put(x, y, IRON[1], ptok) end end end)
  local idx = X.tone(c, vis, X.light(cr.n, { amb = 0.12, wrap = 0.3 }), FRY, { cuts = { 0.18, 0.35, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
  A.seams(c, vis, cr.T, idx, FRY, tok, 0.18)
  vis:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, i) > 0.8 and (idx[k] or 0) >= 3 then c:put(x, y, SEAR[idx[k] >= 5 and 3 or 2], tok) end
  end)
  local sx, sy = A.specAt(vis, cr.n, 30)
  if sx then c:put(sx, sy, "#f4f6c4", tok) end
end

-- quirk: steam curl (2 px wide, pale)
local stok = A.tok("steam")
local sm2 = A.ptube((function()
  local o = {}
  for i = 0, 40 do local t = i / 40
    o[#o + 1] = { 25 + 3.2 * sin(t * 2 * pi * 1.1), 33 - t * 19, 0.75 + 0.2 * (1 - t) }
  end
  return o end)())
sm2:cut(rimO)
sm2:each(function(x, y) local below = sm2:has(x - 1, y) c:put(x, y, below and STEAM[1] or STEAM[2], stok) end)

A.save(c, NAME)
