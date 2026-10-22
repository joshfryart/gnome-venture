local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { shade = "#8fcbd8", deep = "#5a9ab8" })
local neckR = GV.ramp("#a8dce4", { shade = "#8fcbd8", deep = "#5a9ab8" })
-- jar: shoulders curve into neck
local body = c:rrect(13, 21, 50, 56, 10)
body:add(c:ellipse(31.5, 25, 15, 6))
local neck = c:rrect(22, 14, 41, 23, 1)
local p = c:build{
  { "body", body, glass },
  { "neck", neck, neckR, { gloss = false } },
  { "cork", c:rrect(21, 6, 42, 16, 3), GV.ramp("#d9a660", { shade = "#a8582f" }), { stitch = false } },
  { "seed", c:ellipse(32, 42, 9, 8.5), GV.ramp("#e46a9b") },
}
-- neck rim ring
c:fill(c:rect(22, 21, 41, 22), "#8fcbd8")
-- cork grain
c:px(27, 10, "#a8582f"); c:px(28, 10, "#a8582f")
c:px(35, 12, "#a8582f"); c:px(36, 12, "#a8582f")
-- sprout
c:fill(c:rect(31, 27, 32, 34), "#2e5a2c")
c:fill(c:ascii({
  "..####...",
  ".#######.",
  "#########",
  ".#######.",
}, 33, 25), "#58a03e")
c:fill(c:ascii({ "..###", ".##.." }, 34, 25), "#8cc65a")
-- glass glint streak
c:fill(c:rect(18, 30, 19, 40), "#f2e4c0")
c:fill(c:rect(18, 43, 19, 45), "#f2e4c0")
c:seam({ { 22, 16 }, { 41, 16 } })
local t = c:save(O .. "aseprite/ph/clivia-seed.aseprite", O .. "png/ph/clivia-seed.png")
print(GV.report(t))
