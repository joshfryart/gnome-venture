local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local moss = GV.ramp("#6a9a3a", { gloss = "#c8d77a", deep = "#2f5a2a" })
c:build{
  { "mound", c:ellipse(32, 47, 19, 5), "#7a4a1f", { gloss = false } },
  { "top",   c:ellipse(32, 46, 15, 3.5), "#9a6b3f", { gloss = false } },
  { "stem",  c:rect(30, 36, 33, 47):add(c:rect(29, 45, 34, 47)), GV.ramp("#b07a45", { rim = "#d9a660" }), { gloss = false } },
  { "bush",  c:ellipse(32, 30, 8.5), moss },
  { "puffL", c:ellipse(27.5, 34.5, 6), moss, { gloss = false } },
  { "puffR", c:ellipse(36.5, 34, 6), GV.ramp("#7ab55c", { gloss = "#c8d77a", deep = "#2f5a2a" }), { gloss = false } },
}
local t = c:save(O .. "aseprite/ph/stage-nut-2.aseprite", O .. "png/ph/stage-nut-2.png")
print(GV.report(t))
