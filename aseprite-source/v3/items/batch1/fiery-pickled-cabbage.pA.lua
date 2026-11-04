-- fiery-pickled-cabbage pass A. Slim onggi crock (brown glaze, finger-wiped wave, bare clay foot with glaze drips),
-- two napa leaves rising from the mouth (white midribs, chili paste smears), a red chili draped over the rim.
-- quirk: the chili is so hot its tip has caught a tiny flame.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("fiery-pickled-cabbage.pA")
local K, floor, max, min, sqrt, sin = H.K, math.floor, math.max, math.min, math.sqrt, math.sin
local function put(x, y, h) c:put(x, y, h) end
local function idx(v, n) n = n or 6 return max(1, min(n, floor(v * (n - 0.01)) + 1)) end
local function nrm(x, y, z) local l = sqrt(x*x + y*y + z*z) return { x/l, y/l, z/l } end

local GLAZE = { "#2a1716", "#43221d", "#633224", "#87482d", "#ad663a", "#d99257" }
local CLAY  = { "#6b3a2a", "#94553a", "#bb7650", "#d99a6c" }
local LEAFG = { "#2f5a3a", "#467c42", "#6aa04a", "#93c25a", "#bedc7a", "#e2f0a6" }
local RIB   = { "#b8a682", "#d6c79c", "#ece0ba", "#fbf3d8" }
local PASTE = { "#7a1e22", "#b0302a", "#dc4a2c", "#f47a3c" }
local CHILI = { "#5e1426", "#8f1d2a", "#c2282c", "#e5452f", "#ff7a4e", "#ffd2b0" }
local FLAME = { "#e8493b", "#f5a02e", "#ffe38a", "#fff4d6" }

c:groundShadow(32, 58, 12, 2)
-- crock profile (centre 31.5)
local CX = 31.5
local function hw(y)
  if y <= 28 then return 8 end
  if y <= 42 then return 6.5 + 6 * sin((y - 29) / 13 * math.pi / 2) end
  return 12.5 - 5 * ((y - 42) / 15) ^ 1.5
end
local crock = HP.mask()
for y = 26, 57 do local w = hw(y) for x = floor(CX - w + 0.5), floor(CX + w - 0.5 + 0.5) do crock:set(x, y) end end
local n = {}
crock:each(function(x, y)
  local w = hw(y)
  local nx = (x - CX) / (w + 0.5)
  local ny = (y < 29) and -0.2 or (y < 40) and -0.45 or (y < 46) and 0 or 0.35
  n[K(x, y)] = nrm(nx, ny, sqrt(max(0.05, 1 - nx * nx)))
end)
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
crock:each(function(x, y)
  local i = idx(v[K(x, y)])
  if y == 29 then i = max(1, i - 2) end                      -- AO under the rolled lip
  if y == 26 then i = min(6, i + 1) end
  -- finger-wiped wave (lighter glaze line)
  local wy = 44 + floor(1.6 * sin(x * 0.75) + 0.5)
  if y == wy or y == wy - 5 then i = min(6, i + 1) end
  put(x, y, GLAZE[i])
end)
-- bare clay foot with glaze drip tongues
crock:each(function(x, y)
  local edge = 53 + ((x % 5 == 2) and 2 or (x % 7 == 0) and 1 or 0)
  if y > edge then
    local t = (x - CX) / hw(y)
    put(x, y, CLAY[t < -0.5 and 4 or t < 0.1 and 3 or t < 0.6 and 2 or 1])
  end
end)
-- glaze specular
for _, p in ipairs{ {23,36},{22,37},{22,38},{21,39},{21,40},{21,41} } do put(p[1], p[2], "#f0c08a") end
put(22, 36, "#fff4d6")
-- mouth
for x = 25, 38 do put(x, 26, GLAZE[1]) end

-- napa leaves
local function napa(ax, ay, bx, by, wmax, seed)
  local m, nn, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.98 then return -1 end
    local w = 1.6 + (wmax - 1.6) * min(1, t * 1.4)
    if t > 0.8 then w = w * (1 - (t - 0.8) * 2.2) + 0.6 * sin(t * 60) end
    return max(0.6, w)
  end)
  local lv = X.light(nn, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y)
    local k = K(x, y)
    local s, t, i = S[k], T[k], idx(lv[k])
    local col
    if math.abs(s) < 0.38 and t < 0.75 then col = RIB[max(1, min(4, i - 2))]
    else
      col = LEAFG[i]
      if t > 0.55 and (not m:has(x - 1, y - 1) or not m:has(x + 1, y - 1)) then col = LEAFG[max(1, i - 2)] end  -- ruffle
    end
    if X.hash(x, y, seed) > 0.72 and t < 0.85 then col = PASTE[max(1, min(4, i - 2))] end
    put(x, y, col)
  end)
  return m
end
napa(30, 28, 20, 8, 5, 3)
napa(34, 28, 44, 14, 4.2, 7)
-- chili draped over the rim, down the right side
local cm, cT = H.sweep({ {36,25},{41,22},{44,27},{45,37} }, function(t) return 1.6 - 0.9 * t end, 80)
local cn = X.pillow(cm, 1.5)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
cm:each(function(x, y) put(x, y, CHILI[idx(cv[K(x, y)])]) end)
put(40, 22, CHILI[6]) put(41, 22, CHILI[5])
c:paint({ ".ab", "bb." }, 33, 23, { a = LEAFG[4], b = LEAFG[2] })     -- calyx + stem
-- quirk: tiny flame on the chili tip
c:paint({ ".a..", ".ab.", "abca", "bcdb", ".bb." }, 44, 37, { a = FLAME[1], b = FLAME[2], c = FLAME[3], d = FLAME[4] })
H.fin(c)
