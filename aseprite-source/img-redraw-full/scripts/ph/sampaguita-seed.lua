local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(13, 21, 51, 55, 2)
local postL = c:rect(13, 21, 18, 55)
local postR = c:rect(46, 21, 51, 55)
local win = c:rrect(22, 25, 42, 47, 4)
local seed = c:ellipse(32, 37, 7, 7)
local leaf = c:ellipse(36.5, 27.5, 3, 1.5)

local p = c:build{
  { "body", body, "wood", { gloss = false } },
  { "postL", postL, GV.ramp("#a8582f"), { gloss = false } },
  { "postR", postR, GV.ramp("#a8582f"), { gloss = false } },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed", seed, GV.ramp("#3f93b2", { shade = "#256a80" }) },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
}
-- plank slats (outside the window)
for _, y in ipairs({ 29, 38, 47 }) do
  local s = c:rect(19, y, 45, y + 1):cut(win)
  c:fill(s, "#8a4f2a")
end
c:fill(c:rect(19, 51, 45, 52), "#8a4f2a")
-- wood grain flecks
c:paint({ "gg" }, 25, 50, { g = "#d9a660" }); c:paint({ "gg" }, 37, 54, { g = "#d9a660" })
-- window rim
c:fill(win:copy():cut(win:shrink(1)), "#3f93b2")
-- stem
c:fill(c:rect(31, 26, 32, 29), "#2e5a2c")
-- nails
for _, q in ipairs({ {15, 23}, {48, 23}, {15, 52}, {48, 52} }) do c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#2a1a10") end
c:seam({ {19, 22}, {45, 22} })

local t = c:save(O .. "aseprite/ph/sampaguita-seed.aseprite", O .. "png/ph/sampaguita-seed.png")
print(GV.report(t))
