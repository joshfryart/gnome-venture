-- sting (Opus). Tag "poison" (Sting: keeps working). A whole wasp in profile, facing left, in attack pose: its
-- striped abdomen curls down and forward under the body so the stinger points down-left, and a fat drop of acid
-- green venom hangs off the tip with a second drop falling. Seeing the whole insect makes the stinger read as a
-- stinger (not a horn). Material: glossy yellow/black chitin (6-tone each, specular on the abdomen), pale veined
-- wings, thin jointed legs, glowing venom with a cream glint.
-- quirk: the wasp has a cross little eyebrow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = O.new("sting")

local YEL  = { "#7a3a14", "#b4661a", "#e0981e", "#f5c42e", "#ffe066", "#fff3b4" }
local BLK  = { "#1c1424", "#281e30", "#362a40", "#4a3b56", "#6a5a80", "#a594bc" }
local WING = { "#7fa6c8", "#b4d4ea", "#d8eef8", "#eef9ff" }
local VEN  = { "#1f5a3a", "#2f8f3e", "#5ccf3a", "#a8f05a", "#e6ffb0" }
local EYE  = { "#2a1a3a", "#4a2f6a", "#7a5aa8" }

-- wings first (behind the body)
do
  local tok = O.tok("wing")
  for i, w in ipairs{ { 38, 13, 11, 4, -0.5 }, { 34, 16, 8, 3, -0.2 } } do
    local m = O.oval(w[1], w[2], w[3], w[4], w[5])
    m:each(function(x, y)
      local col = i == 1 and WING[3] or WING[2]
      c:put(x, y, col, tok)
    end)
    -- veins: a line along the long axis + one cross vein
    local ca, sa = cos(w[5]), sin(w[5])
    for t = -w[3] + 2, w[3] - 2 do
      local x, y = floor(w[1] + ca * t + .5), floor(w[2] + sa * t + 0.5 + (i == 1 and 0 or 0))
      if m:has(x, y) then c:put(x, y, WING[1], tok) end
    end
    if i == 1 then
      -- lit leading edge
      m:each(function(x, y) if not m:has(x, y - 1) and x < w[1] + 6 then c:put(x, y, WING[4], tok) end end)
    end
  end
end

-- abdomen: curls back, down and forward
local AP = { { 32, 29 }, { 49, 25 }, { 52, 45 }, { 37, 47 } }
local ab, an, AT, AS = O.tube(AP, function(t)
  if t > 0.97 then return 0 end
  return t < 0.08 and 2.5 + t * 60 or (7.6 - 6.2 * ((t - 0.08) / 0.92) ^ 1.9)
end)
local aidxY, aidxB
do
  local tY, tB = O.tok("abY"), O.tok("abB")
  local yel, blk = HP.mask(), HP.mask()
  ab:each(function(x, y) local k = K(x, y)
    local t = AT[k] + AS[k] * 0.02
    local band = floor((t - 0.1) * 7.5)
    if t < 0.1 or band % 2 == 1 then blk:set(x, y) else yel:set(x, y) end
  end)
  aidxY = O.shade(c, yel, an, YEL, { tok = tY, amb = 0.1, wrap = 0.3 })
  aidxB = O.shade(c, blk, an, BLK, { tok = tB, amb = 0.1, wrap = 0.3 })
  -- glossy specular streak along the upper back of the curl
  local sp = X.spec(an, 30)
  ab:each(function(x, y) local k = K(x, y) if sp[k] > 0.72 and AT[k] < 0.55 then
    c:put(x, y, yel:has(x, y) and YEL[6] or BLK[6], yel:has(x, y) and tY or tB) end end)
end

-- stinger: dark tapered needle from the tip, pointing down-left
local sx, sy = O.bez(AP, 0.97)
do
  local tok = O.tok("stinger")
  local m, n, T, S = X.cyl(sx + 1, sy, sx - 8, sy + 4, function(t) return 1.3 * (1 - t) + 0.2 end)
  local idx = O.shade(c, m, n, BLK, { tok = tok, amb = 0.15 })
  m:each(function(x, y) local s = S[K(x, y)] if s < -0.3 then O.set(c, idx, BLK, x, y, 5, tok) end end)
