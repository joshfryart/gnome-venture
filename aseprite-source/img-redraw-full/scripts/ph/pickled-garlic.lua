-- ph/pickled-garlic (Pantry pickle): bulb-shaped pot-belly jar tapering to a twisted paper neck tied with red string, pointed cloves inside
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-garlic"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 41, 17, 15):add(c:poly({ {19, 33}, {27, 22}, {38, 22}, {46, 33} }))
local brine = c:ellipse(32, 41, 15, 13):cut(c:rect(0, 0, 63, 30))
c:build{
  { "glass", body, "glass" },
  { "brine", brine, "#ecd9a0", { contour = "#b8986a", gloss = false } },
}
c:fill(c:rect(18, 30, 46, 30):clip(c:ellipse(32, 41, 15, 13)), "#c9b070")
-- cloves: curved teardrops with pointed tips
local cl = GV.ramp("#f4f0e0", { shade = "#e0c8a0", deep = "#b8986a" })
local function clove(x, y, dx, dy)
  -- plump teardrop: round heel at (x, y), pointed tip 7 px along (dx, dy)
  local tx, ty = x + dx * 7, y + dy * 7
  local m = c:ellipse(x, y, 3.5, 3.5):add(c:poly({ {x - dy * 3.5, y + dx * 3.5}, {x + dy * 3.5, y - dx * 3.5}, {tx, ty}, {tx + 1, ty + 1} }))
  c:part(m, cl, { cres = 2, deep = 0, gloss = false, contact = false, contour = "#6a4a2a" })
  c:px(math.floor(tx + 0.5), math.floor(ty + 0.5), "#c9a070")
  c:fill(c:line({ {x + dy * 2, y - dx * 2}, {math.floor(x + dx * 4 + dy + 0.5), math.floor(y + dy * 4 - dx + 0.5)} }, 1), "#e0c8a0")  -- crease
  c:px(x - 2, y - 1, "#fbf6e8"); c:px(x + 1, y + 2, "#b88aa8")   -- sheen, purple skin fleck
end
clove(22, 41, 0.45, -0.9); clove(32, 40, 0, -1); clove(42, 41, -0.45, -0.9)
clove(21, 49, 0.9, -0.45); clove(43, 49, -0.9, -0.45)
-- oval label with a garlic bulb emblem
c:part(c:ellipse(32, 49, 6.5, 4.5), "cream", { gloss = false, contact = false })
c:paint({
  "...b...",
  "..bwb..",
  ".bwbwb.",
  "bwWbwwb",
  ".bwbwb.",
  "..r.r..",
}, 29, 45, { b = "#c9b878", w = "#f4f0e0", W = "#fbf6e8", r = "#9a6b3f" })
-- twisted paper neck, frayed top, and red string bow
local twist = c:poly({ {26, 23}, {39, 23}, {36, 14}, {37, 10}, {28, 10}, {29, 14} })
c:part(twist, GV.ramp("#e8d8b0", { shade = "#c9b878" }), { cres = 2, deep = 1, contour = "#7a5a3a", gloss = false })
c:fill(c:line({ {30, 12}, {31, 16}, {30, 21} }, 1), "#c9b878")
c:fill(c:line({ {34, 12}, {35, 17}, {35, 21} }, 1), "#c9b878")
c:paint({ "f.f.f.f.f", ".f.f.f.f." }, 28, 8, { f = "#e8d8b0" })
c:part(c:rect(26, 21, 38, 22), "red", { flat = true, contour = false })
c:paint({ "rr...rr", ".rrkrr.", "r.....r" }, 35, 19, { r = "#d6322b", k = "#ae2a2a" })
c:gloss(body, "glass", { 20, 37 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
