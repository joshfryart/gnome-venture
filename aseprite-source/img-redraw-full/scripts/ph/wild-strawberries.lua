local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local BR = GV.ramp("#d6322b")
local DK = GV.ramp("#a8241f")
-- berry: round with a slightly tapered bottom
local function berry(cx, cy)
  local m = c:ellipse(cx, cy, 7, 6.5)
  m:add(c:poly({ {cx - 5, cy + 2}, {cx + 6, cy + 2}, {cx + 0.5, cy + 9} }))
  return m
end
local B = {
  {32, 26, BR},
  {25, 35, BR}, {39, 35, DK},
  {18, 44, DK}, {32, 44, BR}, {46, 44, DK},
}
local list = {}
for i, b in ipairs(B) do list[#list + 1] = { "b" .. i, berry(b[1], b[2]), b[3] } end
local stalk = c:line({ {32, 20}, {32, 13} }, 3)
local leaf = c:poly({ {32, 18}, {35, 12}, {39, 9}, {44, 7}, {43, 12}, {40, 16}, {35, 19} })
list[#list + 1] = { "stalk", stalk, "#2e5a2c", { flat = true } }
list[#list + 1] = { "leaf", leaf, "#58a03e", { gloss = false } }
-- calyx sepals on top berry
list[#list + 1] = { "calyx", c:poly({ {27, 21}, {37, 21}, {35, 23}, {32, 22}, {29, 23} }), "#2e5a2c", { flat = true } }
c:build(list)
c:seam({ {35, 17}, {41, 10} }, { on = 1, off = 1, free = true, gap = "#58a03e" })
-- seeds: triangle of 3 per berry
for _, b in ipairs(B) do
  local x, y = b[1], b[2]
  c:px(x - 3, y + 1, "#f5cf6a"); c:px(x + 2, y + 1, "#f5cf6a"); c:px(x, y + 4, "#f5cf6a")
end
local t = c:save(O .. "aseprite/ph/wild-strawberries.aseprite", O .. "png/ph/wild-strawberries.png")
print(GV.report(t))
