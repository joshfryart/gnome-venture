-- pickled-samphire (final, Opus C34-5). A tall slim cylinder bottle with a flanged lip, stoppered with a cork and a
-- twine wrap round the neck; inside, upright jointed samphire stems with little forked branches stand in pale
-- green-gold brine, a few peppercorns on the bottom.
-- Material: per-pixel lit brine + air (surface of revolution), glass wall, thick base, streaks, meniscus; samphire
-- stems as 2px cylinders with dark joints and a lit swelling above each; cork with pores and a paler end face; twine
-- twist; AO under the stems where they crowd the base.
-- quirk: a spare samphire sprig is tucked under the neck twine like a feather in a hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, max, min, sqrt = math.floor, math.abs, math.sin, math.max, math.min, math.sqrt
local c = A.new("pickled-samphire")

local GL    = { "#2c4c5c", "#4a7c84", "#7cb0a8", "#b0dcc8", "#d6f2e0", "#effbf0" }
local BRINE = { "#56703a", "#76904a", "#96ac5c", "#b4c676", "#cedc94", "#e4eeb6" }
local AIR   = { "#7e9aa4", "#a2bcbc", "#c4d8d2", "#dceae2", "#ebf5ee", "#f4faf4" }
local SAM   = { "#1a3e2c", "#285a34", "#3a763c", "#549446", "#78b252", "#a6ce66" }
local SAMB  = A.tint(SAM, "#c8d890", 0.14)
local CORK  = { "#4e2e22", "#7a4a30", "#a46c44", "#c48e5a", "#ddb07a", "#efcc9a" }
local TW    = { "#4e3022", "#7c5032", "#a8784a", "#cfa266", "#e8c68a" }
local PEP   = { "#241a1e", "#3a2a2a", "#5a4038", "#7a5a48" }

c:groundShadow(32, 56, 11, 1)
local J = A.jar(32, 17, 56, function(y)
  if y <= 17 then return 5.6 end
  if y <= 21 then return 4.6 end
  if y <= 26 then return 4.6 + (1 - math.cos((y - 21) / 5 * math.pi)) / 2 * 4.2 end
  if y >= 54 then return 8.8 - (y - 53) ^ 1.4 * 0.7 end
  return 8.8
end)
A.back(c, J, BRINE, AIR, 27)
local IN = J.inner:copy()
local stok = { r = { name = "samphire" } }

