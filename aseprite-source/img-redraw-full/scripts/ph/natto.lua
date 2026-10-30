-- ph/natto (Pantry ferment): horizontal rice-straw bundle pinched and tied at both ends, beans at the open end, sticky threads
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "natto"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local straw = GV.ramp("#e8d890", { shade = "#c9b878", deep = "#9a8a50", bounce = "#d8c080", rim = "#f6eab0", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
local bean = GV.ramp("#c9a96e", { shade = "#7a4a1f", deep = "#5e2f1e", bounce = "#9a6b3f", gloss = "#efdcae", dot = "#fbf0c0", rim = "#d9b878" })
-- straw capsule: fat middle, pinched necks, flared tufts at both ends
local wrap = c:ellipse(32, 40, 15, 12)
wrap:add(c:rect(14, 37, 50, 43))
wrap:add(c:poly({ {7, 31}, {15, 37}, {15, 44}, {7, 50}, {10, 40} }))      -- left tuft
wrap:add(c:poly({ {57, 31}, {49, 37}, {49, 44}, {57, 50} }))             -- right open end
c:part(wrap, straw, { gloss = { 22, 33 } })
wrap:each(function(x, y) if (x - y) % 4 == 0 and c:get(x, y) == "#e8d890" then c:px(x, y, "#c9b878") end end)
c:fill(c:rect(7, 34, 7, 34), "#9a8a50"); c:fill(c:rect(8, 47, 8, 47), "#9a8a50")
-- ties at the necks
c:part(c:rect(15, 35, 17, 45), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:rect(47, 35, 49, 45), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
-- beans heaped in the open right end
for _, p in ipairs({ {53, 35}, {52, 40}, {54, 44}, {50, 38}, {51, 43} }) do
  c:part(c:ellipse(p[1], p[2], 2), bean, { gloss = false, contact = false, cres = 2, deep = 0 })
  c:px(p[1] - 1, p[2] - 1, "#efdcae")
end
-- sticky strings: two thin threads stretched in loops from the beans
c:fill(c:line({ {51, 34}, {50, 29}, {47, 25}, {43, 24}, {41, 27} }, 1), "#f4f0e0")
c:fill(c:line({ {54, 33}, {56, 28}, {55, 24}, {53, 22} }, 1), "#f4f0e0")
-- tag with three beans
c:part(c:rect(24, 34, 39, 43), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({ "kK.kK.kK", "kk.kk.kk" }, 28, 38, { k = "#7a4a1f", K = "#c9a96e" })
c:ground(32, 54, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
