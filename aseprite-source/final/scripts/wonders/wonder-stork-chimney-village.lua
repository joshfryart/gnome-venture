-- wonder-stork-chimney-village.lua : a village at evening, storks nest on every chimney, each beak holds a gift; one drops a parcel.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-stork-chimney-village"
local STW = GV.ramp("#f6f2e8", { dot = "#fffaf0", gloss = "#fffaf0", rim = "#fffaf0", shade = "#c5c9d8", deep = "#9a9fb8", bounce = "#d8d4e0" })

c:bands(c:rect(0, 0, W - 1, 84), { "#5a6aa8", "#7a7ab8", "#a48ac0", "#d49ab8", "#f0aa98", "#f8c890", "#fbe0a8" }, { dir = "v" })
L.cloud(c, 40, 24, 18, "#d49ab8", "#a48ac0"); L.cloud(c, 130, 36, 20, "#f0aa98", "#d49ab8"); L.cloud(c, 210, 52, 14, "#f8c890", "#f0aa98")
c:fill(c:ellipse(92, 76, 10, 10), "#fff1c8")
-- distant rolling fields and a far steeple
c:fill(L.below(c, function(x) return 76 - 4 * math.sin(x / 24) end), "#8a8ab0")
c:fill(L.below(c, function(x) return 82 - 3 * math.sin(x / 15 + 2) end), "#6a9a60")
c:part(c:rect(150, 62, 154, 80), GV.ramp("#e8d9b0"), { flat = true, gloss = false, outline = false })
c:part(c:poly({ {148, 62}, {152, 52}, {156, 62} }), GV.ramp("#a8241f"), { flat = true, gloss = false, outline = false })

-- generic stork: feet at (x,y) on the nest; item = "letter"|"seed"|"ribbon"|"shoe"|nil ; d = facing (1 right, -1 left)
local function stork(x, y, s, item, d)
  local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, math.max(1, rx * s), math.max(1, ry * s)) end
  -- legs
  c:fill(c:rect(x - 2, y - math.floor(3 * s), x - 2, y), "#d6322b"); c:fill(c:rect(x + 2, y - math.floor(3 * s), x + 2, y), "#d6322b")
  -- tail
  c:part(c:poly({ {x - d * 5 * s, y - 6 * s}, {x - d * 10 * s, y - 9 * s}, {x - d * 9 * s, y - 4 * s} }), GV.ramp("#2a2230"), { flat = true, gloss = false, outline = false })
  -- body
  c:part(E(x, y - 7 * s, 6, 5), STW, { cres = 1 * s, deep = 1.5 * s, gloss = false, outline = (s >= 1.4) })
  -- wing (black tips)
  c:part(E(x - d * 3 * s, y - 5 * s, 3, 2), GV.ramp("#2a2230", { rim = "#5a5a6a" }), { flat = true, gloss = false, outline = false })
  -- neck + head
  c:part(c:rect(x + d * 3 * s - math.floor(s), y - 16 * s, x + d * 3 * s + math.floor(s), y - 8 * s), STW, { flat = true, gloss = false, outline = false })
  c:part(E(x + d * 4 * s, y - 16 * s, 3.4, 3), STW, { cres = 1, deep = 2, gloss = false, outline = (s >= 1.4) })
  -- beak
  local bx = x + d * 7 * s
  c:part(c:rect(math.min(bx, bx + d * 8 * s), math.floor(y - 16 * s), math.max(bx, bx + d * 8 * s), math.floor(y - 15 * s) + (s >= 1.4 and 1 or 0)), GV.ramp("#e0501f"), { flat = true, gloss = false, outline = false })
  -- eye
  if s >= 1.4 then c:eye(x + d * 4 * s - 2 - (d < 0 and 1 or 0), y - 19 * s, true) else c:px(x + d * 4 * s, math.floor(y - 17 * s), "#2a1a10") end
  -- the gift in the beak
  local ix, iy = bx + d * 8 * s, math.floor(y - 15 * s)
  if item == "letter" then
    c:part(c:rect(ix - 1, iy, ix + 5, iy + 4), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false, contour = "#4a2c1a" }); c:px(ix + 2, iy + 2, "#d6322b")
  elseif item == "seed" then
    c:px(ix, iy, "#7a4a1f"); c:px(ix + 1, iy, "#7a4a1f"); c:px(ix, iy + 1, "#7a4a1f"); c:px(ix + 1, iy + 1, "#9a6b3f"); c:px(ix, iy - 1, "#4f9a45"); c:px(ix + 1, iy - 2, "#7ab55c"); c:px(ix - 1, iy - 2, "#7ab55c")
  elseif item == "ribbon" then
    for k = 0, 6 do c:px(ix + d * k, iy + 1 + (k % 4 < 2 and 0 or 1), "#e46a9b"); c:px(ix + d * k, iy + 2 + (k % 4 < 2 and 0 or 1), "#f6b8cf") end
  elseif item == "shoe" then
    c:part(c:rect(ix, iy, ix + 3, iy + 4), GV.ramp("#7a4a1f"), { flat = true, gloss = false, outline = false }); c:part(c:rect(ix - 1, iy + 3, ix + 5, iy + 5), GV.ramp("#9a6b3f"), { flat = true, gloss = false, outline = false })
  end
