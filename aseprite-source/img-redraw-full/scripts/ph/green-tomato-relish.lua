-- ph/green-tomato-relish (Pantry relish): tall square-shouldered pickle jar, green enamel lid with a calyx-star knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "green-tomato-relish"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(15, 23, 49, 56, 3):add(c:rect(19, 19, 45, 24)), "glass" },
  { "fill",  c:rect(17, 25, 47, 54), "#8cb050", { contour = "#4a6a2a", gloss = { 20, 28 } } },
}
-- relish chunks and onion bits
for _, p in ipairs({ {20,27}, {27,26}, {35,27}, {42,28}, {19,49}, {26,51}, {34,50}, {41,49}, {44,52} }) do
  c:paint({ "ab", "bb" }, p[1], p[2], { a = "#7ab55c", b = "#4f9a45" })
end
for _, p in ipairs({ {24,28}, {39,26}, {30,52}, {22,52}, {38,48} }) do c:px(p[1], p[2], "#f1ece0") end
c:part(c:rrect(21, 32, 43, 45, 2), "cream", { gloss = false, contact = false })
-- emblem: green tomato with a 5-point calyx
c:paint({
  "...k.k...",
  "..kkkkk..",
  ".gkgkgkg.",
  "gGgggggg.",
  "gggggggg.",
  "ggggggggs",
  ".ggggggs.",
  "..gssss..",
}, 23, 34, { g = "#8cc060", G = "#d8f0a0", s = "#4f9a45", k = "#2f5a2a" })
c:paint({ "uuu", "", "uu", "", "uuu" }, 35, 36, { u = "#7a5a3a" })
c:part(c:rrect(14, 12, 50, 21, 3), "#4f9a45", { contour = "#2f5a2a" })
c:seam({ {16, 20}, {48, 20} })
-- calyx star knob
local star = c:ascii({
  "....k....",
  "....k....",
  "kk.kkk.kk",
  ".kkkkkkk.",
  "..kkkkk..",
  ".kkk.kkk.",
  ".kk...kk.",
}, 28, 6)
c:part(star, "#3f7a35", { flat = true, contour = "#2f5a2a" })
c:px(31, 9, "#7ab55c"); c:px(32, 8, "#7ab55c")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
