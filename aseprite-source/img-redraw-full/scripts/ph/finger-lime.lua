local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bodyR = GV.ramp("moss", { gloss = "#c8d77a", deep = "#2f5a2a" })
-- slightly oblong citrus with a pointed bottom nub
local body = c:ellipse(31.5, 35, 15, 17)
body:add(c:poly({ {28, 49}, {35, 49}, {32, 56}, {31, 56} }))
local stem = c:line({ {31, 21}, {31, 15} }, 3)
local leaf = c:poly({ {32, 19}, {34, 12}, {40, 7}, {46, 6}, {44, 12}, {38, 17} })
local cap = c:ellipse(31.5, 19.5, 4, 2)
local p = c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "body", body, bodyR, { gloss = { 23, 26 } } },
  { "leaf", leaf, "#58a03e", { gloss = { 38, 10 } } },
  { "cap", cap, "#4a8a3e", { flat = true } },
}
for _, q in ipairs({ {35,15},{36,14},{37,13},{38,12},{39,11},{40,10},{41,9},{42,8} }) do c:px(q[1], q[2], "#3f7a2e") end
-- curved rind line with seed dots
local rind = { {19,37},{20,38},{21,38},{22,39},{23,39},{24,39},{25,40},{26,40},{27,40},{28,40},{29,40},{30,40},{31,40},{32,40},{33,40},{34,40},{35,39},{36,39},{37,39},{38,39},{39,38},{40,38},{41,37},{42,37},{43,36},{44,36} }
for _, q in ipairs(rind) do c:px(q[1], q[2], "#2f5a2a") end
c:paint({ "cc", "cc" }, 25, 43, { c = "#c8d77a" })
c:paint({ "cc", "cc" }, 34, 43, { c = "#c8d77a" })
c:px(29, 46, "#c8d77a")
c:ground(31.5, 56, 15, 2.5)
local t = c:save(O .. "aseprite/ph/finger-lime.aseprite", O .. "png/ph/finger-lime.png")
print(GV.report(t))
