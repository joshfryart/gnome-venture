-- npc-captain_pipi_shellback.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), OC "Reef & Purr"
-- Shopkeeper bust: Captain Pipi Shellback, a cheerful green sea turtle who sails the Coralscatter lagoons.
-- 80x100 gvlib "bust" mode, same build as the ph/npc-* and other art22 shop busts (round backdrop disc, head
-- ~36 px, body bleeding off the bottom, 1 px #000000 border). A cream skipper's cap with a navy peak and a band
-- of brown-and-cream tapa cloth, a frangipani tucked at the side; his shell shows behind the shoulders of a navy
-- sailing jacket with a cream shirt and a string of pipi shells. He holds a grey kitten wearing a little flower
-- lei in his flippers. Pacific touches (tapa, frangipani, shells, the turtle) kept gentle, no costume clichés.
-- Light from the upper left; locked eyes; no text.
-- Pass 1: cap lowered and widened to sit on the head, smaller shell inside the disc, a neck, pale muzzle.
-- Pass 2: scute seams clipped to the visible shell (no stray lines on neck or kitten), radial plate seams.
-- Run: AppRun -b --script npc-captain_pipi_shellback.lua     Writes ../out/npc-captain_pipi_shellback.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local D = "#2a1a10"

local SKIN  = GV.ramp("moss")                -- turtle green
local SHELL = GV.ramp("#9a6b3f")             -- carapace (soil family)
local CAP   = GV.ramp("cream", { dot = "#fff3c8" })
local NAVY  = GV.ramp("#2f4a7a")
local KIT   = GV.ramp("#9a96a6")             -- grey kitten (stone family)
local TAPA, CREAM = "#6a3a22", "#fff1c8"

-- shapes (back to front)
local disc  = c:ellipse(39.5, 50, 34, 34)
local shell = c:ellipse(39.5, 94, 34, 22)
local coat  = c:ellipse(39.5, 107, 30, 29)
local head  = c:ellipse(39.5, 57, 19, 16.5)
local neck  = c:rrect(30, 68, 49, 84, 4)
local crown = c:ellipse(39.5, 31, 22, 10):cut(c:rect(0, 34, 79, 99))
crown:add(c:rrect(19, 28, 60, 40, 3))
local band  = c:rect(20, 35, 59, 40)
local peak  = c:ellipse(39.5, 42, 18, 3.5):cut(c:rect(0, 0, 79, 40))
local shirt = c:poly({ { 30, 79 }, { 50, 79 }, { 40, 92 } })
-- kitten held in front, lower left
local kit   = c:ellipse(25.5, 88, 12, 9.5)
kit:add(c:poly({ { 14, 86 }, { 15, 72 }, { 24, 80 } }))
kit:add(c:poly({ { 27, 80 }, { 36, 72 }, { 37, 86 } }))
local flipL = c:ellipse(13, 96, 5, 3)
local flipR = c:ellipse(38, 96, 5, 3)

c:build{
  { "disc",  disc,  "#8fd0c8", { contour = false, gloss = false } },
  { "shell", shell, SHELL, { gloss = false } },
  { "neck",  neck,  SKIN, { gloss = false } },
  { "coat",  coat,  NAVY, { stitch = { side = "lit" } } },
  { "head",  head,  SKIN },
  { "crown", crown, CAP },
  { "band",  band,  GV.ramp(TAPA), { flat = true } },
  { "peak",  peak,  NAVY, { gloss = false } },
  { "shirt", shirt, "cream", { flat = true } },
  { "kit",   kit,   KIT },
  { "flipL", flipL, SKIN, { gloss = false } },
  { "flipR", flipR, SKIN, { gloss = false } },
}

-- shell scutes peeking past the shoulders: a ring of plate seams echoing the edge, radial seams out to the
-- rim, and a lighter centre on each marginal plate (only where the shell itself shows)
local shellVis = shell:copy():shrink(1):cut(coat:grow(1)):cut(neck:grow(1)):cut(kit:grow(1)):cut(head:grow(1))
local scute = c:ellipse(39.5, 94, 29, 17):edge()
scute:add(c:line({ { 10, 84 }, { 6, 82 } }, 1)):add(c:line({ { 17, 78 }, { 14, 74 } }, 1))
scute:add(c:line({ { 62, 78 }, { 65, 74 } }, 1)):add(c:line({ { 69, 84 }, { 73, 82 } }, 1))
c:fill(scute:clip(shellVis), SHELL.shade)
c:fill(c:rect(9, 78, 10, 79):add(c:rect(68, 78, 69, 79)):add(c:rect(58, 74, 59, 75)):add(c:rect(20, 74, 21, 75)):clip(shellVis), SHELL.rim)
-- tapa triangles on the cap band
for x = 21, 57, 4 do c:paint({ "xxx", ".x." }, x, 37, { x = CREAM }) end
-- gold star badge on the band centre
c:paint({ ".g.", "ggg", ".g." }, 38, 36, { g = "#f5cf6a" })
-- frangipani tucked at the right of the cap
c:paint({ ".pp.", "pppp", "ppyp", ".pp." }, 54, 30, { p = CREAM, y = "#f5cf6a" })
c:paint({ ".pp", "pp." }, 57, 27, { p = "#f7b8cf" })
-- turtle scale patches on the brow and cheeks
for _, p in ipairs({ { 24, 55 }, { 53, 55 }, { 26, 62 }, { 51, 62 } }) do
  c:paint({ "ss", "ss" }, p[1], p[2], { s = SKIN.rim })
end

-- pale beak-like muzzle
c:fill(c:ellipse(39.5, 60, 9, 4.5), SKIN.gloss)
-- face: locked eyes, little nostrils, big friendly smile
c:eye(28, 50); c:eye(46, 50)
c:px(38, 57, SKIN.deep); c:px(41, 57, SKIN.deep)
c:paint({ "u..........u", ".u........u.", "..uuuuuuuu.." }, 34, 61, { u = D })
c:fill(c:rect(37, 63, 42, 63), "#dd3a2a")

-- pipi-shell necklace across the shirt
for i, p in ipairs({ { 31, 80 }, { 35, 83 }, { 40, 85 }, { 45, 83 }, { 49, 80 } }) do
  c:paint({ "sss", ".s." }, p[1] - 1, p[2], { s = (i % 2 == 0) and "#f7b8cf" or CREAM })
end
c:button(56, 86); c:button(57, 93)

-- kitten face: locked small eyes, pink nose, mouth, a flower lei collar
c:eye(19, 85, true); c:eye(29, 85, true)
c:paint({ "pp" }, 25, 89, { p = "#e46a9b" })
c:paint({ "u.uu.u", ".u..u." }, 23, 90, { u = D })
c:fill(c:rect(16, 76, 17, 79), "#e46a9b"); c:fill(c:rect(34, 76, 35, 79), "#e46a9b")
c:fill(c:rect(24, 79, 27, 80), KIT.shade)
for x = 16, 34, 3 do c:paint({ "ff" }, x, 95, { f = (x % 2 == 0) and "#e46a9b" or "#f5cf6a" }) end

-- joins
c:seam({ { 23, 41 }, { 56, 41 } })

local t = c:save(OUT .. "npc-captain_pipi_shellback.aseprite", OUT .. "npc-captain_pipi_shellback.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)
