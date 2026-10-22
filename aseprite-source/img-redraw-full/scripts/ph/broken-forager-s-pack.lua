local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bagR = GV.ramp("#b07a10")
-- handle arch with a gap on the right (snapped)
local handle = c:line({ {17,34}, {18,24}, {23,16}, {31,13}, {38,14} }, 4)
local stub = c:line({ {45,22}, {48,28}, {49,34} }, 4)
handle:add(stub)
local body = c:poly({ {12,33}, {56,33}, {51,57}, {17,57} })
local strap1 = c:rect(15, 40, 52, 42):clip(body)
local strap2 = c:rect(16, 48, 51, 50):clip(body)
local clasp = c:ellipse(28, 32, 4, 4)
-- loose strap piece hanging off lower right
local loose = c:poly({ {49,50}, {54,52}, {52,56}, {47,54} })
local p = c:build{
  { "handle", handle, bagR },
  { "body", body, bagR, { gloss = { 17, 36 } } },
  { "strap1", strap1, "gold", { flat = true } },
  { "strap2", strap2, "gold", { flat = true } },
  { "loose", loose, "gold", { flat = true } },
  { "clasp", clasp, GV.ramp("#8c4a1a") },
}
c:seam({ {15,35}, {53,35} })
-- frayed handle ends
c:px(38, 12, GV.C.gold); c:px(40, 14, GV.C.gold); c:px(44, 20, GV.C.gold); c:px(43, 22, GV.C.gold)
-- zigzag crack through the body
local crack = c:line({ {37,36}, {33,42}, {38,47}, {34,52}, {36,56} }, 2)
c:fill(crack, "#2a1a10")
c:px(36, 36, "#4a2c1a"); c:px(39, 47, "#4a2c1a")
c:fill(c:rect(30, 31, 30, 31), "#4a2c1a")
local t = c:save(O .. "aseprite/ph/broken-forager-s-pack.aseprite", O .. "png/ph/broken-forager-s-pack.png")
print(GV.report(t))
