local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- bundle body: rounded sack, wider at bottom
local body = c:ellipse(31.5, 42, 19, 14):add(c:rrect(16, 28, 47, 54, 9))
body:cut(c:rect(0, 57, 63, 63))
-- gathered neck + ruffle tips flaring out
local neck = c:poly({ {26, 26}, {38, 26}, {35, 19}, {29, 19} })
neck:add(c:poly({ {29, 20}, {22, 11}, {27, 10}, {32, 18} }))
neck:add(c:poly({ {32, 18}, {37, 10}, {42, 11}, {35, 20} }))
local tie = c:rrect(23, 22, 40, 25, 1)
local bow = c:ellipse(43, 22, 3, 2.5):cut(c:ellipse(43, 22, 1, 0.5))
bow:add(c:rect(40, 23, 42, 24))
local patch = c:ellipse(31.5, 41, 10, 10)
local seed = c:ellipse(31.5, 41, 7, 7)

local cream = "#f1ece0"
local p = c:build{
  { "neck", neck, cream },
  { "body", body, cream, { stitch = { side = "lit" } } },
  { "tie", tie, "#dcb06a", { cres = 1 } },
  { "bow", bow, "#dcb06a", { flat = true } },
  { "patch", patch, "#7ab55c", { gloss = false, contact = false } },
  { "inner", c:ellipse(31.5, 41, 8, 8), "#f4f0e0", { gloss = false, contact = false, cres = 1, deep = 0 } },
  { "seed", seed, "moss" },
}
-- sprout
c:paint({
  "....ll.",
  "...llll",
  "..s.ll.",
  "..s....",
  "..s....",
  "..s....",
}, 30, 28, { s = "#4a8a3e", l = "#58a03e" })
c:px(32, 33, "#4a8a3e")
c:seam({ {24, 23}, {39, 23} })
-- stitch dots
c:px(26, 53, "#8c4a1a"); c:px(32, 54, "#8c4a1a"); c:px(38, 53, "#8c4a1a")
local t = c:save(O .. "aseprite/ph/damask-rose-seed.aseprite", O .. "png/ph/damask-rose-seed.png")
print(GV.report(t))
