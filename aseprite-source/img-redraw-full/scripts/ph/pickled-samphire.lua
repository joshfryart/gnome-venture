-- ph/pickled-samphire (Pantry pickle): jar with a thick nautical rope coil round the neck, dark cork, sea-blue brine, branching green samphire, scallop-shell label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-samphire"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(16, 24, 48, 56, 8):add(c:rect(22, 18, 42, 25)), "glass" },
  { "brine", c:rrect(18, 30, 46, 54, 6), "#bfe3ee", { contour = "#3f8fb0", gloss = false } },
}
c:fill(c:rect(20, 30, 44, 30), "#8fcbd8")
-- samphire: 2 px antler branches with 1 px twigs, rising from the base
local G, g = "#5a9a5a", "#7ab55c"
local function sprig(x, top, dir)
  c:fill(c:line({ {x, 54}, {x, top + 4}, {x + dir, top} }, 2), G)
  c:fill(c:line({ {x, top + 9}, {x - 3 * dir, top + 5}, {x - 3 * dir, top + 3} }, 1), g)
  c:fill(c:line({ {x + 1, top + 14}, {x + 4 * dir, top + 10} }, 1), g)
  c:px(x + dir, top - 1, "#a4d07a"); c:px(x - 3 * dir, top + 2, "#a4d07a")
end
sprig(23, 33, 1); sprig(30, 31, -1); sprig(37, 34, 1); sprig(43, 37, -1)
-- label with a scallop shell emblem
c:part(c:rrect(23, 42, 41, 53, 2), "cream", { gloss = false, contact = false })
c:paint({
  "..ppppp..",
  ".pPrprpp.",
  "prprprprp",
  "pprprprpp",
  ".prprprp.",
  "..prprp..",
  "...bbb...",
  "..bbbbb..",
}, 28, 43, { p = "#f6b8cf", P = "#fbe3ea", r = "#e46a9b", b = "#c9a96e" })
-- cork and three rope coils
c:part(c:rrect(25, 9, 39, 17, 2), "#9a6b3f", { contour = "#5e2f1e", gloss = { 27, 11 } })
c:px(30, 13, "#7a4a1f"); c:px(35, 12, "#7a4a1f")
local rope = GV.ramp("#c9a96e", { shade = "#9a6b3f", deep = "#7a4a1f" })
for i, y in ipairs({ 17, 20, 23 }) do
  local m = c:rrect(20, y, 44, y + 2, 1)
  c:part(m, rope, { cres = 1, deep = 0, gloss = false, contact = false, contour = "#5e2f1e" })
  for x = 21 + i, 43, 3 do c:px(x, y, "#ecd9a8"); c:px(x + 1, y + 1, "#9a6b3f"); c:px(x + 2, y + 2, "#7a4a1f") end   -- twist ticks
end
c:gloss(c:rrect(16, 24, 48, 56, 8), "glass", { 19, 32 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
