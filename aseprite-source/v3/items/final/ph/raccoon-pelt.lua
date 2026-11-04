-- raccoon-pelt (final, Sonnet high). A flat, slim raccoon hide laid out belly-down: masked face with empty eye holes, ringed
-- tail curling out under the rump, four splayed paws with toe gaps and pale claws. Ragged fur fringe, grizzled guard hairs,
-- darker saddle stripe along the spine, cool-violet shade, cream muzzle/brows/ear rims.
-- quirk: a spiky burr is stuck in the fur on the right flank.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("raccoon-pelt")
local F  = { "#2f2836", "#4b3f4a", "#6e6169", "#968888", "#bdae9f", "#e6d7bd" }
local DK = { "#15111b", "#241d2a", "#372d39", "#4d4249", "#6a5d60", "#8a7b78" }
local CR = { "#8b7f84", "#b4a9a5", "#d8cfc1", "#f1e9d6", "#fff6e0" }
local OY = 3
local function Y(y) return y + OY end
local function mir(pts) local o = {} for i = #pts, 1, -1 do o[#o + 1] = { 64 - pts[i][1], pts[i][2] } end return o end

-- ===== tail first (the hide covers its root)
local tp = { { 31.5, Y(44) }, { 30, Y(51) }, { 34, Y(55) }, { 42, Y(52.5) } }
local tm, tn, TT, TS = G.tube(tp, function(t)
  local w = 3.9 - 0.7 * t
  if t > 0.93 then w = w * sqrt(max(0.06, 1 - ((t - 0.93) / 0.07) ^ 2)) end
  return w
end)
local tbias = {}
A.streaks(tm, function() return 0.6, 0.8 end, 11, tbias)
local tidx = A.shade(c, tm, tn, F, { bias = tbias })
tm:each(function(x, y) local k = K(x, y)
  local t = TT[k]
  local dark = (t > 0.2 and t < 0.31) or (t > 0.43 and t < 0.54) or (t > 0.66 and t < 0.77) or t > 0.88
  if dark then c:put(x, y, DK[max(1, min(6, (tidx[k] or 3)))], { r = { name = "ring" } }) end
end)

