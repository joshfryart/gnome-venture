local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur = GV.ramp("#a8582f")
local pale = GV.ramp("#d9a660")
-- tail hooking up on the right
local tail = c:line({ {43,49}, {49,49}, {53,46}, {54,41}, {53,37} }, 4)
local feet = c:ellipse(23, 54, 6, 3.5):add(c:ellipse(41, 54, 6, 3.5))
local ears = c:ellipse(20.5, 20, 5, 5):add(c:ellipse(43.5, 20, 5, 5))
local body = c:ellipse(32, 43.5, 15, 12.5)
local head = c:ellipse(32, 30, 13, 12)
local p = c:build{
  { "tail", tail, GV.ramp("#8a4f2a") },
  { "feet", feet, GV.ramp("#5e2f1e") },
  { "ears", ears, fur, { gloss = false } },
  { "body", body, fur, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 47.5, 9, 7.5), pale, { flat = true } },
  { "head", head, fur },
}
-- inner ears
c:fill(c:ellipse(20.5, 20, 2.5, 2.5):cut(head), "#d9a660")
c:fill(c:ellipse(43.5, 20, 2.5, 2.5):cut(head), "#d9a660")
-- muzzle
c:part(c:ellipse(32, 35.5, 6.5, 4.5), pale, { flat = true })
-- bandit mask band with rounded ends
local mask = c:rrect(19, 23, 45, 29, 3):clip(head:copy():add(c:rect(18,23,46,29)))
c:part(mask, GV.ramp("#3a2418"), { flat = true })
c:eye(23, 24); c:eye(37, 24)
-- nose and smile
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 32, { n = "#2a1a10" })
c:px(31, 32, "#5e2f1e")
c:paint({ "s.....s", ".s.s.s.", "..s.s.." }, 29, 36, { s = "#4a2c1a" })
-- whiskers
for _, xy in ipairs({ {24,34},{23,34},{22,34},{21,34}, {24,37},{23,37},{22,38},{21,38} }) do
  c:px(xy[1], xy[2], "#4a2c1a"); c:px(64 - xy[1], xy[2], "#4a2c1a")
end
c:ground(32, 57.5, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-sea-otter-bandit.aseprite", O .. "png/ph/creature-sea-otter-bandit.png")
print(GV.report(t))
