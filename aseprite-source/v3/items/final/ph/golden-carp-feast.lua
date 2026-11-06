-- golden-carp-feast (Opus single pass, aB35_1). A whole roast golden carp on an oval glazed platter, three-quarter top view.
-- Platter: lit rim bevel, sunk well with AO under the rim, visible front edge, 2-tone ground shadow. A pool of amber glaze
-- under the fish. Fish: slim tube body in a 6-tone roast ramp, three diagonal score cuts (dark groove + lit lip),
-- crisp darker tail and dorsal, glossy specular streak, cooked cream eye, contact shadow on the plate.
-- Garnish: lemon wedge (rind + segmented flesh) and a dill sprig laid on the fish.
-- quirk: someone has already sneaked one bite out of its back.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "golden-carp-feast"
local c = G.new2(NAME)
local PLATE = { "#4e4a68", "#7c7a98", "#a9a8c0", "#cfcde0", "#e9e6ef", "#fbf6ea" }
local ROAST = { "#4a2020", "#7a3a1e", "#b05a1c", "#d9821f", "#f2ad38", "#ffd977" }
local GLAZE = { "#8f4a1f", "#c8701f", "#e8962c" }
local LEM = { "#8a5a1a", "#c9941e", "#f0c62e", "#ffe35a", "#fff3a8" }
local HERB = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local CX, CY = 32, 41

-- ground shadow + platter side + top
c:groundShadow(CX + 1, CY + 6, 23, 3)
local top = G.rell(CX, CY, 1, 0, 25.5, 9.5)
local side = top:shift(0, 2):cut(top)
local ptok = { r = { name = "plate" } }
side:each(function(x, y) c:put(x, y, (x < CX - 12) and PLATE[3] or PLATE[2], ptok) end)
local well = G.rell(CX, CY - 0.5, 1, 0, 20.5, 6.5)
local rimm = top:copy():cut(well)
-- rim: convex bevel, lit upper-left
local rn = X.pillow(rimm, 1.6)
X.tone(c, rimm, X.light(rn, { amb = 0.3, wrap = 0.4 }), PLATE, { cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 }, tok = ptok })
-- well: concave, lit on the lower-right inner slope, AO under the upper rim
well:each(function(x, y)
  local dx, dy = (x - CX) / 20.5, (y - CY + 0.5) / 6.5
  local q = dx * dx + dy * dy
  local i = 5
  if q > 0.62 then i = (dy < 0 or dx < -0.4) and 3 or 6 end
  if q > 0.62 and dy < -0.3 then i = 3 end
  c:put(x, y, PLATE[i], ptok)
end)
well:edge():each(function(x, y) if y < CY - 3 then c:put(x, y, PLATE[2], ptok) end end)
-- blue glaze band on the rim (painted ware), 1 px, follows the rim mid line
rimm:each(function(x, y)
  local dx, dy = (x - CX) / 23.2, (y - CY + 0.2) / 8.1
  local q = dx * dx + dy * dy
  if q > 0.94 and q < 1.08 and (x + y) % 4 ~= 0 then c:put(x, y, (y < CY) and "#5fc4c8" or "#3a86b0", ptok) end
end)

-- glaze pool under the fish
local pool = G.rell(CX - 1, CY + 1, 1, 0, 17, 4.2)
pool:clip(well)
local gtok = { r = { name = "glaze" } }
pool:each(function(x, y) c:put(x, y, GLAZE[2], gtok) end)
pool:edge():each(function(x, y) c:put(x, y, y > CY + 1 and GLAZE[3] or GLAZE[1], gtok) end)

-- fish body
local p = { { 15, 39 }, { 24, 36 }, { 38, 35 }, { 47, 38 } }
local function hw(t)
  if t < 0.6 then return 1.6 + 4.0 * sin(t / 0.6 * pi / 2) ^ 1.2 end
  return 5.6 * sqrt(max(0, 1 - ((t - 0.6) / 0.42) ^ 2)) + 0.3
