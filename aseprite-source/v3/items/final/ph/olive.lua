-- olive (final, Opus single pass, aC31_0). A slim olive sprig: a thin grey-bark twig on the diagonal, two narrow
-- lanceolate olive leaves (dark grey-green top with pale midrib, the lower one turned to show its silvery
-- underside), and two olives hanging on short pedicels: one ripe purple-black, one green.
-- Material: per-pixel oval light on both drupes (6-tone), waxy bloom specks, one bright specular each (glossy),
-- cool reflected light lower-right, tiny dark stylar point at the tip, calyx disc at the stem end, AO + contact
-- shadow where the drupes meet the pedicels, bark with lenticel flecks and a paler cut end.
-- quirk: the green olive is turning: a violet blush creeps up from its tip.
local NAME = "olive"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local PURP  = { "#1d1230", "#2f1c40", "#472854", "#64366a", "#875082", "#ae7ca2" }
local GRN   = { "#283a1e", "#41562a", "#5f7630", "#80973a", "#a6b84c", "#cfd877" }
local LEAF  = { "#1a3230", "#27463b", "#395f46", "#527a50", "#759863", "#a1b882" }
local UNDER = { "#46585a", "#677a76", "#8a9e96", "#abbdb2", "#c9d6ca", "#e4ece0" }
local BARK  = { "#33261f", "#4e3c32", "#6c5847", "#8c7660", "#ad977c", "#d0bf9e" }
local SPEC, COOLP, COOLG = "#fbeef4", "#6a6fae", "#6f9a9a"

-- leaves (behind everything)
local ltok = { r = { name = "leaf" } }
local utok = { r = { name = "under" } }
local l1 = A.leaf(c, 30, 15, 37, 6, 52, 6, 2.7, LEAF, { tok = ltok, fold = 0.5, vs = 3.4 })
local l2 = A.leaf(c, 44, 20, 53, 23, 57, 36, 2.5, UNDER, { tok = utok, fold = 0.35, vs = 3.6 })

-- twig
local btok = { r = { name = "bark" } }
local tw = { { 11, 9 }, { 22, 12 }, { 36, 17 }, { 49, 20 } }
local tm, tn, TT, TS, tidx = A.stem(c, tw, function(t) return 1.45 - 0.45 * t end, BARK, { tok = btok, cut = nil })
-- AO on the leaves where the twig crosses
local ab = {}
X.ao(ab, l1, tm, 1, -1) X.ao(ab, l2, tm, 1, -1)
for k, d in pairs(ab) do local x, y = k % 1024 - 256, k // 1024 - 256
  if not tm:has(x, y) then c:put(x, y, (l1:has(x, y) and not l2:has(x, y)) and LEAF[1] or UNDER[2], ltok) end end
-- lenticels and a paler cut end
for _, p in ipairs{ { 17, 10 }, { 26, 14 }, { 33, 16 }, { 42, 18 } } do
  if tm:has(p[1], p[2]) then c:put(p[1], p[2], BARK[6], btok) end end
for _, p in ipairs{ { 11, 9, 6 }, { 11, 8, 5 }, { 10, 9, 5 }, { 11, 10, 4 } } do c:put(p[1], p[2], BARK[p[3]], btok) end
c:put(10, 8, BARK[4], btok)

-- olives: cx, cy, rx, ry, angle(rad, long axis), ramp, pedicel top
local olives = {
  { 22, 34, 5.6, 8.4, 1.42, PURP, { 21, 12 }, COOLP },
  { 37, 41, 5.2, 7.9, 1.72, GRN,  { 37, 17 }, COOLG },
}
-- pedicels first (thin, green-brown)
local STALK = { "#3c3a24", "#5c5a32", "#848044", "#aaa45e" }
for i, o in ipairs(olives) do
  local tx, ty = o[7][1], o[7][2]
  local top = o[2] - o[4]
  local pts = { { tx, ty }, { tx + (i == 1 and -1 or 1), ty + 5 }, { o[1], top - 3 }, { o[1], top + 1 } }
  A.stem(c, pts, function(t) return 0.7 end, STALK, { tok = { r = { name = "ped" .. i } }, cut = tm })
end

for i, o in ipairs(olives) do
  local m, n = A.oval(o[1], o[2], o[4], o[3], o[5], 0.9)
  local tok = { r = { name = "olive" .. i } }
  local bias = {}
  -- AO just under the calyx
  local cap = c:rect(o[1] - 2, o[2] - o[4] - 2, o[1] + 2, o[2] - o[4] + 1)
  X.ao(bias, m, cap, 1, -1)
  local idx, v = A.shade(c, m, n, o[6], { amb = 0.05, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, bias = bias, tok = tok })
  -- quirk: violet blush up from the tip of the green olive (ragged front, same light index)
  if i == 2 then
    m:each(function(x, y) local k = K(x, y)
      local d = (y - o[2]) + (x - o[1]) * 0.25 + (X.hash(x, y, 3) - 0.5) * 2.2
      if d > 3.2 then c:put(x, y, PURP[min(6, idx[k] + (d > 5 and 0 or 1))], tok)
      elseif d > 2 and X.hash(x, y, 9) > 0.5 then c:put(x, y, PURP[min(6, idx[k] + 1)], tok) end
    end)
  end
  -- waxy bloom specks on the lit half
  m:copy():shrink(1):each(function(x, y) local k = K(x, y)
    if v[k] > 0.55 and v[k] < 0.86 and X.hash(x, y, 17 + i) > 0.86 then c:put(x, y, o[6][min(6, idx[k] + 1)], tok) end end)
  -- cool reflected light lower-right
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.55 and y > o[2] - 2 then c:put(x, y, o[8], tok) end end)
  -- calyx: small dark disc + lit ring at the stem end
  local cy0 = o[2] - floor(o[4]) + 0
  c:put(o[1], cy0, o[6][1], tok) c:put(o[1] - 1, cy0, o[6][2], tok) c:put(o[1] + 1, cy0, o[6][2], tok)
  c:put(o[1], cy0 + 1, o[6][2], tok)
  -- stylar point at the bottom
  local by = o[2] + floor(o[4]) - 1
  c:put(o[1] + (i == 1 and 0 or -1), by, i == 1 and PURP[1] or PURP[2], tok)
  -- glossy specular: 2x1 + 1 px
  local sx, sy = A.specAt(m, n, 40)
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, SPEC, tok) c:put(sx, sy + 1, o[6][6], tok)
  c:put(sx + 2, sy - 1, o[6][6], tok)
  o.m = m
end
-- contact shadow of the green olive's pedicel/twig onto nothing else; AO where purple olive's lower right faces green one
A.save(c, NAME)
