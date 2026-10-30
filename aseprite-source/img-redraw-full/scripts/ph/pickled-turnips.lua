-- ph/pickled-turnips (Pantry pickle): wide fishbowl jar of beet-pink brine, round wooden disc lid.
-- Redraw B: the four small soft turnip halves become two big whole turnips (purple shoulders, white bulb, root tail,
-- leaf stubs, crisp umber contour) plus one dark beet slice; the label is dropped so the turnips carry the read.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-turnips"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(32, 38, 22, 18):add(c:rect(19, 17, 45, 24))
local brineM = c:ellipse(32, 39, 20, 15.5):cut(c:rect(0, 0, 63, 25))
c:build{
  { "glass", bowl, "glass" },
  { "brine", brineM, "#e46a9b", { contour = "#9a2a5a", gloss = false } },
}
c:fill(c:rect(14, 25, 50, 26):clip(brineM), "#f6b8cf")   -- lit top rows
c:fill(c:rect(14, 27, 50, 27):clip(brineM), "#ef8fb5")
-- whole turnips: round bulb, purple upper half, white lower half, tapering root tail, green leaf stubs
local white = GV.ramp("#f1ece0", { shade = "#d8c49a", deep = "#b8a070", rim = "#fbf6e8", pale = false })
local purple = GV.ramp("#7a5cc0", { shade = "#4e3a8a", deep = "#3e2f66", rim = "#a894dc", bounce = "#5e48a0" })
local function turnip(x, y, r)
  local bulb = c:ellipse(x, y, r, r - 0.5):add(c:poly({ {x - 3, y + r - 2}, {x + 4, y + r - 2}, {x + 1, y + r + 4}, {x, y + r + 4} }))
  local p = c:part(bulb, white, { cres = 3, deep = 1, gloss = false, contact = false, contour = "#4a2c1a" })
  -- purple shoulders: everything above a gentle curve
  local top = bulb:copy():cut(c:ellipse(x + 1, y + r + 2, r + 3, r + 1.5))
  c:part(top, purple, { cres = 2, deep = 1, gloss = false, contact = false, contour = false })
  c:px(x - r + 2, y - 2, "#a894dc"); c:px(x - r + 3, y - 3, "#a894dc"); c:px(x - r + 4, y - 4, "#c3b2ea")
  c:px(x - r + 3, y + 2, "#fbf6e8")
  c:fill(c:line({ {x - 1, y - r - 4}, {x - 1, y - r} }, 2), "#4f9a45")                -- leaf stubs
  c:fill(c:line({ {x + 3, y - r - 3}, {x + 1, y - r} }, 2), "#2f6a3a")
  c:px(x - 1, y - r - 4, "#7ab55c")
  return p
end
-- dark beet slice low on the left, half behind the big turnip (off the centre line so the group never reads as a face)
c:part(c:ellipse(18, 48, 4.5, 3.5), "#8a2a3a", { cres = 2, deep = 1, gloss = false, contact = false, contour = "#4a2c1a" })
c:fill(c:ellipse(18, 48, 2.5, 1.5):cut(c:ellipse(18, 48, 1, 0.5)), "#b8455a")
turnip(24, 38, 8)
turnip(40, 44, 7)
-- wooden disc lid and knob
c:part(c:rrect(16, 11, 48, 19, 3), "#9a6b3f", { contour = "#5e2f1e", gloss = { 19, 13 } })
c:paint({ "gggg.ggggggg..gggg", "", "...gggggg..ggggggg" }, 22, 14, { g = "#7a4a1f" })
c:part(c:rrect(29, 7, 35, 11, 1), "#9a6b3f", { gloss = false, contact = false })
c:seam({ {18, 19}, {46, 19} })
c:gloss(bowl, "glass", { 16, 30 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
