local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 49, 24, 32):clip(c:rect(0, 0, 63, 49))
local frame = c:ellipse(31.5, 37, 13, 11):clip(c:rect(0,0,63,37)):add(c:rect(18.5, 37, 44.5, 49))
local door = c:ellipse(31.5, 38, 9.5, 8.5):clip(c:rect(0,0,63,38)):add(c:rect(22, 38, 41, 49))
local p = c:build{
  { "mound", mound, GV.ramp("#58a03e") },
}
c:paint({ ".t.t", "t.t." }, 20, 22, { t = "#2e5a2c" })
c:paint({ ".t.t", "t.t." }, 44, 26, { t = "#2e5a2c" })
c:paint({ ".t.t", "t.t." }, 11, 37, { t = "#2e5a2c" })
c:part(frame, GV.ramp("#968f96"), { light = mound })
c:part(door, "wood", { light = mound })
for _, x in ipairs({ 27, 32, 36 }) do
  for y = 30, 49 do if door:has(x, y) and door:has(x-1,y) and door:has(x+1,y) then c:px(x, y, "#5e2f1e") end end
end
c:part(c:ellipse(38.5, 42.5, 1.5, 1.5), "gold", { flat = true })
-- lanterns: glow ring, hook, body
local glow = c:ellipse(11.5, 29.5, 5.5, 5.5):add(c:ellipse(51.5, 29.5, 5.5, 5.5))
c:part(glow, GV.ramp("#f5cf6a"), { flat = true, rim = false })
c:fill(c:rect(11, 20, 12, 25), "#2a1a10")
c:fill(c:rect(51, 20, 52, 25), "#2a1a10")
c:part(c:rrect(9, 25, 14, 33, 2), "gold", { gloss = { 10, 27 } })
c:part(c:rrect(49, 25, 54, 33, 2), "gold", { gloss = { 50, 27 } })
c:fill(c:rect(11, 28, 12, 30), "#fff1c8"); c:fill(c:rect(51, 28, 52, 30), "#fff1c8")
c:fill(c:rect(9, 25, 14, 25), "#7a3a14"); c:fill(c:rect(49, 25, 54, 25), "#7a3a14")
c:ground(31.5, 51, 23, 1.5)
local t = c:save(O .. "aseprite/ph/root_cellar-lantern.aseprite", O .. "png/ph/root_cellar-lantern.png")
print(GV.report(t))
