-- _scarf.lua: shared drawing for yarn-scarf (common) and yarn-scarf-lined (opus2 full redraw).
-- Same scarf as the game base: red and teal striped knit, looped round at the top, knotted,
-- two tails hanging, fringed ends. Knit is drawn as stitch chevrons that follow each tube.
-- rank = "common" | "lined"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local floor, abs, max, min, sqrt, atan = math.floor, math.abs, math.max, math.min, math.sqrt, math.atan

local RED = { "#58202e", "#882c38", "#b23c3e", "#d65a46", "#ee7c5a", "#ffa47c" }
local TEAL = { "#173640", "#1f5658", "#2b7a72", "#3c9e8c", "#66c2a6", "#a6e4c8" }
local WOOD = { "#4a2a26", "#704030", "#985a3a", "#bd7c4c", "#dca266", "#f2c88a" }

local function stripe(u, period, off)
  return (floor((u + (off or 0)) / period) % 2 == 0) and RED or TEAL
end

return function(rank)
  local c = W.new("yarn-scarf" .. (rank == "common" and "" or "-" .. rank))
  local lined = rank == "lined"

  -- knit a tube: m, n, T, S from W.tube; len in px; w half width; period of stripes; colour by u
  local function knit(m, n, T, S, len, w, period, off, extra)
    local groups = { [RED] = { m = HP.mask(), b = {} }, [TEAL] = { m = HP.mask(), b = {} } }
    m:each(function(x, y)
      local k = K(x, y)
      local u = T[k] * len
      local ramp = stripe(u, period, off)
      local g = groups[ramp]
      g.m:set(x, y)
      -- stitch chevrons (V pointing down the tube) and a rib groove up the middle
      local ph = (u + abs(S[k]) * w * 0.9) % 3
      if ph < 1 then W.addBias(g.b, x, y, -1) elseif ph < 2 and X.hash(x, y, 3) < 0.7 then W.addBias(g.b, x, y, 1) end
      if abs(S[k]) < 0.12 then W.addBias(g.b, x, y, -1) end
      if extra then extra(g.b, x, y, u, S[k]) end
    end)
    for ramp, g in pairs(groups) do W.lit(c, g.m, n, ramp, { bias = g.b, amb = 0.1, wrap = 0.3 }) end
  end

  -- ===== 1. the loop round the neck (a ring seen from the front, slightly from above)
  local cx, cy, rx, ry, ri = 31.5, 11, 14.5, 9.5, 0.48
  local ring = c:ellipse(cx, cy, rx, ry):cut(c:ellipse(cx, cy + 0.5, rx * ri, ry * ri))
  local rn, rT, rS = {}, {}, {}
  ring:each(function(x, y)
    local dx, dy = (x + .5 - cx) / (rx + .5), (y + .5 - cy) / (ry + .5)
    local r = sqrt(dx * dx + dy * dy)
    local s = max(-.95, min(.95, (r - (1 + ri) / 2) / ((1 - ri) / 2)))
    local th = atan(dy, dx)
    local k = K(x, y)
    rn[k] = { W.norm(math.cos(th) * s, math.sin(th) * s, sqrt(1 - s * s)) }
    rT[k] = (th + math.pi) / (2 * math.pi)
    rS[k] = s
  end)
  -- back half of the loop (top) sits in shade: bias -1
  knit(ring, rn, rT, rS, 64, 4, 6, 1, function(b, x, y) if y < cy - 2 then W.addBias(b, x, y, -1) end end)

  -- ===== 2. right tail (behind), 3. left tail (in front)
  local rtm, rtn, rtT, rtS = W.tube({ { 37, 19 }, { 42, 26 }, { 45, 37 }, { 44, 51 } }, function(t) return 4.2 + t * 0.6 end)
  local ltm, ltn, ltT, ltS = W.tube({ { 27, 19 }, { 22, 28 }, { 18, 39 }, { 19, 52 } }, function(t) return 4.2 + t * 0.6 end)
  local rb = {}
  knit(rtm, rtn, rtT, rtS, 40, 4.5, 6, 2, function(b, x, y) if ltm:has(x - 1, y) or ltm:has(x - 2, y) then W.addBias(b, x, y, -1) end end)
  knit(ltm, ltn, ltT, ltS, 40, 4.5, 6, 0)

  -- ===== 4. the knot over both tails, a squashed oval with its own wrap
  local km, kn = W.oval(32, 21, 7.5, 5, -0.1)
  local kb = {}
  local kr, kt = HP.mask(), HP.mask()
  km:each(function(x, y)
    if (x + y) % 3 == 0 then W.addBias(kb, x, y, -1) end
    if x >= 30 and x <= 33 then kt:set(x, y) else kr:set(x, y) end
  end)
  -- shadow on the ring and tails under the knot
  km:shift(1, 2):cut(km):each(function(x, y) if ring:has(x, y) or ltm:has(x, y) or rtm:has(x, y) then
    local h = W.get(c, x, y)
    for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(x, y, R[max(1, i - 2)]) end end end
  end end)
  W.lit(c, kr, kn, RED, { bias = kb, amb = 0.12 })
  W.lit(c, kt, kn, TEAL, { bias = kb, amb = 0.12 })
  -- dark wrap line round the knot so it sits proud of the loop and tails
  W.sep(c, km, ring:copy():add(ltm):add(rtm):cut(km), "#3c1a26")
  -- wrap folds on the knot
  for _, p in ipairs{ { 29, 18 }, { 29, 19 }, { 28, 20 }, { 28, 21 }, { 28, 22 }, { 35, 18 }, { 35, 19 }, { 36, 20 }, { 36, 21 }, { 36, 22 } } do
    local h = W.get(c, p[1], p[2])
    for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(p[1], p[2], R[max(1, i - 2)]) end end end
  end
  -- separation line where the left tail crosses over the right one
  W.sep(c, ltm, rtm:copy():cut(ltm), "#3c1a26")
  local ltOnly = ltm:copy():cut(km)
  ltOnly:each(function(x, y) if rtm:has(x + 1, y) and not ltm:has(x + 1, y) then c:put(x, y, "#3c1a26") end end)

  -- ===== 5. ends: fringe (common) or fleece cuffs (lined)
  local function bottoms(m)
    local t = {}
    m:each(function(x, y) if not t[x] or y > t[x] then t[x] = y end end)
    for x, y in pairs(t) do if y < 47 then t[x] = nil end end
    return t
  end
  local lb, rbt = bottoms(ltm), bottoms(rtm)
  if not lined then
    for _, set in ipairs{ { lb, RED }, { rbt, TEAL } } do
      for x, y in pairs(set[1]) do
        if x % 2 == 0 then
          local L = 3 + floor(X.hash(x, y, 5) * 2.5)
          for j = 1, L do c:put(x, y + j, set[2][(j <= 1) and 3 or ((j % 2 == 0) and 4 or 5)]) end
          c:put(x, y + L, set[2][2])
        end
      end
    end
  else
    for _, set in ipairs{ lb, rbt } do
      local fm = HP.mask()
      for x, y in pairs(set) do
        for j = -3, 1 do fm:set(x, y + j) end
        if x % 3 ~= 1 then fm:set(x, y + 2) end
      end
      -- fleece bulges past the knit by a pixel either side (it is a cuff, not a stripe)
      local x0, x1 = 99, -1
      for x in pairs(set) do x0, x1 = min(x0, x), max(x1, x) end
      local y0 = set[x0] - 2
      for j = 0, 3 do fm:set(x0 - 1, y0 + j) fm:set(x1 + 1, y0 + j) end
      W.fleece(c, fm, 17 + x0)
      -- contact shade on the knit just above the cuff
      for x = x0, x1 do
        local yy = set[x] - 4
        local h = W.get(c, x, yy)
        for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(x, yy, R[max(1, i - 2)]) end end end
      end
    end
    -- fleece lining showing on the inner rim of the loop (the neck opening)
    local inner = c:ellipse(cx, cy + 0.5, rx * ri + 2, ry * ri + 2):clip(ring)
    inner:cut(km)
    W.fleece(c, inner, 23)
  end

  if not lined then
    -- quirk: a wooden knitting needle still threaded through the right tail, ball end and all
    local nd = W.tube({ { 35, 50 }, { 41, 47.5 }, { 47, 45 }, { 53, 42.5 } }, function() return 0.9 end)
    local ndn = X.pillow(nd, 1)
    local hidden = HP.mask()
    nd:each(function(x, y) if x >= 40 and x <= 44 then hidden:set(x, y) end end)
    nd:cut(hidden)
    W.lit(c, nd, ndn, WOOD, { amb = 0.2 })
    local ball, bn = W.oval(55, 41.5, 2, 2, 0)
    W.lit(c, ball, bn, RED, { amb = 0.15 })
    c:put(54, 40, RED[6])
    -- the working yarn: a loose loop from the needle tip
    for _, p in ipairs{ { 34, 51 }, { 33, 52 }, { 33, 53 }, { 34, 54 }, { 35, 55 }, { 35, 56 }, { 34, 57 } } do c:put(p[1], p[2], TEAL[4]) end
  else
    -- quirk: a darned heart patch on the left tail
    W.paint(c, 16, 35, {
      ".dd.dd.",
      "dabdbcd",
      "dbbbbcd",
      ".dbbcd.",
      "..dcd..",
      "...d...",
    }, { a = "#ffc4d8", b = "#f5809f", c = "#c94f84", d = "#7d2c5e" })
  end
  return c
end