end

-- legs (thin, jointed), hanging from the thorax
do
  local tok = O.tok("legs")
  for _, L in ipairs{
    { { 24, 29 }, { 21, 35 }, { 23, 40 } },
    { { 27, 30 }, { 27, 36 }, { 30, 41 } },
    { { 30, 29 }, { 33, 34 }, { 36, 37 } },
  } do
    local m = c:line(L, 1)
    m:each(function(x, y) c:put(x, y, BLK[3], tok) end)
    c:put(L[2][1], L[2][2], BLK[5], tok)
  end
end

-- thorax
local thx, thn = O.oval(27, 24, 6.5, 5.5, -0.3)
local tidx = O.shade(c, thx, thn, BLK, { tok = O.tok("thorax"), amb = 0.1, wrap = 0.2 })
-- yellow shoulder mark
O.map(c, { ".yy", "yyh", ".y." }, 24, 20, { y = YEL[4], h = YEL[5] }, O.tok("thorax"))
c:put(25, 20, YEL[6], O.tok("thorax"))
-- petiole (wasp waist) AO
for _, p in ipairs{ { 32, 27 }, { 33, 28 } } do if thx:has(p[1], p[2]) then O.step(c, tidx, BLK, p[1], p[2], -1, O.tok("thorax")) end end

-- head
local hd, hn = O.oval(16, 24, 6.5, 6, 0.15)
local hidx
do
  local tok = O.tok("head")
  hidx = O.shade(c, hd, hn, YEL, { tok = tok, amb = 0.12, wrap = 0.3 })
  -- big compound eye (kidney) on the upper back of the head
  local eye = O.oval(19, 24.5, 2.5, 3.2, 0.25)
  local en = {}
  eye:each(function(x, y) en[K(x, y)] = hn[K(x, y)] or { 0, 0, 1 } end)
  O.shade(c, eye, en, EYE, { tok = O.tok("eye"), amb = 0.2 })
  c:put(18, 22, "#c8b4f0", O.tok("eye")) c:put(18, 23, EYE[3], O.tok("eye"))
  -- quirk: cross eyebrow, angled down toward the front
  O.map(c, { "...bb", "bbb.." }, 15, 19, { b = BLK[1] }, O.tok("brow"))
  -- mandible
  O.map(c, { "dd", "ad", ".d" }, 9, 27, { d = YEL[1], a = YEL[2] }, tok)
end

-- antennae: two curling feelers up and forward
do
  local tok = O.tok("ant")
  for _, A in ipairs{ { { 13, 19 }, { 11, 14 }, { 8, 12 }, { 6, 13 } }, { { 16, 18 }, { 15, 13 }, { 13, 10 }, { 11, 10 } } } do
    for t = 0, 1, 0.02 do
      local x, y = O.bez(A, t)
      c:put(floor(x + .5), floor(y + .5), t > 0.85 and BLK[4] or BLK[2], tok)
    end
  end
end

-- venom: a fat hanging drop at the stinger tip + one falling drop
do
  local tok = O.tok("venom")
  local tx, ty = floor(sx - 8 + .5), floor(sy + 4 + .5)
  O.map(c, {
    "..v...",
    "..vv..",
    ".vvvv.",
    "vcgvvs",
    "vggvvs",
    "vvvvss",
    ".dsss.",
  }, tx - 2, ty, { v = VEN[3], c = VEN[5], g = VEN[4], s = VEN[2], d = VEN[1] }, tok)
  O.map(c, {
    ".v.",
    "vgv",
    "vvs",
    ".s.",
  }, tx - 6, ty + 7, { v = VEN[3], g = VEN[5], s = VEN[2] }, tok)
end

O.save(c, "sting")
