-- Cinder Wyrm, keeper of the Forge of the Cinder Wyrm: a legendary lava wyrm,
-- charcoal-scaled with glowing ember cracks, its long body stacked in two coils
-- round the base of an old brick forge chimney that still spits flame. Horned
-- head reared up on the left, ember throat plate, stubby lizard foreleg.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local coal  = GV.ramp("#454955")               -- charcoal scales (stone family, one recipe step down)
local brick = GV.ramp("#a8582f")               -- forge chimney brick (wood family bounce red)
local ember = GV.R.flame                       -- glowing maw, belly and tail tip

-- forge chimney on the right, flame spitting from its mouth
local flame = c:poly({ {45, 11}, {44, 7}, {47, 9}, {49, 5}, {51, 9}, {54, 6}, {54, 11} })
local stack = c:rect(45, 13, 53, 42)
local cap   = c:rrect(43, 10, 55, 14, 1)

-- bottom coil, left end tapering into the tail along the ground
local coilA = c:ellipse(33, 48.5, 22, 6.5)
coilA:add(c:poly({ {9, 55}, {16, 47}, {18, 55} }))
local tip = c:poly({ {5, 55}, {9, 50}, {11, 55} })

-- upper coil resting on the bottom one, wrapped round the chimney
local coilB = c:ellipse(33, 38, 18, 6.5)

-- ember belly glowing under each coil -- (segmented belly scutes, 3 on / 1 off, on the coil undersides)
local bellyA, bellyB = c:mask(), c:mask()
for x = 16, 50, 4 do bellyA:add(c:rect(x, 52, x + 2, 53)) end
for x = 22, 46, 4 do bellyB:add(c:rect(x, 42, x + 2, 42)) end
bellyA:clip(c:ellipse(33, 48.5, 21, 5.5)); bellyB:clip(c:ellipse(33, 38, 17, 5.5))

-- dorsal spikes down the neck back and along the upper coil
local spikes = c:mask()
local function spike(pts) spikes:add(c:poly(pts)) end
spike({ {9, 27}, {5, 24}, {9, 32} }); spike({ {9, 32}, {6, 31}, {11, 37} })
for _, x in ipairs({ 27, 33, 39 }) do spike({ {x, 33}, {x + 2, 27}, {x + 5, 33} }) end

-- neck rising from the upper coil's left end
local neck = c:line({ {16, 40}, {13, 33}, {14, 26} }, 9)

-- horns sweeping back off the skull
local horns = c:poly({ {14, 14}, {6, 8}, {9, 8}, {18, 12} })
horns:add(c:poly({ {20, 12}, {16, 6}, {19, 6}, {25, 11} }))

-- glowing maw behind the open jaws
local maw = c:poly({ {26, 20}, {40, 20}, {40, 28}, {26, 28} })

-- big wedge head, jaws open to the right
local head = c:ellipse(19.5, 19, 10, 8)
head:add(c:poly({ {25, 13}, {41, 16}, {41, 21}, {25, 23} }))
local jaw = c:poly({ {21, 25}, {38, 27}, {37, 31}, {20, 30} })

-- ember throat plate down the front of the neck
local throat = c:line({ {19, 29}, {19, 35} }, 4)

-- stubby foreleg clawing at the upper coil
local leg = c:line({ {21, 32}, {23, 37}, {26, 38} }, 4)

local p = c:build{
  { "flame",  flame,  ember, { gloss = false, contour = false } },
  { "stack",  stack,  brick, { gloss = false } },
  { "cap",    cap,    brick, { gloss = { 45, 11 } } },
  { "coilA",  coilA,  coal,  { gloss = { 22, 46 } } },
  { "bellyA", bellyA, ember, { flat = true, contour = false } },
  { "tip",    tip,    ember, { flat = true } },
  { "coilB",  coilB,  coal,  { gloss = { 24, 35 }, stitch = { side = "lit" } } },
  { "bellyB", bellyB, ember, { flat = true, contour = false } },
  { "spikes", spikes, ember, { flat = true } },
  { "neck",   neck,   coal,  { gloss = false, light = neck:copy():add(head) } },
  { "horns",  horns,  "gold", { flat = true } },
  { "maw",    maw,    ember, { gloss = false, contour = false } },
  { "jaw",    jaw,    coal,  { gloss = false } },
  { "head",   head,   coal,  { gloss = { 13, 14 } } },
  { "throat", throat, ember, { gloss = false, contour = false } },
  { "leg",    leg,    coal,  { flat = true } },
}

-- brick courses on the chimney (staggered joints)
local mortar = brick.deep
for i, y in ipairs({ 17, 21, 25, 29 }) do
  for x = 46, 52 do if c:get(x, y) == brick.base then c:px(x, y, mortar) end end
  local jx = (i % 2 == 0) and { 48 } or { 50 }
  for _, x in ipairs(jx) do
    for yy = y + 1, y + 3 do if c:get(x, yy) == brick.base then c:px(x, yy, mortar) end end
  end
end
-- hot flame core
c:paint({ "...g..", "..ggg.", ".ggggg" }, 46, 8, { g = "#f5cf6a" })

-- glowing ember cracks across the charcoal scales
local hot, core = "#f08a24", "#f5cf6a"
local function crack(rows, x, y) c:paint(rows, x, y, { o = hot, g = core }) end
crack({ "o...", ".og.", "...o" }, 28, 37)
crack({ "..o", ".g.", "o..", "o.." }, 41, 36)
crack({ "o...o", ".ggo." }, 30, 47)
crack({ "..o.", ".g..", "o...", ".o.." }, 44, 46)
crack({ ".o", "g.", "o." }, 22, 48)
crack({ "o..", ".go" }, 17, 22)
crack({ "o.", ".g", ".o" }, 10, 34)

-- seam where the ember throat plate is sewn on, button at its head
c:seam({ {17, 31}, {17, 37} })
c:button(17, 27)

-- face: wide-set locked eyes under the horns, fangs over the glowing maw
c:eye(14, 15); c:eye(23, 15)
c:paint({ "c....c", "c....c" }, 31, 22, { c = "#f1ece0" })   -- upper fangs
c:paint({ "c", "c" }, 34, 26, { c = "#f1ece0" })               -- lower fang
c:paint({ "c.c" }, 27, 40, { c = "#f1ece0" })                  -- claws
c:px(38, 18, "#f08a24")   -- glowing nostril

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-se-4-lair-forge-of-the-cinder-wyrm.aseprite",
                 PNG .. "creature-boss-lm-se-4-lair-forge-of-the-cinder-wyrm.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
