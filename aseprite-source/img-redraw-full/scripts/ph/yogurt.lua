-- ph/yogurt (Pantry dairy): squat round-shouldered milk bottle, crimped blue foil cap, thick yogurt with a cream line, goat-head label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "yogurt"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local yog = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
c:part(c:rrect(16, 24, 48, 56, 10):add(c:rect(22, 16, 42, 26)), "glass", { gloss = false })
c:part(c:rrect(18, 30, 46, 54, 8):add(c:rect(24, 22, 40, 31)), yog, { gloss = false, contour = "#9a8a50" })
c:fill(c:rect(24, 22, 40, 23), "#fbf6e8"); c:fill(c:rect(24, 24, 40, 24), "#efe0bc")   -- cream line on top
-- oval label with a horned goat head
c:part(c:ellipse(32, 44, 10, 8), GV.ramp("#e8d0a0", { dot = "#fbf6e8" }), { gloss = false, contact = false, cres = 3, deep = 0 })
c:paint({
  "h.........h",
  "hh.......hh",
  ".hh.....hh.",
  "..hFFFFFh..",
  "llFFFFFFsll",
  ".lFkFFFksl.",
  "..FFFFFFs..",
  "..FFFFFss..",
  "...FFFss...",
  "...FnnsF...",
  "....bbb....",
  ".....b.....",
}, 27, 37, { h = "#7a4a1f", F = "#f4f0e0", s = "#c9c5bc", k = "#2a1a10", l = "#8b8f96", n = "#7a5a3a", b = "#c9c5bc" })
c:gloss(c:rrect(16, 24, 48, 56, 10), "glass", { 19, 31 })
-- crimped blue foil cap
c:part(c:rrect(20, 8, 44, 18, 2), "water", { gloss = { 23, 10 } })
for _, x in ipairs({ 24, 29, 35, 40 }) do c:fill(c:rect(x, 13, x, 18), "#25637d") end
c:seam({ {21, 17}, {43, 17} }, { free = false })
c:ground(32, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
