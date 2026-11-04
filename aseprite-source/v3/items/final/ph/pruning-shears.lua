-- pruning-shears (D10, Sonnet artist pass). Hand secateurs held open, jaws up-right: a curved bright cutting blade over
-- a dark coated hook jaw, red enamel handles with ribbed rubber grips and a brass leaf-spring between them, crossing at
-- a brass pivot bolt with a slotted head. Steel is lit per pixel with a bright ground edge, a bevel flat and a streak;
-- AO and cast shadow where the halves cross.
-- quirk: a freshly snipped twig tip with two leaves is tumbling off the jaws, its cut end pale.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_3.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("pruning-shears")

local ST  = { "#2a2e4e", "#454c78", "#66709a", "#939dbe", "#c2cae2", "#f2f6ff" }
local ANV = { "#161a30", "#262d4c", "#3a4468", "#556088", "#808cb4", "#b0bce0" }
local RD  = { "#4e1230", "#7e1c36", "#b02c3c", "#d84840", "#f06c52", "#ffa482" }
local RB  = { "#2a1620", "#44222c", "#5e303a", "#7a4650" }
local BR  = { "#5e3a14", "#98631c", "#cc9226", "#eebc40", "#ffe27c", "#fff6b4" }
local LF  = { "#1f4a30", "#2e6a3a", "#468a44", "#68aa50", "#94c866", "#c4e490" }
local TW  = { "#4a2e1c", "#6e4630", "#92603c", "#c0905c", "#e8c690" }
local ttok, stok, rtok, btok = { r = { name = "twig" } }, { r = { name = "steel" } }, { r = { name = "enamel" } }, { r = { name = "brass" } }

-- local frame: u along the jaws, v across (down); rotated so the jaws point up-right
local PX, PY, PH = 33, 34, -0.55
local ca, sa = cos(PH), sin(PH)
local function T(u, v) return PX + u * ca - v * sa, PY + u * sa + v * ca end
local function TP(pts) local o = {} for i, p in ipairs(pts) do local x, y = T(p[1], p[2]) o[i] = { x, y } end return o end

local BL_P  = TP{ { 0, -1 }, { 10, -6 }, { 19, -11 }, { 26, -7.5 } }          -- upper cutting blade
local HK_P  = TP{ { 0, 1 }, { 10, 6 }, { 19, 8.5 }, { 25.5, 4.5 } }            -- lower hook jaw
local H1_P  = TP{ { -4, 1.8 }, { -10, 4.5 }, { -16.5, 7.8 }, { -23, 11 } }     -- handle of the blade half (lower)
local H2_P  = TP{ { -4, -1.8 }, { -10, -4.5 }, { -15.5, -7.2 }, { -21, -10 } } -- handle of the hook half (upper)
local function wBlade(t) return 3.2 * (1 - t) ^ 0.75 + 0.5 end
local function wHook(t) return 2.8 - 1.3 * t ^ 1.4 end
local function wHandle(t) return 1.9 + 0.65 * sin(pi * min(1, t * 1.15)) ^ 0.7 end

local bm, bn, BT, BS = G.tube(BL_P, wBlade, 160)
local km, kn, KT, KS = G.tube(HK_P, wHook, 160)
local h1m, h1n, H1T, H1S = G.tube(H1_P, wHandle, 160)
local h2m, h2n, H2T, H2S = G.tube(H2_P, wHandle, 160)
local whole = c:rect(0, 0, 63, 63)

local function handle(m, n, TT, SS, bias, pts)
  G.toneN(c, m, n, RD, { bias = bias, tok = rtok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local t, s = TT[k], SS[k]
    if bias and bias[k] then return end
    if t > 0.5 then                                       -- ribbed rubber grip
      local ridge = floor(t * 22) % 2 == 0
      c:put(x, y, ridge and (s < 0 and RB[4] or RB[3]) or (s < 0 and RB[3] or RB[2]), rtok)
      if s > 0.8 then c:put(x, y, RB[1], rtok) end
    elseif s > -0.62 and s < -0.38 and t > 0.1 and t < 0.46 then c:put(x, y, RD[6], rtok)   -- enamel streak
    end
  end)
end

-- 1) hook half (behind): jaw + handle, shaded where the blade half crosses it
local kb, h2b = {}, {}
X.ao(kb, km, bm, 1, -1) G.cast(kb, km, bm, 1, 2, -1) X.ao(kb, km, h1m, 1, -1)
X.ao(h2b, h2m, bm, 1, -1) G.cast(h2b, h2m, bm, 1, 2, -1)
G.toneN(c, km, kn, ANV, { bias = kb, tok = stok, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 }, amb = 0.1, wrap = 0.3 })
km:each(function(x, y) local k = K(x, y)
  if kb[k] then return end
  if KS[k] < -0.7 and KT[k] > 0.1 and KT[k] < 0.92 then c:put(x, y, ANV[6], stok)           -- bright lip on the inner (upper) face
  elseif KS[k] < -0.4 and KT[k] > 0.15 and KT[k] < 0.7 and X.hash(x, y, 2) > 0.2 then c:put(x, y, ANV[5], stok) end
  if KS[k] > 0.8 then c:put(x, y, ANV[1], stok) end
end)
handle(h2m, h2n, H2T, H2S, h2b)
local function tang(ex, ey, ramp)
  local pts = TP{ { 0, 0 }, { ex * 0.33, ey * 0.33 }, { ex * 0.66, ey * 0.66 }, { ex, ey } }
  local m, n = G.tube(pts, function() return 1.9 end, 40)
  G.toneN(c, m, n, ramp, { tok = stok })
