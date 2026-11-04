-- ico-otter (final, Opus). A sea otter floating on its back, head raised to look at you, a scallop shell held
-- on its chest in two small paws, hind feet up, slim tapering tail. The water line cuts the body: a wavy sea band
-- with a lit crest, foam where the fur meets the water and two ripple dashes.
-- Material: per-pixel lit fur (6-tone warm brown), pale cream muzzle and chest, fur tufts along the back edge,
-- ribbed shell with a pink lip, glossy ink nose with a glint, AO where head, paws and shell meet the body.
-- quirk: a tiny pink starfish has hitched a ride on the tail tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, sin, cos, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-otter")
local FUR  = { "#2e1822", "#4b2a25", "#6c3f2c", "#8f5935", "#b27846", "#d29e66" }
local PALE = { "#8a5c42", "#b88660", "#d8ab7c", "#ecc99a", "#f8e3b8" }
local SEA  = { "#233766", "#2c5590", "#3479ab", "#4aa0c2", "#7cc9d4", "#c4f0e4" }
local SHL  = { "#7d2c5e", "#c25a7e", "#ef8ea2", "#ffbdc4", "#ffe3dc" }
local ftok, ptok, stok, wtok = A.tok("fur"), A.tok("pale"), A.tok("shell"), A.tok("sea")

-- tail first (body overlaps its root)
local tm, tn = G.tube({ { 43, 34 }, { 48, 34 }, { 52, 31 }, { 55, 26 } }, function(t) return 3.6 - t * 2.4 end)
A.shade(c, tm, tn, FUR, { tok = ftok })
-- hind feet raised (webbed paddles)
local feet = HP.mask()
for _, f in ipairs{ { 40, 24, -0.45 }, { 44.5, 25, -0.15 } } do
  local m, n = G.oval(f[1], f[2], 2.2, 3.6, f[3])
  A.shade(c, m, n, FUR, { tok = ftok, bias = {} })
  feet:add(m)
end
-- toe splits on the feet
c:put(39, 21, FUR[3], ftok) c:put(44, 22, FUR[3], ftok)
-- body
local bm, bn = G.oval(30, 31, 14.5, 6.6, -0.1)
local bias = {}
G.cast(bias, bm, feet, 1, 1, -1)
local bidx = A.shade(c, bm, bn, FUR, { tok = ftok, bias = bias, amb = 0.08 })
-- pale belly / chest
local belly, beln = G.oval(29, 28.5, 9.5, 3.4, -0.1)
belly:clip(bm)
local bel = {}
belly:each(function(x, y) if not bm:shrink(1):has(x, y) then bel[K(x, y)] = -1 end end)
A.shade(c, belly, beln, PALE, { tok = ptok, bias = bel })
-- fur tufts along the back (lower) edge: notch a few pixels darker
for _, x in ipairs{ 22, 27, 33, 38 } do
  for y = 30, 40 do if bm:has(x, y) and not bm:has(x, y + 1) then c:put(x, y - 1, FUR[2], ftok) end end
end
-- head
local hm, hn = G.oval(15, 23, 8.4, 7.6, 0.1)
local hb = {}
A.shade(c, hm, hn, FUR, { tok = ftok, bias = hb, amb = 0.1 })
-- ears
for _, e in ipairs{ { 9, 17 }, { 21, 17 } } do
  local m, n = G.oval(e[1], e[2], 1.6, 1.3, 0)
  m:cut(hm)
  A.shade(c, m, n, FUR, { tok = ftok })
  c:put(e[1], e[2] + 1, FUR[2], ftok)
end
-- separation head/body: 1px darker fur where the head overlaps the body
hm:edge():each(function(x, y) if bm:has(x, y) and x > 15 then c:put(x, y, FUR[1], ftok) end end)
-- pale face mask
local mz, mzn = G.oval(15, 26.2, 6.2, 4.2, 0)
mz:clip(hm)
A.shade(c, mz, mzn, PALE, { tok = ptok })
-- brows (pale patches above eyes)
c:put(10, 20, PALE[4], ptok) c:put(11, 20, PALE[4], ptok) c:put(18, 20, PALE[4], ptok) c:put(19, 20, PALE[4], ptok)
-- eyes 2x3 ink pills with glint
c:eyeSmall(10, 21) c:eyeSmall(18, 21)
-- nose: glossy ink with cream glint
A.map(c, { "KKKKK", ".KKK." }, 12, 24, { K = A.INK })
c:put(13, 24, "#7a5a66")
-- mouth + whisker pads
A.map(c, { "..k..", ".k.k." }, 12, 26, { k = PALE[1] }, ptok)
for _, w in ipairs{ {9,26},{8,28},{20,26},{21,28} } do c:put(w[1], w[2], PALE[2], ptok) end
-- cheek blush
c:put(9, 24, "#f09a8c", ptok) c:put(21, 24, "#f09a8c", ptok)

