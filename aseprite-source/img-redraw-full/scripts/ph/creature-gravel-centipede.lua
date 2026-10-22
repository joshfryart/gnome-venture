local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local LT = GV.ramp("#6e7685")
local DK = GV.ramp("#4a5160")
local LEG = GV.ramp("#2f3440")
local seg = { {14.5,44}, {21.5,39}, {28.5,36}, {35.5,31}, {42.5,28} }
-- legs: one bent pair per segment, back to front
local legs = c:mask()
for _, s in ipairs(seg) do
  local x, y = math.floor(s[1]), s[2]
  legs:add(c:line({ {x-2, y+4}, {x-3, y+8}, {x-5, y+9} }, 2))
  legs:add(c:line({ {x+2, y+4}, {x+3, y+8}, {x+4, y+9} }, 2))
end
local spec = { { "legs", legs, LEG, { flat = true } } }
for i, s in ipairs(seg) do
  spec[#spec+1] = { "s"..i, c:ellipse(s[1], s[2], 5.5, 6), (i % 2 == 1) and LT or DK }
end
spec[#spec+1] = { "head", c:ellipse(49.5, 22, 6.5, 6.5), DK }
local ant = c:line({ {52, 16}, {55, 11} }, 2):add(c:line({ {47, 16}, {46, 11} }, 2))
ant:add(c:rect(54, 8, 57, 11)):add(c:rect(44, 8, 47, 11))
spec[#spec+1] = { "ant", ant, LEG, { flat = true } }
local p = c:build(spec)
-- lavender joint links
c:fill(c:line({ {18, 37}, {18, 44} }, 1):clip(p.s2.m), "#8f7fc9")
c:fill(c:line({ {32, 30}, {32, 37} }, 1):clip(p.s4.m), "#8f7fc9")
-- pebble flecks
c:spot(c:rect(25, 32, 26, 33), "#a9afba", false)
c:spot(c:rect(39, 25, 41, 26), "#a9afba", false)
c:spot(c:rect(12, 45, 13, 46), "#a9afba", false)
c:eye(45, 20, true); c:eye(51, 20, true)
c:paint({ "u.u", ".u." }, 48, 25, { u = "umber" })
c:ground(28, 53, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-gravel-centipede.aseprite", O .. "png/ph/creature-gravel-centipede.png")
print(GV.report(t))
