-- ph/soy-sauce (Pantry ferment): square-shouldered dark-glass bottle, red spout cap, cream label with a soy pod
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "soy-sauce"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = { base = "#3a2a1f", rim = "#5b6470", gloss = "#8b8f96", dot = "#c9c5bc", shade = "#2a1a10", deep = "#1e120a", bounce = "#4a3428" }
local cap = GV.ramp("#a8241f", { shade = "#5a1010", deep = "#3a0a10", bounce = "#7a1a1a", gloss = "#ff9158", dot = "#ffc27a", rim = "#dd3a2a" })
c:part(c:rect(27, 13, 37, 22), dark, { gloss = false })   -- neck
c:part(c:rrect(16, 20, 48, 56, 3), dark, { gloss = { 19, 26 } })
c:fill(c:rect(19, 24, 19, 52), "#5b6470")   -- glass edge highlight
c:fill(c:rect(20, 24, 45, 24), "#7a5a3a")   -- sauce level line through the shoulder
-- red cap with a pouring spout on the right
c:part(c:rrect(25, 6, 39, 14, 2), cap, { gloss = { 27, 8 } })
c:part(c:poly({ {39, 7}, {45, 7}, {45, 9}, {39, 12} }), cap, { gloss = false, contact = false, cres = 2, deep = 0 })
c:px(44, 7, "#ff9158")
c:seam({ {26, 13}, {38, 13} })
-- label with a green soy pod
c:part(c:rect(20, 30, 44, 50), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({
  "............kk",
  "..kkkk.kkkkkk.",
  ".kPPPPkPPPPPPk",
  "kPBBPPPBBPPBBk",
  "kPBbPPPBbPPBbk",
  "kPPPPkPPPPPPk.",
  ".kkkk.kkkkkk..",
}, 25, 34, { k = "#2f5a2a", P = "#7ab55c", B = "#e8d890", b = "#c9a96e" })
c:paint({ "uuu.uuuu.uu", "", ".uuuu.uuu.." }, 26, 44, { u = "#7a5a3a" })
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
