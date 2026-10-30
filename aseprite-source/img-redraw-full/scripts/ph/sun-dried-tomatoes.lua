-- ph/sun-dried-tomatoes (Pantry dried): five wrinkled red tomato halves dangling on cords from a wooden peg hook, tag below
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "sun-dried-tomatoes"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wooden peg and iron hook
c:part(c:rrect(25, 6, 39, 10, 2), "wood", { gloss = false })
c:px(28, 8, "#5e2f1e"); c:px(36, 8, "#5e2f1e")
c:part(c:line({ {32, 10}, {32, 12} }, 2):add(c:line({ {30, 13}, {31, 14} }, 2)), "stone", { flat = true })
-- cords from the fork to each half
local tops = { {14, 24}, {23, 29}, {32, 32}, {41, 29}, {50, 24} }
local cord = c:line({ {32, 14}, {32, 18} }, 1)
for _, p in ipairs(tops) do cord:add(c:line({ {32, 18}, p }, 1)) end
c:part(cord, "#c9a96e", { flat = true, rim = false, contact = false })
c:paint({ ".k.", "kkk", ".k." }, 31, 17, { k = "#9a6b3f" })
-- tomato halves: a cupped half (lit skin edge, dark inner face, wrinkles), outer ones first
local function half(x, y, s)
  local m = c:ellipse(x, y, 4.5 * s, 6 * s):cut(c:ellipse(x + 5 * s, y + 1, 2, 2.5))
  c:part(m, "#a8241f", { gloss = false, cres = 2 })
  c:fill(c:ellipse(x, y + 1, 2.5 * s, 4 * s):cut(c:ellipse(x + 5 * s, y + 1, 3, 3.5)), "#7a1a24")
  c:fill(c:line({ {x - 2, y - 4}, {x, y - 3}, {x - 1, y - 1} }, 1), "#5a1420")
  c:fill(c:line({ {x - 3, y + 1}, {x - 1, y + 2}, {x - 2, y + 4} }, 1), "#5a1420")
  c:fill(c:line({ {x + 1, y + 3}, {x + 2, y + 5} }, 1), "#5a1420")
  c:px(x - 3, y - 3, "#f2793a"); c:px(x - 4, y - 2, "#d6322b"); c:px(x - 4, y - 1, "#d6322b"); c:px(x - 2, y - 5, "#d6322b")
end
half(14, 30, 1); half(50, 30, 1); half(23, 35, 1); half(41, 35, 1); half(32, 39, 1.15)
for _, p in ipairs(tops) do c:px(p[1], p[2], "#9a6b3f") end
-- tag with a tomato
c:fill(c:rect(32, 47, 32, 48), "#9a6b3f")
c:part(c:rrect(26, 49, 38, 56, 1), "cream", { gloss = false, contact = false })
c:paint({
  "..g.g..",
  "...g...",
  ".rrrrr.",
  "rRrrrrd",
  ".rrrdd.",
}, 29, 50, { r = "#d6322b", R = "#ff9158", d = "#a8241f", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
