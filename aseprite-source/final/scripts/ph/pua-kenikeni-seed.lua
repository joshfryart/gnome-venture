local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { rim = "#e4f6ee", shade = "#8fcbd8", deep = "#3f8fb0", bounce = "#a8dce0" })
-- jar with stepped shoulder: body + narrower neck
local body = c:rrect(16, 22, 47, 54, 6)
local neck = c:rrect(22, 15, 41, 23, 2)
local cork = c:poly({ {21, 5}, {43, 5}, {41, 16}, {23, 16} })
cork = c:rrect(21, 5, 42, 15, 3):cut(c:rect(0, 12, 22, 16)):cut(c:rect(42, 12, 63, 16))
cork:add(c:rect(23, 12, 40, 15))

local p = c:build{
  { "neck", neck, glass, { gloss = false } },
  { "body", body, glass, { gloss = false } },
  { "cork", cork, "wood", { gloss = { 25, 7 } } },
}
-- cork pores
c:fill(c:rect(28, 9, 29, 10), "#8a4f2a")
c:fill(c:rect(35, 7, 36, 8), "#8a4f2a")
c:fill(c:rect(33, 12, 34, 12), "#8a4f2a")
-- neck rim band
c:fill(c:rect(22, 16, 41, 17), "#dcb06a")

-- contents inside glass (flat-ish, lighter tint)
local orange = GV.ramp("#f08a24")
local berry = c:ellipse(32, 40, 8, 8)
c:fill(berry, "#f08a24")
c:fill(c:ellipse(32, 40, 8, 8):cut(c:ellipse(30.5, 38.5, 8, 8)), "#e0501f")
c:px(28, 36, "#ffc27a"); c:px(29, 36, "#ffc27a"); c:px(28, 37, "#ffc27a")
c:fill(c:poly({ {32, 29}, {38, 29}, {37, 33}, {32, 33} }), "#58a03e")
c:fill(c:rect(32, 31, 33, 32), "#3f7a2c")
-- seed pile
for _, x in ipairs({ 21, 25, 29, 33, 37, 41 }) do
  c:fill(c:rrect(x, 50, x + 2, 52, 1), "#8c4a1a")
end
for _, x in ipairs({ 23, 27, 31, 35, 39 }) do
  c:fill(c:rrect(x, 48, x + 2, 50, 1), "#a86030")
end
-- tall glass gloss streak
c:fill(c:rect(19, 25, 20, 41), "#fff3c8")
c:fill(c:rect(19, 44, 20, 46), "#fff3c8")
c:fill(c:rect(24, 17, 25, 20), "#fff3c8")

c:ground(32, 57, 17, 2.5)
local t = c:save(O .. "aseprite/ph/pua-kenikeni-seed.aseprite", O .. "png/ph/pua-kenikeni-seed.png")
print(GV.report(t))
