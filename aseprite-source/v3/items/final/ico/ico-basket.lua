-- ico-basket (final, Opus). Wicker market basket, tapered round body seen a little from above, a twisted rope
-- rim, and one slim twisted arch handle bound to the rim with a few wraps.
-- Material: per-pixel cone light (6-tone willow), basket weave (weavers pass over/under stakes, each weaver
-- lit on top and dark underneath, stakes peeking through dark), twisted rim and handle (diagonal lit/dark twist),
-- dark interior with the back wall weave, AO under the rim, binding wraps where the handle meets the rim.
-- quirk: the corner of a red gingham napkin is flopping out over the front rim.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-basket")
local WIL = { "#4e2a22", "#7a4628", "#a26a34", "#c68e44", "#e2b462", "#f6d890" }
local ROPE = { "#5a3020", "#86542c", "#b07a3c", "#d4a052", "#eec67a", "#fbe4a6" }
local CHK = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local CRM = { "#c9b49a", "#e8d8bc", "#fff4d6" }

c:groundShadow(32, 56, 16, 2)
local CX, H0, H1, TILT = 31.5, 31, 51, 4
-- handle first (rim and body paint over its feet)
local htok = { r = { name = "handle" } }
local hp = { { CX - 17, H0 + 1 }, { CX - 17, 5 }, { CX + 17, 5 }, { CX + 17, H0 + 1 } }
local hm, hn, HT, HS, hs = A.tube(hp, function() return 1.75 end)
local hidx = A.shade(c, hm, hn, ROPE, { tok = htok, amb = 0.05, wrap = 0.2 })
local LEN = 0
for i = 2, #hs do LEN = LEN + sqrt((hs[i].x - hs[i-1].x)^2 + (hs[i].y - hs[i-1].y)^2) end
hm:each(function(x, y) local k = K(x, y)
  local d = HT[k] * LEN + HS[k] * 2.2
  local f = d / 3 - floor(d / 3)
  if f < 0.3 then A.step(c, hidx, ROPE, x, y, -2, htok) elseif f < 0.55 then A.step(c, hidx, ROPE, x, y, 1, htok) end
end)

-- body
local function wfn(h) return 17.5 - 4.5 * (h - H0) / (H1 - H0) end
local body, bn, BI = A.vessel(CX, H0, H1, wfn, TILT)
local wtok = { r = { name = "wicker" } }
local bias = {}
body:each(function(x, y) local k = K(x, y) local h = BI[k].h
  if h < H0 + 2.2 then bias[k] = -1 end            -- AO under the rim
  if h > H1 - 1.5 then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, body, bn, WIL, { tok = wtok, bias = bias, amb = 0.04, wrap = 0.15, cuts = { 0.14, 0.32, 0.5, 0.67, 0.84 } })
-- weave: rows of weavers (3 px) over/under stakes (angle cells)
local NS, ROW = 12, 3
body:each(function(x, y) local k = K(x, y) local inf = BI[k]
  if inf.h > H1 - 2.5 then return end
  local col = (inf.phi + pi / 2) / (pi / NS)
  local ci, cf = floor(col), col - floor(col)
  local r = (inf.h - H0 - 1) / ROW
  local ri, rf = floor(r), r - floor(r)
  local front = (ci + ri) % 2 == 0           -- weaver in front of the stake
  local dphi = 1 / ((wfn(inf.h) + 0.5) * max(0.2, cos(inf.phi)))
  local pw = dphi / (pi / NS)
  if abs(inf.u) > 0.96 then return end
  if front then
    if rf < 0.34 then A.step(c, idx, WIL, x, y, 1, wtok) elseif rf > 0.67 then A.step(c, idx, WIL, x, y, -1, wtok) end
    if cf > 1 - pw * 0.9 and inf.u < 0.9 then A.step(c, idx, WIL, x, y, -1, wtok) end
  else
    -- stake shows between weavers: narrower vertical strand, dark gaps either side
    if cf < 0.25 or cf > 0.75 then A.step(c, idx, WIL, x, y, -2, wtok)
    elseif cf < 0.5 then A.step(c, idx, WIL, x, y, 0, wtok) else A.step(c, idx, WIL, x, y, -1, wtok) end
  end
end)
-- foot band: a thicker twisted coil at the base
body:each(function(x, y) local k = K(x, y) local inf = BI[k]
  if inf.h > H1 - 2.5 then
    local d = x + inf.h * 1.2
    if d / 3 - floor(d / 3) < 0.34 then A.step(c, idx, WIL, x, y, -1, wtok) end
  end
end)

