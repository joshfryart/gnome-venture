-- flowers/spike : tapering column of paired dusk-purple buds
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ramp = GV.ramp("#7b66b4", { gloss = "#a894dc", shade = "#3e2f66" })

-- source buds {x, y, rx, ry}
local src = {
  {19,55,5,4},{32,56,5,4},{45,55,5,4},
  {22,50,5,4},{42,50,5,4},{32,46,5,4},
  {21,44,5,4},{43,44,5,4},
  {23,40,5,4},{41,40,5,4},
  {22,34,5,4},{42,34,5,4},{32,36,5,4},
  {24,30,5,4},{40,30,5,4},
  {24,24,5,4},{40,24,5,4},{32,25,5,4},
  {26,20,5,4},{38,20,5,4},
  {25,13,5,4},{39,13,5,4},{32,15,5,4},
  {27,10,4.5,4},{37,10,4.5,4},
  {32,5,3,4},
}
local SX, SY = 0.9, 0.8
local buds = {}
for _, b in ipairs(src) do
  buds[#buds+1] = { 31.5 + (b[1]-32)*SX*(0.75 + 0.3*b[2]/56) + (b[1] > 32 and 0.5 or (b[1] < 32 and -0.5 or 0)), 9 + (b[2]-1)*SY, b[3]*SX, b[4]*0.9 }
end
table.sort(buds, function(a, b) return a[2] < b[2] end) -- top (back) to bottom (front)
for i, b in ipairs(buds) do
  c:part(c:ellipse(math.floor(b[1]*2+0.5)/2, math.floor(b[2]+0.5), b[3], b[4]), ramp, { cres = 3, deep = 1, contour = "#291d4a", gloss = (i % 2 == 0) and false or nil })
end

local t = c:save(O .. "aseprite/flowers/spike.aseprite", O .. "png/flowers/spike.png")
print(GV.report(t))
