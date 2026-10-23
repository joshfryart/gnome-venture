-- Hurricane Crab (boss, wetland, lv 30): a storm-blue crab whose shell carries a whole island
-- (sand mound, palm, straw hut) under a swirling storm cloud. One giant raised claw.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-cb-4-lair-lair-of-the-hurricane-crab"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local SHELL = GV.R.water
local CLAW  = GV.ramp("#2f6290")
local SAND  = GV.ramp("#c9a96e")
local CLOUD = GV.ramp("#5b6470")
local BOLT  = GV.R.gold

-- legs (back), three per side, bent
local legs = c:line({ {19,45}, {13,48}, {10,53} }, 3)
legs:add(c:line({ {23,48}, {19,51}, {17,55} }, 3))
legs:add(c:line({ {44,45}, {50,48}, {53,53} }, 3))
legs:add(c:line({ {40,48}, {44,51}, {46,55} }, 3))
-- arms
local armL = c:line({ {18,41}, {14,38}, {13,33} }, 3)
local armR = c:line({ {45,42}, {49,41}, {51,38} }, 3)
-- giant raised claw (left) with spiked outer edge and pincer notch
local clawL = c:ellipse(12, 25, 6, 8.5):cut(c:poly({ {9.5,15}, {16.5,15}, {12.5,25} }))
-- small low claw (right)
local clawR = c:ellipse(52, 33, 4, 5):cut(c:poly({ {51,27}, {58,27}, {53.5,33} }))
-- storm cloud (back, top-left) and wind curl
local cloud = c:ellipse(14.5, 13, 3.5, 3.5):add(c:ellipse(22, 10.5, 5, 4.5)):add(c:ellipse(29.5, 12, 3.5, 3.5))
cloud:add(c:rrect(10, 13, 33, 17, 2))
local bolt = c:poly({ {30,15}, {34,15}, {32,18}, {34,18}, {30,24}, {31,20}, {29,20} })
-- shell: wide, flat, spiked at the sides
local shell = c:ellipse(31.5, 41, 18, 8.5)
shell:add(c:poly({ {14,37}, {10,39}, {14,41} })):add(c:poly({ {50,37}, {54,39}, {50,41} }))
-- island sand mound sewn on the shell top
local sand = c:ellipse(30.5, 33, 15, 6.5):cut(c:rect(0, 34, 63, 63))
sand:add(c:rrect(16, 31, 45, 35, 2))
-- hut
local walls = c:rect(19, 22, 26, 29)
local roof = c:poly({ {16,23}, {22.5,15}, {29,23} })
-- palm
local trunk = c:line({ {37,29}, {38,23}, {39,19}, {41,14} }, 2)
local fronds = c:line({ {41,13}, {38,11}, {35,13} }, 3)
fronds:add(c:line({ {42,13}, {46,10}, {50,12}, {51,15} }, 3))
fronds:add(c:line({ {41,12}, {40,9}, {37,8} }, 2))
fronds:add(c:line({ {42,12}, {45,8}, {48,8} }, 2))

local p = c:build{
  { "cloud", cloud, CLOUD, { gloss = { 19, 8 } } },
  { "bolt",  bolt,  BOLT, { flat = true } },
  { "legs",  legs,  "leg", { flat = true } },
  { "armL",  armL,  CLAW, { flat = true } },
  { "armR",  armR,  CLAW, { flat = true } },
  { "clawL", clawL, SHELL },
  { "clawR", clawR, SHELL, { gloss = false } },
  { "shell", shell, SHELL },
  { "sand",  sand,  SAND, { gloss = { 20, 30 } } },
  { "walls", walls, "wood", { gloss = false } },
  { "roof",  roof,  "gold", { gloss = { 20, 19 } } },
  { "trunk", trunk, "wood", { flat = true } },
  { "fronds", fronds, "leaf", { flat = true } },
}
-- storm swirl on the cloud
c:paint({ ".sss.", "s...s", "s.s.s", "s..s.", ".ss.." }, 21, 9, { s = "#a9d6ea" })
-- hut door and thatch line
c:fill(c:rect(22, 25, 23, 29), "#4a2c1a")
-- coconuts
c:fill(c:rect(40, 14, 41, 15), "#5e2f1e"); c:fill(c:rect(42, 15, 43, 16), "#5e2f1e")
-- island sewn onto the shell
c:seam({ {18, 35}, {44, 35} })
c:button(29, 33)
-- angry face on the shell front
c:eye(22, 38); c:eye(36, 38)
c:paint({ "uu.", ".uu" }, 20, 36, { u = "#2a1a10" })
c:paint({ ".uu", "uu." }, 39, 36, { u = "#2a1a10" })
c:paint({ "uuuuuuuu", "u.u..u.u" }, 28, 45, { u = "#2a1a10" })
-- stitched scar across the shell flank
c:fill(c:line({ {43,44}, {47,40} }, 1), "#2a3c6c")
c:px(44, 41, "#f5cf6a"); c:px(46, 43, "#f5cf6a")
c:ground(31.5, 55, 20, 1.5)
local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
