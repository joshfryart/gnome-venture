-- npc-sorrel-petalwing portrait (npc2 P1_34) species: tawny owl
-- 80x100 head-and-shoulders: rose petal hood with scalloped rim + leaf sprig, ear tufts through it, heart face
-- disc with locked eyes, gold hooked beak, rose scarf, a daisy raised in the left wing; petal backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sorrel-petalwing"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FEA = P.wood
local WING = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a221f" }
local HOOD = { hi = P.petal.base, base = P.petal.shade, shade = P.petal.deep, deep = "#4e1c40" }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.base }
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
-- body, belly chevrons
local body = c:ellipse(39.5, 108, 31, 34):clip(c:rect(0, 70, 79, 99))
c:part(body, FEA, { band = 3, pop = { x = 16, y = 84 } })
c:part(c:ellipse(39.5, 98, 13, 16):clip(body), CR, { band = 2, nopop = true })
for _, y in ipairs{ 86, 91, 96 } do for x = 31, 45, 5 do
  c:put(x, y, FEA.base) c:put(x + 1, y + 1, FEA.shade) c:put(x + 2, y + 1, FEA.shade) c:put(x + 3, y, FEA.base) end end
-- scarf
c:part(c:rrect(21, 67, 58, 73, 3), HOOD, { band = 2, pop = { x = 24, y = 68 } })
c:part(c:line({ { 50, 72 }, { 53, 86 } }, 4), HOOD, { band = 1, nopop = true })
-- raised left wing with a daisy
c:part(oval(17, 80, 12, 5, -70), WING, { band = 2, nopop = true })
c:fillMask(c:line({ { 15, 72 }, { 13, 61 } }, 1), P.moss.shade)
for i = 0, 6 do local a = math.rad(-90 + i * 360 / 7)
  c:part(c:ellipse(13 + math.cos(a) * 3.5, 57 + math.sin(a) * 3.5, 2, 2), CR, { band = 1, nopop = true }) end
c:part(c:ellipse(13, 57, 2, 2), P.gold, { band = 1, nopop = true }) c:put(12, 56, P.gold.hi)
-- head + face disc
local head = c:ellipse(39.5, 49, 21, 18)
c:part(head, FEA, { band = 3, pop = { x = 22, y = 46 } })
local face = c:ellipse(32, 52, 9, 9):add(c:ellipse(47, 52, 9, 9)):clip(head)
c:part(face, CR, { band = 2, nopop = true })
-- rose petal hood
local hood = head:copy():clip(c:rect(0, 0, 79, 41))
for x = 21, 58, 6 do hood:add(c:ellipse(x, 41, 3, 2.5):clip(head:grow(1))) end
hood:add(c:poly{ { 33, 34 }, { 39, 20 }, { 46, 34 } })
c:part(hood, HOOD, { band = 3, pop = { x = 26, y = 34 } })
c:stitch{ { 22, 40 }, { 57, 40 } }
-- ear tufts through the hood
c:part(c:poly{ { 22, 37 }, { 15, 23 }, { 29, 32 } }, FEA, { band = 1, nopop = true })
c:part(c:poly{ { 57, 37 }, { 64, 23 }, { 50, 32 } }, FEA, { band = 1, nopop = true })
-- leaf sprig
c:part(oval(49, 27, 6, 2.5, -35), P.moss, { band = 1, nopop = true })
c:fillMask(c:line({ { 45, 30 }, { 52, 25 } }, 1), P.moss.shade)
-- eyes, brows, beak, cheeks
c:eyeLocked(30, 49) c:eyeLocked(45, 49)
c:fillMask(c:line({ { 28, 46 }, { 33, 47 } }, 1), FEA.deep) c:fillMask(c:line({ { 46, 47 }, { 51, 46 } }, 1), FEA.deep)
c:part(c:poly{ { 36, 56 }, { 43, 56 }, { 39.5, 63 } }, P.gold, { band = 1, nopop = true })
c:put(37, 56, P.gold.hi) c:put(38, 57, P.gold.hi)
c:paint({ "PPP", "PPP" }, 24, 58, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 58, { P = "petal.base" })
c:finish{ outline = true }
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
