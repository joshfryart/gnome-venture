-- creature-rot-snail: soft slumped black-violet felt shell whose tip flops forward like a
-- deflated nightcap, sickly olive foot, faces left; withered grass tufts on its trail.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local sick   = GV.ramp("#9ea06a")                      -- sickly olive (moss family, greyed)
local shellR = GV.ramp("#382a50", { rim = "#7b66b4", gloss = "#a894dc", dot = "#c8b8ec" }) -- black-violet (dusk)
local straw  = GV.ramp("#b89c62")                      -- withered grass (soil family)

-- foot: long low body, tail tapering right into the trail
local foot = c:ellipse(26, 51, 18, 3.5)
foot:add(c:poly({ {36,48}, {49,51}, {50,53}, {36,55} }))
-- big chibi head on the left, rising from the foot
local head = c:ellipse(16.5, 38, 9.5, 9):add(c:rrect(8, 40, 25, 52, 4))
-- short wilted stalks splayed outward, ending in 4x4 clubs
local stalks = c:line({ {12,31}, {11,25}, {9,22} }, 2):add(c:line({ {20,31}, {22,25}, {24,22} }, 2))
local clubs = c:rrect(6, 19, 9, 22, 1):add(c:rrect(24, 19, 27, 22, 1))

-- slumped shell: low sagging dome; its soft top folds over and hangs down the back
local shell = c:ellipse(33, 40, 11, 9):cut(c:rect(0, 47, 63, 63))
shell:add(c:rrect(21, 41, 45, 48, 4))                  -- sagging hem pooling on the foot
local flop = c:line({ {29,33}, {35,28}, {41,26}, {46,29}, {48,32} }, 5)
flop:add(c:ellipse(48, 35, 2.5, 3))                    -- the floppy tip hanging down

-- trail: withered grass tufts, blade tips bent over
local tuft = c:line({ {47,54}, {46,48}, {43,46} }, 2):add(c:line({ {50,54}, {50,43}, {51,41} }, 2))
tuft:add(c:line({ {53,54}, {54,47}, {55,46} }, 2))
tuft:add(c:rect(46, 52, 54, 54))

local p = c:build{
  { "stalks", stalks, sick, { flat = true } },
  { "clubs",  clubs, sick, { flat = true } },
  { "foot",   foot, sick },
  { "shell",  shell, shellR, { gloss = { 27, 36 } } },
  { "flop",   flop, shellR, { gloss = { 34, 29 } } },
  { "tuft",   tuft, straw, { flat = true } },
  { "head",   head, sick, { gloss = { 10, 33 } } },
}

-- soft folds in the shell (curved creases, not a spiral)
local inner = p.shell.m:shrink(2)
c:fill(c:line({ {33,34}, {35,40}, {34,44} }, 1):clip(inner), shellR.deep)
c:fill(c:line({ {40,34}, {42,39}, {41,44} }, 1):clip(inner), shellR.deep)
-- hem seam along the sagging bottom, button where the flop is sewn on
c:seam({ {27,45}, {45,45} })
c:button(29, 29)

-- rot spots on the foot
c:spot(c:ellipse(38.5, 51, 1.5, 1))
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 29, 50))

-- face: wide locked eyes, droopy frown
c:eye(9, 36); c:eye(18, 36)
c:paint({ ".uuu.", "u...u" }, 12, 44, { u = "#2a1a10" })

-- rotten trail: dark stain on the ground behind it
c:ground(33, 57, 22, 1, "#35161f")
local t = c:save(D .. "final/aseprite/ph/creature-rot-snail.aseprite", PNG .. "creature-rot-snail.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
