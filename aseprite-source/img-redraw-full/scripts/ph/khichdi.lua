-- ph/khichdi (Gourmand P2 dish): wide white bowl of turmeric-yellow porridge, glossy ghee dab, cumin specks, spoon leaning right
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "khichdi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(31.5, 36, 24, 18):clip(c:rect(0, 36, 63, 63)):add(c:ellipse(31.5, 36, 24, 7))
bowl:cut(c:rect(0, 52, 63, 63)):add(c:rrect(22, 49, 41, 54, 2))    -- flat foot
c:build{
  { "bowl", bowl, "cream" },
}
-- porridge: rim ellipse plus a soft mound
local por = c:ellipse(31.5, 36, 20.5, 5.5):add(c:ellipse(30, 33, 14, 4.5))
c:part(por, "#e8b83a", { contour = "#b8661a", gloss = { 21, 33 }, cres = 3, deep = 0, contact = false })
-- blue glaze band on the bowl belly
c:fill(c:ellipse(31.5, 36, 23, 13):clip(c:rect(0, 44, 63, 45)):cut(c:rect(0, 0, 9, 63)):cut(c:rect(54, 0, 63, 63)), "#3f8fb0")
c:seam({ {12, 46}, {51, 46} }, { gap = "#2f6290" })
-- ghee dab (melting)
c:paint({
  ".hhhhh..",
  "hHHhhhhh",
  "hhhhhhhs",
  ".hhhhss.",
  "...ss...",
}, 27, 32, { h = "#fff0a0", H = "#fff3c8", s = "#f5cf6a" })
for _, p in ipairs({ {20, 35}, {24, 31}, {37, 31}, {41, 35}, {22, 38}, {33, 38}, {45, 37} }) do
  c:px(p[1], p[2], "#6b4a2a"); c:px(p[1], p[2] + 1, "#6b4a2a")    -- cumin seeds 1x2
end
-- spoon: bowl buried in the porridge, handle leaning out to the right
c:part(c:line({ {40, 33}, {55, 24} }, 3), "stone", { flat = true, contact = false })
c:fill(c:line({ {41, 34}, {55, 26} }, 1), "#5b6470")
c:part(c:ellipse(38, 35, 3, 1.5), "stone", { flat = true, contact = false })
c:ground(31.5, 55, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
