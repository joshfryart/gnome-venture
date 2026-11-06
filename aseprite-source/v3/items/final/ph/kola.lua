-- kola (run3, Opus single pass). A slim, knobbly olive kola follicle lying on the diagonal, split open along its seam:
-- cream pith lining (shaded under the upper wall), three rosy kola nuts bedded in it, each with a cotyledon seam and a
-- waxy glint; short woody stalk at the base, pointed beak at the tip. A loose nut sits in front, lower right.
-- Material: warty rind (hash bumps, lit ridge + shadow dot), pale cut lip of the wall, AO where nuts sit in the pith,
-- contact shadow under the loose nut, cool reflected light on the nut's shade side.
-- quirk: the loose nut has one bite taken out of it, showing the pale flesh and two tooth scallops.
local NAME = "kola"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new5(NAME)
local POD  = { "#1e3428", "#2d4f33", "#47703a", "#6a9142", "#93b456", "#c6d982" }
local LINE = { "#8c7656", "#b39d74", "#d4c299", "#e9dcb7", "#f6efd2", "#fffae9" }
local NUT  = { "#4a1428", "#781e36", "#a6303f", "#cc4d4d", "#e67868", "#f8a890" }
local FLESH = { "#c9a87e", "#e3caa0", "#f3e3c0", "#fff6e0" }
local WOOD = { "#3d2622", "#5d3c2c", "#86593a", "#b07d4f" }
local COOL = "#7a6c9a"

-- pod body: tube along a gentle S from stalk (lower left) to beak (upper right)
local pp = { { 13, 46 }, { 22, 41 }, { 36, 30 }, { 51, 17 } }
local pm, pn, PT, PS = G.tube(pp, function(t)
  if t > 0.985 then return -1 end
  return max(0.7, 6.6 * sin(pi * min(1, 0.08 + t * 0.95)) ^ 0.55)
end)
local AX, AY = 51 - 13, 17 - 46
local AL = sqrt(AX * AX + AY * AY)
local ANG = math.atan(AY, AX)
-- opening (seam split), slightly toward the viewer's upper-left half
local op = G.oval(31.5, 32, 12.5, 3.6, ANG, 1)
op:clip(pm:copy():shrink(2))
local bias = {}
-- warts: coarse bumps
local bumps = {}
pm:each(function(x, y) local k = K(x, y)
  local gx, gy = floor((x + (y % 6 < 3 and 0 or 2)) / 4), floor(y / 3)
  if X.hash(gx, gy, 7) > 0.55 then
    local cx, cy = gx * 4 + 1.5 - (y % 6 < 3 and 0 or 2), gy * 3 + 1
    if abs(x - cx) + abs(y - cy) <= 1 then bumps[k] = (x - cx) + (y - cy) end
  end
end)
X.ao(bias, pm, op, 1, -1)
local ptok = { r = { name = "pod" } }
local pidx = G.toneN(c, pm, pn, POD, { bias = bias, tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
for k, d in pairs(bumps) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if not op:has(x, y) and (pidx[k] or 1) > 1 then c:put(x, y, POD[max(1, min(6, pidx[k] + (d < 0 and 1 or -1)))], ptok) end
end
-- seam ridge running to the beak beyond the opening
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k] + 0.12) < 0.09 and (PT[k] > 0.8 or PT[k] < 0.17) and PT[k] > 0.06 then c:put(x, y, POD[2], ptok) end end)
-- cut lip of the wall: pale ring just around the opening
local lip = op:grow(1):cut(op):clip(pm)
lip:each(function(x, y)
  local dx, dy = x - 31.5, y - 32
  local s = -dx * sin(ANG) + dy * cos(ANG)
  c:put(x, y, s < 0 and "#d7e3a0" or "#a9bf6e", ptok)
end)
-- pith lining: cavity is shaded under the upper (lit) wall, bright on the lower-right inner wall
local ltok = { r = { name = "pith" } }
G.fillIdx(c, op, LINE, function(x, y)
  local dx, dy = x - 31.5, y - 32
  local s = (-dx * sin(ANG) + dy * cos(ANG)) / 3.6
  return s < -0.45 and 2 or (s < 0 and 3 or (s < 0.6 and 5 or 4))
end, ltok)
-- nuts bedded in the pith
local nuts = {}
for i, t in ipairs{ 0.32, 0.5, 0.68 } do
  local cx, cy = G.bez(pp, t)
  cx, cy = cx - 0.6, cy + 0.2
  local m, n = G.oval(cx, cy, 3.3, 2.7, ANG + 0.3, 0.8)
  m:clip(op:copy():grow(1)):clip(pm)
  nuts[i] = { m = m, n = n, cx = cx, cy = cy }
