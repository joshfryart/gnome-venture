-- ico-books (final pass, Opus). A stack of three books lying flat, spines to the viewer, staggered.
-- Structure: blue thick book at the bottom, slim orange book in the middle, plum book on top; each shows a rounded
-- spine (horizontal cylinder) and its end with the page block between the boards. Each spine is dressed differently:
-- gold bands + cream title label, dark stripes + gold studs, gold double rule + tooled title.
-- Material: per-pixel cylinder light (6 tones per cloth), cloth weave, page lines on the ends, contact shadow where each
-- book rests on the one below, gold specular on bands.
-- quirk: a quill feather is tucked between the top two books as a bookmark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new("ico-books")
local BL, OR, PL, GO, PG, QU = R.blue, R.orange, R.plum, R.gold, R.page, R.quill

local books = {}
-- book: spine x0..x1, y0..y1; end face e px wide to the right
local function book(x0, y0, x1, y1, e, ramp, dress)
  -- end face: boards top/bottom, page block between
  for x = x1 + 1, x1 + e do
    for y = y0 + 1, y1 - 1 do
      local col
      if y == y0 + 1 or y == y1 - 1 then col = ramp[2]
      else col = ((y - y0) % 2 == 0) and PG[4] or PG[5] end
      if x == x1 + 1 and col ~= ramp[2] then col = PG[2] end           -- AO where pages meet the spine
      if x == x1 + e and col ~= ramp[2] then col = PG[3] end
      c:put(x, y, col)
    end
  end
  -- spine
  local m = c:rrect(x0, y0, x1, y1, 2)
  local hh = (y1 - y0) / 2
  local idx = A.face(c, m, ramp, { R = 1.2, bev = 0.35, grain = 0.015, seed = x0,
    nfn = function(x, y, n) local u = (y - y0 - hh) / (hh + 0.6) return n[1] - 0.15 + (x - x0) / 120, u * 0.95, 0.7 end })
  -- weave: faint diagonal ticks on mid tones
  m:shrink(1):each(function(x, y) if (x + 2 * y) % 9 == 0 and (idx[K(x, y)] or 0) >= 3 then A.step(c, idx, ramp, x, y, -1) end end)
  books[#books + 1] = { m = m, idx = idx, ramp = ramp, x0 = x0, y0 = y0, x1 = x1 + e, y1 = y1 }
  dress(m, idx, x0, y0, x1, y1)
  return m, idx
end

local function goldCol(x0, y0, y1, x, w)
  for xx = x, x + w - 1 do for y = y0 + 1, y1 - 1 do
    local u = (y - y0) / (y1 - y0)
    local col = u < 0.3 and GO[5] or (u < 0.7 and GO[4] or GO[3])
    if y == y1 - 1 then col = GO[2] end
    if xx == x + w - 1 and w > 1 then col = (u < 0.3) and GO[4] or GO[2] end
    c:put(xx, y, col)
  end end
end

-- bottom: blue, thick
book(10, 40, 47, 52, 5, BL, function(m, idx, x0, y0, x1, y1)
  goldCol(x0, y0, y1, x0 + 4, 2) goldCol(x0, y0, y1, x0 + 7, 1)
  goldCol(x0, y0, y1, x1 - 5, 1) goldCol(x0, y0, y1, x1 - 3, 2)
  -- cream title label with ink title
  local lx0, lx1, ly0, ly1 = 23, 34, y0 + 3, y1 - 3
  for x = lx0, lx1 do for y = ly0, ly1 do
    local col = PG[5]
    if y == ly0 or x == lx0 then col = PG[6] end
    if y == ly1 or x == lx1 then col = PG[3] end
    c:put(x, y, col)
  end end
  for x = lx0 + 2, lx1 - 2 do if x ~= 28 then c:put(x, ly0 + 2, BL[2]) end end
  for x = lx0 + 3, lx1 - 4 do c:put(x, ly0 + 4, BL[3]) end
  c:put(x0 + 4, y0 + 2, A.CREAM)
end)

-- middle: orange, slim, shifted right
book(15, 32, 46, 40, 4, OR, function(m, idx, x0, y0, x1, y1)
  for _, x in ipairs{ x0 + 5, x1 - 6 } do
    for y = y0 + 1, y1 - 1 do A.step(c, idx, OR, x, y, -2) A.step(c, idx, OR, x + 1, y, 1) end
  end
  for _, x in ipairs{ 26, 30, 34 } do
    c:put(x, y0 + 3, GO[6]) c:put(x + 1, y0 + 3, GO[4]) c:put(x, y0 + 4, GO[4]) c:put(x + 1, y0 + 4, GO[2])
  end
end)

-- quill feather tucked between the middle and top books (painted before the top book)
do
  local fm, fn, FT, FS = A.blade(22, 32, 7, 31.5, 4, 15, function(t)
    if t < 0.12 then return -1 end
    return 3.1 * sin(pi * min(1, (t - 0.12) / 0.88)) ^ 0.55 - 0.15 end, { fold = 0.35 })
  local fv = X.light(fn, { amb = 0.12, wrap = 0.35 })
  local fidx = X.tone(c, fm, fv, QU, { cuts = { 0.18, 0.32, 0.46, 0.62, 0.8 } })
  -- barbs: split notches along the vane + blue-dipped tip
  fm:each(function(x, y) local k = K(x, y) local t, s = FT[k], FS[k]
    if t > 0.82 then c:put(x, y, ({ "#2a4a7a", "#3769a4", "#4c8ec4", "#70b4dc", "#8fc8e4", "#b2e2ee" })[fidx[k]]) end
    if abs(s) > 0.55 and ((t * 30 + abs(s) * 2) % 3) < 0.7 then c:put(x, y, QU[max(1, fidx[k] - 2)]) end
  end)
  -- shaft
  for i = 0, 40 do
    local t = i / 40
    local u = 1 - t
    local x = u * u * 22 + 2 * u * t * 7 + t * t * 4
    local y = u * u * 32 + 2 * u * t * 31.5 + t * t * 15
    if t < 0.95 then c:put(floor(x + .5), floor(y + .5), t < 0.15 and "#c4a07a" or QU[6]) end
  end
end

-- top: plum, offset left
book(12, 22, 44, 32, 5, PL, function(m, idx, x0, y0, x1, y1)
  for _, x in ipairs{ x0 + 3, x1 - 3 } do
    for y = y0 + 1, y1 - 1 do c:put(x, y, (y < y0 + 4) and GO[5] or GO[3]) end
  end
  for _, x in ipairs{ x0 + 5, x1 - 5 } do
    for y = y0 + 1, y1 - 1 do c:put(x, y, (y < y0 + 4) and GO[4] or GO[2]) end
  end
  -- tooled title: gold dashes with a lit top
  for x = 22, 34 do if x % 4 ~= 1 then c:put(x, y0 + 4, GO[5]) c:put(x, y0 + 5, GO[2]) end end
  c:put(x0 + 3, y0 + 2, A.CREAM)
end)

-- contact shadow: each book darkens the top rows of the one beneath where it rests
for _, pr in ipairs{ { 1, 2 }, { 2, 3 } } do
  local lo, hi = books[pr[1]], books[pr[2]]
  for x = hi.x0 + 1, hi.x1 do
    for dy = 1, 2 do
      local y = hi.y1 + dy
      if lo.idx[K(x, y)] and not hi.m:has(x, y) then A.step(c, lo.idx, lo.ramp, x, y, dy == 1 and -2 or -1) end
    end
  end
end

A.save(c, "ico-books")
