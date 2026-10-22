local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- glass jar: rounded body with shoulders narrowing to a neck
local jar = c:rrect(14, 22, 50, 55, 8)
jar:add(c:rect(22, 15, 42, 24))
local cork = c:rrect(23, 7, 41, 15, 2)

local p = c:build{
  { "jar",  jar,  "#c8ecdc", { pale = true, gloss = false } },
  { "cork", cork, GV.ramp("#d9a660", { shade = "#a8582f" }) },
}
-- glass lip ring under the cork
c:fill(c:rect(22, 15, 42, 16), "#8fcbd8")
-- shoulder line
c:fill(c:rect(22, 22, 22, 23), "#8fcbd8"); c:fill(c:rect(42, 22, 42, 23), "#8fcbd8")
-- cork grain dots
c:px(28, 10, "#a8582f"); c:px(34, 12, "#a8582f"); c:px(37, 9, "#a8582f")

-- stalk
c:part(c:rect(31, 27, 33, 51), GV.ramp("#2e5a2c"), { flat = true })
-- grain ear: alternating pink (left) and crimson (right) pairs
local pink, crim = GV.ramp("#e46a9b"), GV.ramp("#a8241f")
c:part(c:ellipse(32, 25, 2.5, 3.5), pink, { gloss = false })
for _, y in ipairs({ 31, 38, 45 }) do
  c:part(c:ellipse(27.5, y, 3, 3.5), pink, { gloss = false })
  c:part(c:ellipse(36.5, y, 3, 3.5), crim, { gloss = false })
  c:px(26, y - 2, pink.gloss); c:px(35, y - 2, crim.gloss)
end
-- leaf at the base
c:fill(c:ascii({ "..ggg", ".gggg", "gggg.", "gg..." }, 25, 48), "#58a03e")
-- glass glint streak
c:fill(c:rect(18, 28, 19, 42), "#fff1c8")
c:px(18, 45, "#fff1c8"); c:px(18, 46, "#fff1c8")

local t = c:save(O .. "aseprite/ph/triticale-seed.aseprite", O .. "png/ph/triticale-seed.png")
print(GV.report(t))
