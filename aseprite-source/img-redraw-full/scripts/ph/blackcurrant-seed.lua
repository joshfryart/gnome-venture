local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local crate = c:rrect(11, 32, 53, 56, 2)
local posts = c:rect(11, 32, 15, 56):add(c:rect(49, 32, 53, 56))
local leaf = c:poly({ {34, 12}, {37, 8}, {42, 5}, {48, 5}, {47, 9}, {43, 13}, {37, 15} })
local stem = c:rect(31, 12, 32, 17)
local function b(x, y) return c:ellipse(x, y, 4.5, 4.5) end
local back = b(26.5, 22.5); back:add(b(37.5, 22.5))
local top = b(32, 15.5)
local mid = b(20.5, 31.5); mid:add(b(32, 31.5)); mid:add(b(43.5, 31.5))
local p = c:build{
  { "crate", crate, "wood" },
  { "posts", posts, GV.ramp("#8a4f2a"), { gloss = false } },
  { "stem", stem, GV.ramp("#2e5a2c"), { flat = true } },
  { "top", top, GV.ramp("#2f2350") },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "back", back, GV.ramp("#4e3a8a"), { gloss = false } },
  { "mid", mid, GV.ramp("#3e2f66"), { gloss = false } },
}
-- plank gaps
c:fill(c:rect(16, 43, 48, 44), "#5e2f1e")
c:fill(c:rect(16, 50, 48, 51), "#5e2f1e")
-- nail heads on posts
for _, y in ipairs({ 39, 53 }) do c:px(13, y, "#5e2f1e"); c:px(51, y, "#5e2f1e") end
-- berry glints
for _, q in ipairs({ {24, 20}, {35, 20}, {18, 29}, {30, 29}, {41, 29} }) do c:px(q[1], q[2], "#a894dc") end
c:ground(32, 57, 20, 1.5)
local t = c:save(O .. "aseprite/ph/blackcurrant-seed.aseprite", O .. "png/ph/blackcurrant-seed.png")
print(GV.report(t))
