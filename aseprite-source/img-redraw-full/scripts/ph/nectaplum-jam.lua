-- ph/nectaplum-jam (Pantry jam): glass tankard jar with a loop handle on the right, cream ceramic lid with a pit-shaped knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "nectaplum-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local handle = c:rrect(36, 27, 54, 47, 7):cut(c:rrect(42, 32, 49, 42, 3))
c:build{
  { "handle", handle, "glass", { gloss = false } },
  { "glass",  c:rrect(10, 22, 42, 54, 5), "glass" },
  { "jam",    c:rrect(12, 27, 40, 52, 4), "#e0603a", { contour = "#a8461a", gloss = { 15, 30 } } },
  { "label",  c:rect(16, 36, 36, 46), "cream", { gloss = false, contact = false } },
  { "lid",    c:rrect(9, 15, 43, 24, 3), "cream", { gloss = false } },
  { "knob",   c:ellipse(26, 12, 5, 3), "soil", { gloss = false } },
}
c:fill(c:rect(43, 30, 50, 30), "#eef8f2")                -- lit top of the handle loop
c:fill(c:rect(26, 9, 26, 15), "#7a4a1f")                 -- the pit's groove
c:px(23, 11, "#e8a060"); c:px(24, 10, "#e8a060")
c:fill(c:rect(11, 17, 41, 17), "#fff3c8"); c:px(13, 17, "#ffffff")   -- glaze line, one white glint
for _, s in ipairs({ {15, 33}, {20, 30}, {28, 31}, {35, 33}, {17, 49}, {25, 50}, {33, 49}, {38, 48} }) do
  c:px(s[1], s[2], "#f2a05a"); c:px(s[1] + 1, s[2] + 1, "#ae2a2a")
end
c:seam({ {10, 23}, {42, 23} })
-- label: split nectaplum, red half and peach half around a brown pit
c:paint({
  "....g....",
  "..rrgpp..",
  ".rRrkppp.",
  "rrrkkkppp",
  "rrrkkkpps",
  ".rrrkpps.",
  "..rrpps..",
}, 22, 38, { r = "#d6322b", R = "#ff9158", p = "#f2a05a", s = "#c8561c", k = "#7a4a1f", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
