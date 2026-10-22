local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- right blade: long and intact, curved hook tip
local bladeR = c:poly({ {30, 33}, {33, 36}, {44, 18}, {48, 10}, {47, 8}, {43, 12} })
-- left blade: snapped short at y ~20 with a jagged top
local bladeL = c:poly({ {34, 33}, {31, 36}, {22, 22}, {21, 19}, {23, 20}, {24, 18}, {26, 20}, {27, 19} })
local handleL = c:line({ {30, 36}, {21, 52} }, 5)
local handleR = c:line({ {34, 36}, {43, 52} }, 5)
handleR:cut(c:rect(44, 44, 47, 47))           -- chipped notch
local capL = c:ellipse(20.5, 52.5, 3.5, 3.5)
local capR = c:ellipse(43.5, 52.5, 3.5, 3.5)
local tip = c:poly({ {9, 32}, {14, 38}, {12, 40}, {8, 36}, {8, 34} })
local chip = c:rrect(50, 41, 53, 44, 1)

local p = c:build{
  { "bladeL",  bladeL,  "#d6c9b6", { cres = 2 } },
  { "bladeR",  bladeR,  "#d6c9b6", { cres = 2 } },
  { "handleL", handleL, "wood" },
  { "handleR", handleR, "wood" },
  { "capL",    capL,    "#8a4f2a" },
  { "capR",    capR,    "#8a4f2a" },
  { "pivot",   c:ellipse(32, 35, 3), "#968f96" },
  { "tip",     tip,     "#d6c9b6", { flat = true } },
  { "chip",    chip,    "#b07a45", { flat = true } },
}
-- pivot screw slot
c:paint({ "s.", ".s" }, 31, 34, { s = "#5b6470" })
-- crack down the left handle
c:paint({ "k.", ".k", ".k", "k." }, 25, 40, { k = "#2a1a10" })
c:px(24, 44, "#2a1a10")
-- jagged break line on left blade
c:paint({ "k.k.k" }, 22, 20, { k = "#4a2c1a" })
-- seam where the cloth wrap meets the wood near the pivot
local t = c:save(D .. "img-redraw-full/aseprite/ph/broken-fine-secateurs.aseprite", D .. "img-redraw-full/png/ph/broken-fine-secateurs.png")
print(GV.report(t))
