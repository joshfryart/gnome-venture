-- npc-babka-wren portrait (npc2 P1_1) species: wren
-- Same wren as the sprite: brown, red polka-dot babushka knotted under the beak, gold spectacles,
-- cream brow stripe, cocked barred tail behind the shoulder, chocolate babka loaf under one wing.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-babka-wren"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local BR, SC = P.wood, P.ember
local BELLY = { hi = P.cream, base = "#f3e6c8", shade = "#d9c3b0", deep = P.wood.hi }
local CRUST = { hi = P.gold.hi, base = "#e89d28", shade = P.wood.base, deep = P.wood.shade }
local FACE = { hi = P.wood.hi, base = "#c98a55", shade = BR.base, deep = BR.shade }
local CHOC = "#5e3a2e"
local DISC = { base = "#c4e07a", shade = "#9ccf68", deep = "#6aae55" }
local function under(m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex, c.own[q[2] * c.w + q[1]]) end end
local function recol(m, hex) m:each(function(x, y) if c:get(x, y) then c:put(x, y, hex, c.own[y * c.w + x]) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- cocked barred tail behind right shoulder
local tail = c:poly{ { 52, 80 }, { 61, 82 }, { 73, 38 }, { 66, 35 } }
c:part(tail, BR, { band = 2, pop = { x = 66, y = 39 } })
for _, y in ipairs({ 42, 48, 54, 60, 66, 72 }) do recol(c:line({ { 50, y + 1 }, { 76, y - 1 } }, 1):clip(tail:shrink(1)), BR.deep) end
-- body + cream bib
local body = c:ellipse(39.5, 110, 33, 33):clip(c:rect(0, 72, 79, 99))
c:part(body, BR, { band = 3, pop = { x = 13, y = 86 } })
for _, q in ipairs({ { 12, 90 }, { 16, 84 }, { 21, 80 }, { 60, 81 }, { 64, 86 }, { 67, 92 } }) do recol(c:rect(q[1], q[2], q[1] + 2, q[2]):clip(body:shrink(1)), BR.deep) end
local bib = c:ellipse(39.5, 108, 15, 30):clip(c:rect(0, 74, 79, 99)):clip(body)
c:part(bib, BELLY, { band = 2, nopop = true })
for _, q in ipairs({ { 33, 84 }, { 41, 82 }, { 46, 88 }, { 36, 91 }, { 43, 95 }, { 30, 96 } }) do c:put(q[1], q[2], BR.shade) end
-- head
local head = c:ellipse(39.5, 50, 20, 18)
c:part(head, BR, { band = 3 })
-- babushka scarf
local open = c:ellipse(39.5, 53, 16, 14)
local s = c:ellipse(39.5, 46, 24.5, 23):cut(open):clip(c:rect(0, 0, 79, 70))
s:add(c:ellipse(39.5, 72, 4, 2.5))
s:add(c:poly{ { 37, 73 }, { 29, 88 }, { 35, 89 } }) s:add(c:poly{ { 42, 73 }, { 50, 88 }, { 44, 89 } })
c:part(s, SC, { band = 3, pop = { x = 22, y = 30 } }) under(s, SC.deep)
recol(c:line({ { 39, 73 }, { 33, 87 } }, 1):clip(s:shrink(1)), SC.shade) recol(c:line({ { 40, 73 }, { 46, 87 } }, 1):clip(s:shrink(1)), SC.deep)
local inn, keep = s:shrink(2), open:grow(2)
for y = 26, 68, 7 do for x = 16, 63, 7 do local xx = x + ((y - 26) // 7 % 2) * 3
  if inn:has(xx, y) and inn:has(xx + 1, y + 1) and not keep:has(xx, y) then
    c:put(xx, y, P.cream) c:put(xx + 1, y, P.cream) c:put(xx, y + 1, P.cream) c:put(xx + 1, y + 1, P.stone.hi) end end end
-- face
local face = open:copy():clip(head)
c:part(face, FACE, { band = 2, nopop = true })
c:line({ { 24, 45 }, { 32, 42 } }, 1):each(function(x, y) c:put(x, y, P.cream) end)
c:line({ { 47, 42 }, { 55, 45 } }, 1):each(function(x, y) c:put(x, y, P.cream) end)
c:eyeLocked(29, 47) c:eyeLocked(46, 47)
for _, gx in ipairs({ 31, 48 }) do
  c:ellipse(gx, 49, 4, 4):cut(c:ellipse(gx, 49, 3, 3)):each(function(x, y) c:put(x, y, P.gold.base) end)
  c:put(gx - 3, 46, P.gold.hi) c:put(gx - 2, 45, P.gold.hi)
end
for x = 36, 43 do c:put(x, 47, P.gold.shade) end
c:paint({ "hGGGGS", ".GGGS.", "..GS.." }, 37, 54, { h = "gold.hi", G = "gold.base", S = "gold.shade" })
c:paint({ "PPP", "PPP" }, 23, 55, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 55, { P = "petal.base" })
-- babka loaf held under the right wing
local loaf = c:rrect(48, 82, 76, 96, 5)
c:part(loaf, CRUST, { band = 2, pop = { x = 52, y = 84 } }) under(loaf, CRUST.deep)
for k = 0, 3 do recol(c:line({ { 53 + k * 6, 83 }, { 57 + k * 6, 95 } }, 1):clip(loaf:shrink(1)), CHOC) end
for k = 0, 3 do recol(c:line({ { 54 + k * 6, 84 }, { 57 + k * 6, 93 } }, 1):clip(loaf:shrink(2)), CRUST.shade) end
for x = 51, 73, 3 do c:put(x, 83, P.cream) end
local wing = c:ellipse(50, 91, 6, 5)
c:part(wing, BR, { band = 2 })
recol(c:line({ { 46, 93 }, { 53, 89 } }, 1):clip(wing:shrink(1)), BR.deep)
c:finish{ outline = true }
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