end
local function nest(x, y, w) c:part(c:ellipse(x, y, w, 3), GV.ramp("#b8924a"), { cres = 1, deep = 2, gloss = false, outline = false, contour = "#4a2c1a" }); for k = -w + 2, w - 2, 3 do c:px(x + k, y - 1, "#7a4a1f") end end
local function chimney(x, y, w, h, col)
  c:part(c:rect(x, y, x + w - 1, y + h), GV.ramp(col), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x - 1, y, x + w, y + 1), "#e8d9b0")
end
-- roof helper (gable, front view): wall rect + triangle roof
local function house(x, base, w, h, wall, roof, shutter, rh)
  c:part(c:rect(x, base - h, x + w, base), GV.ramp(wall, { shade = "#c8b490", deep = "#9a8460" }), { cres = 4, deep = 7, gloss = false })
  c:part(c:poly({ {x - 4, base - h + 1}, {x + w / 2, base - h - rh}, {x + w + 4, base - h + 1} }), GV.ramp(roof), { cres = 5, deep = 8, gloss = false })
  -- tile rows
  for k = 1, 3 do local yy = base - h - rh + k * (rh // 3 + 1); c:fill(c:rect(x + w / 2 - k * (w // 5 + 1), yy, x + w / 2 + k * (w // 5 + 1), yy), "#8a2a20") end
  -- window with shutters + door
  local wx = x + 5
  c:part(c:rect(wx, base - h + 6, wx + 7, base - h + 14), GV.ramp("#f5cf6a"), { flat = true, gloss = false, contour = "#2a1a10", outline = false })
  c:fill(c:rect(wx - 3, base - h + 6, wx - 2, base - h + 14), shutter); c:fill(c:rect(wx + 8, base - h + 6, wx + 9, base - h + 14), shutter)
  c:fill(c:rect(wx + 3, base - h + 6, wx + 4, base - h + 14), "#c8721a")
  c:part(c:rect(x + w - 10, base - 12, x + w - 4, base), GV.ramp("#7a4a1f"), { flat = true, gloss = false, outline = false, contour = "#2a1a10" })
  -- painted flower trim
  for k = x + 3, x + w - 3, 5 do c:px(k, base - h + 3, "#e46a9b"); c:px(k + 1, base - h + 3, "#4f9a45") end
end

-- back row, far to near
house(4, 92, 34, 22, "#f2e4c0", "#c8421f", "#4a6ea8", 14); chimney(28, 56, 6, 12, "#e8d9b0"); nest(31, 55, 8); stork(31, 54, 0.9, "seed", 1)
house(62, 94, 38, 26, "#f6d8a8", "#a8241f", "#3f8fb0", 16); chimney(70, 50, 7, 14, "#c9a96e"); nest(73, 49, 9); stork(73, 48, 1.0, "letter", -1)
house(118, 92, 32, 22, "#e8d9b0", "#c8421f", "#7a5cc0", 13); chimney(138, 56, 6, 12, "#e8d9b0"); nest(141, 55, 8); stork(141, 54, 0.9, "ribbon", -1)
-- a stork in the sky gliding in with the shoe
local function flyer(x, y, d, item)
  c:part(c:ellipse(x, y, 5, 3), STW, { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {x - 6, y - 2}, {x - 2, y - 9}, {x + 2, y - 2} }), GV.ramp("#2a2230"), { flat = true, gloss = false, outline = false })
  c:part(c:poly({ {x + 3, y + 1}, {x + 9, y + 6}, {x + 5, y + 7} }), GV.ramp("#2a2230"), { flat = true, gloss = false, outline = false })
  c:fill(c:rect(x + d * 5, y - 2, x + d * 13, y - 1), "#e0501f"); c:px(x + d * 4, y - 2, "#2a1a10")
  c:fill(c:rect(x - d * 7, y, x - d * 11, y), "#d6322b")
  if item == "shoe" then c:part(c:rect(x + d * 13, y, x + d * 16, y + 5), GV.ramp("#7a4a1f"), { flat = true, gloss = false, outline = false }); c:part(c:rect(x + d * 13, y + 4, x + d * 18, y + 6), GV.ramp("#9a6b3f"), { flat = true, gloss = false, outline = false }) end
