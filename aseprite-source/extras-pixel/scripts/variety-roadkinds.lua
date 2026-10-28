-- variety-roadkinds.lua : road-kind icons fork / riddle / trade / chain / sketch (96x96, icon mode).
-- Family: umber outline + black border, wood posts, leaf green, gold thread, red cover, cream paper.
-- Params: --script-param root=<repo> pngdir=<dir> out=<dir> only=<name>
local P = app.params
local root = P.root or "/home/user/gnome-venture"
local GV = dofile(root .. "/aseprite-source/gvlib/gvlib.lua")
local OUT = P.out or (root .. "/aseprite-source/extras-pixel/aseprite")
local PNG = P.pngdir or (root .. "/game/assets/img/roadkinds")
local ONLY = P.only or "all"

local PLANK = GV.ramp("#c9a96e")
local CREAM = GV.ramp("#f1ece0")
local DWOOD = GV.ramp("#7a4a1f")
local DK = "#3d2a1c"

local function canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end
local function save(c, name)
  local t = c:save(OUT .. "/variety-roadkind-" .. name .. ".aseprite", PNG .. "/" .. name .. ".png")
  print(name .. " " .. GV.report(t))
end
-- oriented rectangle / arrow polygons from a centre line a->b with half-width hw
local function band(a, b, hw, extra)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L * hw, dx / L * hw
  return { { a[1] + nx, a[2] + ny }, { b[1] + nx, b[2] + ny }, { b[1] - nx, b[2] - ny }, { a[1] - nx, a[2] - ny } }
end

----------------------------------------------------------------- fork: signpost, two arrows
local function fork(c)
  -- ground mound
  c:part(c:ellipse(47.5, 81, 17, 4), "moss", { cres = 3, deep = 1, gloss = false })
  -- post
  c:part(c:rrect(41, 9, 53, 81, 2), DWOOD, { gloss = false })
  c:part(c:rect(43, 12, 44, 77), "#9a6b3f", { flat = true, contour = false, contact = false })
  -- top board points right (red)
  local b1 = c:poly({ { 16, 18 }, { 66, 18 }, { 88, 31 }, { 66, 44 }, { 16, 44 } })
  c:part(b1, "red", { cres = 7, deep = 2 })
  c:seam({ { 22, 25 }, { 62, 25 } })
  c:seam({ { 22, 37 }, { 62, 37 } })
  c:button(24, 29)
  -- lower board points left (plank)
  local b2 = c:poly({ { 80, 51 }, { 30, 51 }, { 8, 64 }, { 30, 77 }, { 80, 77 } })
  c:part(b2, PLANK, { cres = 7, deep = 2 })
  c:seam({ { 34, 58 }, { 74, 58 } })
  c:seam({ { 34, 70 }, { 74, 70 } })
  c:button(68, 62)
  save(c, "fork")
end

----------------------------------------------------------------- riddle: a question mark in a leaf
local function riddle(c)
  -- stem
  c:part(c:line({ { 18, 78 }, { 10, 86 } }, 3), "leaf", { flat = true })
  -- leaf: vesica of two big circles, tips (16,80) and (80,16)
  local R = 60
  local A = c:ellipse(75.9, 75.9, R, R)
  local B = c:ellipse(20.1, 20.1, R, R)
  local leaf = A:copy():clip(B)
  c:part(leaf, "leaf", { cres = 9, deep = 3, stitch = { side = "lit" } })
  -- side veins (flat darker marks)
  local vein = "#2f6a3a"
  for _, p in ipairs({ { 28, 62, 22, 56 }, { 34, 70, 30, 64 }, { 62, 32, 68, 38 }, { 70, 26, 76, 32 } }) do
    c:part(c:line({ { p[1], p[2] }, { p[3], p[4] } }, 2), { base = vein, rim = vein, shade = vein, deep = vein, bounce = vein, gloss = vein, dot = vein }, { flat = true, contour = false, contact = false })
  end
  -- question mark, cream
  local q = c:line({ { 38, 36 }, { 41, 30 }, { 48, 28 }, { 55, 30 }, { 58, 36 }, { 56, 42 }, { 49, 48 }, { 48, 55 } }, 6)
  c:part(q, CREAM, { cres = 3, deep = 1, gloss = false })
  c:part(c:rrect(45, 62, 51, 68, 2), CREAM, { cres = 3, deep = 1, gloss = false })
  save(c, "riddle")
