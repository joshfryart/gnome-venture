-- ico-burst (final, Opus). Comic impact burst: an irregular 9-spike ember star, a rotated 7-spike gold star inside it
-- and a hot cream-yellow core, stacked like bevelled cut-outs.
-- Material: each layer is a bevelled slab (pillow normals, 6-tone ramp, lit upper-left bevel, dark lower-right
-- bevel), contact shadow cast down-right by each upper layer onto the one below, deep AO line where layers meet,
-- one specular glint on the core and a crease line down the centre of each long spike (folded paper look).
-- quirk: one spike tip has snapped off and is flying away.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("ico-burst")
local EMB  = { "#5e1834", "#8e2238", "#c2333a", "#e8533a", "#ff8452", "#ffb27a" }
local GOLD = { "#9a4a1c", "#cc7422", "#ee9e2a", "#fbc540", "#ffe07a", "#fff2b4" }
local CORE = { "#f2a83a", "#ffcf5a", "#ffe58a", "#fff0b6", "#fff7da", "#fffbec" }

local CX, CY = 31.5, 32
local OR = { 25, 19, 24, 21, 25, 18, 23, 20, 24 }
local outer = A.star(CX, CY, 9, function(i) return OR[i + 1] end, function(i) return (i % 2 == 0) and 13 or 14.5 end, -pi / 2 + 0.12)
-- snap the tip of spike 3 (lower right) off: cut it, fling the shard
local a3 = -pi / 2 + 0.12 + 3 * 2 * pi / 9
local tipcut = HP.mask()
outer:each(function(x, y) local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local pr = -dx * sin(a3) + dy * cos(a3)
  if (dx * cos(a3) + dy * sin(a3)) > 18.6 + (floor(pr + 10) % 2) * 1.3 then tipcut:set(x, y) end end)
outer:cut(tipcut)
local mid = A.star(CX - 0.5, CY - 0.5, 7, function(i) return (i % 2 == 0) and 15 or 13 end, 8.5, -pi / 2 + 0.45)
local core = A.star(CX - 0.5, CY - 0.5, 8, function(i) return (i % 2 == 0) and 8.5 or 7 end, 5, -pi / 2):add(A.ell(CX - 0.5, CY - 0.5, 4.6, 4.6))

-- faceted fold: each spike splits along its axis into a lit facet and a shade facet
local function facets(bias, m, n, a0, cx, cy, excl)
  m:each(function(x, y) if not (excl and excl:has(x, y)) then
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local a = math.atan(dy, dx)
    local step = 2 * pi / n
    local f = (a - a0) / step
    local ai = a0 + floor(f + 0.5) * step                -- nearest spike axis
    local off = a - ai
    off = (off + pi) % (2 * pi) - pi
    local px, py = -sin(ai), cos(ai)                     -- perpendicular (+off side)
    local lit = (px * -0.55 + py * -0.7) > 0
    local k = K(x, y)
    local side = (off > 0) == lit
    if abs(off) > 0.025 then bias[k] = (bias[k] or 0) + (side and 1 or -1) end
  end end)
end
local function slab(m, ramp, name, bias, R)
  local n = X.pillow(m, R or 2.6)
  local tok = A.tok(name)
  local idx = A.shade(c, m, n, ramp, { tok = tok, bias = bias, amb = 0.1, wrap = 0.2, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  return idx, tok, n
end
-- outer: AO + cast shadow from the gold star
local ob = {}

A.cast(ob, outer, mid, 1, 2, -1)
X.ao(ob, outer, mid, 1, -1)
facets(ob, outer, 9, -pi / 2 + 0.12, CX, CY, mid)
local oidx, otok = slab(outer, EMB, "ember", ob, 3)
-- mid gold star
local mb = {}
A.cast(mb, mid, core, 1, 1, -1)
X.ao(mb, mid, core, 1, -1)
facets(mb, mid, 7, -pi / 2 + 0.45, CX - 0.5, CY - 0.5, core)
local midx, mtok = slab(mid, GOLD, "gold", mb, 2.4)
-- inner deep edge where gold sits on ember (separation line)
mid:edge():each(function(x, y)
  for _, d in ipairs{ {1,0}, {0,1}, {1,1} } do
    if outer:has(x + d[1], y + d[2]) and not mid:has(x + d[1], y + d[2]) then c:put(x, y, GOLD[1], mtok) break end
  end
end)
-- core
local cb = {}
facets(cb, core, 8, -pi / 2, CX - 0.5, CY - 0.5)
local cidx, ctok, cn = slab(core, CORE, "core", cb, 2.2)
-- hot white-cream centre + glint
A.ell(CX - 0.5, CY - 0.5, 2.2, 2.2):each(function(x, y) c:put(x, y, CORE[6], ctok) end)
c:put(28, 28, A.CREAM, ctok) c:put(29, 28, A.CREAM, ctok)
-- flying shard: the snapped tip, rotated and moved further out along its spike
local sx, sy = CX + cos(a3) * 26.5, CY + sin(a3) * 26.5 + 1.5
local shard = HP.poly{ { sx - 2.5, sy - 2.2 }, { sx + 3.2, sy + 0.2 }, { sx - 1.6, sy + 2.6 } }
local sb = {}
local sn = X.pillow(shard, 1.4)
A.shade(c, shard, sn, EMB, { tok = A.tok("shard"), amb = 0.15, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
A.save(c, "ico-burst")