end
flyer(104, 18, 1, "shoe")
flyer(196, 20, -1, nil)

-- street
local street = L.below(c, function(x) return 100 end)
c:part(street, GV.ramp("#c9b890"), { cres = 6, deep = 9, outline = false, gloss = false })
for _, p in ipairs({ {10,108},{24,114},{40,106},{58,118},{76,112},{92,126},{20,126},{110,108},{130,120},{148,112},{44,128},{72,126},{118,128},{160,126} }) do
  c:part(c:ellipse(p[1], p[2], 5, 2), GV.ramp("#b8a478"), { flat = true, gloss = false, outline = false, contour = false })
end
-- foreground cottage at right with the big stork
local FX = 168
house(FX, 124, 66, 46, "#f2e4c0", "#c8421f", "#4a6ea8", 20)
chimney(FX + 44, 44, 11, 32, "#e8d9b0")
nest(FX + 49, 43, 13)
stork(FX + 49, 42, 1.8, nil, -1)
-- fence + sunflowers by the cottage
for x = 150, 164, 5 do c:fill(c:rect(x, 112, x + 1, 124), "#c9a96e") end
c:fill(c:rect(148, 116, 166, 117), "#9a6b3f")
c:part(c:ellipse(160, 108, 4, 4), GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false }); c:fill(c:ellipse(160, 108, 1.5, 1.5), "#4a2c1a"); c:fill(c:rect(160, 112, 160, 120), "#4f9a45")

-- the parcel dropped at our feet: brown paper, string, red bow, with a little feather drifting down
local PX, PY = 100, 120
c:part(c:rect(PX - 11, PY - 8, PX + 11, PY + 8), GV.ramp("#c9966a"), { cres = 4, deep = 7, gloss = false })
c:fill(c:rect(PX - 1, PY - 8, PX + 1, PY + 8), "#f2e4c0"); c:fill(c:rect(PX - 11, PY - 1, PX + 11, PY + 1), "#f2e4c0")
c:part(c:ellipse(PX - 4, PY - 11, 4, 3), GV.ramp("#d6322b"), { cres = 1, deep = 2, gloss = false, outline = false, contour = "#2a1a10" })
c:part(c:ellipse(PX + 4, PY - 11, 4, 3), GV.ramp("#d6322b"), { cres = 1, deep = 2, gloss = false, outline = false, contour = "#2a1a10" })
c:fill(c:rect(PX - 1, PY - 12, PX + 1, PY - 10), "#a8241f")
c:px(PX - 7, PY - 4, "#fffaf0"); c:px(PX - 8, PY - 4, "#fffaf0")
for _, p in ipairs({ {PX + 3, PY - 30}, {PX - 2, PY - 24}, {PX + 4, PY - 19} }) do c:px(p[1], p[2], "#fffaf0"); c:px(p[1] + 1, p[2] + 1, "#c5c9d8") end
c:ground(PX, PY + 9, 14, 2)
-- little shoe lost by the cottage door? a wooden cart wheel and hay for charm
c:part(c:ellipse(30, 122, 10, 3), GV.ramp("#e8c46a"), { cres = 1, deep = 2, gloss = false, outline = false }); c:part(c:ellipse(30, 118, 8, 5), GV.ramp("#e8c46a"), { cres = 2, deep = 3, gloss = false })
for _, p in ipairs({ {26,116},{32,118},{36,120},{22,120} }) do c:px(p[1], p[2], "#b07a10") end

L.finish(c, SLUG)
