-- Cinder Wyrm, keeper of the Forge of the Cinder Wyrm: a legendary lava wyrm,
-- charcoal-scaled with glowing ember cracks, its long body stacked in two coils
-- round the base of an old brick forge chimney that still spits flame. Horned
-- head reared up on the left, ember throat plate, stubby lizard foreleg.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local coal  = GV.ramp("#5b6470")               -- charcoal scales (stone family, darkest base)
local brick = GV.ramp("#7a4a1f")               -- forge chimney brick (soil family)
local ember = GV.R.flame                       -- glowing throat and tail tip
local horn  = GV.R.dusk                        -- dark horns and spikes

-- forge chimney rising behind the coils, flame spitting from its mouth
local flame = c:poly({ {41, 13}, {40, 9}, {43, 11}, {44, 6}, {47, 10}, {49, 7}, {50, 13} })
local stack = c:rect(39, 14, 50, 44)
local cap   = c:rrect(37, 11, 52, 15, 1)

-- bottom coil: long band, left end tapering into the tail
local coilA = c:rrect(14, 43, 55, 54, 5)
coilA:add(c:poly({ {6, 52}, {16, 44}, {16, 55}, {8, 55} }))
-- tail flicking up at the far left
local tail = c:line({ {8, 52}, {7, 48} }, 3)
local tip  = c:poly({ {5, 48}, {7, 41}, {10, 48} })

-- upper coil resting on the bottom one, wrapped round the chimney
local coilB = c:rrect(16, 33, 52, 45, 6)

-- dorsal spikes along the neck back
local spikes = c:mask()
local function spike(x, y, dx, dy)
  spikes:add(c:poly({ {x, y}, {x + dx, y + dy}, {x + 4, y + 2} }))
end
spike(6, 30, -2, -3); spike(6, 24, -2, -3)

-- neck rising from the upper coil's left end
local neck = c:line({ {16, 40}, {13, 33}, {13, 26} }, 9)

-- horns sweeping back from the brow
local horns = c:poly({ {11, 13}, {7, 6}, {16, 11} })
horns:add(c:poly({ {20, 11}, {19, 5}, {25, 11} }))

-- big wedge head, snout to the right
local head = c:ellipse(19.5, 19, 11, 8.5)
head:add(c:poly({ {24, 15}, {35, 18}, {36, 25}, {24, 27} }))

-- ember throat plate down the front of the neck
local throat = c:line({ {18, 29}, {19, 35} }, 4)

-- stubby foreleg clawing at the upper coil
local leg = c:line({ {22, 32}, {25, 38} }, 4)
local foot = c:ellipse(26.5, 39, 3, 2)

local p = c:build{
  { "flame",  flame,  ember, { gloss = false, contour = false } },
  { "stack",  stack,  brick, { gloss = false } },
  { "cap",    cap,    brick, { gloss = { 39, 12 } } },
  { "coilA",  coilA,  coal,  { gloss = { 20, 47 } } },
  { "tail",   tail,   coal,  { flat = true } },
  { "tip",    tip,    ember, { flat = true } },
  { "coilB",  coilB,  coal,  { gloss = { 22, 36 }, stitch = { side = "lit" } } },
  { "spikes", spikes, horn,  { flat = true } },
  { "neck",   neck,   coal,  { gloss = false, light = neck:copy():add(head) } },
  { "horns",  horns,  horn,  { flat = true } },
  { "head",   head,   coal,  { gloss = { 12, 14 } } },
  { "throat", throat, ember, { gloss = false, contour = false } },
  { "leg",    leg,    coal,  { flat = true } },
  { "foot",   foot,   coal,  { flat = true } },
}

-- brick mortar on the chimney
local mortar = brick.shade
for _, y in ipairs({ 19, 25, 31 }) do
  for x = 40, 49 do if c:get(x, y) == brick.base then c:px(x, y, mortar) end end
end
for _, b in ipairs({ {44, 16}, {44, 17}, {44, 18}, {41, 20}, {41, 21}, {41, 22}, {41, 23}, {41, 24},
                     {47, 20}, {47, 21}, {47, 22}, {47, 23}, {47, 24}, {44, 26}, {44, 27}, {44, 28}, {44, 29}, {44, 30} }) do
  if c:get(b[1], b[2]) == brick.base then c:px(b[1], b[2], mortar) end
end
-- inner flame core
c:paint({ "..g..", ".ggg." }, 43, 10, { g = "#f5cf6a" })

-- glowing ember cracks across the charcoal scales
local hot, core = "#f08a24", "#f5cf6a"
local function crack(rows, x, y) c:paint(rows, x, y, { o = hot, g = core }) end
crack({ "o...", ".og.", "...o" }, 27, 38)
crack({ "..o", ".g.", "o..", "o.." }, 40, 37)
crack({ "o..o", ".go." }, 32, 48)
crack({ "..o.", ".g..", "o...", ".o.." }, 45, 47)
crack({ ".o", "g.", "o." }, 22, 49)
crack({ "o.", ".o", ".g" }, 9, 31)
crack({ "o..", ".go" }, 16, 22)

-- seam where the ember throat plate is sewn on, button at the chin
c:seam({ {16, 29}, {16, 37} })
c:button(18, 26)

-- face: wide-set locked eyes, ember-lit jaw with two fangs
c:eye(14, 14); c:eye(23, 14)
c:paint({ "mmmmmmmmm.", ".ffffff..m", "..c....c.." }, 25, 23, { m = GV.C.ol3, f = "#f08a24", c = "#f1ece0" })
c:px(33, 19, "#f08a24")   -- glowing nostril

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-se-4-lair-forge-of-the-cinder-wyrm.aseprite",
                 PNG .. "creature-boss-lm-se-4-lair-forge-of-the-cinder-wyrm.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
