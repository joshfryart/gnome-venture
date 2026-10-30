-- ph/pickled-peppers (Pantry pickle): tapered Weck clamp jar (wide top, narrow base), glass lid, orange gasket, steel spring clip, red chilies in straw vinegar
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-peppers"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {14, 21}, {51, 21}, {45, 57}, {19, 57} }):clip(c:rrect(14, 21, 50, 56, 4))
local brine = body:shrink(2):cut(c:rect(0, 0, 63, 26))
c:build{
  { "glass", body, "glass" },
  { "brine", brine, "#f5e6b0", { contour = "#c9b070", gloss = false } },
}
-- chilies: curved pods, green stem caps, back to front
local red = GV.ramp("#d6322b", { shade = "#a8241f" })
local function pod(pts, cap)
  c:part(c:line(pts, 3), red, { cres = 1, deep = 0, gloss = false, contact = false, contour = "#6b1b2c" })
  c:px(pts[1][1], pts[1][2] + 1, "#ff9158")
  c:fill(c:rect(cap[1], cap[2], cap[1] + 2, cap[2] + 1), "#4f9a45"); c:px(cap[1] + 1, cap[2] - 1, "#2f5a2a")
end
pod({ {21, 30}, {25, 33}, {28, 38}, {29, 41} }, { 19, 28 })
pod({ {41, 29}, {38, 33}, {36, 37}, {36, 40} }, { 41, 27 })
pod({ {30, 30}, {32, 33}, {33, 36} }, { 29, 28 })
pod({ {23, 44}, {27, 46}, {31, 50}, {32, 53} }, { 21, 42 })
pod({ {43, 43}, {40, 47}, {38, 51}, {37, 54} }, { 43, 41 })
c:part(c:ellipse(28, 51, 2.5, 2), "#f4f0e0", { flat = true, contour = "#b8a070" })   -- garlic clove
-- label with a chili emblem
c:part(c:rrect(24, 38, 40, 47, 2), "cream", { gloss = false, contact = false })
c:paint({
  ".gG...",
  "..rr..",
  "..rrr.",
  "...rr.",
  "...rs.",
  "....s.",
}, 25, 40, { g = "#4f9a45", G = "#2f5a2a", r = "#d6322b", s = "#a8241f" })
c:paint({ "uuu.u", "", "uu.uu" }, 32, 41, { u = "#7a5a3a" })
-- glass lid, gasket, spring clip
c:part(c:rrect(13, 13, 51, 20, 4), "#c9e6f0", { gloss = false, rim = false, contour = "#7fb6cc" })
c:fill(c:rect(17, 15, 25, 15), "#eef8f2")
c:part(c:rect(14, 20, 50, 22), "#e0501f", { cres = 1, deep = 0, gloss = false, rim = false, contact = false })
c:part(c:rrect(46, 11, 50, 29, 1), "#8b8f96", { cres = 1, deep = 0, gloss = false, contour = "#3d4650" })
c:fill(c:rect(47, 12, 47, 27), "#c9c5bc")
c:fill(c:rect(46, 17, 50, 18), "#5b6470")
c:gloss(body, "glass", { 17, 26 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
