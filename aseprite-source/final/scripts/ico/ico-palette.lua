local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- kidney board with a bite notch at the lower right and a thumb hole
local board = c:ellipse(31.5, 32, 24, 20)
board:cut(c:ellipse(49, 48, 6, 6))
board:cut(c:ellipse(41.5, 19.5, 4.5, 3.5))

local p = c:build{
  { "board", board, GV.ramp("#d8b07a"), { gloss = { 16, 20 } } },
}
-- thumb hole: dark well
local hole = c:ellipse(41.5, 19.5, 4.5, 3.5)
c:fill(hole, "#5e2f1e")
c:fill(c:ellipse(42.5, 20.5, 3.5, 2.5):clip(hole), "#2a1a10")

-- five enamel dabs arcing round the board
c:part(c:ellipse(17.5, 31, 5, 5), GV.ramp("#9c2a1e"))
c:part(c:ellipse(26.5, 19.5, 5, 4.5), GV.ramp("#58a03e"))
c:part(c:ellipse(47.5, 32, 5, 5), GV.ramp("#4a7fb0"))
c:part(c:ellipse(25.5, 42.5, 5, 4.5), GV.ramp("#f2cf4a"))
c:part(c:ellipse(37.5, 41.5, 4.5, 4.5), GV.ramp("#f8eed2"))

local t = c:save(O .. "aseprite/ico/ico-palette.aseprite", O .. "png/ico/ico-palette.png")
print(GV.report(t))
