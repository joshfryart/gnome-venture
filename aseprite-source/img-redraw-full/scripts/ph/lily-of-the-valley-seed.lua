local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f1ece0")
local belly = c:ellipse(31.5, 39, 18, 15)
local neck = c:poly({ {26, 26}, {38, 26}, {35, 15}, {29, 15} })
local earL = c:poly({ {21, 10}, {31, 15}, {30, 19}, {25, 19} })
local earR = c:poly({ {43, 10}, {33, 15}, {34, 19}, {39, 19} })
local seed = c:ellipse(31.5, 41, 6.5, 6.5)
local twine = c:rrect(25, 20, 38, 23, 1)

local p = c:build{
  { "earL", earL, GV.ramp("#f4f0e0") },
  { "earR", earR, GV.ramp("#f4f0e0") },
  { "neck", neck, cloth },
  { "belly", belly, cloth, { stitch = { side = "lit" } } },
  { "seed", seed, GV.ramp("#f08a24") },
  { "twine", twine, GV.ramp("#dcb06a"), { gloss = false } },
}
-- bow loops and tails
c:part(c:ellipse(40.5, 19.5, 2.5, 2), GV.ramp("#dcb06a"), { flat = true })
c:fill(c:rect(40, 19, 41, 20), GV.ramp("#dcb06a").shade)
c:part(c:line({ {38, 23}, {40, 29} }, 2), GV.ramp("#dcb06a"), { flat = true })
c:part(c:line({ {36, 23}, {36, 29} }, 2), GV.ramp("#dcb06a"), { flat = true })
-- leaf sprig
c:fill(c:line({ {44, 33}, {46, 29} }, 2), "#2e5a2c")
c:part(c:ellipse(47.5, 27.5, 3, 2), "moss", { flat = true })
-- seam down fold
c:seam({ {31, 27}, {31, 33} })
c:spot(c:ellipse(29, 39, 1, 1), GV.ramp("#f08a24").gloss)

local t = c:save(O .. "aseprite/ph/lily-of-the-valley-seed.aseprite", O .. "png/ph/lily-of-the-valley-seed.png")
print(GV.report(t))
