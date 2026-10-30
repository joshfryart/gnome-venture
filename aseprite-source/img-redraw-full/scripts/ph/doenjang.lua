-- ph/doenjang (Pantry ferment): wide low brown glazed crock, flat grey slab lid, geumjul straw rope with chilies and charcoal.
-- Redraw B: the rope is thicker (4 px) and brighter with dark twist bands and an umber contour, so it stands off the
-- brown glaze; the chilies and charcoal hang together in one cluster on the left and the meju emblem moves right,
-- so nothing lines up as two eyes over a mouth.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "doenjang"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#8a5a2a", { rim = "#9a6b3f", gloss = "#c98a4a", dot = "#e8a060", shade = "#5a3a1a", deep = "#3d2a1c", bounce = "#6a4020" })
local slab = GV.ramp("#8b8f96", { shade = "#5b6470", deep = "#3e4450" })
local straw = GV.ramp("#f5d878", { shade = "#d8b050", deep = "#a8802a", bounce = "#e0c060", rim = "#fbe8a8", gloss = "#fff3c8", dot = "#fbf6e8", pale = false })
c:part(c:rrect(9, 31, 55, 55, 11), glaze, { gloss = { 14, 38 } })
c:part(c:rrect(12, 27, 52, 33, 2), "#7a4a1f", { gloss = false, cres = 2, deep = 0 })   -- rim lip
c:part(c:rrect(16, 20, 48, 28, 3), slab, { gloss = { 19, 22 } })
-- geumjul: thick twisted straw rope round the neck, sagging a little across the front
local rope = c:mask()
local function ry(x) return math.floor(30 + 3 * math.sin(math.pi * (x - 10) / 44)) end
for x = 10, 54 do rope:add(c:rect(x, ry(x), x, ry(x) + 3)) end
c:part(rope, straw, { gloss = false, contact = false, cres = 2, deep = 0, contour = "#2a1a10" })
rope:each(function(x, y) if (x + (y - ry(x))) % 4 == 0 then c:px(x, y, "#a8702a") end end)   -- twist bands
-- one cluster tucked into the rope on the left: chili, charcoal, chili
local function chili(x, y, l)
  c:part(c:poly({ {x - 1, y}, {x + 4, y}, {x + 4, y + l - 3}, {x + 3, y + l}, {x + 1, y + l}, {x - 1, y + l - 3} }), "red", { gloss = false, contact = false, cres = 2, deep = 0, contour = "#2a1a10" })
  c:fill(c:rect(x - 1, y - 2, x + 3, y - 1), "#4f9a45")
  c:px(x, y + 2, "#ff9158"); c:px(x, y + 3, "#ff9158")
end
chili(13, 35, 10)
c:part(c:poly({ {18, 34}, {23, 33}, {25, 37}, {23, 41}, {19, 40} }), "#3a3030", { gloss = false, contact = false, cres = 2, deep = 0 })
c:px(19, 35, "#6a6060"); c:px(20, 35, "#6a6060")
chili(25, 35, 9)
-- emblem on the right of the belly: a meju block (pressed soybean brick) with bean dots
c:part(c:rrect(35, 40, 47, 50, 3), GV.ramp("#c9a96e", { dot = "#efdcae" }), { gloss = false, contact = false })
for _, p in ipairs({ {37, 42}, {42, 43}, {38, 46}, {43, 47} }) do c:paint({ "BB", "Bb" }, p[1], p[2], { B = "#e8d890", b = "#7a4a1f" }) end
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
