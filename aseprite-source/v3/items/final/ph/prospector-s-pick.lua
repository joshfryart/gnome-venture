-- prospector-s-pick (D10, Sonnet artist pass). Slim wooden haft with long grain, a leather wrap under the head and a
-- flared butt; an arched cool-violet steel head (pick point one side, flat chisel the other) lit per pixel, with a bright
-- ground bevel along the top, a streaked specular, a cool bounce on the underside and the haft's end grain showing
-- through the eye. AO on the haft where the head sits.
-- quirk: a lump of gold ore is skewered on the pick point.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_3.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("prospector-s-pick")

local WD = { "#34190f", "#5a3320", "#85532b", "#ab7640", "#cf9a5c", "#efc78c" }
local ST = { "#2a2e4e", "#454c78", "#66709a", "#939dbe", "#c2cae2", "#f2f6ff" }
local GOLD = { "#6e3f10", "#a9701a", "#d9a02a", "#f4c944", "#ffe370", "#fff7b4" }
local LEA = { "#2e150f", "#522a1c", "#7a4326", "#a0602f" }
local BOUNCE = "#6a78b8"
local wtok, stok, gtok = { r = { name = "wood" } }, { r = { name = "steel" } }, { r = { name = "gold" } }

-- head: bezier arch from chisel end (left) to the pick point (right)
local HPTS = { { 14, 31 }, { 23, 10 }, { 44, 8 }, { 54, 23 } }
local function hw(t)
  if t < 0.14 then return 3.2 - 1.0 * (t / 0.14) end         -- chisel flare
  if t < 0.44 then return 2.2 + 1.7 * sin((t - 0.14) / 0.30 * pi / 2) end
  return 3.9 * (1 - (t - 0.44) / 0.56) ^ 0.9 + 0.35
end
local hm, hn, HT, HS = G.tube(HPTS, hw, 200)
-- flat chisel face: drop pixels behind the start line
do local tx, ty = 0.39, -0.92
  local cut = {}
  hm:each(function(x, y) if (x - 14) * tx + (y - 31) * ty < 0.4 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do hm.s[k] = nil end
end

-- haft
local FP = { { 33, 12 }, { 30, 27 }, { 26, 41 }, { 23, 54 } }
local function fw(t) return 1.75 + 0.35 * t + (t > 0.87 and 1.0 * (t - 0.87) / 0.13 or 0) end
local fm, fn, FT, FS, fsm = G.tube(FP, fw, 200)
local fb = {}
X.ao(fb, fm, hm, 2, -1) G.cast(fb, fm, hm, 1, 2, -1)
G.toneN(c, fm, fn, WD, { bias = fb, tok = wtok, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, amb = 0.12, wrap = 0.3 })
local flen = 42
fm:each(function(x, y) local k = K(x, y)
  local t, s = FT[k], FS[k]
  if fb[k] then return end
  -- long grain: pale streak on the lit side, dark pores on the shade side, broken by hash
  if s > -0.8 and s < -0.5 and X.hash(x, y, 5) > 0.2 and t > 0.3 then c:put(x, y, WD[5], wtok)
  elseif abs(s - 0.1) < 0.2 and X.hash(x, y, 8) > 0.55 then c:put(x, y, WD[2], wtok)
  elseif abs(s - 0.55) < 0.2 and X.hash(x, y, 9) > 0.5 then c:put(x, y, WD[2], wtok) end
  -- leather wrap under the head, diagonal turns
  if t > 0.09 and t < 0.27 then
    local g = floor((t * flen + s * 1.9) * 0.62)
    local lit = (s < 0)
    c:put(x, y, (g % 2 == 0) and (lit and LEA[4] or LEA[3]) or (lit and LEA[3] or LEA[2]), wtok)
    if t < 0.1 or t > 0.265 then c:put(x, y, LEA[1], wtok) end
  end
  -- flared butt: darker ring just above the knob
  if t > 0.86 and t < 0.885 then c:put(x, y, WD[2], wtok) end
end)
c:put(23, 54, WD[5]) c:put(24, 54, WD[5]) c:put(22, 55, WD[2]) c:put(23, 55, WD[2]) c:put(24, 55, WD[1])   -- butt end grain

-- gold ore on the pick point (painted first so the tip skewers it)
local nm, nn = G.oval(54.6, 26.4, 3.5, 2.9, 0.5, 0.9)
G.toneN(c, nm, nn, GOLD, { tok = gtok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.1, wrap = 0.3 })
for _, p in ipairs{ { 53, 25 }, { 54, 25 } } do c:put(p[1], p[2], GOLD[6], gtok) end
c:put(52, 27, GOLD[5], gtok) c:put(56, 28, GOLD[1], gtok) c:put(55, 29, GOLD[1], gtok) c:put(57, 26, GOLD[2], gtok)
c:put(54, 27, GOLD[2], gtok) c:put(53, 28, GOLD[3], gtok)

-- steel head
local hb = {}
X.ao(hb, hm, fm, 0, 0)
G.toneN(c, hm, hn, ST, { tok = stok, cuts = { 0.2, 0.38, 0.55, 0.7, 0.85 }, amb = 0.1, wrap = 0.28 })
local hedge = hm:edge()
hm:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if s < -0.78 and t > 0.06 and t < 0.9 then c:put(x, y, ST[6], stok)                   -- ground bevel
  elseif s < -0.5 and s >= -0.78 and t > 0.1 then c:put(x, y, ST[5], stok)
  end
  if s > 0.72 and t > 0.1 and t < 0.85 then c:put(x, y, BOUNCE, stok) end               -- cool bounce underside
  if s > 0.93 then c:put(x, y, ST[1], stok) end
  -- specular streaks (broken)
  if s > -0.45 and s < -0.25 and ((t > 0.2 and t < 0.4) or (t > 0.5 and t < 0.62)) then c:put(x, y, ST[6], stok) end
  -- hammered forge grain
  if s > 0.1 and s < 0.6 and t > 0.1 and X.hash(x, y, 4) > 0.93 then c:put(x, y, ST[2], stok) end
end)
-- chisel face: bright flat edge + dark under-lip
D.line(c, { { 12, 30 }, { 17, 32 } }, ST[6], stok)
D.line(c, { { 13, 31 }, { 18, 33 } }, ST[2], stok)
-- eye socket seam on either side of the haft
for _, p in ipairs{ { 29, 14 }, { 30, 15 }, { 37, 14 }, { 38, 14 } } do if hm:has(p[1], p[2]) then c:put(p[1], p[2], ST[1], stok) end end
-- end grain of the haft through the eye (top)
local eg = G.oval(33.5, 8.2, 2.9, 1.5, 0.05, 0.9)
eg:each(function(x, y) c:put(x, y, WD[5], wtok) end)
for _, p in ipairs{ { 32, 8 }, { 33, 8 }, { 34, 8 } } do c:put(p[1], p[2], WD[3], wtok) end
c:put(33, 7, WD[6], wtok) c:put(32, 7, WD[6], wtok) c:put(35, 9, WD[2], wtok) c:put(31, 9, WD[2], wtok)
-- re-draw the point tip over the nugget so it reads as skewered
local tipx, tipy = G.bez(HPTS, 0.985)
for _, p in ipairs{ { 55, 25 }, { 56, 27 }, { 56, 26 } } do if hm:has(p[1], p[2]) then c:put(p[1], p[2], ST[4], stok) end end
c:put(floor(tipx + 0.5), floor(tipy + 0.5), ST[5], stok)
D.save(c, "prospector-s-pick")
