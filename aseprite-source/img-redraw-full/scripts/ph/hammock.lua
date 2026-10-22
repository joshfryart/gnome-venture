local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local upper = c:ellipse(31.5, 22, 21, 14):cut(c:ellipse(31.5, 14, 24, 12)):clip(c:rect(0, 0, 63, 36))
upper:add(c:rrect(11, 21, 16, 27, 2)); upper:add(c:rrect(47, 21, 52, 27, 2))
local lower = c:ellipse(31.5, 30, 18, 13):cut(c:ellipse(31.5, 23, 21, 11)):clip(c:rect(0, 0, 63, 44)):cut(upper)
c:build{
  { "postL", c:rrect(8, 17, 12, 55, 2), GV.ramp("#6e3a22"), { gloss = false } },
  { "postR", c:rrect(51, 17, 55, 55, 2), GV.ramp("#6e3a22"), { gloss = false } },
  { "lower", lower, GV.ramp("#b6814d"), { gloss = false } },
  { "upper", upper, GV.ramp("#c4925f"), { gloss = { 18, 29 } } },
}
c:fill(c:line({ {12, 19}, {14, 22} }, 2), "#d9a660")
c:fill(c:line({ {51, 19}, {49, 22} }, 2), "#d9a660")
for _, x in ipairs({ 20, 26, 32, 38, 44 }) do
  for y = 0, 63 do if lower:has(x, y) and lower:has(x, y - 1) and lower:has(x, y + 1) then c:px(x, y, "#8a4f2a") end end
end
c:seam({ {17, 27}, {21, 31}, {27, 33}, {36, 33}, {42, 31}, {46, 27} })
c:button(12, 22)
c:ground(31.5, 56, 24, 1.5)
local t = c:save(O .. "aseprite/ph/hammock.aseprite", O .. "png/ph/hammock.png")
print(GV.report(t))
