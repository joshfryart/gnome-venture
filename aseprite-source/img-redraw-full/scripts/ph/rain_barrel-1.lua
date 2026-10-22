local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pipe = c:rect(8, 7, 13, 24)
pipe:add(c:rrect(8, 19, 22, 24, 2))
local body = c:rrect(15, 20, 50, 55, 7)
body:add(c:ellipse(32.5, 21, 17.5, 5))
local stone = GV.ramp("#968f96")
local p = c:build{
  { "pipe", pipe, stone },
  { "drip", c:ellipse(10.5, 29, 1.5, 2), "water", { flat = true } },
  { "body", body, GV.ramp("#a5663a"), { gloss = { 20, 31 } } },
}
-- plank lines
for _, x in ipairs({ 24, 32, 41 }) do
  for y = 26, 54 do if p.body.m:has(x, y) and c:get(x, y) ~= nil then c:px(x, y, "#5e2f1e") end end
end
local hr = GV.ramp("#6a6070")
c:part(c:rect(15, 30, 50, 33):clip(body), hr, { gloss = false, contact = false })
c:part(c:rect(15, 46, 50, 49):clip(body), hr, { gloss = false, contact = false })
-- top rim and water
c:part(c:ellipse(32.5, 21, 17.5, 5), GV.ramp("#8c4a1a"), { gloss = false })
c:part(c:ellipse(32.5, 21.5, 14.5, 3.5), "water", { gloss = { 24, 20 }, contact = false })
c:paint({ "ww....", "..wwww" }, 33, 21, { w = "#a9d6ea" })
-- tap
c:part(c:rrect(29, 49, 36, 52, 1), hr, { flat = true })
c:part(c:rect(31, 53, 34, 54), hr, { flat = true })
c:ground(32.5, 57, 16, 1.5)
local t = c:save(O .. "aseprite/ph/rain_barrel-1.aseprite", O .. "png/ph/rain_barrel-1.png")
print(GV.report(t))
