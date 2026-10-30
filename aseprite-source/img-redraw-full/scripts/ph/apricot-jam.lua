-- ph/apricot-jam (Pantry jam): squat jar, flat gold lid, apricot-orange jam with specks, label with an apricot mark
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "apricot-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(18, 22, 46, 54, 7):add(c:rect(20, 20, 44, 23)), "glass" },
  { "jam",   c:rrect(20, 30, 44, 52, 5), "#f08a24", { contour = "#a8461a", gloss = { 23, 32 } } },
  { "label", c:rrect(22, 36, 42, 46, 2), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(17, 13, 47, 23, 3), "gold" },
}
c:fill(c:rect(22, 30, 42, 30), "#ffb35a")          -- lit jam surface
c:seam({ {19, 21}, {45, 21} })                      -- lid / cap base join
for _, p in ipairs({ {25,34}, {31,32}, {38,33}, {41,35}, {24,49}, {30,50}, {37,49}, {42,47}, {21,41} }) do
  c:px(p[1], p[2], "#ffd38a"); c:px(p[1]+1, p[2]+1, "#b8452f")   -- jam specks: fruit bits
end
-- label: apricot with leaf and cleft, three dashes
c:paint({
  "....ug.",
  "..oouggg",
  ".ooocoo.",
  "oOoocooo",
  "oooocoos",
  ".ooocss.",
  "..osss..",
}, 28, 37, { o = "#f08a24", s = "#c8561c", c = "#d0702a", O = "#ffd38a", u = "umber", g = "#7ab55c" })
c:paint({ "uu.uu.uu" }, 25, 45, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
