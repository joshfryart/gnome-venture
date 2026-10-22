local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local whole = c:ellipse(31.5, 39, 23, 16.5)
local outer = whole:copy()
local mid = c:ellipse(31.5, 39, 15, 16.5)
local ctr = c:ellipse(31.5, 39, 7, 16)
local stem = c:poly({ {28, 24}, {29, 15}, {32, 11}, {36, 12}, {34, 16}, {35, 24} })
local vine = c:line({ {35, 15}, {39, 11}, {44, 10}, {48, 12}, {49, 16}, {47, 18} }, 3)

c:build{
  { "vine", vine, GV.ramp("#58a03e"), { flat = true } },
  { "outer", outer, GV.ramp("#c76a1c") },
  { "mid", mid, GV.ramp("#e8892a"), { light = whole } },
  { "ctr", ctr, GV.ramp("#f4a24a"), { light = whole } },
  { "stem", stem, GV.ramp("#2e5a2c", { rim = "#58a03e" }) },
}

local t = c:save(O .. "aseprite/ico/ico-pumpkin.aseprite", O .. "png/ico/ico-pumpkin.png")
print(GV.report(t))
