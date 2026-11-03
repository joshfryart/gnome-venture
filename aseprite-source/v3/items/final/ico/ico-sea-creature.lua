-- ico-sea-creature (final, Opus single pass). Coral octopus: tall egg mantle (waxy specular, cool bounce on the
-- shade side, freckle spots), small pill eyes with glints, cheeks and a tube siphon for a snout. Six slim tapering
-- tentacles curling outward (tube normals, pale sucker dots on the underside, AO where they leave the mantle).
-- quirk: the raised right tentacle proudly holds up a pearl.
local NAME = "ico-sea-creature"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, floor, max, min, sqrt = math.abs, math.floor, math.max, math.min, math.sqrt
local c = A.new(NAME)
local OC = { "#4a1f45", "#7a2e5e", "#b0446c", "#dc6478", "#f4908a", "#ffc2b0" }
local SUCK = "#ffd9c8"
local COOL = "#8a5a9a"
local PEARL = { "#6a5a8a", "#9a8ab8", "#c8bede", "#ece6f6", "#fff4d6" }
local ttok, mtok = A.tok("tentacle"), A.tok("mantle")

local mantle = A.ellM(30, 21, 10.5, 12.5)
-- flatten the bottom a little (where the arms leave)
mantle:each(function(x, y) if y > 31 then mantle.s[K(x, y)] = nil end end)

local arms = {
  { { 24, 30 }, { 16, 32 }, { 9, 40 }, { 11, 47 }, 2.4, { { 11, 47 }, { 12, 52 }, { 17, 52 }, { 16, 48 } } },
  { { 26, 31 }, { 22, 41 }, { 18, 49 }, { 20, 53 }, 2.4, { { 20, 53 }, { 22, 57 }, { 26, 55 }, { 24, 52 } } },
  { { 29, 31 }, { 29, 42 }, { 26, 52 }, { 31, 56 }, 2.3 },
  { { 33, 31 }, { 35, 42 }, { 39, 51 }, { 35, 55 }, 2.3 },
  { { 36, 30 }, { 42, 38 }, { 47, 44 }, { 47, 49 }, 2.4, { { 47, 49 }, { 47, 54 }, { 42, 54 }, { 43, 50 } } },
  { { 38, 27 }, { 47, 29 }, { 53, 22 }, { 50, 14 }, 2.3 },
}
local all = HP.mask()
local order = { 3, 4, 2, 5, 1, 6 }
local drawn = {}
for _, ai in ipairs(order) do
  local a = arms[ai]
  local w0 = a[5]
  local m, n, T, S = A.tube({ a[1], a[2], a[3], a[4] }, function(t) return w0 * (1 - t * 0.55) end)
  if a[6] then
    local cm, cn, CT, CS = A.tube(a[6], function(t) return 1.15 - t * 0.25 end)
    cm:cut(m)
    cm:each(function(x, y) local k = K(x, y) m:set(x, y) n[k], T[k], S[k] = cn[k], 0.95, CS[k] end)
  end
  local bias = {}
  -- AO: under the mantle and against arms already in front
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.08 then bias[k] = -2 elseif T[k] < 0.16 then bias[k] = -1 end end)
  local idx = A.shade(c, m, n, OC, { tok = ttok, bias = bias, amb = 0.04, wrap = 0.15, cuts = { 0.14, 0.3, 0.48, 0.66, 0.85 } })
  -- separate from arms behind with a dark contour on overlap edges
  m:edge():each(function(x, y) if all:has(x + 1, y) or all:has(x, y + 1) or all:has(x - 1, y) then
    if not all:has(x, y) then A.step(c, idx, OC, x, y, -1, ttok) end end end)
  -- sucker dots along the underside (shade side)
  m:each(function(x, y) local k = K(x, y)
    local t = T[k]
    if S[k] > 0.35 and S[k] < 0.75 and t > 0.22 and t < 0.9 and (floor(t * 40) % 5 == 0) then c:put(x, y, SUCK, ttok) end
  end)
  all:add(m)
end

-- pearl held by the raised arm
local pm = A.ellM(50.5, 10.5, 3, 3)
A.shade(c, pm, X.sphere(50, 10, 3.3, pm), PEARL, { tok = A.tok("pearl"), cuts = { 0.2, 0.42, 0.66, 0.86 } })
c:put(49, 9, A.CREAM, A.tok("pearl")) c:put(49, 8, PEARL[5], A.tok("pearl"))
-- the arm tip curls round the pearl foot
c:put(51, 13, OC[3], ttok) c:put(52, 13, OC[2], ttok) c:put(53, 12, OC[2], ttok)

-- mantle
local mn = X.sphere(29, 19, 12.5, mantle)
local mb = {}
mantle:each(function(x, y) if y >= 30 then mb[K(x, y)] = -1 end end)
local midx = A.shade(c, mantle, mn, OC, { tok = mtok, bias = mb, amb = 0.02, wrap = 0.12, cuts = { 0.12, 0.26, 0.42, 0.6, 0.82 } })
-- cool reflected light on the lower-right rim
mantle:edge():each(function(x, y) if x >= 36 and y >= 18 and y <= 29 then c:put(x, y, COOL, mtok) end end)
-- freckles (darker spots) on the dome
for _, p in ipairs{ { 33, 11 }, { 34, 11 }, { 36, 14 }, { 25, 13 }, { 37, 18 }, { 38, 18 }, { 30, 10 } } do A.step(c, midx, OC, p[1], p[2], -1, mtok) end
-- waxy specular + bloom
c:put(25, 12, OC[6], mtok) c:put(26, 12, OC[6], mtok) c:put(25, 13, OC[6], mtok)
c:put(24, 11, A.CREAM, mtok)

-- face: pill eyes, cheeks, siphon snout
c:eyeSmall(25, 21) c:eyeSmall(33, 21)
c:put(24, 25, "#f5809f", mtok) c:put(25, 25, "#f5809f", mtok)
c:put(35, 25, "#f5809f", mtok) c:put(36, 25, "#f5809f", mtok)
-- siphon (small tube nose) between the eyes, lit top, dark opening
A.map(c, { ".56.", "4554", "3113", ".33." }, 28, 24, { ["1"] = OC[1], ["3"] = OC[3], ["4"] = OC[4], ["5"] = OC[5], ["6"] = OC[6] }, mtok)

A.save(c, NAME)
