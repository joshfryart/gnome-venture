-- ph/candied-chestnuts, redraw A (2.2.1 leftovers, Opus medium): low bentwood box, three big glazed chestnuts
-- in gold foil cups sitting proud of the rim, lid leaning at the right.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "candied-chestnuts", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#e2b878")
local nut = GV.ramp("#8a3a1e", { gloss = "#f2a66a", dot = "#ffd9a0", rim = "#b85a2e" })
-- lid leaning behind at the right
local lid = c:ellipse(49, 36, 7, 13)
c:part(lid, wood, { gloss = false })
c:fill(c:ellipse(49, 36, 4, 8):cut(c:ellipse(49, 36, 3, 7)), "#c9a96e")
-- box
local box = c:rrect(9, 38, 45, 55, 5)
c:part(box, wood, { gloss = { 11, 44 } })
c:fill(c:ellipse(27, 38, 16, 4), "#5e2f1e")
c:seam({ {10, 47}, {42, 47} })
-- three chestnuts in gold foil cups (back one first); the cup hides the lower third of each nut
for _, n in ipairs({ { 27, 25 }, { 16, 33 }, { 38, 33 } }) do
  local x, y = n[1], n[2]
  local m = c:ellipse(x, y, 7, 6):add(c:poly({ {x - 3, y - 4}, {x + 3, y - 4}, {x, y - 9} }))
  c:part(m, nut, { gloss = { x - 3, y - 3 }, contact = false })
  local cup = c:poly({ {x - 8, y + 2}, {x + 9, y + 2}, {x + 6, y + 7}, {x - 5, y + 7} })
  c:part(cup, "gold", { flat = true, contact = false })
  for i = x - 6, x + 6, 2 do c:px(i, y + 3, "#fff1c8"); c:px(i + 1, y + 5, "#b8661a") end
end
c:ground(28, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
