-- ph/peanut-butter (Pantry spread): wide squat jar, knurled wide lid, smooth tan butter with a swirl, peanut label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "peanut-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:rrect(14, 25, 50, 54, 8):add(c:rect(17, 23, 47, 26)), "glass" },
  { "butter", c:rrect(16, 28, 48, 52, 6), "#c9a96e", { contour = "#7a4a1f", gloss = { 19, 34 } } },
  { "label",  c:rrect(21, 38, 43, 48, 2), "cream", { gloss = false, contact = false } },
  { "lid",    c:rrect(12, 15, 52, 24, 3), "gold" },
}
for x = 15, 49, 2 do c:px(x, 16, x < 30 and "#f5cf6a" or "#d0862a"); c:px(x, 23, "#b8661a") end   -- knurled rims
c:seam({ {14, 20}, {50, 20} })
-- swirl on the butter top: a raised curl (light) with a dark groove below
c:paint({
  "...LLLLLL..........LLLLL...",
  "..L......LL......LL.....L..",
  ".Lggggg....LLLLLL...ggg..L.",
  "......ggg..........g...g...",
  ".........gggggggggg........",
}, 18, 29, { L = "#efdcae", g = "#8a5a2f" })
-- label: peanut shell (two lobes with a pinched waist)
c:paint({
  ".uuuu....uuuu.",
  "uPpppuuuupppku",
  "upppkppppppppu",
  "uppppppppkpppu",
  "uppppuuuupppsu",
  ".uuuu....uuuu.",
}, 23, 40, { p = "#d9b878", P = "#efdcae", k = "#9a6b3f", s = "#b08a50", u = "#5e2f1e" })
c:paint({ "uuu", "", "uu" }, 38, 42, { u = "#7a5a3a" })
c:ground(32, 56, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
