-- octo: the deep octopus, FRONT view. Parts (back to front): t1 .. t7 (arms, t1 left .. t7 right, hanging from under the body down to the ground and ending in a curl),
-- body (the domed mantle and head, with a siphon), eyes.
-- Spec features: spots (big lilac spots on the mantle, ringed; a scatter of small ones down the cheeks).
-- Every arm tapers, carries a column of suckers (accent colour) and curls its tip outward; alternate arms are the darker tone so neighbours do not melt together.
-- Quirks (quirks/octo.lua): pearl = the right-most arm (t7) curls its tip around a pearl.
return function(L)
  local P = L.P
  local HP = L.HP
  return function(g)
    local c, f, q, B, A = g.c, g.f, g.q, g.B, g.A
    g:shadow(0, 21)
    local bones = {}
    -- arms: a tapered limb from under the body, spreading outward, the tip curling like a spiral
    for i = -3, 3 do
      local id = "t" .. (i + 4)
      g:T(id)
      local a = i * 4.6
      local s = (i == 0) and 1 or (i < 0 and -1 or 1)
      local e = a * 1.2 + (i == 0 and 2 or 0)
      local pts = { { a * 0.6, 15 }, { a * 0.8, 9.5 }, { a * 1.05, 5.5 }, { e, 2.8 }, { e + s * 2.4, 1.7 }, { e + s * 4.2, 2.8 }, { e + s * 3.8, 4.8 } }
      local m = g:Limb(pts, 5.4, 1.1)
      local R = (i % 2 == 0) and g.D or B
      g:form(m, R, { frac = 0.3, off = 1, inner = false })
      g:under(m, R.deep) g:toplight(m, R, 1)
      -- suckers: pale pads down the middle of the arm, smaller toward the tip
      local tot, seg = 0, {}
      for k = 1, #pts - 1 do seg[k] = math.sqrt((pts[k + 1][1] - pts[k][1]) ^ 2 + (pts[k + 1][2] - pts[k][2]) ^ 2); tot = tot + seg[k] end
      local d = 8.5
      while d < tot - 1.5 do
        local acc, k = 0, 1
        while k < #seg and acc + seg[k] < d do acc = acc + seg[k]; k = k + 1 end
        local t = (d - acc) / seg[k]
        local pa, pb = pts[k][1] + (pts[k + 1][1] - pts[k][1]) * t, pts[k][2] + (pts[k + 1][2] - pts[k][2]) * t
        local w = 5.4 + (1.1 - 5.4) * d / tot
        local x, y = g:x(pa), g:y(pb)
        if w > 3 then
          for _, p in ipairs({ { 0, 0 }, { 1, 0 } }) do L.inside(c, x + p[1], y, A.hi, R.base, R.shade, R.hi) end
          for _, p in ipairs({ { 0, 1 }, { 1, 1 } }) do L.inside(c, x + p[1], y + 1, A.base, R.base, R.shade, R.hi) end
          L.inside(c, x, y + 2, A.deep, R.base, R.shade, R.hi)
        else L.inside(c, x, y, A.base, R.base, R.shade, R.hi) end
        d = d + (w > 3 and 3.2 or 2.6)
      end
      if q.pearl and i == 3 then   -- the pearl held in the curl of the tip
        local px, py = g:x(e + 5.6), g:y(4.2)
        local pm = HP.ellipse(px, py, 3.2, 3.2)
        c:fillMask(pm, P.cream) pm:each(function(x, y) if not pm:has(x + 1, y + 1) then c:put(x, y, L.R.white.shade) end end)
        c:put(px - 1, py - 1, P.sky.hi) c:put(px - 2, py, P.cream)
      end
      bones[#bones + 1] = { id, "body", a * 0.6, 12, true }
    end

    -- body: a tall domed mantle over a rounder head
    g:T("body")
    local body = g:E(0, 23, 14.5, 13)
    body:add(g:E(0, 31, 11.2, 9.5))
    g:form(body, B, { frac = 0.3, offu = 3.3, pop = { { -7, 36.5 } } })
    g:under(body, B.deep) g:belly(body, B, 2.4) g:toplight(body, B, 2)
    -- sheen on the dome, a soft fold where the mantle meets the head, and a lit rim down the left
    g:mark({ { -8.5, 35 }, { -6, 38 }, { -2.5, 40 } }, B.hi, B.base, B.shade)
    g:mark({ { -11.5, 28.5 }, { -6, 27 }, { 0, 26.5 }, { 6, 27.2 }, { 11.8, 28.8 } }, B.shade, B.base, B.hi, B.shade)
    g:mark({ { -12.5, 27.6 }, { -6, 26.2 }, { 0, 25.7 } }, B.hi, B.base)
    for i = 1, 16 do   -- skin bumps
      local a, b = (g:rnd(i, 5) - .5) * 24, 15 + g:rnd(i, 6) * 25
      g:inside(a, b, B.shade, B.base) g:inside(a - 0.6, b + 0.6, B.hi, B.base)
    end
    if f.spots then   -- big ringed spots on the dome, small ones down the sides
      local big = { { -6.5, 34 }, { 3.5, 36.5 }, { 8, 31 }, { -1, 31.5 }, { -10, 30.5 }, { 0, 39.5 }, { 10.5, 25 } }
      for i, p in ipairs(big) do
        local r = (i % 3 == 0) and 1.9 or 2.5
        local sm = g:E(p[1], p[2], r, r * 0.9); sm:clip(body)
        g:over(sm, A.base, B.base, B.shade, B.hi)
        local inner = g:E(p[1] - 0.2, p[2] + 0.2, r * 0.6, r * 0.55); inner:clip(sm)
        g:over(inner, A.shade, A.base) c:put(g:x(p[1]) - 1, g:y(p[2]) - 1, A.hi)
      end
      for i = 1, 7 do
        local a, b = (i % 2 == 0 and 1 or -1) * (11 + g:rnd(i, 3) * 2), 14 + g:rnd(i, 4) * 10
        g:inside(a, b, A.base, B.base, B.shade) g:inside(a + 0.7, b, A.base, B.base, B.shade)
      end
    end
    -- face: pale eye patches under dark brows, cheeks, a small smile
    for _, s in ipairs({ -1, 1 }) do
      local pm = g:E(s * 6.6, 22, 4.9, 4.4)
      g:form(pm, A, { frac = 0.25, off = 1, inner = false }) g:under(pm, A.deep)
      g:stroke({ { s * 11.2, 26.6 }, { s * 6.5, 27.6 }, { s * 2.8, 26.6 } }, B.deep)
      g:dots({ { s * 9.6, 17.6 } }, P.petal.base) g:dots({ { s * 9.6 - s * 0.7, 17.6 } }, P.petal.base)
    end
    local mx, my = g:x(0), g:y(15.8)
    for _, p in ipairs({ { -2, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 0 } }) do c:put(mx + p[1], my + p[2], B.deep) end
    -- the siphon: a short funnel at the lower right, pointing out and down, its mouth dark
    local sp = g:P({ { 6.8, 14.5 }, { 11.2, 15.2 }, { 12.8, 9.2 }, { 8.6, 9.2 } })
    g:form(sp, A, { frac = 0.4, off = 1, inner = true }) g:under(sp, A.deep)
    local lip = g:E(10.7, 9.4, 2.4, 0.9); g:fill(lip, A.deep)
    c:put(g:x(10.7) - 1, g:y(9.4) - 1, A.base) c:put(g:x(10.7), g:y(9.4) - 1, A.base)
    g:mark({ { 7.4, 13.8 }, { 9, 11 } }, P.cream, A.base, A.shade)
    g:T("eyes")
    g:eye(-6.6, 22) g:eye(6.6, 22)
    g:T("body")
    bones[#bones + 1] = { "body", false, 0, 18 }
    bones[#bones + 1] = { "eyes", "body", 0, 22 }
    return bones
  end
end
