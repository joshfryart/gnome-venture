-- ph/garden-gate: three dark posts crossed by two lighter rails
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local post = GV.ramp("#8c4a1a")
local rail = GV.ramp("#c4925f", { rim = "#f0d49a" })

local posts = c:mask()
for _, x in ipairs({ 14, 32, 50 }) do
  posts:add(c:rrect(x - 3, 15, x + 3, 54, 3))
end
c:build{
  { "posts", posts, post },
  { "upper", c:rrect(8, 22, 56, 28, 2), rail, { gloss = { 20, 23 } } },
  { "lower", c:rrect(8, 38, 56, 44, 2), rail, { gloss = { 20, 39 } } },
}
-- wood grain flecks on the rails (1 px accents)
for _, p in ipairs({ { 24, 25 }, { 41, 26 }, { 25, 41 }, { 42, 40 } }) do
  c:paint({ "gg" }, p[1], p[2], { g = rail.shade })
end
-- post caps: little top knot lines
for _, x in ipairs({ 14, 32, 50 }) do
  c:px(x - 1, 33, post.shade); c:px(x, 34, post.shade)
end
c:button(30, 23)
c:ground(32, 55.5, 19, 2.5)

local t = c:save(O .. "aseprite/ph/garden-gate.aseprite", O .. "png/ph/garden-gate.png")
print(GV.report(t))
