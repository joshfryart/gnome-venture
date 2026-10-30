-- ph/quince-paste (Pantry jam): low wooden box, amber quince slab inside, sliding lid pulled half out to the right, a cut slice leaning on the front
-- redraw A: fewer, bigger shapes (no parchment, no knife cut, no grain lines, plain label); slab is deep amber, not pink
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "quince-paste"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local AMBER = GV.ramp("#d0702a", { gloss = "#f5b060", rim = "#e8944a", shade = "#a8461a", deep = "#6b2a14", bounce = "#b8582a" })
local slice = c:poly({ {13, 40}, {25, 37}, {28, 55}, {16, 56} })
c:build{
  { "inside", c:rect(8, 23, 50, 34), "#5e2f1e", { gloss = false, rim = false } },
  { "slab",   c:rect(10, 25, 48, 34), AMBER, { gloss = false, contour = "#4e2a16" } },
  { "box",    c:rrect(8, 35, 50, 54, 2), GV.ramp("#8a5a34", { shade = "#6a3a20", deep = "#4e2a16", rim = "#b07a45", bounce = "#7a4a1f" }), { gloss = false } },
  { "lid",    c:rrect(34, 19, 56, 24, 1), "wood", { gloss = false } },
  { "slice",  slice, AMBER, { gloss = false, contour = "#4e2a16" } },
  { "label",  c:rect(34, 40, 46, 50), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(11, 26, 32, 26), "#f5b060")              -- lit top edge of the slab
c:fill(c:line({ {14, 40}, {24, 38} }, 1), "#f5b060")   -- lit top face of the slice
c:fill(c:rect(35, 20, 55, 20), "#ecc58a")              -- lid lit edge
c:paint({ "kk", "kk" }, 52, 21, { k = "#4e2a16" })      -- notch handle
c:seam({ {9, 36}, {49, 36} })                          -- box joint
-- label: one bold quince (pear-shaped, golden) with a leaf
c:paint({
  "...kgg..",
  "...k....",
  "..yyy...",
  "..yOyy..",
  ".yyyyyy.",
  "yyyyyyys",
  ".yyysss.",
  "..sss...",
}, 36, 41, { y = "#e8a317", O = "#f5cf6a", s = "#b8661a", g = "#4f9a45", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
