local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(11, 29, 52, 54, 3)
local lid = c:poly({ {11, 21}, {52, 17}, {53, 29}, {11, 31} }):closed(1)
local pod = c:poly({ {17, 49}, {20, 43}, {27, 38}, {36, 35}, {44, 35}, {48, 37}, {46, 42}, {39, 47}, {30, 50}, {21, 51} })
local leaf = c:poly({ {45, 10}, {50, 18}, {40, 18} })
c:build{
  { "body", body, GV.ramp("#968f96") },
  { "leaf", leaf, "#2f5a2a", { flat = true } },
  { "lid",  lid,  GV.ramp("#c9c5bc"), { gloss = { 16, 22 } } },
  { "pod",  pod,  GV.ramp("#8c4a1a"), { gloss = { 23, 43 } } },
}
-- gap strip under the propped lid
for x = 13, 50 do c:px(x, 32, "#5b6470") end
-- hinges at the back top edge
c:paint({ ".gg.", "gggg", "gggg", ".gg." }, 17, 18, { g = "#e8a317" })
c:paint({ ".gg.", "gggg", "gggg", ".gg." }, 42, 16, { g = "#e8a317" })
c:px(18, 19, "#fff1c8"); c:px(43, 17, "#fff1c8")
-- pod ridge and beans
c:fill(c:line({ {20, 48}, {28, 44}, {37, 40}, {45, 38} }, 1), "#44281c")
for _, p in ipairs({ {24, 45}, {31, 42}, {38, 39} }) do
  c:paint({ ".b.", "bbb", ".b." }, p[1], p[2] - 1, { b = "#44281c" })
end
-- stem tab
c:fill(c:line({ {17, 49}, {14, 52} }, 2), "#2e5a2c")
-- seam along lid line, latch button
c:seam({ {14, 34}, {50, 34} })
c:button(30, 30)
local t = c:save(O .. "aseprite/ph/cacao-seed.aseprite", O .. "png/ph/cacao-seed.png")
print(GV.report(t))
