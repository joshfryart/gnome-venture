-- rhubarb-chutney (final D12, Sonnet high). A squat straight-sided glass jar of dark amber chutney, heaped above the rim,
-- full of glossy pink rhubarb chunks and raisins seen through the glass; rectangular paper label with a rhubarb stalk and
-- leaf; a wooden spoon stands in the heap and lifts a dollop. quirk: a drip is falling from the spoon back onto the heap.
local NAME = "rhubarb-chutney"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local CH   = { "#2e1418", "#522428", "#7e3a30", "#a85a38", "#cd8046", "#eeaa66" }
local PK   = { "#5e1634", "#8e2444", "#c23458", "#e0506a", "#f28aa0", "#ffc4cc" }
local GL   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0e8", "#c6f2f4", "#f0fcff" }
local WOOD = { "#3a2220", "#51302b", "#7a4630", "#a46a40", "#cc9460", "#e8b982" }
local PAP  = { "#a88a6c", "#cdb088", "#e8d0a6", "#f6e6c0", "#fff0d0", "#fff8e4" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.88 }
local CX = 27
local function cylN(m, x0, x1)
  local n = {}
  m:each(function(x, y) local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
  return n
end
-- ---------- jar glass silhouette
local J = HP.mask()
for y = 29, 54 do
  local hw
  if y <= 31 then hw = 10.5 elseif y == 32 then hw = 11.5 elseif y == 33 then hw = 13 elseif y == 34 then hw = 14
  else hw = 14.5 end
  if y >= 50 then local d = y - 50 hw = 14.5 - 4 + sqrt(max(0, 16 - d * d)) end
  for x = floor(CX - hw + 0.5), floor(CX + hw - 0.5) do J:set(x, y) end
end
local inner = J:copy():cut(J:edge()):cut(J:copy():cut(J:edge()):edge())     -- 2 px of glass
inner:each(function(x, y) if y >= 53 or y <= 29 then inner.s[K(x, y)] = nil end end)
-- glass paint (whole jar first, contents go over it)
do
  local gn = cylN(J, CX - 14.5, CX + 14.5)
  X.tone(c, J, X.light(gn, { amb = 0.2, wrap = 0.5 }), GL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
end
-- ---------- contents + heap
local M = G.rell(CX, 29.5, 1, 0, 11.4, 5.2):add(G.rell(22, 27.6, 1, 0, 4.4, 3.2)):add(G.rell(32, 27.2, 1, 0, 4.6, 3.3)):cut(HP.rect(0, 31, 63, 63))
local Cm = inner:copy():add(M)
local tokC = { r = { name = "chutney" } }
local nC = cylN(Cm, CX - 13, CX + 13)
local nM = X.pillow(M, 4.5, 1.1)
M:each(function(x, y) nC[K(x, y)] = nM[K(x, y)] end)
local biasC = {}
-- shade under the heap overhang, and where the glass base thickens
Cm:each(function(x, y) if y >= 51 then biasC[K(x, y)] = -1 end end)
Cm:each(function(x, y) local k = K(x, y) local h = X.hash(floor(x / 2), floor(y / 2), 6)
  if h > 0.8 then biasC[k] = (biasC[k] or 0) + 1 elseif h < 0.16 then biasC[k] = (biasC[k] or 0) - 1 end end)
local idxC = X.tone(c, Cm, X.light(nC, { amb = 0.04, wrap = 0.12 }), CH, { cuts = { 0.4, 0.58, 0.74, 0.86, 0.95 }, bias = biasC, tok = tokC })
-- label rectangle (clear zone for chunks)
local LX0, LX1, LY0, LY1 = 20, 33, 41, 50
local function inLabel(x, y, m) return x >= LX0 - m and x <= LX1 + m and y >= LY0 - m and y <= LY1 + m end
-- chunks: glossy rhubarb pieces and raisins on a jittered grid
local function put(x, y, ramp, off)
  local k = K(x, y)
  local i = max(1, min(6, (idxC[k] or 3) + (off or 0)))
  c:put(x, y, ramp[i], tokC)
end
local count = 0
for gy = 31.5, 52, 3.1 do
  for gx = 15.5, 39, 3.6 do
    local jx = floor(gx + (X.hash(floor(gx * 3), floor(gy * 3), 2) - 0.5) * 2.4 + .5)
    local jy = floor(gy + (X.hash(floor(gx * 3), floor(gy * 3), 3) - 0.5) * 2.0 + .5)
    local h = X.hash(jx, jy, 8)
    local ok = Cm:has(jx, jy) and Cm:has(jx + 2, jy + 1) and Cm:has(jx - 1, jy) and not inLabel(jx, jy, 1) and not inLabel(jx + 3, jy + 1, 0)
    if ok and jy > 31 and jy < 52 and jx > 17 and jx < 38 then
      if h < 0.62 then
        -- rhubarb chunk 3x2 (+ lit top row)
        for dx = 0, 2 do put(jx + dx, jy, PK, 1) put(jx + dx, jy + 1, PK, -1) end
        put(jx, jy, PK, 2) if X.hash(jx, jy, 4) > 0.5 then put(jx + 1, jy + 1, PK, 0) end
        put(jx + 3, jy + 1, PK, -2)
      else
        for dx = 0, 1 do for dy = 0, 1 do put(jx + dx, jy + dy, { "#2a1426", "#4a2a42", "#6a3e5a", "#86566e", "#a8788c", "#d0a0b0" }, (dy == 0 and dx == 0) and 3 or 0) end end
        c:px(jx, jy, "#c8a0b4")
      end
      count = count + 1
    end
  end
end
-- chunks on the heap
for _, q in ipairs{ { 22, 28, "p" }, { 28, 26, "p" }, { 33, 28, "r" }, { 25, 30, "r" }, { 30, 29, "p" }, { 36, 30, "p" }, { 19, 30, "p" } } do
  local x, y = q[1], q[2]
  if M:has(x, y) and M:has(x + 2, y + 1) then
    if q[3] == "p" then
      for dx = 0, 2 do put(x + dx, y, PK, 2) put(x + dx, y + 1, PK, -1) end
      put(x, y, PK, 3)
    else for dx = 0, 1 do for dy = 0, 1 do put(x + dx, y + dy, { "#2a1426", "#4a2a42", "#6a3e5a", "#86566e", "#a8788c", "#d0a0b0" }, dy == 0 and 3 or 1) end end end
  end
end
-- glaze: bright sticky shine on the heap
c:px(22, 25, "#fff0c8") c:px(23, 25, "#fff0c8") c:px(21, 26, CH[6]) c:px(24, 24, CH[6])

-- ---------- glass details: lit left wall streak, base light, rim lip
for y = 36, 49 do if (y ~= 41 and y ~= 42) then c:put(CX - 12, y, GL[6]) end end
c:put(CX - 12, 51, GL[5]) c:put(CX - 11, 52, GL[5])
for y = 40, 46 do c:put(CX + 12, y, GL[3]) end
for x = CX - 9, CX + 8 do if J:has(x, 53) then c:put(x, 53, (x % 3 == 0) and GL[5] or GL[4]) end end
c:put(CX - 10, 29, GL[5]) c:put(CX - 9, 29, GL[6]) c:put(CX + 10, 29, GL[3])
for x = CX - 11, CX - 10 do c:put(x, 30, GL[5]) end
c:put(CX + 11, 30, GL[2])
-- glass rim (front lip) either side of the heap
for x = CX - 11, CX + 11 do
  local col = (x < CX - 1) and GL[5] or GL[3]
  if J:has(x, 29) and not M:has(x, 29) then c:put(x, 29, col) end
end
-- ---------- label
do
  local lab = HP.rect(LX0, LY0, LX1, LY1)
  for _, p in ipairs{ { LX0, LY0 }, { LX1, LY0 }, { LX0, LY1 } } do lab.s[K(p[1], p[2])] = nil end
  local ln = {}
  lab:each(function(x, y) local t = max(-.97, min(.97, ((x - 27) / 14) * 2 - 0)) ln[K(x, y)] = { t * 0.75, 0, sqrt(1 - (t * 0.75)^2) } end)
  X.tone(c, lab, X.light(ln, { amb = 0.2, wrap = 0.4 }), PAP, { cuts = { 0.3, 0.45, 0.6, 0.78, 0.9 } })
  lab:edge():each(function(x, y) if y == LY0 or y == LY1 then c:put(x, y, PAP[2]) end end)
  for x = LX0 + 1, LX1 - 1 do c:put(x, LY1, PAP[1]) end
  -- rhubarb stalk + leaf icon
  for _, q in ipairs{ { 22, 48 }, { 23, 47 }, { 24, 46 }, { 25, 45 }, { 26, 44 } } do
    c:put(q[1], q[2], "#c23458") c:put(q[1] + 1, q[2], "#e0506a") c:put(q[1], q[2] + 1, "#8e2444")
  end
  for _, q in ipairs{ { 27, 42, 3 }, { 28, 42, 4 }, { 29, 42, 4 }, { 27, 43, 3 }, { 28, 43, 4 }, { 29, 43, 5 }, { 30, 43, 3 }, { 28, 44, 2 }, { 29, 44, 3 } } do
    c:put(q[1], q[2], ({ "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" })[q[3]])
  end
  -- text dashes
  for _, q in ipairs{ { 28, 46, 4 }, { 28, 48, 3 } } do for dx = 0, q[3] - 1 do c:put(q[1] + dx, q[2], PAP[1]) end end
  c:put(30, 47, PAP[1])
  -- peeling corner (quirk-adjacent detail)
  c:put(LX1, LY1, PAP[5]) c:put(LX1 - 1, LY1, PAP[3])
end
-- ground shadow
c:groundShadow(CX + 1, 55, 16, 2)

-- ---------- spoon (drawn last: stands in the heap, lifts a dollop); drip falls beside it
do
  local W = { "#5a3828", "#7e4e32", "#aa7040", "#cf9860", "#ecc088", "#fbe2b0" }
  local tok = { r = { name = "spoon" } }
  local hm, hn, hT, hS = G.tube({ { 32, 28.5 }, { 30.4, 24.5 }, { 28.9, 20.5 }, { 27.3, 16.4 } }, function(t) return 1.5 - 0.35 * t end)
  X.tone(c, hm, X.light(hn, { amb = 0.1, wrap = 0.25 }), W, { cuts = CUTS, tok = tok })
  hm:each(function(x, y) local k = K(x, y)
    if abs(hS[k] - 0.2) < 0.12 and hT[k] > 0.1 and X.hash(x, y, 2) > 0.25 then c:put(x, y, W[3], tok) end   -- grain
  end)
  -- chutney smear where the handle enters the heap
  for _, q in ipairs{ { 30, 28, 5 }, { 31, 27, 4 }, { 32, 27, 3 }, { 33, 28, 3 }, { 30, 27, 4 }, { 31, 28, 3 } } do c:put(q[1], q[2], CH[q[3]], tokC) end
  -- bowl (face on) and dollop
  local ax, ay = -0.36, -0.93
  local bm = G.rell(25.4, 11.4, ax, ay, 5.3, 3.6)
  X.tone(c, bm, X.light(X.pillow(bm, 2.2), { amb = 0.1, wrap = 0.3 }), W, { cuts = CUTS, tok = tok })
  local dm = G.rell(25.0, 10.2, ax, ay, 3.5, 2.1)
  G.toneN(c, dm, X.pillow(dm, 2.0), CH, { cuts = { 0.3, 0.46, 0.62, 0.76, 0.9 }, amb = 0.06, wrap = 0.2 })
  -- pink chunk + glints in the dollop
  for dx = 0, 1 do c:px(25 + dx, 9, PK[4]) c:px(26 + dx, 10, PK[3]) end
  c:px(25, 8, PK[5])
  c:px(24, 7, CH[6]) c:px(25, 7, "#fff0c8")
  -- quirk: a string of chutney slides off the bowl and a drop falls toward the heap
  for _, q in ipairs{ { 21, 14, 4 }, { 21, 15, 3 }, { 21, 16, 3 }, { 21, 17, 4 } } do c:px(q[1], q[2], CH[q[3]]) end
  c:px(22, 13, CH[3])
  local dr = G.rell(21, 20.2, 0, 1, 2.0, 1.4)
  G.toneN(c, dr, X.pillow(dr, 1.4), CH, { cuts = { 0.3, 0.46, 0.62, 0.76, 0.9 }, amb = 0.06, wrap = 0.2 })
  c:px(20, 19, "#fff0c8")
end
G.save2(c, NAME)
