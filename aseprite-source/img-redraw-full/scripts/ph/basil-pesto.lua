-- ph/basil-pesto (Pantry spread): lowest widest jar, dark green pesto under a gold oil layer, basil sprig in the twine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "basil-pesto"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(11, 32, 53, 55, 5), "glass" },
  { "pesto", c:rrect(13, 36, 51, 53, 4), "#4a7a30", { contour = "#2a4a1a", gloss = false } },
}
for _, p in ipairs({ {16,42}, {18,48}, {47,43}, {48,49}, {15,51}, {46,51} }) do c:px(p[1], p[2], "#2f5a2a"); c:px(p[1] + 1, p[2] + 1, "#7ab55c") end
-- gold oil layer on top, with bubbles
c:fill(c:rect(14, 36, 50, 39), "#e8c030"); c:fill(c:rect(14, 36, 50, 36), "#f5d860"); c:fill(c:rect(14, 39, 50, 39), "#b08a1a")
for _, p in ipairs({ {18,37}, {27,38}, {35,37}, {44,38} }) do c:px(p[1], p[2], "#fff3a0") end
c:part(c:rrect(20, 42, 44, 52, 2), "cream", { gloss = false, contact = false })
-- emblem: two basil leaves
c:paint({
  "..gg..gg..",
  ".gGgg.gGg.",
  "ggvgg.gvgg",
  "gvggs.ggvg",
  ".gss...ss.",
  "...t..t...",
}, 22, 44, { g = "#4f9a45", G = "#8cc060", v = "#2f5a2a", s = "#3a7a30", t = "#7a5a3a" })
c:paint({ "uuu", "", "uu" }, 36, 45, { u = "#7a5a3a" })
c:part(c:rrect(10, 24, 54, 34, 3), "#2f5a2a", { contour = "#1a3a14" })
c:seam({ {12, 31}, {52, 31} })
-- twine with a tucked basil sprig standing up on the right
c:fill(c:rect(11, 33, 53, 33), "#c9a96e")
c:fill(c:line({ {49, 33}, {50, 20} }, 1), "#3a7a30")
c:part(c:poly({ {50, 22}, {56, 17}, {56, 21}, {52, 25} }), "#4f9a45", { flat = true })
c:part(c:poly({ {50, 26}, {44, 22}, {45, 26}, {49, 29} }), "#4f9a45", { flat = true })
c:part(c:ellipse(50.5, 17, 2, 3), "#4f9a45", { flat = true })
c:px(54, 19, "#8cc060"); c:px(46, 24, "#8cc060")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
