-- ph/lemon-cordial (Pantry cordial): round-bellied bottle, narrow neck, cork with a thread tie, pale lemon cordial
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "lemon-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 41, 16, 15):add(c:rect(28, 14, 36, 28))
c:build{
  { "glass",  body, "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 42, 14, 12.5):cut(c:rect(0, 0, 63, 30)), "#f5e27a", { contour = "#c8a83a", gloss = { 22, 36 } } },
  { "label",  c:rrect(22, 38, 42, 47, 2), "cream", { gloss = false, contact = false } },
  { "cork",   c:rrect(28, 6, 36, 14, 1), "#c9a96e", { gloss = false } },
}
c:fill(c:rect(21, 31, 43, 31), "#fff3a0")          -- lit liquid surface
c:seam({ {28, 16}, {36, 16} }, { free = true })     -- thread tie round the neck
c:px(29, 9, "#9a6b3f"); c:px(33, 11, "#9a6b3f"); c:px(31, 8, "#9a6b3f")   -- cork pores
-- label: lemon and two ticks
c:paint({
  "..g....",
  ".yyyy..",
  "yYyyyy.",
  "yyyyyyy",
  ".yyyys.",
  "..sss..",
}, 25, 40, { y = "#f5d23a", Y = "#fff3a0", s = "#d0a01a", g = "#7ab55c" })
c:paint({ "uuu", "", "uu" }, 34, 42, { u = "#7a5a3a" })
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
