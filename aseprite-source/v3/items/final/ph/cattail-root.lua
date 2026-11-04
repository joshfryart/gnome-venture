-- cattail-root (ph, Opus single pass). A slim jointed cattail rhizome lying on a gentle S from lower-left to
-- upper-right: per-pixel cylinder light on a 6-tone buff-pink ramp, pinched nodes every few px with a dark groove,
-- a lit lip and a ragged papery brown leaf-scale collar; fine lengthwise fibre streaks; thin wiry rootlets hanging
-- from the nodes. Left end is cut clean: a pale starchy disc with a ring of spongy air holes (aerenchyma).
-- Right end turns up into a sharp ivory-green shoot bud with a sheath.
-- quirk: a tiny pond snail is hitching a ride on the back of the rhizome.
local NAME = "cattail-root"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local RT = { "#4e3240", "#7a5450", "#a47c66", "#c8a282", "#e4c6a0", "#f6e4c2" }
local SC = { "#3a2226", "#5e3a2c", "#86583a", "#ad7e50" }
local CUT = { "#b8a07a", "#dccaa0", "#f2e6c4", "#fff6de" }
local SH = { "#3f5a3a", "#6e8e52", "#a2bf74", "#cfe09c", "#ecf2c6", "#fffbe2" }
local ROOT = { "#5a3c34", "#8a6650" }

-- rootlets first (behind)
local rtok = A.tok("rootlet")
local function rootlet(x, y, pts)
  local px, py = x, y
  for _, d in ipairs(pts) do
    local nx, ny = px + d[1], py + d[2]
    local n = max(abs(d[1]), abs(d[2]))
    for i = 1, n do c:put(floor(px + d[1] * i / n + .5), floor(py + d[2] * i / n + .5), i % 3 == 0 and ROOT[1] or ROOT[2], rtok) end
    px, py = nx, ny
  end
end
-- rhizome along bezier
local p = { { 11, 45 }, { 22, 36 }, { 34, 46 }, { 48, 33 } }
local NODES = { 0.2, 0.42, 0.63, 0.84 }
local function hw(t)
  local w = 3.9 - t * 0.5
  for _, nt in ipairs(NODES) do local d = abs(t - nt) * 40 if d < 1 then w = w - 0.7 * (1 - d) end end
  return w
end
local rm, rn, RT_, RS, samp = A.tube(p, hw)
for i, nt in ipairs(NODES) do
  local s = samp[floor(nt * 160) + 1]
  local bx, by = floor(s.x + s.px * (s.w + 0.5) + .5), floor(s.y + s.py * (s.w + 0.5) + .5)
  local dirs = { { { -2, 2 }, { 0, 2 }, { -2, 2 }, { -1, 1 } }, nil, { { 1, 2 }, { 2, 2 }, { 0, 2 }, { 2, 1 } }, nil }
  if dirs[i] then rootlet(bx, by, dirs[i]) end
end
-- shoot bud at the right end (drawn before the rhizome so the rhizome caps its base)
local stok = A.tok("shoot")
local sp = { { 46, 35 }, { 50, 30 }, { 51, 24 }, { 54, 16 } }
local sm, sn = A.tube(sp, function(t) return 2.9 * (1 - t) ^ 0.8 + 0.2 end)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), SH, { cuts = A.CUTS, tok = stok })
-- sheath: brown papery wrap on lower part of the shoot
local _, _, ST, SS = A.tube(sp, function(t) return 2.9 * (1 - t) ^ 0.8 + 0.2 end)
sm:each(function(x, y) local k = K(x, y) local t = ST[k]
  if t < 0.3 and SS[k] > -0.2 then c:put(x, y, SC[SS[k] > 0.5 and 2 or 3], stok) end
  if t > 0.29 and t < 0.33 and SS[k] > -0.2 then c:put(x, y, SC[4], stok) end end)
