-- rice (final, agent aD12_3). A harvest sheaf: three straw stalks of different heights, tied with a twisted straw rope
-- (twist stripes, knot, frayed tails), each topped by a drooping panicle of lit golden grains with fine awns on a thin
-- rachis, two long arching leaf blades with midribs, cut pale stalk ends. quirk: a tiny ladybird rides the left leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("rice")
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STRAW = { "#6a6a30", "#8a8c3e", "#aab45c", "#c8cc78", "#e0e298", "#f4f2c0" }
local GRAIN = { "#8a5a22", "#b8863a", "#dcaa4c", "#f0c862", "#fae08c", "#fff2c0" }
local ROPE  = { "#6a4a22", "#a07a34", "#cfa04a", "#ecc86a" }
local ltok = { r = { name = "leaf" } }

-- leaf blades (behind): arch out from the tie
local function blade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * (1 - t) ^ 0.75 + 0.3)
  end, { fold = 0.4 })
  G.toneN(c, m, n, LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.05 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
blade(28, 49, 13, 41, 9, 53, 2.2)
blade(35, 49, 49, 41, 54, 52, 2.2)
-- ladybird on the left blade
do
  local lx, ly = floor(0.25 * 28 + 0.5 * 12 + 0.25 * 7 + 0.5), floor(0.25 * 49 + 0.5 * 40 + 0.25 * 54 + 0.5) - 2
  c:fillMask(c:rect(lx, ly, lx + 2, ly + 2), "#d04b25")
  c:px(lx, ly, "#ee6c22") c:px(lx + 1, ly + 1, "#2b1c26") c:px(lx + 2, ly + 2, "#8a2a24") c:px(lx + 1, ly - 1, "#2b1c26")
  c:px(lx + 2, ly, "#ee6c22")
end

-- stalks (base -> top of arch) and their drooping panicle curves
local stalks = {
  { { { 26, 56 }, { 27, 43 }, { 21, 30 }, { 15, 22 } }, { { 15, 22 }, { 10, 20 }, { 8, 27 }, { 11, 36 } }, 1.35 },
  { { { 31, 56 }, { 31, 40 }, { 32, 26 }, { 32, 15 } }, { { 32, 15 }, { 36, 10 }, { 43, 12 }, { 43, 23 } }, 1.5 },
  { { { 36, 56 }, { 36, 43 }, { 41, 34 }, { 46, 29 } }, { { 46, 29 }, { 50, 27 }, { 53, 33 }, { 51, 41 } }, 1.35 },
}
local stok = { r = { name = "straw" } }
local grainPx = HP.mask()
for si, s in ipairs(stalks) do
  local m, n, T, S = G.tube(s[1], function(t) return s[3] - 0.35 * t end)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), STRAW, { cuts = { 0.22, 0.4, 0.58, 0.76, 0.9 }, tok = stok })
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.15 and T[k] < 0.9 and abs(S[k]) < 0.12 then c:px(x, y, STRAW[5]) end    -- sheen line
    if T[k] > 0.3 and T[k] < 0.34 then c:px(x, y, STRAW[2]) end                          -- node
    if T[k] > 0.96 then c:px(x, y, STRAW[6]) end end)                                   -- cut end
end
local function panicle(p, side0)
  local m, n = G.tube(p, function(t) return 0.95 - 0.45 * t end)
  X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), STRAW, { cuts = { 0.3, 0.55, 0.8, 0.9, 0.97 }, tok = stok })
  local N = 9
  for i = 1, N do
    local t = 0.06 + (i - 1) / N * 0.9
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.04)) local x1, y1 = G.bez(p, max(0, t - 0.04))
    local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local side = ((i % 2 == 0) and 1 or -1) * side0
    local px, py = -ty * side, tx * side
    local gx, gy = x + px * 2.1 + tx * 0.8, y + py * 2.1 + ty * 0.8
    local ang = atan(ty + py * 0.35, tx + px * 0.35)
    local gm, gn = G.oval(gx, gy, 2.9, 1.5, ang, 0.9)
    -- ring (contact separation) over earlier grains
    gm:grow(1):cut(gm):each(function(xx, yy) if grainPx:has(xx, yy) then c:px(xx, yy, GRAIN[1]) end end)
    G.toneN(c, gm, gn, GRAIN, { tok = { r = { name = "grain" } }, amb = 0.15, wrap = 0.3 })
    grainPx:add(gm)
    c:px(floor(gx - tx * 0.8 - 0.5), floor(gy - ty * 0.8 - 0.5), GRAIN[6])
    if i % 2 == 1 or i == N then
      local ex, ey = gx + tx * 3.6, gy + ty * 3.6
      A.line(c, gx + tx * 2.6, gy + ty * 2.6, ex + tx * 1.4, ey + ty * 1.4, function(j) return j == 0 and GRAIN[2] or GRAIN[3] end)
    end
  end
  local ex, ey = G.bez(p, 1)
  local gm, gn = G.oval(ex, ey + 1.4, 1.5, 2.6, 0, 0.9)
  G.toneN(c, gm, gn, GRAIN, { tok = { r = { name = "grain" } }, amb = 0.15, wrap = 0.3 })
end
panicle(stalks[1][2], -1) panicle(stalks[2][2], 1) panicle(stalks[3][2], 1)

-- twisted straw rope with knot and frayed tails
local rm, rn, RT, RS = G.tube({ { 22, 47 }, { 28, 46 }, { 34, 45 }, { 41, 44 } }, function(t) return 1.8 end)
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.12, wrap = 0.3 }), ROPE, { cuts = { 0.3, 0.6, 0.82 }, tok = { r = { name = "rope" } } })
rm:each(function(x, y) local k = K(x, y)
  local ph = RT[k] * 30 + RS[k] * 1.6
  if floor(ph) % 2 == 0 then c:px(x, y, ROPE[max(1, (ridx[k] or 3) - 1)]) end end)
local kn = c:ellipse(39.5, 44, 2.6, 2.8)
local knm = A.lit(c, kn, ROPE, 2) kn:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, ROPE[1]) end end) c:px(38, 42, ROPE[4])
A.line(c, 40, 46, 43, 53, function(i) return i % 2 == 0 and ROPE[2] or ROPE[3] end)
A.line(c, 41, 46, 46, 51, function(i) return i % 2 == 0 and ROPE[3] or ROPE[2] end)
c:px(43, 54, ROPE[2]) c:px(44, 53, ROPE[1]) c:px(47, 52, ROPE[2]) c:px(46, 52, ROPE[1])
-- shadow of rope on stalks beneath
rm:copy():shift(0, 2):cut(rm):each(function(x, y) if c.pix[y * c.w + x] and not grainPx:has(x, y) then c:px(x, y, STRAW[2]) end end)
A.save(c, "rice")
