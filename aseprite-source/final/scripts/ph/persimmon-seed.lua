local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local seed = c:ellipse(31.5, 28, 11, 10)
local calyx = c:poly({ {25,19}, {28,16}, {31,18}, {33,14}, {35,18}, {38,16}, {39,20}, {33,21}, {29,21} })
local leaf = c:poly({ {39,15}, {47,8}, {50,10}, {44,17} })
local crate = c:rrect(11, 33, 52, 55, 1)
local postL = c:rect(11, 31, 17, 56)
local postR = c:rect(46, 31, 52, 56)
c:build{
  { "seed", seed, "#f08a24" },
  { "leaf", leaf, "#4a8a3e", { flat = true } },
  { "calyx", calyx, "#2e5a2c", { flat = true } },
  { "crate", crate, "wood" },
  { "postL", postL, "#8a4f2a" },
  { "postR", postR, "#8a4f2a" },
}
-- slat gaps
c:fill(c:rect(18, 40, 45, 41), "#5e2f1e")
c:fill(c:rect(18, 48, 45, 49), "#5e2f1e")
-- plank grain ticks
c:px(24, 37, "#8a4f2a"); c:px(25, 37, "#8a4f2a"); c:px(38, 45, "#8a4f2a"); c:px(39, 45, "#8a4f2a"); c:px(29, 52, "#8a4f2a"); c:px(30, 52, "#8a4f2a")
-- leaf midrib
c:px(43, 13, "#2e5a2c"); c:px(44, 12, "#2e5a2c"); c:px(45, 11, "#2e5a2c")
-- nails
for _, p in ipairs({ {13,33}, {48,33}, {13,52}, {48,52} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#ecc58a")
end
local t = c:save(O .. "aseprite/ph/persimmon-seed.aseprite", O .. "png/ph/persimmon-seed.png")
print(GV.report(t))
