-- ph/jostaberry-jam (Pantry jam): waisted hourglass jar (wide shoulder, pinched waist, wide base) under a scalloped steel crown cap
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "jostaberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:poly({ {23, 15}, {42, 15}, {42, 21}, {48, 25}, {50, 30}, {43, 38}, {50, 46}, {50, 52}, {47, 56}, {18, 56}, {15, 52}, {15, 46}, {22, 38}, {15, 30}, {17, 25}, {23, 21} })
local fill  = c:poly({ {25, 19}, {40, 19}, {40, 23}, {46, 27}, {47, 30}, {40, 38}, {47, 46}, {48, 51}, {46, 54}, {19, 54}, {17, 51}, {18, 46}, {25, 38}, {18, 30}, {19, 27}, {25, 23} })
local cap = c:rect(21, 8, 43, 14)
for x = 20, 43, 4 do cap:add(c:rect(x, 15, x + 1, 16)) end   -- crown scallops
c:build{
  { "glass", glass, "glass" },
  { "jam",   fill, "#3a2850", { contour = "#1e1438", gloss = { 20, 29 } } },
  { "label", c:rect(25, 33, 40, 43), "cream", { gloss = false, contact = false } },
  { "cap",   cap, "stone", { gloss = false } },
}
c:fill(fill:copy():clip(c:rect(0, 19, 63, 23)), "#5a7a40")   -- green gooseberry tint at the top
c:fill(fill:copy():clip(c:rect(0, 23, 63, 23)), "#3f5a2a")
for x = 23, 41, 3 do c:fill(c:rect(x, 9, x, 13), "#5b6470") end   -- crimp ridges
c:fill(c:rect(22, 9, 42, 9), "#c9c5bc")
for _, s in ipairs({ {21, 28}, {42, 28}, {20, 49}, {28, 51}, {37, 50}, {44, 49} }) do c:px(s[1], s[2], "#7b66b4") end
-- label: dark berry with three green stripes and a whisker tip
c:paint({
  "...kk...",
  "..dddd..",
  ".dgdgdg.",
  "dLgdgdgd",
  "ddgdgdgd",
  ".dgdgdd.",
  "..dddd..",
  "...k....",
}, 26, 34, { d = "#3a2850", L = "#7b66b4", g = "#5a7a40", k = "#7a4a1f" })
c:paint({ "uuu", "", "uu", "", "uuu" }, 35, 36, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
