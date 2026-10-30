-- ph/salsa-verde (Pantry sauce): basalt molcajete on three stubby legs, green salsa, pestle across, tomatillo tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "salsa-verde"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local basalt = GV.ramp("#5b6470")
c:build{
  { "legs",  c:rrect(15, 48, 21, 55, 2):add(c:rrect(29, 49, 35, 56, 2)):add(c:rrect(43, 48, 49, 55, 2)), "#3d2a1c", { gloss = false } },
  { "bowl",  c:rrect(9, 30, 55, 51, 10):add(c:ellipse(32, 30, 23, 6)), basalt, { gloss = { 14, 33 } } },
  { "salsa", c:ellipse(32, 29.5, 19, 4), "#7ab55c", { contour = "#2f4a20", gloss = false } },
}
-- basalt pits
for _, p in ipairs({ {15,38}, {21,44}, {27,40}, {12,43}, {36,46}, {24,48}, {17,47}, {38,40} }) do
  c:px(p[1], p[2], "#3d2a1c"); c:px(p[1] + 1, p[2], "#8b93a0")
end
for _, p in ipairs({ {18,29}, {24,28}, {30,30}, {38,28}, {44,30}, {27,31}, {41,31} }) do c:px(p[1], p[2], "#2f5a2a") end
for _, p in ipairs({ {21,28}, {33,27}, {46,29} }) do c:px(p[1], p[2], "#b8e08a") end
-- pestle lying across the rim, rising to the right
c:part(c:line({ {24, 30}, {48, 17} }, 4):add(c:ellipse(51, 15, 4.5, 4)), "#b4b8bf", { contour = "#4a4f58", gloss = { 49, 13 } })
c:fill(c:line({ {27, 27}, {46, 17} }, 1), "#dfe3e8")
-- tag on a string: tomatillo in a papery husk
c:fill(c:line({ {45, 31}, {46, 38} }, 1), "#c9a96e")
c:part(c:rrect(40, 38, 52, 48, 1), "cream", { gloss = false })
c:paint({
  "...k...",
  ".hhkhh.",
  "hhgggh.",
  "hgGgggh",
  "hgggggh",
  ".hgggh.",
  "..hhh..",
}, 43, 39, { h = "#a4b86a", g = "#7ab55c", G = "#c8e8a0", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
