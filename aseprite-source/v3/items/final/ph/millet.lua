-- millet (final, Opus single pass). One slim foxtail-millet stalk (3 px, straw-green, two jointed nodes) rising
-- and arching over into a nodding, tapered panicle of tiny round gold grains (each grain lit per pixel, dark
-- crevices between, staggered rows) with short bristles on both flanks. Two long grass blades from the nodes
-- (midrib, V-fold light, AO where they sheathe the stalk). quirk: a single dewdrop sliding down the lower blade.
local NAME = "millet"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = G.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#2a3f26", "#3e5c2e", "#5a7e38", "#7ea044", "#a8c25a", "#d4e08a" }
local GRAIN = { "#5e3418", "#8e5420", "#bf7c28", "#e2a63a", "#f6cc5c", "#fff0a4" }
local DEW = { "#2e5a74", "#3f86a6", "#6cb8cc", "#a6e0e0", "#d8f6f0" }
local BR_L, BR_D = "#f4dc8e", "#a87a34"

-- masks first (for AO / overlap)
local sm, sn, ST, SS, SA = A.tube({ { 20, 56 }, { 21, 40 }, { 23, 20 }, { 35, 12 } }, function(t) return 1.45 - 0.3 * t end)
local hm, hn, HT, HS, HA, HG, hlen, HD, hs = A.tube({ { 33, 11 }, { 44, 10 }, { 51, 23 }, { 48, 41 } }, function(t)
  return max(1.1, 4.3 * sin(pi * (0.22 + 0.78 * t)) ^ 0.6)
end, { cap = true })

-- grass blades (behind the stalk)
local ltok = { r = { name = "leaf" } }
local function grass(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * (1 - t) ^ 0.5 * min(1, 0.55 + t * 4))
  end, { fold = 0.42 })
  m:cut(sm)
  local bias = {}
  X.ao(bias, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = ltok, bias = bias, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if not bias[k] and abs(S[k]) < 0.17 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
  end)
  return m, n, T, S
end
local l1 = grass(21, 43, 4, 35, 9, 20, 2.5)
local l2, l2n, l2T, l2S = grass(21, 49, 35, 43, 42, 54, 2.3)

-- stalk: tube light, two nodes (dark joint row + pale swelling above), AO under the panicle
local stok = { r = { name = "stalk" } }
local sb = {}
sm:cut(hm)
X.ao(sb, sm, hm, 2, -1)
local sidx = G.toneN(c, sm, sn, STEM, { tok = stok, bias = sb, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.35 })
sm:each(function(x, y) local k = K(x, y)
  if y == 43 or y == 49 then c:put(x, y, STEM[2], stok)
  elseif y == 42 or y == 48 then c:put(x, y, STEM[min(6, (sidx[k] or 3) + 1)], stok) end
end)

-- panicle: per-grain normals (staggered lattice in arc-length / offset space) on top of the tube normal
local htok = { r = { name = "panicle" } }
local bn, crev = {}, {}
hm:each(function(x, y) local k = K(x, y)
  local a, b = HA[k], HD[k]
  local i = floor(a / 2.7 + 0.5)
  local off = (i % 2) * 1.25
  local j = floor((b - off) / 2.5 + 0.5)
  local da, db = (a - i * 2.7) / 1.45, (b - off - j * 2.5) / 1.35
  local g, nn = HG[k], hn[k]
  local bx = (g.tx * da + g.px * db) * 0.85
  local by = (g.ty * da + g.py * db) * 0.85
  bn[k] = { G.norm(nn[1] + bx, nn[2] + by, nn[3] + 0.15) }
  if da * da + db * db > 1.0 then crev[k] = -1 end
end)
G.toneN(c, hm, bn, GRAIN, { tok = htok, bias = crev, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.3 })
-- bristles: short spikes off both flanks, swept toward the tip
for i, s in ipairs(hs) do
  if i % 22 == 8 and s.t > 0.05 and s.t < 0.86 then
    for _, side in ipairs { -1, 1 } do
      local w = s.w + 0.6
      local x0, y0 = s.x + side * s.px * w, s.y + side * s.py * w
      local dx, dy = side * s.px * 0.75 + s.tx * 0.65, side * s.py * 0.75 + s.ty * 0.65
      for q = 0, 1 do
        local x, y = floor(x0 + dx * q + 0.5), floor(y0 + dy * q + 0.5)
        if not hm:has(x, y) then c:put(x, y, side < 0 and BR_L or BR_D, htok) end
      end
    end
  end
end
A.glint(c, hm, bn, A.CREAM, htok, 40)

-- quirk: dewdrop on the lower blade, with its contact shadow
local dx0, dy0 = 33, 46
local dtok = { r = { name = "dew" } }
l2:each(function(x, y) if (x == dx0 + 1 and y == dy0 + 2) or (x == dx0 + 2 and y == dy0 + 1) then c:put(x, y, LEAF[1], ltok) end end)
local dm = c:ellipse(dx0, dy0, 1.6, 1.6)
local dn = X.sphere(dx0, dy0, 1.6, dm)
X.tone(c, dm, X.light(dn, { amb = 0.15, wrap = 0.4 }), DEW, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = dtok })
c:put(dx0 + 1, dy0 + 1, DEW[5], dtok)
c:put(dx0 - 1, dy0 - 1, A.CREAM, dtok)

G.save2(c, NAME)
