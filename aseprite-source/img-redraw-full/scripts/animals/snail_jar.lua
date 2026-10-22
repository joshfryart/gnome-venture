local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- jar: round shoulders narrowing to a neck under the lid
local jar = c:rrect(12, 18, 51, 56, 8)
jar:add(c:rrect(17, 13, 46, 24, 6))
jar:add(c:rect(21, 13, 42, 16))
local soil = c:rrect(15, 43, 48, 53, 4):cut(c:rect(15, 43, 48, 44)):add(c:rect(16, 43, 47, 46))
local lid = c:rrect(18, 6, 45, 13, 2)
local stem = c:line({ { 21, 44 }, { 21, 36 }, { 22, 30 }, { 23, 25 } }, 2)
local leaves = c:ellipse(17.5, 33, 3.5, 2):add(c:ellipse(26.5, 28, 3.5, 2)):add(c:ellipse(20, 24, 2.5, 3))
local foot = c:rrect(24, 40, 46, 44, 2):add(c:rrect(40, 33, 45, 43, 2))
local shell = c:ellipse(32, 35, 7.5, 7)
local glass = GV.ramp("#cfe9ee", { rim = "#8fcbd8", gloss = "#fff3c8" })
local p = c:build{
  { "jar", jar, glass },
  { "soil", soil, GV.ramp("#7a5a3a") },
  { "stem", stem, GV.ramp("#4f9a4a"), { flat = true } },
  { "leaves", leaves, GV.ramp("#4f9a4a") },
  { "foot", foot, GV.ramp("#cdbb8f") },
  { "shell", shell, GV.ramp("#c47a3a") },
  { "lid", lid, GV.ramp("#a0724a") },
}
-- shell spiral
c:paint({
  "..sssss.",
  ".s.....s",
  "s..sss..",
  "s.s...s.",
  "s.s.s.s.",
  "s..ss.s.",
  ".s...s..",
  "..sss...",
}, 28, 31, { s = "#7a4a1f" })
-- eyestalks with dark tips
c:fill(c:line({ { 42, 33 }, { 41, 29 } }, 1), "#cdbb8f")
c:fill(c:line({ { 44, 33 }, { 46, 29 } }, 1), "#cdbb8f")
c:paint({ "dd...dd", "dd...dd" }, 40, 27, { d = "#2a1a10" })
c:px(41, 37, "#2a1a10")
-- lid rim line and contact on the neck
c:fill(c:rect(19, 12, 44, 12), "#6b4a2b")
c:seam({ { 20, 9 }, { 43, 9 } })
-- glass glint stripe
c:fill(c:rect(15, 22, 15, 38), "#fff3c8")
c:fill(c:rect(16, 20, 16, 23), "#fff3c8")
-- soil pebbles
c:px(19, 49, "#4e3522"); c:px(30, 50, "#4e3522"); c:px(42, 48, "#4e3522"); c:px(36, 51, "#a07a52")
local t = c:save(O .. "aseprite/animals/snail_jar.aseprite", O .. "png/animals/snail_jar.png")
print(GV.report(t))
