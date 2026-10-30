-- ph/pumpkin-butter (Pantry spread): round orange glazed ceramic pot with two ear lug handles, wooden lid with a curled stem knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pumpkin-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local stem = c:rect(30, 13, 34, 21):add(c:rect(33, 11, 37, 13))
c:build{
  { "lugL", c:rrect(8, 33, 16, 43, 3), "#e0802a", { gloss = false } },
  { "lugR", c:rrect(48, 33, 56, 43, 3), "#e0802a", { gloss = false } },
  { "pot",  c:ellipse(32, 41, 18, 13), "#e0802a", { gloss = { 18, 35 } } },
  { "lid",  c:rrect(18, 21, 46, 29, 3), "#9a6b3f", { gloss = false } },
  { "stem", stem, "#7a4a1f", { gloss = false } },
  { "label", c:ellipse(32, 43, 9, 6), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(10, 37, 13, 38), "#ae2a2a"); c:fill(c:rect(51, 37, 54, 38), "#ae2a2a")   -- grip grooves in the lugs
c:fill(c:rect(10, 36, 13, 36), "#f08a24")
for _, g in ipairs({ {21, 24}, {27, 26}, {35, 24}, {41, 26}, {24, 27}, {38, 27} }) do c:fill(c:rect(g[1], g[2], g[1] + 2, g[2]), "#7a4a1f") end
c:fill(c:rect(20, 22, 44, 22), "#c98a4a")
c:px(36, 11, "#9a6b3f"); c:px(37, 12, "#c98a4a")
c:seam({ {19, 28}, {45, 28} })
-- label: ribbed pumpkin with a stem and a cinnamon quill tick
c:paint({
  "....kk...",
  "....k....",
  ".ooyoyoo.",
  "oOoyoyooo",
  "ooyooyoyo",
  "ooyooyoys",
  ".ossysss.",
}, 28, 39, { o = "#e8a317", O = "#f5cf6a", y = "#d0862a", s = "#b8661a", k = "#4f9a45" })
c:paint({ "q", "q", "q" }, 38, 41, { q = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
