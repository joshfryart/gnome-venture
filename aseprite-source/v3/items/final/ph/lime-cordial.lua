-- lime-cordial (final, Opus single pass). A slim, tall glass cordial bottle: cork stopper with grain and a paler top,
-- twisted twine wrapped twice round the neck with a loose tail, rounded shoulders of empty glass (pale core, bright rim
-- streak, darker glass edge), bright green cordial with a meniscus line, a cream paper label with a lime-wheel badge,
-- thick darker glass foot, 2-tone ground shadow.
-- quirk: one green drip has run down from the lip over the neck glass.
local NAME = "lime-cordial"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GLASS = { "#2a4a7a", "#3a6e98", "#5c9cbc", "#8cc6d4", "#b6e6e2", "#e4fbf2" }
local CORD = { "#1f4a26", "#2e6a26", "#4f9028", "#78b52e", "#a3d23c", "#d4ec72" }
local CORK = { "#51302b", "#864c33", "#a86a42", "#c58a58", "#e0b07c", "#f2d0a0" }
local TWINE = { "#6e4a26", "#9a6c34", "#c89a52", "#e8c47c" }
local PAPER = { "#8f7a5a", "#bfa67a", "#dcc79a", "#efe0b8", "#fff4d6" }
local LIME = { "#2b6a2f", "#3f8c2f", "#62ad35", "#8ccb48" }

c:groundShadow(32, 57, 12, 2)
local X0, X1 = 24, 39
-- glass silhouette
local body = c:rrect(X0, 27, X1, 56, 3)
local sh = c:ellipse(31.5, 28, 7.6, 9) sh:clip(c:rect(0, 0, 63, 28))
local neck = c:rect(29, 16, 34, 22)
local glass = body:copy():add(sh):add(neck)
local lip = c:rect(28, 14, 35, 15)
glass:cut(lip)
local gtok = { r = { name = "glass" } }
local liq = glass:copy():clip(c:rect(0, 31, 63, 53)):clip(c:rect(X0 + 1, 0, X1 - 1, 63))
-- empty glass, then liquid, cylinder shading per column
A.vcyl(c, glass, GLASS, X0, X1, { cuts = { 0.15, 0.35, 0.55, 0.72, 0.88 } })
A.vcyl(c, liq, CORD, X0, X1, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
for _, m in ipairs{ glass } do m:each(function(x, y) c.own[y * 64 + x] = gtok end) end
-- meniscus (pale) and the row under it
for x = X0 + 1, X1 - 1 do c:put(x, 31, x < X1 - 3 and CORD[6] or CORD[4], gtok) end
-- glass thickness: darker edge columns on the shade side, bright rim streak + pale core on the lit side
glass:edge():each(function(x, y) if x >= 31 then c:put(x, y, x >= X1 - 1 and GLASS[2] or GLASS[3], gtok) else c:put(x, y, GLASS[4], gtok) end end)
for y = 23, 52 do
  local x = (y < 27) and (y < 22 and 30 or 26 + max(0, floor((27 - y) * 0.6))) or X0 + 2
  if not (y >= 35 and y <= 47) then c:put(x, y, y < 31 and GLASS[6] or CORD[6], gtok) end
end
c:put(X0 + 2, 33, A.CREAM, gtok) c:put(X0 + 2, 34, A.CREAM, gtok)
-- thick foot
for x = X0 + 1, X1 - 1 do c:put(x, 54, x < 31 and "#3f7a52" or "#2e5e48", gtok) c:put(x, 55, GLASS[2], gtok) end
for x = X0 + 2, X0 + 5 do c:put(x, 54, "#6fae7c", gtok) end
-- lip ring
local ltok = { r = { name = "lip" } }
A.vcyl(c, lip, GLASS, 28, 35, { cuts = { 0.15, 0.35, 0.55, 0.72, 0.88 } })
lip:each(function(x, y) c.own[y * 64 + x] = ltok end)
c:put(29, 14, GLASS[6], ltok)
-- cork
local cm = c:rect(29, 8, 34, 13)
cm:add(c:rect(28, 9, 35, 9))
local ctok = { r = { name = "cork" } }
A.vcyl(c, cm, CORK, 28, 35, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
cm:each(function(x, y) c.own[y * 64 + x] = ctok
  if y > 9 and X.hash(x, y, 9) > 0.72 then A.rp(c, x, y, CORK, 2, ctok) end end)
for x = 29, 34 do c:put(x, 8, x < 33 and CORK[6] or CORK[5], ctok) end   -- paler end grain on top
for x = 28, 35 do c:put(x, 13, CORK[1], ctok) end                         -- AO where cork enters the lip
-- twine: two twisted wraps round the neck + tail
local ttok = { r = { name = "twine" } }
for _, y in ipairs{ 19, 21 } do
  for x = 28, 35 do
    local i = ((x + y) % 2 == 0) and 3 or 2
    if x == 28 then i = i + 1 elseif x >= 34 then i = i - 1 end
    A.rp(c, x, y, TWINE, i, ttok)
  end
  for x = 29, 34 do c:put(x, y + 1, GLASS[2], gtok) end                   -- shadow row under each wrap
end
for _, q in ipairs{ { 36, 20, 2 }, { 37, 21, 3 }, { 37, 22, 2 }, { 38, 23, 3 }, { 38, 24, 2 } } do A.rp(c, q[1], q[2], TWINE, q[3], ttok) end
-- label: cream paper, curved shading, top/bottom edges, lime-wheel badge
local ptok = { r = { name = "label" } }
for y = 36, 47 do for x = X0 + 1, X1 - 1 do
  local i = 4
  if x <= X0 + 2 then i = 5 elseif x >= X1 - 2 then i = 2 elseif x >= X1 - 4 then i = 3 end
  if y == 36 then i = i - 1 end
  A.rp(c, x, y, PAPER, i, ptok)
end end
for x = X0 + 1, X1 - 1 do c:put(x, 48, CORD[1], gtok) end   -- AO under the label
local wx, wy = 31, 41
local wheel = c:ellipse(wx, wy, 4, 4)
wheel:each(function(x, y)
  local dx, dy = x - wx, y - wy
  local r = sqrt(dx * dx + dy * dy)
  local col
  if r > 3.5 then col = (dx + dy > 0) and LIME[1] or LIME[2]
  elseif r > 2.6 then col = PAPER[5]
  else
    local a = math.atan(dy, dx)
    local seg = (a / (pi / 4)) % 1
    col = (seg < 0.2 or r < 0.6) and PAPER[5] or ((dx + dy > 0) and LIME[3] or LIME[4])
  end
  c:put(x, y, col, ptok)
end)
-- tiny label lettering lines
for x = 27, 36 do if x % 3 ~= 0 then c:put(x, 46, PAPER[1], ptok) end end
-- quirk: drip down the neck from the lip
local dtok = { r = { name = "drip" } }
for y = 16, 18 do c:put(34, y, CORD[4], dtok) end
c:put(34, 16, CORD[5], dtok)
c:put(34, 18, CORD[3], dtok)
c:put(35, 18, CORD[2], dtok)
-- shoulder glint
c:put(27, 24, A.CREAM, gtok)

A.save(c, NAME)