end
local nb = {}
for i, s in ipairs(nuts) do
  -- AO in the pith around each nut
  s.m:grow(1):each(function(x, y) if op:has(x, y) and not s.m:has(x, y) and (x - s.cx) + (y - s.cy) > -1 then c:px(x, y, LINE[1]) end end)
end
for i, s in ipairs(nuts) do
  local b = {}
  if nuts[i + 1] then X.ao(b, s.m, nuts[i + 1].m, 1, -1) end
  local tok = { r = { name = "nut" .. i } }
  local idx = G.toneN(c, s.m, s.n, NUT, { bias = b, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.3 })
  -- cotyledon seam: short dark line across the nut
  for d = -1, 1 do c:put(floor(s.cx + d * 0.6 + .5), floor(s.cy - d * 0.8 + .5), NUT[2], tok) end
  local sx, sy = G.specAt(s.m, s.n, 30) if sx then c:px(sx, sy, "#ffd8c4") end
end

-- stalk
local sm, sn = G.tube({ { 14, 46 }, { 11, 48 }, { 9, 50 }, { 8, 53 } }, function(t) return 1.3 - 0.3 * t end)
sm:cut(pm)
G.toneN(c, sm, sn, WOOD, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
c:px(8, 54, WOOD[4]) c:px(7, 54, WOOD[3])

-- loose nut (front, lower right) with a bite
local LX, LY = 45, 46
local lm, ln = G.oval(LX, LY, 5.4, 4.4, -0.35, 0.85)
local bite = HP.mask()
for _, q in ipairs{ { LX - 3.2, LY - 3.0, 2.9 }, { LX - 0.6, LY - 4.2, 2.5 } } do bite:add(G.oval(q[1], q[2], q[3], q[3], 0, 1)) end
local face = lm:copy():clip(bite)
lm:cut(bite)
-- contact shadow on the pod where the nut overlaps it
lm:shift(1, 1):each(function(x, y) if pm:has(x, y) and not lm:has(x, y) and not face:has(x, y) then c:px(x, y, POD[1]) end end)
local lb = {}
local ntok = { r = { name = "loose" } }
local li = G.toneN(c, lm, ln, NUT, { bias = lb, tok = ntok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.3 })
-- cool reflected light on the lower-right rim
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.55 and (li[k] or 1) <= 2 then c:put(x, y, COOL, ntok) end end)
-- seam
G.ln(c, LX + 1, LY - 1, LX + 3, LY + 3, NUT[2], lm)
G.ln(c, LX + 2, LY - 1, LX + 4, LY + 2, NUT[3], lm)
-- bitten face: pale flesh, darker toward the far (lower-right) wall, thin skin lip
local ftok = { r = { name = "flesh" } }
G.fillIdx(c, face, FLESH, function(x, y)
  local d = (x - (LX - 3)) + (y - (LY - 4))
  return d < -2 and 4 or (d < 1 and 3 or (d < 3 and 2 or 1))
end, ftok)
face:edge():each(function(x, y) if lm:grow(1):has(x, y) and ((x - LX) + (y - LY) > -5) then c:px(x, y, NUT[4]) end end)
-- tooth scallop marks
c:px(LX - 3, LY - 2, FLESH[1]) c:px(LX - 1, LY - 3, FLESH[1])
local sx, sy = G.specAt(lm, ln, 40) if sx then c:px(sx, sy, "#fff4d6") c:px(sx + 1, sy, "#ffd8c4") end
G.save2(c, NAME)
