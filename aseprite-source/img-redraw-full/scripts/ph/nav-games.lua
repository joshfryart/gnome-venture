local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:rrect(9, 9, 54, 47, 9)
local band = c:rrect(9, 38, 54, 54, 8):cut(c:rect(0, 0, 63, 41))
band:add(c:rect(9, 42, 54, 47))
local bandR = GV.ramp("#d6c9b6")
local p = c:build{
  { "body", body, GV.ramp("#f4f0e0"), { light = body:copy():add(band), gloss = { 15, 14 } } },
  { "band", band, bandR, { gloss = false } },
}
c:seam({ {12, 42}, {51, 42} }, { free = true })
local pipR = GV.ramp("#d6322b")
local pips = { {20, 19}, {43, 19}, {31.5, 28.5}, {20, 37}, {43, 37} }
for _, q in ipairs(pips) do
  c:part(c:ellipse(q[1], q[2], 4.5, 4), pipR, { gloss = false, contact = false, contour = false })
  c:px(math.floor(q[1]) - 2, math.floor(q[2]) - 2, "#ff9158")
  c:px(math.floor(q[1]) - 1, math.floor(q[2]) - 3, "#ff9158")
end
local t = c:save(O .. "aseprite/ph/nav-games.aseprite", O .. "png/ph/nav-games.png")
print(GV.report(t))
