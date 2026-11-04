-- fennel (B31, Opus single pass). A Florence fennel: squat pale bulb built of overlapping sheaths (each sheath edge
-- bevelled: dark seam + lit lip, waxy cream bloom on the upper left), flat tan root plate with three root stubs,
-- three slim ribbed stalks fanning out of the neck (AO where they sink into it) and feathery thread-leaf fronds.
-- quirk: one stalk has bolted into a tiny yellow umbel flower.
local NAME = "fennel"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = G.new(NAME)

local BULB = { "#3f5c50", "#6c8d6c", "#9dbb8c", "#c6dcaa", "#e4eec6", "#f7f6df" }
local STALK = { "#23504a", "#3d7852", "#5f9e5a", "#8cc26a", "#bce08c", "#e0f2b4" }
local FROND = { "#1d4a3e", "#2e6c48", "#4e9a4e", "#7cc35a", "#b4e07c" }
local ROOT = { "#5a3a2c", "#8a6040", "#b88c5c", "#dcbc88" }
local YEL = { "#b06a1a", "#e8a724", "#ffd84a", "#fff1a0" }

-- stalks first (bulb neck will overlap their bases)
local stalks = {
  { { 29, 36 }, { 27, 26 }, { 21, 20 }, { 15, 15 } },
  { { 31, 35 }, { 31, 26 }, { 32, 18 }, { 32, 12 } },
  { { 33, 36 }, { 36, 27 }, { 41, 21 }, { 47, 16 } },
}
local SM = HP.mask()
local tips = {}
for i, p in ipairs(stalks) do
  local m, n, T, S = G.tube(p, function(t) return 1.45 - 0.5 * t end)
  local idx = G.shade(c, m, n, STALK, { amb = 0.12, wrap = 0.3 })
  -- rib: a darker groove line just right of centre along the stalk
  m:each(function(x, y) local k = K(x, y)
    if S[k] > 0.05 and S[k] < 0.4 and T[k] < 0.9 then c:put(x, y, STALK[max(1, idx[k] - 1)]) end end)
  SM:add(m)
  tips[i] = p[4]
end

-- fronds: fans of thread leaves, each thread forking once or twice
local FM = HP.mask()
local function thread(x0, y0, dx, dy, len, depth)
  local x, y = x0, y0
  for s = 1, len do
    x, y = x + dx, y + dy
    local xi, yi = floor(x + .5), floor(y + .5)
    local lit = (dx + dy < 0) and 1 or 0
    local tone = 3 + lit + ((s > len - 2) and 1 or 0) - ((s <= 1) and 1 or 0)
    c:put(xi, yi, FROND[max(1, min(5, tone))]) FM:set(xi, yi)
    if depth > 0 and (s == floor(len / 2) or s == len - 1) then
      local side = (s == floor(len / 2)) and 1 or -1
      local ca, sa = math.cos(0.75 * side), math.sin(0.75 * side)
      thread(x, y, dx * ca - dy * sa, dx * sa + dy * ca, max(2, floor(len / 2.4)), depth - 1)
    end
  end
end
local fans = {
  { 15, 15, { -2.5, -1.9, -1.3, -0.6, 0.0 }, 6 },
  { 32, 12, { -2.0, -1.4, -0.8, -0.2, 0.4 }, 6 },
  { 47, 16, { -1.6, -0.9, -0.3, 0.3, 0.9 }, 6 },
}
for fi, f in ipairs(fans) do
  for j, a in ipairs(f[3]) do
    if not (fi == 2 and j == 5) then
      local dx, dy = math.sin(a), -math.cos(a)
      thread(f[1], f[2], dx, dy, f[4] - ((j == 1 or j == 5) and 1 or 0), 1)
    end
  end
end

-- quirk: bolted umbel off the middle stalk (thin pedicel, five rays, yellow florets)
G.pline(c, { { 33, 22 }, { 37, 17 }, { 38, 13 } }, STALK[4])
local um = { { 36, 11, 3 }, { 37, 10, 4 }, { 38, 10, 4 }, { 39, 10, 3 }, { 40, 11, 2 }, { 35, 11, 2 },
             { 37, 9, 4 }, { 38, 9, 3 }, { 36, 10, 3 }, { 39, 11, 2 }, { 38, 11, 2 }, { 37, 11, 3 } }
