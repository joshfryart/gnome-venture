local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local woodR = GV.ramp("#b6814d")
local railR = GV.ramp("#c4925f")
local capR = GV.ramp("#dcb06a")
local pale = GV.ramp("#f4f0e0")
local rails = c:rect(16, 28, 48, 31):add(c:rect(16, 37, 48, 40))
local pickets = c:mask()
for _, x in ipairs({ 17, 22, 27, 32, 37, 42 }) do
  pickets:add(c:poly({ { x, 25 }, { x + 2, 22 }, { x + 4, 25 }, { x + 4, 45 }, { x, 45 } }))
end
local brace = c:line({ { 18, 38 }, { 45, 29 } }, 2)
local p = c:build{
  { "rails", rails, railR, { gloss = false } },
  { "pickets", pickets, pale, { gloss = false, light = c:rect(16, 22, 48, 45) } },
}
-- brace sits on pickets/rails
c:fill(brace:copy():clip(pickets:copy():add(rails)), "#4a2c1a")
local p2 = c:build{
  { "postL", c:rrect(9, 24, 16, 47, 2), woodR, { gloss = { 11, 29 } } },
  { "postR", c:rrect(47, 24, 54, 47, 2), woodR, { gloss = { 49, 29 } } },
  { "capL", c:rrect(8, 20, 17, 24, 1), capR, { flat = true } },
  { "capR", c:rrect(46, 20, 55, 24, 1), capR, { flat = true } },
}
for _, x in ipairs({ 17, 22, 27, 32, 37, 42 }) do
  c:px(x + 1, 26, "#fff3c8"); c:px(x + 1, 27, "#fff3c8")
end
c:part(c:ellipse(44, 34, 2.5, 2.5), "gold", { gloss = false, contact = false })
c:px(43, 33, "#fff1c8")
c:ground(31.5, 48, 24, 1.5)
local t = c:save(O .. "aseprite/ph/garden-gate-gate.aseprite", O .. "png/ph/garden-gate-gate.png")
print(GV.report(t))
