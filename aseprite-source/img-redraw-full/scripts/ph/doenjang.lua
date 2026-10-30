-- ph/doenjang (Pantry paste): wide low brown bowl-crock, flat round stone slab lid, straw rope hung with red chilies and charcoal
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "doenjang"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#8a5a2a", { rim = "#9a6b3f", gloss = "#c98a4a", dot = "#e8a060", shade = "#5a3a1a", deep = "#3d2a1c", bounce = "#6a4020" })
local slab = GV.ramp("#8b8f96", { shade = "#5b6470", deep = "#3e4450" })
local straw = GV.ramp("#e8d890", { shade = "#c9b878", deep = "#9a8a50", bounce = "#d8c080", rim = "#f6eab0", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
c:part(c:rrect(9, 31, 55, 55, 11), glaze, { gloss = { 14, 38 } })
c:part(c:rrect(12, 27, 52, 33, 2), "#7a4a1f", { gloss = false, cres = 2, deep = 0 })   -- rim lip
c:part(c:rrect(16, 20, 48, 28, 3), slab, { gloss = { 19, 22 } })
-- geumjul: twisted straw rope tied round the neck, sagging across the front
local rope = c:mask()
for x = 10, 54 do
  local y = math.floor(30 + 3 * math.sin(math.pi * (x - 10) / 44))
  rope:add(c:rect(x, y, x, y + 2))
end
local rp = c:part(rope, straw, { gloss = false, contact = false, cres = 2, deep = 0 })
rp.m:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, "#c9b878") end end)   -- twist ticks
c:paint({ "kk.kk", ".kkk.", "k...k" }, 10, 29, { k = "#c9b878" })              -- knot at the left
-- red chilies and charcoal lumps tucked into the rope, hanging over the belly
for _, q in ipairs({ {16, 33, 9}, {22, 34, 8}, {44, 34, 9} }) do
  local x, y, l = q[1], q[2], q[3]
  c:part(c:poly({ {x - 1, y}, {x + 4, y}, {x + 4, y + l - 3}, {x + 3, y + l}, {x + 1, y + l}, {x - 1, y + l - 3} }), "red", { gloss = false, contact = false, cres = 2, deep = 0 })
  c:fill(c:rect(x - 1, y - 2, x + 2, y - 1), "#4f9a45")
  c:px(x, y + 2, "#ff9158"); c:px(x, y + 3, "#ff9158")
end
for _, q in ipairs({ {37, 35} }) do
  c:part(c:poly({ {q[1], q[2]}, {q[1] + 5, q[2] - 1}, {q[1] + 6, q[2] + 3}, {q[1] + 4, q[2] + 6}, {q[1] + 1, q[2] + 5} }), "#3a3030", { gloss = false, contact = false, cres = 2, deep = 0 })
  c:px(q[1] + 1, q[2] + 1, "#6a6060")
end
-- emblem: a meju block (pressed soybean brick) with bean dots
c:part(c:rrect(26, 42, 38, 52, 3), GV.ramp("#c9a96e", { dot = "#efdcae" }), { gloss = false, contact = false })
for _, p in ipairs({ {29, 44}, {34, 45}, {30, 48}, {34, 49} }) do c:paint({ "BB", "Bb" }, p[1], p[2], { B = "#e8d890", b = "#7a4a1f" }) end
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