end
local fm, fn, FT, FS, samp = G.tube(p, hw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- quirk: a bite out of the back
local bx, by = G.at(samp, 0.4, -1.15)
local bite = G.rell(bx, by, 1, 0, 2.9, 2.6)
fm:cut(bite)
local ftok = { r = { name = "fish" } }
-- tail + dorsal: crisp, darker
local tail = c:poly{ { 17, 37 }, { 11, 32 }, { 9, 34 }, { 12, 39 }, { 9, 44 }, { 11, 45 }, { 17, 41 } }
tail:cut(fm)
X.tone(c, tail, X.light(X.pillow(tail, 1.5), { amb = 0.1, wrap = 0.3 }), ROAST, { cuts = { 0.25, 0.42, 0.6, 0.78, 0.95 }, tok = ftok })
for _, q in ipairs{ { 13, 35 }, { 14, 36 }, { 13, 42 }, { 14, 41 }, { 12, 38 } } do G.pin(c, tail, q[1], q[2], ROAST[2], ftok) end
local dx0, dy0 = G.at(samp, 0.56, -0.9)
local dorsal = c:poly{ { dx0 - 4, dy0 + 1 }, { dx0 - 1, dy0 - 4 }, { dx0 + 3, dy0 - 3 }, { dx0 + 5, dy0 + 1 } }
dorsal:cut(fm)
X.tone(c, dorsal, X.light(X.pillow(dorsal, 1.3), { amb = 0.1, wrap = 0.3 }), ROAST, { cuts = { 0.25, 0.42, 0.6, 0.78, 0.95 }, tok = ftok })
G.pin(c, dorsal, dx0, dy0 - 2, ROAST[2], ftok) G.pin(c, dorsal, dx0 + 2, dy0 - 1, ROAST[2], ftok)
-- contact shadow of the fish on the plate/glaze
fm:shift(1, 2):each(function(x, y)
  if not fm:has(x, y) and well:has(x, y) then c:put(x, y, pool:has(x, y) and GLAZE[1] or PLATE[3], gtok) end end)
-- body light
local bias = {}
X.ao(bias, fm, bite, 1, -1)
local idx = X.tone(c, fm, X.light(fn, { amb = 0.08, wrap = 0.3 }), ROAST, { cuts = CUTS, bias = bias, tok = ftok })
-- bite: pale flesh rim inside the bite
bite:grow(1):cut(bite):each(function(x, y) if fm:has(x, y) then c:put(x, y, (y > by) and "#f6dcae" or "#fbe9c6", ftok) end end)
-- score cuts: diagonal grooves with a lit lip
for _, tc in ipairs{ 0.28, 0.5, 0.68 } do
  fm:each(function(x, y) local k = K(x, y)
    local t, s = FT[k], FS[k]
    if abs(s) > 0.8 then return end
    local d = (t - tc) * LEN + s * 2.2
    if d > -0.5 and d < 0.5 then c:put(x, y, ROAST[max(1, idx[k] - 2)], ftok)
    elseif d >= 0.5 and d < 1.5 and s < 0.4 then c:put(x, y, ROAST[min(6, idx[k] + 1)], ftok) end
  end)
end
-- gill arc
fm:each(function(x, y) local k = K(x, y)
  local d = (FT[k] - 0.8) * LEN + FS[k] * FS[k] * 2.4
  if d > -0.5 and d < 0.5 and abs(FS[k]) < 0.85 then c:put(x, y, ROAST[max(1, idx[k] - 2)], ftok) end end)
-- glossy streak + glint
for _, t in ipairs{ 0.62, 0.66, 0.7, 0.74 } do local x, y = G.at(samp, t, -0.55) G.pin(c, fm, x, y, ROAST[6], ftok) end
do local x, y = G.at(samp, 0.66, -0.55) G.pin(c, fm, x, y - 0, "#fff6dc", ftok) end
-- cooked eye
local ex, ey = G.at(samp, 0.9, -0.25)
c:put(ex, ey, "#fbf0d6", ftok) c:put(ex + 1, ey, "#e8dcc0", ftok) c:put(ex, ey + 1, "#e8dcc0", ftok) c:put(ex + 1, ey + 1, "#2b1c26", ftok)
c:put(ex - 1, ey, ROAST[2], ftok) c:put(ex, ey - 1, ROAST[2], ftok)
local mx, my = G.at(samp, 0.99, 0.2) c:put(mx, my, ROAST[1], ftok)

-- dill sprig on the fish (stem + feathery tufts)
local htok = { r = { name = "herb" } }
local sx, sy = G.at(samp, 0.72, 0.1)
for i = 0, 6 do c:put(sx - i, sy - floor(i / 3), HERB[2], htok) end
for _, q in ipairs{ { -1, -1, 3 }, { -2, 1, 2 }, { -3, -2, 4 }, { -4, 0, 3 }, { -5, -2, 3 }, { -6, 0, 2 }, { -7, -3, 4 }, { 1, -1, 3 } } do
  c:put(sx + q[1], sy + q[2], HERB[q[3]], htok) end

-- lemon wedge at the front right (rind lower, flesh upper face with segment lines)
local ltok = { r = { name = "lemon" } }
local lx, ly = 46, 45
local wedge = HP.mask()
for y = ly - 4, ly + 3 do for x = lx - 6, lx + 6 do
  local dx, dy = (x - lx) / 6.4, (y - ly + 0.5) / 3.6
  if dx * dx + dy * dy <= 1 and y >= ly - 3 then wedge:set(x, y) end
end end
wedge:each(function(x, y)
  local dx, dy = (x - lx) / 6.4, (y - ly + 0.5) / 3.6
  local q = dx * dx + dy * dy
  local i
  if y <= ly - 1 then i = (q > 0.7) and 5 or 4         -- flesh face (top), pith edge pale
  else i = (dx < -0.2) and 4 or ((q > 0.8) and 2 or 3) end -- rind side
  c:put(x, y, LEM[i], ltok)
end)
for _, q in ipairs{ { lx - 3, ly - 2 }, { lx, ly - 3 }, { lx + 3, ly - 2 }, { lx - 1, ly - 2 }, { lx + 1, ly - 2 } } do
  if wedge:has(q[1], q[2]) then c:put(q[1], q[2], LEM[3], ltok) end end
c:put(lx - 2, ly - 3, LEM[5], ltok)
c:put(lx - 4, ly + 1, "#fffbe0", ltok)
G.save2(c, NAME)
