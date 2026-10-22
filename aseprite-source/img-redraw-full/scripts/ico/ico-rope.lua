local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tan = GV.ramp("#dcb06a", { gloss = "#ecc58a" })
local ring = c:ellipse(29.5, 31, 20, 16):cut(c:ellipse(29.5, 31, 11, 7))
local tail = c:line({ { 46, 40 }, { 51, 43 }, { 54, 47 }, { 54, 51 }, { 51, 54 } }, 5)
tail:add(c:ellipse(50, 54, 2.5, 2.5))
tail:cut(ring:grow(1))
c:build{
  { "tail", tail, tan, { gloss = false } },
  { "ring", ring, tan },
}
-- twist ticks: 2px diagonals across the band
local T = "#8a4f2a"
-- radial twist strokes across the band, each a 2px diagonal
local cx, cy = 29.5, 31
for i = 0, 13 do
  local a = i * (2 * math.pi / 14) + 0.2
  for k = 0, 5 do
    local r = 0.62 + k * 0.06
    local x = math.floor(cx + math.cos(a + k * 0.07) * 20 * r + 0.5)
    local y = math.floor(cy + math.sin(a + k * 0.07) * 16 * r + 0.5)
    if ring:has(x, y) then c:px(x, y, T) end
    if ring:has(x + 1, y) then c:px(x + 1, y, T) end
  end
end
c:paint({ "tt.", ".tt" }, 51, 47, { t = T })
c:paint({ "tt.", ".tt" }, 49, 42, { t = T })
local t = c:save(O .. "aseprite/ico/ico-rope.aseprite", O .. "png/ico/ico-rope.png")
print(GV.report(t))
