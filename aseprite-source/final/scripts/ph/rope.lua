local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.ramp("#dcb06a")
local cx, cy = 30, 31
local ring = c:ellipse(cx, cy, 21, 17):cut(c:ellipse(cx, cy, 13, 9))
local tail = c:line({ {46,41}, {50,44}, {53,48}, {54,52} }, 5)
tail:add(c:ellipse(54, 53, 2.5, 2.5))
tail:cut(ring)
c:build{
  { "ring", ring, R, { gloss = { 16, 21 } } },
  { "tail", tail, R, { gloss = false } },
}
-- twist ticks across the band
local T = "#a5663a"
for i = 0, 17 do
  local a = i * (2 * math.pi / 18) + 0.1
  local x0, y0 = cx + math.cos(a) * 15, cy + math.sin(a) * 11
  local x1, y1 = cx + math.cos(a + 0.22) * 19, cy + math.sin(a + 0.22) * 15
  local m = c:line({ { math.floor(x0 + 0.5), math.floor(y0 + 0.5) }, { math.floor(x1 + 0.5), math.floor(y1 + 0.5) } }, 1)
  m:clip(ring:shrink(1))
  local skip = false
  m:each(function(x, y) if x < cx - 8 and y < cy - 6 and x < 22 and y < 24 then skip = true end end)
  if not skip then c:fill(m, T) end
end
c:fill(c:line({ {49,43}, {51,46} }, 1), T)
c:fill(c:line({ {52,47}, {54,49} }, 1), T)
local t = c:save(O .. "aseprite/ph/rope.aseprite", O .. "png/ph/rope.png")
print(GV.report(t))
