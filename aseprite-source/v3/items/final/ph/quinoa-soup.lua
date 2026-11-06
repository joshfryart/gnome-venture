-- quinoa-soup (final, Sonnet high). A round oatmeal-glazed stoneware bowl (iron speckle, a teal dipped glaze band with a
-- wavy drip edge, a turned foot ring, cool bounce light lower right) full of golden broth: heaps of tiny cream quinoa
-- beads each with a curled germ tail, orange carrot dice with a lit top face, torn green herb, two red pepper bits and a
-- few oil glints. A wooden spoon (grain lines, bevel) stands in the broth with a ripple ring round its bowl.
-- quirk: the steam curl ends in a spiral, exactly like a quinoa germ ring.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("quinoa-soup")
local CER = { "#5f4c58", "#8c7468", "#bda68a", "#e2d0aa", "#f6e8c6", "#fffaf0" }
local TEAL = { "#14333f", "#1f5565", "#2f7e92", "#4aa4b0", "#86cfcc", "#c4ece0" }
local BR = { "#9a4a1c", "#c97620", "#ea9c2c", "#f8bc46", "#fdd678", "#fff0b0" }
local WOOD = { "#4a2c26", "#74452f", "#a06a40", "#c68c55", "#e2b27a", "#f6d8a6" }
local QB = { "#7a6552", "#a8926e", "#d2bd92", "#ecdcb2", "#faf0cc", "#fffaf0" }
local CAR = { "#7a2a1a", "#b0431c", "#dc6a22", "#f58f34", "#ffb85c", "#ffd88a" }
local HERB = { "#1d4a34", "#2c6e42", "#45914c", "#6ab455", "#98d070", "#c4e690" }
local PEP = { "#5a1428", "#8e2234", "#c33a3a", "#e45c44", "#fa8a60", "#ffc09a" }
local ST = { "#a9a3bd", "#cfcbe0", "#ece8f4", "#fffaf0" }

local CX, CY = 31, 33
c:groundShadow(CX, 56.5, 18, 1.6)

-- foot ring
local foot = c:rect(25, 51, 37, 54)
local fn = X.pillow(foot, 1.6)
G.toneN(c, foot, fn, CER, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.0, wrap = 0.1, bias = (function() local b = {} for x = 25, 37 do b[K(x, 51)] = -2 b[K(x, 52)] = -1 end return b end)() })
for x = 25, 37 do c:put(x, 54, CER[1]) end

-- bowl body
local body = HP.mask()
for y = CY, 52 do
  local hw = 23 * sqrt(max(0, 1 - ((y - CY) / 23.5) ^ 2))
  for x = floor(CX - hw + 0.5), floor(CX + hw - 0.5) do body:set(x, y) end
end
local bn = X.sphere(CX - 4, CY - 2, 25, body)
local bt = { r = { name = "bowl" } }
local bidx = X.tone(c, body, X.light(bn, { amb = 0.1, wrap = 0.35 }), CER, { cuts = { 0.2, 0.34, 0.5, 0.66, 0.82 }, tok = bt })
-- reflected cool light on the lower-right silhouette
body:edge():each(function(x, y)
  local k = K(x, y)
  if x > CX + 4 and y > CY + 7 and not body:has(x + 1, y + 1) then c:put(x, y, "#9aa6b4", bt) end end)
