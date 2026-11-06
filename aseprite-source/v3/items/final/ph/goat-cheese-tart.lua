-- goat-cheese-tart (final, Opus aB35 single pass). Shallow fluted shortcrust tart seen 3/4 from above: fluted wall
-- (per-flute normals), a pillowed golden rim, the inner back wall in shadow, a pale baked custard with brown blisters,
-- four rounds of goat cheese (bloomy grey rind ring, white top, broiled gold spot) and a thyme sprig.
-- AO where custard meets the crust and under each cheese round; ground shadow.
-- quirk: a tiny ant on the front rim, carrying off a crumb.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_0.lua")
local HP, X, K, norm = A.HP, A.X, A.K, A.norm
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("goat-cheese-tart")
local CRUST = { "#4e2420", "#7e3a26", "#a85a2a", "#c97a34", "#e4a04e", "#f6cc7c" }
local CUST  = { "#8f5a2a", "#c08a3a", "#e0b052", "#f0cc72", "#f9e29e", "#fff3c8" }
local CHZ   = { "#6a5f72", "#9d93a3", "#c9c1c4", "#e6dfd8", "#f6f1e8", "#fffcf2" }
local THY   = { "#1f4a3a", "#2e7646", "#5aa452", "#9dd06c" }
local CX, TY, BY, RX, RY = 32, 27, 33, 22, 9

c:groundShadow(CX, BY + RY - 1, RX + 1, 3)
-- fluted wall: union of top and bottom ellipses + band, scalloped bottom edge
local wall = HP.ellipse(CX, BY, RX, RY):add(HP.rect(CX - RX, TY, CX + RX, BY))
local wtok = { r = { name = "wall" } }
local wn, wb = {}, {}
wall:each(function(x, y)
  local dx = (x - CX) / (RX + 0.5)
  local ph = sin((x - CX) * 2 * pi / 3.2)
  wn[K(x, y)] = { norm(dx + ph * 0.45, 0.15, sqrt(max(0.05, 1 - dx * dx))) }
  if ph < -0.55 then wb[K(x, y)] = -1 end   -- flute grooves
end)
A.shade(c, wall, wn, CRUST, { bias = wb, tok = wtok, amb = 0.1 })
-- rim ring (top face, pillowed)
local outer = HP.ellipse(CX, TY, RX, RY)
local inner = HP.ellipse(CX, TY, RX - 3, RY - 3)
local rim = outer:copy():cut(inner)
local pn = X.pillow(rim, 1.6)
local rn = {}
for k, n in pairs(pn) do rn[k] = { norm(n[1], n[2] * 0.7 - 0.55, n[3]) } end
local rtok = { r = { name = "rim" } }
local ridx = A.shade(c, rim, rn, CRUST, { tok = rtok, amb = 0.14 })
-- crimp marks on the rim (little dents every 4 px on the front arc)
rim:each(function(x, y) if y > TY + 3 and (x - CX) % 4 == 0 then A.step(c, ridx, CRUST, x, y, -1, rtok) end end)
-- inner back wall (in shadow) and custard
local cust = HP.ellipse(CX, TY + 1, RX - 3, RY - 3):clip(inner)
local back = inner:copy():cut(cust)
c:fillMask(back, CRUST[2])
back:each(function(x, y) if not back:has(x, y - 1) then c:put(x, y, CRUST[1]) end end)
local cn = X.pillow(cust, 3)
local cnn, cb = {}, {}
for k, n in pairs(cn) do cnn[k] = { norm(n[1] * 0.6, n[2] * 0.6 - 0.6, n[3]) } end
X.ao(cb, cust, rim, 1, -1)
local ctok = { r = { name = "custard" } }
local cidx = A.shade(c, cust, cnn, CUST, { bias = cb, tok = ctok, amb = 0.2 })
-- baked blisters
for _, p in ipairs{ { 18, 26 }, { 24, 31 }, { 45, 26 }, { 38, 32 }, { 30, 24 }, { 47, 30 } } do
  if cust:has(p[1], p[2]) then c:put(p[1], p[2], CUST[2], ctok) if cust:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], CUST[3], ctok) end end
end
-- cheese rounds: little cylinders (top ellipse + 1-2 px side), rind ring, broiled spot
local function round(x0, y0, r)
  local top = HP.ellipse(x0, y0, r, r * 0.55)
  local side = HP.ellipse(x0, y0 + 1.5, r, r * 0.55):cut(top)
  local tok = { r = { name = "chz" } }
  -- contact shadow on the custard
  HP.ellipse(x0 + 1, y0 + 2.5, r, r * 0.5):each(function(x, y)
    if cust:has(x, y) and not top:has(x, y) and not side:has(x, y) then A.step(c, cidx, CUST, x, y, -2, ctok) end end)
  side:each(function(x, y) c:put(x, y, x < x0 - 1 and CHZ[3] or CHZ[2], tok) end)
  local tn = X.pillow(top, 1.5)
  for k, n in pairs(tn) do tn[k] = { norm(n[1], n[2] * 0.7 - 0.5, n[3]) } end
  local idx = A.shade(c, top, tn, CHZ, { tok = tok, amb = 0.3 })
  top:edge():each(function(x, y) if y >= y0 then A.step(c, idx, CHZ, x, y, -1, tok) end end)
  c:put(x0 + 1, y0, "#e8b45a", tok) c:put(x0 + 2, y0, "#d9923e", tok) c:put(x0 + 1, y0 + 1, "#efc874", tok)
  c:put(x0 - 2, y0 - 1, CHZ[6], tok)
end
round(21, 26, 4) round(35, 24, 4.5) round(29, 31, 4.5)
-- thyme sprig: thin stem with paired leaves
local tt = { r = { name = "thyme" } }
local st = { { 39, 32 }, { 40, 31 }, { 41, 31 }, { 42, 30 }, { 43, 30 }, { 44, 29 }, { 45, 29 }, { 46, 28 } }
for i, p in ipairs(st) do c:put(p[1], p[2], i < 3 and "#6a4a2a" or THY[1], tt) end
for _, l in ipairs{ { 40, 30, 3 }, { 41, 32, 2 }, { 42, 29, 3 }, { 43, 31, 2 }, { 44, 28, 4 }, { 45, 30, 2 }, { 46, 27, 4 }, { 47, 28, 3 }, { 47, 27, 4 } } do
  c:put(l[1], l[2], THY[l[3]], tt)
end
-- quirk: a tiny ant on the front rim with a crumb
local ax, ay = 23, 35
A.map(c, {
  "....cC",
  ".k.kk.",
  "kkkKkk",
  ".k.k.k",
}, ax, ay - 2, { k = "#2b1c26", K = "#5a3a4a", c = "#fbe09a", C = "#d9923e" })
A.save(c, "goat-cheese-tart")
