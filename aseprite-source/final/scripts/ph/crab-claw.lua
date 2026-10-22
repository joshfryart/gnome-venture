local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local coral = GV.ramp("#f2793a")
local red = "red"
local wrist = c:rrect(25, 45, 39, 57, 3)
local lj = c:poly({ {18,38},{12,26},{11,16},{14,8},{17,6},{20,10},{23,20},{30,32} })
local rj = c:poly({ {46,38},{52,26},{53,16},{50,8},{47,7},{44,11},{41,20},{34,32} })
local palm = c:ellipse(32, 39, 14, 10)
local p = c:build{
  { "wrist", wrist, GV.ramp("#d9885a") },
  { "rj", rj, red },
  { "lj", lj, coral },
  { "palm", palm, coral },
}
-- teeth along inner edges (cream nubs pointing into the gap)
local T = "#f1ece0"
for _, t in ipairs({ {20,13},{22,19},{25,25} }) do
  c:px(t[1], t[2], T); c:px(t[1]+1, t[2], T); c:px(t[1]+1, t[2]+1, T)
end
for _, t in ipairs({ {43,14},{41,20},{38,26} }) do
  c:px(t[1], t[2], T); c:px(t[1]+1, t[2], T); c:px(t[1], t[2]+1, T)
end
-- knuckle bumps
c:spot(c:ellipse(25, 36, 1.5, 1), "#ffc27a")
c:spot(c:ellipse(31, 34, 1.5, 1), "#ffc27a")
c:spot(c:ellipse(37, 35, 1.5, 1), "#ffc27a")
-- wrist band ridges
c:seam({ {26, 51}, {38, 51} }, { gap = "#c47a52" })
local t = c:save(O .. "aseprite/ph/crab-claw.aseprite", O .. "png/ph/crab-claw.png")
print(GV.report(t))
