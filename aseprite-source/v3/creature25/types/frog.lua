-- frog: frogs and toads, FRONT view (faces the viewer). Parts: footL, footR (the folded back legs), body, eyeL, eyeR (+ fly).
-- Spec features: belly (pale belly in the accent colour), spots (+ spotcol), toad = slug has "toad" (flatter, warty, no shine).
-- Quirks (quirks/frog.lua): fly = a fly sits between the eyes and both eyes roll to it; tongue = the tip of the tongue is out; lily = a lily pad scrap with a bud on its head; flower = a tiny flower on its head; worm = a worm dangles from its mouth.
-- Per animal: bullfrog has eardrums, mire toad brow ridges and glands, poison dart frog gloss and round toe discs, spadefoot vertical pupils and foot spades.
return function(L)
  local P = L.P
  local sqrt, max = math.sqrt, math.max
  local rect = L.HP.rect
  return function(g)
    local c, f, q, B, A = g.c, g.f, g.q, g.B, g.A
    local toad = g.s.slug:find("toad") ~= nil
    local dart, mire, spade = g.s.slug:find("dart") ~= nil, g.s.slug:find("mire") ~= nil, g.s.slug:find("spadefoot") ~= nil
    local bw, bh = toad and 16 or 15, toad and 10 or 11.2          -- body half-width and half-height
    local ey = toad and 20 or 22.5                                 -- height of the eye bumps
    g:shadow(0, 18.5)
    for _, s in ipairs({ -1, 1 }) do   -- folded back legs with dark bars, wide webbed feet with toe pads
      g:T(s < 0 and "footL" or "footR")
      local m = g:E(s * 14, 6.7, 5.8, 5.8)
      g:form(m, B, { frac = s > 0 and 0.4 or 0.15 }) g:under(m, B.deep)
      for i = 0, 2 do g:mark({ { s * (11.7 + i * 2.5), 10 - i * 1.7 }, { s * (11.7 + i * 2.5) + (s > 0 and 1.7 or -1.7), 8.3 - i * 1.7 } }, B.deep, B.base, B.shade) end
      local ft = g:E(s * 15.8, 1.9, 5.8, 2.1)
      g:form(ft, B, { frac = 0.3, off = 1 }) g:under(ft, B.deep)
      for i = -1, 1 do g:put(s * 15.8 + i * 3.3, 2.5, B.deep) g:put(s * 15.8 + i * 3.3 - 1.7, 2.5, B.hi) end
      if spade then   -- the horny digging spade on the inner edge of each foot
        local sp = g:E(s * 10.6, 2.2, 1.7, 1.7); g:form(sp, L.R.bark, { frac = 0.4, off = 1 }) g:put(s * 10.6 - 0.6, 2.8, P.cream)
      end
      if dart then for i = -1, 1 do g:dots({ { s * 15.8 + i * 3.3 + 0.5, 1.4 } }, A.base) end end   -- round sticky toe discs
    end
    g:T("body")
    local body = g:E(0, 11.7, bw, bh)
    g:form(body, B, { frac = 0.28, offu = 3.3, pop = { { -bw * 0.66, 11.7 + bh * 0.6 } } })
    g:under(body, B.deep) g:toplight(body, B, 1)
    if f.belly ~= false then
      local bel = g:E(0, 5.8, 10, 6.2); bel:clip(body)
      g:form(bel, f.belly and A or L.lighter(B), { frac = 0.25, off = 2, inner = false })
      local br = f.belly and A or L.lighter(B)
      for i = 1, 5 do local a, b = (g:rnd(i, 1) - .5) * 14, 2.5 + g:rnd(i, 2) * 6; g:inside(a, b, br.shade, br.base) end   -- speckled belly
      for a = -6.5, 6.5, 1.7 do g:inside(a, 10, br.shade, br.base) end                                                 -- the fold of the throat
    end
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "eyeL" or "eyeR")
      local ea = s * 8.3
      local bump = g:E(ea, ey, 5.4, 5.4)
      g:form(bump, B, { frac = s > 0 and 0.3 or 0.12, off = 2, pop = s < 0 and { { ea - 2.5, ey + 3.3 } } or nil })
      local w = g:E(ea, ey - 0.4, 2.9, 2.9); g:fill(w, P.gold.base)                                  -- a golden eye
      w:each(function(x, y) if not w:has(x, y - 1) then c:put(x, y, P.ink) elseif not w:has(x, y + 1) then c:put(x, y, P.gold.shade) end end)
      local px, py = g:x(ea), g:y(ey - 0.4)
      if q.fly then   -- both eyes have rolled inward and up, at the fly
        c:fillMask(rect(px - s * 2 - 1, py - 2, px - s * 2, py), P.ink) c:put(px - s * 2 - (s > 0 and 0 or 1), py - 2, P.cream)
      elseif spade then   -- a tall slit pupil
        c:fillMask(rect(px - 1, py - 3, px, py + 1), P.ink) c:put(px - 1, py - 3, P.cream)
      else            -- a wide slit pupil
        c:fillMask(rect(px - 2, py - 1, px + 1, py), P.ink) c:put(px - 2, py - 1, P.cream)
      end
      c:put(px + s * 2, py + 1, P.gold.hi)
    end
    g:T("body")
    local mouth = {}
    for a = -bw + 2, bw - 2, 1 do mouth[#mouth + 1] = { a, 14.4 - 1.9 * sqrt(max(0, 1 - (a / (bw - 2)) ^ 2)) } end   -- a very wide mouth
    g:stroke(mouth, B.deep)
    g:dots({ { -bw + 1, 15 }, { bw - 1, 15 }, { -bw + 0.2, 15.8 }, { bw - 0.2, 15.8 } }, B.deep)
    if q.tongue then   -- the tip of its tongue is already out
      local t = g:R(6.7, 11.7, 7.5, 10); g:fill(t, P.petal.base) g:put(6.7, 10, P.petal.shade) g:put(7.5, 9.2, P.petal.shade)
    end
    g:dots({ { -2.5, 16.7 }, { 1.7, 16.7 } }, B.deep) g:dots({ { -2.5, 17.5 }, { 1.7, 17.5 } }, B.hi)   -- nostrils
    g:dots({ { -10.8, 11.7 }, { -10, 11.7 }, { 10, 15 }, { 10.8, 15 } }, P.petal.base)                 -- cheeks
    if f.spots then   -- bold spots (poison frogs) or dull blotches (toads)
      local sc = f.spotcol and L.ramp(f.spotcol) or nil
      for i = 1, 9 do
        local a, b = (g:rnd(i, 7) - .5) * 2 * (bw - 3), 13 + g:rnd(i, 8) * (bh - 2.5)
        local m = g:E(a, b, sc and 1.5 or 1.2, sc and 1.2 or 0.9); m:clip(body)
        if sc then g:over(m, sc.base, B.base, B.shade, B.hi) else g:over(m, B.deep, B.base, B.shade) end
      end
    end
    local nw = toad and 14 or 8
    for i = 1, nw do   -- warts: a dark dot with a lit top
      local a, b = (g:rnd(i, 3) - .5) * 2 * (bw - 2), 12.5 + g:rnd(i, 4) * (bh - 3)
      g:inside(a, b, B.shade, B.base) L.inside(c, g:x(a) + 1, g:y(b), B.shade, B.base) g:inside(a, b + 0.9, B.hi, B.base)
    end
    for _, s in ipairs({ -1, 1 }) do   -- front legs and toes
      local a = g:E(s * 7.5, 4.6, 2.1, 3.75)
      g:form(a, B, { frac = 0.34, off = 1, inner = false })
      local yt = g:y(1.7)
      a:each(function(x, y) if not a:has(x - s, y) and y < yt then c:put(x, y, B.shade) end end)   -- a soft edge against the belly, not a hard line
      local tx = g:x(s * 7.5)
      c:fillMask(rect(tx - 3, g.gy - 2, tx + 3, g.gy - 1), B.base)
      c:put(tx - 1, g.gy - 1, B.deep) c:put(tx + 1, g.gy - 1, B.deep) c:put(tx - 3, g.gy - 2, B.hi) c:put(tx, g.gy - 2, B.hi) c:put(tx + 3, g.gy - 2, B.hi)
    end
    if not toad then g:put(-5, 21.7, P.cream) g:put(-4.2, 13.3, P.sky.hi) end                        -- wet shine
    if not toad and not dart then   -- the round eardrum behind each eye
      for _, s in ipairs({ -1, 1 }) do
        local tm = g:E(s * 13, 15.6, 2.5, 2.5); g:over(tm, B.hi, B.base, B.shade) tm:each(function(x, y) if not tm:has(x + 1, y + 1) then L.inside(c, x, y, B.shade, B.hi, B.base) end end)
        g:inside(s * 13, 15.6, B.deep, B.hi, B.base)
      end
    end
    if mire then   -- heavy brow ridges and big warty glands behind the eyes
      for _, s in ipairs({ -1, 1 }) do
        local gl = g:E(s * 12.6, 16.8, 3.6, 2.4); g:over(gl, B.shade, B.base, B.hi, B.shade) gl:each(function(x, y) if not gl:has(x - 1, y - 1) then L.inside(c, x, y, B.hi, B.shade, B.base) end end)
        for i = 0, 2 do g:dots({ { s * (11.4 + i * 1.2), 16.4 + (i % 2) * 0.8 } }, B.deep) end
        g:stroke({ { s * 3.4, 21 }, { s * 8, 21.6 }, { s * 12.6, 20 } }, B.deep)
      end
    end
    if dart then   -- glossy skin: bright streaks, bright dots on the belly edge
      g:dots({ { -6, 19.2 }, { -5, 19.8 }, { -3.8, 20 }, { 6, 18.6 } }, P.cream) g:dots({ { -10, 14 }, { -9, 15 }, { 8, 10 } }, P.sky.hi)
    end
    if q.lily then   -- a scrap of lily pad on its head, with a pink bud
      local lp = g:E(0, 22.6, 4.2, 1.9); lp:cut(g:P({ { 0, 22.6 }, { 4.6, 24.4 }, { 4.6, 21.2 } }))
      g:form(lp, P.moss, { frac = 0.34, off = 1 }) g:under(lp, P.moss.deep) g:mark({ { -3, 22.4 }, { 0, 22.6 } }, P.moss.deep, P.moss.base, P.moss.shade)
      g:fill(g:E(-1.4, 24.4, 1.2, 1.2), P.petal.base) g:dots({ { -1.4, 25.4 } }, P.petal.hi)
    end
    if q.flower then   -- a tiny flower from the rainforest, tucked on its head
      g:dots({ { 0.2, 22.4 }, { 0.2, 23.4 } }, P.moss.base)
      local fx, fy = g:x(0.2), g:y(25)
      for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do c:put(fx + d[1] * 2, fy + d[2] * 2, P.petal.base) c:put(fx + d[1], fy + d[2], P.petal.base) end
      c:put(fx, fy, P.gold.base)
    end
    if q.worm then   -- a worm dangling from the corner of its mouth
      local w = g:Ln1({ { 5.5, 14.2 }, { 7.6, 10.8 }, { 5.8, 7.6 }, { 7.8, 4.6 } }, 2)
      g:fill(w, P.petal.base) w:each(function(x, y) if not w:has(x + 1, y + 1) then c:put(x, y, P.petal.shade) end end)
      g:dots({ { 7, 11.6 }, { 6.4, 8.4 } }, P.petal.hi) g:dots({ { 6.4, 9.6 }, { 7.2, 6 } }, P.petal.deep)
    end
    if q.fly then   -- the fly: on the frog's head, between its eyes
      g:T("fly") local x, y = g:x(0), g:y(bh + 11.7 + 2.5)
      c:fillMask(rect(x - 1, y, x, y + 1), P.ink) c:put(x - 2, y - 1, P.sky.base) c:put(x + 1, y - 1, P.sky.base) c:put(x - 3, y - 2, P.sky.base) c:put(x + 2, y - 2, P.sky.base) c:put(x - 1, y, P.ember.base)
    end
    return { { "footL", false, -13.8, 2.5 }, { "footR", false, 14.6, 2.5 }, { "body", false, 0.4, 0 }, { "eyeL", "body", -8, ey - 5.5 }, { "eyeR", "body", 8.7, ey - 5.5 }, { "fly", "body", 0.4, bh + 13 } }
  end
end
