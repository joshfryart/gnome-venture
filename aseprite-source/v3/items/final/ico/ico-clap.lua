-- ico-clap (final pass, Opus). Two slim hands pressed together mid-clap, thumbs side by side in front, fingers
-- fanning out behind, rolled cloth cuffs at the wrists, three bold gold "clap" rays above.
-- Material: per-pixel pillow light per finger (6-tone skin, warm light / cool-violet shade), knuckle creases,
-- lit nail tips, AO where fingers meet the palm, contact shadow under each thumb; cuffs carry diagonal weave and
-- a lit rolled edge.
-- quirk: the right hand wears a tiny gold ring.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("ico-clap")
local SA = { "#6e3a36", "#9c5a48", "#c98462", "#e6a77c", "#f5c497", "#ffe0bd" }
local SB = { "#45292a", "#6a3f31", "#8a5638", "#a96d47", "#c78b5d", "#e3b07f" }
local CUFF_L = { "#2a4a7a", "#346aa0", "#3f8ac0", "#5fb0d8", "#9adcee", "#c8f2f4" }
local CUFF_R = { "#35295f", "#4a3a88", "#5f4aad", "#7d66cc", "#a48ce2", "#cdb8f4" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

local function mir(pts) local o = {} for i, p in ipairs(pts) do o[i] = { 63 - p[1], p[2] } end return o end

local function hand(skin, cramp, flip, name)
  local tok = A.tok(name)
  local F = function(pts) return flip and mir(pts) or pts end
  local fingers = {
    F{ { 19.5, 33 }, { 18, 23 } },     -- pinky
    F{ { 22.5, 31 }, { 21.5, 17.5 } }, -- ring
    F{ { 26, 30 }, { 26, 14.5 } },     -- middle
    F{ { 29.5, 30 }, { 30, 17 } },     -- index
  }
  local all = HP.mask()
  local fmasks = {}
  for i, f in ipairs(fingers) do
    local fm = A.stroke(f, 1.75)
    fmasks[i] = fm
    local n = X.pillow(fm, 1.8)
    local bias = {}
    -- knuckle crease ~ 55% up the finger, AO at the base
    local cx, cy = f[1][1] + (f[2][1] - f[1][1]) * 0.55, f[1][2] + (f[2][2] - f[1][2]) * 0.55
    fm:each(function(x, y) local k = K(x, y)
      if math.abs(y - floor(cy + 0.5)) == 0 then bias[k] = -1 end
      if y > f[1][2] - 3 then bias[k] = (bias[k] or 0) - 1 end
    end)
    A.shade(c, fm, n, skin, { amb = 0.08, wrap = 0.3, bias = bias, tok = tok })
    -- lit nail tip
    local tx, ty = floor(f[2][1] + 0.5), floor(f[2][2] + 0.5) - 1
    if fm:has(tx, ty) then c:put(tx, ty, skin[6], tok) end
    if fm:has(tx + (flip and 1 or -1), ty) then c:put(tx + (flip and 1 or -1), ty, skin[5], tok) end
    all:add(fm)
  end
  -- separation grooves between neighbouring fingers (earlier finger darkens where the next one overlaps it)
  for i = 1, #fmasks - 1 do
    local nxt = fmasks[i + 1]
    fmasks[i]:each(function(x, y)
      if not nxt:has(x, y) and (nxt:has(x + 1, y) or nxt:has(x - 1, y)) then c:put(x, y, skin[2], tok) end
    end)
  end
  -- palm / back of hand
  local palm = c:poly(F{ { 31, 29 }, { 31, 44 }, { 29, 48 }, { 21, 48 }, { 17.5, 41 }, { 17.5, 33 }, { 22, 30 } })
  local pn = X.pillow(palm, 3.2)
  local pb = {}
  -- AO under the finger bases
  palm:each(function(x, y) local k = K(x, y)
    if all:has(x, y - 1) and not all:has(x, y) then pb[k] = -1 end
    if all:has(x, y) then pb[k] = -1 end
  end)
  -- knuckle ridge: a lit row across the back of the hand
  local pidx = A.shade(c, palm, pn, skin, { amb = 0.1, wrap = 0.3, bias = pb, tok = tok })
  for _, kx in ipairs{ 21, 25, 28 } do
    local x = flip and (63 - kx) or kx
    A.step(c, pidx, skin, x, 33, 1, tok)
  end
  -- thumb in front, along the inner edge
  local th = A.stroke(F{ { 26.5, 43 }, { 29.5, 35 }, { 30.3, 29.5 } }, 1.8)
  th:clip(c:rect(flip and 32 or 0, 0, flip and 63 or 31, 63))
  local tb = {}
  local tn = X.pillow(th, 1.8)
  A.shade(c, th, tn, skin, { amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = tb, tok = tok })
  -- contact shadow of the thumb on the palm (down-right / down-left)
  th:shift(flip and 1 or -1, 1):each(function(x, y) if palm:has(x, y) and not th:has(x, y) then A.step(c, pidx, skin, x, y, -1, tok) end end)
  local nx, ny = F{ { 30, 30 } }[1][1], 30
  c:put(nx, ny, skin[6], tok)
  -- cuff: rolled cloth band at the wrist
  local cuff = c:poly(F{ { 31, 46 }, { 31, 54 }, { 18, 54 }, { 17, 50 }, { 19, 46 } })
  local cn = X.pillow(cuff, 2.4)
  local cb = {}
  cuff:each(function(x, y) local k = K(x, y)
    local xx = flip and (63 - x) or x
    if (xx + y) % 4 == 0 and y > 48 then cb[k] = -1 end   -- diagonal weave
    if y == 48 then cb[k] = (cb[k] or 0) - 1 end           -- under the rolled edge
  end)
  A.shade(c, cuff, cn, cramp, { amb = 0.1, wrap = 0.3, bias = cb, tok = A.tok(name .. "-cuff") })
  return palm, fmasks, tok
end

hand(SA, CUFF_L, false, "handL")
local palmR, fR, tokR = hand(SB, CUFF_R, true, "handR")

-- quirk: tiny gold ring on the right hand's ring finger, just above the knuckle base
local rx = 63 - 21
for _, q in ipairs{ { rx - 1, 26, GOLD[3] }, { rx, 26, GOLD[4] }, { rx + 1, 26, GOLD[2] }, { rx + 1, 27, GOLD[1] } } do
  if fR[2]:has(q[1], q[2]) then c:put(q[1], q[2], q[3], tokR) end
end

-- clap rays: three bold gold dashes
local rt = A.tok("rays")
for _, r in ipairs{ { { 31.5, 5 }, { 31.5, 10 } }, { { 19, 8 }, { 15.5, 4.5 } }, { { 44, 8 }, { 47.5, 4.5 } } } do
  local rm = A.stroke(r, 1.3)
  rm:each(function(x, y)
    local e = not rm:has(x + 1, y) or not rm:has(x, y + 1)
    local l = not rm:has(x - 1, y) or not rm:has(x, y - 1)
    c:put(x, y, l and GOLD[4] or (e and GOLD[2] or GOLD[3]), rt)
  end)
end
A.save(c, "ico-clap")