-- ===== hide silhouette
local M = HP.mask()
local head = c:ellipse(31.5, Y(14), 7.5, 5.2)
head:add(c:poly{ { 24, Y(13) }, { 40, Y(13) }, { 42.5, Y(17) }, { 38, Y(21) }, { 26, Y(21) }, { 21.5, Y(17) } })
local earL, earR = c:ellipse(25, Y(8.4), 2.4, 2.4), c:ellipse(38, Y(8.4), 2.4, 2.4)
local bl = { { 27, Y(18) }, { 25, Y(25) }, { 26.5, Y(33) }, { 23.5, Y(41) }, { 27, Y(47) } }
local bp = {} for _, p in ipairs(bl) do bp[#bp + 1] = p end for _, p in ipairs(mir(bl)) do bp[#bp + 1] = p end
local body = c:poly(bp)
local limbs = {}
local function limb(ax, ay, bx, by, w0, w1, pr)
  local m = G.tube(A.path(ax, ay, bx, by), function(t) return w0 + (w1 - w0) * t end)
  m:add(c:ellipse(bx, by, pr, pr * 0.9))
  limbs[#limbs + 1] = { m = m, d = { (bx - ax), (by - ay) }, tip = { bx, by } }
  return m
end
local fl = limb(27, Y(24), 12.5, Y(30.5), 3.0, 2.6, 2.9)
local fr = limb(36, Y(24), 50.5, Y(30.5), 3.0, 2.6, 2.9)
local hl = limb(27.5, Y(41), 14, Y(50.5), 3.3, 2.8, 3.0)
local hr = limb(35.5, Y(41), 49, Y(50.5), 3.3, 2.8, 3.0)
M:add(head):add(earL):add(earR):add(body)
for _, l in ipairs(limbs) do M:add(l.m) end
M = A.ragged(M, 3, 0.22, 0.16)
-- keep the face clean: restore head interior
local keep = c:ellipse(31.5, Y(14), 6.5, 4.5)
M:add(keep)

-- ===== light + fur
local n = A.slab(M, 3.0, { 0.04, 0.08 })
local bias = {}
local function dirf(x, y)
  for _, l in ipairs(limbs) do
    if l.m:has(x, y) and (x < 24 or x > 39) then
      local dx, dy = l.d[1], l.d[2] local ln = sqrt(dx * dx + dy * dy) return dx / ln, dy / ln
    end
  end
  local dx = (x - 31.5) * 0.045
  local ln = sqrt(dx * dx + 1) return dx / ln, 1 / ln
end
A.streaks(M, dirf, 5, bias, 0.17, 0.85, 2.6)
-- guard-hair grizzle: sparse bright tips and dark hairs
M:each(function(x, y)
  local h = X.hash(x, y, 21)
  local k = K(x, y)
  if h < 0.05 then bias[k] = (bias[k] or 0) + 1 elseif h > 0.965 then bias[k] = (bias[k] or 0) - 1 end
  -- darker saddle stripe down the spine
  if abs(x - 31.5) <= 1.6 and y > Y(21) and y < Y(46) and X.hash(x, y, 33) < 0.8 then bias[k] = (bias[k] or 0) - 1 end
end)
-- shadow cast by the hide on the tail root
local tbias2 = {}
local idx = A.shade(c, M, n, F, { bias = bias, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 } })

-- inner separation lines where the tail root meets the rump
tm:each(function(x, y) if M:has(x, y + 1) or M:has(x, y) then end end)
M:each(function(x, y)
  if y > Y(44) and tm:has(x, y + 1) and not M:has(x, y + 1) then c:put(x, y, DK[3]) end
end)
-- cool reflected light on the lower-right fringe
M:edge():each(function(x, y)
  if not (M:has(x + 1, y) and M:has(x, y + 1)) and x > 31 and y > Y(20) and X.hash(x, y, 77) < 0.5 then
    c:put(x, y, "#5a4d63")
  end
end)

-- ===== paws: dark socks, toe gaps, claws
for _, l in ipairs(limbs) do
  local tx, ty = l.tip[1], l.tip[2]
  local dx, dy = l.d[1], l.d[2] local ln = sqrt(dx * dx + dy * dy) dx, dy = dx / ln, dy / ln
  local px, py = -dy, dx
  for y = floor(ty) - 4, floor(ty) + 4 do for x = floor(tx) - 4, floor(tx) + 4 do
    if M:has(x, y) then
      local a = (x - tx) * dx + (y - ty) * dy
      local nz = idx[K(x, y)] or 3
      if a > -0.6 then c:put(x, y, DK[max(2, min(5, nz - 1))]) end
    end
  end end
  for _, s in ipairs{ -1.1, 1.1 } do
    local gx, gy = floor(tx + dx * 2.2 + px * s + 0.5), floor(ty + dy * 2.2 + py * s + 0.5)
    if M:has(gx, gy) then c:put(gx, gy, DK[1]) end
  end
  for _, s in ipairs{ -1.8, 0, 1.8 } do
    local gx, gy = floor(tx + dx * 3.7 + px * s + 0.5), floor(ty + dy * 3.7 + py * s + 0.5)
    if not M:has(gx, gy) then c:put(gx, gy, "#e8dcc4") end
  end
end

-- ===== ears
local function ear(m, cx, cy)
  m:each(function(x, y)
    local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    if d < 1.5 then c:put(x, y, DK[(x < cx or y < cy) and 3 or 2])
    elseif y < cy - 1.2 then c:put(x, y, CR[(x < cx) and 3 or 2]) end
  end)
end
ear(earL, 25, Y(8.4) + 0.6) ear(earR, 38, Y(8.4) + 0.6)

-- ===== face
local face = {
  ".......dd.......",
  ".......dd.......",
  "..cCC..dd..CCc..",
  ".cCCddddddddCCc.",
  "..ddeeddddeedd..",
  "..ddrrddddrrdd..",
  "..c.ddCCCCdd.c..",
  "...cCCCCCCCCc...",
  "....cCgNNNCc....",
  ".....cCNNCc.....",
  "......cssc......",
}
local pal = { d = DK[3], D = DK[2], c = CR[3], C = CR[4], s = CR[2], e = DK[1], r = "#b98a58", N = "#1b1220", g = CR[5] }
local fy = floor(Y(14)) - 3
for r, row in ipairs(face) do for i = 1, #row do
  local ch = row:sub(i, i)
  if pal[ch] and M:has(23 + i, fy + r - 1) then c:put(23 + i, fy + r - 1, pal[ch]) end
end end
-- darker lower edge of the mask band on the shade (right) side
for _, p in ipairs{ { 37, fy + 3 }, { 36, fy + 5 }, { 38, fy + 4 } } do c:put(p[1], p[2], DK[2]) end

-- ===== quirk: a burr snagged in the flank fur
local burr = {
  ".K.K.",
  "KBhBK",
  ".BhdB",
  "KBddK",
  ".K.K.",
}
local bp2 = { K = "#4e2a1e", B = "#9a6238", h = "#d29a5a", d = "#6a3c28" }
for r, row in ipairs(burr) do for i = 1, #row do
  local ch = row:sub(i, i) if bp2[ch] then c:put(34 + i, Y(30) + r, bp2[ch]) end end end

A.save(c, "raccoon-pelt")
