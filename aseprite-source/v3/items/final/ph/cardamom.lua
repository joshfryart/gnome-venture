-- cardamom (final, Opus single pass). A slim olive stalk on the diagonal carrying three green cardamom pods:
-- pointed spindles with three longitudinal ribs (lit ridge, dark groove), waxy bloom flecks, a brown calyx collar
-- where each pod meets the stalk (AO there), a tiny dried beak at each tip, pale cut end grain on the stalk foot.
-- quirk: a withered violet-veined flower wisp still clings to the tip of the upper-left pod.
local NAME = "cardamom"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new(NAME)

local POD = { "#22432e", "#36623a", "#4f8443", "#71a64e", "#9cc764", "#cfe598" }
local STALK = { "#2f2a1c", "#4c4526", "#6c6630", "#8e8a3f", "#b2ad5a", "#d8d08a" }
local CAL = { "#3a2420", "#5e3a2c", "#8a5c3a", "#b8875a" }
local BLOOM = "#e4f0c0"
local WISP = { "#5a459e", "#9a86d0", "#ddd2f2" }

-- stalk: lower-left foot to upper-right tip
local sp = { { 13, 57 }, { 20, 44 }, { 33, 28 }, { 49, 11 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.25 - 0.45 * t end)

-- pods: base on the stalk, tip outward. {bx, by, tx, ty, w}
local P = {
  { 24, 43, 44, 51, 3.9 },
  { 29, 33, 11, 23, 3.7 },
  { 43, 18, 56, 34, 3.6 },
}
local pods = {}
for i, p in ipairs(P) do
  local m, n, U, V, g = A.pod(p[1], p[2], p[3], p[4], p[5], 0.75)
  pods[i] = { m = m, n = n, U = U, V = V, g = g }
end

-- stalk behind pods
local stok = A.tok("stalk")
local sbias = {}
for _, q in ipairs(pods) do X.ao(sbias, sm, q.m, 1, -1) end
local svis = sm:copy() for _, q in ipairs(pods) do svis:cut(q.m) end
A.shade(c, svis, sn, STALK, { bias = sbias, tok = stok, amb = 0.14, wrap = 0.3 })
-- stalk: fine fibre line on the lit side, cut end grain at the foot
svis:each(function(x, y) local k = K(x, y)
  if ST[k] < 0.05 then c:put(x, y, (SS[k] < 0.2) and STALK[6] or STALK[5], stok)
  elseif SS[k] < -0.25 and SS[k] > -0.6 and ST[k] > 0.1 and ST[k] < 0.8 and X.hash(x, y, 2) > 0.45 then c:put(x, y, STALK[5], stok) end
end)
for _, q in ipairs{ { 13, 57 }, { 12, 57 } } do if sm:has(q[1], q[2]) then c:put(q[1], q[2], STALK[3], stok) end end

-- pods: drawn back to front (3 under 1? none overlap much); AO from the stalk on each pod base
for i, q in ipairs(pods) do
  local tok = A.tok("pod" .. i)
  local bias = {}
  local vis = q.m:copy()
  for j = i + 1, #pods do vis:cut(pods[j].m) X.ao(bias, q.m, pods[j].m, 1, -1) end
  local idx = A.shade(c, vis, q.n, POD, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })
  -- ribs: lit ridge at v=-0.42 (light line + dark groove beside), centre ridge, shade groove at v=+0.45
  local g = q.g
  for s = -78, 78 do local u = s / 100
    local function mark(v, d)
      local x, y = A.podAt(g, u, v, 0.75)
      if vis:has(x, y) then local k = K(x, y)
        local ii = max(1, min(6, (idx[k] or 3) + d)) idx[k] = ii c:put(x, y, POD[ii], tok) end
    end
    mark(-0.5, 1) mark(-0.22, -1) mark(0.42, -1)
  end
  -- calyx collar at the base, dried beak at the tip
  vis:each(function(x, y) local k = K(x, y)
    if q.U[k] < -0.8 then c:put(x, y, CAL[(q.V[k] < -0.1) and 4 or ((q.V[k] < 0.4) and 3 or 2)], tok) end
  end)
  local bx, by = A.podAt(g, 1.08, 0, 0.75)
  if not q.m:has(bx, by) then c:put(bx, by, CAL[2], tok) end
  -- waxy bloom flecks on the lit half
  vis:each(function(x, y) local k = K(x, y)
    if q.V[k] < -0.35 and abs(q.U[k]) < 0.6 and X.hash(x, y, i) > 0.86 and (idx[k] or 0) >= 4 then c:put(x, y, BLOOM, tok) end
  end)
  -- one 2x1 specular on the lit ridge
  local sx, sy = A.podAt(g, -0.25, -0.62, 0.75)
  local sx2, sy2 = A.podAt(g, -0.1, -0.62, 0.75)
  for _, pp in ipairs{ { sx, sy }, { sx2, sy2 } } do if vis:has(pp[1], pp[2]) then c:put(pp[1], pp[2], A.CREAM, tok) end end
  -- cool reflected light along the shade rim
  q.m:edge():each(function(x, y) local k = K(x, y)
    if vis:has(x, y) and q.V[k] > 0.7 and abs(q.U[k]) < 0.55 then c:put(x, y, "#4f8a7e", tok) end end)
end

-- quirk: withered flower wisp on pod 2's tip (upper-left), curling up
local wt = A.tok("wisp")
local tx, ty = A.podAt(pods[2].g, 1.08, 0, 0.75)
local wisp = { { tx - 1, ty, 2 }, { tx - 2, ty - 1, 2 }, { tx - 2, ty - 2, 3 }, { tx - 1, ty - 3, 2 }, { tx, ty - 3, 1 }, { tx - 3, ty - 1, 1 } }
for _, w in ipairs(wisp) do if not c:get(w[1], w[2]) then c:put(w[1], w[2], WISP[w[3]], wt) end end

A.save(c, NAME)
