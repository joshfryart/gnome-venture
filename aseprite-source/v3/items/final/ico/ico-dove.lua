-- ico-dove (final, Opus). A white dove gliding right with its near wing swept up and back, far wing peeking above,
-- fanned tail, carrying an olive sprig. Slim tapered body, small round head, short peach beak.
-- Material: per-pixel ellipsoid light on body and head (6-tone cool white, violet shade, warm cream light), wings
-- built from separate primary feathers with a dark split between them and a lit leading edge (covert row), tail
-- feathers fanned with shaft lines, AO where the wing roots into the body, cool reflected light under the belly;
-- olive leaves with a midrib, one glossy olive.
-- quirk: a single loose feather drifts down behind the tail.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-dove")
local WH = { "#3e3a6a", "#62649a", "#8e94c2", "#bcc4e2", "#e2e8f4", "#fff4d6" }
local LEAF = { "#1e4a3e", "#2f7446", "#4fa050", "#84c860", "#c4e68a" }
local OLIVE = { "#2a1e3a", "#4a3a6a", "#6e5a9a", "#a48ac8" }
local BEAK = { "#a84a3a", "#e07a52", "#ffb07a" }
local SPEC = "#fff4d6"
local function stepAt(x, y, d, tok) -- move the pixel's current WH tone by d steps
  local h = c:get(x, y) if not h then return end
  for i, w in ipairs(WH) do if w == h then c:put(x, y, WH[max(1, min(#WH, i + d))], tok) return end end
end

-- far wing (behind), painted first
local wtokF = A.tok("farwing")
local function wing(root, tip, nfeat, spread, len, wbase, tok, darker)
  local all = HP.mask()
  local feats = {}
  local ax, ay = tip[1] - root[1], tip[2] - root[2]
  local base = math.atan(ay, ax)
  for i = 1, nfeat do
    local a = base + (i - (nfeat + 1) / 2) * spread
    local L = len * (1 - 0.1 * abs(i - nfeat * 0.35))
    local bx, by = root[1] + cos(a) * L, root[2] + sin(a) * L
    local fm, fn, FT, FS = X.cyl(root[1], root[2], bx, by, function(t) return wbase * (0.55 + 0.6 * sin(min(1, t * 1.15) * pi * 0.85)) end)
    feats[#feats + 1] = { m = fm, n = fn, t = FT }
  end
  -- paint from trailing to leading feather so the leading edge sits on top
  for i = #feats, 1, -1 do
    local f = feats[i]
    local m = f.m:copy():cut(all)
    local bias = {}
    m:each(function(x, y) local k = K(x, y) bias[k] = darker or 0
      if f.t[k] and f.t[k] < 0.3 then bias[k] = bias[k] - 1 end end)
    local idx = A.shade(c, m, f.n, WH, { amb = 0.14, wrap = 0.45, bias = bias, tok = tok, cuts = { 0.14, 0.3, 0.5, 0.7, 0.9 } })
    -- dark split along this feather's trailing side (touching the previous feather)
    m:each(function(x, y)
      if all:has(x + 1, y) or all:has(x, y + 1) or all:has(x - 1, y + 1) then A.step(c, idx, WH, x, y, -2, tok) end
    end)
    all:add(f.m)
  end
  return all
end
local farW = wing({ 34, 30 }, { 41, 7 }, 4, 0.24, 21, 2.4, wtokF, -1)

-- tail fan (behind body)
local ttok = A.tok("tail")
local tail = HP.mask()
for i, a in ipairs{ 2.85, 3.0, 3.17 } do
  local ex, ey = 20 + cos(a) * 13, 39 + sin(a) * 13 + 2
  local fm, fn, FT = X.cyl(21, 38, ex, ey, function(t) return 1.8 + t * 1.6 end)
  local m = fm:copy():cut(tail)
  local bias = {}
  m:each(function(x, y) bias[K(x, y)] = (i == 3) and -1 or 0 end)
  local idx = A.shade(c, m, fn, WH, { amb = 0.14, wrap = 0.4, bias = bias, tok = ttok, cuts = { 0.14, 0.3, 0.5, 0.7, 0.9 } })
  m:each(function(x, y) if tail:has(x, y - 1) or tail:has(x + 1, y - 1) then A.step(c, idx, WH, x, y, -2, ttok) end end)
  tail:add(fm)
end
-- body: slim tapered ellipsoid, head
local btok = A.tok("body")
local body, bn = A.oval(32, 38, 13, 5.6, -0.12)
local hm, hn = A.oval(45.5, 30.5, 5, 4.6, 0)
local neck, nn = A.oval(41, 34, 5, 4.2, -0.6)
local all = body:copy():add(neck):add(hm)
local n = {}
for k, v in pairs(bn) do n[k] = v end
for k, v in pairs(nn) do n[k] = v end
for k, v in pairs(hn) do n[k] = v end
local bias = {}
X.ao(bias, all, tail, 1, -1)
-- under-belly cool bounce
local idx = A.shade(c, all, n, WH, { amb = 0.12, wrap = 0.4, bias = bias, tok = btok, cuts = { 0.12, 0.28, 0.46, 0.68, 0.94 } })
local rim = X.rim(n)
all:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > 39 then c:put(x, y, "#9aa8d8", btok) end end)
-- eye: 2x3 ink pill with glint
c:eyeSmall(46, 28)
-- beak: short wedge
local bk = c:poly{ { 50, 29.5 }, { 55.5, 31 }, { 50, 32.5 } }
bk:each(function(x, y) c:put(x, y, y < 31 and BEAK[3] or (y == 31 and BEAK[2] or BEAK[1]), A.tok("beak")) end)
-- cheek blush feather line under the eye (subtle)
c:put(44, 32, WH[4], btok)

-- near wing: swept up and back from the shoulder
local wtokN = A.tok("nearwing")
local nearW = wing({ 31, 35 }, { 14, 10 }, 5, 0.2, 25, 2.6, wtokN, 0)
-- covert row: lit leading edge along the wing root
local cov = X.cyl(31, 35, 22, 22, function(t) return 2.4 - t * 0.8 end)
local cm = cov:copy()
local cn = select(2, X.cyl(31, 35, 22, 22, function(t) return 2.4 - t * 0.8 end))
A.shade(c, cm, cn, WH, { amb = 0.2, wrap = 0.5, tok = wtokN, cuts = { 0.14, 0.3, 0.5, 0.66, 0.84 } })
-- ambient row where the coverts overlap the primaries
nearW:each(function(x, y) if not cm:has(x, y) and (cm:has(x - 1, y) or cm:has(x, y - 1) or cm:has(x - 1, y - 1)) then stepAt(x, y, -2, wtokN) end end)
-- AO where the near wing roots into the body
for _, p in ipairs{ { 33, 37 }, { 34, 37 }, { 33, 38 }, { 32, 38 } } do if all:has(p[1], p[2]) then c:put(p[1], p[2], WH[3], btok) end end
c:put(26, 25, SPEC, wtokN)

-- olive sprig from the beak
local ltok = A.tok("leaf")
local stem = { { 53, 32 }, { 54, 35 }, { 54, 38 }, { 53, 41 } }
for _, p in ipairs(stem) do c:put(p[1], p[2], LEAF[2], ltok) end
for y = 33, 40 do c:put(floor(53.5 + sin((y - 32) / 3) * 0.7), y, LEAF[2], ltok) end
local function leaf(ax, ay, bx, by, w)
  local m, nl, T, S = X.cyl(ax, ay, bx, by, function(t) return w * sin(max(0.05, t) * pi) ^ 0.7 end)
  local li = A.shade(c, m, nl, LEAF, { amb = 0.15, wrap = 0.4, tok = ltok, cuts = { 0.2, 0.4, 0.62, 0.84 } })
  -- midrib
  for i = 1, 6 do local t = i / 7 local x, y = floor(ax + (bx - ax) * t + 0.5), floor(ay + (by - ay) * t + 0.5)
    if m:has(x, y) then c:put(x, y, LEAF[5], ltok) end end
  return m
end
leaf(54, 35, 59, 33, 1.9)
leaf(54, 38, 50, 43, 1.9)
leaf(53, 41, 57, 46, 1.8)
-- one glossy olive
local om, onn = A.oval(51, 46, 1.2, 1.7, 0.3)
A.shade(c, om, onn, OLIVE, { amb = 0.15, tok = A.tok("olive"), cuts = { 0.25, 0.5, 0.8 } })
c:put(50, 45, OLIVE[4], A.tok("olive"))

-- quirk: a loose feather drifting below the tail
local qf = X.cyl(10, 50, 16, 47, function(t) return 1.5 * sin(max(0.08, t) * pi) end)
local qn = select(2, X.cyl(10, 50, 16, 47, function(t) return 1.5 * sin(max(0.08, t) * pi) end))
A.shade(c, qf, qn, WH, { amb = 0.2, wrap = 0.4, tok = A.tok("loose"), cuts = { 0.14, 0.3, 0.5, 0.7, 0.9 } })
for _, p in ipairs{ { 11, 50 }, { 12, 49 }, { 13, 49 }, { 14, 48 } } do if qf:has(p[1], p[2]) then c:put(p[1], p[2], WH[3], A.tok("loose")) end end
c:put(9, 51, WH[2], A.tok("loose"))
A.save(c, "ico-dove")
