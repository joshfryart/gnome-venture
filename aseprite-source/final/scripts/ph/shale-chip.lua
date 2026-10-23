-- shale-chip: a thick wedge of layered slate chipped off the Shale Slater's back
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- top face: an irregular tilted wedge with a bitten notch at the upper right
local top = c:poly({ {9, 30}, {20, 17}, {33, 12}, {44, 13}, {55, 22}, {47, 37}, {22, 41} })
top:cut(c:poly({ {44, 13}, {49, 13}, {50, 20}, {45, 19} }))
-- side: the layered edge showing beneath the face (thickness 9)
local side = c:poly({ {9, 30}, {22, 41}, {47, 37}, {55, 22}, {55, 31}, {47, 46}, {22, 50}, {9, 39} })
side:cut(top)
local whole = top:copy():add(side)
-- a thinner upper flake still clinging to the face (shale splits in sheets)
local flake = c:poly({ {12, 28}, {21, 18}, {33, 14}, {42, 16}, {39, 26}, {24, 32} })
local fside = flake:shift(0, 3):add(flake:shift(1, 2)):cut(flake):clip(top)
local p = c:build{
  { "side", side, GV.ramp("#5b6470"), { light = whole, gloss = false } },
  { "top",  top,  "stone", { light = whole, gloss = false } },
  { "fside", fside, GV.ramp("#5b6470"), { light = whole, gloss = false, contact = false } },
  { "flake", flake, "stone", { light = whole, gloss = { 19, 23 } } },
}
-- shale layers: two lamination lines running along the side
local inner = p.side.m:shrink(1)
c:fill(c:line({ {10, 34}, {22, 44}, {47, 40}, {55, 26} }, 1):clip(inner), "#3a4250")
-- cleavage scratches on the face (slater-plate lilac sheen)
c:fill(c:line({ {30, 35}, {38, 32}, {46, 30} }, 1):clip(p.top.m:shrink(2)):cut(p.flake.m:grow(1)), "#6c7382")
c:fill(c:line({ {25, 37}, {29, 36} }, 1):clip(p.top.m:shrink(2)):cut(p.flake.m:grow(1)), "#6c7382")
-- slater-plate lilac sheen along the flake's lit edge
c:fill(c:line({ {24, 22}, {32, 19}, {37, 19} }, 1):clip(p.flake.m:shrink(2)), "#8f7fc9")
-- the slater's gold seam along the middle layer join
c:seam({ {12, 38}, {22, 47}, {46, 43}, {53, 31} })
local t = c:save(D .. "final/aseprite/ph/shale-chip.aseprite", PNG .. "shale-chip.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
