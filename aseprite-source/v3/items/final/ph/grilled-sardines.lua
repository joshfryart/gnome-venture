-- grilled-sardines (aC10_3 Opus pass). Two slim whole sardines fresh off the grill, laid head-to-tail on the diagonal
-- across a narrow olive-wood serving board (grain lines, pale end grain, bevel, hang hole). Fish: steel-blue backs
-- with a dark lateral stripe, silver flanks, cream bellies, per-pixel light, blistered skin, char stripes from the grill
-- bars with golden crisped edges, gill arc, ink eye with glint, forked tails charred at the tips. Lemon wedge with
-- segments and pith, parsley sprig, coarse salt flakes.
-- quirk: a single curl of steam is rising off the top fish.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("grilled-sardines")
local WOOD = { "#4a2a22", "#6e4030", "#965e3e", "#b8804e", "#d6a46a", "#ecc994" }
local BACK = { "#1e2a48", "#2c405e", "#3e5c7a", "#58809a", "#7ea6b6", "#a8c8cc" }
local SILV = { "#56607a", "#7c879c", "#a4adbc", "#c8ced6", "#e2e6e6", "#f6f4ec" }
local CHAR = { "#2e1c1e", "#4a2a24", "#8a5230", "#c8863e" }
local LEM  = { "#8a5a14", "#c8901c", "#ecbc2e", "#f8dc5a", "#fff09a", "#fffbd2" }
local PARS = { "#1e4a30", "#2e6e3a", "#4c9a46", "#7cc45a" }

