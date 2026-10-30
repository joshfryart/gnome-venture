-- ph/pickled-asparagus (Pantry pickle): tall square-shouldered jar, cork stopper, hemp twine bow at the neck, spears with bud tips above the brine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-asparagus"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(17, 20, 47, 56, 3):add(c:rect(22, 13, 42, 21))
c:build{
  { "glass", body, "glass" },
  { "brine", c:rect(19, 28, 45, 54), "#e0f0d0", { contour = "#8fb4a0", gloss = false } },
}
c:fill(c:rect(19, 28, 45, 28), "#8fb4a0")   -- brine line
-- spears: six upright 3 px stalks, bud tips above the brine line
local xs, tops = { 20, 24, 28, 33, 37, 41 }, { 24, 22, 25, 21, 23, 26 }
for i, x in ipairs(xs) do
  local y = tops[i]
  c:fill(c:rect(x, y + 2, x + 2, 54), "#7ab55c")
  c:fill(c:rect(x + 2, y + 3, x + 2, 54), "#4f9a45")
  c:fill(c:rect(x, y + 3, x, 53), "#a4b86a")
  -- bud: pointed tip
  c:px(x + 1, y, "#4f9a45")
  c:fill(c:rect(x, y + 1, x + 2, y + 2), "#4f9a45"); c:px(x, y + 1, "#6a9a3a")
  c:fill(c:rect(x, y + 3, x + 2, y + 3), "#2f5a2a")
  for yy = y + 8, 52, 7 do c:px(x + 1, yy, "#4a8a3e"); c:px(x + 2, yy + 1, "#2f5a2a") end   -- scale ticks
end
c:px(40, 31, "#4f9a45"); c:px(41, 32, "#4f9a45"); c:px(40, 33, "#4f9a45")   -- dill
-- label with a spear emblem
c:part(c:rect(22, 40, 42, 51), "cream", { gloss = false, contact = false })
c:paint({
  "..G..",
  ".GgG.",
  "..g..",
  ".Gg..",
  "..g..",
  "..gG.",
  "..g..",
  "..g..",
  "..s..",
}, 23, 41, { G = "#4f9a45", g = "#7ab55c", s = "#c9b878" })
c:paint({ "uuu.uu", "", "uu.uuuu", "", "uuuu" }, 31, 43, { u = "#7a5a3a" })
-- cork and twine with a bow
c:part(c:rrect(24, 6, 40, 13, 2), "#c9a96e", { contour = "#7a4a1f", gloss = { 27, 8 } })
c:px(29, 10, "#9a6b3f"); c:px(35, 9, "#9a6b3f"); c:px(32, 11, "#9a6b3f")
c:part(c:rect(21, 16, 43, 18), "#c9a96e", { cres = 1, deep = 0, gloss = false, contact = false })
for x = 22, 42, 3 do c:px(x, 17, "#9a6b3f") end
c:paint({
  ".tt.tt.",
  "tTtktTt",
  ".tt.tt.",
  "..t.t..",
  "..t..t.",
}, 39, 14, { t = "#c9a96e", T = "#ecc58a", k = "#7a4a1f" })
c:gloss(c:rect(17, 20, 47, 56), "glass", { 20, 30 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
