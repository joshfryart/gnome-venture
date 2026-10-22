local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- three glass tubes (pills), x 10,23,36 width 10
local xs = { 10, 23, 36 }
local soils = { "#3d2a1c", "#9a6b3f", "#c9a96e" }
local list = {}
for i, x in ipairs(xs) do
  local tube = c:rrect(x, 12, x + 9, 43, 4)
  list[#list + 1] = { "tube" .. i, tube, "glass", { cres = 3 } }
end
-- soil fills (lower part inside glass)
for i, x in ipairs(xs) do
  local fill = c:rrect(x + 2, 21 + (i - 1) * 3, x + 7, 41, 2)
  list[#list + 1] = { "soil" .. i, fill, GV.ramp(soils[i]), { gloss = false, cres = 2, contact = false } }
end
-- caps
for i, x in ipairs(xs) do
  list[#list + 1] = { "cap" .. i, c:rrect(x - 1, 9, x + 10, 13, 1), "wood", { flat = true } }
end
-- dropper: glass stem + red bulb
list[#list + 1] = { "dstem", c:rrect(51, 22, 55, 43, 2), "glass", { gloss = false, cres = 2 } }
list[#list + 1] = { "dcollar", c:rect(50, 21, 56, 24), "wood", { flat = true } }
list[#list + 1] = { "bulb", c:ellipse(53, 17, 4, 5), "red", { cres = 2 } }
-- tray front + rack bar
list[#list + 1] = { "tray", c:rrect(8, 37, 56, 52, 3), "wood" }
list[#list + 1] = { "bar", c:rect(8, 35, 56, 39), GV.ramp("#8a4f2a"), { gloss = false, cres = 2 } }
local p = c:build(list)

-- extra glass glints on tubes
for _, x in ipairs(xs) do
  c:px(x + 2, 16, GV.R.glass.gloss); c:px(x + 2, 17, GV.R.glass.gloss)
end
c:seam({ { 11, 44 }, { 53, 44 } })
local t = c:save(O .. "aseprite/ph/soil-test-kit.aseprite", O .. "png/ph/soil-test-kit.png")
print(GV.report(t))
