-- ph/wattle-fence-gate : woven wattle gate between two chunky posts, diagonal brace, gold latch
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/wattle-fence-gate"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lr" }
local wood  = GV.R.wood
local rail  = GV.ramp("#c4925f")
local paleR = GV.ramp("#d9a660", { gloss = "#ecc58a" })
local withy = GV.ramp("#9a6b3f")
local brace = GV.ramp("#8a4f2a", { deep = "#5e2f1e" })

local PX = { 15, 21, 27, 33, 39, 45 }
local paleM = {}
local list = {
  -- side rail stubs running off the frame (the fence continues)
  { "stubs", c:rect(0, 26, 8, 29):add(c:rect(0, 38, 8, 41)):add(c:rect(55, 26, 63, 29)):add(c:rect(55, 38, 63, 41)),
    rail, { cres = 1, gloss = false } },
}
for i, x in ipairs(PX) do
  paleM[i] = c:rrect(x, 20 + (i % 2), x + 3, 46, 1)
  list[#list + 1] = { "p" .. i, paleM[i], paleR, { cres = 1, deep = 0, gloss = { x, 23 } } }
end
c:build(list)
-- woven withies: run across the pales, then the pales come back over on alternate crossings
local rows = { { 30, 32 }, { 34, 36 } }
for r, ry in ipairs(rows) do
  c:part(c:rect(14, ry[1], 49, ry[2]), withy, { cres = 1, deep = 0, gloss = false })
end
for r, ry in ipairs(rows) do
  for i, x in ipairs(PX) do
    if (i + r) % 2 == 0 then
      c:part(c:rect(x, ry[1], x + 3, ry[2]), paleR,
        { light = paleM[i], cres = 1, deep = 0, gloss = false, rim = false, contact = false, contour = false })
    end
  end
end
c:build{
  { "rails", c:rect(14, 25, 49, 28):add(c:rect(14, 38, 49, 41)), rail, { cres = 1, gloss = false } },
  { "postL", c:rrect(6, 17, 13, 50, 2), wood, { cres = 3, gloss = { 7, 20 } } },
  { "postR", c:rrect(50, 17, 57, 50, 2), wood, { cres = 3, gloss = { 51, 20 } } },
  { "capL",  c:rrect(5, 13, 14, 17, 2), GV.ramp("#d9a660"), { cres = 2, gloss = false } },
  { "capR",  c:rrect(49, 13, 58, 17, 2), GV.ramp("#d9a660"), { cres = 2, gloss = false } },
  { "brace", c:line({ { 16, 40 }, { 47, 27 } }, 3), brace, { flat = true } },
  { "latch", c:rrect(45, 31, 49, 35, 1), "gold", { flat = true } },
}
c:px(46, 32, "#fff1c8")
c:ground(31.5, 52, 27, 1.5)
local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
