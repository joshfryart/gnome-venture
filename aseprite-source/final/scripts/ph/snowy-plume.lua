local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- leaf-shaped vane along axis (17,53)->(50,9), widest near (30,34)
local ax, ay, bx, by = 20, 49, 47, 14
local dx, dy = bx - ax, by - ay
local L = math.sqrt(dx * dx + dy * dy)
local ux, uy = dx / L, dy / L
local nx, ny = -uy, ux
local vane = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local px, py = x + 0.5 - ax, y + 0.5 - ay
  local t = (px * ux + py * uy) / L
  local d = px * nx + py * ny
  if t >= 0 and t <= 1 then
    local w = 9.5 * math.sin(math.pi * (t ^ 0.8)) ^ 0.9
    -- left side (upper-left) slightly fuller
    local lim = (d < 0) and w * 1.0 or w * 0.85
    if math.abs(d) <= lim then vane:set(x, y) end
  end
end end
-- notches on the lower-right side
vane:cut(c:poly({ {39,30}, {43,27}, {42,31} }))
vane:cut(c:poly({ {34,38}, {38,36}, {36,41} }))
c:part(vane, "dusk", { gloss = { 25, 27 } })
-- barbs on the upper-left side
local bar = "#3e2f66"
c:line({ {27,39}, {23,36} }, 2)
c:line({ {32,32}, {28,29} }, 2)
c:line({ {37,25}, {34,22} }, 2)
c:fill(c:line({ {27,39}, {23,36} }, 2), bar)
c:fill(c:line({ {32,32}, {28,29} }, 2), bar)
c:fill(c:line({ {37,25}, {34,22} }, 2), bar)
-- quill across the vane
local quill = c:line({ {19,51}, {43,19} }, 3)
c:part(quill, GV.ramp("#4e3a8a"), { flat = true, contour = false, contact = false })
c:fill(c:line({ {21,48}, {42,20} }, 1), "#6a56a8")
-- bare cream stem
local stem = c:line({ {15,55}, {19,50} }, 3)
c:part(stem, "cream", { flat = true, contour = false })
local t = c:save(O .. "aseprite/ph/snowy-plume.aseprite", O .. "png/ph/snowy-plume.png")
print(GV.report(t))
