local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stem = c:poly({ {26, 34}, {39, 34}, {37, 55}, {28, 55} })
local cap = c:ellipse(32, 18, 24, 7)
for _, s in ipairs({ {12, 23}, {22, 25}, {32, 26}, {42, 25}, {52, 23} }) do
  cap:add(c:ellipse(s[1], s[2], 4.5, 3))
end
cap:add(c:poly({ {16, 22}, {49, 22}, {39, 41}, {26, 41} }))
local p = c:build{
  { "stem", stem, "cream" },
  { "cap", cap, "gold", { gloss = { 18, 15 } } },
  { "dip", c:ellipse(32, 17, 14, 4), "#d0862a", { gloss = false, contact = false } },
}
-- gill ridges running down toward stem
c:fill(c:line({ {20, 28}, {24, 33}, {28, 39} }, 1), "#b8661a")
c:fill(c:line({ {32, 29}, {32, 39} }, 1), "#b8661a")
c:fill(c:line({ {44, 28}, {40, 33}, {36, 39} }, 1), "#b8661a")
-- lip rim along top edge
for x = 18, 46 do
  for y = 10, 14 do
    if cap:has(x, y) and not cap:has(x, y - 1) then c:px(x, y, "#f5cf6a") break end
  end
end
c:ground(32.5, 56, 9, 1.5)
local t = c:save(O .. "aseprite/ph/chanterelle.aseprite", O .. "png/ph/chanterelle.png")
print(GV.report(t))
