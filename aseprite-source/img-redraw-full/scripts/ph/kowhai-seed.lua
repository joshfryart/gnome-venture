local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pot = c:ellipse(31.5, 39, 18, 14):add(c:rrect(17, 26, 46, 52, 6))
local band = c:rect(0, 45, 63, 47):clip(pot)
local lid = c:ellipse(31.5, 24, 15, 6):cut(c:rect(0, 25, 63, 63))
lid:add(c:rrect(15, 23, 48, 27, 2))
local p = c:build{
  { "pot",  pot,  "#f1ece0" },
  { "band", band, "petal", { flat = true } },
  { "lid",  lid,  "#f4f0e0", { light = pot:copy():add(lid) } },
  { "knob", c:ellipse(31.5, 15, 3.5, 3), "petal" },
  { "seed", c:ellipse(30.5, 38, 7, 7), "petal" },
}
c:part(c:line({ {33,31},{36,28} }, 2), GV.ramp("#2f5a2a", {base="#3f7a34"}), { flat = true })
c:part(c:poly({ {36,30},{40,26},{45,26},{43,30},{38,32} }), GV.ramp("#58a03e"), { flat = true })
c:seam({ {16,27}, {47,27} })
local t = c:save(O .. "aseprite/ph/kowhai-seed.aseprite", O .. "png/ph/kowhai-seed.png")
print(GV.report(t))
