local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cane = GV.ramp("#b6814d", { rim = "#f0d49a" })

-- cane in two halves along (10,54)->(50,10), snapped near (30,32); upper half offset 1px
local lower = c:line({ {10, 54}, {27, 35} }, 5)
local upper = c:line({ {34, 28}, {50, 10} }, 5)
-- jagged splinter teeth on both broken ends (gap between them reads as the snap)
lower:add(c:poly({ {24, 34}, {27, 31}, {28, 34}, {30, 32}, {30, 37}, {27, 39} }))
upper:add(c:poly({ {32, 30}, {33, 26}, {35, 25}, {38, 28}, {36, 31}, {35, 29}, {34, 32} }))

local reel = c:ellipse(18, 47, 5.5, 5.5)
local eye = c:ellipse(51, 37, 3.5, 3.5)
eye:cut(c:ellipse(51, 37, 1.5, 1.5))
local sp1 = c:line({ {44, 48}, {48, 46} }, 2)
local sp2 = c:line({ {8, 40}, {12, 38} }, 2)

c:build{
  { "lower", lower, cane, { light = c:line({ {10, 54}, {50, 10} }, 5) } },
  { "upper", upper, cane },
  { "reel",  reel,  "#a8582f" },
  { "eye",   eye,   "#8a4f2a", { gloss = false } },
  { "sp1",   sp1,   cane, { flat = true } },
  { "sp2",   sp2,   cane, { flat = true } },
}
-- cane nodes (bamboo rings)
for _, q in ipairs({ { 17, 48 }, { 24, 40 }, { 40, 21 }, { 46, 15 } }) do
  c:px(q[1], q[2], "#8a4f2a"); c:px(q[1] + 1, q[2] + 1, "#8a4f2a"); c:px(q[1] + 2, q[2] + 2, "#8a4f2a")
end
-- reel hub and handle
c:paint({ ".hh.", "hddh", "hddh", ".hh." }, 16, 45, { h = "#5e2f1e", d = "#ecc58a" })
c:part(c:rect(22, 47, 25, 49), "gold", { flat = true })
-- fishing line: tip curves right then down to the eyelet
c:paint({
  "ll.....",
  "..ll...",
  "....l..",
  ".....l.",
  ".....l.",
  "......l",
  "......l",
  "......l",
  "......l",
  "......l",
  ".....l.",
  ".....l.",
  ".....l.",
  "....l..",
  "....l..",
  "....l..",
  "...l...",
  "...l...",
  "...l...",
  "...l...",
  "...l...",
  "..l....",
}, 50, 10, { l = "#d6c9b6" })
local t = c:save(O .. "aseprite/ph/broken-cane-fishing-rod.aseprite", O .. "png/ph/broken-cane-fishing-rod.png")
print(GV.report(t))