end

----------------------------------------------------------------- trade: two hands swapping a basket
local function trade(c)
  local SK = "skin"
  -- basket handle (behind)
  local arc = c:ellipse(47.5, 44, 20, 20):cut(c:rect(0, 44, 99, 99)):cut(c:ellipse(47.5, 46, 14, 14))
  c:part(arc, PLANK, { cres = 3, deep = 1, gloss = false })
  -- basket body
  local body = c:poly({ { 24, 44 }, { 71, 44 }, { 64, 76 }, { 31, 76 } })
  c:part(body, PLANK, { cres = 6, deep = 2 })
  for _, x in ipairs({ 36, 47, 58 }) do c:part(c:rect(x, 50, x + 1, 74), DWOOD, { flat = true, contour = false, contact = false }) end
  c:part(c:rect(28, 58, 67, 59), DWOOD, { flat = true, contour = false, contact = false })
  -- apples peeking out
  c:part(c:ellipse(37, 42, 6, 6), "red", { cres = 3, deep = 1 })
  c:part(c:ellipse(49, 40, 6, 6), "gold", { cres = 3, deep = 1 })
  c:part(c:ellipse(60, 42, 6, 6), "moss", { cres = 3, deep = 1 })
  c:part(c:rrect(22, 44, 73, 52, 2), PLANK, { cres = 3, deep = 1, gloss = false })
  -- left sleeve + hand (from lower left, red cuff)
  c:part(c:poly({ { 7, 54 }, { 20, 58 }, { 20, 80 }, { 7, 76 } }), "red", { cres = 4, deep = 1, gloss = false })
  c:part(c:rrect(17, 56, 37, 78, 6), SK, { cres = 5, deep = 2 })
  c:part(c:rrect(30, 54, 40, 68, 4), SK, { cres = 3, deep = 1, gloss = false })
  c:seam({ { 11, 58 }, { 11, 74 } }, { free = true })
  for _, y in ipairs({ 64, 69, 74 }) do c:px(30, y, "#c47a52"); c:px(31, y, "#c47a52"); c:px(32, y, "#c47a52") end
  for _, y in ipairs({ 64, 69, 74 }) do c:px(63, y, "#c47a52"); c:px(64, y, "#c47a52"); c:px(65, y, "#c47a52") end
  -- right sleeve + hand (from lower right, moss cuff)
  c:part(c:poly({ { 88, 54 }, { 75, 58 }, { 75, 80 }, { 88, 76 } }), "leaf", { cres = 4, deep = 1, gloss = false })
  c:part(c:rrect(58, 56, 78, 78, 6), SK, { cres = 5, deep = 2 })
  c:part(c:rrect(55, 54, 65, 68, 4), SK, { cres = 3, deep = 1, gloss = false })
  save(c, "trade")
end

----------------------------------------------------------------- chain: linked acorns
local function acorn(c, cx, cy)
  -- nut
  local nut = c:ellipse(cx, cy + 4, 8, 10):cut(c:rect(0, 0, 99, cy - 1))
  nut:add(c:rect(cx - 8, cy - 4, cx + 8, cy + 3))
  c:part(nut, "wood", { cres = 6, deep = 2 })
  -- cap
  local cap = c:ellipse(cx, cy - 2, 10, 8):cut(c:rect(0, cy + 2, 99, 99))
  c:part(cap, DWOOD, { cres = 5, deep = 2, stitch = { side = "lit" } })
  -- stem
  c:part(c:rect(cx - 1, cy - 12, cx + 1, cy - 8), DWOOD, { flat = true })
  -- cap cross-hatch
  for _, dx in ipairs({ -5, -1, 3 }) do c:px(cx + dx, cy - 3, "#4e2a16"); c:px(cx + dx + 1, cy - 1, "#4e2a16") end
