-- ico-bucket (final, Opus). Slim staved wooden bucket, wider at the mouth, seen a little from above, two iron
-- hoops, an iron bail handle on riveted ear lugs with a turned wooden grip, water inside.
-- Material: per-pixel cone light (6-tone pine), stave grooves with a lit lip, grain dashes, pale end grain on the
-- rim, dark inner wall, 6-tone water with a ripple and glint; iron with a lit top edge, rivets and a specular streak;
-- AO under the hoops, under the rim and where the bail meets the lugs; cool reflected light on the right.
-- quirk: a knot hole low on the right has sprung a leak, a thin jet and a falling drop.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-bucket")
local PINE = { "#4e2a28", "#74402c", "#9c5c34", "#c47e44", "#e0a35e", "#f4c98c" }
local END  = { "#8a5636", "#b07a4c", "#d3a06a", "#ecc48e", "#fbe0b0" }
local IRON = { "#29283a", "#403f58", "#5c5e7a", "#7f84a0", "#aab0c6", "#dde2ee" }
local WATER = { "#233f6e", "#2f5f94", "#3a86b0", "#4fa9c2", "#7fd0d4", "#c2f2e6" }
local GRIP = { "#51302b", "#7a4630", "#a86a3e", "#cc8f52", "#ecba7c" }
local BOUNCE = "#6e4a62"

c:groundShadow(32, 55, 15, 2)
local CX, H0, H1, TILT = 31.5, 25, 51, 3.6
local function wfn(h) local t = (h - H0) / (H1 - H0) return 13.2 - 3.0 * t end
local LW = wfn(H0) + 0.5

-- bail handle (behind the body): 3 px iron arc between the ears, grip at the top
local EY = H0 + 5
local arc = {}
for i = 0, 40 do
  local a = pi * i / 40
  arc[#arc + 1] = { CX - (LW + 0.6) * cos(a), EY - 17 * sin(a) ^ 0.85 }
end
local bail = A.stroke(arc, 1.25)
local itok = { r = { name = "iron" } }
local bn = X.pillow(bail, 1.5)
A.shade(c, bail, bn, IRON, { tok = itok, amb = 0.05, wrap = 0.2 })
-- grip: turned wood dowel over the top of the bail
local grip = A.HP.mask()
local GY = EY - 17
for y = GY - 3, GY + 3 do for x = floor(CX - 5), floor(CX + 5) + 1 do
  local dx = (x - CX) / 6
  local e = abs(dx) > 0.8 and 1 or 0
  if y >= GY - 2 + e and y <= GY + 2 - e then grip:set(x, y) end
end end
local gn = {}
grip:each(function(x, y) local s = (y - GY) / 2.6 gn[K(x, y)] = { A.norm((x - CX) / 18, s, sqrt(max(0.05, 1 - s * s))) } end)
local gtok = { r = { name = "grip" } }
local gidx = A.shade(c, grip, gn, GRIP, { tok = gtok, amb = 0.05, wrap = 0.2 })
-- grain dash + ends darker where they bind the iron
for _, p in ipairs{ { -2, -1 }, { -1, -1 }, { 2, 1 }, { 3, 1 } } do A.step(c, gidx, GRIP, floor(CX + p[1]), GY + p[2], -1, gtok) end
for y = GY - 3, GY + 3 do for _, x in ipairs{ floor(CX - 5), floor(CX + 5) + 1 } do A.step(c, gidx, GRIP, x, y, -1, gtok) end end

-- body
local body, bnn, BI = A.vessel(CX, H0, H1, wfn, TILT)
local ptok = { r = { name = "pine" } }
local bias = {}
local HOOPS = { { 29, 32 }, { 45.5, 48.5 } }
body:each(function(x, y) local k = K(x, y) local h = BI[k].h
  for _, hp in ipairs(HOOPS) do if h > hp[2] and h < hp[2] + 1.5 then bias[k] = -1 end end
  if h < H0 + 1.5 then bias[k] = (bias[k] or 0) - 1 end
  if h > H1 - 1.2 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, body, bnn, PINE, { bias = bias, tok = ptok, amb = 0.03, wrap = 0.14, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 } })
local NS, OFF = 7, 0.52
body:each(function(x, y) local k = K(x, y) local inf = BI[k]
  local f = (inf.phi + pi / 2) / (pi / NS) + OFF
  local fr = f - floor(f)
  local pw = 1 / ((wfn(inf.h) + 0.5) * max(0.15, cos(inf.phi))) / (pi / NS)
  if abs(inf.u) < 0.92 then
    if fr < pw * 0.95 then A.step(c, idx, PINE, x, y, -2, ptok)
    elseif fr < pw * 1.9 and inf.u < -0.3 and inf.u > -0.8 then A.step(c, idx, PINE, x, y, 1, ptok)
    else
      local st = floor(f)
      local g = fr - (0.4 + 0.3 * X.hash(st, 5, 2))
      if abs(g) < pw * 0.5 and X.hash(st, floor(inf.h / 3), 9) > 0.6 then A.step(c, idx, PINE, x, y, -1, ptok) end
    end
  end
end)
body:each(function(x, y) local inf = BI[K(x, y)]
  if not body:has(x + 1, y) and inf.h > 33 and inf.h < 45 then c:put(x, y, BOUNCE, ptok) end end)

