-- npc-burdock-puddlejump portrait (npc2 P1_5) species: butterfly
-- Same design as the sprite: butter face, orange smock with cord + dew-drop pendant, pink cream-spotted wings,
-- brown dome cap, curled antennae, coiled proboscis nose, burdock-leaf parasol held in the right hand. Sky disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-burdock-puddlejump"
local BUT = { hi = "#fff0b0", base = "#ffd36a", shade = "#e09a3c", deep = "#8f4a1f" }
local ORA = { hi = "#ffb25c", base = "#f08a2e", shade = "#c25a2a", deep = "#6e2f24" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- leaf parasol behind
c:part(c:line({ { 64, 92 }, { 63, 60 }, { 60, 34 } }, 2), P.moss, { band = 1, nopop = true })
local leaf = oval(61, 22, 15, 10, -22)
for _, q in ipairs{ { 47, 20 }, { 53, 12 }, { 62, 9 }, { 71, 12 }, { 76, 20 }, { 73, 29 }, { 64, 33 } } do leaf:add(c:ellipse(q[1], q[2], 2.5, 2.5)) end
leaf:clip(c:rect(0, 0, 79, 99))
c:part(leaf, P.moss, { band = 2, pop = { x = 52, y = 16 } })
c:fillMask(c:line({ { 60, 33 }, { 64, 22 }, { 70, 13 } }, 1):clip(leaf:shrink(1)), P.moss.hi)
for _, v in ipairs{ { { 62, 27 }, { 51, 22 } }, { { 64, 22 }, { 56, 13 } }, { { 63, 25 }, { 73, 25 } }, { { 66, 18 }, { 74, 16 } } } do
  c:fillMask(c:line(v, 1):clip(leaf:shrink(1)), P.moss.shade)
end
c:part(c:ellipse(52.5, 18, 1.5, 2), P.sky, { band = 1, nopop = true }) c:put(52, 17, P.cream)
-- wings
for _, s in ipairs{ -1, 1 } do
  local up = oval(39.5 + s * 24, 64, 12, 8, s * -40)
  local lo = oval(39.5 + s * 23, 82, 8, 6, s * 25)
  c:part(lo, P.petal, { band = 1, nopop = true })
  c:part(up, P.petal, { band = 2, nopop = true })
  c:fillMask(c:ellipse(39.5 + s * 30, 59, 2.5, 2.5), P.cream)
  c:fillMask(c:ellipse(39.5 + s * 25, 69, 1.5, 1.5), P.cream)
  c:fillMask(c:ellipse(39.5 + s * 25, 84, 1.5, 1.5), P.cream)
  c:fillMask(c:line({ { 39.5 + s * 16, 70 }, { 39.5 + s * 30, 63 } }, 1):clip(up:shrink(1)), P.petal.shade)
end
-- smock body
local body = c:ellipse(39.5, 104, 27, 30):clip(c:rect(0, 72, 79, 99))
c:part(body, ORA, { band = 3, pop = { x = 20, y = 82 } })
c:fillMask(c:line({ { 29, 74 }, { 39, 85 }, { 50, 74 } }, 2), P.wood.deep)
c:part(c:poly{ { 37, 86 }, { 42, 86 }, { 41, 91 }, { 39.5, 92 }, { 38, 91 } }, P.sky, { band = 1, nopop = true })
c:put(38, 87, P.cream)
for _, f in ipairs{ { { 24, 86 }, { 22, 99 } }, { { 54, 88 }, { 56, 99 } } } do c:fillMask(c:line(f, 1):clip(body:shrink(1)), ORA.shade) end
c:part(c:ellipse(63.5, 88, 4, 3.5), BUT, { band = 1, pop = { x = 61, y = 86 } })
-- head
local head = c:ellipse(39.5, 50, 20.5, 17)
c:part(head, BUT, { band = 3, pop = { x = 26, y = 44 } })
-- dome cap
local hat = c:ellipse(39.5, 37, 24, 4.5)
hat:add(c:ellipse(39.5, 31, 15, 11):clip(c:rect(0, 0, 79, 37)))
hat:add(c:ellipse(39.5, 19, 3, 2.5))
c:part(hat, P.wood, { band = 3, pop = { x = 30, y = 25 } })
c:stitch{ { 26, 34 }, { 53, 34 } }
for x = 15, 64 do if hat:has(x, 41) or (hat:has(x, 40) and not hat:has(x, 41)) then
  local y = hat:has(x, 41) and 41 or 40 c:put(x, y, P.wood.deep, nil) end end
for _, q in ipairs{ { 36, 22 }, { 38, 20 }, { 40, 19 } } do c:put(q[1], q[2], P.wood.hi) end
-- antenna tips
c:part(c:ellipse(20, 11, 2.5, 2.5), P.dusk, { band = 1, pop = { x = 19, y = 10 } })
c:part(c:ellipse(58, 6, 2.5, 2.5), P.dusk, { band = 1, pop = { x = 57, y = 5 } })
-- face: locked eyes, coiled proboscis nose, smile, cheeks
c:eyeLocked(29, 46) c:eyeLocked(46, 46)
c:paint({ ".DDD.", "D...D", "D.DD.", "D....", ".DD.." }, 37, 52, { D = ORA.deep })
c:paint({ "i......i", ".iiiiii.", "..iPPi.." }, 36, 59, { i = "ink", P = "petal.base" })
c:paint({ "PPP", "PPP" }, 24, 56, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 56, { P = "petal.base" })
c:put(24, 56, P.petal.hi) c:put(53, 56, P.petal.hi)
c:finish{ outline = true }
c:fillMask(c:line({ { 33, 22 }, { 27, 17 }, { 22, 13 } }, 1), P.ink)
c:fillMask(c:line({ { 46, 22 }, { 52, 13 }, { 56, 8 } }, 1), P.ink)
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
