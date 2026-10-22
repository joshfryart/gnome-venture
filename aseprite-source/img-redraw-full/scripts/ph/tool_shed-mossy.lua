local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local moss = "moss"
local moss2 = GV.ramp("#58a03e")
c:build{
  { "walls", c:rect(14, 30, 49, 48), GV.ramp("#a5663a"), { gloss = false } },
  { "door", c:rect(25, 36, 38, 48), GV.ramp("#8c4a1a"), { gloss = false, rim = false } },
  { "roof", c:poly({ {11, 31}, {18, 15}, {46, 15}, {53, 31} }), GV.ramp("#968f96") },
  { "eave", c:rrect(10, 29, 54, 32, 1), GV.ramp("#6a6070"), { gloss = false } },
  { "toolL", c:line({ {16, 48}, {14, 31} }, 2), GV.ramp("#8a4f2a"), { flat = true } },
  { "bladeL", c:rrect(12, 27, 17, 31, 1), "stone", { flat = true } },
  { "toolR", c:line({ {47, 48}, {50, 31} }, 2), GV.ramp("#8a4f2a"), { flat = true } },
  { "bladeR", c:rrect(47, 27, 53, 30, 1), "stone", { flat = true } },
  { "m1", c:ellipse(19.5, 17, 5, 3.5):add(c:ellipse(15.5, 21, 3, 3)), moss },
  { "m2", c:ellipse(32, 15, 6, 3.5), moss2 },
  { "m3", c:ellipse(44, 19, 4.5, 3.5):add(c:ellipse(48, 23, 3, 3)), moss },
  { "m4", c:ellipse(19, 46, 5, 3):add(c:rect(14, 37, 16, 46)), moss2, { gloss = false } },
  { "m5", c:ellipse(43, 46, 5, 3):add(c:rect(47, 39, 49, 46)), moss, { gloss = false } },
}
c:fill(c:rect(17, 37, 23, 37), "#8a4f2a"); c:fill(c:rect(40, 37, 46, 37), "#8a4f2a")
c:fill(c:rect(17, 42, 23, 42), "#8a4f2a"); c:fill(c:rect(40, 42, 46, 42), "#8a4f2a")
c:fill(c:line({ {26, 37}, {36, 46} }, 2), "#44281c")
c:fill(c:line({ {36, 37}, {26, 46} }, 2), "#44281c")
c:fill(c:rect(31, 37, 32, 47), "#44281c")
c:ground(31.5, 52, 22, 2)
local t = c:save(O .. "aseprite/ph/tool_shed-mossy.aseprite", O .. "png/ph/tool_shed-mossy.png")
print(GV.report(t))
