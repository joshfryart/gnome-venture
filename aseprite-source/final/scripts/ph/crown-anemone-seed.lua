local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jar = c:rrect(16, 26, 48, 51, 7):add(c:rrect(23, 19, 41, 28, 2))
c:build{
  { "jar", jar, GV.ramp("#c8ecdc"), { gloss = false } },
  { "lip", c:rrect(21, 18, 43, 22, 1), "#8fcbd8", { gloss = false } },
  { "cork", c:rrect(23, 10, 41, 19, 2), "#d9a660" },
  { "seed", c:ellipse(32, 39, 9, 7), "#e46a9b" },
}
c:px(35, 15, "#b07a45"); c:px(29, 17, "#b07a45"); c:px(38, 12, "#b07a45")
c:fill(c:rect(31, 27, 32, 32), "#2f5a2a")
c:fill(c:ellipse(35.5, 27.5, 2.5, 1.5), "#58a03e")
for _, x in ipairs({26, 32, 38}) do c:fill(c:rect(x - 1, 48, x, 49), "#8c4a1a") end
c:fill(c:rect(19, 31, 19, 37), "#fff1c8")
c:ground(32, 53, 15, 2.5)
local t = c:save(O .. "aseprite/ph/crown-anemone-seed.aseprite", O .. "png/ph/crown-anemone-seed.png")
print(GV.report(t))
