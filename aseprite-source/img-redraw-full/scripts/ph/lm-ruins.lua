local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#d6c9b6")
local grey = GV.ramp("#968f96")
local mound = c:ellipse(31.5, 50.5, 25, 5)
local lp = c:rect(9, 30, 17, 52)
local lcap = c:rect(7, 26, 19, 30):cut(c:poly({ {7,26},{11,26},{7,29} }))
local ms = c:poly({ {27,40},{30,36},{32,38},{34,33},{37,40},{37,53},{27,53} })
local rp = c:rect(46, 22, 54, 52)
local rcap = c:rect(44, 17, 56, 22)
local slab = c:poly({ {20,48},{43,46},{44,51},{21,53} })
local p = c:build{
  { "mound", mound, "moss" },
  { "lpillar", lp, stone },
  { "lcap", lcap, grey },
  { "stub", ms, stone },
  { "rpillar", rp, stone },
  { "rcap", rcap, grey },
  { "slab", slab, grey },
}
-- column fluting
for _, x in ipairs({ 12, 14 }) do c:fill(c:rect(x, 32, x, 50), stone.shade) end
for _, x in ipairs({ 49, 51 }) do c:fill(c:rect(x, 24, x, 50), stone.shade) end
c:fill(c:rect(32, 41, 32, 51), stone.shade)
-- crack on stub
c:paint({ "u.", ".u", "u." }, 30, 41, { u = "umber" })
-- vines
c:fill(c:line({ {11,51},{13,47},{12,43},{14,39} }, 2), "#58a03e")
c:fill(c:line({ {51,35},{49,39},{50,43},{48,47} }, 2), "#58a03e")
c:paint({ "lll" }, 14, 44, { l = "#a4b86a" })
c:paint({ "lll" }, 46, 41, { l = "#a4b86a" })
local t = c:save(O .. "aseprite/ph/lm-ruins.aseprite", O .. "png/ph/lm-ruins.png")
print(GV.report(t))
