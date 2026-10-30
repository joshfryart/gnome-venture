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
-- label (redraw A): a strig of three round berries hanging from a green stem with a leaf.
-- No stripes: the old striped berry centred on the label read as an eye at 1x.
c:fill(c:rect(25, 34, 37, 34), "#4f9a45")
c:paint({ "ll.", "lll", ".l." }, 37, 33, { l = "#4f9a45" })
for _, b in ipairs({ {25, 36, 1}, {30, 38, 3}, {35, 36, 1} }) do
  c:fill(c:rect(b[1] + 1, 35, b[1] + 1, 35 + b[3]), "#7a4a1f")
  c:paint({ ".dd.", "dLdd", "dddd", ".dd." }, b[1], b[2] + 0, { d = "#3a2850", L = "#a894dc" })
end
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
