local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- sand dome
local sand = c:ellipse(31.5, 47, 19, 14):cut(c:rect(0, 48, 63, 63))
-- leaning trunk
local trunk = c:line({ {32, 44}, {35, 39}, {36, 34}, {35, 29}, {32, 25} }, 4)
-- three arching fronds, tips drooping
local fronds = c:line({ {31, 23}, {26, 19}, {20, 19}, {16, 22}, {14, 26} }, 4)
fronds:add(c:line({ {33, 23}, {38, 19}, {44, 19}, {48, 22}, {50, 26} }, 4))
fronds:add(c:line({ {32, 23}, {30, 18}, {31, 14}, {35, 12} }, 4))
fronds:add(c:ellipse(32, 23, 4, 3))
-- coconut
local nut = c:ellipse(35.5, 28, 3, 3)
-- wavy sea strip
local sea = c:mask()
for x = 11, 52 do
  local top = math.floor(46 + 1.2 * math.sin((x - 11) / 10 * 2 * math.pi) + 0.5)
  for y = top, top + 4 do sea:set(x, y) end
end
c:build{
  { "sand",   sand,   "#dcb06a" },
  { "trunk",  trunk,  "#b6814d" },
  { "nut",    nut,    "#8c4a1a" },
  { "fronds", fronds, "#58a03e" },
  { "sea",    sea,    "#3f93b2" },
}
-- trunk rings
c:px(33, 40, "#8a4f2a"); c:px(34, 40, "#8a4f2a")
c:px(34, 35, "#8a4f2a"); c:px(35, 35, "#8a4f2a")
-- wave crest glints
for _, x in ipairs({ 14, 24, 34, 44 }) do
  c:px(x, 47, "#c8ecdc"); c:px(x + 1, 46, "#c8ecdc")
end
local t = c:save(O .. "aseprite/ico/ico-island.aseprite", O .. "png/ico/ico-island.png")
print(GV.report(t))
