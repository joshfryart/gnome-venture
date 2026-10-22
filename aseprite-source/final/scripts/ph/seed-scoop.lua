local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:line({ {49, 52}, {39, 34} }, 6)
local bowl = c:poly({ {8, 11}, {22, 10}, {34, 14}, {42, 24}, {42, 33}, {35, 39}, {25, 40}, {16, 34}, {10, 24} })
local cav = c:poly({ {13, 15}, {23, 14}, {32, 18}, {37, 26}, {36, 32}, {30, 35}, {22, 33}, {16, 26} })
local pile = c:ellipse(27, 29, 8, 4.5):clip(cav:shrink(1))
local ferrule = c:line({ {40, 36}, {42, 40} }, 7)
local p = c:build{
  { "handle", handle, GV.ramp("#b6814d", { rim = "#f0d49a" }) },
  { "ferrule", ferrule, GV.ramp("#5b6470"), { gloss = false } },
  { "bowl", bowl, GV.ramp("#a8a4ac", { rim = "#d6d2ca" }) },
  { "cavity", cav, GV.ramp("#6e7682"), { gloss = false, rim = false, contact = false, cres = 2, deep = 1 } },
  { "seeds", pile, GV.ramp("#9a6b3f"), { cres = 2, deep = 1, gloss = { 22, 27 } } },
}
-- individual seed ticks on the pile
for _, s in ipairs({ {25, 30}, {29, 28}, {31, 31}, {27, 26} }) do c:px(s[1], s[2], "#5e2f1e") end
local t = c:save(D .. "img-redraw-full/aseprite/ph/seed-scoop.aseprite", D .. "img-redraw-full/png/ph/seed-scoop.png")
print(GV.report(t))