-- rhizome
local bias = {}
X.ao(bias, rm, sm, 1, -1)
local tok = A.tok("rhizome")
local idx = X.tone(c, rm, X.light(rn, { amb = 0.06, wrap = 0.24 }), RT, { cuts = A.CUTS, bias = bias, tok = tok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
rm:each(function(x, y) local k = K(x, y) local t, s = RT_[k], RS[k] local cur = idx[k]
  for _, nt in ipairs(NODES) do
    local d = (t - nt) * LEN + s * s * 1.2
    if d > -0.5 and d < 0.5 then c:put(x, y, RT[max(1, cur - 2)], tok) return
    elseif d >= 0.5 and d < 1.5 and s < 0.3 then c:put(x, y, RT[min(6, cur + 1)], tok) return
    elseif d <= -0.5 and d > -2.6 and s > -0.1 then
      -- ragged papery scale collar on the lower side
      if A.hash(x, y, 5) < 0.75 then c:put(x, y, SC[(s > 0.6) and 1 or (s > 0.3 and 2 or 3)], tok) end return
    end
  end
  -- fibre streaks along the length
  if t > 0.03 and abs(s) < 0.7 and floor(s * 5 + 10) % 2 == 0 and A.hash(floor(t * LEN / 3), floor(s * 5 + 10), 9) < 0.45 then
    c:put(x, y, RT[max(1, cur - 1)], tok) end
end)
-- cool bounce lower-right
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and RS[k] > 0.8 and RT_[k] > 0.05 then
  local inside = false for _, nt in ipairs(NODES) do if abs(RT_[k] - nt) * LEN < 3 then inside = true end end
  if not inside then c:put(x, y, "#9a8aa6", tok) end end end)
-- specular streak on the lit shoulder of the first segment
for _, q in ipairs{ { 0.08, -0.55 }, { 0.1, -0.55 }, { 0.12, -0.55 }, { 0.3, -0.55 }, { 0.32, -0.55 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), RT[6], tok)
end
-- cut end: starchy disc with spongy air holes
local s0 = samp[1]
local ang = math.atan(s0.ty, s0.tx)
local cmk, cnn = A.oval(s0.x - s0.tx * 0.6, s0.y - s0.ty * 0.6, 1.6, 3.7, ang, 1)
local ctok = A.tok("cut")
cmk:each(function(x, y) local k = K(x, y)
  local dx, dy = x - s0.x, y - s0.y
  local v = -dx * s0.ty + dy * s0.tx
  c:put(x, y, v < -1.5 and CUT[4] or (v > 2 and CUT[2] or CUT[3]), ctok) end)
for _, q in ipairs{ { -2, 0 }, { 2, 1 }, { 0, -2 }, { 0, 2 } } do
  local x, y = floor(s0.x - s0.tx + q[1] * 0.0 + .5), floor(s0.y + q[2] + .5)
  if cmk:has(x, y) then c:put(x, y, CUT[1], ctok) end
end
cmk:edge():each(function(x, y) local dx, dy = x - s0.x, y - s0.y if -dx * s0.ty + dy * s0.tx > 1 then c:put(x, y, RT[3], ctok) end end)
-- shoot glint
do local bx, by = A.specAt(sm, sn, 50) if bx then c:put(bx, by, SH[6], stok) end end

-- quirk: pond snail on the back of the rhizome (shell spiral, soft grey body, eye stalks)
local s = samp[floor(0.53 * 160) + 1]
local qx, qy = floor(s.x - s.px * s.w + .5) - 2, floor(s.y - s.py * s.w + .5) - 5
local map = {
  "..e.e.",
  "..b.b.",
  ".SSsb.",
  "SsoSbb",
  "SoSsBB",
  ".SSB..",
}
local SN = { S = "#7a4a3a", s = "#c08a5a", o = "#e8c48a", b = "#9aa0a8", B = "#6a6e7c", e = "#2b1c26" }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SN[ch] then c:put(qx + xx - 1, qy + yy - 1, SN[ch]) end end end
A.save2(c, NAME)
