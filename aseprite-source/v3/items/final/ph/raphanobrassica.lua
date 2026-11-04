-- raphanobrassica (final, Sonnet high). The radish-cabbage hybrid, slim: a long torpedo root, deep magenta shoulders
-- bleeding into a pale icicle tail (tapered streaks, faint growth rings, waxy bloom, one specular, cool reflected light),
-- three broad blue-green cabbage leaves with frilly pale margins, a pale midrib and branching veins on thin petioles,
-- and a tight little cabbage heart nested in the crown where the stalks meet.
-- quirk: a ladybird is strolling on the right leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("raphanobrassica")
local MAG   = { "#4a1440", "#7a1f5a", "#a82c70", "#cf4a8a", "#ea78ac", "#f8b0cc" }
local PALE  = { "#7a6a98", "#a898bc", "#cfc4da", "#ece4ea", "#f8f2f2", "#fffaf6" }
local CAB   = { "#1d3b4a", "#2a5a5a", "#3b7f6a", "#5aa27a", "#88c496", "#bfe3b8" }
local HEART = { "#2a5a4a", "#4a8a62", "#74b07c", "#a0cf92", "#c8e6a8", "#eef8c8" }
local GRN   = { "#2d5a3a", "#4b8656", "#78b06a", "#a6cf86", "#cfe7a4", "#e8f5c4" }
local BOUNCE = "#8e9cd2"
local ltok = { r = { name = "leaf" } }

-- leaves first (the root and heart overlap their bases)
local drawn = {}
local function cab(ax, ay, cx, cy, bx, by, W, ruf, fb)
  local m, n, T, S, len = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.26 then return 1.0 end
    local u = (t - 0.26) / 0.74
    return max(1.0, W * sin(pi * min(1, u * 0.9 + 0.1)) ^ 0.62 + ruf * sin(t * 40))
  end, { ramp = CAB, veins = { 0.4, 0.48, 0.56, 0.64, 0.72, 0.8, 0.88 }, sweep = 2.0, rib = 0.17, ribEnd = 0.95, ribHi = "#dff0d0", veinMax = 0.85,
         fibre = CAB[5], cool = "#2a5a7a", fold = 0.5,
         tear = { [-1] = { depth = 0.34, t0 = 0.34, t1 = 0.97 }, [1] = { depth = 0.34, t0 = 0.34, t1 = 0.97 } } })
  m:each(function(x, y) local k = K(x, y)
    if T[k] < 0.3 then c:put(x, y, S[k] <= 0 and "#c8e6a8" or "#8cba78", ltok)                        -- pale petiole
    elseif X.hash(x, y, 21) > 0.9 and abs(S[k]) < 0.8 then c:put(x, y, CAB[6], ltok) end             -- waxy bloom
  end)
  for _, d in ipairs(drawn) do A.contact(c, d, m, CAB[1], 1, 1, ltok) end
  drawn[#drawn + 1] = m
  return m
end
cab(31, 29, 18, 30, 8, 14, 5.2, 0.35)
cab(33, 29, 47, 30, 56, 14, 5.2, 0.35)
cab(32, 28, 31, 20, 34, 7, 4.2, 0.3)

-- root
local rp = { { 32, 27 }, { 31, 37 }, { 33, 47 }, { 36, 56 } }
local rm = G.tube(rp, function(t)
  if t < 0.3 then return 6.4 * sin(min(1, (t + 0.04) / 0.3) * pi / 2) ^ 0.55 end
  return 6.4 * ((1 - t) / 0.7) ^ 1.15 + 0.45
end)
local rn = X.pillow(rm, 6)
local v = X.light(rn, { amb = 0.06, wrap = 0.2 })
local pm, mm = HP.mask(), HP.mask()
local streak = { [29] = 5, [33] = 4, [36] = 3 }
rm:each(function(x, y)
  local edge = 40 + floor((x - 32) * 0.15 + 0.5) + ((x % 3 == 0) and 1 or 0)
  local magenta = y < edge
  local sx = streak[x]
  if sx and y >= edge and y < edge + sx then magenta = true end
  if magenta then mm:set(x, y) else pm:set(x, y) end
end)
local bias = {}
mm:each(function(x, y) local k = K(x, y)
  if y % 4 == 0 and abs(x - 32) < 5 and X.hash(x, y, 6) > 0.4 then bias[k] = -1 end            -- faint growth rings
  if y <= 30 then bias[k] = (bias[k] or 0) + 0 end end)
local rcut = { 0.2, 0.38, 0.55, 0.72, 0.87 }
X.tone(c, mm, v, MAG, { cuts = rcut, bias = bias })
local pb = {}
pm:each(function(x, y) if y % 5 == 0 and X.hash(x, y, 7) > 0.5 then pb[K(x, y)] = -1 end end)
X.tone(c, pm, v, PALE, { cuts = rcut, bias = pb })
-- green crown shoulder
rm:each(function(x, y) if y <= 30 then c:put(x, y, GRN[max(1, min(6, floor(v[K(x, y)] * 5.4) + 1))]) end end)
for x = 28, 36 do if rm:has(x, 31) and X.hash(x, 31, 3) > 0.5 then c:put(x, 31, GRN[2]) end end
-- cool reflected light, lower right
local rim = X.rim(rn)
rm:edge():each(function(x, y) if rim[K(x, y)] > 0.7 and y > 33 and y < 50 then c:put(x, y, BOUNCE) end end)
-- waxy bloom + specular
mm:copy():shrink(1):each(function(x, y) if v[K(x, y)] > 0.68 and X.hash(x, y, 11) > 0.85 then c:put(x, y, MAG[6]) end end)
c:put(27, 34, "#fff6f2") c:put(28, 34, "#fff6f2") c:put(27, 35, MAG[6]) c:put(29, 33, MAG[6])
-- rootlets
for _, p in ipairs{ { 34, 50 }, { 32, 51 }, { 30, 52 }, { 29, 54 } } do c:put(p[1], p[2], PALE[3]) end
for _, p in ipairs{ { 35, 53 }, { 37, 54 }, { 39, 55 }, { 40, 57 } } do c:put(p[1], p[2], PALE[2]) end

-- cabbage heart in the crown
local hm = c:ellipse(32, 24, 4.4, 4.2)
local hn = X.sphere(31.6, 23.6, 4.4, hm)
local hv = X.light(hn, { amb = 0.1, wrap = 0.25 })
X.tone(c, hm, hv, HEART, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
A.pline(c, { { 33, 20 }, { 35, 22 }, { 35, 25 } }, HEART[2])
A.pline(c, { { 29, 22 }, { 30, 25 }, { 32, 27 } }, HEART[2])
c:put(30, 21, HEART[6]) c:put(31, 21, HEART[6])
for x = 29, 35 do if hm:has(x, 28) then c:put(x, 28, HEART[1]) end end

-- quirk: ladybird on the right leaf
local rows = { ".KK.", "HRKR", "RKKR", ".RR." }
local pal = { K = "#2b1c26", R = "#e8493b", H = "#ff8a5c" }
for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i) if ch ~= "." then c:put(47 + i - 1, 19 + j - 1, pal[ch]) end end end
A.save(c, "raphanobrassica")
