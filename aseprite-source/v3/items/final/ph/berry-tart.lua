-- berry-tart (final, Opus single pass). A low open tart in three-quarter view: fluted golden shortcrust wall,
-- a crimped beaded rim, and a glossy sunken pool of berry filling studded with whole bilberries.
-- Material: per-pixel light. Crust: 6-tone gold-brown, vertical flutes on the wall (lit ridge / dark groove),
-- pillowed crimp beads round the rim, AO where the filling meets the rim. Filling: 6-tone glossy magenta jam with
-- glaze glints. Berries: little dusky spheres with a glint each. 2-tone ground shadow.
-- quirk: somebody has already taken a bite out of the front edge (crumbly pale cut face).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.atan, math.pi
local c = A.new("berry-tart")
local CR  = { "#5a2a22", "#8a4a2a", "#b8733a", "#d99a4c", "#eec06a", "#fbe09a" }
local JAM = { "#2a1032", "#4a1850", "#702468", "#9a3478", "#c65a94", "#f2a2c4" }
local BER = { "#1a1438", "#2a2560", "#3d3f8a", "#5560a8", "#7d8cc6", "#b3c0e6" }
local CRUMB = { "#e8c890", "#fff0c4" }
local CX, CY, RX, RY, WALL = 32, 27, 22, 11, 7

c:groundShadow(CX + 1, CY + WALL + 3, RX + 1, 3)
-- bite: three overlapping circles at the front-left edge
local bite = HP.mask()
for d = 0, WALL do bite:add(c:ellipse(18, 35 + d, 3.2, 3.0)):add(c:ellipse(22.5, 36.5 + d, 3.0, 2.8)) end
local function scal(x, y, cy)    -- crimped (scalloped) outer ellipse test
  local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - cy) / RY
  local a = atan(dy, dx)
  local rr = 1 + 0.045 * cos(a * 16)
  return dx * dx + dy * dy <= rr * rr, a
end
-- wall: union of the top ellipse swept down, front half only shows
local wall, top = HP.mask(), HP.mask()
for y = CY - RY - 2, CY + RY + WALL + 2 do for x = CX - RX - 2, CX + RX + 2 do
  if scal(x, y, CY) then top:set(x, y) end
  for d = 0, WALL do if scal(x, y, CY + d) then wall:set(x, y) break end end
end end
wall:cut(top)
wall:cut(bite) top:cut(bite)
-- wall normals: cylinder across x, flutes modulate
local wn = {}
wall:each(function(x, y)
  local s = max(-0.97, min(0.97, (x + 0.5 - CX) / (RX + 0.5)))
  local a = math.acos(s)
  local fl = sin(a * 16 * 1.0 + 0.3) * 0.45
  wn[K(x, y)] = { A.norm(s + fl * sqrt(1 - s * s), 0.25, sqrt(1 - s * s)) }
end)
local wtok = { r = { name = "crust" } }
local wb = {}
X.ao(wb, wall, top, 1, -1)
A.tone(c, wall, wn, CR, { amb = 0.1, wrap = 0.3, bias = wb, tok = wtok })
-- rim ring (pillowed beads) and filling pool
local pool = c:ellipse(CX - 0.5, CY - 0.5, RX - 4, RY - 3)
local ring = top:copy():cut(pool)
local rn = X.pillow(ring, 2.2)
-- bead pattern: brighten crests between crimps
local rb = {}
ring:each(function(x, y) local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - CY) / RY
  local a = atan(dy, dx) if cos(a * 16) < -0.55 then rb[K(x, y)] = -1 end end)
A.tone(c, ring, rn, CR, { amb = 0.12, wrap = 0.3, bias = rb, tok = wtok })
-- filling: shallow dish, lit from upper left, AO under the back rim
local jn = {}
pool:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / (RX - 4), (y + 0.5 - CY) / (RY - 3)
  jn[K(x, y)] = { A.norm(-dx * 0.35, -dy * 0.35, 1) }   -- concave
end)
local jb = {}
X.ao(jb, pool, ring, 1, -2)
local jtok = { r = { name = "jam" } }
A.tone(c, pool, jn, JAM, { amb = 0.15, wrap = 0.3, bias = jb, tok = jtok, cuts = { 0.3, 0.45, 0.6, 0.78, 0.92 } })
-- glaze glints
for _, g in ipairs{ {26, 24}, {27, 24}, {38, 31}, {22, 30} } do c:put(g[1], g[2], JAM[6], jtok) end
-- berries on the filling (back to front)
local bs = { {24, 22}, {31, 20}, {38, 21}, {44, 25}, {20, 27}, {28, 27}, {35, 26}, {41, 30}, {25, 32}, {32, 32}, {46, 30} }
table.sort(bs, function(a, b) return a[2] < b[2] end)
for _, b in ipairs(bs) do
  if pool:has(b[1], b[2]) then
    -- contact shadow on the jam under each berry
    c:put(b[1] + 1, b[2] + 3, JAM[1], jtok) c:put(b[1] + 2, b[2] + 2, JAM[1], jtok) c:put(b[1], b[2] + 3, JAM[2], jtok)
    A.berry(c, b[1] + 0.5, b[2] + 0.5, 2.2, BER, { spec = "#e8ecff", tok = { r = { name = "b" .. b[1] .. b[2] } } })
    c:put(b[1] + 1, b[2] + 1, BER[1])                     -- tiny crown
  end
end
-- bite cut face: pale crumb along the bitten crust edge
local crust = wall:copy():add(ring)
crust:each(function(x, y)
  for _, d in ipairs{ {1, 0}, {-1, 0}, {0, 1}, {0, -1} } do
    if bite:has(x + d[1], y + d[2]) then c:put(x, y, (x + y) % 3 == 0 and CRUMB[2] or CRUMB[1], wtok) break end
  end
end)
-- shortcrust specks (baked sugar) on the rim
for _, p in ipairs{ {16, 22}, {29, 15}, {44, 17}, {50, 26}, {36, 37} } do if ring:has(p[1], p[2]) then c:put(p[1], p[2], CR[6], wtok) end end
-- one rim glint
c:put(18, 19, A.CREAM, wtok) c:put(19, 19, CR[6], wtok)
-- a crumb flying from the bite
c:put(11, 44, CRUMB[1]) c:put(12, 44, CR[4])
A.fin(c, "berry-tart")
