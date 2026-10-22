local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local shell = GV.ramp("#dcb06a")
local backR = GV.ramp("#c4914f")

-- back shell wall: thin arc visible above the front shell at the tips
local back = c:ellipse(31, 28, 24.5, 24):clip(c:rect(0, 26, 63, 52))
-- lettuce frill: band plus 5 big scallops spilling over the top
local let = c:rect(9, 26, 53, 33)
for i, x in ipairs({ 12, 21.5, 31, 40.5, 50 }) do
  let:add(c:ellipse(x, (i % 2 == 0) and 24 or 26, 5, 5))
end
-- tomatoes
local tom = c:ellipse(17, 24, 3.5, 3.5)
tom:add(c:ellipse(31.5, 21, 3.5, 3.5))
tom:add(c:ellipse(46, 23.5, 3.5, 3.5))
-- front shell: true half-moon, flat top at y 31
local front = c:ellipse(31, 31, 25.5, 23):clip(c:rect(0, 31, 63, 63))
local all = back:copy():add(front)

local p = c:build{
  { "back",  back,  backR },
  { "let",   let,   "moss" },
  { "tom",   tom,   GV.ramp("#d6322b") },
  { "front", front, shell, { light = all } },
}
-- fold line following the shell curve
local pts = {}
for a = 15, 165, 10 do
  local r = math.rad(a)
  pts[#pts + 1] = { math.floor(31.5 + 21 * math.cos(r) + 0.5), math.floor(31 + 17 * math.sin(r) + 0.5) }
end
c:fill(c:line(pts, 2):clip(front:shrink(3)), "#b07a45")
-- toasted dimples
c:px(22, 38, "#b07a45"); c:px(41, 37, "#b07a45"); c:px(32, 40, "#b07a45")
local t = c:save(O .. "aseprite/ico/ico-taco.aseprite", O .. "png/ico/ico-taco.png")
print(GV.report(t))
