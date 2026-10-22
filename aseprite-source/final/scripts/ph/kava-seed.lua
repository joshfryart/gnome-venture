local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc")
local jar = c:rrect(15, 24, 48, 54, 8)
local contents = c:ellipse(32, 44, 12, 7):add(c:ellipse(26, 47, 6, 4)):add(c:ellipse(38, 46, 7, 5))
c:build{
  { "neck", c:rrect(22, 17, 41, 26, 2), glass, { gloss = false } },
  { "jar", jar, glass, { gloss = { 18, 29 } } },
  { "contents", contents, GV.ramp("#f08a24"), { gloss = false } },
  { "cork", c:rrect(21, 7, 42, 18, 3), GV.ramp("#d9a660", { shade = "#a8582f" }) },
}
-- long vertical gloss on the left glass wall
c:fill(c:rect(18, 30, 18, 43), glass.gloss); c:px(18, 46, glass.gloss)
c:fill(c:rect(19, 30, 19, 32), "#ffffff")
-- seeds
for _, s in ipairs({ { 27, 44 }, { 33, 41 }, { 39, 44 } }) do c:fill(c:ellipse(s[1], s[2], 1.5, 1.5), "#b8452f") end
c:px(26, 43, "#ffc27a"); c:px(32, 40, "#ffc27a"); c:px(38, 43, "#ffc27a")
-- root curl
c:fill(c:line({ { 22, 48 }, { 19, 50 }, { 19, 52 }, { 21, 52 } }, 2), "#2e5a2c")
-- cork texture dots
c:px(28, 11, "#a8582f"); c:px(35, 13, "#a8582f"); c:px(31, 15, "#a8582f")
c:seam({ { 22, 17 }, { 41, 17 } }, { on = 2, off = 1 })
local t = c:save(O .. "aseprite/ph/kava-seed.aseprite", O .. "png/ph/kava-seed.png")
print(GV.report(t))
