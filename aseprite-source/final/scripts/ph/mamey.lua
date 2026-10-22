local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 38, 17.5, 17)
local stem = c:rrect(30, 15, 33, 23, 1)
local leaf = c:poly({ {33,20}, {37,15}, {43,12}, {50,11}, {47,16}, {41,20}, {35,22} })
c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
  { "body", body, "gold", { gloss = { 23, 29 } } },
}
for _, p in ipairs({ {36,19}, {37,18}, {38,17}, {39,17}, {40,16}, {41,16}, {42,15}, {43,14}, {44,14}, {45,13} }) do c:px(p[1], p[2], "#2f5a2a") end
-- two-tone lower belly: repaint base pixels below a gentle curve
local base = GV.R.gold.base
body:each(function(x, y)
  local edge = 42 + math.floor(((x - 31.5) / 17.5) ^ 2 * -3 + 0.5)
  if y >= edge and c:get(x, y) == base then c:px(x, y, "#d0862a") end
end)
-- warm speckles (2 px beans)
for _, q in ipairs({ {37,45}, {42,38}, {33,50}, {27,46} }) do
  c:px(q[1], q[2], "#b8661a"); c:px(q[1] + 1, q[2], "#b8661a")
end
local t = c:save(O .. "aseprite/ph/mamey.aseprite", O .. "png/ph/mamey.png")
print(GV.report(t))
