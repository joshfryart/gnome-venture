local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- full handle, then split with a jagged crack band
local full = c:line({ {18, 52}, {40, 11} }, 5)
local crack = c:poly({ {20, 28}, {25, 32}, {27, 29}, {30, 33}, {33, 31}, {38, 34},
                       {38, 38}, {33, 36}, {31, 39}, {28, 36}, {26, 39}, {20, 35} })
local upper = full:copy():clip(c:rect(0, 0, 63, 36)):cut(crack)
local lower = full:copy():clip(c:rect(0, 30, 63, 63)):cut(crack):shift(-2, 1)
-- chipped notches on the lower piece
lower:cut(c:poly({ {11, 44}, {16, 46}, {13, 48} }))

local blade = c:poly({ {34, 6}, {57, 6}, {55, 18}, {32, 18} })
local splinter = c:line({ {39, 41}, {43, 45} }, 2)

c:build{
  { "lower",  lower,  "wood" },
  { "upper",  upper,  "wood" },
  { "blade",  blade,  GV.ramp("#8c4a1a") },
  { "splinter", splinter, "wood", { flat = true } },
}
-- wood grain on the handle pieces
c:px(24, 43, GV.R.wood.shade); c:px(23, 45, GV.R.wood.shade)
c:px(33, 22, GV.R.wood.shade); c:px(32, 24, GV.R.wood.shade)
-- rivet where the handle meets the blade
c:paint({ "gg", "gs" }, 39, 11, { g = GV.R.gold.base, s = GV.R.gold.shade })
-- worn cutting edge along the bottom of the blade
c:line({ {33, 17}, {55, 17} }, 1):each(function(x, y) if blade:has(x, y) then c:px(x, y, "#c48a5a") end end)

local t = c:save(O .. "aseprite/ph/broken-garden-hoe.aseprite", O .. "png/ph/broken-garden-hoe.png")
print(GV.report(t))
