local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 39, 20, 14)
local foot = c:rrect(21, 49, 42, 55, 2)
local lid = c:ellipse(31.5, 24, 17, 5):add(c:rrect(14, 24, 49, 28, 2))
local dome = c:ellipse(31.5, 22, 12, 5):cut(c:rect(0, 24, 63, 63))
lid:add(dome)
local knob = c:ellipse(31.5, 15, 3.5, 3.5)
local p = c:build{
  { "foot", foot, GV.ramp("#2f6290") },
  { "body", body, "water" },
  { "lid",  lid,  GV.ramp("#5aa8c8") },
  { "knob", knob, "gold", { gloss = false } },
}
c:seam({ {16, 29}, {47, 29} })
-- painted gardenia bloom on the belly
local cream = "#f4f0e0"
local petals = c:mask()
petals:add(c:ellipse(31.5, 35, 2.5, 3))
petals:add(c:ellipse(27, 39, 3, 2.5))
petals:add(c:ellipse(36, 39, 3, 2.5))
petals:add(c:ellipse(28.5, 44, 2.5, 2.5))
petals:add(c:ellipse(34.5, 44, 2.5, 2.5))
c:fill(petals, cream)
c:fill(petals:edge(), "#c9c5bc")
c:fill(c:rect(30, 39, 33, 41), "#e8a317")
c:px(30, 39, "#f5cf6a")
-- leaves
c:fill(c:ellipse(22, 45, 3, 1.5), "#58a03e")
c:fill(c:ellipse(41, 45, 3, 1.5), "#58a03e")
c:px(20, 45, "#7ab55c"); c:px(39, 45, "#7ab55c")
-- knob gloss
c:px(30, 13, "#fff1c8"); c:px(29, 14, "#fff1c8")
c:ground(31.5, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/wild-gardenia-seed.aseprite", O .. "png/ph/wild-gardenia-seed.png")
print(GV.report(t))
