local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaves = c:ellipse(20, 16, 4.5, 2.5):add(c:ellipse(44, 16, 4.5, 2.5))
local cone = c:poly({ {14, 19}, {51, 19}, {33, 56} })
local rim = c:ellipse(32.5, 19, 18, 3.5)
local rose = c:ellipse(32.5, 13, 8, 7)
local p = c:build{
  { "leaves", leaves, GV.ramp("#58a03e"), { gloss = false, cres = 2 } },
  { "cone", cone, "cream", { light = cone } },
  { "rim", rim, GV.ramp("#e0d8c0"), { gloss = false, cres = 2 } },
  { "rose", rose, GV.ramp("#f6f0e2"), { cres = 3, gloss = { 28, 9 } } },
}
-- rose petal layers: pink edge hints and inner spiral
c:paint({
  "..p.....p..",
  ".p...pp...p",
  "....p..p...",
  "p..p.pp.p..",
  "...p.p..p..",
  "....p..p..p",
  ".p...pp....",
}, 27, 9, { p = "#e46a9b" })
-- twist lines down the cone
for i = 0, 26 do
  local y = 24 + i
  local x1 = math.floor(19 + i * 14 / 26 + 0.5)
  local x2 = math.floor(46 - i * 14 / 26 + 0.5)
  if i % 3 ~= 2 then c:px(x1, y, "#dcb06a"); c:px(x2, y, "#dcb06a") end
end
-- seeds on the cone
c:paint({ "ss", "ss" }, 31, 28, { s = "#9a6b3f" })
c:paint({ "ss", "ss" }, 26, 34, { s = "#9a6b3f" })
c:paint({ "ss", "ss" }, 36, 38, { s = "#9a6b3f" })
c:ground(33, 57, 8, 1.5)
local t = c:save(O .. "aseprite/ph/white-rose-of-york-seed.aseprite", O .. "png/ph/white-rose-of-york-seed.png")
print(GV.report(t))
