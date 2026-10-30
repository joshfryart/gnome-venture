-- ph/guava-jam (Pantry jam): tulip jar with a flared mouth, pale glass disc lid on an orange seal ring, two steel clips on the sides
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "guava-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:rrect(16, 24, 48, 54, 10):add(c:rect(15, 22, 49, 26))
local clipL = c:rect(12, 16, 14, 32):add(c:rect(12, 14, 19, 16))
local clipR = c:rect(50, 16, 52, 32):add(c:rect(45, 14, 52, 16))
c:build{
  { "glass", glass, "glass" },
  { "jam",   c:rrect(18, 28, 46, 52, 8), "#e87aa0", { contour = "#a83a6a", gloss = { 21, 31 } } },
  { "label", c:rect(23, 36, 41, 48), "cream", { gloss = false, contact = false } },
  { "ring",  c:rect(15, 20, 49, 22), "#f08a24", { gloss = false } },
  { "lid",   c:rrect(16, 13, 48, 20, 3), "#c9e6f2", { gloss = false } },
  { "clipL", clipL, "stone", { flat = true } },
  { "clipR", clipR, "stone", { flat = true } },
}
c:px(21, 15, "#f8fcf4"); c:px(22, 15, "#eef8f2"); c:px(21, 16, "#eef8f2")   -- glass lid glint
c:fill(c:rect(19, 18, 45, 18), "#8fcbd8")
c:fill(c:rect(13, 30, 13, 31), "#c9c5bc"); c:fill(c:rect(51, 30, 51, 31), "#c9c5bc")
c:seam({ {16, 21}, {48, 21} })
-- label: guava half, green rind ring, pink flesh, gold seeds
c:paint({
  "..ggggg..",
  ".gpppppg.",
  "gppypyppg",
  "gpypppypg",
  "gppypyppg",
  ".gpppppg.",
  "..ggggg..",
}, 28, 38, { g = "#7ab55c", p = "#f6b8cf", y = "#e8a317" })
c:paint({ "uuu.uu.uu" }, 28, 46, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
