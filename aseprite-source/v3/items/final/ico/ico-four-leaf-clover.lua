-- ico-four-leaf-clover (final, Opus): four heart-shaped leaflets in an X on a slim curving stalk; the fourth
-- (lower-right) leaflet is a touch smaller, as the lucky one usually is.
-- Material: per-pixel pillow light with a V fold along each midrib, pale midrib, the clover's pale chevron
-- watermark, a few lateral veins, AO + a dark knot where the leaflets meet the stalk, separation lines between leaflets.
-- quirk: a single dewdrop (glassy: bright rim, pale core, contact shadow) sits on the upper-right leaflet.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor, cos, sin, pi = math.sqrt, math.max, math.min, math.abs, math.floor, math.cos, math.sin, math.pi
local c = A.new("ico-four-leaf-clover")
local LEAF  = { "#1a4636", "#24603f", "#327e45", "#4b9e4c", "#71bf56", "#a6db72" }
local STALK = { "#1f4f3a", "#2f7444", "#4f9a4e", "#7cbc5e", "#a6d47a" }
local SEA   = { "#2f66a6", "#5fbfd6", "#b6f0e0", "#e4fbf6" }
local CX, CY = 31, 27

-- stalk first (leaflets lap over its top)
local sm, sn, sT, sS, sidx = A.tube(c, { { CX, CY + 1 }, { CX + 1, CY + 12 }, { CX + 5, CY + 22 }, { CX + 8, CY + 30 } },
  function(t) return 1.45 - t * 0.3 end, STALK, { tok = { r = { name = "stalk" } }, cuts = { 0.3, 0.5, 0.68, 0.84 } })
local stok = { r = { name = "stalk" } }
sm:each(function(x, y) if sT[K(x, y)] < 0.18 then A.step(c, sidx, STALK, x, y, -1, stok) end end) -- AO under the leaves

local leaves, lidx, ltok = {}, {}, {}
-- air between the leaflets: thin wedges along the bisectors (the outline turns them into ink seams)
local GAPS = {}
for _, b in ipairs{ -pi * 0.5, 0, pi * 0.5, pi } do
  local ux, uy = cos(b), sin(b)
  local g = HP.mask()
  for r = 2.5, 24, 0.25 do
    local w = r < 5 and 0.5 or 0.5 + (r - 5) * 0.16
    g:add(c:ellipse(CX + ux * r, CY + uy * r, w, w))
  end
  GAPS[#GAPS + 1] = g
end
local function leaflet(i, ang, L)
  local ux, uy = cos(ang), sin(ang)
  local px, py = -uy, ux
  local m = A.rell(CX + ux * 0.42 * L, CY + uy * 0.42 * L, ux, uy, 0.44 * L, 0.27 * L)
  for _, sd in ipairs{ -1, 1 } do
    local lx, ly = CX + ux * 0.66 * L + px * sd * 0.27 * L, CY + uy * 0.66 * L + py * sd * 0.27 * L
    m:add(c:ellipse(lx, ly, 0.31 * L, 0.31 * L))
  end
  m:cut(c:ellipse(CX, CY, 1.6, 1.6))
  m:cut(c:ellipse(CX + ux * 0.99 * L, CY + uy * 0.99 * L, 0.17 * L, 0.17 * L))   -- heart notch
  for _, g in ipairs(GAPS) do m:cut(g) end
  local pn = X.pillow(m, 3)
  local n, AL, PR = {}, {}, {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - CX, y - CY
    local a, p = dx * ux + dy * uy, dx * px + dy * py
    AL[k], PR[k] = a, p
    local f = (p < 0 and -1 or 1) * 0.22
    local q = pn[k]
    n[k] = { A.norm(q[1] + px * f, q[2] + py * f, q[3]) }
  end)
  local tok = { r = { name = "leaf" .. i } }
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if AL[k] < 0.22 * L then bias[k] = -1 end end)  -- AO at the base
  local idx = A.shade(c, m, n, LEAF, { cuts = { 0.24, 0.4, 0.56, 0.72, 0.87 }, amb = 0.1, wrap = 0.28, tok = tok, bias = bias })
  m:each(function(x, y) local k = K(x, y)
    local a, p = AL[k], PR[k]
    local i0 = idx[k]
    if abs(p) < 0.5 and a > 0.12 * L and a < 0.86 * L then
      c:put(x, y, LEAF[min(6, i0 + 2)], tok)                                     -- pale midrib
    elseif abs(a - (0.34 * L + abs(p) * 0.8)) < 0.7 and abs(p) > 1 and abs(p) < 0.42 * L then
      c:put(x, y, LEAF[min(6, i0 + 2)], tok)                                     -- chevron watermark
    elseif abs(p) > 1.2 and abs(p) < 0.4 * L and a > 0.55 * L and a < 0.85 * L and floor(a - abs(p) * 0.7 + 0.5) % 3 == 0 then
      c:put(x, y, LEAF[max(1, i0 - 1)], tok)                                     -- lateral veins
    end
  end)
  leaves[i], lidx[i], ltok[i] = m, idx, tok
end
leaflet(1, -pi * 0.74, 19)
leaflet(2, -pi * 0.26, 19)
leaflet(3, pi * 0.75, 18.5)
leaflet(4, pi * 0.25, 17)
-- separate neighbouring leaflets (same ramp) with a dark row on the later one
for i = 2, 4 do for j = 1, i - 1 do A.sep(c, leaves[i], lidx[i], LEAF, leaves[j], -2, ltok[i]) end end
-- knot where leaflets meet the stalk
for _, p in ipairs{ { CX - 1, CY - 1, 2 }, { CX, CY - 1, 3 }, { CX - 1, CY, 2 }, { CX, CY, 2 }, { CX + 1, CY, 1 }, { CX, CY + 1, 1 }, { CX + 1, CY - 1, 2 }, { CX - 1, CY + 1, 1 }, { CX + 1, CY + 1, 1 } } do
  c:put(p[1], p[2], STALK[p[3]], stok) end
c:put(CX - 1, CY - 1, STALK[4], stok)

-- quirk: a dewdrop on the upper-right leaflet, with its contact shadow
local dx, dy = CX + 11, CY - 10
for _, p in ipairs{ { 1, 3 }, { 2, 3 }, { 3, 2 }, { 3, 1 } } do
  local x, y = dx + p[1], dy + p[2] if leaves[2]:has(x, y) then c:put(x, y, LEAF[1], ltok[2]) end end
local drop = {
  ".bb.",
  "bcpb",
  "bppd",
  ".dd.",
}
A.map(c, drop, dx - 1, dy - 1, { b = SEA[2], c = A.CREAM, p = SEA[3], d = SEA[1] }, { r = { name = "dew" } })
c:put(dx, dy, SEA[4], { r = { name = "dew" } })
A.save(c, "ico-four-leaf-clover")
