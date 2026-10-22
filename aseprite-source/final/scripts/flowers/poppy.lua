-- flowers/poppy : top-down red poppy, four round petals, dark centre
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 31.5
local low = GV.ramp("#ae2a2a")
local R = GV.R.red

c:build{
  { "lowL", c:ellipse(22.5, 40.5, 14), low, { gloss = false } },
  { "lowR", c:ellipse(40.5, 40.5, 14), low, { gloss = false } },
  { "upR",  c:ellipse(40.5, 22.5, 14), "red", { gloss = false } },
  { "upL",  c:ellipse(22.5, 22.5, 14), "red", { gloss = false } },
}
-- petal creases
local cr = R.deep
c:fill(c:line({ {19, 15}, {18, 20}, {19, 26} }, 1), R.shade)
c:fill(c:line({ {44, 15}, {45, 20}, {44, 26} }, 1), R.shade)
c:fill(c:line({ {17, 39}, {21, 44}, {25, 46} }, 1), cr)
c:fill(c:line({ {46, 39}, {42, 44}, {38, 46} }, 1), cr)
-- enamel sheen on the upper-left petal
c:fill(c:line({ {13, 19}, {14, 16}, {17, 13}, {21, 11}, {24, 11} }, 1), R.gloss)
c:fill(c:line({ {14, 19}, {15, 16}, {18, 14}, {21, 12} }, 1), R.gloss)
c:px(16, 18, R.dot)

c:part(c:ellipse(cx, cy, 6.5), "dusk", { gloss = false, contour = "#2a1a10" })
-- stamen spokes and dots
local st = "#291d4a"
for i = 0, 11 do
  local a = (i + 0.5) * math.pi / 6
  for r = 6, 8 do c:px(math.floor(cx + r*math.cos(a) + 0.5), math.floor(cy + r*math.sin(a) + 0.5), st) end
  local x, y = math.floor(cx + 9.3*math.cos(a)), math.floor(cy + 9.3*math.sin(a))
  c:fill(c:rect(x, y, x+1, y+1), st)
end
c:part(c:ellipse(cx, cy, 2.5), "moss", { gloss = false, contour = false })
c:px(30, 30, GV.R.moss.gloss)

local t = c:save(O .. "aseprite/flowers/poppy.aseprite", O .. "png/flowers/poppy.png")
print(GV.report(t))
