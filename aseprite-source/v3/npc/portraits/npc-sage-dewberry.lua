-- npc-sage-dewberry portrait (npc2 P1_33) species: butterfly
-- 80x100 head+shoulders, sky backdrop disc. Same design as the sprite: pink spotted wings, lilac fuzz crown,
-- club antennae, gold robe + ember scarf, dewberry sprig in hand.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sage-dewberry"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUZZ = { hi = "#e2d2f2", base = "#b9a0da", shade = "#8b72b8", deep = "#5e4a8a" }
local BERRY = { hi = "#9a7cc8", base = "#5d4290", shade = "#40306e", deep = "#2f2452" }
local LEAF = { hi = "#b4d878", base = "#72a84c", shade = "#4b7c4e", deep = "#34564c" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
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
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function inked(m) c:fillMask(m:copy():grow(1), P.ink) end
-- wings
for _, s in ipairs{ -1, 1 } do
  local up = oval(39.5 + s * 24, 63, 13, 8, s * -40)
  local lo = oval(39.5 + s * 20, 82, 8, 5.5, s * 30)
  c:part(lo, P.petal, { band = 2, nopop = true })
  c:part(up, P.petal, { band = 2, pop = { x = s < 0 and 12 or 58, y = 58 } })
  c:part(c:ellipse(39.5 + s * 29, 58, 3, 3):clip(up:copy():shrink(1)), CR, { band = 1, nopop = true, inner = false })
  c:part(c:ellipse(39.5 + s * 21, 84, 1.8, 1.8):clip(lo:copy():shrink(1)), CR, { band = 1, nopop = true, inner = false })
  c:fillMask(c:line({ { 39.5 + s * 12, 71 }, { 39.5 + s * 25, 61 } }, 1):clip(up:copy():shrink(1)), P.petal.shade)
  c:fillMask(c:line({ { 39.5 + s * 14, 79 }, { 39.5 + s * 23, 81 } }, 1):clip(lo:copy():shrink(1)), P.petal.shade)
end
-- robe + scarf
local body = c:ellipse(39.5, 106, 29, 30):clip(c:rect(0, 74, 79, 99))
c:part(body, P.gold, { band = 3, pop = { x = 18, y = 88 } })
for _, f in ipairs{ { { 25, 86 }, { 22, 99 } }, { { 54, 88 }, { 57, 99 } }, { { 46, 92 }, { 47, 99 } } } do c:fillMask(c:line(f, 1):clip(body), P.gold.shade) end
local sc = c:ellipse(39.5, 76, 14, 4)
sc:add(c:poly{ { 29, 77 }, { 34, 77 }, { 33, 93 }, { 28, 92 } })
c:part(sc, P.ember, { band = 2, pop = { x = 29, y = 74 } })
c:fillMask(c:line({ { 31, 82 }, { 31, 90 } }, 1), P.ember.shade)
-- prop: dewberry sprig in the right hand
local tw = c:line({ { 61, 86 }, { 63, 74 }, { 64, 66 } }, 2)
inked(tw) c:part(tw, P.wood, { band = 1, nopop = true })
local lf = c:poly{ { 63, 77 }, { 68, 72 }, { 73, 72 }, { 71, 75 }, { 66, 79 } }
inked(lf) c:part(lf, LEAF, { band = 1, pop = { x = 67, y = 73 } })
c:fillMask(c:line({ { 64, 77 }, { 71, 73 } }, 1), LEAF.shade)
local be = HP.mask()
local DRU = { { 62, 61 }, { 66, 61 }, { 64, 58 }, { 62, 64.5 }, { 66, 64.5 }, { 64, 62.5 } }
for _, q in ipairs(DRU) do be:add(HP.ellipse(q[1], q[2], 1.9, 1.9)) end
inked(be) c:part(be, BERRY, { band = 2, pop = { x = 62, y = 57 } })
for _, q in ipairs(DRU) do c:put(math.floor(q[1]) - 1, math.floor(q[2]) - 1, BERRY.hi) end
local hand = c:ellipse(61, 86, 3.5, 3)
inked(hand) c:part(hand, P.skinA, { band = 1, pop = { x = 59, y = 84 } })
-- head + fuzz crown
local hcx, hcy, hrx, hry = 39.5, 52, 20, 17.5
local head = c:ellipse(hcx, hcy, hrx, hry)
c:part(head, P.skinA, { band = 3, pop = { x = 27, y = 49 } })
local fz = head:copy():clip(c:rect(0, 0, 79, 42))
local T = { 2, 2.5, 2, 2.5, 3, 2.5, 2, 2.5, 2, 2.5, 2 }
for i = 0, 10 do local a = math.rad(198 + i * 14.4) fz:add(HP.ellipse(hcx + math.cos(a) * (hrx - .5), hcy + math.sin(a) * (hry - .5), T[i + 1], T[i + 1])) end
local DR = { 1, 2, 0, 1, 3, 1, 0, 2, 1, 0, 1, 3, 1, 0, 2, 1, 0, 1, 2, 0 }
for x = 20, 59 do local d = DR[(x * 7) % #DR + 1] if head:has(x, 42) then for y = 43, 42 + d do if head:has(x, y + 1) then fz:set(x, y) end end end end
fz:add(c:poly{ { 36, 35 }, { 37, 29 }, { 39, 32 }, { 40, 27 }, { 42, 32 }, { 44, 30 }, { 44, 36 } })
c:part(fz, FUZZ, { band = 2, inner = false, pop = { x = 26, y = 38 } })
for _, s in ipairs{ { 26, 41, 27, 39 }, { 31, 38, 32, 36 }, { 37, 37, 38, 35 }, { 46, 38, 47, 36 }, { 52, 40, 53, 38 }, { 34, 42, 35, 40 }, { 43, 41, 44, 39 } } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(fz):each(function(x, y) if c:get(x, y) == FUZZ.base then c:put(x, y, FUZZ.hi) end end)
end
-- face
c:eyeLocked(29, 50) c:eyeLocked(46, 50)
c:paint({ "hSS.", "SSSd", ".dd." }, 38, 56, { h = "skinA.hi", S = "skinA.shade", d = "skinA.deep" })
c:paint({ "i....i", ".iiii." }, 37, 61, { i = "ink" })
c:paint({ "PPP", "PPP" }, 25, 58, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 52, 58, { P = "petal.base" })
c:put(25, 58, P.petal.hi) c:put(52, 58, P.petal.hi)
-- antenna clubs
c:part(c:ellipse(24, 14, 3, 3), BERRY, { band = 1, pop = { x = 22, y = 12 } })
c:part(c:ellipse(56, 14, 3, 3), BERRY, { band = 1, pop = { x = 54, y = 12 } })
c:finish{ outline = true }
c:fillMask(c:line({ { 34, 32 }, { 31, 25 }, { 27, 20 }, { 25, 18 } }, 1), P.ink)
c:fillMask(c:line({ { 45, 32 }, { 48, 25 }, { 52, 20 }, { 55, 18 } }, 1), P.ink)
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
