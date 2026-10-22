local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy rice dome
local rice = c:ellipse(31.5, 30, 19, 14)
rice:add(c:ellipse(22, 22, 7, 6)); rice:add(c:ellipse(32, 18, 8, 6)); rice:add(c:ellipse(42, 22, 7, 6))
rice:cut(c:rect(0, 31, 63, 63))
-- bowl
local bowl = c:ellipse(31.5, 30, 22, 19):cut(c:rect(0, 0, 63, 29))
local foot = c:rrect(23, 46, 40, 51, 2)
local band = c:rrect(9, 28, 54, 32, 2)
c:build{
  { "foot", foot, GV.ramp("#d6c9b6") },
  { "bowl", bowl, GV.ramp("#f4f0e0"), { gloss = { 16, 36 } } },
  { "rice", rice, GV.ramp("#f1ece0"), { gloss = { 22, 20 } } },
  { "band", band, GV.ramp("#d6c9b6"), { gloss = false } },
}
-- grain ticks
local g = "#d6c9b6"
for _, p in ipairs({ {28,24},{38,26},{18,27},{31,29},{45,28},{26,18},{40,18},{34,24},{21,24} }) do
  c:px(p[1], p[2], g); c:px(p[1]+1, p[2], g)
end
-- confetti: egg, pea, carrot
c:part(c:ellipse(24, 23, 3, 3), GV.ramp("#dcb06a"), { flat = true })
c:part(c:ellipse(35, 20, 3, 3), "leaf", { flat = true })
c:part(c:ellipse(43.5, 25.5, 2.5, 2.5), "gold", { flat = true })
c:part(c:ellipse(30, 27, 2, 1.5), "leaf", { flat = true })
c:part(c:ellipse(17.5, 28, 2, 1.5), GV.ramp("#dcb06a"), { flat = true })
c:seam({ {11, 30}, {52, 30} })
local t = c:save(O .. "aseprite/ph/egg-fried-rice.aseprite", O .. "png/ph/egg-fried-rice.png")
print(GV.report(t))
