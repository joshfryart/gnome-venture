-- cauliflower (ph, Opus single pass). A tight cream curd of knobbly florets (each floret its own lit dome, deep
-- violet crevices between them, fine granular speckle) cupped by four slim blue-green wrapper leaves with pale
-- midribs and swept veins; the two front leaves wrap over the curd foot (AO + contact shadow on the curd).
-- A pale cut stem stub with a fibrous ring underneath.
-- quirk: a little green inchworm arches over the right leaf.
local NAME = "cauliflower"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#163640", "#1d5554", "#2b7360", "#46936a", "#72b478", "#a6d496" }
local CURD = { "#6a5468", "#9c8580", "#c8b394", "#e4d4ae", "#f5ebcb", "#fffbe8" }
local RIB = "#d6eebc"
local STEM = { "#3d6a50", "#6a9a6c", "#9cc690", "#cfe6b0", "#eef6d6" }

local function lw(W) return function(t) if t > 0.985 then return -1 end
  return max(0.5, W * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.75) end end
-- geometry
local bl = { A.blade(29, 46, 13, 38, 10, 12, lw(6.2), { fold = 0.5 }) }
local br = { A.blade(35, 46, 51, 38, 54, 11, lw(6.2), { fold = 0.5 }) }
local fl = { A.blade(31, 51, 21, 46, 17, 33, lw(5.6), { fold = 0.45 }) }
local fr = { A.blade(33, 51, 43, 46, 47, 33, lw(5.6), { fold = 0.45 }) }

-- curd: florets on a dome
local CX, CY, RX, RY = 32, 33, 15, 11
local cen = {}
for row = -3, 3 do
  for col = -4, 4 do
    local x = CX + col * 5.2 + ((row % 2 == 0) and 0 or 2.6)
    local y = CY + row * 4.4
    local q = ((x - CX) / (RX - 2.2)) ^ 2 + ((y - CY) / (RY - 2)) ^ 2
    if q <= 1 then
      local r = 3.5 - q * 0.9 + (A.hash(col, row, 3) - 0.5) * 0.6
      cen[#cen + 1] = { x + (A.hash(col, row, 1) - 0.5) * 1.2, y + (A.hash(col, row, 2) - 0.5) * 1.0, r }
    end
  end
end
local cm = HP.mask()
for _, p in ipairs(cen) do cm:add(HP.ellipse(p[1], p[2], p[3], p[3])) end
local cn, crev = {}, {}
cm:each(function(x, y)
  local b1, b2, bp = 1e9, 1e9
  for _, p in ipairs(cen) do local d = sqrt((x - p[1]) ^ 2 + (y - p[2]) ^ 2) - p[3]
    if d < b1 then b2 = b1 b1, bp = d, p elseif d < b2 then b2 = d end end
  local dx, dy = (x - bp[1]) / (bp[3] + 0.6), (y - bp[2]) / (bp[3] + 0.6)
  local q = min(0.96, dx * dx + dy * dy)
  local ex, ey = (x - CX) / RX, (y - CY) / RY
  local eq = min(0.95, ex * ex + ey * ey)
  local nx, ny, nz = dx + ex * 0.8, dy + ey * 0.8, sqrt(1 - q) + sqrt(1 - eq) * 0.8
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  cn[K(x, y)] = { nx / l, ny / l, nz / l }
  if b2 - b1 < 0.9 then crev[K(x, y)] = true end
end)
local bias = {}
for k in pairs(crev) do bias[k] = -2 end
X.ao(bias, cm, fl[1], 2, -1) X.ao(bias, cm, fr[1], 2, -1)
A.cast(bias, cm, fl[1], 1, -2, -1) A.cast(bias, cm, fr[1], -1, -2, -1)
cm:each(function(x, y) local k = K(x, y) if not crev[k] and A.hash(x, y, 7) < 0.13 then bias[k] = (bias[k] or 0) - 1 end end)

-- back leaves first
local lb = {}
X.ao(lb, bl[1], cm, 2, -1) X.ao(lb, br[1], cm, 2, -1)
A.leaf(c, bl[1], bl[2], bl[3], bl[4], bl[5], LEAF, { bias = lb, ribHi = RIB, ribLo = LEAF[4], cool = "#3d6f86", tok = A.tok("bl") })
A.leaf(c, br[1], br[2], br[3], br[4], br[5], LEAF, { bias = lb, ribHi = RIB, ribLo = LEAF[4], cool = "#3d6f86", tok = A.tok("br") })
-- curd
local ctok = A.tok("curd")
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.1, wrap = 0.3 }), CURD, { cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 }, bias = bias, tok = ctok })
-- cool bounce on the lower-right of the curd rim
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and not crev[k] and (bias[k] or 0) == 0 then c:put(x, y, "#b4b0c4", ctok) end end)
-- one waxy glint on the top-left floret
do local bx, by = A.specAt(cm, cn, 60) c:put(bx, by, CURD[6], ctok) c:put(bx + 1, by, CURD[6], ctok) end
-- stem stub
local sm = HP.mask() sm:add(HP.rect(30, 50, 34, 54)) sm:add(HP.ellipse(32, 54, 2.5, 1.2))
local sn = {} sm:each(function(x, y) local t = max(-0.95, min(0.95, (x - 32) / 3)) sn[K(x, y)] = { t, 0.1, sqrt(1 - t * t) } end)
X.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = A.tok("stem") })
for x = 30, 34 do c:put(x, 50, STEM[1], A.tok("stem")) end
-- front leaves over curd
local fb = {}
X.ao(fb, fl[1], fr[1], 1, -1)
A.leaf(c, fr[1], fr[2], fr[3], fr[4], fr[5], LEAF, { bias = {}, ribHi = RIB, ribLo = LEAF[4], cool = "#3d6f86", tok = A.tok("fr") })
A.leaf(c, fl[1], fl[2], fl[3], fl[4], fl[5], LEAF, { bias = {}, ribHi = RIB, ribLo = LEAF[4], cool = "#3d6f86", tok = A.tok("fl") })

-- quirk: inchworm arched on the right back leaf
local wx, wy = 51, 20
local map = {
  ".gGG..",
  "gG..Gh",
  "G....e",
  "G.....",
}
local WC = { g = "#9ee05a", G = "#5aa83a", h = "#c8f07a", e = "#2b1c26" }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if WC[ch] then c:put(wx + xx - 1, wy + yy - 1, WC[ch]) end end end
A.save2(c, NAME)
