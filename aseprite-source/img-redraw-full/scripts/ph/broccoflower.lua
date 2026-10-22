local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lime = GV.ramp("#94c95a")
-- shield dome (no stalk) with sharp cone spikes around the top and sides
local head = c:ellipse(32, 35, 17, 17)
head:add(c:poly({ {16, 32}, {48, 32}, {42, 53}, {22, 53} }))
local spikes = { -- tip, then base centre; base half-width 4
  { 32, 7, 32, 20 }, { 20, 11, 23, 22 }, { 44, 11, 41, 22 },
  { 11, 21, 18, 27 }, { 53, 21, 46, 27 }, { 9, 34, 17, 36 }, { 55, 34, 47, 36 },
  { 13, 46, 19, 43 }, { 51, 46, 45, 43 },
}
for _, s in ipairs(spikes) do
  local dx, dy = s[1] - s[3], s[2] - s[4]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L * 4.5, dx / L * 4.5
  head:add(c:poly({ { s[1], s[2] }, { s[3] + nx, s[4] + ny }, { s[3] - nx, s[4] - ny } }))
end
local p = c:build{ { "head", head, lime, { gloss = { 20, 24 } } } }
-- floret cones in a spiral: light face, shaded right flank and base
local function cone(x, y, h)
  for i = 0, h do
    local w = math.floor(i * 4 / h + 0.5)
    for xx = x - w, x + w do c:px(xx, y - h + i, lime.rim) end
    c:px(x + w, y - h + i, lime.shade)
    if w > 0 then c:px(x + w - 1, y - h + i, lime.base) end
  end
  for xx = x - 4, x + 4 do c:px(xx, y + 1, lime.shade) end
  c:px(x, y - h, lime.gloss)
end
cone(32, 22, 6)
cone(41, 31, 6)
cone(37, 42, 6)
cone(27, 42, 6)
cone(23, 31, 6)
-- spiral vein
c:fill(c:line({ {32, 25}, {32, 49} }, 2), lime.shade)
local t = c:save(O .. "aseprite/ph/broccoflower.aseprite", O .. "png/ph/broccoflower.png")
print(GV.report(t))
