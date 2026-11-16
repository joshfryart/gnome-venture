-- _scarf.lua: shared drawing for yarn-scarf (common) and yarn-scarf-lined (opus3 richness pass,
-- built on opus2/_scarf.lua). Both ranks are the same cut, loop, knot and stripes.
-- Same scarf as the game base: red and teal striped knit, looped round at the top, knotted, two
-- tails hanging (left longer, swinging out), fringed ends.
-- opus3: slimmer tubes like the base, narrower stripes, real knit texture (2 px stitch columns
-- with a groove between, each stitch lit upper-left), a rounded tied knot with wrap folds instead
-- of a flat band, asymmetric tails, rim light on the lit edges and a bounce line on the shade side.
-- rank = "common" | "lined"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local floor, abs, max, min, sqrt, atan = math.floor, math.abs, math.max, math.min, math.sqrt, math.atan

local RED = { "#541c32", "#86283a", "#b23c3e", "#d65a46", "#ee7c5a", "#ffa47c" }
local TEAL = { "#18303f", "#1f5258", "#2b7a72", "#3c9e8c", "#66c2a6", "#a6e4c8" }
local WOOD = { "#4a2a26", "#704030", "#985a3a", "#bd7c4c", "#dca266", "#f2c88a" }
local DARK = "#3c1a26"

