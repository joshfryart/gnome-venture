-- ph/tamarind-chutney (Pantry chutney): round terracotta matka pot, flared rim, dark drip, tilted saucer lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tamarind-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local clay = GV.ramp("#b0603a", { shade = "#7a3a1f" })
c:build{
  { "neck", c:rect(22, 19, 42, 29), clay, { gloss = false } },
  { "pot",  c:ellipse(32, 41, 20, 14), clay, { gloss = { 17, 34 } } },
  { "lip",  c:rrect(19, 16, 45, 21, 2), clay, { gloss = false } },
}
c:fill(c:rect(22, 17, 42, 17), "#3d2a1c")                -- dark chutney seen in the mouth
-- carved band lines
c:fill(c:line({ {15, 33}, {22, 30}, {42, 30}, {49, 33} }, 1), "#8a4428")
c:part(c:ellipse(30, 42, 10, 6), "cream", { gloss = false, contact = false })
-- emblem: curved tamarind pod with three bumps
c:paint({
  ".bb.bb.bb..",
  "bBbbbbbbbb.",
  "bbbbbbbbbbs",
  ".sss.sss.ss",
}, 25, 40, { b = "#7a4a1f", B = "#b08050", s = "#4a2a1c" })
-- drip over the rim ending in a bead
local drip = c:rect(36, 16, 44, 18):add(c:rect(41, 18, 44, 22)):add(c:rect(42, 22, 44, 29)):add(c:ellipse(43, 31, 2.5, 2.5)):add(c:rect(36, 18, 38, 20))
c:part(drip, "#3d2a1c", { flat = true })
c:px(42, 30, "#8a6a4a"); c:px(42, 20, "#6a4a30"); c:px(37, 17, "#6a4a30")
-- saucer lid propped askew on the rim
c:part(c:poly({ {30, 17}, {33, 12}, {40, 9}, {49, 8}, {54, 10}, {52, 14}, {45, 17}, {36, 19} }), "#9a5030", { gloss = { 37, 12 } })
c:fill(c:line({ {32, 17}, {40, 15}, {48, 13}, {53, 11} }, 1), "#6a2e18")
c:fill(c:line({ {35, 14}, {42, 11}, {49, 10} }, 1), "#c87a4a")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
