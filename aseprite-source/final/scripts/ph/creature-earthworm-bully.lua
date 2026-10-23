-- creature-earthworm-bully : a fat pink worm that thinks the tunnel is his, and shoves like it.
-- Reared up from a coiled base, leaning in chest-first, scowling V brow, smug underbite,
-- tail tip flicked up behind him, and a stitched clitellum worn like a champion's belt.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pink = GV.R.petal                       -- petal family #e46a9b
local band = GV.ramp("#c9507e")               -- deeper petal for the clitellum belt

-- coiled tail lying on the ground, tip flicked up at the back
local coil = c:ellipse(30, 50, 21, 5.5)
coil:add(c:line({ {12, 49}, {9, 44}, {9, 40} }, 5)):add(c:ellipse(10, 38.5, 2, 2))
-- fat torso leaning in to the right, belly pushed out
local torso = c:ellipse(29, 45, 11, 7):add(c:ellipse(31.5, 38, 11.5, 9)):add(c:ellipse(34, 29, 9.5, 7))
-- big chibi head, jutting forward
local head = c:ellipse(35, 17, 14, 10.5)
-- clitellum belt across the belly, following the lean
local belt = torso:copy():clip(c:poly({ {0, 33}, {63, 31}, {63, 37}, {0, 39} }))

local p = c:build{
  { "torso", torso, pink, { light = torso:copy():add(head) } },
  { "coil", coil, pink },
  { "belt", belt, band, { gloss = false, contact = false } },
  { "head", head, pink, { gloss = { 29, 8 } } },
}

-- segment rings: one on the neck, a few across the coil
local rc = pink.shade
torso:shrink(1):clip(c:rect(0, 28, 63, 28)):each(function(x, y) c:px(x, y, rc) end)
for _, x in ipairs({ 15, 46, 50 }) do
  coil:shrink(1):clip(c:rect(x, 0, x, 63)):each(function(xx, y) c:px(xx, y, rc) end)
end

-- belt seam with a button buckle
c:seam({ {21, 36}, {44, 34} })
c:button(31, 33)

-- eyes under a heavy scowling V brow
c:eye(26, 15); c:eye(39, 15)
c:paint({
  "bb..................bb",
  "bbbb..............bbbb",
  "..bbbb..........bbbb..",
  "....bbbb......bbbb....",
}, 24, 11, { b = "umber" })
-- lopsided smirk with an underbite: two teeth poking up over the lower lip
c:paint({
  ".............m",
  "............m.",
  "m..tt..tt..m..",
  ".mmmmmmmmmm...",
}, 29, 20, { m = "umber", t = "#f2e4c0" })

c:ground(30, 56, 20, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-earthworm-bully.aseprite", PNG .. "creature-earthworm-bully.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
