local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local segs = { {13,37}, {17.5,40}, {22,41}, {26.5,39}, {31,35.5}, {35.5,33}, {40,33.5}, {44,35} }
-- legs (back): dark 2 px sticks
local legs = c:mask()
for i, s in ipairs(segs) do
  local x, y = math.floor(s[1]), math.floor(s[2])
  legs:add(c:line({ {x, y - 4}, {x - 1, y - 7}, {x - 3, y - 8} }, 2))
  legs:add(c:line({ {x, y + 4}, {x - 1, y + 7}, {x - 3, y + 8} }, 2))
end
c:part(legs, GV.ramp("#5e2a3a"), { flat = true })
local dark = GV.ramp("#9c2a1e")
local list = {}
for i, s in ipairs(segs) do
  local r = (i % 2 == 1) and dark or "red"
  list[#list + 1] = { "s" .. i, c:ellipse(s[1], s[2], 4.5, 4.5), r, { gloss = (i % 2 == 0) and { math.floor(s[1]) - 2, math.floor(s[2]) - 3 } or false } }
end
list[#list + 1] = { "head", c:ellipse(49, 33, 6, 5.5), dark }
local p = c:build(list)
-- antennae
c:line({ {47, 28}, {45, 23}, {43, 19} }, 2):each(function(x, y) c:px(x, y, GV.C.ol3) end)
c:line({ {51, 28}, {54, 23}, {56, 19} }, 2):each(function(x, y) c:px(x, y, GV.C.ol3) end)
c:fill(c:rrect(41, 15, 44, 18, 1), GV.C.ol3)
c:fill(c:rrect(55, 15, 58, 18, 1), GV.C.ol3)
c:px(42, 16, "#5e2a3a"); c:px(56, 16, "#5e2a3a")
-- face
c:eye(45, 31, true); c:eye(50, 31, true)
c:paint({ "m...m", ".m.m." }, 46, 36, { m = GV.C.ol3 })
local t = c:save(O .. "aseprite/ph/creature-giant-centipede.aseprite", O .. "png/ph/creature-giant-centipede.png")
print(GV.report(t))