-- opening: dark interior, back wall weave
local RW = wfn(H0) + 0.5
local open = A.ellM(CX, H0, RW, TILT)
local inner = A.ellM(CX, H0 + 0.3, RW - 2.6, TILT - 1.7)
local itok = { r = { name = "inside" } }
inner:each(function(x, y)
  local col = WIL[2]
  if y >= H0 + 0.5 then col = WIL[1] end
  if y < H0 and ((x + floor(y / 2)) % 4 == 0) then col = WIL[1] end
  c:put(x, y, col, itok)
end)
-- rim: twisted rope ring
local rtok = { r = { name = "rim" } }
local rim = open:copy():cut(inner)
local rn = X.pillow(rim, 1.6)
local ridx = A.shade(c, rim, rn, ROPE, { tok = rtok, amb = 0.06, wrap = 0.25 })
rim:each(function(x, y)
  local ang = math.atan(y - H0, (x - CX) * TILT / RW)
  local d = ang * RW * 0.9 + (y - H0) * 0.5
  local f = d / 2.6 - floor(d / 2.6)
  if f < 0.33 then A.step(c, ridx, ROPE, x, y, -2, rtok) elseif f < 0.55 then A.step(c, ridx, ROPE, x, y, 1, rtok) end
end)
-- binding wraps where the handle meets the rim (3 turns each side)
for _, sx in ipairs{ -1, 1 } do
  local x0 = floor(CX + sx * (RW - 1.2) + 0.5)
  for i = 0, 2 do
    local y = floor(H0 - 4 + i * 2)
    for dx = -1, 1 do
      local x = x0 + dx
      if hm:has(x, y) or rim:has(x, y) then c:put(x, y, (dx == -1) and ROPE[6] or (dx == 0 and ROPE[4] or ROPE[2]), rtok) end
    end
    if hm:has(x0, y + 1) and not rim:has(x0, y + 1) then c:put(x0 - 1, y + 1, ROPE[2], rtok) c:put(x0, y + 1, ROPE[2], rtok) c:put(x0 + 1, y + 1, ROPE[1], rtok) end
  end
end

-- quirk: gingham napkin corner flopped over the front-right rim
local ntok = { r = { name = "napkin" } }
local nap = c:poly{ { CX + 3, H0 - 3 }, { CX + 12, H0 - 2 }, { CX + 11, H0 + 9 }, { CX + 7, H0 + 6 }, { CX + 4, H0 + 3 } }
local nn = X.pillow(nap, 2)
local nv = X.light(nn, { amb = 0.1, wrap = 0.3 })
nap:each(function(x, y) local k = K(x, y)
  local lv = nv[k] or 0.5
  local cx, cy = floor(x / 2) % 2, floor(y / 2) % 2
  local fold = y > H0 + 1 and 0 or 1           -- the part over the rim edge is in shade below the fold
  local t
  if cx == 0 and cy == 0 then t = CHK[(lv > 0.6 and fold == 1) and 3 or 2]
  elseif cx ~= cy then t = (lv > 0.55 and fold == 1) and CHK[4] or CHK[3]
  else t = (lv > 0.55) and CRM[3] or CRM[2] end
  c:put(x, y, t, ntok)
end)
-- fold line where the cloth turns over the rim
for x = CX + 4, CX + 12 do local y = floor(H0 + 1) if nap:has(x, y) then c:put(x, y, CHK[1], ntok) end end

A.save(c, "ico-basket")
