-- ph/pickled-cauliflower (Pantry pickle): faceted hexagonal-shouldered jar, solid turmeric-gold brine, cream floret clouds, domed pewter lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-cauliflower"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {16, 27}, {24, 20}, {41, 20}, {49, 27}, {49, 52}, {43, 57}, {22, 57}, {16, 52} })
local brine = body:shrink(2):cut(c:rect(0, 0, 63, 26))
c:build{
  { "glass", body, "glass" },
  { "brine", brine, "#f5cf6a", { contour = "#b8661a", gloss = false } },
}
c:fill(brine:copy():clip(c:rect(0, 41, 63, 63)), "#e8a317")
c:fill(brine:copy():clip(c:rect(0, 27, 63, 27)), "#fff1c8")
-- florets: three-bump clouds on a short stalk
local fl = GV.ramp("#f4f0e0", { shade = "#e0c890", deep = "#b8a070" })
local function floret(x, y)
  c:fill(c:rect(x - 1, y + 2, x + 1, y + 5), "#d8e0a0")
  local m = c:ellipse(x - 3, y, 3, 3):add(c:ellipse(x + 3, y, 3, 3)):add(c:ellipse(x, y - 3, 3, 3)):add(c:ellipse(x, y + 1, 3, 2))
  c:part(m, fl, { cres = 2, deep = 1, gloss = false, contact = false, contour = "#8a5a1a" })
  c:px(x - 4, y - 1, "#fbf6e8"); c:px(x - 1, y - 4, "#fbf6e8")
  c:px(x + 1, y, "#e0c890"); c:px(x - 2, y + 1, "#e0c890")
end
floret(25, 34); floret(39, 33); floret(31, 43); floret(41, 44)
-- facet lines
c:fill(c:rect(24, 22, 24, 56):clip(body), "#7fb6cc")
c:fill(c:rect(41, 22, 41, 56):clip(body), "#7fb6cc")
-- label low on the jar with a floret emblem
c:part(c:rect(22, 49, 43, 55), "cream", { gloss = false, contact = false })
c:paint({
  ".b.b.",
  "bwbwb",
  "bwwwb",
  ".bgb.",
  "..g..",
}, 24, 50, { b = "#b8a070", w = "#f4f0e0", g = "#4f9a45" })
c:paint({ "uuu.uu.uu", "", "uu.uuuu" }, 31, 51, { u = "#7a5a3a" })
-- domed pewter lid
local lid = c:ellipse(32.5, 16, 12, 5):cut(c:rect(0, 17, 63, 63)):add(c:rrect(20, 15, 45, 21, 2))
c:part(lid, "#8b8f96", { contour = "#3d4650", gloss = { 25, 13 } })
c:fill(c:rect(26, 14, 39, 14), "#c9c5bc")
c:seam({ {21, 20}, {44, 20} })
c:gloss(body, "glass", { 19, 29 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
