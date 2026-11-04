-- npc-quill-rootstock portrait (npc2 P1_31) species: rhinoceros beetle
-- 80x100 head-and-shoulders, bleeds off the bottom. Violet shell helmet with gold seam and stubby horn,
-- knobbed antennae, brown face, wing cases behind the shoulders, teal tunic + violet scarf.
-- Prop: a gnarled taproot with a fresh sprout. Backdrop: gold disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-quill-rootstock"
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- wing cases behind the shoulders
for _, s in ipairs{ -1, 1 } do
  local el = c:ellipse(39.5 + s * 25, 82, 8.5, 14)
  c:part(el, "dusk", { band = 2, pop = { x = 39 + s * 25 - 4, y = 72 } })
  c:fillMask(c:line({ {39.5 + s * 22, 72}, {39.5 + s * 22, 99} }, 1):clip(el:shrink(1)), P.dusk.deep)
end
-- tunic
local body = c:ellipse(39.5, 108, 28, 35):clip(c:rect(0, 70, 79, 99))
c:part(body, "sea", { band = 3, pop = { x = 20, y = 82 } })
-- scarf with hanging tail
local sc = c:rrect(22, 68, 57, 75, 3):add(c:poly{ {46,73},{52,73},{55,90},{48,89} })
c:part(sc, "dusk", { band = 2, pop = { x = 25, y = 69 } })
c:fillMask(c:line({ {49,76},{51,88} }, 1), P.dusk.shade)
c:button(40, 72)
-- gnarled taproot, held up at lower left
local root = c:line({ {13,99},{16,92},{19,86},{21,79} }, 4)
for _, q in ipairs{ {15,94},{20,84},{17,89} } do root:add(c:ellipse(q[1], q[2], 2.5, 2)) end
c:part(root, "wood", { band = 2, pop = { x = 17, y = 84 } })
for _, q in ipairs{ {18,87},{19,88},{16,93},{20,82} } do c:put(q[1], q[2], P.wood.deep) end
c:fillMask(c:line({ {13,92},{10,90} }, 1), P.wood.shade) c:fillMask(c:line({ {19,90},{23,93} }, 1), P.wood.shade)
c:fillMask(c:line({ {21,79},{21,75} }, 1), P.moss.shade)
c:part(c:ellipse(18, 74, 3.5, 1.8), "moss", { band = 1, pop = { x = 16, y = 73 } })
c:part(c:ellipse(25, 73, 3.5, 1.8), "moss", { band = 1 })
c:part(c:ellipse(25, 89, 4, 3), "skinB", { band = 1, pop = { x = 23, y = 88 } })
-- face + shell helmet
c:part(c:ellipse(39.5, 52, 18, 15), "skinB", { band = 3, pop = { x = 30, y = 56 } })
local helm = c:ellipse(39.5, 46, 22, 19):cut(c:ellipse(39.5, 56, 15.5, 13)):clip(c:rect(0, 0, 79, 59))
c:part(helm, "dusk", { band = 3, pop = { x = 25, y = 34 } })
c:stitch{ {39,29},{39,42} }
for _, q in ipairs{ {24,37},{23,39},{22,41},{26,35} } do c:put(q[1], q[2], P.dusk.hi) end
c:part(c:poly{ {36,31},{43,31},{42,24},{40,20},{38,22} }, "dusk", { band = 1, pop = { x = 38, y = 24, horizontal = false } })
-- face
c:eyeLocked(29, 47) c:eyeLocked(46, 47)
local nose = c:ellipse(39.5, 55, 2.5, 2)
c:part(nose, "skinB", { band = 1, pop = { x = 38, y = 54 } })
c:paint({ "i......i", ".iiiiii." }, 36, 59, { i = "ink" })
c:cheek(26, 55) c:cheek(52, 55)
-- antenna knobs (stalks after outline)
c:part(c:ellipse(20, 12, 2.5, 2.5), "dusk", { band = 1, pop = { x = 18, y = 11 } })
c:part(c:ellipse(59, 12, 2.5, 2.5), "dusk", { band = 1, pop = { x = 57, y = 11 } })
c:finish{ outline = true }
c:fillMask(c:line({ {33,29},{29,21},{25,16},{22,14} }, 1), P.ink)
c:fillMask(c:line({ {46,29},{50,21},{54,16},{57,14} }, 1), P.ink)
backdrop(c, P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
