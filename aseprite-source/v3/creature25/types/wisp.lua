-- wisp: the will-o-wisp, a marsh light, FRONT view. Parts (back to front): body (the flame, licks up from its base), core (the glowing face), base (a mound of marsh grass it hovers over), eyes.
-- The flame is three layers: orange rim, a body in the creature's colour (g.B), a white-hot heart (the core, in the lighter tone of g.B). Sparks lift off the tips.
-- Spec features: none (colour comes from `col`); `acc` is not used (the core is the lighter tone of col so the face always glows).
-- Quirks (quirks/wisp.lua): cattail = a brown cattail grows out of the grass at its right side.
return function(L)
  local P = L.P
  local HP = L.HP
  return function(g)
    local c, q, B = g.c, g.q, g.B
    local O = L.R.orange                 -- the hot rim of the flame
    local CO = L.lighter(B)              -- the glowing core
    g:shadow(0, 13)

    -- body: a bulb with four tongues (one tall and curled, two long licks, a short flick on each side), every one tapering to a fine tip
    g:T("body")
    local fl = g:E(0, 15, 13, 9)
    fl:add(g:Limb({ { 0, 18 }, { -1.5, 28 }, { 1, 37 }, { 5, 45 } }, 13, 1))
    fl:add(g:Limb({ { -6, 17 }, { -10.5, 25 }, { -9.5, 33 }, { -12.5, 39 } }, 9, 1))
    fl:add(g:Limb({ { 6, 17 }, { 10.5, 24 }, { 9.5, 31 }, { 12.5, 36 } }, 9, 1))
    fl:add(g:Limb({ { -10, 14 }, { -15, 19 }, { -15.5, 25 } }, 6, 1))
    fl:add(g:Limb({ { 10, 14 }, { 14.5, 18 }, { 15, 22 } }, 5, 1))
    fl:cut(g:R(-30, -5, 30, 5))          -- the flame stands on its base: nothing hangs below b = 5
    g:form(fl, O, { frac = 0.3, off = 2, inner = false })
    -- the yellow layer: the same flame, two pixels in; shade on its right; a cream top light
    local mid = fl:shrink(2)
    g:form(mid, B, { frac = 0.3, off = 2, inner = false })
    local heart = fl:shrink(5)
    g:form(heart, CO, { frac = 0.3, off = 2, inner = false })
    -- the rim burns brighter on its left and flickers: a few orange-gold dither pixels out into the yellow
    local x0, y0, x1, y1 = mid:bbox()
    mid:each(function(x, y)
      if not mid:has(x - 1, y) and (x + y) % 3 == 0 then L.inside(c, x, y, B.shade, B.base) end
      if not mid:has(x, y - 1) and (x % 2 == 0) then L.inside(c, x, y, B.hi, B.base) end
      if not fl:shrink(1):has(x, y + 2) then L.inside(c, x, y, O.base, B.shade, B.base) end
    end)
    for _, k in ipairs({ { { -2, 31 }, { 0, 26 } }, { { -9, 29 }, { -8, 25 } }, { { 9, 27 }, { 8.5, 23.5 } } }) do   -- little swirls inside the tongues
      g:mark(k, B.shade, B.base, B.hi)
    end
    g:belly(fl, O, 2)
    -- the foot of the flame glows hot: orange-red where it meets the grass
    fl:each(function(x, y) if y >= g:y(9) and (x + y) % 2 == 0 then L.inside(c, x, y, O.shade, B.base, B.shade, O.base) end end)
    -- sparks: little plus signs and bars lifting off the tips
    local function spark(a, b, big)
      local x, y = g:x(a), g:y(b)
      c:put(x, y, P.cream) c:put(x - 1, y, B.hi) c:put(x + 1, y, B.hi) c:put(x, y - 1, B.hi) c:put(x, y + 1, B.hi)
      if big then c:put(x - 2, y, B.base) c:put(x + 2, y, B.base) c:put(x, y - 2, B.base) c:put(x, y + 2, B.base) end
    end
    spark(-14, 45, true) spark(14, 41, false) spark(9, 51, false) spark(-5, 52, false)
    g:dots({ { -17, 33 }, { 15, 48 } }, O.base)

    -- core: the glowing face, a round cream ball with a warm underside and a soft halo of yellow
    g:T("core")
    local ball = g:E(0, 17, 10, 10)
    g:form(ball, CO, { frac = 0.28, offu = 3, pop = { { -5, 23 } } })
    g:under(ball, B.base) g:belly(ball, CO, 2.2)
    ball:each(function(x, y) if (x + y) % 3 == 0 and not ball:has(x - 1, y - 1) then c:put(x, y, P.cream) end end)
    g:dots({ { -7.5, 14 }, { 7, 13.5 } }, P.petal.base) g:dots({ { -6.7, 14 }, { 7.8, 13.5 } }, P.petal.base)   -- cheeks
    -- base: a mound of marsh grass: a low dark tussock with blades curling up in front of the flame foot
    g:T("base")
    local mound = g:E(0, 6.2, 12, 3.6); mound:cut(g:R(-14, -1, 14, 0.4))
    g:form(mound, L.R.pine, { frac = 0.3, off = 1, inner = false }) g:under(mound, P.ink)
    g:toplight(mound, L.R.pine, 1)
    local blades = { { -10.5, 4.5, -1.2 }, { -7.5, 6.5, -0.8 }, { -4.5, 5, 0.6 }, { 4, 5.5, -0.5 }, { 7.5, 6.8, 0.9 }, { 10.8, 4.6, 1.4 } }
    for i, bl in ipairs(blades) do
      local m = g:P({ { bl[1] - 1, 7.2 }, { bl[1] + 1, 7.2 }, { bl[1] + bl[3] * 2, 7.2 + bl[2] } })
      g:form(m, i % 2 == 0 and L.R.moss or L.R.pine, { frac = 0.35, off = 1, inner = false })
    end
    g:dots({ { -3, 4.4 }, { 1, 3.4 }, { 6, 4 }, { -8, 3.6 } }, L.R.pine.deep)
    if q.cattail then   -- a cattail: a green stem and a fat brown head
      local m = g:Ln({ { 13, 6.5 }, { 13.8, 13 } }, 0.7); g:form(m, L.R.moss, { noshade = true })
      local hd = g:RR(12.6, 12, 15, 18.5, 1); g:form(hd, L.R.bark, { frac = 0.4, off = 1 }); g:under(hd, P.ink)
      g:dots({ { 13.4, 13.5 }, { 14, 15.5 } }, L.R.bark.deep) g:put(13, 17.5, L.R.bark.hi)
      g:stroke({ { 13.8, 18.9 }, { 13.8, 21 } }, L.R.bark.deep)
    end

    g:T("eyes")
    g:eye(-4, 19) g:eye(4, 19)
    g:T("core")
    -- a small open smile in the heart colour
    local mx, my = g:x(0), g:y(12.5)
    for _, p in ipairs({ { -3, -1 }, { -2, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 0 }, { 3, -1 } }) do c:put(mx + p[1], my + p[2], P.ink) end
    for _, p in ipairs({ { -1, 2 }, { 0, 2 }, { 1, 2 } }) do c:put(mx + p[1], my + p[2], P.petal.base) end   -- a tiny tongue
    return { { "body", false, 0, 6 }, { "core", "body", 0, 17 }, { "base", false, 0, 8 }, { "eyes", "core", 0, 19 } }
  end
end
