-- ph/persimmon-jam (Pantry jam): extra squat round jar of orange jam under a green four-point calyx lid on a brown stem nub
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "persimmon-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- four leaf points seen from the front: back (up-left), left, right and front (down over the jar shoulder)
local calyx = c:ellipse(32, 27, 9, 4)
calyx:add(c:poly({ {26, 25}, {10, 30}, {16, 31}, {28, 30} }))      -- left point
calyx:add(c:poly({ {37, 25}, {55, 30}, {49, 31}, {36, 30} }))      -- right point
calyx:add(c:poly({ {27, 29}, {37, 29}, {32, 39} }))                -- front point
calyx:add(c:poly({ {28, 25}, {24, 17}, {33, 23} }))                -- back point
c:build{
  { "glass", c:rrect(11, 29, 53, 54, 12), "glass" },
  { "jam",   c:rrect(13, 32, 51, 52, 10), "#e87a20", { contour = "#a8461a", gloss = { 17, 37 } } },
  { "label", c:rrect(36, 39, 48, 49, 2), "cream", { gloss = false, contact = false } },
  { "calyx", calyx, "leaf", { gloss = false } },
  { "stem",  c:rrect(30, 15, 35, 25, 1), "soil", { gloss = false } },
}
-- leaf veins
c:fill(c:line({ {25, 28}, {15, 30} }, 1), "#2f5a2a"); c:fill(c:line({ {38, 28}, {49, 30} }, 1), "#2f5a2a")
c:fill(c:line({ {32, 31}, {32, 36} }, 1), "#2f5a2a"); c:fill(c:line({ {29, 24}, {26, 19} }, 1), "#2f5a2a")
c:fill(c:rect(31, 15, 34, 15), "#c98a4a")
for _, s in ipairs({ {20, 44}, {25, 49}, {31, 47}, {17, 49}, {44, 35} }) do c:px(s[1], s[2], "#ffb35a") end
-- label (offset right so the front leaf point stays clear): persimmon with its calyx
c:paint({
  "...kk...",
  ".gggggg.",
  "g.gggg.g",
  ".oooooo.",
  "oOoooooo",
  "ooooooos",
  ".oooss..",
}, 38, 40, { o = "#f08a24", O = "#ffd38a", s = "#c8561c", g = "#4f9a45", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
