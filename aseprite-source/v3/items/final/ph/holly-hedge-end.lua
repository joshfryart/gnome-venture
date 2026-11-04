-- holly-hedge-end: 3/4 view terminal piece of clipped holly hedge. A slim run comes in from a clean-cut connector
-- end on the left (trimmed twig ends showing) and finishes in a rounded topiary cap on the right. Lumpy top face
-- lit per pixel (6-tone glossy holly), darker front face with AO under the overhang, stamped spiky leaves with
-- midribs, contact shadows and waxy glints, berry clusters, 2 px soil strip with pebbles.
-- quirk: a robin has claimed the rounded cap as its perch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_1.lua")
local HP = A.HP
local c = A.new("holly-hedge-end")
local plan = A.union(HP.rect(8, 22, 49, 32), HP.ellipse(49, 27, 6.2, 5))
A.spikes(plan, { { 0, -1 }, { 1, 0 }, { 1, -1 } }, 3, 0.32, function(x, y) return x <= 9 end)
A.hedge3q(plan, 8, { cutL = 8, seed = 5, pebbles = { { 14, 42 }, { 31, 41 }, { 46, 42 } } })
A.berries({ { 13, 25 }, { 27, 28 }, { 38, 24 }, { 21, 35, { { 0, 0 }, { 3, 1 } } } })
-- robin (facing left), feet on the cap
A.paint({
  "...hhb.....",
  "..hbbbb....",
  ".hbebbbbb..",
  "yoobbbbbbbt",
  ".oooobbbdtt",
  ".oOOwwbddt.",
  "..OwwwwdD..",
  "...wwwd....",
  "....l.l....",
}, 44, 13, { h = "#b07c4c", b = "#7e5236", d = "#583828", D = "#3e2722", e = "#2b1c26", y = "#f2b23a",
  o = "#f27a38", O = "#c75230", w = "#f4e6cc", t = "#4e3026", l = "#4e2f26" })
A.fin()
