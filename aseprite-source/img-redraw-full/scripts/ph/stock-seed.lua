local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f4f0e0", { shade = "#dcb06a" })

-- sprig behind the knot
local stem = c:line({ {32, 27}, {32, 9} }, 2)
local leaves = c:mask()
leaves:add(c:poly({ {31, 23}, {25, 22}, {22, 17}, {27, 18} }))
leaves:add(c:poly({ {33, 23}, {39, 22}, {42, 17}, {37, 18} }))
leaves:add(c:poly({ {31, 16}, {27, 15}, {25, 11}, {29, 12} }))
leaves:add(c:poly({ {33, 16}, {37, 15}, {39, 11}, {35, 12} }))
local buds = c:mask()
buds:add(c:ellipse(32.5, 7.5, 2, 2)); buds:add(c:ellipse(28.5, 10, 1.5, 1.5)); buds:add(c:ellipse(36.5, 10, 1.5, 1.5))

-- cloth body: round bottom, gathered neck
local body = c:ellipse(32, 44, 18, 12)
body:add(c:poly({ {22, 29}, {42, 29}, {48, 40}, {16, 40} }))
-- ear corners
local earL = c:poly({ {19, 17}, {27, 29}, {15, 29} })
local earR = c:poly({ {45, 17}, {50, 29}, {37, 29} })
local tie = c:rect(22, 27, 42, 30)

local p = c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leaves", leaves, "moss", { flat = true } },
  { "buds", buds, "#a4b86a", { flat = true } },
  { "earL", earL, cloth, { gloss = false } },
  { "earR", earR, cloth, { gloss = false } },
  { "body", body, cloth, { gloss = { 22, 36 } } },
  { "tie", tie, "#c9a96e", { flat = true } },
}
c:stitch(p.body.m)
-- fold lines down the belly
for _, pt in ipairs({ {27,33},{26,36},{26,40},{26,44},{26,47},{27,50},{28,52} }) do c:px(pt[1], pt[2], "#dcb06a") end
for _, pt in ipairs({ {38,33},{39,37},{39,41},{39,45},{38,49},{37,52} }) do c:px(pt[1], pt[2], "#dcb06a") end
-- criss-cross string on the knot
for i = 0, 5 do c:px(26 + i, 31 + i, "#9a6b3f"); c:px(38 - i, 31 + i, "#9a6b3f") end
c:button(30, 27)
c:ground(32, 57, 16, 2.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/stock-seed.aseprite", D .. "img-redraw-full/png/ph/stock-seed.png")
print(GV.report(t))
