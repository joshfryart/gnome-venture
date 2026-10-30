-- ph/pickled-turnips (Pantry pickle): wide fishbowl jar of magenta beet brine, purple-topped turnip halves, beet slice, wooden disc lid with knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-turnips"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(32, 38, 22, 18):add(c:rect(19, 17, 45, 24))
c:build{
  { "glass", bowl, "glass" },
  { "brine", c:ellipse(32, 39, 20, 15.5):cut(c:rect(0, 0, 63, 25)), "#e46a9b", { contour = "#9a2a5a", gloss = false } },
}
c:fill(c:rect(14, 25, 50, 26):clip(c:ellipse(32, 39, 20, 15.5)), "#f6b8cf")   -- lit top rows
c:fill(c:rect(14, 27, 50, 27):clip(c:ellipse(32, 39, 20, 15.5)), "#ef8fb5")
-- turnip halves: cream half-rounds with a purple crown band, flat cut face down
local turnip = GV.ramp("#f1ece0", { shade = "#d8c49a", deep = "#b8a070" })
local function half(x, y)
  local m = c:ellipse(x, y, 5, 4.5)
  c:part(m, turnip, { cres = 2, deep = 1, gloss = false, contact = false, contour = "#7a2a4a" })
  c:fill(m:copy():cut(c:ellipse(x + 1, y + 4, 7, 5.5)), "#7a5cc0")   -- curved purple shoulders
  c:px(x - 3, y - 2, "#a894dc"); c:px(x - 2, y - 3, "#a894dc")
  c:px(x - 2, y + 1, "#fbf6e8")
  c:px(x, y + 5, "#b8a070"); c:px(x + 1, y + 6, "#b8a070")            -- root tail
  c:fill(c:rect(x - 1, y - 6, x, y - 5), "#4f9a45")                     -- leaf stub
end
half(22, 34); half(42, 35); half(31, 43); half(20, 48)
c:part(c:ellipse(43, 48, 4, 4), "#8a2a3a", { cres = 2, deep = 1, gloss = false, contact = false })   -- beet slice
c:fill(c:ellipse(43, 48, 2, 2):cut(c:ellipse(43, 48, 1, 1)), "#b8455a")
-- small oval label with a turnip emblem
c:part(c:ellipse(32, 51, 7, 4.5), "cream", { gloss = false, contact = false })
c:paint({
  ".g.g.",
  ".PPP.",
  "PPpPP",
  "bwwwb",
  ".bwb.",
  "..r..",
}, 26, 48, { g = "#4f9a45", P = "#7a5cc0", p = "#a894dc", w = "#f1ece0", b = "#b8a070", r = "#9a6b3f" })
c:paint({ "uu.u", "", "u.uu" }, 33, 50, { u = "#7a5a3a" })
-- wooden disc lid and knob
c:part(c:rrect(16, 11, 48, 19, 3), "#9a6b3f", { contour = "#5e2f1e", gloss = { 19, 13 } })
c:paint({ "gggg.ggggggg..gggg", "", "...gggggg..ggggggg" }, 22, 14, { g = "#7a4a1f" })
c:part(c:rrect(29, 7, 35, 11, 1), "#9a6b3f", { gloss = false, contact = false })
c:seam({ {18, 19}, {46, 19} })
c:gloss(bowl, "glass", { 16, 30 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
