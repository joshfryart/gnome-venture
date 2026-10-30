-- ph/lemon-curd (Pantry curd): wide-mouthed jar of bright curd under a pale cellophane dome gathered with a big gold ribbon bow
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "lemon-curd"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cello = c:ellipse(32, 20, 15, 7):clip(c:rect(0, 0, 63, 22)):add(c:rect(24, 20, 40, 26))
cello:add(c:poly({ {24, 26}, {40, 26}, {50, 33}, {14, 33} }))
local loops = c:ellipse(24, 27, 6, 4):add(c:ellipse(40, 27, 6, 4))
local tails = c:line({ {30, 30}, {25, 38} }, 3):add(c:line({ {34, 30}, {39, 38} }, 3))
local CELLO = { base = "#eef4ec", rim = "#f8fcf4", shade = "#c9e6f2", deep = "#a9d6ea", bounce = "#c9e6f2", gloss = "#f8fcf4", dot = "#f8fcf4", pale = true }
c:build{
  { "glass", c:rrect(13, 29, 51, 54, 5), "glass" },
  { "curd",  c:rrect(15, 33, 49, 52, 4), "#f5d828", { contour = "#d0862a", gloss = false } },
  { "label", c:rect(21, 40, 43, 50), "cream", { gloss = false, contact = false } },
  { "cello", cello, CELLO, { gloss = false } },
  { "tails", tails, "gold", { gloss = false, flat = true, contour = "#7a3a14" } },
  { "loops", loops, "gold", { gloss = false, flat = true, contour = "#7a3a14" } },
  { "knot",  c:rrect(29, 24, 35, 30, 2), "gold", { gloss = false, flat = true, contour = "#7a3a14" } },
}
c:fill(c:rect(16, 34, 48, 34), "#f1ece0")               -- curd top sheen
c:fill(c:line({ {22, 15}, {19, 20} }, 1), "#f8fcf4"); c:fill(c:line({ {27, 14}, {26, 18} }, 1), "#f8fcf4")   -- cellophane sheen
c:px(23, 15, "#ffffff")                                  -- the one white highlight
for _, x in ipairs({ 26, 30, 34, 38 }) do c:px(x, 21, "#a9d6ea"); c:px(x, 22, "#c9e6f2") end   -- gathered pleats above the bow
c:fill(c:rect(22, 26, 25, 28), "#b8661a"); c:fill(c:rect(39, 26, 42, 28), "#b8661a")   -- loop openings
c:fill(c:rect(21, 24, 25, 24), "#f5cf6a"); c:fill(c:rect(37, 24, 41, 24), "#f5cf6a")
c:fill(c:rect(31, 25, 32, 25), "#f5cf6a")
-- label: lemon slice, pale rind ring with radial ticks
c:paint({
  "..rrrrr..",
  ".ryyyyyr.",
  "ryktyktyr",
  "rytykytyr",
  "ryyyyyyyr",
  "rytykytyr",
  "ryktyktyr",
  ".ryyyyyr.",
  "..rrrrr..",
}, 28, 40, { r = "#e8a317", y = "#f5d828", t = "#f1ece0", k = "#d0862a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
