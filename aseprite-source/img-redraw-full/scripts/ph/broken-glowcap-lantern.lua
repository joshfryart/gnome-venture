local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d")
-- hang loop + stem
local hang = c:rrect(29, 9, 35, 17, 1)
local loop = c:ellipse(32, 9, 4, 3):cut(c:ellipse(32, 9, 2, 1))
hang:add(loop)
-- glass chamber with chipped lower-right corner
local glass = c:rrect(22, 21, 42, 51, 4)
glass:cut(c:poly({ {38, 52}, {43, 52}, {43, 44} }))
-- top plate, bottom plate with a chunk missing at lower right
local top = c:rrect(19, 15, 45, 22, 3)
local bot = c:rrect(19, 50, 45, 56, 3)
bot:cut(c:poly({ {39, 57}, {46, 57}, {46, 50}, {43, 50} }))
local p = c:build{
  { "hang",  hang,  "#c4925f", { flat = true } },
  { "glass", glass, "gold" },
  { "orb",   c:ellipse(32, 36, 6.5, 6.5), "#e8a317" },
  { "top",   top,   wood },
  { "bot",   bot,   wood },
  -- loose chips drifting off
  { "chipR", c:poly({ {47, 50}, {52, 52}, {49, 56} }), wood, { flat = true } },
  { "chipL", c:poly({ {9, 42}, {14, 44}, {10, 47} }), "gold", { flat = true } },
}
-- wood grain seams on plates
c:seam({ {22, 18}, {42, 18} })
c:seam({ {22, 53}, {38, 53} })
-- zig-zag crack through the glass
c:line({ {30, 23}, {35, 29}, {29, 35}, {36, 43}, {32, 49} }, 2):clip(p.glass.m)
c:fill(c:line({ {30, 23}, {35, 29}, {29, 35}, {36, 43}, {32, 49} }, 2):clip(p.glass.m), "#2a1a10")
-- small crack in the top plate
c:fill(c:line({ {30, 17}, {31, 20} }, 1), "#4a2c1a")
local t = c:save(O .. "aseprite/ph/broken-glowcap-lantern.aseprite", O .. "png/ph/broken-glowcap-lantern.png")
print(GV.report(t))
