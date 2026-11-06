-- feast-berry-honey-cake (Opus single pass). A tall, slim two-layer sponge on a footed porcelain cake stand: crumb-speckled
-- sponge sides, a cream + jam filling band, a glossy honey glaze that runs down in drips, raspberries (drupelet texture)
-- and blueberries (waxy bloom, dark eye) with air between them, and a mint sprig. Stand: bevelled plate, slim stem, foot.
-- quirk: a tiny bee has come for the honey and hovers by the longest drip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_2.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = D.new("feast-berry-honey-cake")
local PORC = { "#4a4766", "#7c7c9e", "#a9acc6", "#cdd2e2", "#e6eaf2", "#f8f5ec" }
local SPONGE = { "#6b3a2e", "#9a5a3a", "#c4834e", "#dea464", "#efc283", "#fbdfa8" }
local CREAM = { "#8c6c7c", "#bc9ea6", "#dfc6c0", "#f2e2d2", "#fbefdc", "#fff8ea" }
local HONEY = { "#7a3614", "#b45c18", "#de861c", "#f5b42c", "#ffd65a", "#fff0a0" }
local RASP = { "#561832", "#8e2240", "#c2303e", "#e4473a", "#ff7660", "#ffb09a" }
local BLUE = { "#1d1c46", "#2c3172", "#424f9c", "#5a6ec2", "#8aa0e0", "#c4d2ff" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local JAM = "#a8243c"

-- ground shadow under the foot
c:groundShadow(32, 58, 12, 1)
-- stand foot
local ftok = D.tok("porc")
local foot = D.sweep(D.ellipseMask(32, 55, 8, 2), 1)
D.lit(c, foot, PORC, { R = 2, tok = ftok })
-- stem (slim, 5 px) with a collar
local stem = HP.rect(30, 46, 34, 54)
D.toneN(c, stem, D.vcylN(stem, 32, 2.5), PORC, { tok = ftok })
for x = 30, 34 do c:put(x, 54, PORC[2], ftok) end                     -- ambient where stem meets the foot
local collar = HP.rect(29, 51, 35, 52)
D.toneN(c, collar, D.vcylN(collar, 32, 3.5), PORC, { tok = ftok })
-- plate: rim thickness 2 + top
local ptop = D.ellipseMask(32, 43, 20, 4)
local prim = D.sweep(ptop, 2):cut(ptop)
D.toneN(c, prim, D.vcylN(prim, 32, 21, 0.5), PORC, { tok = ftok, bias = {} })
for x = 11, 53 do for y = 43, 50 do if prim:has(x, y) and not prim:has(x, y + 1) then c:put(x, y, PORC[2], ftok) end end end
-- cake (painted later) footprint, used for contact shadow on the plate
local CX, RX, TY, RY, H = 32, 13, 16, 4.5, 22
local ctop = D.ellipseMask(CX, TY, RX, RY)
local cbase = D.ellipseMask(CX, TY + H, RX, RY)
local pbias = {}
X.ao(pbias, ptop, cbase, 2, -1)
local pn = {} ptop:each(function(x, y) pn[K(x, y)] = { D.norm(-0.05, -0.55, 1) } end)
D.toneN(c, ptop, pn, PORC, { tok = ftok, bias = pbias })
-- bevel: bright inner lip on the back of the plate, a gilt-ish rim line
ptop:edge():each(function(x, y) if y < 43 then c:put(x, y, PORC[6], ftok) end end)
cbase:each(function(x, y) if ptop:has(x, y + 1) and not cbase:has(x, y + 1) then c:put(x, y + 1, PORC[1], ftok) end end)

-- cake side wall
local stok = D.tok("sponge")
local side = D.sweep(ctop, H):cut(ctop)
local sn = D.vcylN(side, CX, RX, 0.15)
local sidx = D.toneN(c, side, sn, SPONGE, { tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
local function topY(x) local u = (x - CX) / (RX + 0.45) return TY + RY * sqrt(max(0, 1 - u*u)) end
-- filling band (cream with a jam line) across the middle; crumb speckles in the sponge
side:each(function(x, y)
  local d = y - topY(x)
  local k = K(x, y)
  local i = sidx[k] or 3
  if d >= 11 and d < 14 then
    local ci = min(6, max(1, i + 1))
    c:put(x, y, CREAM[ci], stok)
    if d >= 13 then c:put(x, y, JAM, stok) end
    if d < 12 and i >= 4 and X.hash(x, y, 3) > 0.7 then c:put(x, y, CREAM[6], stok) end
  elseif d >= 14 and d < 15 then
    c:put(x, y, SPONGE[max(1, i - 2)], stok)                 -- ambient under the filling
  elseif X.hash(x, y, 7) > 0.84 and d > 3 then
    c:put(x, y, SPONGE[max(1, i - 1)], stok)                 -- crumb pores
  elseif X.hash(x, y, 9) > 0.92 and d > 3 and i >= 3 then
    c:put(x, y, SPONGE[min(6, i + 1)], stok)
  end
end)
-- reflected cool light on the lower-right edge of the sponge
side:each(function(x, y) if x == CX + RX and topY(x) + 5 < y then c:put(x, y, "#a8707a", stok) end end)

-- honey glaze: top + collar band + drips
local htok = D.tok("honey")
local glaze = ctop:copy()
side:each(function(x, y) if y - topY(x) < 2.5 then glaze:set(x, y) end end)
local drips = { { 20, 5, 2 }, { 23, 9, 2 }, { 27, 4, 2 }, { 31, 12, 3 }, { 35, 6, 2 }, { 39, 14, 3 }, { 43, 7, 2 } }
local dripM = HP.mask()
for _, d in ipairs(drips) do
  local x0, L, w = d[1], d[2], d[3]
  local y0 = floor(topY(x0))
  for y = y0, y0 + L do for x = x0, x0 + w - 1 do dripM:set(x, y) end end
  local by = y0 + L + 1
  for x = x0 - (w == 3 and 0 or 0), x0 + w - 1 do dripM:set(x, by) end
  if w == 3 then dripM:set(x0 + 1, by + 1) end
end
dripM:clip(side)
glaze:add(dripM)
local gn = {}
glaze:each(function(x, y)
  if ctop:has(x, y) then gn[K(x, y)] = { D.norm(-0.12 + (x - CX) * 0.02, -0.6, 1) }
  else local s = max(-0.97, min(0.97, (x - CX) / (RX + 0.5))) gn[K(x, y)] = { D.norm(s, 0.05, sqrt(1 - s*s)) } end
end)
D.toneN(c, glaze, gn, HONEY, { tok = htok, cuts = { 0.2, 0.36, 0.52, 0.66, 0.8 } })
-- drip bulbs: a lit pixel on each and a dark lip under
for _, d in ipairs(drips) do
  local x0, L = d[1], d[2]
  local y = floor(topY(x0)) + L
  if glaze:has(x0, y) then c:put(x0, y, HONEY[6], htok) end
end
-- glossy rim catch-light along the back of the glaze and the front lip
ctop:edge():each(function(x, y) if y < TY - 1 and x < CX + 4 then c:put(x, y, HONEY[5], htok) end end)
for x = 21, 26 do c:put(x, floor(topY(x)) + 1, HONEY[6], htok) end
-- sponge shadow just under the glaze lip
side:each(function(x, y) local d = y - topY(x)
  if not glaze:has(x, y) and glaze:has(x, y - 1) then c:put(x, y, SPONGE[max(1, (sidx[K(x, y)] or 3) - 2)], stok) end end)

-- mint sprig (behind berries)
local ltok = D.tok("leaf")
D.leaf(c, 30, 13, 25, 8.5, 2.1, LEAF, ltok)
D.leaf(c, 33, 13, 38, 8.5, 1.9, LEAF, ltok)
-- berries on top, back to front, with air between
local rtok, btok = D.tok("rasp"), D.tok("blue")
local function rasp(cx, cy, r)
  local m, n = D.oval(cx, cy, r, r * 0.95, 0)
  local idx = D.toneN(c, m, n, RASP, { tok = rtok })
  -- drupelets: bright beads on a staggered grid, darker gaps
  m:each(function(x, y) local k = K(x, y)
    if (x + (y % 2)) % 2 == 0 and (idx[k] or 3) >= 3 then c:put(x, y, RASP[min(6, idx[k] + 1)], rtok)
    elseif (idx[k] or 3) >= 4 then c:put(x, y, RASP[idx[k] - 1], rtok) end end)
  c:put(floor(cx - r * 0.4 + .5), floor(cy - r * 0.5 + .5), "#fff1e0", rtok)
  return m
end
local function blue(cx, cy, r)
  local m, n = D.oval(cx, cy, r, r * 0.9, 0)
  D.toneN(c, m, n, BLUE, { tok = btok })
  c:put(floor(cx + .5), floor(cy - .5), BLUE[1], btok)       -- crown eye
  c:put(floor(cx + 1.5), floor(cy - .5), BLUE[2], btok)
  c:put(floor(cx - r * 0.5 + .5), floor(cy - r * 0.5 + .5), BLUE[6], btok) -- waxy bloom catch
  c:put(floor(cx + r * 0.6 + .5), floor(cy + r * 0.5 + .5), "#6a5aa8", btok) -- cool bounce
  return m
end
local beads = {}
beads[#beads + 1] = rasp(25.5, 13, 2.5)
beads[#beads + 1] = blue(32, 12.5, 2.0)
beads[#beads + 1] = rasp(38.5, 13.5, 2.5)
beads[#beads + 1] = blue(22, 17.5, 1.9)
beads[#beads + 1] = rasp(30, 17.5, 2.6)
beads[#beads + 1] = blue(36.5, 18.5, 1.9)
beads[#beads + 1] = blue(42.5, 16, 1.5)
-- contact shadows on the glaze under each berry
for _, m in ipairs(beads) do
  m:shift(1, 1):each(function(x, y) if ctop:has(x, y) then
    local own = false for _, q in ipairs(beads) do if q:has(x, y) then own = true end end
    if not own then c:put(x, y, HONEY[2], htok) end end end)
end
-- one sparkle on the glaze
c:put(20, 19, "#fff4d6", htok)

-- quirk: a tiny bee hovering by the longest drip (head left, toward the honey)
local bx, by = 48, 26
local map = {
  ".ww.ww.",
  ".wWwwW.",
  "KYKYKy.",
  "KYKYKyK",
  ".KyKyK.",
}
local BC = { K = "#2b1c26", Y = "#ffd65a", y = "#de961c", w = "#e4f6ff", W = "#b9d6ef" }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(bx + xx - 1, by + yy - 1, BC[ch], D.tok("bee")) end end end
c:put(47, 28, "#2b1c26", D.tok("bee"))   -- stinger-less nose toward the cake
c:put(48, 28, "#fff4d6", D.tok("bee"))   -- eye glint
D.save(c, "ph", "feast-berry-honey-cake")