return function(rank)
  local c = W.new("yarn-scarf" .. (rank == "common" and "" or "-" .. rank))
  local lined = rank == "lined"
  local parts = {}

  -- knit a tube. T 0..1 along, S -1..1 across. Stitches: 2 px columns + 1 px groove across the
  -- tube, rows every 2 px along it; each stitch light top-left, dark bottom-right.
  local function knit(m, n, T, S, len, w, period, off, extra)
    local groups = { [RED] = { m = HP.mask(), b = {} }, [TEAL] = { m = HP.mask(), b = {} } }
    m:each(function(x, y)
      local k = K(x, y)
      local u = T[k] * len
      local ramp = (floor((u + (off or 0)) / period) % 2 == 0) and RED or TEAL
      local g = groups[ramp]
      g.m:set(x, y)
      local a = floor((S[k] + 1) * w + 0.5) % 3
      local r = floor(u) % 2
      if a == 2 then W.addBias(g.b, x, y, -1)
      elseif a == 0 and r == 0 then W.addBias(g.b, x, y, 1)
      elseif a == 1 and r == 1 then W.addBias(g.b, x, y, -1) end
      -- stripe edges: a shade row where a stripe turns over (reads as a colour change in the knit)
      if floor((u + (off or 0)) % period) == 0 then W.addBias(g.b, x, y, -1) end
      if extra then extra(g.b, x, y, u, S[k]) end
    end)
    for ramp, g in pairs(groups) do
      W.lit(c, g.m, n, ramp, { bias = g.b, amb = 0.1, wrap = 0.3 })
      parts[#parts + 1] = { g.m, ramp }
    end
  end

  -- ===== 1. the loop round the neck (a ring seen from the front, slightly from above)
  local cx, cy, rx, ry, ri = 31.5, 12, 13.5, 9.5, 0.52
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
  knit(ring, rn, rT, rS, 70, 3, 5, 1, function(b, x, y) if y < cy - 3 then W.addBias(b, x, y, -1) end end)

  -- ===== 2. right tail (behind, shorter), 3. left tail (in front, longer, swings out)
  local rtm, rtn, rtT, rtS = W.tube({ { 36, 20 }, { 41, 27 }, { 44, 36 }, { 43, 46 } }, function(t) return 3.4 + t * 0.4 end)
  local ltm, ltn, ltT, ltS = W.tube({ { 28, 20 }, { 22, 28 }, { 17, 39 }, { 18, 51 } }, function(t) return 3.4 + t * 0.5 end)
  knit(rtm, rtn, rtT, rtS, 36, 3.6, 5, 2, function(b, x, y) if ltm:has(x - 1, y) or ltm:has(x - 2, y) then W.addBias(b, x, y, -1) end end)
  knit(ltm, ltn, ltT, ltS, 42, 3.8, 5, 0)
  W.sep(c, ltm, rtm:copy():cut(ltm), DARK)
  W.sep(c, rtm:copy():cut(ltm), ring:copy():cut(rtm):cut(ltm), DARK)
  W.sep(c, ltm, ring:copy():cut(ltm), DARK)

  -- ===== 4. the knot: a rounded wrap over both tails, knit rows run round it
  local km, kn = W.oval(32, 21, 5.6, 4.6, 0)
  -- shadow on the ring and tails under the knot (lower right)
  km:shift(1, 2):cut(km):each(function(x, y)
    local h = W.get(c, x, y)
    for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(x, y, R[max(1, i - 2)]) end end end
  end)
  local kT, kS = {}, {}
  km:each(function(x, y) kT[K(x, y)] = (x + .5 - 26) / 12 kS[K(x, y)] = (y + .5 - 21) / 5 end)
  knit(km, kn, kT, kS, 12, 4.6, 4, 2)
  -- wrap folds: two curved creases where the wrap tucks in, each with a lit lip
  for _, p in ipairs{ { 29, 18 }, { 28, 19 }, { 28, 20 }, { 28, 21 }, { 28, 22 }, { 29, 23 }, { 35, 18 }, { 36, 19 }, { 36, 20 }, { 36, 21 }, { 36, 22 }, { 35, 23 } } do
    local h = W.get(c, p[1], p[2])
    for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(p[1], p[2], R[max(1, i - 3)]) end end end
  end
  for _, p in ipairs{ { 30, 18 }, { 29, 20 }, { 29, 21 } } do W.step(c, p[1], p[2], RED, 2) W.step(c, p[1], p[2], TEAL, 2) end
  W.sep(c, km, ring:copy():add(ltm):add(rtm):cut(km), DARK)

  -- ===== 5. ends: fringe (common) or fleece cuffs (lined)
  local function bottoms(m, T)
    local t = {}
    m:each(function(x, y) if T[K(x, y)] and T[K(x, y)] > 0.8 and (not t[x] or y > t[x]) then t[x] = y end end)
    -- keep only columns whose bottom is the tube's true end (not a side edge)
    local ymax = -1
    for _, y in pairs(t) do ymax = max(ymax, y) end
    for x, y in pairs(t) do if y < ymax - 2 then t[x] = nil end end
    return t
  end
  local lb, rbt = bottoms(ltm, ltT), bottoms(rtm, rtT)

  -- rim light on the lit edges, bounce line on the shade edges (before the ends are added)
  for _, p in ipairs(parts) do W.rimb(c, p[1], p[2], { rimMax = 6 }) end

  if not lined then
    for _, set in ipairs{ { lb, RED }, { rbt, TEAL } } do
      for x, y in pairs(set[1]) do
        if x % 2 == 0 then
          local L = 3 + floor(X.hash(x, y, 5) * 2.5)
          for j = 1, L do c:put(x, y + j, set[2][(j <= 1) and 2 or ((j % 2 == 0) and 4 or 5)]) end
          c:put(x, y + L, set[2][2])
        end
      end
    end
  else
    for _, set in ipairs{ lb, rbt } do
      local fm = HP.mask()
      local x0, x1 = 99, -1
      for x in pairs(set) do x0, x1 = min(x0, x), max(x1, x) end
      for x, y in pairs(set) do
        for j = -4, 1 do fm:set(x, y + j) end
        if x % 3 ~= 1 then fm:set(x, y + 2) end
      end
      -- fleece bulges past the knit by a pixel either side (a cuff, not a stripe)
      local y0 = set[x0] - 3
      for j = 0, 4 do fm:set(x0 - 1, y0 + j) fm:set(x1 + 1, y0 + j) end
      W.fleece(c, fm, 17 + x0)
      for x = x0, x1 do
        local yy = set[x] - 5
        local h = W.get(c, x, yy)
        for _, R in ipairs{ RED, TEAL } do for i, v in ipairs(R) do if v == h then c:put(x, yy, R[max(1, i - 2)]) end end end
      end
    end
    -- fleece lining turned over the inner rim of the loop (the neck opening), 3 px
    local inner = c:ellipse(cx, cy + 0.5, rx * ri + 3, ry * ri + 3):clip(ring)
    inner:cut(km)
    W.fleece(c, inner, 23)
    -- the knit's edge where the lining folds over it
    ring:copy():cut(inner):cut(km):each(function(x, y)
      if inner:has(x + 1, y) or inner:has(x - 1, y) or inner:has(x, y + 1) or inner:has(x, y - 1) then
        W.step(c, x, y, RED, -2) W.step(c, x, y, TEAL, -2)
      end
    end)
  end

  if not lined then
    -- quirk: a wooden knitting needle still threaded through the right tail, red ball end and all
    local nd = W.tube({ { 34, 48 }, { 40, 45.5 }, { 46, 43 }, { 53, 40 } }, function() return 0.9 end)
    local ndn = X.pillow(nd, 1)
    local hidden = HP.mask()
    nd:each(function(x, y) if x >= 40 and x <= 45 then hidden:set(x, y) end end)
    nd:cut(hidden)
    W.lit(c, nd, ndn, WOOD, { amb = 0.2 })
    local ball, bn = W.oval(55, 39, 2.2, 2.2, 0)
    W.lit(c, ball, bn, RED, { amb = 0.15 })
    c:put(54, 38, RED[6])
    -- the working yarn: a loose loop off the needle tip
    for _, p in ipairs{ { 33, 49 }, { 32, 50 }, { 32, 51 }, { 33, 52 }, { 34, 53 }, { 34, 54 }, { 33, 55 }, { 32, 56 } } do c:put(p[1], p[2], TEAL[4]) end
    c:put(32, 51, TEAL[5])
  else
    -- quirk: a darned pink heart patch on the left tail, cross-stitched in place
    W.paint(c, 14, 34, {
      ".dd.dd.",
      "dabdbcd",
      "dbebecd",
      ".dbbcd.",
      "..dcd..",
      "...d...",
    }, { a = "#ffc4d8", b = "#f5809f", c = "#c94f84", d = "#6a2450", e = "#ffe0ea" })
  end
  return c
end
