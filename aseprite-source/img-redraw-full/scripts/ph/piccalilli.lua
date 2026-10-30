-- ph/piccalilli (Pantry pickle): squat wide jar of mustard-yellow relish, cream florets, lacquered lid with a pinstripe
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "piccalilli"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(12, 25, 52, 55, 6), "glass" },
  { "fill",  c:rrect(14, 28, 50, 53, 5), "#e8b830", { contour = "#a8701a", gloss = { 17, 31 } } },
}
-- cream floret bumps (clusters of three) and cucumber bits
for _, p in ipairs({ {17,30}, {26,29}, {37,30}, {45,32}, {16,47}, {25,49}, {37,48}, {45,46} }) do
  c:paint({ ".a.", "abb", ".b." }, p[1], p[2], { a = "#fbf6e8", b = "#e0d4b0" })
end
for _, p in ipairs({ {22,32}, {32,31}, {42,29}, {21,50}, {31,51}, {41,51} }) do c:paint({ "gg" }, p[1], p[2], { g = "#7ab55c" }) end
c:part(c:rrect(20, 35, 44, 46, 2), "cream", { gloss = false, contact = false })
-- emblem: cauliflower floret
c:paint({
  "..cc.cc..",
  ".cCccccc.",
  "ccccccccs",
  ".ccsccsc.",
  "g.ttttt.g",
  ".gg.t.gg.",
  "...ggg...",
}, 22, 37, { c = "#f1ece0", C = "#fbfdfe", s = "#c9b98a", t = "#b0c890", g = "#4f9a45" })
c:paint({ "uuuu", "", "uuu", "", "uuuu" }, 35, 38, { u = "#7a5a3a" })
-- lacquered mustard lid with black pinstripes
c:part(c:rrect(11, 15, 53, 26, 3), "#e8a317")
c:fill(c:rect(13, 17, 51, 17), "#2a1a10")
c:fill(c:rect(12, 24, 52, 24), "#2a1a10")
c:seam({ {13, 26}, {51, 26} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
