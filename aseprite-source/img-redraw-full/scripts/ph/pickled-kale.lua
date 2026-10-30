-- ph/pickled-kale (Pantry ferment-pickle): wide-shouldered jar, grey rubber bung with a little S airlock, glass weight disc pressing dark ruffled kale
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-kale"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(14, 24, 50, 56, 9):add(c:rect(22, 19, 42, 25))
c:build{
  { "glass", body, "glass" },
  { "brine", c:rrect(16, 31, 48, 54, 7), "#d0e4b8", { contour = "#6a9a3a", gloss = false } },
}
-- ruffled kale leaves: dark frilly blobs with a pale midrib
local kale = GV.ramp("#2f5a2a", { gloss = "#7ab55c", rim = "#4f9a45", shade = "#23431f", deep = "#162a14", bounce = "#2a4a24" })
local function leaf(x, y, w, h)
  local m = c:ellipse(x, y, w, h)
  for i = -w, w, 3 do m:add(c:ellipse(x + i, y - h + 1, 2, 2)) end   -- frilly top edge
  c:part(m, kale, { cres = 2, deep = 1, gloss = false, contact = false, contour = "#162a14" })
  for i = -w + 1, w - 1, 3 do c:px(x + i, y - h, "#4f9a45") end
  c:fill(c:line({ {x - w + 2, y + 1}, {x + w - 2, y - 1} }, 1), "#7ab55c")
end
leaf(24, 38, 6, 4); leaf(39, 37, 7, 4); leaf(42, 47, 5, 4); leaf(22, 49, 5, 3)
-- glass weight disc pressing the leaves
c:part(c:ellipse(32, 31, 12, 2.5), "#c9e6f0", { flat = true, contour = "#7fb6cc" })
c:fill(c:rect(24, 30, 31, 30), "#eef8f2")
-- label with a kale leaf emblem
c:part(c:rrect(23, 41, 41, 52, 2), "cream", { gloss = false, contact = false })
c:paint({
  ".k.k.",
  "kkkkk",
  ".kgk.",
  "kkgkk",
  ".kgk.",
  "..g..",
  "..g..",
}, 25, 43, { k = "#2f5a2a", g = "#7ab55c" })
c:paint({ "uuu.uu", "", "uu.uuu", "", "uuuu" }, 32, 44, { u = "#7a5a3a" })
-- rubber bung and S-bend airlock
c:part(c:rrect(25, 14, 39, 21, 2), "#5b6470", { contour = "#3d4650", gloss = { 27, 15 } })
c:seam({ {26, 20}, {38, 20} })
local tube = c:line({ {32, 14}, {32, 10}, {33, 8}, {37, 8}, {38, 10}, {38, 13} }, 2)
c:part(tube, "#c9e6f0", { flat = true, contour = "#7fb6cc" })
c:part(c:ellipse(39, 14, 2.5, 2.5), "#c9e6f0", { flat = true, contour = "#7fb6cc" })   -- bubble chamber
c:fill(c:rect(38, 15, 40, 16), "#3f8fb0"); c:px(38, 15, "#8fcbd8")
c:gloss(c:rrect(14, 24, 50, 56, 9), "glass", { 18, 30 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
