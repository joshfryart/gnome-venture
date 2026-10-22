local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fruit = c:ellipse(31.5, 37, 16, 16)
local stem = c:rect(30, 15, 32, 22)
local leaf = c:poly({ {32, 18}, {35, 12}, {40, 8}, {46, 7}, {44, 12}, {39, 17} })
local calyx = c:ascii({
  "..x.x..",
  ".xxxxx.",
  "xxxxxxx",
}, 28, 20)

c:build{
  { "fruit", fruit, GV.ramp("#f08a24", { shade = "#e0501f" }) },
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaf", leaf, "#7ab55c", { gloss = false } },
  { "calyx", calyx, "#4a8a3e", { flat = true } },
}
-- leaf midrib
c:fill(c:line({ {35, 15}, {40, 11}, {44, 9} }, 1), GV.R.moss.shade)

-- a row of pore dimples
for _, p in ipairs({ {37, 34}, {41, 38}, {35, 43}, {26, 46} }) do c:px(p[1], p[2], GV.R.gold.bounce) end

local t = c:save(O .. "aseprite/ph/orange.aseprite", O .. "png/ph/orange.png")
print(GV.report(t))