-- hoops
for _, hp in ipairs(HOOPS) do
  local hm, hn = HP.mask(), {}
  body:each(function(x, y) local k = K(x, y) local h = BI[k].h
    if h >= hp[1] and h <= hp[2] then hm:set(x, y)
      local t = (h - hp[1]) / (hp[2] - hp[1])
      local nn = bnn[k]
      hn[k] = { A.norm(nn[1] * 1.15, nn[2] + (t < 0.34 and -0.6 or (t > 0.7 and 0.6 or 0)), nn[3]) }
    end end)
  A.shade(c, hm, hn, IRON, { tok = itok, amb = 0.04, wrap = 0.15 })
  local w = wfn(hp[1])
  for _, ph in ipairs{ -0.66, -0.54, -0.42 } do
    local x = floor(CX + sin(ph) * (w + 0.5) + 0.5)
    local y = floor(hp[1] + TILT * cos(ph) + 0.5)
    if hm:has(x, y) then c:put(x, y, IRON[6], itok) end
  end
end

-- rim: pale end-grain ring, dark inner wall, water
local lid = A.ellM(CX, H0, LW, TILT)
local inner = A.ellM(CX, H0 + 0.3, LW - 2.2, TILT - 1.3)
local etok = { r = { name = "end" } }
local ln = X.pillow(lid, 1.6)
local lidx = A.shade(c, lid, ln, END, { tok = etok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
lid:each(function(x, y) if not inner:has(x, y) then
  local u = (x - CX) / LW
  local f = (math.asin(max(-1, min(1, u))) + pi / 2) / (pi / NS) + OFF
  if f - floor(f) < 0.13 and y > H0 then A.step(c, lidx, END, x, y, -2, etok) end
end end)
inner:each(function(x, y) c:put(x, y, PINE[1], ptok) end)
local water = A.ellM(CX, H0 + 1.2, LW - 3.0, TILT - 1.9)
water:clip(inner)
local wtok = { r = { name = "water" } }
local wn = {}
water:each(function(x, y) local dx = (x - CX) / LW wn[K(x, y)] = { A.norm(dx * 0.9, -0.15, 1) } end)
local widx = A.shade(c, water, wn, WATER, { tok = wtok, amb = 0.2, wrap = 0.3, cuts = { 0.25, 0.45, 0.62, 0.78, 0.92 } })
-- back-wall shadow on the water (rows nearest the far rim) and a ripple ring
water:each(function(x, y) if not water:has(x, y - 1) then A.step(c, widx, WATER, x, y, -2, wtok) end end)
for _, p in ipairs{ { -6, 0 }, { -5, 0 }, { -4, 0 }, { 2, 1 }, { 3, 1 }, { 4, 1 }, { 5, 1 } } do
  local x, y = floor(CX + p[1]), floor(H0 + 1 + p[2])
  if water:has(x, y) then c:put(x, y, WATER[5], wtok) end
end
c:put(floor(CX - 5), floor(H0), WATER[6], wtok)

-- ear lugs: riveted iron plates over the bail ends
for _, sd in ipairs{ -1, 1 } do
  local ex = floor(CX + sd * (wfn(EY - 1) - 0.6) + 0.5)
  local lug = c:rrect(ex - 2, EY - 3, ex + 2, EY + 3, 1)
  lug:clip(body:copy():add(bail))
  local lnn = X.pillow(lug, 1.6)
  local lidx2 = A.shade(c, lug, lnn, IRON, { tok = itok, amb = 0.05, wrap = 0.2 })
  c:put(ex, EY - 1, IRON[sd < 0 and 6 or 5], itok) c:put(ex, EY, IRON[1], itok)
  -- AO on the stave just below the lug
  for x = ex - 2, ex + 2 do if body:has(x, EY + 4) and not lug:has(x, EY + 4) then A.step(c, idx, PINE, x, EY + 4, -1, ptok) end end
end

-- quirk: leaking knot hole low on the right, thin jet and a drop
local kx, ky = floor(CX + 9), 39
A.map(c, { ".k.", "kKk", ".k." }, kx - 1, ky - 1, { k = PINE[2], K = A.INK }, ptok)
A.map(c, {
  "hs....",
  "..hs..",
  "....s.",
  ".....s",
  "......",
  "....hS",
  "....SS",
}, kx + 1, ky, { h = WATER[6], s = WATER[4], S = WATER[3] }, wtok)

A.save(c, "ico-bucket")
