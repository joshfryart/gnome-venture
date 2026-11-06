-- cabbage (final pass, Opus aB13_4). A firm, slightly tall cabbage head (fresh yellow-green, wrapped in two overlapping
-- head leaves whose edges lip over each other, whitish veins fanning from each leaf base, one gloss mark) cupped by four
-- bluish waxy wrapper leaves (ruffled scalloped margins, thick pale midrib, branching pale veins, cool lower-right rim,
-- AO where they tuck under the head). A cut stalk pokes out lower-left showing its pale ringed end.
-- quirk: a small cabbage-white caterpillar inching up the right wrapper leaf.
local NAME = "cabbage"
local M = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_4.lua")
local HP, X, K = M.HP, M.X, M.K
local floor, max, min, abs, sin, cos, pi, sqrt, atan = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt, math.atan
local c = M.new(NAME)

local OUTL = { "#173a40", "#20524c", "#2d6c58", "#428a66", "#62a67a", "#90c69a" }
local OVEIN = "#c8e6b8"
local HEAD = { "#2c5a3c", "#3d7c46", "#5a9c4e", "#82bb5c", "#acd676", "#d8eea2" }
local HVEIN = "#e2f4b6"
local COOL = "#3c6e80"
local STALK = { "#4e7a44", "#6e9c52", "#94bc66", "#bcd888", "#e2efb8" }
local CAT = { "#3a6428", "#5a8c32", "#86b840", "#b2d858", "#def088" }

-- masks first (for AO)
local hcx, hcy = 32, 31
local head = c:ellipse(hcx, hcy, 12, 13)

local function wrapMask(ax, ay, cx, cy, bx, by, w, nr)
  return M.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local base = w * sin(pi * min(1, t * 0.82 + 0.16)) ^ 0.6
    return max(0.5, base * (1 - 0.14 * abs(sin(t * nr * pi))))
  end, { fold = 0.3 })
end
local back = {
  { wrapMask(31, 42, 14, 40, 11, 18, 8, 6) },
  { wrapMask(33, 42, 50, 40, 53, 19, 8, 6) },
}
local front = {
  { wrapMask(32, 56, 31, 50, 33, 43, 4.2, 3) },
  { wrapMask(31, 55, 19, 54, 13, 43, 5.6, 4) },
  { wrapMask(33, 55, 45, 54, 51, 43, 5.6, 4) },
}
local frontAll = HP.mask() for _, f in ipairs(front) do frontAll:add(f[1]) end

local function paintWrap(L, bias, tok, cutm)
  local m, n, T, S, len = L[1], L[2], L[3], L[4], L[5]
  if cutm then m:cut(cutm) end
  local idx = M.toneN(c, m, n, OUTL, { bias = bias, tok = tok, amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias[k] and bias[k] <= -2 then return end
    if abs(s) < 0.13 and t < 0.9 then c:put(x, y, OVEIN, tok) return end
    if s > 0.13 and s < 0.26 and t < 0.86 then c:put(x, y, OUTL[max(1, (idx[k] or 3) - 1)], tok) return end
    local ph = (t * len - abs(s) * 6) / 6.5
    if abs(ph - floor(ph + .5)) < 0.08 and abs(s) > 0.25 and abs(s) < 0.82 and t > 0.08 and t < 0.86 then
      c:put(x, y, s < 0 and OVEIN or OUTL[min(6, (idx[k] or 3) + 1)], tok) end
  end)
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] and rim[k] > 0.3 then c:put(x, y, COOL, tok) end end)
  return m
end

-- deep backing where the leaves gather under the head (no see-through gaps)
c:ellipse(32, 43, 14, 6):each(function(x, y) c:put(x, y, (y > 45) and OUTL[1] or OUTL[2], { r = { name = "under" } }) end)
-- back wrapper leaves (behind the head): AO + cast shadow from the head
for i, L in ipairs(back) do
  local bias = {}
  X.ao(bias, L[1], head, 2, -1) M.cast(bias, L[1], head, 1, 2, -1)
  paintWrap(L, bias, { r = { name = "back" .. i } })
end

