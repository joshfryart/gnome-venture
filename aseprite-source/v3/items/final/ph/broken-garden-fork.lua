-- broken-garden-fork (aB11_2, Opus single pass). Upright border fork: wooden D-grip (crossbar + two arms), slim ash shaft
-- with grain, steel socket, a pillowed steel shoulder and four slim tapering tines with air between them.
-- Material: tube light on wood with grain streaks and pale end grain on the crossbar, bevel + specular on steel, AO where
-- the shaft enters the socket and the tines leave the shoulder.
-- broken: the right tine has snapped; its tip flies off to the right with a shard; a split runs up the shaft with a splinter.
-- quirk: an earthworm has looped itself round the left tine.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_2.lua")
local HP, X, K = H.HP, H.X, H.K
local S, W = H.STEEL, H.WOOD
local floor = math.floor
local c = H.new("broken-garden-fork")
local wtok, stok = { r = { name = "wood" } }, { r = { name = "steel" } }

-- D-grip arms then crossbar
local function wtube(p, w, seed)
  local m, n, T, Sx = H.tube(p, function() return w end)
  local idx = H.shade(c, m, n, W, { tok = wtok, spec = 24, specThr = 0.93 })
  H.grain(c, m, T, Sx, idx, W, 12, wtok, seed)
  return m
end
wtube({ { 27, 11 }, { 27, 15 }, { 29, 18 }, { 31, 21 } }, 1.2, 2)
wtube({ { 37, 11 }, { 37, 15 }, { 35, 18 }, { 33, 21 } }, 1.2, 3)
local cb = wtube({ { 25, 10 }, { 28, 10 }, { 36, 10 }, { 39, 10 } }, 1.7, 4)
-- pale end grain on the crossbar ends
c:put(24, 10, W[6], wtok) c:put(24, 9, W[5], wtok) c:put(24, 11, W[4], wtok)
c:put(40, 10, W[3], wtok) c:put(40, 9, W[4], wtok) c:put(40, 11, W[2], wtok)
-- brass rivets where arms meet the shaft top
c:put(32, 21, "#e8b23a") c:put(32, 22, "#8f5a1f")

-- shaft
local sm, sn, sT, sS = X.cyl(32, 21, 32, 41, function() return 1.6 end)
local sb = {}
sm:each(function(x, y) if y >= 39 then sb[K(x, y)] = -1 end end)
local sidx = H.shade(c, sm, sn, W, { tok = wtok, bias = sb, spec = 24, specThr = 0.93 })
H.grain(c, sm, sT, sS, sidx, W, 20, wtok, 7)
-- split up the shaft with a splinter springing out to the right
for _, p in ipairs{ { 32, 27 }, { 32, 28 }, { 33, 29 }, { 33, 30 }, { 33, 31 } } do c:put(p[1], p[2], W[1], wtok) end
c:put(34, 29, W[5], wtok) c:put(35, 28, W[4], wtok) c:put(36, 27, W[3], wtok)

-- steel socket (tapers into the shoulder)
local km, kn = X.cyl(32, 40, 32, 46, function(t) return 2.0 + 0.6 * t end)
local kb = X.ao({}, km, sm, 1, -1)
H.shade(c, km, kn, S, { tok = stok, bias = kb, spec = 20, specThr = 0.88, specCol = H.SPEC })
c:put(32, 43, S[1], stok) -- rivet hole
c:put(31, 42, S[5], stok)

-- shoulder
local shm = c:rrect(23, 46, 41, 49, 1)
H.slab(c, shm, 1.6, S, { tok = stok, spec = 20, specThr = 0.9, bounce = "#6a78b0" })
for x = 25, 39 do c:put(x, 46, S[6], stok) end

-- tines
local tx = { 24.5, 29.5, 34.5, 39.5 }
local tm = {}
for i, x in ipairs(tx) do
  local y1 = i == 4 and 53 or 57
  local m, n, T = X.cyl(x, 49, x - (i - 2.5) * 0.4, y1, function(t) if i == 4 then return 1.0 end return 1.05 - 0.45 * t end)
  local b = X.ao({}, m, shm, 1, -1)
  H.shade(c, m, n, S, { tok = stok, bias = b, spec = 18, specThr = 0.9 })
  tm[i] = m
end
-- jagged snap on the right tine
c:put(39, 53, S[1], stok) H.erase(c, HP.mask():set(40, 53))
-- flying tip + shard
local fm, fn = H.tube({ { 45, 54 }, { 46, 56 }, { 47, 57 }, { 49, 59 } }, function(t) return 1.0 - 0.45 * t end)
H.shade(c, fm, fn, S, { tok = stok, spec = 18, specThr = 0.88 })
c:put(45, 54, S[2], stok)
c:put(44, 51, S[5], stok) c:put(45, 51, S[3], stok)

-- quirk: earthworm looped round the left tine
local P = H.PINK
local worm = { { 21, 51, 3 }, { 22, 52, 4 }, { 23, 52, 3 }, { 24, 53, 4 }, { 25, 53, 3 }, { 26, 53, 2 }, { 27, 54, 2 },
  { 27, 55, 3 }, { 26, 55, 3 }, { 25, 55, 2 }, { 22, 56, 3 }, { 21, 56, 4 }, { 20, 55, 4 }, { 20, 54, 5 }, { 20, 52, 4 }, { 20, 53, 3 } }
for _, w in ipairs(worm) do c:put(w[1], w[2], P[w[3]]) end
c:put(24, 55, S[2], stok) c:put(23, 56, P[2]) -- passes behind tine at the bottom
c:put(21, 51, P[5]) c:put(22, 52, P[4]) -- glossy head + clitellum
c:put(24, 53, P[2])
H.fin(c, debug.getinfo(1, "S").source)
