-- rhubarb-cordial (final D12, Sonnet high). A slim swing-top bottle: glass body with a rounded shoulder and long neck,
-- rhubarb-pink cordial with a meniscus, fizz bubbles and a vertical shine, thin wire bail over a white china stopper with a
-- pink band, and an oval paper label with a rhubarb stalk. quirk: one big bubble has escaped and floats beside the stopper.
local NAME = "rhubarb-cordial"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LIQ  = { "#4e1230", "#7e2046", "#b02e5a", "#d84a72", "#f07a9a", "#ffb0c4" }
local GL   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0e8", "#c6f2f4", "#f0fcff" }
local PORC = { "#7c789a", "#a8a6c4", "#cbc9de", "#e4e2f0", "#f4f2fa", "#fffdf6" }
local PAP  = { "#a88a6c", "#cdb088", "#e8d0a6", "#f6e6c0", "#fff0d0", "#fff8e4" }
local ST   = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.88 }
local CX = 30
local function cylN(m, x0, x1)
  local n = {}
  m:each(function(x, y) local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
  return n
end
-- ---------- bottle profile
local function hw(y)
  if y <= 14 then return 4.6 end                     -- lip
  if y <= 24 then return 3.7 end                     -- neck
  if y <= 32 then local t = (y - 24) / 8 return 3.7 + 7.0 * sin(t * pi / 2) ^ 1.3 end
  return 10.7
end
local J = HP.mask()
for y = 13, 55 do
  local h = hw(y)
  if y >= 52 then local d = y - 52 h = 10.7 - 3.6 + sqrt(max(0, 3.6 * 3.6 - d * d * 1.1)) end
  for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do J:set(x, y) end
end
local inner = J:copy():cut(J:edge())
inner:each(function(x, y) if y >= 53 or y < 20 then inner.s[K(x, y)] = nil end end)   -- liquid fill line at y 20
-- glass over everything
X.tone(c, J, X.light(cylN(J, CX - 10.7, CX + 10.7), { amb = 0.22, wrap = 0.5 }), GL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- empty neck above the liquid: pale clear core
J:each(function(x, y) if y < 20 and not J:edge():has(x, y) then c:put(x, y, (x < CX) and GL[5] or GL[4]) end end)
-- ---------- liquid
local tokL = { r = { name = "liquid" } }
local nL = cylN(inner, CX - 9.6, CX + 9.6)
local biasL = {}
inner:each(function(x, y) if y >= 51 then biasL[K(x, y)] = -1 end end)
local idxL = X.tone(c, inner, X.light(nL, { amb = 0.08, wrap = 0.18 }), LIQ, { cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 }, bias = biasL, tok = tokL })
local function lp(x, y, i) if inner:has(x, y) then c:put(x, y, LIQ[i], tokL) end end
-- meniscus: bright row on top of the liquid
for x = CX - 3, CX + 3 do lp(x, 20, 5) end
lp(CX - 3, 20, 6) lp(CX - 2, 20, 6) lp(CX + 3, 20, 3) lp(CX + 2, 21, 3)
-- vertical shine (left) and a thin bounce (right)
for y = 27, 49 do if y % 9 ~= 0 then c:put(CX - 7, y, LIQ[6], tokL) c:put(CX - 6, y, LIQ[5], tokL) end end
lp(CX - 5, 27, 5) lp(CX - 5, 28, 5) lp(CX - 6, 26, 5)
for y = 36, 46 do c:put(CX + 7, y, "#8f6cc8", tokL) end
for x = CX - 6, CX + 6 do if inner:has(x, 52) then c:put(x, 52, (x % 3 == 0) and LIQ[2] or LIQ[3], tokL) end end
-- glass base light and walls
for x = CX - 8, CX + 6 do if J:has(x, 54) then c:put(x, 54, (x % 2 == 0) and GL[5] or GL[4]) end end
for y = 36, 50 do c:put(CX - 10, y, (y % 7 == 0) and GL[5] or GL[6]) end
for y = 22, 29 do c:put(CX - 3, y, GL[6]) end
-- bubbles inside the liquid
local function bub(x, y, r)
  if r == 1 then c:px(x, y, LIQ[6]) c:px(x + 1, y, LIQ[4]) c:px(x, y + 1, LIQ[4]) c:px(x + 1, y + 1, LIQ[3]) return end
  c:px(x + 1, y, LIQ[5]) c:px(x, y + 1, LIQ[5]) c:px(x + 2, y + 1, LIQ[3]) c:px(x + 1, y + 2, LIQ[3])
  c:px(x + 1, y + 1, "#ffd8e4") c:px(x, y, LIQ[6])
end
bub(27, 44, 2) bub(33, 36, 1) bub(31, 29, 1) bub(26, 33, 1) bub(35, 47, 1)
-- ---------- label (oval) with rhubarb stalk
do
  local lab = G.rell(CX, 41.6, 1, 0, 7.4, 6.4)
  local ln = {}
  lab:each(function(x, y) local t = max(-.97, min(.97, (x - CX) / 8)) ln[K(x, y)] = { t * 0.7, 0, sqrt(1 - (t * 0.7)^2) } end)
  X.tone(c, lab, X.light(ln, { amb = 0.2, wrap = 0.4 }), PAP, { cuts = { 0.3, 0.45, 0.6, 0.78, 0.9 } })
  lab:edge():each(function(x, y) c:put(x, y, PAP[2]) end)
  lab:edge():each(function(x, y) if x > CX + 2 or y > 45 then c:put(x, y, PAP[1]) end end)
  for _, q in ipairs{ { 25, 46 }, { 26, 45 }, { 27, 44 }, { 28, 43 }, { 29, 42 }, { 30, 41 }, { 31, 40 } } do
    c:put(q[1], q[2], "#c23458") c:put(q[1] + 1, q[2], "#e0506a") c:put(q[1], q[2] + 1, "#8e2444")
  end
  for _, q in ipairs{ { 32, 38, 4 }, { 33, 38, 5 }, { 32, 39, 3 }, { 33, 39, 4 }, { 34, 39, 3 }, { 33, 40, 2 }, { 34, 40, 3 } } do
    c:put(q[1], q[2], ({ "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" })[q[3]])
  end
  for x = 27, 33 do c:put(x, 47, (x % 2 == 0) and PAP[1] or PAP[2]) end
end
-- ---------- stopper (china) with pink band, and the wire bail
do
  local m = G.rell(CX, 9.6, 1, 0, 5.8, 3.6)
  m:add(HP.rect(CX - 3, 11, CX + 3, 14))
  local n = X.pillow(m, 3.2)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), PORC, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
  for x = CX - 5, CX + 5 do if m:has(x, 11) then c:put(x, 11, (x < CX) and "#f28aa0" or "#d84a72") end end
  for x = CX - 5, CX + 5 do if m:has(x, 12) and x > CX - 4 then c:put(x, 12, (x < CX) and "#d84a72" or "#a02a4a") end end
  c:px(CX - 3, 7, PORC[6]) c:px(CX - 4, 8, PORC[6]) c:px(CX - 2, 6, PORC[5])
  -- wire bail: arch over the stopper, down both sides to a ring on the neck
  local path = { { CX - 7, 21 }, { CX - 7, 13 }, { CX - 7, 10 }, { CX - 5, 6 }, { CX, 4 }, { CX + 5, 6 }, { CX + 7, 10 }, { CX + 7, 13 }, { CX + 7, 21 } }
  for i = 1, #path - 1 do
    local a, b = path[i], path[i + 1]
    local nn = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for s = 0, nn do
      local x, y = floor(a[1] + (b[1] - a[1]) * s / nn + .5), floor(a[2] + (b[2] - a[2]) * s / nn + .5)
      c:put(x, y, (x < CX - 1 or y < 6) and ST[4] or (x > CX + 3 and ST[2] or ST[3]))
    end
  end
  for x = CX - 7, CX + 7 do c:put(x, 21, ST[3]) c:put(x, 22, ST[2]) end
  for x = CX - 7, CX - 2 do c:put(x, 21, ST[4]) end
  c:put(CX + 7, 22, ST[1]) c:put(CX - 7, 22, ST[2])
