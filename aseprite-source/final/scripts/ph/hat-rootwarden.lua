local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local brim = c:ellipse(32, 46, 21, 6)
local brimTop = c:ellipse(32, 44, 18, 4)
local crown = c:poly{ {15,45}, {16,36}, {18,29}, {22,23}, {27,18}, {33,14}, {40,12}, {46,13}, {50,16},
                      {51,19}, {47,19}, {42,17}, {38,19}, {38,24}, {41,31}, {45,38}, {49,45} }
local band = c:rect(10, 37, 54, 43):clip(crown:grow(1))
local bob = c:ellipse(50, 19, 3, 3)
local stem = c:rect(31, 31, 32, 38)
local leafL = c:poly{ {31,32}, {28,29}, {25,28}, {24,30}, {26,32}, {29,33} }
local leafR = c:poly{ {33,32}, {35,28}, {38,26}, {40,27}, {39,30}, {36,32} }

local wood = GV.ramp("#a5663a")
c:build{
  { "brim", brim, GV.ramp("#8c4a1a") },
  { "brimTop", brimTop, wood, { gloss = false } },
  { "crown", crown, wood, { gloss = { 22, 27 } } },
  { "band", band, GV.ramp("#b6814d", { rim = "#f0d49a" }), { gloss = false } },
  { "stem", stem, GV.ramp("#2e5a2c"), { flat = true } },
  { "leafL", leafL, GV.ramp("#58a03e"), { flat = true } },
  { "leafR", leafR, GV.ramp("#7ab55c"), { flat = true } },
  { "bob", bob, "gold", { gloss = { 49, 18 } } },
}
c:seam({ { 22, 41 }, { 48, 41 } })
c:button(17, 39)
c:ground(32, 53, 19, 1.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/hat-rootwarden.aseprite",
                 D .. "img-redraw-full/png/ph/hat-rootwarden.png")
print(GV.report(t))
