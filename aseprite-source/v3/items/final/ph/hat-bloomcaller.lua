-- hat-bloomcaller (final, Opus aC11_0). A tall, slim felt wizard-gardener hat in rose-violet: a narrow cone whose tip
-- bends over to the right, a wide soft brim, a moss-green satin band with a big open sunny bloom pinned on it, and a
-- climbing vine with three leaves spiralling up the cone. Material: per-pixel tube light on the cone (6 tones),
-- diagonal felt creases (dark groove + lit lip), brim lit as a soft disc with a dark underside lip and AO under the
-- cone, satin band with a bright sheen line, petals with a midline vein, the one gold stitch along the brim hem.
-- quirk: the bent tip has sprouted its own tiny bud, just opening.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt = math.max, math.min, math.floor, math.abs, math.sqrt
local c = A.new("hat-bloomcaller")
local FELT = { "#3a1a48", "#5c2668", "#82358a", "#a94c9f", "#cf6fb4", "#f0a2cf" }
local BAND = { "#1d4a3e", "#2e6e48", "#4a9450", "#7cc35a", "#c4e07a" }
local PET  = { "#b0661c", "#e0962a", "#f5c03a", "#ffe07a", "#fff3c0" }
local LEAF = { "#173f36", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local tC, tBr, tBa = A.tok("cone"), A.tok("brim"), A.tok("band")

-- brim: wide flattened ellipse with a thick underside lip
local brim = c:ellipse(32, 45, 25, 6)
local bn = {}
brim:each(function(x, y)
  local u, v = (x - 32) / 26, (y - 45) / 7
  bn[K(x, y)] = { A.norm(u * 0.5, v * 0.9 - 0.25, 1) }
end)
local bb = {}
-- underside lip: the bottom 2 rows of each column are the darker turned-down edge
brim:each(function(x, y) if not brim:has(x, y + 2) then bb[K(x, y)] = -2 end end)
-- AO where the cone sits
brim:each(function(x, y) if y <= 45 and x >= 21 and x <= 44 then bb[K(x, y)] = (bb[K(x, y)] or 0) - 1 end end)
A.shade(c, brim, bn, FELT, { tok = tBr, bias = bb, amb = 0.12, wrap = 0.3 })
-- the one stitch: gold hem along the front of the brim top
c:stitch{ {12,48},{20,50},{32,51},{44,50},{52,48} }

-- cone: tube along a bezier, tip bends right and droops
local p = { {32,44},{31,26},{35,11},{47,9} }
local cm, cn, CT, CS = A.tube(p, function(t)
  if t > 0.97 then return 0.6 end
  return 10.5 * (1 - t) ^ 1.05 + 0.9
end)
-- keep the base flat on the brim
cm:cut(c:rect(0, 45, 63, 63))
local cb = {}
cm:each(function(x, y) local k = K(x, y)
  -- felt creases: two diagonal folds across the cone
  local t, s = CT[k], CS[k]
  for _, f in ipairs{ { 0.32, 0.5 }, { 0.55, -0.4 } } do
    local d = (t - f[1]) * 38 + s * f[2] * 6
    if d > -0.6 and d < 0.6 and abs(s) < 0.85 then cb[k] = -2 elseif d >= 0.6 and d < 1.6 and abs(s) < 0.85 then cb[k] = 1 end
  end
end)
local cidx = A.shade(c, cm, cn, FELT, { tok = tC, bias = cb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- felt nap: sparse darker flecks
cm:each(function(x, y) local k = K(x, y) if X.hash(x, y, 5) < 0.05 and (cidx[k] or 1) >= 3 then c:put(x, y, FELT[(cidx[k]) - 1], tC) end end)
-- cool reflected light on the right edge of the lower cone
cm:edge():each(function(x, y) local k = K(x, y) if CS[k] > 0.7 and CT[k] < 0.55 and CT[k] > 0.1 then c:put(x, y, "#6a4aa6", tC) end end)

-- band: satin ribbon around the cone base
cm:each(function(x, y) local k = K(x, y)
  if y >= 38 and y <= 42 then
    local i = cidx[k] or 3
    local col = BAND[max(1, min(5, i - 1))]
    if y == 39 and CS[k] < -0.1 and CS[k] > -0.7 then col = BAND[5] end
    if y == 42 then col = BAND[1] end
    c:put(x, y, col, tBa)
  end
end)
-- AO under band + where cone meets brim
for x = 20, 44 do if cm:has(x, 43) then c:put(x, 43, FELT[2], tC) end if cm:has(x, 44) then c:put(x, 44, FELT[1], tC) end end

-- vine spiralling up the cone: a 1 px stem with three small leaves
local vine = { {27,37},{29,33},{33,30},{36,27},{35,23},{33,20},{35,17},{38,15} }
for i = 1, #vine - 1 do
  local m = c:line({ vine[i], vine[i + 1] }, 1)
  m:each(function(x, y) if cm:has(x, y) then c:put(x, y, (i % 2 == 0) and LEAF[2] or LEAF[3], A.tok("vine")) end end)
end
local function leaf(x, y, flip)
  local rows = flip and { "..Ll", ".LhL", "dLL." , "d..." } or { "lL..", "LhL.", ".LLd", "...d" }
  A.map(c, rows, x, y, { l = LEAF[4], L = LEAF[3], h = LEAF[5], d = LEAF[1] }, A.tok("vine"))
end
leaf(30, 30, true) leaf(36, 23, false) leaf(31, 17, true)

-- the bloom pinned on the band (front-left): five rounded petals + seeded centre
local fx, fy = 26, 38
local petals = HP.mask()
for i = 0, 4 do
  local a = -math.pi / 2 + i * 2 * math.pi / 5
  petals:add(c:ellipse(fx + math.cos(a) * 3.2, fy + math.sin(a) * 3.2, 2, 2))
end
local pn = X.sphere(fx - 1, fy - 1, 6, petals)
local pidx = A.shade(c, petals, pn, PET, { tok = A.tok("petal"), amb = 0.2, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- petal gaps + veins
for i = 0, 4 do
  local a = -math.pi / 2 + (i + 0.5) * 2 * math.pi / 5
  local gx, gy = floor(fx + math.cos(a) * 4 + .5), floor(fy + math.sin(a) * 4 + .5)
  if petals:has(gx, gy) then c:put(gx, gy, PET[1], A.tok("petal")) end
  local a2 = -math.pi / 2 + i * 2 * math.pi / 5
  c:put(floor(fx + math.cos(a2) * 3.6 + .5), floor(fy + math.sin(a2) * 3.6 + .5), PET[2], A.tok("petal"))
end
A.map(c, { ".Oo", "OoO", "oO." }, fx - 1, fy - 1, { O = "#c4561e", o = "#8f3a1c" }, A.tok("eye"))
c:put(fx - 1, fy - 1, "#ffb060")
c:put(fx - 2, fy - 4, A.CREAM)   -- petal sheen glint

-- quirk: a tiny bud sprouting from the bent tip
local tx, ty = 47, 9
A.map(c, {
  "..pP.",
  ".pPPp",
  "..gp.",
  ".lg..",
  "lLg..",
}, tx, ty - 4, { p = "#f5809f", P = "#ffc4d8", g = LEAF[2], l = LEAF[4], L = LEAF[3] }, A.tok("bud"))
c:put(49, 6, A.CREAM)
-- felt glint on the lit shoulder of the cone
c:put(26, 30, FELT[6], tC) c:put(26, 31, FELT[6], tC)

A.save(c, "hat-bloomcaller")