end
-- squeeze 4 straight neck rows so the bottle stays within the 54 px frame
do
  local Y0, N = 15, 4
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do
    local x, y = i % c.w, i // c.w
    local ny
    if y < Y0 then ny = y elseif y < Y0 + N then ny = nil else ny = y - N end
    if ny then pix[ny * c.w + x] = v own[ny * c.w + x] = c.own[i] end
  end
  c.pix, c.own = pix, own
end
-- ---------- quirk: an escaped bubble
do
  local bm = G.rell(45.5, 12.5, 1, 0, 3.7, 3.7)
  local bn = X.sphere(45.5, 12.5, 3.7, bm)
  X.tone(c, bm, X.light(bn, { amb = 0.3, wrap = 0.6 }), { "#8fc4e8", "#b2dcf0", "#cfe9f4", "#e0f3f8", "#ecf8fa", "#f6fcfc" }, { cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 } })
  bm:edge():each(function(x, y) c:put(x, y, (x + y > 58) and "#5f9ad0" or "#a8d4ee") end)
  c:px(44, 10, "#fffdf6") c:px(45, 10, "#fffdf6") c:px(43, 11, "#fffdf6") c:px(47, 15, "#e4a8d0") c:px(46, 15, "#f0c4e0")
  -- tiny follower bubble
  c:px(49, 18, "#cfe9f4") c:px(50, 18, "#b2dcf0") c:px(49, 19, "#8fc4e8") c:px(50, 19, "#8fc4e8")
end
c:groundShadow(CX + 1, 52, 13, 2)
G.save2(c, NAME)
