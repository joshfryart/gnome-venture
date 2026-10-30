-- ph/bilberry-jam (Pantry jam): opaque blue-grey stoneware jar, blue-black jam dripping over the rim, domed ceramic cap with a heather sprig
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "bilberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local drip = c:rrect(17, 22, 47, 27, 2):add(c:rect(23, 27, 25, 31)):add(c:ellipse(24, 32, 1, 1)):add(c:rect(39, 27, 41, 29)):add(c:ellipse(40, 30, 1, 1))
local cap = c:ellipse(32, 22, 14, 7):clip(c:rect(0, 0, 63, 23)):add(c:rect(18, 22, 46, 24))
c:build{
  { "jar",   c:rrect(16, 25, 48, 54, 7), "#5b6470", { gloss = { 20, 30 } } },
  { "drip",  drip, "#2a3a7a", { gloss = false } },
  { "label", c:ellipse(32, 42, 10, 6), "cream", { gloss = false, contact = false } },
  { "cap",   cap, "#c9c5bc", { gloss = false } },
  { "knob",  c:rrect(29, 10, 35, 15, 2), "#c9c5bc", { gloss = false } },
}
c:px(23, 18, "#f8fcf4"); c:px(24, 17, "#eef8f2"); c:px(22, 19, "#eef8f2")
c:fill(c:rect(19, 26, 46, 26), "#5a86b8")                -- wet lit edge of the jam rim
-- heather sprig tucked under the cap on the right
c:fill(c:line({ {45, 24}, {50, 13} }, 1), "#4f9a45")
c:paint({
  ".lv",
  "vl.",
  ".lv",
  "lv.",
  ".vl",
  "l..",
}, 47, 11, { v = "#7a5cc0", l = "#c3b2ea" })
c:seam({ {19, 23}, {45, 23} })
-- label: bilberry cluster with crown dots
c:paint({
  ".bbb.bbb.",
  "bLbbbLbbb",
  "bbkbbbkbb",
  ".bbbbbbb.",
  "...bLbb..",
  "...bbkb..",
  "....bb...",
}, 28, 39, { b = "#2a3a7a", L = "#5a86b8", k = "#c3b2ea" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
