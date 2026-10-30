-- ph/cold-brew-coffee (Pantry cordial): milk-bottle shape with a neck bulb above a pinched waist, flat foil cap, near-black cold brew, coffee-bean label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cold-brew-coffee"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(18, 33, 46, 56, 6):add(c:poly({ {26, 28}, {39, 28}, {46, 36}, {18, 36} }))
glass:add(c:ellipse(32, 21, 9, 7)):add(c:rect(27, 26, 37, 30)):add(c:rect(27, 12, 37, 16))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(20, 34, 44, 54, 5):add(c:poly({ {27, 30}, {38, 30}, {44, 37}, {20, 37} })):add(c:ellipse(32, 22, 6.5, 4.5)):add(c:rect(29, 26, 35, 31)),
    GV.ramp("#3a2a1f", { rim = "#6a4a30", gloss = "#8a6a48", dot = "#b08a60" }), { contour = "#2a1a10", gloss = false } },
  { "label",  c:rect(21, 39, 43, 52), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(22, 35, 23, 50), "#6a4a30"); c:fill(c:rect(27, 20, 27, 24), "#6a4a30")   -- sheen
-- flat foil disc cap with a crimped edge
c:part(c:rrect(24, 8, 40, 15, 3), GV.ramp("#c9c5bc", { shade = "#8b8f96", deep = "#5b6470" }), { gloss = { 27, 10 }, cres = 2 })
for x = 26, 38, 2 do c:px(x, 14, "#8b8f96") end
c:seam({ {26, 16}, {38, 16} }, { free = true })
-- coffee bean with an S-curve crease
c:paint({
  "..bbbb..",
  ".bBbbkb.",
  "bBbbkbbb",
  "bbbkbbbb",
  "bbkbbbbs",
  ".bkbbbs.",
  "..ssss..",
}, 28, 42, { b = "#7a4a1f", B = "#9a6b3f", k = "#2a1a10", s = "#5e2f1e" })
c:ground(32, 57, 14, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
