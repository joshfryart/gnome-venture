-- harvest-sack (final, Opus aC11_0). A tall, slim-shouldered burlap sack, slumped a little, cinched at the neck with a
-- twisted jute rope whose tail hangs down; the frilled mouth spills wheat ears and one leek top. Material: per-pixel
-- light (pillow + cylinder blend, 6-tone tan), burlap weave (offset warp/weft grid), vertical slump folds, a darker
-- sewn patch with the one gold stitch, rope twist (diagonal light/dark), wheat ears with kernels and awns, AO under the
-- rope and at the base. Ground shadow (it stands).
-- quirk: a field mouse peeks out from between the wheat ears at the top.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_0.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt = math.max, math.min, math.floor, math.abs, math.sqrt
local c = A.new("harvest-sack")
local BUR  = { "#5a3a2c", "#7e5638", "#a37a4a", "#c49b62", "#dcbb80", "#f1dba6" }
local PATCH = { "#4a2f2e", "#6e4232", "#8f5a3c", "#ad744a", "#c99360", "#e0b27c" }
local ROPE = { "#4d3424", "#7a5636", "#a8804d", "#d3ad70" }
local WHEAT = { "#7a4a1f", "#b5782a", "#dba23c", "#f3cf6a", "#ffeaa6" }
local LEEK = { "#1f4a3c", "#2f6f4a", "#4d9a52", "#86c264", "#c4e07a" }
local tS, tR, tW = A.tok("sack"), A.tok("rope"), A.tok("wheat")

c:groundShadow(32, 56, 14, 2)

-- contents first (sack mouth paints over the stalk bases)
-- leek: a slim fanned blade pair at the back right
for _, b in ipairs{ { {35,17},{37,13},{39,10},{42,8} , 1.6 }, { {33,17},{33,13},{31,11},{28,9}, 1.3 } } do
  local m, n = A.tube({ b[1], b[2], b[3], b[4] }, function(t) return b[5] * (1 - t * 0.5) end)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  local idx = X.tone(c, m, v, LEEK, { cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = A.tok("leek") })
end
-- wheat: three slim stalks with plaited ears + awns
local ears = { { 24, 17, 20, 9 }, { 30, 17, 30, 8 }, { 39, 17, 45, 10 } }
for i, e in ipairs(ears) do
  local x0, y0, x1, y1 = e[1], e[2], e[3], e[4]
  local m = c:line({ { x0, y0 }, { x1 + (x0 - x1) * 0.45, y1 + (y0 - y1) * 0.45 } }, 1)
  c:fillMask(m, WHEAT[2])
  -- ear: kernels alternating along the top 45%
  local ex, ey = x1 + (x0 - x1) * 0.45, y1 + (y0 - y1) * 0.45
  local dx, dy = x1 - ex, y1 - ey
  local L = sqrt(dx*dx + dy*dy) dx, dy = dx / L, dy / L
  local px, py = -dy, dx
  for s = 0, floor(L) do
    local cx, cy = ex + dx * s, ey + dy * s
    local side = (s % 2 == 0) and 1 or -1
    local kx, ky = floor(cx + px * side * 0.9 + .5), floor(cy + py * side * 0.9 + .5)
    c:put(floor(cx + .5), floor(cy + .5), WHEAT[3], tW)
    c:put(kx, ky, side < 0 and WHEAT[4] or WHEAT[3], tW)
    if s % 2 == 0 then c:put(floor(cx - px + .5), floor(cy - py + .5), WHEAT[5], tW) end
  end
  -- awns
  c:put(floor(x1 + dx * 1.5 + .5), floor(y1 + dy * 1.5 + .5), WHEAT[4], tW)
  c:put(floor(x1 + dx * 2.5 + px * 1 + .5), floor(y1 + dy * 2.5 + py * 1 + .5), WHEAT[3], tW)
end

