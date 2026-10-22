local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- leaves (behind the root top)
local leafL = c:ellipse(25, 12, 4, 5.5):add(c:poly({ {28,14}, {33,18}, {30,18}, {26,15} }))
local leafR = c:ellipse(39, 11.5, 4, 5.5):add(c:poly({ {36,14}, {34,18}, {31,18}, {37,13} }))
-- root: tapered, slightly knobby
local root = c:poly({ {21,19}, {43,19}, {42,26}, {40,33}, {38,40}, {36,47}, {34,53}, {32,58}, {30,53}, {28,46}, {26,39}, {24,32}, {22,26} })
root:add(c:ellipse(24, 40, 2, 2))
root:add(c:ellipse(40, 33, 2, 2))
local top = c:ellipse(32, 19, 11, 3)
root:cut(top)
local p = c:build{
  { "leafL", leafL, "moss", { flat = true } },
  { "leafR", leafR, GV.ramp("#6a9a3a"), { flat = true } },
  { "root", root, "#9a6b3f", { light = root:copy():add(top) } },
  { "top", top, GV.ramp("#f1ece0"), { gloss = false, contact = false } },
}
-- cut ring and pale core
c:outline(top)
local ring = top:copy():cut(top:shrink(1))
c:fill(ring, "#ecc58a")
c:px(31, 19, "#c9a96e"); c:px(32, 19, "#c9a96e")
-- leaf veins
for _, q in ipairs({ {28,15},{27,14},{26,13},{26,12},{25,11},{25,10},{25,9},{25,8} }) do c:px(q[1], q[2], "#2f5a2a") end
for _, q in ipairs({ {36,15},{37,14},{38,13},{38,12},{39,11},{39,10},{39,9},{39,8} }) do c:px(q[1], q[2], "#2f5a2a") end
-- bark rings
for x = 24, 40 do if root:has(x, 28) and root:has(x - 1, 28) and root:has(x + 1, 28) then c:px(x, 28, "#5e2f1e") end end
for x = 26, 38 do if root:has(x - 1, 38) and root:has(x + 1, 38) then c:px(x, 38, "#5e2f1e") end end
for x = 28, 36 do if root:has(x - 1, 46) and root:has(x + 1, 46) then c:px(x, 46, "#5e2f1e") end end
-- lumps
c:fill(c:ellipse(24, 40, 1, 1), "#7a4a1f")
c:fill(c:ellipse(40, 33, 1, 1), "#7a4a1f")
local t = c:save(O .. "aseprite/ph/cassava.aseprite", O .. "png/ph/cassava.png")
print(GV.report(t))
