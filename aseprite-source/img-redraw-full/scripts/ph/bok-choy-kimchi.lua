-- ph/bok-choy-kimchi (Pantry kimchi): jar under a red/cream GINGHAM cloth cap tied with string, bok choy halves in red paste
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "bok-choy-kimchi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(16, 26, 48, 56, 8), "glass" },
  { "paste", c:rrect(18, 31, 46, 54, 6), "red", { gloss = false, contour = "#6b1b2c" } },
}
-- bok choy halves: pale stems with red streaks, green leaf fans on top
for _, x in ipairs({ 22, 33 }) do
  c:part(c:rrect(x, 37, x + 7, 44, 2), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false, cres = 2, deep = 0 })
  c:part(c:ellipse(x + 3.5, 34, 5, 3), "leaf", { gloss = false, contact = false, cres = 2, deep = 0 })
  c:fill(c:rect(x + 2, 38, x + 2, 43), "#dd3a2a"); c:fill(c:rect(x + 5, 39, x + 5, 44), "#dd3a2a")
end
c:part(c:rrect(22, 44, 42, 53, 2), "cream", { gloss = false, contact = false })
c:paint({   -- label emblem: three stems fanning, green tops
  "g.ggg.g",
  "gg.g.gg",
  ".c.c.c.",
  ".ccccc.",
  "..ccc..",
}, 26, 46, { g = "#4f9a45", c = "#c9b878" })
c:paint({ "uu.u", "", "u.uu" }, 35, 47, { u = "#7a5a3a" })
-- gingham cloth: dome over the mouth with a scalloped skirt
local cloth = c:rrect(14, 11, 50, 26, 7)
for i = 0, 5 do cloth:add(c:ellipse(16.5 + i * 6.2, 27, 3, 3)) end
local cp = c:part(cloth, GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false })
local lightC = { ["#f1ece0"] = true, ["#f5b860"] = true }
cp.m:each(function(x, y)
  local row, col = (y // 3) % 2 == 0, (x // 3) % 2 == 0
  if not (row or col) then return end
  local cur = c:get(x, y)
  local dark = not lightC[cur]
  local hex
  if row and col then hex = dark and "#ae2a2a" or "#dd3a2a" else hex = dark and "#d86a6a" or "#f09a8a" end
  c:px(x, y, hex)
end)
c:gloss(cloth, GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { 18, 14 })
-- string tie at the neck with a bow
c:part(c:rect(15, 25, 49, 26), "#c9a96e", { flat = true, contact = false })
c:paint({ "ss.ss", "sssss", ".sks.", "s...s" }, 38, 24, { s = "#c9a96e", k = "#7a4a1f" })
c:ground(32, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
