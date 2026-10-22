-- ph/artichoke-seed : burlap sack tied with twine, artichoke badge
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sack: narrow neck flaring to a round belly, flat-ish bottom
local sack = c:ellipse(32, 41, 18, 13):add(c:poly({ {25, 20}, {40, 20}, {48, 34}, {16, 34} }))
sack:add(c:rrect(16, 42, 48, 54, 7))
-- tuft: ruffled gathered top flaring above the neck
local tuft = c:poly({ {28, 23}, {37, 23}, {45, 11}, {19, 11} })
for _, x in ipairs({ 22, 28, 35, 41 }) do tuft:add(c:ellipse(x, 11, 3, 2.5)) end
local twine = c:rect(24, 19, 40, 23)
local loops = c:ellipse(27, 24, 3, 2):add(c:ellipse(37, 24, 3, 2)):add(c:line({ {29, 25}, {26, 29} }, 2)):add(c:line({ {35, 25}, {38, 29} }, 2))
local badge = c:ellipse(32, 39, 8, 7):add(c:poly({ {25, 37}, {40, 37}, {32, 27} }))

local p = c:build{
  { "sack",  sack, GV.ramp("#d9b97a"), { stitch = { side = "lit" } } },
  { "tuft",  tuft, GV.ramp("#c9a96e") },
  { "twine", twine, GV.ramp("#8c4a1a"), { gloss = false } },
  { "loops", loops, GV.ramp("#8c4a1a"), { flat = true } },
  { "badge", badge, "moss", { gloss = { 27, 35 } } },
}
c:fill(c:rect(32, 22, 33, 22), "#5e2f1e") -- knot centre
-- tuft gathers: folds
c:fill(c:line({ {28, 14}, {30, 21} }, 1), "#9a6b3f")
c:fill(c:line({ {36, 14}, {34, 21} }, 1), "#9a6b3f")
-- artichoke scales: chevrons + centre vein
local V = "#2e5a2c"
c:fill(c:line({ {32, 31}, {32, 45} }, 1), V)
c:fill(c:line({ {26, 36}, {32, 41} }, 1), V); c:fill(c:line({ {38, 36}, {32, 41} }, 1), V)
c:fill(c:line({ {27, 41}, {32, 45} }, 1), V); c:fill(c:line({ {37, 41}, {32, 45} }, 1), V)
c:fill(c:line({ {29, 33}, {32, 36} }, 1), V); c:fill(c:line({ {35, 33}, {32, 36} }, 1), V)
-- patch stitches beside badge, side seam
c:seam({ {21, 31}, {21, 44} }, { free = true })
c:seam({ {43, 31}, {43, 44} }, { free = true })
c:seam({ {47, 30}, {47, 49} })

local t = c:save(O .. "aseprite/ph/artichoke-seed.aseprite", O .. "png/ph/artichoke-seed.png")
print(GV.report(t))
