local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 50, 23.5, 34):cut(c:rect(0, 50, 63, 120))
local arch = c:ellipse(32, 37, 14, 13):cut(c:rect(0, 37, 63, 63)):add(c:rect(18, 37, 46, 49))
local door = c:ellipse(32, 38, 10, 9.5):cut(c:rect(0, 38, 63, 63)):add(c:rect(22, 38, 42, 49))
local p = c:build{
  { "mound", mound, GV.ramp("#58a03e"), { gloss = { 16, 25 } } },
  { "arch", arch, GV.ramp("#968f96"), { gloss = false } },
  { "door", door, GV.ramp("#a5663a"), { gloss = { 25, 33 } } },
}
-- stone blocks on arch
c:paint({ "s" }, 20, 34, { s = "#4a2c1a" })
for _, q in ipairs({ {19,33},{20,33},{23,28},{24,29},{31,24},{31,25},{39,28},{40,29},{43,33},{44,33},{18,42},{19,42},{20,42},{44,42},{45,42},{46,42} }) do
  c:px(q[1], q[2], "#4a2c1a")
end
-- planks
for y = 29, 49 do if door:has(32, y) then c:px(32, y, "#44281c") end end
for y = 33, 49 do
  if door:has(26, y) then c:px(26, y, "#44281c") end
  if door:has(38, y) then c:px(38, y, "#44281c") end
end
-- crossbar
for x = 23, 41 do if door:has(x, 44) then c:px(x, 44, "#5e2f1e") end end
-- latch
c:paint({ ".gg.", "gyyg", "gyyg", ".gg." }, 34, 39, { g = "#b8661a", y = "#f5cf6a" })
-- grass tufts
local t1 = { "#2f5a2a" }
for _, l in ipairs({ { {12,22},{11,18} }, { {14,22},{15,19} }, { {50,24},{52,21} }, { {12,36},{10,34} }, { {52,37},{54,35} } }) do
  local m = c:line(l, 1)
  m:each(function(x, y) c:px(x, y, "#2f5a2a") end)
end
c:seam({ {22, 30}, {27, 25}, {32, 23}, {37, 25}, {42, 30} }, { free = false })
c:ground(32, 50, 23, 1.5)
local t = c:save(O .. "aseprite/ph/root_cellar-1.aseprite", O .. "png/ph/root_cellar-1.png")
print(GV.report(t))