-- shell held on the chest (scallop fan, hinge down)
local SX, SY = 29.5, 28.5
local sm = HP.mask()
for y = 21, 28 do for x = 23, 36 do
  local dx, dy = x + 0.5 - SX, y + 0.5 - SY
  local r = sqrt(dx*dx + dy*dy)
  if r <= 5.9 and dy <= 0.2 and abs(dx) <= 5.4 then sm:set(x, y) end
end end
for x = 28, 31 do sm:set(x, 28) end
local sn = X.pillow(sm, 2.5)
local sidx = A.shade(c, sm, sn, SHL, { tok = stok })
-- ribs: radial grooves
sm:each(function(x, y)
  local a = math.atan(x + 0.5 - SX, -(y + 0.5 - SY))
  local f = (a / 0.36) % 2
  if f < 0.6 and y < 27 then A.step(c, sidx, SHL, x, y, -1, stok) end
end)
c:put(26, 24, SHL[5], stok) c:put(27, 23, SHL[5], stok)
-- paws hugging the shell sides
for _, p in ipairs{ { 23.5, 26 }, { 35.5, 26 } } do
  local m, n = G.oval(p[1], p[2], 2.3, 2.3, 0)
  A.shade(c, m, n, FUR, { tok = ftok })
  m:edge():each(function(x, y) if sm:has(x + (p[1] < 29 and 1 or -1), y) then c:put(x, y, FUR[2], ftok) end end)
end
c:put(23, 25, FUR[6], ftok)
-- AO on the chest under the shell
for x = 25, 34 do if belly:has(x, 29) then c:put(x, 29, PALE[2], ptok) end end

-- water band: drawn over the lower body. Pointed crests every 7 px, banded depth.
local wm = HP.mask()
local function top(x) return 32.4 + 2.2 * math.abs(sin((x + 2) * math.pi / 7)) end
local X0, X1 = 6, 56
for x = X0, X1 do
  local yt = floor(top(x) + 0.5)
  local yb = 44
  if x < X0 + 3 then yt = yt + (X0 + 3 - x) yb = yb - (X0 + 3 - x) end
  if x > X1 - 3 then yt = yt + (x - X1 + 3) yb = yb - (x - X1 + 3) end
  for y = yt, yb do wm:set(x, y) end
end
wm:each(function(x, y)
  local d = y - top(x)
  local i = d < 0.9 and 6 or d < 2.2 and 5 or d < 5 and 4 or d < 8 and 3 or 2
  if not wm:has(x, y + 1) then i = 1 end
  if x > X1 - 6 and i > 2 then i = i - 1 end  -- shade side lower right
  c:put(x, y, SEA[i], wtok)
end)
-- foam where the otter meets the water
for x = X0, X1 do
  local y
  for yy = 28, 44 do if wm:has(x, yy) then y = yy break end end
  if y and (bm:has(x, y - 1) or tm:has(x, y - 1) or hm:has(x, y - 1)) then
    c:put(x, y, (x % 4 == 0) and SEA[6] or A.CREAM, wtok)
    if bm:has(x, y - 1) and not belly:has(x, y - 1) then c:put(x, y - 1, FUR[2], ftok) end
  end
end
-- ripple dashes
for _, r in ipairs{ { 11, 38, 5 }, { 28, 40, 6 }, { 43, 38, 5 }, { 19, 41, 3 }, { 37, 42, 3 } } do
  for x = r[1], r[1] + r[3] - 1 do if wm:has(x, r[2] + 1) then c:put(x, r[2], SEA[5], wtok) c:put(x, r[2] + 1, SEA[2], wtok) end end
end

-- quirk: tiny starfish on the tail tip
A.map(c, {
  "..s..",
  "sSSSs",
  ".SHS.",
  "s.d.s",
}, 52, 22, { s = SHL[3], S = SHL[3], H = SHL[5], d = SHL[1] }, stok)
c:put(54, 23, SHL[4], stok)
A.save(c, "ico-otter")
