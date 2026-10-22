local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slender curved fang, wide at lower left, tip up-right
local body = c:poly({
  {17, 58}, {12, 50}, {10, 41}, {12, 32}, {16, 24}, {21, 17}, {27, 11}, {34, 5},
  {35, 7}, {32, 13}, {29, 20}, {27, 28}, {27, 36}, {29, 44}, {32, 51}, {29, 57},
})
-- bark back half: right side of a centre curve
local back = body:copy():clip(c:poly({
  {34, 3}, {44, 3}, {44, 60}, {24, 60}, {24, 52}, {22, 44}, {21, 36}, {22, 28}, {25, 20}, {29, 13},
}))
local sap = c:line({ {17, 51}, {15, 43}, {15, 36}, {17, 29}, {21, 22}, {25, 17} }, 3):clip(body:shrink(2))
local cap = c:rrect(11, 52, 33, 59, 2):clip(body:grow(1))

body, back, sap, cap = body:shift(3, -1), back:shift(3, -1), sap:shift(3, -1), cap:shift(3, -1)
c:build{
  { "fang", body, GV.ramp("#dcb06a"), { gloss = { 18, 27 } } },
  { "back", back, GV.ramp("#a5663a"), { gloss = false, contact = false } },
  { "sap", sap, GV.ramp("#a4b86a"), { flat = true } },
  { "cap", cap, GV.ramp("#5e2f1e", { rim = "#8a4f2a" }), { gloss = false } },
}
-- pale tip
c:paint({ "..tt", ".tt.", "tt.." }, 34, 5, { t = "#f1ece0" })

local t = c:save(D .. "img-redraw-full/aseprite/ph/thorn-fang.aseprite", D .. "img-redraw-full/png/ph/thorn-fang.png")
print(GV.report(t))
