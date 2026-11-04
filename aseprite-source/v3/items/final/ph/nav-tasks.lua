-- nav-tasks (final, Opus single pass). A slim upright clipboard: bevelled wood board with vertical grain and a paler
-- end-grain edge, a cream sheet (soft curl light, AO where it meets the board, contact shadow under the clip), a brass
-- clip with a bevel, a bright specular streak, a dark hanging hole and two rivets. Three rows: two ticked boxes with
-- written lines, the third box still empty.
-- quirk: an inchworm is arching across the last, unticked row, as if measuring how much is left to do.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, max, min = math.floor, math.sin, math.max, math.min
local c = A.new("nav-tasks")
local WOOD  = { "#4a2924", "#6e3d2b", "#91573a", "#b47547", "#d29a5e", "#ecc58a" }
local PAPER = { "#a8968c", "#c8b7a5", "#e2d3bb", "#f0e5cb", "#faf2dc", "#fffae9" }
local GOLD  = { "#5a3620", "#8c5724", "#c2822c", "#e6a93c", "#f8d066", "#fff1b6" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- board
local bm = c:rrect(16, 12, 47, 56, 3)
local bn = X.pillow(bm, 2.4)
local paper = c:rect(20, 20, 43, 51)
local bias = {}
bm:each(function(x, y) local k = K(x, y)
  local g = (x + 1.3 * sin(y * 0.21 + x * 0.9)) % 5
  if g < 0.9 then bias[k] = -1 end
  if (x == 17 or x == 18) and y > 15 and y < 53 and X.hash(x, y, 3) < 0.25 then bias[k] = (bias[k] or 0) - 1 end
end)
-- knot on the bottom rail
for _, p in ipairs{ { 37, 54 }, { 38, 54 }, { 36, 53 }, { 39, 53 } } do bias[K(p[1], p[2])] = -2 end
bias[K(37, 53)] = -3 bias[K(38, 53)] = -2
-- AO + contact shadow around the sheet
A.HP = HP
X.ao(bias, bm, paper, 1, -1)
local sh = paper:shift(1, 1) sh:each(function(x, y) if bm:has(x, y) and not paper:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
A.shade(c, bm, bn, WOOD, { bias = bias, amb = 0.1, wrap = 0.3 })
-- pale end grain on the top edge highlight
for x = 19, 44 do if X.hash(x, 12, 5) < 0.5 then c:put(x, 12, WOOD[6]) end end

-- paper: nearly flat, slight curl, lit top-left
paper:each(function(x, y)
  local t = PAPER[5]
  if x == 20 or y == 20 then t = PAPER[6] end
  if x == 43 or y == 51 then t = PAPER[3] end
  if x == 42 and y > 21 then t = PAPER[4] end
  if (x == 43 and y == 51) then t = PAPER[2] end
  c:put(x, y, t)
end)
-- faint ruled lines
for _, y in ipairs{ 28, 36, 44, 49 } do for x = 21, 42 do c:put(x, y, "#e3e1d8") end end
for _, y in ipairs{ 28, 36, 44, 49 } do c:put(20, y, "#d9a3a8") end

-- clip: hanger plate + lever bar (brass)
local plate = c:rrect(26, 8, 37, 16, 2)
local ring = c:ellipse(31.5, 7.5, 3, 2.5)
plate:add(ring)
local bar = c:rrect(22, 15, 41, 19, 2)
-- contact shadow from clip onto the paper/board
for x = 22, 42 do
  for _, y in ipairs{ 20, 21 } do
    if paper:has(x, y) then c:put(x, y, y == 20 and PAPER[2] or PAPER[3]) end
  end
end
local pn = X.pillow(plate, 1.6)
local pb = {}
X.ao(pb, plate, bar, 1, -1)
A.shade(c, plate, pn, GOLD, { bias = pb, wrap = 0.3 })
-- hanging hole
c:put(31, 7, GOLD[1]) c:put(32, 7, GOLD[1]) c:put(31, 8, GOLD[2]) c:put(32, 8, GOLD[3])
c:put(30, 6, GOLD[6])
local barn = X.pillow(bar, 2)
local bidx = A.shade(c, bar, barn, GOLD, { wrap = 0.3 })
-- bevel lines + specular streak
for x = 24, 39 do c:put(x, 16, x < 33 and GOLD[6] or GOLD[5]) end
c:put(25, 16, "#fffbe6") c:put(26, 16, "#fffbe6")
for x = 23, 40 do c:put(x, 18, GOLD[3]) end
-- rivets
for _, rx in ipairs{ 24, 39 } do c:put(rx, 17, GOLD[1]) c:put(rx - 1, 17, GOLD[5]) end

-- three rows
local function box(y0)
  for x = 22, 27 do c:put(x, y0, "#5a7fb0") c:put(x, y0 + 5, "#8bb0d4") end
  for y = y0, y0 + 5 do c:put(22, y, "#5a7fb0") c:put(27, y, "#8bb0d4") end
  for y = y0 + 1, y0 + 4 do for x = 23, 26 do c:put(x, y, "#f4f8f2") end end
  c:put(23, y0 + 1, "#c9d8e6") c:put(24, y0 + 1, "#c9d8e6") c:put(23, y0 + 2, "#c9d8e6")
end
local function tick(y0)
  local pts = { { 23, y0 + 2 }, { 24, y0 + 3 }, { 25, y0 + 4 }, { 26, y0 + 3 }, { 27, y0 + 2 }, { 28, y0 + 1 }, { 29, y0 } }
  for i, p in ipairs(pts) do
    c:put(p[1], p[2] + 1, LEAF[1])
    c:put(p[1], p[2], i <= 3 and LEAF[2] or LEAF[3])
  end
  c:put(28, y0, LEAF[4]) c:put(29, y0 - 1, LEAF[3]) c:put(30, y0 - 1, LEAF[2])
end
local function words(y0, a, b)
  for x = 30, a do c:put(x, y0 + 2, (x == 34 or x == 39) and "#c4ab98" or "#7a5a52") end
  for x = 30, b do c:put(x, y0 + 4, x == 33 and "#e2d3bb" or "#a88c7c") end
end
box(22) words(22, 41, 36) tick(22)
box(30) words(30, 40, 38) tick(30)
box(38) words(38, 41, 34)

-- quirk: inchworm arching across the last row (head right, measuring)
local IW = { k = A.INK, h = "#c8ec7a", g = "#8ccf4a", s = "#4f9a3a", d = "#2f6a3a", e = "#2b1c26", c = "#fff4d6" }
local worm = {
  "....hgg.....",
  "...hg..gs...",
  "..hg....gs..",
  ".hg......ghh",
  "sg.......sge",
  "s.........sg",
}
for yy, row in ipairs(worm) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if IW[ch] then c:put(29 + xx, 42 + yy, IW[ch]) end end end
c:put(40, 46, "#fff4d6")

A.save(c, "nav-tasks")
