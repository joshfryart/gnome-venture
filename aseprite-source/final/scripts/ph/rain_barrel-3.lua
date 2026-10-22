local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pipe = GV.ramp("#968f96")
local hoopR = GV.ramp("#6a6070")
local spout = c:rect(7, 7, 11, 23); spout:add(c:rect(7, 19, 21, 23))
c:part(spout, pipe)
c:part(c:ellipse(9, 28, 2, 2.5), GV.ramp("#a9d6ea"), { gloss = false })
c:px(9, 25, "#a9d6ea")
-- flag pole behind barrel rim
c:part(c:rect(46, 9, 47, 22), GV.ramp("#44281c"), { flat = true })
c:part(c:poly({ { 48, 9 }, { 57, 12 }, { 48, 16 } }), GV.ramp("#d6322b"), { gloss = false })
local body = c:rrect(14, 21, 49, 55, 8)
local p = c:build{
  { "barrel", body, GV.ramp("#a5663a") },
}
for _, x in ipairs({ 23, 32, 41 }) do c:line({ { x, 27 }, { x, 53 } }, 1) end
for _, x in ipairs({ 23, 32, 41 }) do for y = 27, 53 do if c:get(x,y) then c:px(x, y, "#7a4a2a") end end end
local h1 = c:rect(14, 29, 49, 32):clip(body)
local h2 = c:rect(14, 45, 49, 48):clip(body)
c:part(h1, hoopR, { gloss = false, light = body })
c:part(h2, hoopR, { gloss = false, light = body })
c:part(c:ellipse(31.5, 21, 18, 5.5), GV.ramp("#8c4a1a"), { gloss = false })
c:part(c:ellipse(31.5, 21.5, 15, 3.5), GV.ramp("#3f93b2"), { contact = false, gloss = { 22, 20 } })
c:paint({ "ww...www" }, 26, 22, { w = "#a9d6ea" })
c:part(c:rect(29, 50, 34, 52), hoopR, { flat = true })
c:px(31, 53, "#a9d6ea"); c:px(32, 53, "#a9d6ea"); c:px(31, 54, "#a9d6ea"); c:px(32, 54, "#a9d6ea")
c:button(16, 34)
c:seam({ { 18, 54 }, { 28, 54 } }); c:seam({ { 36, 54 }, { 46, 54 } })
c:px(44, 13, "#f5cf6a"); c:px(43, 14, "#f5cf6a"); c:px(45, 14, "#f5cf6a"); c:px(44, 15, "#f5cf6a")
c:ground(31.5, 57, 20, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/rain_barrel-3.aseprite", O .. "png/ph/rain_barrel-3.png")
print(GV.report(t))