for _, q in ipairs(um) do c:put(q[1], q[2], YEL[q[3]]) end
G.pline(c, { { 38, 12 }, { 36, 12 } }, STALK[3])
c:put(38, 12, STALK[3]) c:put(40, 12, STALK[3])

-- bulb: squat body + tapering neck
local BM = G.oval(31, 45, 10.2, 7.6, 0)
local neck = c:poly{ { 26, 31 }, { 36, 31 }, { 38, 40 }, { 24, 40 } }
BM:add(neck)
local rows = {}
BM:each(function(x, y) local r = rows[y] if not r then rows[y] = { x, x } else r[1], r[2] = min(r[1], x), max(r[2], x) end end)
local bn = {}
BM:each(function(x, y)
  local r = rows[y]
  local mid, hw = (r[1] + r[2] + 1) / 2, (r[2] - r[1] + 1) / 2
  local nx = max(-0.95, min(0.95, (x + 0.5 - mid) / hw))
  local ny = y > 41 and max(-0.4, min(0.92, (y - 45) / 8)) or -0.18
  bn[K(x, y)] = { G.norm(nx, ny, sqrt(max(0.05, 1 - nx * nx))) }
end)
local bidx = G.shade(c, BM, bn, BULB, { amb = 0.16, wrap = 0.35, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- sheath seams: curved lines that converge into the neck; dark seam + lit lip to its left (bevel)
local seams = { -0.62, -0.22, 0.3, 0.7 }
for _, b in ipairs(seams) do
  for y = 31, 51 do
    local r = rows[y]
    if r then
      local mid, hw = (r[1] + r[2] + 1) / 2, (r[2] - r[1] + 1) / 2
      local bend = b * (y < 41 and 0.85 or (0.85 + 0.15 * min(1, (y - 41) / 6)))
      local x = floor(mid + bend * hw + 0.5)
      if BM:has(x, y) and BM:has(x + 1, y) and BM:has(x - 1, y) and y < 51 then
        local k = K(x, y)
        c:put(x, y, BULB[max(1, (bidx[k] or 3) - 2)])
        local kl = K(x - 1, y)
        if b > 0 then c:put(x + 1, y, BULB[min(6, (bidx[K(x + 1, y)] or 3) + 1)])
        else c:put(x - 1, y, BULB[min(6, (bidx[kl] or 3) + 1)]) end
      end
    end
  end
end
-- waxy bloom: cream flecks on the upper-left of the body
for _, q in ipairs{ { 24, 42 }, { 25, 41 }, { 23, 44 }, { 27, 40 } } do if BM:has(q[1], q[2]) then c:put(q[1], q[2], BULB[6]) end end
-- cool reflected light on the lower-right rim
BM:edge():each(function(x, y) if x > 34 and y > 46 then c:put(x, y, "#7fa6a0") end end)
-- AO: stalk pixels right above the neck
G.touch(SM, BM):each(function(x, y) if not BM:has(x, y) then c:put(x, y, STALK[1]) end end)
for x = 26, 36 do if BM:has(x, 31) and SM:has(x, 30) then c:put(x, 31, BULB[2]) end end

-- root plate + stubs
local plate = c:rect(27, 52, 35, 53):cut(c:rect(27, 53, 27, 53)):cut(c:rect(35, 53, 35, 53))
plate:each(function(x, y) c:put(x, y, (y == 52) and ROOT[3] or ROOT[2]) end)
c:put(28, 52, ROOT[4]) c:put(29, 52, ROOT[4])
for x = 27, 35 do if BM:has(x, 51) then c:put(x, 51, BULB[1]) end end
G.pline(c, { { 29, 54 }, { 28, 56 } }, ROOT[2])
G.pline(c, { { 31, 54 }, { 31, 57 } }, ROOT[1])
G.pline(c, { { 33, 54 }, { 35, 56 } }, ROOT[2])

-- one glint on the bulb shoulder
c:put(25, 43, "#fff4d6") c:put(26, 43, "#fff4d6")

G.save(c, NAME)