-- quirk: field mouse peeking out between the stalks (head only, round ear, pink nose, small eye)
A.map(c, {
  ".ee...",
  "eppe..",
  "eFFFF.",
  "FFkFFF",
  "FfFFFFn",
  ".ffff..",
}, 25, 10, { e = "#a9878f", p = "#f5a3b8", F = "#b6a3a6", f = "#857077", k = "#2b1c26", n = "#f5809f" }, A.tok("mouse"))
c:put(27, 13, "#2b1c26") c:put(27, 12, "#2b1c26") c:put(26, 12, "#fff4d6")

-- sack body: slim, slightly bulging bottom, slumps to the right
local body = c:poly{ {24,22},{40,22},{43,28},{45,38},{45,47},{42,53},{36,55},{27,55},{21,53},{19,46},{20,36},{22,28} }
local nP = X.pillow(body, 6)
local nC = A.vcylN(body, 19, 45)
local n = A.blend(nP, nC, 0.45)
local bias = {}
-- slump folds: two shallow vertical creases (dark groove + lit ridge)
body:each(function(x, y) local k = K(x, y)
  if y > 24 and y < 50 then
    local f1 = 27 + floor((y - 24) * 0.12 + .5)
    local f2 = 37 + floor((y - 24) * 0.18 + .5)
    if x == f1 or x == f2 then bias[k] = -1 elseif x == f1 - 1 or x == f2 - 1 then bias[k] = 1 end
  end
  if y >= 53 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, body, n, BUR, { tok = tS, bias = bias, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
-- burlap weave: offset grid (weft every 2 rows, warp every 2 cols, alternating)
body:each(function(x, y) local k = K(x, y) local cur = idx[k] or 3
  if (x + floor(y / 2)) % 2 == 0 and y % 2 == 0 then c:put(x, y, BUR[max(1, cur - 1)], tS)
  elseif (x % 4 == 1) and (y % 2 == 1) and cur < 6 and cur >= 3 then c:put(x, y, BUR[cur + 1], tS) end
end)
-- sewn patch, lower right, with the one gold stitch
local patch = c:rect(33, 40, 40, 47)
local pn = X.pillow(patch, 2)
A.shade(c, patch, pn, PATCH, { tok = A.tok("patch"), amb = 0.12 })
patch:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, PATCH[2], A.tok("patch")) end end)
for x = 33, 40 do c:put(x, 48, BUR[1], tS) end
c:stitch{ {34,40},{39,40} }
c:stitch{ {40,42},{40,46} }

-- frilled mouth: flared ruffle above the rope, ragged top edge
local frill = c:poly{ {22,15},{42,15},{39,22},{25,22} }
for x = 21, 43 do if (x % 3 == 0) then frill:set(x, 14) end end
local fn = X.pillow(frill, 2)
local fidx = A.shade(c, frill, fn, BUR, { tok = A.tok("frill"), amb = 0.1 })
for x = 22, 42 do if x % 3 == 1 and frill:has(x, 18) then for y = 16, 21 do A.putIn(c, frill, x, y, BUR[2], A.tok("frill")) end end end
-- inner dark mouth behind the contents line
for x = 25, 39 do if frill:has(x, 15) and x % 3 ~= 0 then c:put(x, 15, BUR[1], A.tok("frill")) end end

-- rope tie: twisted, 3 px tall band at the neck + hanging tail
local rope = c:rect(23, 21, 41, 23)
rope:add(c:line({ {40,23},{42,27},{42,31} }, 2))
rope:each(function(x, y)
  local ph = (x + y) % 3
  local col = ph == 0 and ROPE[1] or (ph == 1 and ROPE[2] or ROPE[3])
  if y == 21 and ph == 2 then col = ROPE[4] end
  if x >= 39 and y >= 24 then col = ((x + y) % 2 == 0) and ROPE[2] or ROPE[1] end
  c:put(x, y, col, tR)
end)
c:put(41, 32, ROPE[3], tR) c:put(42, 32, ROPE[2], tR) c:put(43, 33, ROPE[2], tR) -- frayed end
-- AO under the rope on the body
for x = 23, 41 do if body:has(x, 24) and not rope:has(x, 24) then c:put(x, 24, BUR[1], tS) end end
c:put(24, 22, ROPE[4], tR) c:put(25, 22, ROPE[4], tR)  -- the one glint (rope sheen)

A.save(c, "harvest-sack")
