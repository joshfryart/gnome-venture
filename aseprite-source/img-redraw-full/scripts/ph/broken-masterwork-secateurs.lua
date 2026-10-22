local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- blades: curved gold hooks forming an upward V; left one slightly bent
local bladeL = c:poly({ {28, 33}, {33, 31}, {24, 19}, {19, 12}, {15, 11}, {16, 16}, {21, 24} })
local bladeR = c:poly({ {31, 31}, {36, 33}, {43, 22}, {47, 14}, {46, 10}, {42, 12}, {38, 20} })
-- handles: wooden grips, the right one snapped in two
local handleL = c:line({ {29, 35}, {21, 50} }, 6)
local handleR = c:line({ {34, 35}, {38, 42} }, 6)
local handleR2 = c:line({ {40, 46}, {43, 51} }, 6)
local shard = c:poly({ {47, 39}, {51, 38}, {52, 42}, {48, 43} })
local pivot = c:ellipse(32, 33, 3.5, 3.5)

local p = c:build{
  { "bladeL", bladeL, "gold" },
  { "bladeR", bladeR, "gold" },
  { "handleL", handleL, GV.ramp("#b6814d") },
  { "handleR", handleR, GV.ramp("#b6814d") },
  { "handleR2", handleR2, GV.ramp("#b6814d") },
  { "shard", shard, GV.ramp("#b6814d"), { flat = true } },
  { "pivot", pivot, GV.ramp("#b07a10") },
}
-- crack through the left blade
c:fill(c:line({ {20, 17}, {23, 20}, {21, 23} }, 1):clip(p.bladeL.m), "#2a1a10")
-- jagged break edges on the right handle
c:paint({ "k.k", ".k." }, 37, 42, { k = "#2a1a10" })
c:paint({ ".k.", "k.k" }, 40, 45, { k = "#2a1a10" })
-- chip nick on the left handle
c:fill(c:line({ {23, 44}, {21, 47} }, 1):clip(p.handleL.m), "#2a1a10")
-- pivot glint and screw slot
c:px(31, 32, "#fff1c8")
c:px(32, 34, "#5e2f1e"); c:px(33, 34, "#5e2f1e")

local t = c:save(O .. "aseprite/ph/broken-masterwork-secateurs.aseprite", O .. "png/ph/broken-masterwork-secateurs.png")
print(GV.report(t))
