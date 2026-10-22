local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lens pod from (10,42) to (54,20)
local ax, ay, bx, by = 14, 43, 53, 22
local cx, cy = (ax + bx) / 2, (ay + by) / 2
local L = math.sqrt((bx-ax)^2 + (by-ay)^2) / 2
local ux, uy = (bx-ax) / (2*L), (by-ay) / (2*L)
local pod = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x + 0.5 - cx, y + 0.5 - cy
  local a = dx*ux + dy*uy
  local b = -dx*uy + dy*ux
  local half = 11.5 * math.max(0, 1 - (a/L)^2) ^ 0.6
  if b > -half*0.8 and b < half then pod:set(x, y) end
end end
local stalk = c:line({ {13, 42}, {10, 46} }, 3)
local nuts = { {24, 33}, {33, 29}, {42, 25} }
local parts = {
  { "stalk", stalk, "moss", { flat = true } },
  { "pod", pod, "petal" },
}
for i, n in ipairs(nuts) do
  parts[#parts+1] = { "nut" .. i, c:ellipse(n[1], n[2], 5, 5), GV.ramp("#a8241f", { shade = "#6b1b2c" }),
    { gloss = (i == 1) and { n[1]-2, n[2]-2 } or false } }
end
c:build(parts)

c:fill(c:line({ {17, 41}, {23, 40}, {30, 37}, {39, 34}, {47, 30}, {51, 27} }, 2), "#6b1b2c")
for i, n in ipairs(nuts) do
  if i > 1 then c:px(n[1]-2, n[2]-2, "#ff9158"); c:px(n[1]-1, n[2]-3, "#ff9158") end
end
local t = c:save(O .. "aseprite/ph/bambara.aseprite", O .. "png/ph/bambara.png")
print(GV.report(t))
