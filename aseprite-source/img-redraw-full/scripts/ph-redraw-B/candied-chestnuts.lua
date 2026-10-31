-- ph/candied-chestnuts, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: box + lid + foil + nuts = four ideas in 16 px; the nuts (the product) were the smallest thing. Fix
-- (distill): one huge glazed marron glace in a crinkled gold foil cup, a second one peeking behind. The pointed tip,
-- pale base patch and mirror gloss say "candied chestnut"; gold says "treat".
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "candied-chestnuts", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local nut = GV.ramp("#8a3418", { gloss = "#ffb070", dot = "#ffe2b0", rim = "#c0602e" })
local function chestnut(x, y, r)
  local m = c:ellipse(x, y, r, r - 1):add(c:poly({ {x - r * 0.55, y - r * 0.6}, {x + r * 0.55, y - r * 0.6}, {x + 1, y - r - 2} }))
  c:part(m, nut, { gloss = { x - r * 0.5, y - r * 0.5 } })
  c:fill(c:rect(x, y - r - 1, x + 1, y - r), "#f2d8a8")   -- polish 1: pale tuft at the tip, a chestnut not an onion
  return m
end
local function cup(x, y, w, h)
  local m = c:poly({ {x - w, y}, {x + w + 1, y}, {x + w - 3, y + h}, {x - w + 3, y + h} })
  c:part(m, "gold", { gloss = false, cres = 3, contact = false })
  for i = x - w + 1, x + w, 3 do c:fill(c:line({ {i, y + 1}, {i + 1, y + h - 1} }, 1):clip(m), "#b8661a") end
  for i = x - w, x + w, 2 do c:px(i, y, "#fff1c8") end
end
chestnut(42, 27, 9)
cup(42, 31, 11, 8)
chestnut(25, 31, 14)
c:fill(c:ellipse(25, 40, 9, 2):clip(c:ellipse(25, 31, 14, 13)), "#d9a066")
cup(25, 40, 17, 12)
c:ground(30, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
