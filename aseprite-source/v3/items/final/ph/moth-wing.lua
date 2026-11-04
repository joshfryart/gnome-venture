-- moth-wing (final, Opus single pass). One shed moth wing pair seen flat: a long slim dusty-teal forewing (pointed
-- apex, radiating veins from the furry base, dark zigzag postmedial band, cream crescent spots, gold-ringed eyespot,
-- checkered scale fringe on the outer margin) overlapping a rounded rose-ochre hindwing with a dark border and
-- veins. Soft pillow light, contact shadow of the forewing on the hindwing, fluffy cream base tuft.
-- quirk: a little round clothes-moth hole has been nibbled through the forewing.
local NAME = "moth-wing"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local FW = { "#1c2a44", "#25415f", "#2f5f7c", "#4a8496", "#76aeb4", "#a8d4cc" }
local HW = { "#3a1f2e", "#5e2e3a", "#8a4a48", "#b8705a", "#dc9e78", "#f2c89a" }
local FUR = { "#8e7a6a", "#c8b49a", "#eadcc0", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e" }
local BX, BY = 13, 47       -- wing root

-- hindwing: rounded fan with a scalloped margin
local hw = c:poly{ { 13, 46 }, { 22, 40 }, { 32, 39 }, { 41, 42 }, { 44, 47 }, { 41, 53 }, { 33, 57 }, { 24, 57 }, { 17, 53 } }
for _, p in ipairs{ { 41, 48, 3 }, { 36, 54, 3 }, { 28, 56, 2.5 } } do hw:add(c:ellipse(p[1], p[2], p[3], p[3])) end
-- forewing: broad moth triangle, pointed apex up-right, straight-ish outer margin down to the tornus
local fw = c:poly{ { 11, 47 }, { 15, 37 }, { 23, 27 }, { 34, 18 }, { 45, 12 }, { 54, 9 }, { 56, 11 }, { 55, 17 }, { 52, 24 }, { 48, 31 }, { 45, 36 }, { 36, 40 }, { 26, 44 }, { 17, 49 }, { 13, 49 } }
fw:add(c:ellipse(52.5, 21, 3, 7))
fw:add(c:poly{ { 13, 49 }, { 11, 47 }, { 12, 45 } })
hw:cut(fw)

local function polarT(x, y) local dx, dy = x - BX, y - BY return sqrt(dx * dx + dy * dy), atan(dy, dx) end

-- hindwing tone: pillow + slight cup, contact shadow under the forewing
local htok = { r = { name = "hind" } }
local hbias = {}
X.ao(hbias, hw, fw, 2, -1) A.cast(hbias, hw, fw, 1, 2, -1)
local hn = X.pillow(hw, 4)
local hidx = X.tone(c, hw, X.light(hn, { amb = 0.18, wrap = 0.35 }), HW, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, bias = hbias, tok = htok })
-- dark border band along the outer margin + pale submarginal line
local hd = X.dist(hw)
hw:each(function(x, y) local k = K(x, y) local r = polarT(x, y)
  if r > 14 and not hbias[k] then
    local d = hd[k]
    if d < 2.5 then c:put(x, y, HW[max(1, (hidx[k] or 3) - 2)], htok)
    elseif d < 3.5 then c:put(x, y, HW[min(6, (hidx[k] or 3) + 1)], htok) end
  end
end)
-- hindwing veins (radiating)
for _, a in ipairs{ 0.05, 0.32, 0.6, 0.9 } do
  local pts = {}
  for r = 6, 30, 2 do pts[#pts + 1] = { BX + cos(a - 0.35) * r, BY + sin(a - 0.35) * r * 1.0 + r * 0.25 } end
  for i = 1, #pts - 1 do A.line(c, { pts[i], pts[i + 1] }, HW[3], htok, hw) end
end
-- re-apply contact shadow under the forewing over veins
hw:each(function(x, y) if hbias[K(x, y)] and fw:shift(1, 2):has(x, y) then c:put(x, y, HW[1], htok) end end)

-- forewing tone
local ftok = { r = { name = "fore" } }
local fn = X.pillow(fw, 4)
local fidx = X.tone(c, fw, X.light(fn, { amb = 0.15, wrap = 0.35 }), FW, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, tok = ftok })
local fd = X.dist(fw)
local function fput(x, y, step) local k = K(x, y) if fw:has(x, y) then c:put(x, y, FW[max(1, min(6, (fidx[k] or 3) + step))], ftok) end end
-- radiating veins from the root (shade tone, lit-side neighbour pixel brighter)
for _, a in ipairs{ -1.05, -0.86, -0.7, -0.55, -0.4, -0.26 } do
  for r = 7, 52, 0.5 do
    local x, y = floor(BX + cos(a) * r + .5), floor(BY + sin(a) * r + .5)
    if fw:has(x, y) and fd[K(x, y)] > 1.2 then fput(x, y, -2) end
  end
