local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tuft = c:line({ {31, 21}, {25, 11} }, 3):add(c:line({ {32, 21}, {32, 8} }, 3)):add(c:line({ {33, 21}, {39, 11} }, 3))
local p = c:build{
  { "tuft", tuft, "moss", { gloss = false } },
  { "stem", c:rect(31, 16, 33, 22), "#2f5a2a", { flat = true } },
  { "fruit", c:ellipse(32, 38, 17, 17), "water" },
}
-- diamond lattice
local fm = p.fruit.m:shrink(2)
for x = 0, 63 do for y = 0, 63 do
  if fm:has(x, y) and ((x + y) % 8 == 0 or (x - y) % 8 == 0) then
    local col = c:get(x, y)
    if col == GV.R.water.base or col == GV.R.water.rim then c:px(x, y, GV.R.water.shade) elseif col ~= GV.R.water.gloss and col ~= GV.R.water.dot then c:px(x, y, "#5a86b8") end
  end
end end
local t = c:save(O .. "aseprite/ph/pandanus.aseprite", O .. "png/ph/pandanus.png")
print(GV.report(t))
