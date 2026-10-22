local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wood = GV.ramp("#b07a45", { rim = "#d9a660" })
local p = c:build{
  { "shaft", c:line({ {15, 49}, {35, 29} }, 5), wood },
  { "foot",  c:line({ {13, 51}, {16, 48} }, 5), "#8a4f2a" },
  { "orb",   c:ellipse(43, 20, 8.5), "water" },
  { "collar", c:line({ {32, 24}, {39, 31} }, 4), "#b8893f" },
}
c:seam({ {27, 34}, {31, 38} }, { free = false })
c:seam({ {29, 32}, {33, 36} }, { free = false })
c:paint({ ".c.", "ccc", ".c." }, 47, 14, { c = "#f8eed2" })
local t = c:save(O .. "aseprite/ico/ico-staff.aseprite", O .. "png/ico/ico-staff.png")
print(GV.report(t))
