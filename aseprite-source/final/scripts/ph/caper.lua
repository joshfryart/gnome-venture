local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stem = c:line({ {31, 54}, {30, 46}, {29, 40} }, 3)
stem:add(c:line({ {29, 41}, {24, 40}, {19, 39} }, 3))
stem:add(c:line({ {30, 41}, {37, 39}, {43, 38} }, 3))

local p = c:build{
  { "stem",  stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "lbud",  c:ellipse(17.5, 33, 6, 6), GV.ramp("#7ab55c"), { gloss = { 15, 30 } } },
  { "rbud",  c:ellipse(45.5, 31, 6, 6), GV.ramp("#7ab55c"), { gloss = { 43, 28 } } },
  { "sepL",  c:rrect(14, 38, 21, 40, 1), GV.ramp("#2f5a2a"), { flat = true } },
  { "sepR",  c:rrect(42, 36, 49, 38, 1), GV.ramp("#2f5a2a"), { flat = true } },
  { "bud",   c:ellipse(31.5, 29, 10, 11), GV.ramp("#6a9a3a", { rim = "#a4b86a" }), { gloss = { 26, 23 } } },
  { "petal", c:ascii({ ".pp.", "pppp", ".pp." }, 30, 16), GV.ramp("#f1ece0"), { flat = true } },
}
-- bud scale arcs
for _, q in ipairs({ {26, 24}, {25, 27}, {25, 30}, {26, 33}, {27, 35}, {37, 24}, {38, 27}, {38, 30}, {37, 33}, {36, 35} }) do
  c:px(q[1], q[2], GV.C.umber)
end
-- calyx at base of big bud
c:paint({ "kkkkkk", ".kkkk." }, 29, 39, { k = "#2f5a2a" })

local t = c:save(O .. "aseprite/ph/caper.aseprite", O .. "png/ph/caper.png")
print(GV.report(t))
