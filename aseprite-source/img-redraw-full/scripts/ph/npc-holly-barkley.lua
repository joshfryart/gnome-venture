local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local brown = GV.ramp("#a5663a")
local jacket = c:ellipse(39.5, 101, 34, 25)
local scarf = c:line({ {28,79}, {34,82}, {40,83}, {46,82}, {52,79} }, 5)
local tail = c:poly({ {47,80}, {54,97}, {44,95} })
local p = c:build{
  { "bg", c:ellipse(40, 50, 36, 36), "#b0bc66", { gloss = false } },
  { "jacket", jacket, "gold", { stitch = { side = "lit" } } },
  { "tail", tail, "#7a5cc0" },
  { "scarf", scarf, "#7a5cc0" },
  { "earL", c:ellipse(23, 35, 11, 11), brown },
  { "earR", c:ellipse(57, 35, 11, 11), brown },
  { "pinkL", c:ellipse(23, 35, 6, 6), "#f6b8cf", { contact = false } },
  { "pinkR", c:ellipse(57, 35, 6, 6), "#f6b8cf", { contact = false } },
  { "head", c:ellipse(40, 53, 21, 19), brown },
  { "muzzle", c:ellipse(40, 62, 12, 9), "#dcb06a" },
  { "nose", c:ellipse(40, 58, 3.5, 2.5), "#d9667f", { flat = true } },
}
-- collar V on jacket
c:fill(c:poly({ {30,86}, {40,96}, {50,86}, {47,86}, {40,92}, {33,86} }):clip(p.jacket.m), "#b8661a")
c:seam({ {49,85}, {51,94} })
c:button(42, 80)
c:eye(28, 46); c:eye(47, 46)
local W = "#2a1a10"
c:paint({ "w........", ".wwwwwwww" }, 15, 61, { w = W })
c:paint({ "........w", "wwwwwwww." }, 56, 61, { w = W })
c:paint({ "ww.......", "..www....", ".....wwww" }, 17, 64, { w = W })
c:paint({ ".......ww", "....www..", "wwww....." }, 55, 64, { w = W })
c:paint({ "w.....w", ".wwwww." }, 37, 65, { w = W })
local t = c:save(O .. "aseprite/ph/npc-holly-barkley.aseprite", O .. "png/ph/npc-holly-barkley.png")
print(GV.report(t))
