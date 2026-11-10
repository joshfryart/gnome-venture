-- golem: stone giants, FRONT view. Parts (back to front): legL, legR, body, armL, armR, head (+ eyes).
-- Stacked boulders with chiselled planes (a lit facet upper left, strata lines), a carved face in deep sockets, heavy fists with knuckles.
-- Spec features: moss (lichen cap, shoulder and knee patches in the accent colour), crack (a jagged split through head and chest),
--   crystal (shards in the accent colour growing from the crown and the shoulders; bosses grow a third, taller one).
-- Sub-kinds: none; size is read from g.u (bosses, u >= 1.8, get extra strata, a chin of rubble and a bigger rune).
-- Quirks (quirks/golem.lua): flower = a little flower grows out of the moss on its head; monocle = a glass ring over its right eye;
--   goldtooth = one tooth in its grim mouth is gold.
return function(L)
  local P = L.P
  local HP = L.HP
  local rect = HP.rect
  return function(g)
    local c, f, q, B, A, u = g.c, g.f, g.q, g.B, g.A, g.u
    local boss = u >= 1.8
    local fs = (B == L.R.night) and 0.55 or 1   -- the deep purple needs a narrower shade band to keep its planes readable
    local DK = L.darker(B)
    g:shadow(0, 22)

    -- a little tuft of lichen lying on a mask: a blob of the accent colour with a lit top and a hanging fringe
    local function lichen(m, host)
      m:clip(host)
      g:form(m, A, { frac = 0.3, off = 1, inner = false })
      g:toplight(m, A, 1)
      local x0, y0, x1, y1 = m:bbox(); if not x0 then return end
      for x = x0 + 1, x1 - 1, 3 do for y = y1, y0, -1 do if m:has(x, y) then
        if host:has(x, y + 1) then c:put(x, y + 1, A.shade) end
        if g:rnd(x, y) > 0.5 and host:has(x, y + 2) then c:put(x, y + 2, A.deep) end
        break end end end
    end
    -- a crystal shard: base centre (a, b), height h, half width w, leaning by `lean` units; lit left facet, dark right facet, a pale tip
    local function shard(a, b, h, w, lean)
      local m = g:P({ { a - w, b }, { a - w * 0.8, b + h * 0.7 }, { a + lean, b + h }, { a + w * 0.8, b + h * 0.75 }, { a + w, b } })
      g:fill(m, A.base)
      local x0, y0, x1, y1 = m:bbox()
      local mid = g:x(a + lean * 0.4)
      m:each(function(x, y)
        if x < mid - 1 then c:put(x, y, A.hi) elseif x > mid + 1 then c:put(x, y, A.shade) end
        if not m:has(x, y + 1) then c:put(x, y, A.deep) end
      end)
      c:put(g:x(a + lean), g:y(b + h) + 1, P.cream)
      return m
    end
    -- a jagged crack through a part: points in units; deep line with a lit lower edge
    local function crack(pts, host)
      local m = g:Ln1(pts, 1)
      m:clip(host)
      m:each(function(x, y) if host:has(x + 1, y + 1) and not m:has(x + 1, y + 1) then L.inside(c, x + 1, y + 1, B.hi, B.base, B.shade) end end)
      g:fill(m, P.ink)
      m:each(function(x, y) if f.crystal and (x + y) % 5 == 0 then c:put(x, y, A.shade) end end)
    end

    -- legs: boulder stumps with a wide toe block, toe seams and a knee crease
    local legs = {}
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "legL" or "legR")
      local m = g:P({ { s * 2, 10 }, { s * 11, 10 }, { s * 11.5, 4 }, { s * 12.5, 3 }, { s * 12.5, 0.5 }, { s * 11, 0 }, { s * 2.5, 0 }, { s * 1.5, 1.5 }, { s * 2, 4 } })
      legs[s] = m
      g:form(m, B, { frac = (s > 0 and 0.38 or 0.25) * fs, offu = 2, pop = { { s * 4.5, 8.5 } } })
      g:under(m, B.deep) g:toplight(m, B, 1)
      -- a lit facet on the thigh, a crease at the knee, toe seams
      g:over(g:P({ { s * 3, 9.5 }, { s * 8, 9.5 }, { s * 3.5, 6 } }), B.hi, B.base)
      g:mark({ { s * 2.5, 5.2 }, { s * 6, 4.4 }, { s * 11, 5 } }, B.shade, B.base, B.hi)
      g:mark({ { s * 6.8, 2.8 }, { s * 6.8, 0.5 } }, B.deep, B.base, B.shade) g:mark({ { s * 9.4, 3 }, { s * 9.4, 0.5 } }, B.deep, B.base, B.shade)
      g:dots({ { s * 10.5, 7.5 }, { s * 4, 3 } }, B.shade)                               -- pits in the rock
      if f.moss then lichen(g:E(s * 8, 9.6, 3.2, 1.6), m) end                            -- lichen on the knee
    end

    -- body: a big chamfered boulder with strata, a lit plane, carved rune, belt of rubble
    g:T("body")
    local body = g:P({ { -10.5, 8 }, { -13, 11 }, { -14, 21 }, { -11, 26 }, { 11, 26 }, { 14, 21 }, { 13, 11 }, { 10.5, 8 } })
    g:form(body, B, { frac = 0.3 * fs, offu = 3, pop = { { -9, 23 } } })
    g:under(body, B.deep) g:belly(body, B, 2.2) g:toplight(body, B, 1)
    g:over(g:P({ { -12.5, 23 }, { -6, 25.5 }, { -3, 22 }, { -9, 17 }, { -12.5, 18 } }), B.hi, B.base)       -- the lit plane of the chest
    g:mark({ { -13, 20.5 }, { -9, 20 }, { -5, 21.2 } }, B.base, B.hi)                                      -- its chiselled lower edge
    g:mark({ { -13.5, 14.5 }, { -8, 15.5 }, { -3, 14 }, { 3, 15.2 }, { 8, 13.8 }, { 13, 14.6 } }, B.shade, B.base, B.hi, B.shade)   -- strata
    g:mark({ { -12.5, 11.2 }, { -6, 10.4 }, { 2, 11.4 }, { 9, 10.6 }, { 12.5, 11.4 } }, B.deep, B.base, B.shade)
    if boss then g:mark({ { -13.8, 18 }, { -9, 18.8 }, { -4.5, 17.4 }, { 1, 18.6 }, { 5, 17.5 } }, B.shade, B.base, B.hi) end
    for i = 1, 14 do local a, b = (g:rnd(i, 21) - .5) * 24, 9 + g:rnd(i, 22) * 15; g:inside(a, b, B.shade, B.base) g:inside(a + 0.8, b + 0.8, B.hi, B.base) end   -- pits and grit
    -- the carved rune: a gold diamond with a plus cut into it
    local rx, ry, rr = g:x(0.5), g:y(17.8), boss and 4 or 3
    for d = -rr, rr do
      local w = rr - math.abs(d)
      for k = -w, w do c:put(rx + k, ry + d, P.gold.base) end
      c:put(rx - w, ry + d, P.gold.deep) c:put(rx + w, ry + d, P.gold.deep)
    end
    for k = -rr + 2, rr - 2 do c:put(rx + k, ry, P.gold.hi) c:put(rx, ry + k, P.gold.hi) end
    c:put(rx, ry, P.cream)
    if f.crack then crack({ { -11.5, 25.5 }, { -9.5, 22.5 }, { -10.8, 20 }, { -8.5, 17 }, { -9.5, 14.5 }, { -7, 11.5 } }, body) end
    if f.moss then lichen(g:E(8.5, 24, 4.8, 2.2), body) lichen(g:E(-7, 12.4, 3.6, 1.6), body) end

    -- arms: a round shoulder, a thick forearm, a heavy fist with knuckles and a thumb
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "armL" or "armR")
      local m = g:E(s * 16, 23, 4.4, 3.8)
      m:add(g:Limb({ { s * 16, 22 }, { s * 16.4, 16 } }, 5.6, 6.2))
      m:add(g:RR(s * 16 - 4.6, 10.4, s * 16 + 4.6, 17.5, 2))
      g:form(m, B, { frac = (s > 0 and 0.4 or 0.28) * fs, offu = 2, pop = { { s * 14.5, 24.5 } } })
      g:under(m, B.deep) g:toplight(m, B, 1)
      g:over(g:P({ { s * 13.2, 25 }, { s * 17, 25.5 }, { s * 14, 21 } }), B.hi, B.base)
      g:mark({ { s * 12.2, 18.4 }, { s * 16, 17.6 }, { s * 20.4, 18.2 } }, B.deep, B.base, B.shade, B.hi)   -- the wrist band
      for i = -1, 1 do g:mark({ { s * 16.2 + i * 2.6, 14.6 }, { s * 16.2 + i * 2.6, 11.2 } }, B.shade, B.base, B.hi) end   -- knuckles
      g:dots({ { s * 14.8 - 1, 16 }, { s * 17.4, 16 } }, B.hi)
      g:dots({ { s * 13.8, 20.5 }, { s * 18.4, 21.6 }, { s * 15.5, 23 } }, B.shade)
      if f.crystal then shard(s * 16.3, 25.4, boss and 8 or 6, 1.5, s * 0.8) shard(s * 18.6, 24.4, 4, 1, s * 1.4) end   -- shards pushing out of the shoulder
      if f.moss then lichen(g:E(s * 16, 25, 3.6, 1.6), m) end
    end

    -- head: a squared boulder with an overhanging brow, deep eye sockets, a nose ridge and a grim mouth
    g:T("head")
    local head = g:P({ { -8.5, 25 }, { -10, 28 }, { -10.8, 37 }, { -8.5, 40 }, { 8.5, 40 }, { 10.8, 37 }, { 10, 28 }, { 8.5, 25 } })
    g:form(head, B, { frac = 0.28 * fs, offu = 3, pop = { { -8, 38 } } })
    g:under(head, B.deep) g:toplight(head, B, 1)
    g:over(g:P({ { -10.2, 38 }, { -3, 39.6 }, { -6, 36.5 }, { -10.2, 35.5 } }), B.hi, B.base)
    g:fill(g:R(-9.8, 35.4, 9.8, 36.4), B.shade)                                      -- the brow ledge: a dark underside ...
    g:mark({ { -10, 36.8 }, { 10, 36.8 } }, B.base, B.shade, B.hi)                   -- ... under a pale lip
    local eyes = { { -4.5, 33 }, { 5, 33 } }
    for _, e in ipairs(eyes) do   -- sockets, then (below) the eyes themselves
      local ex, ey = g:x(e[1]), g:y(e[2])
      c:fillMask(rect(ex - 3, ey - 3, ex + 2, ey + 2), B.deep)
      c:put(ex - 3, ey - 3, B.shade) c:put(ex + 2, ey - 3, B.shade) c:put(ex - 3, ey + 2, B.shade) c:put(ex + 2, ey + 2, B.shade)
    end
    g:fill(g:R(0, 27.5, 1.6, 33), B.base)                                             -- the nose ridge, lit on its left, dark on its right
    g:fill(g:R(1.6, 27.5, 2.4, 33), B.shade) g:put(0, 33, B.hi) g:put(0, 31, B.hi)
    g:dots({ { -0.2, 27.2 }, { 2.2, 27.2 } }, B.deep)
    -- mouth: a deep carved slot with stone teeth
    local mouth = g:R(-5.5, 26.2, 6.5, 28.2); g:fill(mouth, B.deep)
    local mx0, mx1, my = g:x(-5.5), g:x(6.5), g:y(28.2)
    for x = mx0 + 1, mx1 - 1, 3 do c:put(x, my, B.base) c:put(x + 1, my, B.hi) if x + 3 < mx1 then c:put(x, my + 1, B.base) end end
    if q.goldtooth then c:put(mx0 + 7, my, P.gold.base) c:put(mx0 + 8, my, P.gold.hi) c:put(mx0 + 7, my + 1, P.gold.shade) end
    g:dots({ { -9, 30 }, { 9, 31 }, { -8, 38.4 } }, B.shade)
    g:dots({ { -7.5, 29.5 }, { 8, 29 } }, P.petal.base)                               -- the faintest blush (even stone has cheeks)
    if f.crack then crack({ { 2.5, 40 }, { 1, 38.5 }, { 3, 36.4 }, { 1.6, 34.5 } }, head) crack({ { 8, 28.5 }, { 6.5, 30.5 }, { 7.6, 32.2 } }, head) end
    if boss then g:dots({ { -3, 26.3 }, { 3, 26.5 }, { 0, 25.6 } }, B.deep) end   -- rubble stuck to the chin
    g:T("eyes")
    for _, e in ipairs(eyes) do g:eye(e[1], e[2]) end
    g:T("head")
    -- brows: heavy slabs slanting over each socket
    for i, e in ipairs(eyes) do
      local ex, ey = g:x(e[1]), g:y(e[2])
      for k = -3, 2 do   -- slants down toward the nose: angry
        local rise = (i == 1) and (k < 0 and 1 or 0) or (k > -1 and 0 or 1)
        c:put(ex + k, ey - 4 - rise, B.deep) c:put(ex + k, ey - 5 - rise, B.shade)
      end
    end
    if q.monocle then   -- a glass ring over its right eye, with a chain
      local ex, ey = g:x(5), g:y(33)
      local ring = HP.ellipse(ex - 0.5, ey - 0.5, 4, 4); ring:cut(HP.ellipse(ex - 0.5, ey - 0.5, 2.6, 2.6))
      c:fillMask(ring, P.gold.base)
      ring:each(function(x, y) if not ring:has(x, y + 1) then c:put(x, y, P.gold.shade) end end)
      c:put(ex - 3, ey - 3, P.cream) c:put(ex + 2, ey + 2, A.hi)
      for i = 1, 5 do c:put(ex + 3, ey + 3 + i, P.gold.base) end
    end
    -- lichen cap and a crown of crystals on the head
    if f.moss then
      local cap = g:E(0, 39.6, 9.2, 2.6)
      cap:add(g:E(-5, 41, 3.6, 1.6)) cap:add(g:E(4.5, 41.2, 3, 1.4))
      g:form(cap, A, { frac = 0.3, off = 1, inner = false }) g:toplight(cap, A, 1)
      for x = g:x(-8), g:x(8), 3 do
        c:put(x, g:y(37.6), A.base) if g:rnd(x, 2) > .4 then c:put(x, g:y(37.6) + 1, A.shade) end
        c:put(x + 1, g:y(38.2), A.shade)
      end
      c:fillMask(rect(g:x(-8), g:y(37.4), g:x(-6.5), g:y(37.4) + 2), A.shade) c:put(g:x(-8), g:y(37.4), A.base)
      if q.flower then   -- a flower grows out of the moss: stem, two leaves, a petal head
        local fx, fy = g:x(4.5), g:y(42)
        for y = fy - 6, fy do c:put(fx, y, A.deep) end
        c:put(fx - 1, fy - 3, A.base) c:put(fx - 2, fy - 4, A.base) c:put(fx + 1, fy - 2, A.base) c:put(fx + 2, fy - 3, A.base)
        for _, d in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do c:put(fx + d[1], fy - 8 + d[2], P.petal.base) end
        c:put(fx, fy - 8, P.gold.base) c:put(fx - 1, fy - 9, P.petal.hi)
      end
    end
    if f.crystal then
      shard(-5.5, 38.5, boss and 11 or 9, 2.3, -1.2) shard(5, 38.5, boss and 13 or 10, 2.5, 1)
      if boss then shard(0, 39, 8, 1.8, 0.2) end
    end
    return { { "legL", false, -6.5, 8 }, { "legR", false, 6.5, 8 }, { "body", false, 0, 9 }, { "armL", "body", -16, 24 }, { "armR", "body", 16, 24 },
      { "head", "body", 0, 26 }, { "eyes", "head", 0.5, 33 } }
  end
end
