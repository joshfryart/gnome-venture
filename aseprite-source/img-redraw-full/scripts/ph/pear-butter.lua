-- ph/pear-butter (Pantry spread): straight stoneware crock, swirl peak of pear butter, tilted wooden disc lid with a cinnamon stick across it
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pear-butter"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local swirl = c:ellipse(28, 28, 13, 4):add(c:ellipse(26, 24, 8, 4)):add(c:ellipse(25, 20, 4, 3)):add(c:rect(24, 16, 25, 17))
local function rotEllipse(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  for y = cy - rx - 1, cy + rx + 1 do for x = cx - rx - 1, cx + rx + 1 do
    local dx, dy = x - cx, y - cy
    local u, v = dx * math.cos(a) + dy * math.sin(a), -dx * math.sin(a) + dy * math.cos(a)
    if (u / (rx + 0.4)) ^ 2 + (v / (ry + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local lid = rotEllipse(43, 21, 12, 5, -14):add(rotEllipse(43, 23, 12, 5, -14))
local stick = c:line({ {31, 19}, {49, 14} }, 2)
c:build{
  { "crock",  c:rrect(14, 28, 50, 54, 4), "#c9a96e", { gloss = { 18, 33 } } },
  { "swirl",  swirl, "#d8c070", { gloss = false } },
  { "lid",    lid, "wood", { gloss = false } },
  { "stick",  stick, "#a8582f", { gloss = false, flat = true } },
  { "label",  c:ellipse(32, 41, 9, 5), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(15, 48, 49, 50), "#9a6b3f"); c:fill(c:rect(15, 48, 49, 48), "#b0623a")   -- glaze band stripe
c:fill(c:rect(15, 29, 49, 29), "#e6d4ac")              -- crock lip
-- swirl groove
c:paint({ "..ss", ".s..", "s...ssss", ".sss...ss" }, 18, 22, { s = "#b07a10" })
c:px(24, 18, "#b07a10")
-- lid edge, cinnamon quill rolled end and its split
c:fill(c:line({ {33, 26}, {54, 21} }, 1), "#8a4f2a")
c:paint({ "cc", "kc" }, 30, 19, { c = "#e8a060", k = "#7a4a1f" })
for _, g in ipairs({ {38, 23}, {44, 21}, {50, 20}, {36, 27}, {46, 25} }) do c:px(g[1], g[2], "#8a4f2a"); c:px(g[1] + 1, g[2], "#8a4f2a") end
c:seam({ {16, 31}, {48, 31} })
-- label: pear with stalk and leaf
c:paint({
  "...kgg.",
  "...k...",
  "..aaa..",
  "..aLa..",
  ".aaaaa.",
  "aaaaaas",
  ".aasss.",
}, 29, 37, { a = "#a4b86a", L = "#e6eea0", s = "#7ab55c", g = "#4f9a45", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
