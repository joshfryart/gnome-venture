-- bell-clapper (final pass, Opus). A forged iron bell clapper hanging a little off-plumb: a round eye (torus-lit ring
-- with a dark hole and bevelled inner edge), a riveted collar, a slim hammered shaft (3 px, faceted with alternating
-- tones), the heavy ball (sphere light, bright specular, cool reflected light, AO where the shaft meets it) and the
-- short tapered flight below it. Material cues: bevel, bright edge, specular streak, dark hole, rust freckles.
-- quirk: a polished bronze-gold scuff on the ball's flank where it has been striking the bell for years.
local NAME = "bell-clapper"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local IRON = { "#1e1c2a", "#33334a", "#4e5068", "#717489", "#9ea1b6", "#d2d5e2" }
local BRZ = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RUST = { "#7a3424", "#b0562c" }
local COOL = "#4f6c96"
local SPEC = "#f4f6ff"
local CUTS = { 0.2, 0.36, 0.52, 0.7, 0.88 }

local RX, RY = 35, 14       -- eye centre
local BX, BY = 29, 43       -- ball centre
local BR = 7.6
-- flight (below the ball, along the same axis)
local ax, ay = BX - RX, BY - RY
local al = sqrt(ax*ax + ay*ay) local ux, uy = ax / al, ay / al
local fm, fn = A.tube({ { BX, BY }, { BX + ux * 6, BY + uy * 6 }, { BX + ux * 9, BY + uy * 9 }, { BX + ux * 11.5, BY + uy * 11.5 } },
  function(t) return 2.6 - t * 1.2 end)
local ftok = { r = { name = "flight" } }
A.shade(c, fm, fn, IRON, { amb = 0.1, wrap = 0.3, cuts = CUTS, tok = ftok })
-- flight end face (paler, flat)
local ex, ey = floor(BX + ux * 11.5 + 0.5), floor(BY + uy * 11.5 + 0.5)

-- shaft
local sx0, sy0 = RX - ux * -5.2, RY + uy * 5.2
local sm, sn, ST = A.tube({ { RX + ux * 5, RY + uy * 5 }, { RX + ux * 12, RY + uy * 12 }, { BX - ux * 12, BY - uy * 12 }, { BX - ux * 5, BY - uy * 5 } },
  function(t) return 1.6 + (t > 0.85 and (t - 0.85) * 6 or 0) end)
local stok = { r = { name = "shaft" } }
local sidx = A.shade(c, sm, sn, IRON, { amb = 0.12, wrap = 0.3, cuts = CUTS, tok = stok })
-- hammer facets: every ~3 px along the shaft knock one lit pixel down a tone
sm:each(function(x, y) local k = K(x, y) local t = ST[k]
  if t and floor(t * 9) % 2 == 0 and (sidx[k] or 0) >= 4 and X.hash(x, y, 3) > 0.45 then A.step(c, sidx, IRON, x, y, -1, stok) end end)

-- ball
local bm = HP.ellipse(BX, BY, BR, BR)
local bn = X.sphere(BX - 0.3, BY - 0.3, BR, bm)
local bias = {}
X.ao(bias, bm, sm, 1, -1)
local btok = { r = { name = "ball" } }
local bidx = A.shade(c, bm, bn, IRON, { amb = 0.06, wrap = 0.2, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, bias = bias, tok = btok })
-- cool reflected light on the lower-right rim
local rimv = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if rimv[k] > 0.55 and (bidx[k] or 9) <= 2 then c:put(x, y, COOL, btok) end end)
-- quirk: bronze scuff on the right flank (strike mark), lit from the upper left
local sc = HP.ellipse(BX + 4, BY - 0.5, 1.4, 2.6)
sc:clip(bm:shrink(2))
sc:each(function(x, y) local k = K(x, y)
  local i = 2
  if x <= BX + 3 then i = 3 end
  if y >= BY + 1 then i = 1 end
  c:put(x, y, BRZ[i], btok)
end)
c:put(BX + 3, BY - 2, BRZ[4], btok)
-- rust freckles (shade side)
for _, p in ipairs{ { BX + 2, BY + 5, 1 }, { BX + 3, BY + 4, 2 }, { BX - 3, BY + 6, 1 } } do
  if bm:has(p[1], p[2]) then c:put(p[1], p[2], RUST[p[3]], btok) end end
