-- ph/pear-butter (Pantry spread): straight stoneware crock, swirl peak of pear butter, thin wooden disc lid tipped up on the rim, a rolled cinnamon quill across it
-- redraw A: lid is a thin disc (pale face + dark edge + growth rings) instead of a thick loaf; the quill is long, dark red-brown, with rolled scroll ends
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pear-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function rotEllipse(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  for y = cy - rx - 1, cy + rx + 1 do for x = cx - rx - 1, cx + rx + 1 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * math.cos(a) + dy * math.sin(a), -dx * math.sin(a) + dy * math.cos(a)
    if (u / (rx + 0.4)) ^ 2 + (v / (ry + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- swirl peak on the left half of the open crock
local swirl = c:ellipse(25, 29, 10, 3):add(c:ellipse(24, 25, 7, 3)):add(c:ellipse(23, 21, 4, 3)):add(c:rect(22, 16, 23, 18))
-- the lid: a round disc tipped up against the rim on the right, its face turned toward us
local face = rotEllipse(42, 21, 11, 8, -24)
local edge = face:copy():shift(2, 2):cut(face)
local stick = c:line({ {27, 25}, {56, 14} }, 3)
local W = GV.ramp("#d9a660", { shade = "#b07a45", deep = "#8a4f2a", bounce = "#c98a4a", rim = "#ecc58a" })
c:build{
  { "crock",  c:rrect(12, 29, 48, 55, 4), "#c9a96e", { gloss = { 16, 34 } } },
  { "swirl",  swirl, "#d8c070", { gloss = false } },
  { "edge",   edge, "#7a4a1f", { gloss = false, flat = true } },
  { "lid",    face, W, { gloss = false } },
  { "stick",  stick, "#b8582a", { gloss = false, flat = true, contour = "#3d1a10" } },
}
c:fill(c:rect(13, 48, 47, 50), "#9a6b3f"); c:fill(c:rect(13, 48, 47, 48), "#b0623a")   -- glaze band stripe
c:fill(c:rect(13, 30, 47, 30), "#e6d4ac")              -- crock lip
-- swirl groove
c:paint({ "..ss", ".s..", "s...sss", ".sss..." }, 18, 23, { s = "#b07a10" })
-- growth rings on the lid face
c:fill(rotEllipse(42, 21, 6, 4, -24):edge(), "#b07a45")
c:px(42, 21, "#8a4f2a"); c:px(43, 21, "#8a4f2a")
-- cinnamon quill: lit top line, dark split, rolled scroll at both ends
c:fill(c:line({ {29, 24}, {54, 14} }, 1), "#e8905a")
c:fill(c:line({ {31, 26}, {54, 17} }, 1), "#5e2414")
c:paint({ ".c.", "cks", ".s." }, 26, 24, { c = "#e08a50", k = "#5e2414", s = "#b8582a" })
c:paint({ ".c.", "cks", ".s." }, 53, 13, { c = "#e08a50", k = "#5e2414", s = "#b8582a" })
c:seam({ {14, 32}, {46, 32} })
-- label: pear with stalk and leaf
c:part(c:ellipse(30, 41, 9, 5), "cream", { gloss = false, contact = false })
c:paint({
  "...kgg.",
  "...k...",
  "..aaa..",
  "..aLa..",
  ".aaaaa.",
  "aaaaaas",
  ".aasss.",
}, 27, 37, { a = "#a4b86a", L = "#e6eea0", s = "#7ab55c", g = "#4f9a45", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
