local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local upper = GV.ramp("#8a6fe0")
local lower = GV.ramp("#f2a64a")
local dk = GV.ramp("#4a3a52")

c:build{
  { "lowL", c:ellipse(24, 44, 9, 9), lower, { gloss = false } },
  { "lowR", c:ellipse(40, 44, 9, 9), lower, { gloss = false } },
  { "upL",  c:ellipse(20, 25, 11, 11):add(c:ellipse(16, 20, 7, 7)), upper, { gloss = { 13, 15 } } },
  { "upR",  c:ellipse(44, 25, 11, 11):add(c:ellipse(48, 20, 7, 7)), upper, { gloss = { 41, 16 } } },
  { "body", c:rrect(29, 24, 35, 50, 3), dk, { gloss = false } },
  { "antL", c:line({ {30, 18}, {27, 14}, {24, 12} }, 2), dk, { flat = true } },
  { "antR", c:line({ {34, 18}, {37, 14}, {40, 12} }, 2), dk, { flat = true } },
  { "clL",  c:rrect(21, 8, 24, 11, 1), dk, { flat = true } },
  { "clR",  c:rrect(40, 8, 43, 11, 1), dk, { flat = true } },
  { "head", c:ellipse(32, 21, 4.5, 4), dk, { gloss = false } },
}
for _, s in ipairs({ { 17, 27, 3, 2.5 }, { 47, 27, 3, 2.5 }, { 22, 47, 2, 2 }, { 42, 47, 2, 2 } }) do
  c:spot(c:ellipse(s[1], s[2], s[3], s[4]), "#f4f0e0")
end
-- body segments
c:fill(c:rect(30, 34, 34, 34), dk.shade); c:fill(c:rect(30, 40, 34, 40), dk.shade)
c:eye(28, 19, true); c:eye(33, 19, true)

c:ground(32, 56, 13, 1.5)
local t = c:save(O .. "aseprite/gather/net-bug.aseprite", O .. "png/gather/net-bug.png")
print(GV.report(t))
