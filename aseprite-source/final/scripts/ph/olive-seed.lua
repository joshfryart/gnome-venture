local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lid propped open behind the tin (hinged at the back)
local lid = c:poly({ {14, 11}, {51, 11}, {53, 29}, {12, 29} })
local lidRim = c:rect(12, 26, 52, 29):clip(lid)
local tab = c:poly({ {44, 6}, {50, 6}, {52, 12}, {42, 12} })
local inside = c:rect(14, 28, 50, 33)
local seed = c:ellipse(30, 32, 8, 7)
local leaf = c:poly({ {38, 30}, {42, 23}, {48, 20}, {47, 26}, {42, 31} })
local tin = c:rrect(11, 33, 53, 55, 3)

local p = c:build{
  { "tab", tab, "#2e5a2c", { flat = true } },
  { "lid", lid, "#dcd4c4" },
  { "rim", lidRim, "#58a03e", { gloss = false } },
  { "inside", inside, "#5b6470", { gloss = false, rim = false } },
  { "leaf", leaf, "#58a03e" },
  { "seed", seed, "#58a03e" },
  { "tin", tin, "#c9c5bc" },
}
c:fill(c:rect(37, 29, 38, 31), "#2e5a2c")
-- hinge line at the back of the tin
c:seam({ {14, 30}, {50, 30} }, { free = true })
-- front band and latch
c:seam({ {14, 37}, {50, 37} })
c:button(30, 34)
c:ground(32, 56, 20, 1.5)

local t = c:save(O .. "aseprite/ph/olive-seed.aseprite", O .. "png/ph/olive-seed.png")
print(GV.report(t))
