-- orange (final pass, Opus aC31_1). A round navel-less orange, a touch taller than wide, sunk stem cavity with a
-- green five-point calyx, short woody stem and one slim glossy leaf (midrib + paired veins, lit edge) sweeping right.
-- Material: per-pixel sphere light (6-tone orange, violet-red shade), sparse pitted peel (oil glands), waxy specular
-- cluster + cream glint upper-left, cool reflected light lower-right, AO in the cavity and under the leaf.
-- quirk: a tiny round "1st" prize sticker on the lower right of the peel (opening-day market pick).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "orange"
local c = A.new(NAME)
local OR = { "#6e2234", "#ac3a2c", "#da5f20", "#f58a22", "#ffb346", "#ffda8c" }
local LEAF = A.LEAF
local WOOD = { "#51302b", "#864c33", "#b97a4a" }
local COOL, SPEC = "#b0506a", "#fff4d6"

local CX, CY, RX, RY = 31, 38, 13, 13.5
local m = c:ellipse(CX, CY, RX, RY)
local n = X.sphere(CX, CY, 13.6, m)
-- stem cavity dimple: tilt normals toward the cavity
m:each(function(x, y) local k = K(x, y) local dx, dy = x - (CX + 1), y - (CY - RY + 2.5)
  local d = sqrt(dx * dx + dy * dy)
  if d < 3.2 then local f = (3.2 - d) / 3.2 * 0.7 local p = n[k]
    n[k] = { A.norm(p[1] - dx / (d + 0.1) * f, p[2] - dy / (d + 0.1) * f, p[3]) } end end)

-- leaf (behind nothing; its foot overlaps the top of the fruit)
local lm, ln, LT, LS = A.blade(34, 22, 41, 12, 51, 13, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.8 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.75)
end, { fold = 0.4 })
local bias = {}
A.cast(bias, m, lm, 0, 2, -1)
local otok = { r = { name = "fruit" } }
local idx = A.shade(c, m, n, OR, { tok = otok, bias = bias, amb = 0.06, wrap = 0.2 })
-- oil-gland pits
m:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i >= 3 and i <= 5 and X.hash(x, y, 11) > 0.83 and not (x < CX - 3 and y < CY - 3 and i >= 5) then
    A.step(c, idx, OR, x, y, -1, otok)
  end
end)
-- reflected light
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.66 and y > CY - 2 then c:put(x, y, COOL, otok) end end)
-- specular cluster
local sx, sy = A.specAt(m, n, 40)
for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 2, -1 } } do c:put(sx + p[1], sy + p[2], OR[6], otok) end
c:put(sx, sy, SPEC, otok)
-- cavity
for _, p in ipairs{ { 31, 25 }, { 32, 25 }, { 33, 25 }, { 32, 26 }, { 31, 26 } } do if m:has(p[1], p[2]) then c:put(p[1], p[2], OR[1], otok) end end

-- leaf
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t > 0.06 and t < 0.9 then c:put(x, y, s <= 0 and "#c2e48c" or LEAF[2], ltok) return end
  local ph = (t * 18 - abs(s) * 2.2)
  if abs(ph % 4 - 2) < 0.35 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.85 then
    A.step(c, lidx, LEAF, x, y, s < 0 and 1 or -1, ltok) end
end)
-- stem
local stok = { r = { name = "stem" } }
for _, p in ipairs{ { 32, 24, 2 }, { 33, 24, 1 }, { 32, 23, 3 }, { 33, 23, 2 }, { 33, 22, 3 }, { 34, 22, 2 } } do c:put(p[1], p[2], WOOD[p[3]], stok) end
-- calyx star
A.map(c, {
  "a...a",
  ".bcb.",
  "ab.ba",
  ".c.c.",
}, 30, 24, { a = LEAF[5], b = LEAF[3], c = LEAF[2] }, { r = { name = "calyx" } })
c:put(32, 26, WOOD[2], stok)

-- quirk: round prize sticker
A.map(c, {
  ".abb.",
  "abrrd",
  "brgrd",
  ".ddd.",
}, 37, 43, { a = "#fff4d6", b = "#f2e2bc", d = "#c9b48e", r = "#3a86b0", g = "#ffe38a" }, { r = { name = "sticker" } })

A.save(c, NAME)