end
-- postmedial zigzag band across the wing (dark) with a pale edge on its root side
for t = 0, 1, 0.02 do
  local x0, y0, x1, y1 = 36, 17, 45, 35
  local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
  local z = (floor(t * 9) % 2 == 0) and (A.frac(t * 9)) or (1 - A.frac(t * 9))
  x = x + z * 2.4
  local xi, yi = floor(x + .5), floor(y + .5)
  fput(xi, yi, -3) fput(xi + 1, yi, -2) fput(xi - 1, yi, 1)
end
-- cream crescent spots in the submarginal row
for _, q in ipairs{ { 50, 13 }, { 51, 19 }, { 50, 25 }, { 47, 31 } } do
  if fw:has(q[1], q[2]) then c:put(q[1], q[2], "#e8f0d8", ftok) c:put(q[1] - 1, q[2] + 1, FW[6], ftok) end
end
-- checkered scale fringe along the outer margin (right-hand edge)
local fe = fw:edge()
fe:each(function(x, y) if x > 46 or (x > 30 and y > 30 and x + y > 72) then
  c:put(x, y, ((x + y) % 2 == 0) and FW[6] or FW[1], ftok) end end)
-- eyespot: gold ring, ink pupil with cream glint, dark halo
local ex, ey = 30, 33
for y = ey - 3, ey + 3 do for x = ex - 3, ex + 3 do
  local q = (x - ex) ^ 2 + (y - ey) ^ 2
  if q <= 10 then
    local col = q <= 2 and A.INK or (q <= 5 and (x + y < ex + ey and GOLD[3] or GOLD[2]) or FW[1])
    if fw:has(x, y) then c:put(x, y, col, ftok) end
  end
end end
c:put(ex - 1, ey - 1, A.CREAM, ftok)
-- dusty leading-edge (costa) highlight, one bright pop near the apex
for x = 20, 50 do
  for y = 0, 63 do if fw:has(x, y) then
    if fd[K(x, y)] < 1 and x < 52 then c:put(x, y, FW[6], ftok) end
    break end end
end
c:put(47, 12, A.CREAM, ftok) c:put(48, 11, FW[6], ftok)

-- quirk: nibbled hole (transparent centre; finish draws its ink rim)
local hole = c:ellipse(40.5, 23.5, 2.5, 2.5)
hole:each(function(x, y) c.pix[y * 64 + x] = nil c.own[y * 64 + x] = nil end)
-- frayed pale scale ring just outside the hole
hole:grow(2):cut(hole:grow(1)):each(function(x, y) if fw:has(x, y) and x + y < 64 then c:put(x, y, FW[5], ftok) end end)

-- furry root tuft
local tuft = HP.mask()
for _, b in ipairs{ { 12, 46, 2.6 }, { 15, 44, 1.8 }, { 10, 49, 1.6 }, { 15, 48, 1.6 } } do
  for y = floor(b[2] - 3), floor(b[2] + 3) do for x = floor(b[1] - 3), floor(b[1] + 3) do
    if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] ^ 2 + 0.4 then tuft:set(x, y) end end end
end
local utok = { r = { name = "fur" } }
local un = X.pillow(tuft, 2)
X.tone(c, tuft, X.light(un, { amb = 0.2, wrap = 0.3 }), FUR, { cuts = { 0.3, 0.55, 0.8 }, tok = utok })
-- hair strokes
for _, q in ipairs{ { 11, 45, 4 }, { 13, 44, 4 }, { 12, 47, 1 }, { 14, 46, 2 }, { 10, 48, 2 } } do if tuft:has(q[1], q[2]) then c:put(q[1], q[2], FUR[q[3]], utok) end end

A.save2(c, NAME)
