-- npc-bramble-mossfoot PASS 2 (polish). Hearth Pop v3, 80x100 portrait, bleed off bottom.
-- Hedgehog villager: two-row spiky crown (wood ramp, pale quill tips), cream face, red knotted scarf,
-- green cardigan-jumper with one gold button. quirk: a nibbled leaf tucked behind the right ear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-mossfoot"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end
local function pts(list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
local FACE = { hi = P.cream, base = P.cream, shade = P.skinA.base, deep = P.skinA.shade }
local BACK = { hi = P.wood.shade, base = P.wood.shade, shade = P.wood.deep, deep = P.wood.deep }
local cx, cy = 40, 46

---------------------------------------------------------------- jumper
local jum = c:ellipse(39.5, 104, 38, 34):clip(c:rect(0, 68, 79, 99))
c:part(jum, "moss", { band = 3, pop = { x = 12, y = 84 } })
-- ribbed hem of the neckline + placket
for x = 28, 52, 2 do c:px(x, 72, P.moss.shade) end
c:fillMask(c:line({ {36,75},{36,99} }, 1), P.moss.shade)
c:button(36, 86)
c:px(35, 85, P.gold.hi) c:px(37, 87, P.gold.shade)

---------------------------------------------------------------- spikes: hand-placed tips, big wedges
-- front spikes: wood.base with a 2px wood.shade edge on the clockwise (lower-right) side and a pale tip;
-- back spikes peek between them in flat wood.shade with a wood.deep seam.
local core = c:ellipse(cx, cy, 20, 19)
local function wedge(tx, ty, half)
  local a = math.atan(ty - cy, tx - cx)
  local r0 = 19
  local m = c:poly{ { cx + math.cos(a - half) * r0, cy + math.sin(a - half) * r0 }, { tx, ty }, { cx + math.cos(a + half) * r0, cy + math.sin(a + half) * r0 } }
  return { s = m, a = a, t = { tx, ty }, len = math.sqrt((tx - cx) ^ 2 + (ty - cy) ^ 2), half = half, r0 = r0 }
end
local front, back = {}, {}
local LEN = { 34, 36, 34, 37, 35, 38, 35, 37, 34, 36, 33 }
for i = 0, 10 do
  local a = math.rad(152 + i * 23.6)
  local L = LEN[i + 1]
  front[#front + 1] = wedge(cx + math.cos(a) * L, cy + math.sin(a) * L * 0.9, 0.34)
end

local mass = core:copy()
for _, sp in ipairs(front) do mass:add(sp.s) end
for _, sp in ipairs(back) do mass:add(sp.s) end
c:part(mass, "wood", { band = 3, pop = { x = 27, y = 33 } })
local inFront = HP.mask()
for _, sp in ipairs(front) do inFront:add(sp.s) end
inFront:cut(core)
for _, sp in ipairs(back) do
  sp.s:copy():cut(core):cut(inFront):each(function(x, y)
    local col = P.wood.shade
    if inFront:has(x - 1, y) or inFront:has(x, y - 1) or inFront:has(x + 1, y) then col = P.wood.deep end
    c:put(x, y, col, P.wood)
  end)
end
for _, sp in ipairs(front) do
  local ax, ay = math.cos(sp.a), math.sin(sp.a)
  sp.s:copy():cut(core):each(function(x, y)
    local dx, dy = x + .5 - cx, y + .5 - cy
    local along = dx * ax + dy * ay
    local side = ax * dy - ay * dx
    local hw = math.sin(sp.half) * sp.r0 * (1 - (along - sp.r0) / (sp.len - sp.r0))
    local col = P.wood.base
    if side > hw - 2.2 then col = P.wood.shade end
    if sp.len - along < 4 then col = P.wood.hi end
    c:put(x, y, col, P.wood)
  end)
end

---------------------------------------------------------------- quirk leaf (behind the ear): nibbled
local leaf = c:poly{ {57,38},{59,30},{64,24},{71,21},{70,28},{66,34},{60,39} }
leaf:cut(c:ellipse(69.5, 29.5, 1.5, 1.5)):cut(c:ellipse(67, 32.5, 1.5, 1.2))
c:part(leaf, "moss", { band = 1, pop = { x = 61, y = 30 } })
c:fillMask(c:line({ {59,37},{63,30},{70,22} }, 1):clip(leaf), P.moss.shade)

---------------------------------------------------------------- ears
for _, e in ipairs{ { 24, 38 }, { 56, 38 } } do
  c:part(c:ellipse(e[1], e[2], 3.5, 3.5), "skinA", { band = 1, nopop = true })
  c:fillMask(c:ellipse(e[1], e[2] + 0.5, 1.5, 1.5), P.petal.base)
end

---------------------------------------------------------------- face: heart-shaped, widow's peak of spikes
local face = c:ellipse(40.5, 52, 18, 13):add(c:ellipse(33, 44, 9, 7)):add(c:ellipse(48, 44, 9, 7))
face:cut(c:poly{ {35,32},{40.5,41},{46,32} })
c:part(face, FACE, { nopop = true, band = 2 })
-- eye masks (teardrop toward the snout)
c:fillMask(c:ellipse(32.5, 47, 5, 4):add(c:ellipse(47, 47, 5, 4)):add(c:rect(33, 44, 46, 47)):add(c:ellipse(40, 41, 4, 3)):clip(face), P.wood.hi)
c:eyeLocked(30, 45) c:eyeLocked(44, 45)
c:cheek(27, 54) c:cheek(53, 54)
-- snout poking toward viewer's right
local SNOUT = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.base }
local snout = c:poly{ {38,53},{44,50.5},{50,51},{53,53},{52,56},{46,58},{40,58},{38,56} }
c:part(snout, SNOUT, { nopop = true, band = 1, inner = false })
pts({ {40,58},{41,58},{42,58},{43,58},{44,58},{45,58},{46,57},{47,57},{48,57},{49,56} }, P.skinA.base)
c:paint({ ".iii.", "iciii", "iiiii", ".iii." }, 49, 50, { i = "ink", c = "cream" })
pts({ {39,60},{40,61},{41,61},{42,61},{43,60} }, P.skinA.shade)  -- smile
pts({ {43,55},{46,56} }, P.skinA.base)                           -- whisker dots

---------------------------------------------------------------- scarf: wrap, knot, two tails with fringe
c:part(c:poly{ {23,67},{32,64},{40,67},{48,64},{57,67},{58,72},{48,74},{40,75},{32,74},{22,72} }, "ember", { band = 2 })
c:part(c:ellipse(51.5, 74, 3.5, 3), "ember", { band = 1, nopop = true })
c:part(c:poly{ {48,76},{54,76},{57,92},{50,92} }, "ember", { band = 2, nopop = true })
c:part(c:poly{ {54,75},{58,76},{64,86},{59,89} }, "ember", { band = 1, nopop = true })
pts({ {52,92},{55,92},{61,88} }, P.ember.deep)
c:stitch{ {50, 89}, {56, 89} }

c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
