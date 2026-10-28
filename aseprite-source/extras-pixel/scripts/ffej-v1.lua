-- Ffej v1 (Puzzles): Jeff's evil twin. Upside-down jigsaw piece (knob down, notch up), dark moss green,
-- arms spread wide with claw hands, eyepatch on the left eye, one angry brow, sly smirk. Moss family, darkened.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/ffej/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- body: square block, knob hanging off the bottom, notch bitten out of the top
local body = c:rrect(16, 13, 47, 41, 3)
body:add(c:rrect(26, 39, 37, 52, 2)); body:add(c:ellipse(31.5, 50, 7, 5.5))   -- knob, down
body:cut(c:rect(28, 10, 35, 17))                                                -- notch, up
body:cut(c:ellipse(31.5, 14, 6, 4.5))

-- arms: spread wide and raised a touch, three-fingered claw hands at the ends
local arms = c:line({ {18, 27}, {11, 21} }, 5); arms:add(c:line({ {45, 27}, {52, 21} }, 5))
arms:add(c:ellipse(10, 19, 3, 3)); arms:add(c:ellipse(53, 19, 3, 3))
arms:cut(body:shrink(1))

local p = c:build{
  { "arms", arms, GV.ramp("#3c8f4a"), { flat = true } },
  { "body", body, GV.ramp("#2f7a3e"), { stitch = { side = "lit" } } },
}

-- claws (umber nicks on the hands)
c:paint({ "u.u", ".u." }, 8, 15, { u = "umber" }); c:paint({ "u.u", ".u." }, 52, 15, { u = "umber" })

-- seams where the (upside-down) halves meet, button at the knob root
c:seam({ {19, 39}, {26, 39} }); c:seam({ {37, 39}, {44, 39} })
c:button(30, 43)

-- face: patch over the left eye, good eye on the right, one furious brow, a smirk that climbs on the right
c:eye(35, 24)
c:fill(c:rrect(22, 24, 28, 29, 1), "#2a1a10")
c:paint({ "u.......u", ".u.....u.", "..uuuuu.." }, 20, 21, { u = "umber" })          -- strap on both sides of the patch
c:paint({ "ssss", ".sss" }, 23, 25, { s = "#4a3a6a" })                                 -- patch cloth, dusk shade
c:paint({ "....uuu", "..uuu..", "uuu...." }, 33, 19, { u = "umber" })                  -- angry brow, slanting in
c:paint({ "..........u", ".........u.", "uuuuuuuuu.." }, 24, 33, { u = "umber" })      -- smirk: flat, hooks up at the right
c:paint({ "ff" }, 29, 36, { f = "#c8d77a" })                                           -- one glinting tooth

local t = c:save(OUT .. "ffej-v1.aseprite", OUT .. "ffej-v1.png")
print("ffej-v1", GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
