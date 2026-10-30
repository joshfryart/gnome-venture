-- ph/pickled-onions (Pantry pickle): wide round swing-top jar, wire bail over a glass lid, red gasket, pearl onions under a brine line
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-onions"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local onion = GV.ramp("#f4f0e0", { shade = "#e8d890", bounce = "#efe2a8", deep = "#c9b070" })
c:build{
  { "glass", c:rrect(13, 25, 51, 56, 14):add(c:rect(19, 23, 45, 27)), "glass" },
  { "brine", c:rrect(15, 31, 49, 54, 12), "#d8ecc8", { contour = "#8fb4a0", gloss = false } },
}
c:fill(c:rect(17, 31, 47, 31), "#8fb4a0")                 -- brine line, air gap above
-- pearl onions: back row first
for _, o in ipairs({ {23, 39}, {33, 37}, {42, 40}, {20, 48}, {44, 49} }) do
  c:part(c:ellipse(o[1], o[2], 5, 5), onion, { cres = 3, deep = 1, gloss = false, contact = false, contour = "#8a6a3a" })
  c:px(o[1], o[2] - 5, "#c9b070"); c:px(o[1], o[2] - 6, "#6a8a3a")   -- pointed tip
  c:px(o[1] - 2, o[2] - 2, "#fbf6e8")                                  -- pearly sheen
  c:fill(c:line({ {o[1] - 1, o[2] - 3}, {o[1] - 2, o[2] + 2} }, 1), "#e8d890") -- skin layer line
end
c:px(28, 34, "#4a8a3e"); c:px(29, 33, "#4a8a3e"); c:px(29, 35, "#6a8a3a")          -- bay sprig
-- glass lid, gasket, wire bail
c:part(c:rrect(17, 12, 47, 24, 5), "#c9e6f0", { gloss = false, rim = false, contour = "#7fb6cc" })
c:fill(c:rect(19, 24, 45, 24), "#7fb6cc")
c:fill(c:rect(21, 14, 27, 14), "#eef8f2")
c:part(c:rect(17, 25, 47, 27), "red", { cres = 1, deep = 0, gloss = false, rim = false, contact = false })
-- wire bail: dark 2 px arch lying over the lid face, hinged on the shoulders
local wire = c:line({ {16, 34}, {17, 28}, {20, 21}, {24, 17}, {29, 16}, {35, 16}, {40, 17}, {44, 21}, {47, 28}, {48, 34} }, 2)
c:fill(wire, "#3d4650")
c:fill(c:line({ {16, 33}, {17, 28}, {20, 21}, {24, 17}, {29, 16}, {35, 16} }, 1), "#8b8f96")
c:part(c:rrect(14, 32, 18, 36, 1), "#8b8f96", { flat = true, contour = "#3d4650" })   -- hinge lugs
c:part(c:rrect(46, 32, 50, 36, 1), "#8b8f96", { flat = true, contour = "#3d4650" })
c:px(16, 34, "#3d4650"); c:px(48, 34, "#3d4650")
-- label with an onion emblem
c:part(c:rrect(22, 44, 42, 53, 2), "cream", { gloss = false, contact = false })
c:paint({
  "...g...",
  "...b...",
  "..bwb..",
  ".bwwwb.",
  "bwWwwwb",
  "bwwwwsb",
  ".bwwsb.",
  "..bbb..",
}, 23, 44, { g = "#7ab55c", b = "#b8a070", w = "#f4f0e0", W = "#fbf6e8", s = "#e8d890", r = "#9a6b3f" })
c:paint({ "uu.uuu", "", "uuu.u" }, 32, 47, { u = "#7a5a3a" })
c:gloss(c:rrect(13, 25, 51, 56, 14), "glass", { 18, 33 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
