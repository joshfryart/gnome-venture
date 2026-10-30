-- ph/lemon-curd (Pantry curd): wide-mouthed jar of bright curd, cellophane gathered at the neck into a pinked fan-shaped tuft, tied with a big gold bow
-- redraw A: the bow sits on the pale cellophane (never on the curd) with a deep umber contour; the cellophane is a crinkled fan with a zigzag top and a pinked skirt, not a puffy dome
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "lemon-curd"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- tuft: fan above the tie with a pinked (zigzag) top edge
local tuft = c:poly({ {25, 25}, {39, 25}, {48, 13}, {16, 13} })
for x = 16, 46, 4 do tuft:add(c:poly({ {x, 13}, {x + 4, 13}, {x + 2, 9} })) end
-- skirt: cellophane draped over the jar shoulder, pinked hem
local skirt = c:poly({ {24, 27}, {40, 27}, {53, 34}, {11, 34} })
for x = 11, 49, 4 do skirt:add(c:poly({ {x, 34}, {x + 4, 34}, {x + 2, 37} })) end
local CELLO = { base = "#e4f0f2", rim = "#f8fcf4", shade = "#b9dcec", deep = "#8fb4d6", bounce = "#c9e6f2", gloss = "#f8fcf4", dot = "#f8fcf4", pale = true }
local loops = c:poly({ {32, 27}, {19, 21}, {18, 32} }):add(c:poly({ {32, 27}, {46, 21}, {47, 32} }))
local tails = c:poly({ {30, 28}, {33, 28}, {26, 36}, {23, 35} }):add(c:poly({ {32, 28}, {35, 28}, {42, 35}, {39, 36} }))
c:build{
  { "glass", c:rrect(13, 30, 51, 55, 5), "glass" },
  { "curd",  c:rrect(15, 36, 49, 53, 4), "#f5d828", { contour = "#d0862a", gloss = false } },
  { "label", c:rect(21, 41, 43, 51), "cream", { gloss = false, contact = false } },
  { "skirt", skirt, CELLO, { gloss = false } },
  { "tuft",  tuft, CELLO, { gloss = false } },
  { "tails", tails, "gold", { gloss = false, flat = true, contour = "#5e2a10" } },
  { "loops", loops, "gold", { gloss = false, contour = "#5e2a10" } },
  { "knot",  c:rrect(29, 24, 35, 30, 2), "gold", { gloss = false, flat = true, contour = "#5e2a10" } },
}
-- crinkle folds in the cellophane: vertical pleat lines fanning out from the tie
for _, l in ipairs({ { {28, 24}, {22, 13} }, { {32, 24}, {32, 11} }, { {36, 24}, {42, 13} } }) do c:fill(c:line(l, 1), "#a9d6ea") end
for _, l in ipairs({ { {16, 33}, {20, 30} }, { {48, 33}, {44, 30} } }) do c:fill(c:line(l, 1), "#a9d6ea") end
c:fill(c:line({ {19, 15}, {21, 20} }, 1), "#f8fcf4")
c:px(19, 14, "#ffffff")                                  -- the one white highlight
-- loop openings (dark) and lit upper edges so each loop reads as a ribbon
c:fill(c:rect(23, 25, 26, 28), "#b8661a"); c:fill(c:rect(38, 25, 41, 28), "#b8661a")
c:fill(c:line({ {20, 22}, {30, 26} }, 1), "#f5cf6a"); c:fill(c:line({ {34, 26}, {44, 22} }, 1), "#f5cf6a")
c:fill(c:rect(31, 25, 32, 25), "#fff1c8")
c:fill(c:rect(16, 37, 48, 37), "#f1ece0")               -- curd top sheen
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
}, 28, 42, { r = "#e8a317", y = "#f5d828", t = "#f1ece0", k = "#d0862a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
