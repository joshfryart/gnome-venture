-- ico-calendar (final, Opus). A chunky tear-off wall calendar: red binding header, two steel rings through it,
-- a cream page printed with a 3x3 block of date squares (today's in red), a stack of page edges and a card
-- backing board showing at the bottom.
-- Material: paper = per-pixel bevel light (6-tone cream, cool lilac shade) with AO under the header; header = 6-tone
-- glossy red with a bright top edge and dark punched holes; rings = 6-tone steel cylinders with a specular streak and a
-- dark inner shadow where they enter the holes; date squares = 4-tone embossed print; board = 4-tone card.
-- quirk: a ragged stub of yesterday's torn-off page is still caught under the header.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-calendar")
local PAPER = { "#8c7a96", "#c4b2b4", "#e6d6c4", "#f6ead4", "#fff4e2", "#fffaf0" }
local RED   = { "#5e1a32", "#9a2438", "#c8343c", "#e8493b", "#ff7656", "#ffb28a" }
local STEEL = { "#3a3c58", "#5e6080", "#8c8ea8", "#b4b6c8", "#d8d8e4", "#f4f2f8" }
local SQ    = { "#5f7aa8", "#86a0c8", "#a9c0e0", "#cfdcf0" }
local BOARD = { "#51302b", "#864c33", "#b97a4a", "#d89a62" }

local X0, X1, Y0, Y1 = 10, 50, 14, 52
-- backing board + page-edge stack at the bottom
local btok = A.tok("board")
for x = X0, X1 do
  c:put(x, Y1 + 3, BOARD[(x < X0 + 2) and 3 or 2], btok)
  c:put(x, Y1 + 4, BOARD[1], btok)
end
c:put(X0, Y1 + 4, BOARD[2], btok)
local etok = A.tok("edges")
for x = X0, X1 do
  c:put(x, Y1 + 1, (x % 7 == 3) and PAPER[2] or PAPER[3], etok)
  c:put(x, Y1 + 2, (x % 5 == 1) and PAPER[3] or PAPER[2], etok)
end

-- front page
local page = c:rect(X0, Y0, X1, Y1)
local ptok = A.tok("paper")
local pn = X.pillow(page, 2.2, 1.0)
local pb = {}
for x = X0, X1 do for y = Y0 + 10, Y0 + 11 do pb[K(x, y)] = (y == Y0 + 10) and -2 or -1 end end   -- AO under header
local pidx = A.shade(c, page, pn, PAPER, { tok = ptok, bias = pb, amb = 0.62, wrap = 0.3, cuts = { 0.3, 0.55, 0.7, 0.8, 0.93 } })

-- quirk: ragged stub of yesterday's page caught under the header (warmer, with a torn zigzag edge + shadow)
local stok = A.tok("stub")
for x = X0 + 1, X1 - 1 do
  local d = ({ 1, 2, 3, 2, 1, 2, 2, 3, 1, 2, 3, 3, 2, 1 })[(x * 5) % 14 + 1]
  for y = Y0 + 10, Y0 + 9 + d do c:put(x, y, (y == Y0 + 10) and PAPER[3] or PAPER[4], stok) end
  local ys = Y0 + 10 + d
  if page:has(x, ys) then A.set(c, pidx, PAPER, x, ys, 2, ptok) end
end

-- header
local htok = A.tok("header")
local head = c:rrect(X0, Y0, X1, Y0 + 9, 3)
head:clip(c:rect(0, 0, 63, Y0 + 9))
local hn = X.pillow(head, 2.6, 1.1)
local hidx = A.shade(c, head, hn, RED, { tok = htok, amb = 0.1, wrap = 0.25, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
-- bright top lip + darker bottom lip
for x = X0 + 3, X1 - 4 do A.set(c, hidx, RED, x, Y0 + 1, 6, htok) end
for x = X0, X1 do A.set(c, hidx, RED, x, Y0 + 9, 2, htok) end
for x = X0 + 2, X1 - 3, 2 do A.set(c, hidx, RED, x, Y0 + 8, 3, htok) end

-- rings: steel loops dropping into punched holes
local rtok = A.tok("ring")
for _, rx in ipairs{ 17, 41 } do
  -- hole in the header
  for x = rx - 1, rx + 3 do for y = Y0 + 3, Y0 + 5 do
    if not ((x == rx - 1 or x == rx + 3) and (y == Y0 + 3 or y == Y0 + 5)) then c:put(x, y, (y == Y0 + 5) and RED[2] or RED[1], htok) end
  end end
  local ring = c:rrect(rx, Y0 - 6, rx + 2, Y0 + 4, 1)
  local rn = {}
  ring:each(function(x, y) local u = (x - rx - 1) / 1.6 rn[K(x, y)] = { u, (y < Y0 - 4) and -0.5 or 0, sqrt(max(0.05, 1 - u * u)) } end)
  local ridx = A.shade(c, ring, rn, STEEL, { tok = rtok, amb = 0.12, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.82 } })
  for y = Y0 - 4, Y0 + 1 do c:put(rx, y, STEEL[6], rtok) end         -- specular streak
  c:put(rx + 1, Y0 + 3, STEEL[2], rtok) c:put(rx + 2, Y0 + 3, STEEL[1], rtok) c:put(rx, Y0 + 4, STEEL[2], rtok)
  c:put(rx + 1, Y0 + 4, STEEL[1], rtok) c:put(rx + 2, Y0 + 4, STEEL[1], rtok)
end

-- date squares: 3x3 embossed print, today's in red
local qtok = A.tok("dates")
for r = 0, 2 do for q = 0, 2 do
  local x, y = 15 + q * 11, 29 + r * 8
  local today = (r == 1 and q == 2)
  local R = today and { RED[2], RED[3], RED[4], RED[5] } or SQ
  for yy = y, y + 5 do for xx = x, x + 7 do
    local col = R[3]
    if yy == y or xx == x then col = R[4] end
    if yy == y + 5 or xx == x + 7 then col = R[2] end
    if (yy == y + 5 and xx == x) or (xx == x + 7 and yy == y) then col = R[3] end
    c:put(xx, yy, col, qtok)
  end end
  -- soft print shadow under/right on the paper
  for xx = x + 1, x + 8 do A.set(c, pidx, PAPER, xx, y + 6, 3, ptok) end
  for yy = y + 1, y + 5 do A.set(c, pidx, PAPER, x + 8, yy, 3, ptok) end
  if today then
    c:put(x + 3, y + 2, A.CREAM, qtok) c:put(x + 4, y + 2, A.CREAM, qtok)
    c:put(x + 3, y + 3, A.CREAM, qtok) c:put(x + 4, y + 3, RED[6], qtok)
  end
end end
A.save(c, "ico-calendar")
