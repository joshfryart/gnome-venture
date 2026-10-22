local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local hedge = c:rrect(10, 26, 50, 48, 8):add(c:rect(10, 40, 50, 48))
-- tail sweeping out left
hedge:add(c:poly({{12,32},{4,26},{6,34},{12,42}}))
local pot = c:rrect(12, 47, 48, 54, 2)
local body = hedge:copy(); body:add(pot)
local p = c:build{
  { "pot", pot, "wood", { light = body } },
  { "hedge", hedge, GV.ramp("#58a03e"), { light = body } },
  { "left", c:ellipse(20, 26, 6.5), GV.ramp("#7ab55c"), { gloss = {17, 22} } },
  { "mid", c:ellipse(33, 25, 7), GV.ramp("#4a8a3e") },
  { "head", c:ellipse(46, 18, 6), GV.ramp("#7ab55c") },
}
-- snout bump on head
c:fill(c:rect(52, 18, 54, 20), "#7ab55c"); c:fill(c:rect(52, 21, 54, 21), "#4a8a3e")
-- leaf-clip lines
for _, x in ipairs({15, 23, 31, 39, 46}) do
  c:fill(c:line({{x,37},{x+2,36},{x+4,37}}, 1), "#2f5a2a")
end
c:seam({{13, 50}, {47, 50}})
local t = c:save(O .. "aseprite/ph/dragon-topiary.aseprite", O .. "png/ph/dragon-topiary.png")
print(GV.report(t))
