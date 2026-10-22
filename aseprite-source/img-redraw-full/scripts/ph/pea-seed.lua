local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local env = c:rrect(19, 8, 45, 55, 3)
local p = c:build{
  { "env", env, GV.ramp("#f1ece0") },
  { "flap", c:poly({ {19,8}, {46,8}, {32,27} }), GV.ramp("#dcb06a"), { light = env } },
  { "seal", c:ellipse(32, 27, 3, 3), "red" },
  { "pod", c:poly({ {21,53}, {23,45}, {29,38}, {37,33}, {46,30}, {45,37}, {39,45}, {30,51} }), GV.ramp("#7ab55c") },
}
-- pod stem
c:fill(c:line({ {22,51}, {20,54} }, 2), "#2f5a2a")
-- peas
local peas = { {28,45}, {34,40}, {40,36} }
for _, q in ipairs(peas) do
  local x, y = q[1], q[2]
  c:fill(c:rrect(x-2, y-2, x+1, y+1, 1), "#a4cf5a")
  c:px(x+1, y, "#4a8a3e"); c:px(x, y+1, "#4a8a3e"); c:px(x, y, "#58a03e")
  c:px(x-1, y-1, "#e8f2a8")
end
c:seam({ {20, 9}, {32, 26}, {45, 9} })
c:ground(32, 56, 12, 1.5)
local t = c:save(O .. "aseprite/ph/pea-seed.aseprite", O .. "png/ph/pea-seed.png")
print(GV.report(t))
