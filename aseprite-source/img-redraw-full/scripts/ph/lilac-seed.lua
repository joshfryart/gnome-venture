local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local belly = c:ellipse(31.5, 40, 17, 13)
local foot = c:rrect(22, 50, 41, 55, 1)
local band = c:rect(10, 37, 53, 41):clip(belly)
local lid = c:rrect(19, 24, 44, 30, 3)
local knob = c:ellipse(31.5, 21, 4, 3.5)
local seed = c:ellipse(47, 18, 6, 6)
local leaf = c:ellipse(52, 8, 3.5, 2)

c:build{
  { "belly", belly, GV.ramp("#7b66b4", { gloss = "#a894dc" }) },
  { "foot",  foot,  "#3e2f66" },
  { "band",  band,  "#e46a9b", { gloss = false } },
  { "lid",   lid,   "#f6b8cf" },
  { "knob",  knob,  "#f6b8cf" },
  { "seed",  seed,  "#f08a24" },
  { "stem",  c:line({ {47, 12}, {48, 9} }, 2), "#2f5a2a", { flat = true } },
  { "leaf",  leaf,  "#58a03e", { flat = true } },
}
c:seam({ {22, 30}, {42, 30} })
c:button(23, 25)
c:ground(31.5, 57, 14, 1.5)
local t = c:save(O .. "aseprite/ph/lilac-seed.aseprite", O .. "png/ph/lilac-seed.png")
print(GV.report(t))
