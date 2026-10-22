local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- broad straight spear blade, guard at its base
local blade = c:poly({ {34,37},{45,18},{47,7},{38,14},{26,32} })
local handleAll = c:poly({ {12,50},{19,56},{31,42},{24,36} }):closed(2)
local capBand = c:poly({ {9,49},{18,58},{22,53},{14,45} })
local cap = handleAll:copy():clip(capBand)
local handle = handleAll:copy():cut(capBand)
local guard = c:poly({ {34,39},{32,42},{23,37},{25,34} })

local steel = GV.ramp("#c9c5bc", { shade = "#8b8f96" })
local p = c:build{
  { "blade",  blade,  steel },
  { "handle", handle, "wood" },
  { "cap",    cap,    "#8a4f2a", { gloss = false } },
  { "guard",  guard,  "#5b6470", { gloss = false } },
}

-- centre groove and two depth ticks on the lower edge
c:fill(c:line({ {31,33}, {38,22}, {43,14} }, 1):clip(p.blade.m:shrink(1)), "#5b6470")
c:px(38, 27, "#5b6470"); c:px(41, 22, "#5b6470")

-- thread wrapped around the handle
c:seam({ {17,43}, {25,50} })

local t = c:save(O .. "aseprite/ph/hori-hori.aseprite", O .. "png/ph/hori-hori.png")
print(GV.report(t))
