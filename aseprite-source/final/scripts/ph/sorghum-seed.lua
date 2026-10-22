local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({ {42, 30}, {46, 24}, {52, 20}, {51, 26}, {47, 30} })
local g = { {21, 30, "#f08a24"}, {27, 31, "#e0501f"}, {33, 30, "#f08a24"}, {39, 31, "#e0501f"}, {44, 30, "#f08a24"} }
local p = c:build{
  { "leaf", leaf, "#58a03e", { flat = true } },
  { "foot", c:rrect(22, 51, 42, 56, 1), "#8a4f2a" },
  { "pot", c:ellipse(32, 40, 18, 13), "#d9a660" },
}
c:fill(c:rect(14, 40, 50, 42):clip(p.pot.m), "#f08a24")
for i, v in ipairs(g) do
  c:part(c:ellipse(v[1], v[2], 2.5, 3), v[3], { flat = true })
end
local lid = c:ellipse(32, 25, 13, 10):cut(c:rect(0, 26, 63, 63)):add(c:rrect(18, 23, 46, 27, 1))
c:part(lid, "#b07a45")
c:part(c:ellipse(32, 13, 3.5, 3), "#8a4f2a")
c:seam({ {20, 26}, {44, 26} })
local t = c:save(O .. "aseprite/ph/sorghum-seed.aseprite", O .. "png/ph/sorghum-seed.png")
print(GV.report(t))
