-- npc-hazel-brambleby portrait (npc2 P1_13) species: honeybee
-- 80x100 head and shoulders: plump gold honeybee, brown forehead stripe, leaf cap, round brown button nose,
-- small glassy wings angled up behind the head, elbowed antennae with knobs, knitted moss cardigan with a
-- striped bee chest in the V. Prop in frame: bramble sprig of blackberries. Backdrop: dusk disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-hazel-brambleby"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local BERRY = { hi = P.dusk.base, base = P.dusk.deep, shade = "#2a1f45", deep = "#2a1f45" }
local function dot(x, y, h) c:put(x, y, h, c.own[y * c.w + x]) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- wings angled up behind the head
for _, s in ipairs{ -1, 1 } do
  local w = oval(39.5 + s * 21, 34, 9, 5, s * 35)
  c:part(w, WING, { band = 1, nopop = true })
  c:fillMask(c:line({ { 39.5 + s * 16, 38 }, { 39.5 + s * 26, 31 } }, 1):clip(w:shrink(1)), P.sky.base)
  w:edge():each(function(x, y) if not w:has(x, y - 1) and c:get(x, y) == P.sky.hi then dot(x, y, P.cream) end end)
end
-- cardigan shoulders
local body = c:ellipse(39.5, 104, 31, 31):clip(c:rect(0, 70, 79, 99))
c:part(body, "moss", { band = 3, pop = { 18, 84 } })
for y = 74, 99, 3 do for x = 12 + (y % 2) * 2, 70, 5 do if body:has(x, y) and body:has(x, y + 1) then dot(x, y, P.moss.shade) end end end
local vee = c:poly{ { 32, 69 }, { 47, 69 }, { 39.5, 88 } }
c:part(vee, "gold", { band = 1, nopop = true })
vee:each(function(x, y) if y == 75 or y == 76 or y == 82 then dot(x, y, P.wood.deep) end end)
c:button(39, 92) c:button(39, 98)
-- head
local hcx, hcy = 39.5, 51
local head = c:ellipse(hcx, hcy, 20, 17.5)
for _, a in ipairs{ 200, 230, 260, 290, 320 } do
  local r = math.rad(a) head:add(HP.ellipse(hcx + math.cos(r) * 19.5, hcy + math.sin(r) * 17, 1.5, 1.5))
end
c:part(head, "gold", { band = 3, pop = { 25, 44 } })
-- brown forehead stripe
head:each(function(x, y) if y >= 37 and y <= 41 then
  local v = c:get(x, y)
  dot(x, y, (v == P.gold.shade or y == 41) and P.wood.deep or P.wood.shade)
end end)
for _, x in ipairs{ 26, 27, 31 } do dot(x, 38, P.wood.base) end
-- leaf cap
local leaf = c:poly{ { 26, 37 }, { 36, 28 }, { 52, 29 }, { 46, 37 } }
c:part(leaf, "moss", { band = 1, pop = { 33, 31 } })
c:line({ { 28, 36 }, { 50, 30 } }, 1):clip(leaf):each(function(x, y) dot(x, y, P.moss.deep) end)
c:part(c:line({ { 51, 30 }, { 54, 27 } }, 1), "wood", { band = 1, nopop = true })
-- face
c:eyeLocked(28, 46) c:eyeLocked(47, 46)
c:part(c:ellipse(39.5, 54.5, 2.5, 2), "wood", { band = 1, pop = { 38, 53 } })
c:paint({ "i......i", ".iiiiii.", "..iPPi.." }, 36, 57, { i = "ink", P = "petal.base" })
c:paint({ "PPP", "PPP" }, 23, 54, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 54, { P = "petal.base" })
dot(23, 54, P.petal.hi) dot(54, 54, P.petal.hi)
-- bramble sprig (prop) held up at the right shoulder
c:part(c:line({ { 60, 99 }, { 63, 84 }, { 65, 72 } }, 2), "wood", { band = 1, nopop = true })
dot(62, 88, P.wood.hi)
local lf = c:poly{ { 64, 79 }, { 71, 74 }, { 75, 77 }, { 69, 82 } }
c:part(lf, "moss", { band = 1, pop = { 69, 76 } })
for _, q in ipairs{ { 63, 69 }, { 67, 69 }, { 61, 65 }, { 65, 65 }, { 69, 65 }, { 63, 61 }, { 67, 61 } } do
  c:part(c:ellipse(q[1], q[2], 2, 2), BERRY, { band = 1, pop = { q[1] - 1, q[2] - 1, false } })
end
c:part(c:ellipse(61, 88, 3.5, 3), "gold", { band = 1, pop = { 59, 87 } })
c:finish{ outline = true }
-- elbowed antennae with knobs
c:fillMask(c:line({ { 31, 34 }, { 28, 24 }, { 20, 17 } }, 1), P.ink)
c:fillMask(c:line({ { 48, 34 }, { 51, 24 }, { 59, 17 } }, 1), P.ink)
c:fillMask(c:ellipse(19, 16, 1.5, 1.5), P.ink) c:fillMask(c:ellipse(60, 16, 1.5, 1.5), P.ink)
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
