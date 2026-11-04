-- croak-sac (final pass, Opus). A frog's vocal sac, puffed full: a stretched, glossy, pale rose membrane balloon
-- (thin lilac capillaries, bright rim, paler core, big wet specular, cool bounce low right) gathered at a short
-- neck into a ruffled collar of spotted frog-green skin.
-- quirk: a tiny fly has landed on the sac, about to regret it.
local NAME = "croak-sac"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_4.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SAC = { "#6e2a5a", "#a2477a", "#d0709a", "#eca0b8", "#fbc8d2", "#ffe6e2" }
local VEIN = "#b05a92"
local SKIN = { "#173f36", "#22603e", "#36844a", "#58a650", "#8cc65e", "#c4e07a" }
local SPOT = "#1d4a3a"

-- balloon body: round bottom + tapering neck, slightly tilted
local body = (G.oval(33, 39, 13.2, 14.2, 0.15, 1))
local neck = A.stem(c, { { 31, 27 }, { 30, 22 }, { 29, 19 }, { 28, 16 } }, function(t) return 4.6 - t * 1.6 end, SAC, { tok = { r = { name = "sac" } } })
local sac = body:copy():add(neck)
local n = A.body(sac, 31, 34, 15, 6, 0.75)
local tok = { r = { name = "sac" } }
local idx = A.shade(c, sac, n, SAC, { tok = tok, amb = 0.1, wrap = 0.35 })
-- paler translucent core: lift the mid tones inside the inner disc
local inner = body:shrink(4)
inner:each(function(x, y) local k = K(x, y) if idx[k] == 3 or idx[k] == 4 then idx[k] = idx[k] + 1 c:put(x, y, SAC[idx[k]], tok) end end)
-- capillaries: wandering branched lines from the neck down the sac
local function vein(pts, w)
  for i = 0, 40 do local x, y = G.bez(pts, i / 40) local xi, yi = floor(x + 0.5), floor(y + 0.5)
    if sac:has(xi, yi) and not sac:edge():has(xi, yi) then local k = K(xi, yi)
      c:put(xi, yi, (idx[k] or 3) >= 5 and SAC[4] or VEIN, tok) end end
end
vein({ { 31, 26 }, { 27, 32 }, { 22, 38 }, { 24, 47 } })
vein({ { 32, 26 }, { 35, 33 }, { 33, 42 }, { 36, 51 } })
vein({ { 34, 34 }, { 39, 36 }, { 42, 40 }, { 43, 46 } })
vein({ { 25, 37 }, { 23, 41 }, { 26, 43 }, { 29, 46 } })
-- bright rim (stretched membrane catches light all round the lit edge)
sac:edge():each(function(x, y) local k = K(x, y) local nn = n[k]
  if nn and nn[1] < -0.2 and nn[2] < 0.3 and idx[k] >= 3 then c:put(x, y, SAC[6], tok) end end)
-- cool bounce lower right
local rim = X.rim(n)
sac:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.55 and idx[k] <= 2 then c:put(x, y, "#8a6fd0", tok) end end)
-- wet specular: 3x2 + one glint, and a smaller second reflection
for _, q in ipairs{ { 24, 30 }, { 25, 30 }, { 23, 31 }, { 24, 31 }, { 23, 32 } } do c:put(q[1], q[2], "#fff4d6", tok) end
c:put(26, 29, SAC[6], tok) c:put(40, 47, SAC[5], tok) c:put(41, 46, SAC[5], tok)

-- collar: ruffled frog-skin band around the neck top
local col = HP.mask()
for i = 0, 6 do local a = i / 6 * pi
  col:add(G.rell(27.5 + cos(a) * 5.2, 14.2 + sin(a) * 1.2 - 0.6, 0.97, 0.25, 2.2, 1.9)) end
col:add(G.rell(27.5, 13.2, 0.97, 0.25, 4.5, 2.0))
local cn = A.body(col, 27, 12, 6, 2, 0.5)
local ctok = { r = { name = "skin" } }
local cidx = A.shade(c, col, cn, SKIN, { tok = ctok })
-- ruffle folds + spots
col:each(function(x, y) local k = K(x, y)
  if (x % 3 == 0) and cidx[k] >= 3 and y >= 14 then c:put(x, y, SKIN[cidx[k] - 1], ctok) end
  if X.hash(x, y, 13) > 0.85 and cidx[k] >= 3 then c:put(x, y, SPOT, ctok) end end)
-- AO on the sac just under the collar
col:shift(0, 1):each(function(x, y) if sac:has(x, y) and not col:has(x, y) then c:put(x, y, SAC[1], tok) end end)
col:shift(1, 2):each(function(x, y) if sac:has(x, y) and not col:has(x, y) and not col:shift(0, 1):has(x, y) then c:put(x, y, SAC[2], tok) end end)

-- quirk: tiny fly on the upper right shoulder
local ftok = { r = { name = "fly" } }
for _, q in ipairs{ { 42, 27, "#35295f" }, { 43, 27, "#35295f" }, { 44, 27, "#5a459e" }, { 41, 27, "#2b1c26" },
                    { 42, 25, "#b6f0e0" }, { 43, 25, "#e4f6ff" }, { 43, 26, "#b6f0e0" }, { 42, 26, "#8bc4ea" },
                    { 41, 28, "#35295f" }, { 43, 28, "#35295f" } } do c:put(q[1], q[2], q[3], ftok) end
c:put(41, 26, "#ec4f4c", ftok)
A.save(c, NAME)
