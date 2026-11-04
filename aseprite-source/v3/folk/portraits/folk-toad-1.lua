-- folk-toad-1 portrait (folk F2_9) variant: 1
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local GOLDI = "#dca23c"
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local function hash(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + s * 37.719) * 43758.5453 return n - math.floor(n) end
local function warts(c, m, r, seed, dens)
  local l = {}
  m:each(function(x, y) if hash(x, y, seed) < dens and m:has(x - 1, y - 1) and m:has(x + 2, y + 2) then l[#l + 1] = { x, y } end end)
  for _, p in ipairs(l) do
    local v = c:get(p[1], p[2])
    if v == r.base or v == r.shade then c:put(p[1], p[2], r.hi) c:put(p[1] + 1, p[2] + 1, r.deep) end
  end
end
local H = {}
local NAME = "folk-toad-1"
local S = R("#b8c45c", "#7f9a40", "#566e44", "#383c4e")
local B = R("#f4e8aa", "#dcc47c", "#a8906c", "#6e5a60")
local STRAW = R("#f8de8c", "#deb658", "#a87e44", "#6e4a3e")
local RUST = R("#f28c5c", "#c45230", "#8a3232", "#56243c")
local DEN = R("#a0bcdc", "#6c8aba", "#4c5a8c", "#34365e")
local STEEL = R("#e2e8ea", "#9eaab6", "#666e88", "#3e3e5a")
local WOOD = R("#d69c5c", "#9e663a", "#6a4036", "#42283c")
local DISC = R("#cfe6f2", "#8cc0d8", "#6a90b8", "#4e6492")
local function weave(c, m, r) local l = {} m:each(function(x, y) if (x + 2 * y) % 4 == 0 and c:get(x, y) == r.base then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], r.shade) end end
H.clothes = function(c)
  c:part(c:rrect(26, 84, 53, 99, 3), DEN, { band = 2, pop = { x = 28, y = 88 } })
  c:part(c:line({ { 29, 85 }, { 25, 76 } }, 3), DEN, { band = 1, nopop = true })
  c:part(c:line({ { 50, 85 }, { 54, 76 } }, 3), DEN, { band = 1, nopop = true })
  c:stitch({ { 31, 93 }, { 48, 93 } })
  c:part(c:rect(28, 85, 30, 87), STRAW, { band = 1, nopop = true }) c:part(c:rect(49, 85, 51, 87), STRAW, { band = 1, nopop = true })
  c:part(c:poly({ { 24, 73 }, { 55, 73 }, { 39.5, 89 } }), RUST, { band = 2, pop = { x = 28, y = 74 } })
  c:part(c:ellipse(39.5, 75, 3.5, 2.5), RUST, { band = 1, pop = { x = 38, y = 74 } })
end
H.top = function(c)
  local brim = c:ellipse(39.5, 38, 21, 5)
  c:part(brim, STRAW, { band = 2, pop = { x = 24, y = 36 } }) weave(c, brim, STRAW)
  local cr = c:rrect(29, 22, 50, 36, 6)
  c:part(cr, STRAW, { band = 2, pop = { x = 32, y = 24 } }) weave(c, cr, STRAW)
  for x = 29, 50 do for y = 32, 34 do if cr:has(x, y) then c:put(x, y, y == 34 and RUST.shade or RUST.base) end end end
  c:fillMask(c:line({ { 46, 33 }, { 48, 26 } }, 1), "#4e7a44")
  for _, q in ipairs({ { 47, 27, "#8cc45a" }, { 49, 26, "#6aa84a" }, { 46, 29, "#8cc45a" }, { 49, 29, "#6aa84a" }, { 48, 25, "#8cc45a" } }) do c:put(q[1], q[2], q[3]) end
end
H.front = function(c)
  c:part(c:poly({ { 57, 80 }, { 67, 80 }, { 62, 62 } }), STEEL, { band = 2, pop = { x = 60, y = 72 } })
  c:fillMask(c:line({ { 62, 67 }, { 62, 78 } }, 1), STEEL.shade)
  c:part(c:rect(60, 81, 64, 82), STEEL, { band = 1, nopop = true })
  c:part(c:rrect(60, 83, 64, 97, 2), WOOD, { band = 1, nopop = true })
  c:part(c:ellipse(62, 88, 4.5, 3.5), S, { band = 1, pop = { x = 60, y = 86 } })
  c:put(61, 90, S.deep) c:put(63, 90, S.deep)
  c:put(61, 64, WOOD.shade) c:put(62, 65, WOOD.base) c:put(63, 64, WOOD.deep)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
if H.back then H.back(c) end
local body = c:ellipse(39.5, 100, 30, 26):clip(c:rect(0, 0, 79, 99))
c:part(body, S, { band = 3, pop = { x = 17, y = 86 } })
warts(c, body, S, 5, 0.03)
c:part(c:ellipse(39.5, 96, 14, 12):clip(c:rect(0, 0, 79, 99)), B, { band = 1, nopop = true })
if H.clothes then H.clothes(c) end
local head = c:ellipse(39.5, 57, 19.5, 15)
head:add(c:ellipse(21.5, 53, 3, 2.5)) head:add(c:ellipse(57.5, 53, 3, 2.5))
c:part(head, S, { band = 3, pop = { x = 27, y = 47 } })
warts(c, head, S, 11, 0.035)
c:part(c:ellipse(39.5, 70, 13, 4):clip(head), B, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 58, 5, 3), S, { band = 1, pop = { x = 37, y = 56 } })
c:put(37, 59, S.deep) c:put(41, 59, S.deep)
c:fillMask(c:line({ { 22, 61 }, { 25, 64 }, { 31, 65 }, { 39, 66 }, { 40, 66 }, { 48, 65 }, { 54, 64 }, { 57, 61 } }, 1), INK)
for _, q in ipairs({ { 24, 60 }, { 25, 60 }, { 26, 60 }, { 52, 60 }, { 53, 60 }, { 54, 60 } }) do c:put(q[1], q[2], P.petal.base) end
if H.top then H.top(c) end
for _, ex in ipairs({ 30.5, 48.5 }) do
  c:part(c:ellipse(ex, 44, 7, 6), S, { band = 2, pop = { x = math.floor(ex) - 4, y = 40 } })
  c:fillMask(c:ellipse(ex, 43.5, 3.6, 3.6), GOLDI)
end
c:eyeLocked(28, 41) c:eyeLocked(46, 41)
for _, ex in ipairs({ 28, 46 }) do for i = 0, 4 do c:put(ex + i, 39, S.shade) end end
if H.front then H.front(c) end
c:finish{ outline = true }
backdrop(DISC)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
