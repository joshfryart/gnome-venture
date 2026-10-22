local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local crate = c:rrect(11, 36, 52, 55, 2)
local straw = c:poly({ {13, 38}, {13, 34}, {16, 31}, {18, 34}, {21, 30}, {24, 34}, {27, 31}, {37, 31}, {40, 34}, {43, 30}, {46, 34}, {48, 31}, {51, 35}, {51, 38} })
local fruit = c:ellipse(32, 22, 10, 12.5)
local calyx = c:poly({ {27, 10}, {37, 10}, {35, 12}, {29, 12} })
local stem = c:rect(31, 6, 32, 9)
local p = c:build{
  { "crate", crate, "wood" },
  { "straw", straw, "gold", { gloss = false } },
  { "fruit", fruit, GV.ramp("#d8364e", { gloss = "#f6b8cf", shade = "#ae2a2a", deep = "#6b1b2c" }), { gloss = { 26, 15 } } },
  { "stem", stem, "moss", { flat = true } },
  { "calyx", calyx, "moss", { flat = true } },
}
-- slats
c:fill(c:rect(13, 43, 50, 43), "#5e2f1e"); c:fill(c:rect(13, 49, 50, 49), "#5e2f1e")
-- handle holes
c:paint({ ".ooo.", "ooooo", ".ooo." }, 14, 39, { o = "#2a1a10" })
c:paint({ ".ooo.", "ooooo", ".ooo." }, 45, 39, { o = "#2a1a10" })
-- straw strands
c:paint({ "s..s....s", ".s..s..s." }, 15, 35, { s = "#e8a317" })
c:paint({ "s....s..s", ".s..s..s." }, 40, 35, { s = "#e8a317" })
-- nails
for _, x in ipairs({ 14, 49 }) do c:px(x, 46, "#ecc58a"); c:px(x, 52, "#ecc58a") end
c:ground(32, 57, 18, 2)
local t = c:save(O .. "aseprite/ph/tamarillo-seed.aseprite", O .. "png/ph/tamarillo-seed.png")
print(GV.report(t))
