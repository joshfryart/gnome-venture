local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pear-shaped cloth bundle: round belly tapering to a pinched neck
local body = c:ellipse(31.5, 41, 15, 13)
body:add(c:poly({ {26, 26}, {38, 26}, {44, 34}, {20, 34} }))
local frill = c:poly({ {21, 17}, {43, 17}, {38, 27}, {26, 27} })
local seed = c:ellipse(31.5, 17, 7, 6)
local sprStem = c:rect(31, 8, 32, 11)
local leaf = c:poly({ {33, 8}, {36, 5}, {40, 6}, {38, 9}, {34, 10} })
local band = c:rrect(25, 25, 38, 28, 1)
local loopL = c:ellipse(23.5, 26.5, 3, 2.5):cut(c:ellipse(23.5, 26.5, 1, 0.5))
local loopR = c:ellipse(39.5, 26.5, 3, 2.5):cut(c:ellipse(39.5, 26.5, 1, 0.5))
local endL = c:line({ {29, 28}, {27, 33} }, 2)
local endR = c:line({ {34, 28}, {36, 34} }, 2)
local patch = c:rrect(28, 40, 35, 47, 2)

local cream = GV.ramp("#f1ece0")
local frillR = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local seedR = GV.ramp("#3f93b2")
local p = c:build{
  { "seed",  seed, seedR },
  { "body",  body, cream, { stitch = true } },
  { "frill", frill, frillR },
  { "stem",  sprStem, "moss", { flat = true } },
  { "leaf",  leaf, GV.ramp("#58a03e"), { flat = true } },
  { "loopL", loopL, "wood", { flat = true } },
  { "loopR", loopR, "wood", { flat = true } },
  { "endL",  endL, "wood", { flat = true } },
  { "endR",  endR, "wood", { flat = true } },
  { "band",  band, "wood" },
  { "patch", patch, seedR },
}
-- pleat folds on the frill

for _, q in ipairs({ {27,19},{27,20},{28,21},{28,22},{28,23},{29,24},{29,25},
                     {36,19},{36,20},{35,21},{35,22},{35,23},{34,24},{34,25} }) do
  c:px(q[1], q[2], "#dcb06a")
end
-- knot
c:paint({ "kk", "kk" }, 31, 26, { k = "#8a4f2a" })
-- seam down the belly under the patch
c:seam({ {32, 31}, {32, 38} })
c:ground(31.5, 54, 12, 1)
local t = c:save(O .. "aseprite/ph/itoh-peony-seed.aseprite", O .. "png/ph/itoh-peony-seed.png")
print(GV.report(t))
