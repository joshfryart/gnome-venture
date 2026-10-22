local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local green = GV.ramp("#58a03e")
local crown = c:ellipse(40, 25, 20, 15):cut(c:rect(0, 26, 79, 99))
local brim = c:ellipse(40, 27, 33, 4.5)
local band = crown:copy():clip(c:rect(0, 20, 79, 24))
crown:cut(band)
local p = c:build{
  { "back",  c:ellipse(40, 52, 33), "#f6b8cf", { gloss = false } },
  { "body",  c:ellipse(40, 99, 33, 26), "#dd3a2a" },
  { "apron", c:poly({ {27, 80}, {54, 80}, {59, 100}, {21, 100} }), "#f8eed2", { gloss = false } },
  { "face",  c:ellipse(40, 54, 27, 18), green },
  { "chin",  c:ellipse(40, 62, 17, 8), "#b0bc66", { gloss = false } },
  { "bumpL", c:ellipse(26, 36, 9), green },
  { "bumpR", c:ellipse(54, 36, 9), green, { gloss = false } },
  { "ballL", c:ellipse(26, 38, 6), "#f8eed2", { flat = true } },
  { "ballR", c:ellipse(54, 38, 6), "#f8eed2", { flat = true } },
  { "crown", crown, "#f5cf6a" },
  { "band",  band, "#a5663a", { gloss = false } },
  { "brim",  brim, "#d9a660", { stitch = true, gloss = false } },
}
-- apron straps and collar V
c:line({ {29, 76}, {32, 81} }, 2); c:fill(c:line({ {29, 75}, {32, 80} }, 2), "#f8eed2")
c:fill(c:line({ {51, 75}, {48, 80} }, 2), "#f8eed2")
c:seam({ {19, 22}, {61, 22} })
c:button(38, 20)
c:eye(24, 36); c:eye(52, 36)
c:fill(c:rect(36, 52, 37, 53), "#2f5a2a"); c:fill(c:rect(43, 52, 44, 53), "#2f5a2a")
c:fill(c:line({ {26, 61}, {33, 65}, {47, 65}, {54, 61} }, 2), "#2f5a2a")
local t = c:save(O .. "aseprite/ph/npc-hazel-dewberry.aseprite", O .. "png/ph/npc-hazel-dewberry.png")
print(GV.report(t))
