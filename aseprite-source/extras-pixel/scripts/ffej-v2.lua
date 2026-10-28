-- Ffej v2 (Puzzles): Jeff's evil twin, caught in the act. Upside-down jigsaw piece (knob down, notch up),
-- dark moss green. Left arm raised holding a stolen bright-green chunk of Jeff, right hand on hip,
-- eyepatch on the right eye, one angry brow on the left, smirk hooking up on the left, a scar seam on the knob.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/ffej/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body: slightly taller block, knob hanging off the bottom a little to the right (a lean), notch bitten out of the top
local body = c:rrect(18, 16, 47, 42, 3)
body:add(c:rrect(28, 40, 39, 51, 2)); body:add(c:ellipse(33.5, 49, 7, 5.5))   -- knob, down and off-centre
body:cut(c:rect(29, 12, 36, 20))                                                -- notch, up
body:cut(c:ellipse(32.5, 17, 6, 4.5))

-- left arm: up and out, holding the loot. right arm: bent, fist on the hip
local arms = c:line({ {20, 26}, {13, 17} }, 5); arms:add(c:ellipse(12, 15, 3, 3))
arms:add(c:line({ {45, 30}, {53, 34}, {50, 40} }, 5)); arms:add(c:ellipse(49, 40, 3, 3))
arms:cut(body:shrink(1))

-- loot: a small piece of Jeff (bright green, one knob) pinched in the raised hand
local loot = c:rrect(10, 7, 19, 13, 1); loot:add(c:ellipse(20, 10, 3, 2.5))

c:build{
  { "arms", arms, GV.ramp("#3c8f4a"), { flat = true } },
  { "body", body, GV.ramp("#2f7a3e"), { stitch = { side = "lit" } } },
  { "loot", loot, GV.ramp("#1fb86b"), { flat = true, contact = false } },
}

-- claw nicks on both hands
c:paint({ "u.u", ".u." }, 10, 16, { u = "umber" }); c:paint({ "uu", ".u" }, 47, 42, { u = "umber" })

-- seams on the halves, button at the knob root, and a crooked scar stitch down the knob
c:seam({ {21, 40}, {27, 40} }); c:seam({ {40, 40}, {45, 40} })
c:button(32, 44)
c:seam({ {37, 48}, {35, 52}, {37, 56} })

-- face: good eye on the left under a furious brow, patch over the right eye, smirk hooking up on the left
c:eye(24, 26)
c:paint({ "uuu....", "..uuu..", "....uuu" }, 22, 21, { u = "umber" })                  -- angry brow, slanting in
c:fill(c:rrect(35, 26, 41, 31, 1), "#2a1a10")
c:paint({ "u.......u", ".u.....u.", "..uuuuu.." }, 33, 23, { u = "umber" })          -- strap
c:paint({ "ssss", ".sss" }, 36, 27, { s = "#4a3a6a" })                                 -- patch cloth, dusk shade
c:paint({ "u..........", ".u.........", "..uuuuuuuu." }, 23, 34, { u = "umber" })      -- smirk, hooks up at the left
c:paint({ "ff" }, 34, 37, { f = "#c8d77a" })                                           -- one glinting tooth

local t = c:save(OUT .. "ffej-v2.aseprite", OUT .. "ffej-v2.png")
print("ffej-v2", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