end
local function link(c, cx, cy, rx, ry)
  local ring = c:ellipse(cx, cy, rx, ry):cut(c:ellipse(cx, cy, rx - 3, ry - 3))
  c:part(ring, "gold", { cres = 2, deep = 1, gloss = false })
end
local function chain(c)
  link(c, 33, 59, 10, 7); link(c, 63, 37, 10, 7)
  acorn(c, 18, 70); acorn(c, 48, 48); acorn(c, 78, 26)
  save(c, "chain")
end

----------------------------------------------------------------- sketch: notebook and pencil
local function sketch(c)
  -- page block (cream edge, peeks out right and below)
  c:part(c:rrect(20, 14, 72, 84, 3), CREAM, { cres = 4, deep = 1, gloss = false })
  for _, y in ipairs({ 80, 77 }) do c:part(c:rect(24, y, 70, y), { base = "#d8c49a", rim = "#d8c49a", shade = "#d8c49a", deep = "#d8c49a", bounce = "#d8c49a", gloss = "#d8c49a", dot = "#d8c49a" }, { flat = true, contour = false, contact = false }) end
  -- red cover
  c:part(c:rrect(14, 10, 66, 78, 4), "red", { cres = 8, deep = 2, stitch = { side = "lit" } })
  -- binding strip on the left with thread holes
  c:part(c:rect(14, 10, 24, 78), GV.ramp("#ae2a2a"), { cres = 3, deep = 1, gloss = false })
  for y = 16, 72, 10 do c:button(16, y) end
  -- label with scribble lines
  c:part(c:rrect(32, 20, 58, 44, 2), CREAM, { cres = 3, deep = 1, gloss = false })
  for _, y in ipairs({ 26, 31, 36 }) do c:part(c:rect(36, y, 54, y + 1), DWOOD, { flat = true, contour = false, contact = false }) end
  -- pencil, diagonal (top right to lower left tip)
  local tipP, backP = { 44, 88 }, { 84, 44 }
  local function lerp(t) return { tipP[1] + (backP[1] - tipP[1]) * t, tipP[2] + (backP[2] - tipP[2]) * t } end
  c:part(c:poly(band(lerp(0.30), lerp(0.80), 7)), "gold", { cres = 5, deep = 2 })
  c:part(c:poly(band(lerp(0.80), lerp(0.88), 7)), GV.ramp("#8b8f96"), { cres = 2, deep = 1, gloss = false })
  c:part(c:poly(band(lerp(0.88), lerp(1.0), 7)), "petal", { cres = 3, deep = 1 })
  -- sharpened wood + graphite tip
  local a, b = lerp(0.30), lerp(0)
  local nx, ny = band(lerp(0.30), lerp(0.80), 7)[1][1] - a[1], band(lerp(0.30), lerp(0.80), 7)[1][2] - a[2]
  c:part(c:poly({ { a[1] + nx, a[2] + ny }, { a[1] - nx, a[2] - ny }, { b[1], b[2] } }), "skin", { cres = 3, deep = 1, gloss = false })
  c:part(c:poly({ { lerp(0.10)[1] + nx * 0.4, lerp(0.10)[2] + ny * 0.4 }, { lerp(0.10)[1] - nx * 0.4, lerp(0.10)[2] - ny * 0.4 }, { b[1], b[2] } }), GV.ramp("#4a2c1a"), { flat = true })
  save(c, "sketch")
end

local fns = { fork = fork, riddle = riddle, trade = trade, chain = chain, sketch = sketch }
for _, n in ipairs({ "fork", "riddle", "trade", "chain", "sketch" }) do
  if ONLY == "all" or ONLY == n then fns[n](canvas()) end
end
