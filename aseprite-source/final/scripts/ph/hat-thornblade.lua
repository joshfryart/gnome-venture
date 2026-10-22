local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crown = c:poly({
  {13,47},{13,38},{15,30},{19,23},{25,17},{32,12},{39,9},{45,8},{50,10},
  {48,13},{44,14},{40,17},{38,22},{39,29},{43,36},{48,42},{51,47}
})
local p = c:build{
  { "brim",    c:ellipse(32, 49, 24, 6.5), GV.ramp("#ae2a2a") },
  { "brimtop", c:ellipse(32, 47, 21, 4),   "red" },
  { "crown",   crown, "red", { light = crown:copy():add(c:ellipse(32,49,24,6.5)) } },
  { "band",    c:rrect(13, 40, 50, 46, 2), GV.ramp("#b8452f", { rim = "#ecc58a" }) },
  { "blade",   c:poly({ {26,41},{32,25},{39,41} }), GV.ramp("#f1ece0") },
  { "bobble",  c:ellipse(50, 10.5, 3.5, 3.5), "gold", { gloss = { 49, 9 } } },
}
c:seam({ {14,41}, {49,41} })
for y = 28, 38 do c:px(32, y, "#8b8f96") end
c:px(22, 49, "#f9d49c"); c:px(42, 51, "#f9d49c"); c:px(29, 53, "#f9d49c")
c:ground(32, 56.5, 22, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/hat-thornblade.aseprite", D .. "img-redraw-full/png/ph/hat-thornblade.png")
print(GV.report(t))
