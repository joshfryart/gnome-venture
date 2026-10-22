local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5,48,23,14):cut(c:rect(0,49,63,63))
mound:add(c:ellipse(20,36,8,6)):add(c:ellipse(34,33,9,7)):add(c:ellipse(45,39,7,6)):add(c:rrect(9,42,54,48,4))
local pts = {}
for i = 0, 34 do
  local x = 13 + i
  local y = 32 - i*0.18 + 4*math.sin(i/34*2.6*math.pi)
  pts[#pts+1] = {x, math.floor(y+0.5)}
end
local worm = c:line(pts, 5):add(c:ellipse(48,23,3.5,3.5))
local p = c:build{
  { "mound", mound, GV.ramp("#7a4a1f"), { gloss = {17,34} } },
  { "worm", worm, GV.ramp("#e46a9b"), { gloss = {20,26}, light = worm } },
}
for _, q in ipairs({{22,40},{34,42},{27,45},{42,44},{16,45}}) do
  c:px(q[1],q[2],"#3d2a1c"); c:px(q[1]+1,q[2],"#3d2a1c")
end
-- worm segment rings
for _, x in ipairs({19,25,31,37,42}) do
  local y0
  for y = 10, 50 do if worm:has(x,y) then y0 = y break end end
  if y0 then for y = y0+1, y0+3 do if worm:has(x,y) then c:px(x,y,GV.ramp("#e46a9b").shade) end end end
end
c:px(48,21,"#2a1a10"); c:px(49,21,"#2a1a10"); c:px(48,22,"#2a1a10"); c:px(49,22,"#2a1a10")
c:ground(31.5,51,18,2.5)
local t = c:save(O.."aseprite/ph/worm-castings.aseprite", O.."png/ph/worm-castings.png")
print(GV.report(t))
