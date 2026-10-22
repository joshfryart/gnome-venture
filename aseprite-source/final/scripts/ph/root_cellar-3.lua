local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- flag behind mound
c:part(c:rect(31, 9, 32, 21), GV.ramp("#44281c"), { flat = true })
c:part(c:poly({ { 33, 9 }, { 42, 12 }, { 33, 16 } }), GV.ramp("#d6322b"), { gloss = false })
local mound = c:ellipse(31.5, 52, 25, 32):cut(c:rect(-10, 53, 80, 120))
c:part(mound, GV.ramp("#58a03e", { rim = "#7ab55c" }), { gloss = { 16, 30 } })
-- grass tufts
for _, g in ipairs({ { 13, 27 }, { 50, 28 }, { 9, 40 }, { 52, 42 } }) do
  c:paint({ "g.g", ".g." }, g[1], g[2], { g = "#2e5a2c" })
end
local frame = c:ellipse(32, 38, 13, 12):add(c:rect(19, 38, 45, 52)):cut(c:rect(-10, 53, 80, 120))
c:part(frame, GV.ramp("#968f96"), { gloss = false })
-- stones in frame
for _, s in ipairs({ { 21, 34 }, { 27, 28 }, { 36, 28 }, { 42, 34 }, { 20, 44 }, { 43, 44 } }) do c:px(s[1], s[2], "#5b6470") end
local door = c:ellipse(32, 39, 9, 8):add(c:rect(23, 39, 41, 52)):cut(c:rect(-10, 53, 80, 120))
c:part(door, GV.ramp("#b8784a"), { gloss = { 26, 34 } })
-- planks fanning from arch centre
c:line({ { 28, 33 }, { 27, 52 } }, 1); c:line({ { 32, 31 }, { 32, 52 } }, 1); c:line({ { 36, 33 }, { 37, 52 } }, 1)
door:each(function() end)
for y = 30, 52 do for x = 22, 42 do
  if door:has(x, y) and ((x == 32) or (x == 28 and y >= 33) or (x == 36 and y >= 33) or (x == 27 and y >= 43) or (x == 37 and y >= 43)) then c:px(x, y, "#6a3a1e") end
end end
c:part(c:ellipse(39.5, 45.5, 1.5, 1.5), "gold", { flat = true })
c:part(c:rect(8, 30, 13, 36), "gold", { flat = true })
c:button(9, 26)
c:seam({ { 7, 52 }, { 18, 52 } }); c:seam({ { 46, 52 }, { 55, 52 } })
c:px(54, 22, "#f5cf6a"); c:px(53, 23, "#f5cf6a"); c:px(55, 23, "#f5cf6a"); c:px(54, 24, "#f5cf6a")
c:ground(32, 54, 25, 1.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/root_cellar-3.aseprite", O .. "png/ph/root_cellar-3.png")
print(GV.report(t))