-- one jointed stem: list of points bottom->top, 2px wide, joints every `seg` px
local function stem(pts, seg, branches)
  local P = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for s = (i == 1 and 0 or 1), n do P[#P + 1] = { floor(a[1] + (b[1] - a[1]) * s / n + .5), floor(a[2] + (b[2] - a[2]) * s / n + .5) } end
  end
  for j, p in ipairs(P) do
    local x, y = p[1], p[2]
    local R = y >= J.level and SAMB or SAM
    local joint = (j % seg == 0)
    local swell = (j % seg == 1)
    local l, r = joint and 3 or (swell and 6 or 5), joint and 1 or (swell and 3 or 2)
    if j == #P then l, r = 6, 4 end
    if IN:has(x, y) then c:put(x, y, R[l], stok) end
    if IN:has(x + 1, y) and j < #P then c:put(x + 1, y, R[r], stok) end
  end
  for _, b in ipairs(branches or {}) do
    local p = P[b[1]]
    local x, y, d = p[1] + (b[2] > 0 and 1 or 0), p[2], b[2]
    for s = 1, b[3] do
      x, y = x + d, y - 1
      local R = y >= J.level and SAMB or SAM
      if IN:has(x, y) then c:put(x, y, R[s == b[3] and 6 or (d < 0 and 5 or 3)], stok) end
      if s < b[3] and IN:has(x, y + 1) and d > 0 then c:put(x, y + 1, R[2], stok) end
    end
  end
end
-- back stems first (darker), then front
stem({ { 27, 53 }, { 26, 40 }, { 27, 29 } }, 4, { { 9, -1, 3 }, { 18, 1, 2 } })
stem({ { 36, 53 }, { 37, 42 }, { 36, 30 } }, 4, { { 7, 1, 3 }, { 15, -1, 2 } })
stem({ { 31, 53 }, { 30, 38 }, { 31, 24 } }, 5, { { 11, -1, 3 }, { 20, 1, 3 }, { 25, -1, 2 } })
stem({ { 34, 53 }, { 34, 44 }, { 33, 33 }, { 34, 26 } }, 4, { { 6, 1, 2 }, { 16, -1, 3 }, { 23, 1, 2 } })
stem({ { 25, 53 }, { 24, 46 }, { 25, 37 } }, 3, { { 6, 1, 2 } })
stem({ { 38, 53 }, { 39, 47 }, { 38, 39 } }, 3, { { 5, -1, 2 } })
-- peppercorns on the base
for _, p in ipairs{ { 29, 52 }, { 33, 52 }, { 36, 51 }, { 27, 51 } } do
  c:put(p[1], p[2], PEP[3], stok) c:put(p[1] + 1, p[2], PEP[2], stok) c:put(p[1], p[2] + 1, PEP[2], stok) c:put(p[1] + 1, p[2] + 1, PEP[1], stok)
  c:put(p[1], p[2], PEP[4], stok)
end
-- AO along the base where the stems crowd
for x = 23, 41 do if IN:has(x, 53) then c:put(x, 53, BRINE[1], J.btok) end end

local GT = A.front(c, J, GL, { menisc = { BRINE[6], BRINE[5] }, s0 = 24, s1 = 50, gaps = { [37] = true, [38] = true }, r0 = 28, r1 = 34, wide = 12 })
-- lip flange highlight
c:put(27, 17, GL[6], GT) c:put(28, 17, GL[6], GT)

-- cork: tapered plug, paler end face, pores
local cork = HP.mask()
for y = 9, 18 do local h = (y <= 10) and 4.2 or (4.6 - (y - 10) * 0.08)
  for x = floor(32 - h), floor(32 + h) do if abs(x + 0.5 - 32) <= h then cork:set(x, y) end end end
cork:cut(c:rect(28, 9, 28, 9)) cork:cut(c:rect(36, 9, 36, 9))
local ctok = { r = { name = "cork" } }
local cn = {}
cork:each(function(x, y) local nx = max(-0.95, min(0.95, (x + 0.5 - 32) / 5)) cn[K(x, y)] = { nx, y <= 10 and -0.7 or 0, sqrt(1 - nx * nx) } end)
local idx = A.lit(c, cork, cn, CORK, { tok = ctok, cuts = { 0.18, 0.36, 0.55, 0.72, 0.9 } })
cork:each(function(x, y)
  if y <= 10 then c:put(x, y, x < 33 and CORK[6] or CORK[5], ctok) end
  if y == 11 then c:put(x, y, CORK[3], ctok) end
  if y > 11 and X.hash(x, y, 7) > 0.8 then c:put(x, y, CORK[max(1, idx[K(x, y)] - 2)], ctok) end
end)
c:put(31, 10, CORK[4], ctok) c:put(34, 9, CORK[4], ctok) -- pores on the end face
-- shadow where the cork enters the neck
for x = 27, 37 do if J.m:has(x, 18) then c:put(x, 18, GL[1], GT) end end

-- quirk: spare sprig tucked under the twine, pointing up-left
local qt = { r = { name = "sprig" } }
for _, p in ipairs{ { 27, 20, 3 }, { 26, 19, 4 }, { 25, 18, 3 }, { 25, 17, 5 }, { 24, 16, 4 }, { 24, 15, 5 }, { 23, 14, 3 }, { 23, 13, 5 }, { 22, 12, 6 },
  { 24, 18, 2 }, { 23, 16, 3 }, { 22, 16, 5 }, { 21, 15, 6 }, { 26, 15, 5 }, { 27, 14, 6 }, { 25, 15, 2 } } do
  c:put(p[1], p[2], SAM[p[3]], qt) end
-- twine wrapped round the neck (3 turns, twisted) with a short loose end
local ttok = { r = { name = "twine" } }
for y = 19, 21 do for x = 26, 38 do if J.m:has(x, y) or (x >= 27 and x <= 37) then
  local s = (x + 2 * y) % 3
  local i = (s == 0) and 2 or ((s == 1) and 4 or 3)
  if x >= 35 then i = i - 1 end
  if x <= 28 and y == 19 then i = i + 1 end
  c:put(x, y, TW[max(1, min(5, i))], ttok)
end end end
c:put(38, 21, TW[3], ttok) c:put(39, 22, TW[2], ttok) c:put(39, 23, TW[3], ttok) c:put(40, 24, TW[2], ttok)
A.fin(c)