-- teal dipped band under the rim with a wavy drip edge
local function fy(x) local t = (x - CX) / 23 return CY + 7.2 * sqrt(max(0, 1 - t * t)) end
body:each(function(x, y)
  local k = K(x, y)
  local wave = 3.2 + 1.6 * sin(x * 0.55) + 1.2 * sin(x * 1.3 + 1) + ((X.hash(x, 3, 5) > 0.82) and 2 or 0)
  if y <= fy(x) + wave then c:put(x, y, TEAL[bidx[k]], bt) end
end)
-- glaze lip along the drip edge: a bright 1px line one row above the bottom edge
body:each(function(x, y)
  local wave = 3.2 + 1.6 * sin(x * 0.55) + 1.2 * sin(x * 1.3 + 1) + ((X.hash(x, 3, 5) > 0.82) and 2 or 0)
  if abs(y - (fy(x) + wave)) < 0.7 and bidx[K(x, y)] and bidx[K(x, y)] > 2 and x < CX + 12 then c:put(x, y, TEAL[min(6, bidx[K(x, y)] + 1)], bt) end
end)
-- iron speckle in the stoneware
body:each(function(x, y)
  local wave = 3.2 + 1.6 * sin(x * 0.55) + 1.2 * sin(x * 1.3 + 1)
  if y > fy(x) + wave + 3 and X.hash(x, y, 9) > 0.965 then c:put(x, y, CER[2], bt) end
end)
-- a pale glaze flow streak on the lit side
for y = 44, 49 do local x = 15 + floor((y - 44) * 0.5) if body:has(x, y) then c:put(x, y, CER[6], bt) end end
-- spare shade line where bowl meets foot (ambient)
for x = 25, 37 do c:put(x, 51, CER[1], bt) end

-- rim ring
local outer = c:ellipse(CX, CY, 23, 7.2)
local inner = c:ellipse(CX, CY + 0.2, 20.2, 5.4)
local ring = outer:copy():cut(inner)
local rn = X.pillow(outer, 2.2)
local rt = { r = { name = "rim" } }
G.toneN(c, ring, rn, CER, { cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 }, tok = rt, amb = 0.3, wrap = 0.4 })
-- teal rim stripe on the front outer edge
ring:each(function(x, y) if y > CY + 2 and not outer:has(x, y + 1) then c:put(x, y, TEAL[2], rt) end
  if y > CY + 2 and outer:has(x, y + 1) and not outer:has(x, y + 2) and x > CX - 17 and x < CX + 18 then c:put(x, y, TEAL[3], rt) end end)
-- inner back wall (cream, in shade)
local wall = inner:copy()
wall:each(function(x, y) c:put(x, y, y < CY - 2 and CER[3] or CER[2], rt) end)
for x = 11, 51 do for y = CY - 6, CY - 4 do if inner:has(x, y) and y == CY - 5 and x < CX + 10 then c:put(x, y, CER[4], rt) end end end

-- broth surface
local soup = c:ellipse(CX, CY + 0.8, 18.8, 4.6)
local st = { r = { name = "soup" } }
soup:each(function(x, y)
  local u, v = (x - CX) / 18.8, (y - (CY + 0.8)) / 4.6
  local i = 4
  if v < -0.35 then i = 3 end
  if u + v * 0.5 < -0.55 then i = 5 end
  if v > 0.45 then i = 3 end
  c:put(x, y, BR[i], st)
end)
soup:edge():each(function(x, y) c:put(x, y, y < CY + 1 and BR[2] or BR[3], st) end)
-- oil glints
for _, q in ipairs{ { 15, 33 }, { 16, 33 }, { 43, 36 }, { 44, 36 }, { 30, 31 } } do if soup:has(q[1], q[2]) then c:put(q[1], q[2], BR[6], st) end end

-- quinoa beads (3x2 pale discs with a curl)
local function bead(x, y, tail)
  if not soup:has(x + 1, y) then return end
  c:put(x, y, QB[5], st) c:put(x + 1, y, QB[6], st) c:put(x + 2, y, QB[4], st)
  c:put(x, y + 1, QB[3], st) c:put(x + 1, y + 1, QB[3], st) c:put(x + 2, y + 1, QB[2], st)
  if tail then c:put(x + 3, y, QB[4], st) c:put(x + 3, y - 1, QB[5], st) end
