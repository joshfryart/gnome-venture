local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Catmull-Rom path, stamp discs for a round tube
local P = { {14,44},{14,44},{21,38},{28,37},{35,42},{41,43},{46,37},{47,29},{47,25},{47,25} }
local body = c:mask()
local centre = {}
for i = 2, #P - 2 do
  local p0, p1, p2, p3 = P[i-1], P[i], P[i+1], P[i+2]
  for s = 0, 9 do
    local t = s / 10
    local t2, t3 = t*t, t*t*t
    local function cr(a, b, cc, d) return 0.5*((2*b) + (-a+cc)*t + (2*a-5*b+4*cc-d)*t2 + (-a+3*b-3*cc+d)*t3) end
    local x = cr(p0[1], p1[1], p2[1], p3[1]); local y = cr(p0[2], p1[2], p2[2], p3[2])
    local r = 4.5
    if i == 2 then r = 3.8 + 0.7 * t end
    body:add(c:ellipse(x, y, r, r))
    centre[#centre+1] = { x, y }
  end
end
body:add(c:ellipse(47.5, 23.5, 6, 6))
local pink = GV.ramp("#c9707a")
c:build{ { "body", body, pink } }
-- segment rings: short light bands across the tube
for k = 6, #centre - 12, 9 do
  local a, b = centre[k], centre[k+1]
  local dx, dy = b[1]-a[1], b[2]-a[2]
  local L = math.sqrt(dx*dx+dy*dy); if L == 0 then L = 1 end
  local nx, ny = -dy/L, dx/L
  local x0, y0 = math.floor(a[1] - nx*2 + 0.5), math.floor(a[2] - ny*2 + 0.5)
  local x1, y1 = math.floor(a[1] + nx*2 + 0.5), math.floor(a[2] + ny*2 + 0.5)
  c:fill(c:line({ {x0,y0}, {x1,y1} }, 1), "#e3949b")
end
c:eye(47, 20, true)
c:paint({ "m...m", ".mmm." }, 47, 26, { m = "#3b2223" })
c:ground(30, 50, 17, 1.5)
local t = c:save(O .. "aseprite/animals/worm.aseprite", O .. "png/animals/worm.png")
print(GV.report(t))