c:groundShadow(32, 51, 22, 1.5)
-- board: slim rounded plank, handle with a hole on the right
local board = HP.rrect(8, 33, 50, 49, 3):add(HP.rrect(48, 38, 57, 43, 2))
local hole = HP.rect(54, 40, 55, 41)
board:cut(hole)
local bn = X.pillow(board, 2)
local btok = D.tok("board")
local bidx = G.toneN(c, board, bn, WOOD, { tok = btok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
board:each(function(x, y) local k = K(x, y)
  -- grain: wavy lines along the board
  local g = (y + 0.9 * sin(x * 0.35 + y * 0.6)) % 3
  if g < 0.55 and bidx[k] and bidx[k] > 2 and bidx[k] < 6 then c:put(x, y, WOOD[bidx[k] - 1], btok) end
  if x == 8 or (x == 9 and (y == 33 or y == 49)) then c:put(x, y, WOOD[6], btok) end      -- pale end grain
end)
c:put(54, 39, WOOD[1], btok) c:put(55, 39, WOOD[2], btok) c:put(54, 42, WOOD[5], btok)    -- hole rim

-- sardine along a cubic bezier (head at p1). returns mask
local function sardine(p, seed)
  local m, n, T, S, sm = G.tube(p, function(t)
    if t < 0.06 then return 1.6 + t * 22 end                                                -- blunt snout
    if t < 0.32 then return 2.9 + (t - 0.06) * 2.6 end
    if t < 0.86 then return 3.6 * (1 - (t - 0.32) / 0.54) ^ 0.9 + 0.75 end
    return -1
  end, 200)
  -- forked tail beyond the end
  local ex, ey = G.bez(p, 1) local bx, by = G.bez(p, 0.97)
  local ux, uy = ex - bx, ey - by local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local tx, ty = G.bez(p, 0.86)
  local tail = HP.mask()
  for _, sd in ipairs{ 1, -1 } do
    local px, py = -uy * sd, ux * sd
    tail:add(HP.line({ { tx, ty }, { tx + ux * 3 + px * 1.5, ty + uy * 3 + py * 1.5 }, { tx + ux * 5 + px * 3.4, ty + uy * 5 + py * 3.4 } }, 1.6))
  end
  tail:cut(m)
  local ttok = D.tok("tail" .. seed)
  G.toneN(c, tail, X.pillow(tail, 1), SILV, { tok = ttok, amb = 0.15, wrap = 0.3 })
  tail:each(function(x, y) local d = (x - tx) * ux + (y - ty) * uy
    if d > 3.8 then c:put(x, y, CHAR[2], ttok) elseif d > 2.6 then c:put(x, y, CHAR[3], ttok) end end)
  local tok = D.tok("fish" .. seed)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    local i = 1
    for j, ct in ipairs{ 0.2, 0.36, 0.52, 0.68, 0.84 } do if v[k] >= ct then i = j + 1 end end
    local R = SILV
    if s < -0.38 then R = BACK
    elseif s < -0.26 then R = BACK i = max(1, i - 2) end                                     -- dark lateral stripe
    if s > 0.62 then i = min(6, i + 1) end                                                   -- cream belly
    local hex = R[max(1, min(6, i))]
    -- blistered skin specks
    if X.hash(x, y, seed) < 0.06 and t > 0.25 then hex = R[max(1, i - 1)] end
    -- char stripes across the body (grill bars), golden crisp fringe
    local L = sm and #sm or 1
    local q = (x * 0.8 - y * 0.6 + seed * 1.7) % 5
    if t > 0.2 and t < 0.8 and s > -0.75 and s < 0.5 then
      if q < 1.1 then hex = (s < -0.3) and CHAR[1] or CHAR[2]
      elseif q < 1.7 and s < 0.2 then hex = CHAR[4] end
    end
    c:put(x, y, hex, tok)
  end)
  -- gill arc + eye
  local gx, gy = G.bez(p, 0.2) local hx, hy = G.bez(p, 0.07)
  for _, o in ipairs{ -1.4, -0.4, 0.6, 1.6 } do
    local px, py = -uy, ux
    local xx, yy = floor(gx + px * o + 0.5), floor(gy + py * o + 0.5)
    if m:has(xx, yy) then c:put(xx, yy, CHAR[3], tok) end
  end
  local exx, eyy = floor(hx + 0.5), floor(hy - 0.8 + 0.5)
  c:put(exx, eyy, D.INK, tok) c:put(exx + 1, eyy, D.INK, tok) c:put(exx, eyy + 1, D.INK, tok) c:put(exx + 1, eyy + 1, "#3a2a36", tok)
  c:put(exx, eyy, SILV[6], tok)
  -- one specular streak on the back
  local sx, sy = G.bez(p, 0.45)
  c:put(floor(sx - 1.5), floor(sy - 1.8), SILV[6], tok) c:put(floor(sx - 0.5), floor(sy - 1.8), SILV[5], tok)
  return m:add(tail)
end
-- lower fish: head left, tail right; upper fish: head right, tail left (head-to-tail)
local f1 = sardine({ { 12, 45 }, { 21, 47 }, { 33, 47 }, { 47, 43 } }, 1)
local f2 = sardine({ { 50, 36 }, { 43, 39 }, { 31, 38 }, { 18, 35 } }, 2)
-- contact shadow of the fish on the board
local sh = HP.mask()
for _, f in ipairs{ f1, f2 } do
  f:shift(1, 2):each(function(x, y) if board:has(x, y) and not f1:has(x, y) and not f2:has(x, y) then sh:set(x, y) end end)
end
sh:each(function(x, y) D.shift(c, x, y, WOOD, -2) end)
-- 1 px dark separation line where the fish meet the board
local fa = f1:copy():add(f2)
fa:grow(1):cut(fa):each(function(x, y) if board:has(x, y) then c:put(x, y, WOOD[1], btok) end end)

-- lemon wedge in front (left), parsley sprig behind it
local ptok = D.tok("parsley")
for _, p in ipairs{ { 11, 35, 3 }, { 12, 34, 4 }, { 10, 34, 2 }, { 11, 33, 4 }, { 13, 35, 3 }, { 9, 35, 2 }, { 12, 36, 2 } } do
  c:put(p[1], p[2], PARS[p[3]], ptok)
end
local wedge = HP.poly{ { 7, 41 }, { 18, 41 }, { 15, 37 }, { 10, 37 } }
local wtok = D.tok("lemon")
wedge:each(function(x, y)
  local i
  if y == 41 then i = 2                                                       -- rind
  elseif y == 40 then i = 6                                                   -- pith
  else i = ((x + (41 - y)) % 4 == 0) and 6 or ((x < 13) and 5 or 4) end      -- segments
  c:put(x, y, LEM[i], wtok)
end)
c:put(7, 41, LEM[1], wtok) c:put(18, 41, LEM[1], wtok) c:put(12, 38, LEM[6], wtok)
-- salt flakes on the fish
local stok = D.tok("salt")
for _, p in ipairs{ { 24, 46 }, { 36, 45 }, { 28, 37 }, { 40, 37 }, { 22, 35 } } do
  if f1:has(p[1], p[2]) or f2:has(p[1], p[2]) then c:put(p[1], p[2], "#fbf6ea", stok) end
end
-- quirk: steam curl off the top fish
local qt = D.tok("steam")
local SC = { "#e8eef4", "#e8eef4" }
for _, p in ipairs{ { 34, 32, 1 }, { 33, 31, 1 }, { 33, 30, 2 }, { 34, 29, 1 }, { 35, 28, 1 }, { 35, 27, 2 }, { 34, 26, 1 }, { 33, 25, 2 }, { 34, 24, 1 } } do
  c:put(p[1], p[2], SC[p[3]], qt)
end
D.save(c, "grilled-sardines")