-- ball specular: streak + hot pixel
for _, p in ipairs{ { BX - 4, BY - 3 }, { BX - 3, BY - 4 }, { BX - 4, BY - 4 } } do c:put(p[1], p[2], IRON[6], btok) end
c:put(BX - 3, BY - 5, SPEC, btok) c:put(BX - 5, BY - 2, SPEC, btok)
-- AO collar where the shaft enters the ball
for _, p in ipairs{ { -1, 0 }, { 0, 0 }, { 1, 0 }, { -1, 1 } } do
  local x, y = floor(BX - ux * (BR - 0.5) + p[1] + 0.5), floor(BY - uy * (BR - 0.5) + p[2] + 0.5)
  if bm:has(x, y) then c:put(x, y, IRON[1], btok) end
end
-- flight end face
if fm:has(ex, ey) then c:put(ex, ey, IRON[4], ftok) end

-- eye: torus
local RO, RI = 6.2, 2.4
local em, en = HP.mask(), {}
local rc, rt = (RO + RI) / 2, (RO - RI) / 2
for y = RY - 8, RY + 8 do for x = RX - 8, RX + 8 do
  local dx, dy = x - RX, y - RY
  local d = sqrt(dx*dx + dy*dy)
  if d <= RO + 0.1 and d >= RI - 0.1 then
    em:set(x, y)
    local s = max(-0.95, min(0.95, (d - rc) / (rt + 0.4)))
    local rx_, ry_ = dx / max(d, 0.01), dy / max(d, 0.01)
    en[K(x, y)] = { A.norm(rx_ * s, ry_ * s, sqrt(1 - s*s)) }
  end
end end
local etok = { r = { name = "eye" } }
local eidx = A.shade(c, em, en, IRON, { amb = 0.1, wrap = 0.3, cuts = CUTS, tok = etok })
-- bright edge on the lit outer rim
em:edge():each(function(x, y) local dx, dy = x - RX, y - RY
  local d = sqrt(dx*dx + dy*dy)
  if d > rc and dx + dy < -4 then c:put(x, y, IRON[6], etok) end
  if d < rc and dx + dy > 1 then c:put(x, y, IRON[5], etok) end   -- lit inner bevel facing the light
  if d < rc and dx + dy < -1 then c:put(x, y, IRON[1], etok) end  -- shadowed inner bevel
end)
c:put(RX - 3, RY - 4, SPEC, etok)

-- collar (forged boss) between eye and shaft, with a rivet
local cxm, cym = RX + ux * 6.6, RY + uy * 6.6
local cm = A.rell(cxm, cym, ux, uy, 1.9, 3.3)
local cn = A.dome(cm, cxm, cym, 3, 1.5, 0.5)
local ctok = { r = { name = "collar" } }
local cidx = A.shade(c, cm, cn, IRON, { amb = 0.1, wrap = 0.3, cuts = CUTS, tok = ctok })
-- ambient row where the collar meets the ring / shaft
cm:each(function(x, y) local t = (x - cxm) * ux + (y - cym) * uy if t > 0.9 then A.step(c, cidx, IRON, x, y, -1, ctok) end if t < -1.2 then A.step(c, cidx, IRON, x, y, 1, ctok) end end)
-- deep seam where the collar sits on the shaft
sm:each(function(x, y) local t = (x - cxm) * ux + (y - cym) * uy if t > 1.9 and t <= 2.9 and not cm:has(x, y) then c:put(x, y, IRON[1], stok) end end)
local rvx, rvy = floor(cxm + 0.5), floor(cym + 0.5)
c:put(rvx, rvy, IRON[2], ctok) c:put(rvx - 1, rvy - 1, IRON[6], ctok)

A.save(c, NAME)
