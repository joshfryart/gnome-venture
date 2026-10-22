local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- husk body: long horizontal capsule, slightly fatter at the right
local body = c:rrect(9, 24, 50, 47, 11)
local face = c:ellipse(48, 35.5, 8, 11.5)
local p = c:build{
  { "husk", body, GV.ramp("#8c4a1a", { gloss = "#ecc58a" }), { gloss = { 17, 28 } } },
  { "face", face, GV.ramp("#dcb06a"), { gloss = { 44, 28 } } },
}
-- inner ring on the cut face
local ring = c:ellipse(48, 35.5, 5, 7):cut(c:ellipse(48, 35.5, 3, 5))
c:fill(ring, "#a5663a")
c:px(48, 35, "#7a3a14"); c:px(48, 36, "#7a3a14")

-- fibre streaks running along the length (2 px dashes)
local function streak(y, x0, x1)
  local x = x0
  while x + 3 <= x1 do
    c:fill(c:rect(x, y, x + 3, y + 1), "#5e2f1e")
    x = x + 6
  end
end
streak(31, 23, 37)
streak(36, 14, 36)
streak(41, 17, 37)

local t = c:save(O .. "aseprite/ph/coconut-husk.aseprite", O .. "png/ph/coconut-husk.png")
print(GV.report(t))