end
local bx = {
  { 20, 36, 1 }, { 24, 37 }, { 26, 35 }, { 30, 36, 1 }, { 33, 34 }, { 36, 37 }, { 39, 35, 1 }, { 22, 33 }, { 17, 35 },
  { 28, 38 }, { 32, 31 }, { 36, 32 }, { 41, 37 }, { 27, 32, 1 }, { 21, 38 }, { 34, 38 }, { 38, 33 }, { 25, 30 }, { 43, 33 },
}
for _, b in ipairs(bx) do bead(b[1], b[2], b[3]) end
-- carrot dice (top face lit, front darker)
local function cube(x, y)
  for i = 0, 2 do c:put(x + i, y, i == 0 and CAR[6] or CAR[5], st) end
  for i = 0, 2 do c:put(x + i, y + 1, i == 2 and CAR[3] or CAR[4], st) c:put(x + i, y + 2, i == 2 and CAR[2] or CAR[3], st) end
  c:put(x + 3, y + 1, CAR[2], st) c:put(x + 3, y + 2, CAR[1], st)
end
cube(23, 34) cube(36, 35) cube(29, 33)
-- herb: torn leaf bits with a vein
local function herb(x, y, flip)
  local rows = flip and { "..hh.", ".hHhh", "hhhH." } or { ".hh..", "hhHh.", ".Hhhh" }
  A.map(c, rows, x, y, { h = HERB[4], H = HERB[2] }, st)
  c:put(x + (flip and 3 or 1), y, HERB[5], st)
end
herb(19, 33, false) herb(40, 32, true) herb(31, 37, false)
-- red pepper bits
for _, q in ipairs{ { 33, 36 }, { 25, 32 } } do
  c:put(q[1], q[2], PEP[5], st) c:put(q[1] + 1, q[2], PEP[4], st) c:put(q[1], q[2] + 1, PEP[3], st) c:put(q[1] + 1, q[2] + 1, PEP[2], st)
end

-- spoon in the broth
local sm, sn2, sT, sS = G.tube({ { 37, 37 }, { 41, 29 }, { 47, 20 }, { 53, 12 } }, function(t) return 1.2 + 0.5 * t end)
G.toneN(c, sm, sn2, WOOD, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.25 })
sm:each(function(x, y) local k = K(x, y)
  if abs(sS[k]) < 0.15 and sT[k] > 0.1 then c:put(x, y, sS[k] <= 0 and WOOD[5] or WOOD[2]) end
  if sS[k] > 0.3 and (floor(sT[k] * 36)) % 6 == 0 then c:put(x, y, WOOD[1]) end
end)
-- end-grain cap
c:put(53, 11, WOOD[6]) c:put(54, 11, WOOD[5])
-- spoon bowl dipping in the broth + ripple ring
local sb = G.oval(36, 37, 3.4, 2.2, -0.5, 0.8)
local sbn = select(2, G.oval(36, 37, 3.4, 2.2, -0.5, 0.8))
G.toneN(c, sb, sbn, WOOD, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.2 })
local rip = c:ellipse(36, 37.4, 6, 3):cut(c:ellipse(36, 37.4, 4.6, 2.2))
rip:each(function(x, y) if soup:has(x, y) and not sb:has(x, y) and y >= 36 then c:put(x, y, BR[5], st) end end)
local brothline = sb:copy()
brothline:each(function(x, y) if y >= 38 then c:put(x, y, BR[3], st) end end)
c:put(34, 36, WOOD[6])

-- steam with a spiral curl (quirk)
local function steam(pts, w0, w1)
  local m, n, T, S = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  m:each(function(x, y) local k = K(x, y) c:put(x, y, S[k] < -0.2 and ST[4] or (S[k] > 0.35 and ST[1] or ST[3])) end)
end
steam({ { 27, 29 }, { 22, 24 }, { 32, 20 }, { 28, 15 } }, 1.0, 0.9)
steam({ { 28, 15 }, { 25, 12 }, { 27, 7.5 }, { 31, 9 } }, 0.9, 0.7)
for _, q in ipairs{ { 31, 11 }, { 30, 12 }, { 29, 11 } } do c:put(q[1], q[2], ST[3]) end
A.save(c, "quinoa-soup")
