local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea")
local pink = GV.ramp("#e46a9b", { gloss = "#f6b8cf" })
-- tall jar with square shoulders and a short neck
local jar = c:rrect(18, 26, 45, 54, 5)
jar:add(c:rrect(20, 22, 43, 30, 2))
local contents = c:rrect(21, 31, 42, 51, 4)
local p = c:build{
  { "jar", jar, glass },
  { "pink", contents, pink, { gloss = false, rim = false } },
  { "label", c:rect(19, 37, 44, 46), "cream", { gloss = false } },
  { "lid", c:rrect(17, 14, 46, 23, 3), "gold" },
}
-- radish rounds floating above the label
local function radish(x, y)
  c:paint({ ".pp.", "pwwp", "pwwp", ".pp." }, x, y, { p = "#ae2a2a", w = "#f6b8cf" })
end
radish(23, 32); radish(31, 32); radish(37, 47); radish(25, 47)
-- glass glint strip on the lit side
c:fill(c:rect(20, 27, 20, 34), "#e8f6fb")
-- label: tiny radish mark
c:paint({ "..g.g", "...g.", "..pp.", ".pppp", ".pppp", "..pp." }, 29, 38, { g = "#4a8a3e", p = "#dd3a2a" })
c:seam({ {18, 23}, {45, 23} })
c:button(17, 17)
c:ground(31.5, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/pickled-radishes.aseprite", O .. "png/ph/pickled-radishes.png")
print(GV.report(t))
