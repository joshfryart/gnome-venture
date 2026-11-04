-- shale-chip (D15 redraw, single pass). A broken shard of shale seen from above-front: an angular, elongated slab, top
-- face bevelled and tilted to the light, with fine fissile seams along the grain and a conchoidal bite out of the right
-- edge plus a dark crack. The front edge is a stack of thin laminae in cool slate, plum-grey and one rust-stained
-- band, each with a lit ledge; the right end splinters into two projecting flakes. A small flying chip and a speck
-- of dust sit at the lower right, ground shadow under the shard.
-- quirk: a tiny ammonite fossil is pressed into the top face (spiral ribs, raised rim).
local NAME = "shale-chip"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local SL = { "#2b2d42", "#43465f", "#5e627f", "#7b809c", "#9ba0b8", "#c3c7d8" }
local SD = { "#241f33", "#38304a", "#4e4560", "#6b5f78", "#8a7e92", "#b0a5b0" }
local BRW = { "#3a2630", "#5a3a40", "#7e5650", "#a07468", "#c49384", "#e0b9a8" }
local T = 7

c:groundShadow(32, 47.5, 23, 3)

local top = c:poly{ { 9, 35 }, { 13, 25 }, { 27, 17 }, { 46, 15 }, { 55, 21 }, { 52, 29 }, { 46, 32 }, { 48, 35 },
                    { 40, 38 }, { 29, 39 }, { 18, 40 } }
local body = HP.mask()
for dy = 0, T do body:add(top:shift(0, dy)) end
local side = body:copy():cut(top)
local ymax = {}
top:each(function(x, y) if not ymax[x] or y > ymax[x] then ymax[x] = y end end)

-- front edge: laminae ---------------------------------------------------------------------------------------
local stk = { r = { name = "side" } }
local BANDS = {
  { SL, 3, 2 }, { SD, 2, 1 }, { SL, 2, 2 }, { BRW, 2, 1 }, { SD, 3, 1 }, { SL, 1, 2 }, { SD, 2, 1 }, { SL, 2, 1 },
}
local function bandAt(dd)
  local acc = 0
  for i, b in ipairs(BANDS) do
    acc = acc + b[3]
    if dd < acc then return b, dd == acc - b[3] end
  end
  return BANDS[#BANDS], false
end
side:each(function(x, y)
  local d = y - (ymax[x] or y)
  local dd = d + floor(x * 0.07) + floor(X.hash(floor(x / 4), 0, 3) * 2)
  local b, first = bandAt((dd - 1) % 12)
  local i = b[2]
  if first then i = i + 1 end
  if x > 44 then i = i - 1 end
  if d >= T then i = 1 end
  c:put(x, y, b[1][max(1, min(6, i))], stk)
end)
-- projecting splinter flakes at the broken right end
local function flake(pts, w)
  local m = c:line(pts, w)
  m:cut(top)
  m:each(function(x, y)
    local up = not m:has(x, y - 1)
    c:put(x, y, up and SD[5] or SD[2], stk)
  end)
  c:put(pts[#pts][1], pts[#pts][2], SD[3], stk)
end
flake({ { 53, 26 }, { 58, 25 } }, 2)
flake({ { 52, 29 }, { 57, 30.5 } }, 2)

-- top face --------------------------------------------------------------------------------------------------
local tn = X.pillow(top, 2.2)
local v = X.light(tn, { amb = 0.12, wrap = 0.35 })
for k, val in pairs(v) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  v[k] = max(0, min(1, val + 0.28 - 0.0055 * (x + y - 35)))
end
local ttok = { r = { name = "top" } }
local tidx = X.tone(c, top, v, SL, { cuts = { 0.26, 0.42, 0.58, 0.74, 0.88 }, tok = ttok })
-- fissile seams along the grain (dashed, so they never run edge to edge)
top:each(function(x, y) local k = K(x, y)
  local u = y + floor(0.3 * x)
  local i = tidx[k]
  if X.hash(u, 0, 5) > 0.55 and X.hash(floor(x / 4), u, 8) > 0.32 and top:shrink(1):has(x, y) then c:put(x, y, SL[max(1, i - 1)], ttok)
  elseif X.hash(u - 1, 0, 9) > 0.82 and X.hash(floor(x / 5), u, 2) > 0.4 then c:put(x, y, SL[min(6, i + 1)], ttok) end
end)
-- conchoidal bite: lit lip above the notch, shadow below
local bite = HP.mask()
for _, q in ipairs{ { 47, 33 }, { 48, 34 }, { 49, 33 }, { 46, 32 }, { 47, 34 } } do if top:has(q[1], q[2]) then bite:set(q[1], q[2]) end end
-- crack from the right edge inward, with a lit shoulder
local crack = c:line({ { 53, 22 }, { 49, 24 }, { 50, 26 }, { 45, 27 }, { 43, 29 } }, 1):clip(top)
crack:each(function(x, y) c:put(x, y, SL[1], ttok) end)
crack:each(function(x, y) if top:has(x - 1, y - 1) and not crack:has(x - 1, y - 1) then c:put(x - 1, y - 1, SL[5], ttok) end end)

-- fossil ammonite (quirk) ----------------------------------------------------------------------------------
local fx, fy, sq = 27, 27.5, 0.78
top:each(function(x, y) local k = K(x, y)
  local dx, dy = x - fx, (y - fy) / sq
  local rho = sqrt(dx * dx + dy * dy)
  local i = tidx[k]
  if rho < 5.6 then
    local th = math.atan(dy, dx)
    local p = rho / 2.1 + th / (2 * pi)
    local f = p - floor(p)
    if rho < 1.3 then c:put(x, y, SL[min(6, i + 1)], ttok)
    elseif f < 0.5 then c:put(x, y, SL[min(6, i + 1)], ttok)
    else c:put(x, y, SL[max(1, i - 2)], ttok) end
  elseif rho < 6.7 then
    if (dx + dy) > 0 then c:put(x, y, SL[max(1, i - 1)], ttok) else c:put(x, y, SL[min(6, i + 1)], ttok) end
  end
end)
-- a stain where the plum band meets the top edge
for _, q in ipairs{ { 14, 33 }, { 15, 34 }, { 16, 34 } } do if top:has(q[1], q[2]) then c:put(q[1], q[2], BRW[4], ttok) end end

-- flying chip -----------------------------------------------------------------------------------------------
local chip = c:poly{ { 51, 44 }, { 57, 43 }, { 58, 49 }, { 54, 52 }, { 50, 50 } }
local cn = X.pillow(chip, 1.8)
local ctok = { r = { name = "chip" } }
A.toneN(c, chip, cn, SL, { tok = ctok, cuts = { 0.3, 0.46, 0.62, 0.78, 0.9 }, amb = 0.1, wrap = 0.3 })
c:put(53, 47, SL[2], ctok) c:put(54, 48, SL[2], ctok) c:put(55, 49, SL[1], ctok)
c:put(52, 45, SL[6], ctok) c:put(53, 45, SL[5], ctok)
-- dust specks
c:put(47, 44, SL[4], ctok) c:put(48, 44, SL[3], ctok) c:put(49, 53, SL[3], ctok) c:put(48, 52, SL[2], ctok)

A.save2(c, NAME)
