local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local shell = GV.ramp("#f6d9b8")
local cx, cy, R = 34, 29, 19
local body = c:ellipse(cx, cy, R)
local spout = c:ellipse(17, 46, 7, 6):add(c:poly({ {16, 38}, {12, 46}, {24, 52}, {28, 44} }))
local p = c:build{
  { "body",  body,  shell },
  { "spout", spout, shell },
}
-- spiral groove: two turns, ending toward the spout at lower left
local pts = {}
local endA = math.pi * 0.75 + 4 * math.pi
local N = 80
for i = 0, N do
  local t = i / N
  local a = endA - (1 - t) * 4 * math.pi
  local r = 1.5 + t * 13.5
  pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
end
local groove = c:line(pts, 3):clip(body)
c:fill(groove, "#d28b6a")
local core = c:line(pts, 1):clip(body)
c:fill(core, "#a8582f")
local t = c:save(O .. "aseprite/ico/ico-shell.aseprite", O .. "png/ico/ico-shell.png")
print(GV.report(t))
