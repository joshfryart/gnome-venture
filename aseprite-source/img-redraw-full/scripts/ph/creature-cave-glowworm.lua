local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local brown = GV.ramp("#a5663a")
local lx, ly = 45, 41
-- glow rings (hard, stepped, outside the silhouette)
local outer = c:ellipse(lx, ly, 8.5, 8.5)
local inner = c:ellipse(lx, ly, 6.5, 6.5)
local body = {
  {"seg1", c:ellipse(20, 44, 5.5, 5.5)},
  {"seg2", c:ellipse(26.5, 42.5, 5.5, 5.5)},
  {"seg3", c:ellipse(33, 43, 5.5, 5.5)},
  {"seg4", c:ellipse(38.5, 44.5, 5.5, 5.5)},
}
local parts = {
  { "glowO", outer, GV.ramp("#f0bf56"), { flat = true, rim = false, contact = false, contour = false } },
  { "glowI", inner, GV.ramp("#f8db8c"), { flat = true, rim = false, contact = false, contour = false } },
}
for i = #body, 1, -1 do
  parts[#parts + 1] = { body[i][1], body[i][2], tan, { cres = 3, deep = 1 } }
end
parts[#parts + 1] = { "lamp", c:ellipse(lx + 0.5, 43, 5.5, 5.5), "gold", { cres = 3, contour = false } }
parts[#parts + 1] = { "head", c:ellipse(14.5, 43.5, 4.5, 4.5), brown, { cres = 3, gloss = false } }
local p = c:build(parts)
-- lamp core: warm cream glow inside the gold
c:fill(c:ellipse(45, 42.5, 2.5, 2.5), "#f8eed2")
c:px(44, 41, "#fff3c8")
-- seam along the back
c:seam({ {19, 39}, {26, 37}, {33, 37.5}, {40, 39.5} })
-- small eye, set at the front of the head
c:eye(11, 41, true)
local t = c:save(O .. "aseprite/ph/creature-cave-glowworm.aseprite", O .. "png/ph/creature-cave-glowworm.png")
print(GV.report(t))
