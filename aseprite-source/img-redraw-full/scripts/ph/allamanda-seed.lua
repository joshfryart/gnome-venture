local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cream = GV.ramp("#f1ece0")
local fold  = GV.ramp("#dcb06a")

-- cone pointing down, rounded tip
local cone = c:poly({ {16, 27}, {49, 27}, {34, 50}, {31, 50} })
cone:add(c:ellipse(32.5, 49, 2, 2))
-- pinched twist neck, flares out at top like twisted paper
local neck = c:poly({ {28, 19}, {37, 19}, {35, 23}, {37, 27}, {28, 27}, {30, 23} })
neck:add(c:poly({ {24, 16}, {29, 18}, {31, 22}, {26, 21} }))
neck:add(c:poly({ {41, 16}, {36, 18}, {34, 22}, {39, 21} }))

local stem = c:line({ {32, 20}, {32, 14} }, 3)
local leaf = c:poly({ {34, 15}, {37, 11}, {43, 11}, {40, 15}, {36, 17} })

local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, GV.ramp("#6a9a3a"), { gloss = false } },
  { "neck", neck, cream, { gloss = false } },
  { "cone", cone, cream, { stitch = { side = "lit" } } },
  { "flap", c:poly({ {16, 27}, {21, 27}, {41, 45}, {38, 47} }), fold, { gloss = false, light = cone } },
  { "window", c:ellipse(32.5, 37, 5.5, 5.5), "moss" },
  { "band", c:rect(16, 25, 49, 28), "gold", { gloss = false } },
}

-- twist creases on the neck
c:paint({ "f..", ".f.", "..f" }, 30, 19, { f = "#dcb06a" })
c:paint({ "..f", ".f.", "f.." }, 33, 22, { f = "#dcb06a" })
-- seeds inside the window
c:spot(c:ellipse(31, 35, 1, 1.5)); c:spot(c:ellipse(35, 38, 1, 1.5))
c:seam({ {18, 29}, {47, 29} })

local t = c:save(O .. "aseprite/ph/allamanda-seed.aseprite", O .. "png/ph/allamanda-seed.png")
print(GV.report(t))
