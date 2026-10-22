local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local grey = GV.ramp("#968f96")
local pale = GV.ramp("#f4f0e0")
local postR = GV.ramp("#d6c9b6")
-- rails
local rails = c:rect(6, 30, 57, 33):add(c:rect(6, 37, 57, 40))
c:part(rails, grey, { gloss = false })
-- pickets: four each side, 4 px wide, pointed-round tops
local function picket(x)
  local m = c:rrect(x, 25, x + 4, 43, 1)
  m:add(c:rect(x + 1, 23, x + 3, 24))
  return m
end
local xs = { 6, 13, 20, 38, 45, 52 }
for _, x in ipairs(xs) do
  c:part(picket(x), pale, { flat = true, rim = false })
  c:fill(c:rect(x + 4, 26, x + 4, 42), pale.shade)
end
-- centre post block
local post = c:rrect(26, 24, 37, 44, 2)
c:part(post, postR, { gloss = false })
c:part(c:rrect(28, 28, 35, 40, 2), pale, { gloss = false })
-- post cap
c:part(c:rrect(25, 21, 38, 25, 1), postR, { gloss = { 27, 22 } })
-- picket left-edge glints
for _, x in ipairs(xs) do c:px(x + 1, 27, pale.gloss); c:px(x + 1, 28, pale.gloss) end
c:seam({ { 28, 26 }, { 35, 26 } }, { free = true })
c:button(30, 31)
c:ground(31.5, 46, 26, 1.5)
local t = c:save(O .. "aseprite/ph/garden-gate-straight.aseprite", O .. "png/ph/garden-gate-straight.png")
print(GV.report(t))
