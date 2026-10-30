-- ph/falafel (Gourmand P2 dish): paper cone cut in a V holding crisp falafel, the top one broken open green
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "falafel"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function ball(x, y, hex)
  local p = c:part(c:ellipse(x, y, 7, 7), hex, { cres = 4, contact = false })
  for _, d in ipairs({ {-3, 1}, {2, -2}, {3, 3}, {-1, 4}, {-4, -2} }) do c:px(x + d[1], y + d[2], "#6a3a1a") end   -- crust crumbs
  return p
end
ball(23, 25, "#9a5a2a"); ball(41, 25, "#a8662e"); ball(32, 30, "#9a5a2a")
-- top ball, broken open: crust ring around a bright herby centre
local top = c:part(c:ellipse(32, 15, 7.5, 7), "#a8662e", { contact = false, gloss = { 27, 11 } })
local cut = c:ellipse(33, 16, 5.5, 5)
c:fill(cut:edge(), "#e6c08a")                                        -- pale crumb ring where it broke
c:fill(cut:shrink(1), "#7ab648")
c:fill(c:ellipse(34.5, 17.5, 2.5, 2), "#4a8a3e")
for _, p in ipairs({ {31, 14}, {33, 13}, {30, 17}, {35, 15} }) do c:px(p[1], p[2], "#c8d77a") end
for _, p in ipairs({ {32, 16}, {36, 18}, {33, 19} }) do c:px(p[1], p[2], "#2f5a2a") end
-- paper cone cut in a V
local cone = c:poly({ {12, 28}, {32, 35}, {52, 28}, {33, 56}, {31, 56} })
c:part(cone, "cream", { light = cone })
c:fill(c:line({ {32, 36}, {32, 54} }, 1), "#c9bfa8")                   -- fold
c:fill(c:line({ {14, 29}, {32, 35} }, 1), "#fff3c8")                   -- lit cut edge
c:seam({ {18, 38}, {31, 43} }, { gap = "#d8c49a" })                     -- glued paper seam
c:seam({ {34, 43}, {46, 38} }, { gap = "#d8c49a" })
-- sesame
for _, p in ipairs({ {20, 22}, {26, 21}, {44, 22}, {39, 21}, {29, 28}, {28, 10}, {37, 9} }) do c:px(p[1], p[2], "#f1ece0") end
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
