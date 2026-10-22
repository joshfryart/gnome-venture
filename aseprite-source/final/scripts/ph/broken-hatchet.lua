local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:line({ {19, 51}, {35, 16} }, 5)
-- quarter-moon blade: curved cutting edge on the right
local blade = c:ellipse(43, 20, 8, 12):cut(c:rect(0, 0, 42, 63))
blade:add(c:poly({ {31, 12}, {37, 11}, {44, 8}, {44, 33}, {38, 24}, {31, 20} }))
blade:cut(c:ellipse(39, 3, 5, 5)):cut(c:ellipse(37, 33, 4, 6))   -- concave beard
blade:cut(c:poly({ {46, 30}, {52, 25}, {52, 35} }))       -- chipped corner
local edge = c:ellipse(43, 20, 8, 12):cut(c:ellipse(42, 20, 6, 10)):cut(c:rect(0, 0, 45, 63)):clip(blade)
local wrap = handle:copy():clip(c:rect(0, 44, 63, 47))
local spl1 = c:line({ {40, 45}, {45, 42} }, 2)
local spl2 = c:line({ {12, 39}, {16, 43} }, 2)

local wood = GV.ramp("#b6814d", { gloss = "#f0d49a" })
local p = c:build{
  { "handle", handle, wood },
  { "wrap", wrap, GV.ramp("#5e2f1e"), { contour = false, gloss = false } },
  { "blade", blade, GV.ramp("#8c4a1a") },
  { "edge", edge, GV.ramp("#d9a660"), { flat = true, contour = false } },
  { "spl1", spl1, wood, { flat = true } },
  { "spl2", spl2, wood, { flat = true } },
}
-- zig-zag crack across the shaft
c:paint({
  "k....",
  ".k...",
  "..k..",
  ".k...",
  "..k..",
  "...k.",
}, 25, 30, { k = "#2a1a10" })
c:px(22, 37, "#2a1a10"); c:px(31, 33, "#2a1a10")
c:seam({ {16, 45}, {24, 45} })

local t = c:save(O .. "aseprite/ph/broken-hatchet.aseprite", O .. "png/ph/broken-hatchet.png")
print(GV.report(t))
