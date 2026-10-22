local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

-- shaft: diagonal pole from lower left to the head
local shaft = c:line({ {22, 53}, {40, 15} }, 5)
-- stone head: round pebble cap
local head = c:ellipse(42, 11, 7, 6.5)
-- cord hangs off the shaft to the left, bead below
local cord = c:line({ {30, 37}, {25, 40}, {21, 43} }, 2)
local bead = c:ellipse(18.5, 46.5, 3.5, 3.5)

local p = c:build{
  { "shaft", shaft, GV.ramp("#b6814d", { rim = "#d9a660" }) },
  { "cord",  cord,  "#968f96", { flat = true } },
  { "bead",  bead,  GV.ramp("#968f96"), { gloss = { 17, 44 }, cres = 2, deep = 1 } },
  { "head",  head,  GV.ramp("#d6c9b6", { shade = "#8b8f96" }), { pale = true, gloss = { 38, 7 } } },
}
-- thread-gold wrap just under the head
c:seam({ {35, 19}, {41, 22} })
c:seam({ {34, 22}, {40, 25} })
c:ground(31.5, 57, 15, 2)
local t = c:save(O .. "aseprite/ph/wayfarer-s-staff.aseprite", O .. "png/ph/wayfarer-s-staff.png")
print(GV.report(t))
