-- ph/dried-dates (Pantry dried): round woven palm-leaf basket with a tall arched handle, heaped with glossy dates, palm tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "dried-dates"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- handle arc behind everything, lashed at the rim
local arc = c:ellipse(32, 38, 20, 31):cut(c:ellipse(32, 38, 17, 28)):cut(c:rect(0, 36, 63, 90))
c:part(arc, "#9a6b3f", { gloss = false, cres = 2, deep = 0 })
for _, a in ipairs({ 0.35, 0.65, 0.95, 1.25, 1.57, 1.89, 2.19, 2.49, 2.79 }) do
  c:px(math.floor(32 + 18.5 * math.cos(a) + 0.5), math.floor(38 - 29.5 * math.sin(a) + 0.5), "#7a4a1f")
end
-- dates heap: glossy dark ovals with a lit top and a crease
local function date(x, y)
  c:part(c:ellipse(x, y, 4.5, 2.5), "#5a3a1f", { gloss = false, cres = 2, deep = 0 })
  c:fill(c:rect(x - 2, y - 2, x + 1, y - 2), "#7a4a1f"); c:px(x - 2, y - 1, "#a8742f")
  c:fill(c:rect(x - 1, y + 1, x + 2, y + 1), "#2a1a10")
end
for _, p in ipairs({ {32, 21}, {24, 25}, {40, 25}, {18, 30}, {46, 30}, {29, 28}, {36, 29}, {23, 33}, {32, 33}, {41, 33} }) do date(p[1], p[2]) end
-- basket bowl with a rim band and diagonal weave
local bowl = c:rrect(10, 34, 54, 41, 2):add(c:ellipse(32, 41, 22, 14):cut(c:rect(0, 0, 63, 40)))
bowl:cut(c:rect(0, 55, 63, 63))
c:part(bowl, "#c9a96e", { gloss = { 15, 42 } })
for y = 40, 54 do for x = 10, 54 do
  if bowl:has(x, y) and (x + y) % 4 == 0 and c:get(x, y) == "#c9a96e" then c:px(x, y, "#9a6b3f") end
  if bowl:has(x, y) and (x - y) % 8 == 0 and c:get(x, y) == "#c9a96e" then c:px(x, y, "#9a6b3f") end
end end
c:part(c:rrect(9, 34, 55, 39, 2), "#9a6b3f", { gloss = false, cres = 2 })
c:seam({ {11, 36}, {53, 36} })
-- lashing where the handle meets the rim
c:paint({ "kk", "kk", "kk" }, 13, 33, { k = "#5e2f1e" }); c:paint({ "kk", "kk", "kk" }, 50, 33, { k = "#5e2f1e" })
-- tag on a string with a date palm
c:fill(c:rect(32, 40, 32, 42), "#5e2f1e")
c:part(c:rrect(26, 43, 38, 52, 1), "cream", { gloss = false, contact = false })
c:paint({
  ".ll.ll.",
  "lllklll",
  "l.lkl.l",
  "...k...",
  "...k...",
  "..kkk..",
}, 29, 45, { l = "#4f9a45", k = "#7a4a1f" })
c:ground(32, 56, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
