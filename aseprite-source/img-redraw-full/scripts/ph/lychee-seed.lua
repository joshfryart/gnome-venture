local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- paper cone, point down, top gathered into a pinched twist
local cone   = c:poly({ {11, 26}, {53, 26}, {32, 57} })
local gather = c:poly({ {14, 27}, {50, 27}, {37, 19}, {27, 19} })
local knot   = c:rrect(28, 14, 35, 20, 1)
local ruff   = c:poly({ {22, 8}, {26, 10}, {29, 8}, {32, 11}, {35, 8}, {38, 10}, {42, 8}, {37, 15}, {27, 15} })
local stem   = c:rect(39, 9, 40, 14)
local leafm  = c:ellipse(43.5, 7.5, 4, 2.5)
local seed   = c:ellipse(31.5, 39, 6, 6)
c:build{
  { "cone",   cone,   GV.ramp("#f1ece0") },
  { "gather", gather, GV.ramp("#e6dcc4"), { gloss = false } },
  { "stem",   stem,   GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf",   leafm,  GV.ramp("#58a03e"), { flat = true } },
  { "ruff",   ruff,   GV.ramp("#dcb06a"), { gloss = false } },
  { "knot",   knot,   GV.ramp("#dcb06a"), { gloss = false } },
  { "seed",   seed,   GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
-- gather pleats
c:fill(c:line({ {24, 26}, {29, 20} }, 1), "#c9a96e"); c:fill(c:line({ {40, 26}, {35, 20} }, 1), "#c9a96e")
c:seam({ {14, 30}, {31, 55} })
c:fill(c:line({ {44, 31}, {38, 44} }, 1), "#dcb06a")

local t = c:save(O .. "aseprite/ph/lychee-seed.aseprite", O .. "png/ph/lychee-seed.png")
print(GV.report(t))
