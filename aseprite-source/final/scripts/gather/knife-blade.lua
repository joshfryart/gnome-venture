local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- single-edge wedge blade, point upper left
local blade = c:poly({ {11, 11}, {35, 29}, {30, 37}, {15, 26} })
local bevel = blade:copy():clip(c:poly({ {9, 9}, {37, 28}, {35, 31}, {12, 15} }))
local guard = c:line({ {29, 38}, {36, 29} }, 4)
local handle = c:line({ {35, 37}, {46, 45} }, 7)
handle:add(c:ellipse(46.5, 45.5, 5, 5))

local p = c:build{
  { "blade",  blade,  GV.ramp("#d7dee3") },
  { "bevel",  bevel,  GV.ramp("#f4f8fa"), { flat = true, contour = false, contact = false } },
  { "handle", handle, "wood" },
  { "guard",  guard,  GV.ramp("#8c6a28"), { flat = true } },
}
-- spine line along the lower edge
c:line({ {16, 27}, {29, 36} }, 1):each(function(x, y) if p.blade.m:has(x, y) and not p.guard.m:has(x, y) then c:px(x, y, "#a9b6bd") end end)
-- pale rivet on the guard
c:paint({ ".r.", "rrr", ".r." }, 31, 32, { r = "#f4f8fa" })
c:seam({ {38, 40}, {48, 47} })

local t = c:save(O .. "aseprite/gather/knife-blade.aseprite", O .. "png/gather/knife-blade.png")
print(GV.report(t))
