-- animals/lilypad : flat green pad with a V notch to the centre, pink flower on the right rim
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local padR = GV.ramp("#4f9a45")
local pad = c:ellipse(30.5, 33, 20, 15)
pad:cut(c:poly({ {31, 33}, {36, 16}, {50, 22} }))

c:build{
  { "pad", pad, padR },
}
-- vein ring + radial veins (skip gloss area upper-left)
local ring = c:ellipse(30.5, 33, 16, 11):edge()
ring:cut(c:poly({ {31, 33}, {35, 16}, {52, 22} }):grow(1))
ring:each(function(x, y)
  if not (x < 26 and y < 30) then c:px(x, y, "#3b7a33") end
end)
for _, v in ipairs({ { {30, 34}, {20, 41} }, { {30, 34}, {31, 46} }, { {30, 34}, {42, 42} }, { {30, 34}, {17, 33} } }) do
  c:fill(c:line(v, 1):clip(pad:shrink(3)), "#3b7a33")
end
-- flower on the right rim, built after the pad so it sits on top
c:build{
  { "petals", c:ellipse(46, 38, 6, 5):add(c:ellipse(46, 33.5, 3, 2.5)):add(c:ellipse(41.5, 38, 2.5, 3)):add(c:ellipse(50.5, 38, 2.5, 3)), GV.ramp("#f6b8cf", { shade = "#e46a9b" }) },
  { "centre", c:ellipse(46, 37.5, 2, 2), GV.ramp("#f7e17a"), { flat = true } },
}
c:px(45, 36, "#fff1c8")

local t = c:save(O .. "aseprite/animals/lilypad.aseprite", O .. "png/animals/lilypad.png")
print(GV.report(t))
