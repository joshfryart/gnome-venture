local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- big lobed leaf behind, to the right
local leaf = c:ellipse(43, 24, 9, 10)
leaf:cut(c:poly({ {53, 15}, {45, 22}, {50, 13} }))
leaf:cut(c:poly({ {54, 25}, {46, 25}, {54, 29} }))
leaf:cut(c:poly({ {50, 35}, {44, 28}, {46, 36} }))
local fruit = c:ellipse(29, 36, 17, 17)
local stem = c:rrect(27, 13, 31, 21, 1)
local p = c:build{
  { "leaf", leaf, GV.ramp("#4a8a3e") },
  { "fruit", fruit, "moss" },
  { "stem", stem, "wood", { gloss = false } },
}
-- leaf veins from the stem out into each lobe
c:fill(c:line({ {37, 22}, {48, 15} }, 1):clip(leaf):cut(fruit), "#2f5a2a")
c:fill(c:line({ {37, 22}, {50, 22} }, 1):clip(leaf):cut(fruit), "#2f5a2a")
c:fill(c:line({ {37, 23}, {49, 31} }, 1):clip(leaf):cut(fruit), "#2f5a2a")
-- stem top nub
c:fill(c:rect(27, 11, 31, 13), "#5e2f1e")
-- diamond-scale skin pattern across the fruit
local inner = fruit:shrink(3)
for gy = 0, 7 do
  for gx = 0, 7 do
    local x = 14 + gx * 5 + (gy % 2) * 2.5
    local y = 22 + gy * 4
    x = math.floor(x)
    if inner:has(x, y) and inner:has(x, y + 2) and inner:has(x - 1, y + 1) and inner:has(x + 1, y + 1) then
      local s = (x - 29) + (y - 36)
      local cur = c:get(x, y + 1)
      local hi, lo
      if s < 6 then hi, lo = "#a4b86a", "#6a9a3a" else hi, lo = "#7ab55c", "#2f5a2a" end
      if s < -14 then hi = "#c8d77a" end
      c:px(x, y, hi); c:px(x - 1, y + 1, hi); c:px(x + 1, y + 1, lo); c:px(x, y + 2, lo)
    end
  end
end
c:gloss(fruit, GV.R.moss)
local t = c:save(O .. "aseprite/ph/breadfruit.aseprite", O .. "png/ph/breadfruit.png")
print(GV.report(t))