-- quirk: caterpillar on the right back leaf
do
  local pts = {}
  for i = 0, 20 do local t = i / 20 pts[#pts + 1] = { 45.5 + t * 6, 34 - t * 5 - sin(t * pi) * 1.8 } end
  local cm, cn, CT, CS = M.ptube(pts, function(t) return 1.25 + 0.15 * sin(t * pi) end)
  cm:cut(head)
  local tok = { r = { name = "caterpillar" } }
  local idx = M.toneN(c, cm, cn, CAT, { tok = tok, amb = 0.15, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.82 } })
  cm:each(function(x, y) local k = K(x, y)
    local ph = CT[k] * 6
    if abs(ph - floor(ph + .5)) < 0.09 and CT[k] > 0.1 and CT[k] < 0.85 then c:put(x, y, CAT[max(1, (idx[k] or 3) - 2)], tok) end
    if CS[k] > 0.45 and CS[k] < 0.8 and floor(CT[k] * 10) % 2 == 0 then c:put(x, y, "#f2dc6a", tok) end
  end)
  c:put(52, 28, "#2b3a20", tok) c:put(51, 27, "#4a5c30", tok) c:put(52, 27, "#e8f2c0", tok)
  -- tiny contact shadow under the body on the leaf
  cm:shift(1, 1):each(function(x, y) if not cm:has(x, y) and not head:has(x, y) and back[2][1]:has(x, y) then c:put(x, y, OUTL[2], { r = { name = "back2" } }) end end)
end

-- head
do
  local hm = head:copy()
  local bias = {}
  X.ao(bias, hm, frontAll, 2, -1)
  local n = M.body(hm, hcx - 1, hcy - 1, 13, 5, 0.75)
  local tok = { r = { name = "head" } }
  local idx = M.toneN(c, hm, n, HEAD, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  local function d(x, y, px, py) return sqrt((x - px) ^ 2 + (y - py) ^ 2) end
  local L1 = { 46, 47, 19 }   -- outer head leaf (lower right)
  local L2 = { 17, 49, 24 }   -- second head leaf (lower left)
  local inner = hm:shrink(1)
  local function region(x, y)
    if d(x, y, L1[1], L1[2]) < L1[3] then return L1 end
    if d(x, y, L2[1], L2[2]) < L2[3] then return L2 end
    return { hcx, hcy + 20, 99 }
  end
  hm:each(function(x, y) local k = K(x, y) local i = idx[k]
    local r = region(x, y)
    -- veins fan from each leaf's base
    local dd = d(x, y, r[1], r[2])
    local a = atan(y - r[2], x - r[1])
    local step = 0.4
    if dd > 7 and dd < min(r[3], 40) - 1.5 and abs(a / step - floor(a / step + .5)) * step * dd < 0.5 then
      c:put(x, y, i >= 4 and HVEIN or HEAD[min(6, i + 1)], tok) end
    -- seams: lit lip on the overlapping leaf, shadow on the leaf beneath
    if inner:has(x, y) then
      local e1 = d(x, y, L1[1], L1[2]) - L1[3]
      local e2 = d(x, y, L2[1], L2[2]) - L2[3]
      if e1 >= -1 and e1 < 0 then c:put(x, y, HEAD[min(6, i + 1)], tok)
      elseif e1 >= 0 and e1 < 1.6 then c:put(x, y, HEAD[max(1, i - 2)], tok)
      elseif e1 >= 0 and e2 >= -1 and e2 < 0 then c:put(x, y, HEAD[min(6, i + 1)], tok)
      elseif e1 >= 0 and e2 >= 0 and e2 < 1.6 then c:put(x, y, HEAD[max(1, i - 2)], tok) end
    end
  end)
  -- one gloss mark (2x1) upper-left
  local bx, by = M.specAt(hm, n, 30)
  c:put(bx, by, "#f4fbd8", tok) c:put(bx + 1, by, HEAD[6], tok)
  c:put(bx - 3, by + 4, "#f4fbd8", tok)
end

-- front wrapper leaves cupping the base
for i, L in ipairs(front) do
  local bias = {}
  local later = HP.mask() for j = i + 1, #front do later:add(front[j][1]) end
  X.ao(bias, L[1], later, 1, -1)
  paintWrap(L, bias, { r = { name = "front" .. i } }, later)
end

-- cut stalk poking out lower-left, pale ringed end
do
  local sm, sn, ST = M.tube({ { 32, 53 }, { 30, 56 }, { 28.5, 58 }, { 27, 60 } }, function(t) return 2.1 end)
  sm:cut(frontAll)
  local tok = { r = { name = "stalk" } }
  M.toneN(c, sm, sn, STALK, { tok = tok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.5, 0.68, 0.85 } })
  local face = c:ellipse(27, 60, 2, 1.3)
  face:each(function(x, y) c:put(x, y, STALK[5], tok) end)
  face:edge():each(function(x, y) if x + y > 87 then c:put(x, y, STALK[3], tok) else c:put(x, y, STALK[4], tok) end end)
  c:put(27, 60, "#a8c070", tok)
end

M.save(c, NAME)
