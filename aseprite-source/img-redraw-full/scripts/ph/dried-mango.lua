-- ph/dried-mango (Pantry dried): flat bamboo mat, five golden mango strips fanned like cards from a twine tie
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "dried-mango"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mat = c:rrect(7, 41, 56, 55, 2)
c:part(mat, "#c9a96e", { gloss = false, stitch = true })
for x = 10, 54, 3 do c:fill(c:rect(x, 43, x, 53):clip(mat), "#9a6b3f") end
-- burned mango mark on the mat (clears the slats under it)
c:paint({
  "....ll..",
  "..bbbl..",
  ".bbbbbb.",
  "bbbbbbbb",
  "bbbbbbbb",
  ".bbbbbb.",
  "..bbbb..",
}, 28, 46, { b = "#7a4a1f", l = "#4f6a2a" })
c:fill(c:rect(27, 45, 27, 53), "#c9a96e"); c:fill(c:rect(36, 45, 36, 53), "#c9a96e")
-- strips: long tapering tongues from the tie to pointed tips
local bx, by = 32, 42
local function strip(tx, ty)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy, px, py = dx / L, dy / L, -dy / L, dx / L
  local function at(t, w) return { bx + dx * t + px * w, by + dy * t + py * w } end
  local m = c:poly({ at(0, -2.5), at(0.45, -3.6), at(0.8, -3), at(0.95, -1.5), at(1.02, 0), at(0.95, 1.5), at(0.8, 3), at(0.45, 3.6), at(0, 2.5) })
  c:part(m, "#f0a02f", { cres = 3, deep = 0, gloss = false })
  c:fill(c:line({ at(0.25, 0.5), at(0.85, 0.5) }, 1), "#c8661f")       -- fibre line
  c:fill(c:line({ at(0.35, -2), at(0.7, -2) }, 1), "#f5cf6a")          -- sun-gold lit edge
end
strip(9, 21); strip(55, 21); strip(18, 11); strip(46, 11); strip(32, 7)
-- twine tie with a cross hatch and a bow
c:part(c:rrect(25, 37, 39, 43, 1), "#7a4a1f", { gloss = false, cres = 2 })
for x = 26, 38, 2 do c:px(x, 39, "#c98a4a"); c:px(x + 1, 41, "#c98a4a") end
c:paint({ "bb.bb", "bBkBb", "bb.bb", ".b.b." }, 38, 38, { b = "#9a6b3f", B = "#c98a4a", k = "#4e2a16" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
