local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = c:ellipse(31.5, 38, 15, 17)
local cap = c:ellipse(31.5, 31, 16.5, 12):cut(c:rect(0, 31, 63, 63))
cap:add(c:ellipse(31.5, 31, 16.5, 3))
local stalk = c:rrect(30, 13, 33, 21, 1)
local p = c:build{
  { "stalk", stalk, "#2f5a2a", { flat = true } },
  { "shell", shell, GV.ramp("#dcb06a"), { gloss = { 22, 37 } } },
  { "cap",   cap,   GV.ramp("#a5663a"), { gloss = { 22, 23 } } },
}
-- ridge grooves on the cap (curved to follow the dome)
local G = "#5e2f1e"
for _, y in ipairs({ 23, 27 }) do
  for x = 20, 43 do
    if cap:has(x - 2, y) and cap:has(x + 2, y) and cap:has(x, y - 1) and cap:has(x, y + 1) and c:get(x, y) ~= GV.ramp("#a5663a").gloss then c:px(x, y, G) end
  end
end
-- smile crease on the shell
local K = "#8a4f2a"
for _, q in ipairs({ {27,46},{28,47},{29,47},{30,48},{31,48},{32,48},{33,48},{34,47},{35,47},{36,46} }) do
  c:px(q[1], q[2], K)
end
c:seam({ {16, 33}, {47, 33} })
c:button(17, 31)
local t = c:save(O .. "aseprite/ph/macadamia.aseprite", O .. "png/ph/macadamia.png")
print(GV.report(t))