end
tang(-5, -2, ANV)

-- 2) brass leaf-spring between the handles (zig-zag, with a dark under-line)
do
  local zz = { { -9.5, -3.4 }, { -7, -1.8 }, { -11.5, -0.9 }, { -7, 0.6 }, { -11.5, 1.5 }, { -9.5, 3.4 } }
  local pts = {} for i, p in ipairs(zz) do local x, y = T(p[1], p[2]) pts[i] = { floor(x + 0.5), floor(y + 0.5) } end
  local under = {} for i, p in ipairs(pts) do under[i] = { p[1] + 1, p[2] + 1 } end
  D.line(c, under, BR[1], btok)
  D.line(c, pts, BR[3], btok)
  for i = 1, #pts do local p = pts[i] if i % 2 == 0 then c:put(p[1], p[2], BR[5], btok) end end
end

-- 3) blade half (front): handle, tang, blade with edge bevel
local h1b = {}
G.cast(h1b, h1m, bm, 0, 0, 0)
handle(h1m, h1n, H1T, H1S, nil)
local bb = {}
G.toneN(c, bm, bn, ST, { bias = bb, tok = stok, cuts = { 0.2, 0.38, 0.55, 0.7, 0.85 }, amb = 0.1, wrap = 0.28 })
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  if s > 0.78 and t > 0.1 then c:put(x, y, ST[6], stok)                                      -- sharp ground edge
  elseif s > 0.4 and s <= 0.78 and t > 0.12 then c:put(x, y, ST[4], stok)                    -- bevel flat
  elseif s < -0.78 then c:put(x, y, ST[5], stok) end
  if s > -0.5 and s < -0.28 and t > 0.2 and t < 0.75 and floor(t * 9) % 3 ~= 2 then c:put(x, y, ST[6], stok) end   -- streak
  if s < -0.86 and t > 0.1 then c:put(x, y, ST[2], stok) end
end)
tang(-5, 2, ST)

-- 4) brass pivot bolt, slotted, on top of everything
local px0, py0 = T(0, 0)
local bolt, bn2 = G.oval(px0, py0, 3.1, 3.1, 0, 1.0)
G.toneN(c, bolt, bn2, BR, { tok = btok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1, wrap = 0.3 })
bolt:edge():each(function(x, y) if x + y > px0 + py0 + 1 then c:put(x, y, BR[1], btok) end end)
local bx, by = floor(px0 + 0.5), floor(py0 + 0.5)
D.line(c, { { bx - 1, by + 1 }, { bx + 1, by - 1 } }, BR[1], btok)          -- screw slot
c:put(bx - 1, by - 2, BR[6], btok) c:put(bx - 2, by - 1, BR[6], btok)

-- quirk: snipped twig tumbling off the jaw tips
local twp = TP{ { 3, 16 }, { 6, 17.5 }, { 10, 17 }, { 14, 14 } }
local twm, twn, TT2, TS2 = G.tube(twp, function(t) return 1.3 - 0.2 * t end, 80)
G.toneN(c, twm, twn, TW, { tok = ttok, cuts = { 0.3, 0.55, 0.8, 0.92 }, amb = 0.15, wrap = 0.3 })
local cx0, cy0 = T(3, 16)
c:put(floor(cx0 + 0.5), floor(cy0 + 0.5), TW[5], ttok) c:put(floor(cx0 + 0.5) - 1, floor(cy0 + 0.5), TW[5], ttok)
local function lf(ax, ay, cx, cy, bx, by, w)
  local m, n, TTT, SSS = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7) end, { fold = 0.35 })
  G.toneN(c, m, n, LF, { tok = { r = { name = "leaf" } }, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(SSS[k]) < 0.18 and TTT[k] > 0.1 and TTT[k] < 0.9 then c:put(x, y, SSS[k] <= 0 and LF[6] or LF[3]) end end)
  return m
end
local tx, ty = T(8, 17.5)
lf(tx, ty, tx - 1, ty + 4, tx - 4, ty + 7, 2.3)
local ux, uy = T(12, 16)
lf(ux, uy, ux + 2, uy + 4, ux + 3, uy + 7, 2.0)
D.save(c, "pruning-shears")
