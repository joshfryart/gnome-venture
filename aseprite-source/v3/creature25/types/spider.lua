-- spider: the orb spider and the crystal weaver, SIDE view, faces right. Parts, back to front: leg1, leg2 (behind, darker), body (the abdomen), leg3, leg4 (in front of the body), head (+eyes; it covers the legs' roots).
-- Every leg part paints a PAIR of jointed legs (near and far) so the spider has eight. The eyes part holds only eye pixels: one big gnome eye and two small ones.
-- Spec features: spots = orb spider: a leaf-shaped pattern and cream spots on the abdomen; crystal weaver: faceted abdomen with crystal spikes and gem spots.
-- Quirks (quirks/spider.lua):  thread = a silk thread hangs from the spinnerets to the ground     scarf = a knitted scarf round the neck
return function(L)
  local P = L.P
  local cos, sin, pi = math.cos, math.sin, math.pi
  return function(g)
    local c, f, q, B, A, D, slug = g.c, g.f, g.q, g.B, g.A, g.D, g.s.slug
    local crystal = slug:find("crystal") ~= nil
    g:shadow(-2, 28)
    -- a leg: hip -> high knee -> shin down to a pointed foot; w units thick
    local function leg(r, hip, knee, foot, w)
      local mid = { knee[1] + (foot[1] - knee[1]) * 0.55, knee[2] + (foot[2] - knee[2]) * 0.55 }
      local m = g:Limb({ hip, knee, mid, foot }, w, w * 0.55)
      m:clip(g:R(-60, 0, 60, 60))
      g:form(m, r, { frac = 0.4, off = 1 }) g:under(m, r.deep)
      g:inside(knee[1] - 0.8, knee[2] + 0.9, r.hi, r.base)
      g:dots({ { knee[1] + 0.5, knee[2] - 0.4 } }, crystal and A.base or r.shade)                   -- the knee joint
      g:dots({ { mid[1], mid[2] } }, r.shade)
      g:dots({ { foot[1], foot[2] + 0.2 } }, r.deep)
      for k = 1, 3 do g:inside(knee[1] + (foot[1] - knee[1]) * k / 4 + 1, knee[2] + (foot[2] - knee[2]) * k / 4 + 0.4, r.deep, r.base, r.shade) end   -- bristles
    end
    local spec = {   -- hip a, knee a, foot a, knee height: legs 1, 2 reach back, 3, 4 arch over the head to the front
      { -3, -14, -30, 31 }, { -1.5, -6, -19, 34 }, { -1, 6, 19, 35 }, { -2, 12, 31, 33 } }
    local function legs(i, r1, r2)
      local h, k, fo, kh = table.unpack(spec[i])
      leg(r1, { h - 1.5, 14.5 }, { k - 3, kh - 2.5 }, { fo - 3.5, 0.6 }, 2.2)     -- the far leg of the pair, offset
      leg(r2, { h, 14 }, { k, kh }, { fo, 0.6 }, 2.4)
    end
    g:T("leg1") legs(1, D, D)
    g:T("leg2") legs(2, D, D)
    -- abdomen (+ a short waist joining the head)
    g:T("body")
    local ab = g:E(-9, 16.5, 11.5, 10)
    ab:add(g:E(2, 15, 3.6, 3.4))
    ab:add(g:P({ { -18.5, 14 }, { -23, 11 }, { -19, 9 } }))                  -- spinnerets
    if crystal then   -- crystal spikes along the back
      ab:add(g:P({ { -15, 22 }, { -17, 29.5 }, { -11.5, 25.5 } })) ab:add(g:P({ { -10, 25 }, { -8, 33 }, { -4.6, 25.4 } })) ab:add(g:P({ { -4, 24.4 }, { -0.5, 30 }, { 1, 22.5 } }))
    end
    g:form(ab, B, { frac = 0.3, offu = 3.5, pop = { { -16, 22 }, { -14, 24 }, { -12, 25.5 } } })
    g:under(ab, B.deep) g:belly(ab, B, 3) g:toplight(ab, B, 1)
    if crystal then
      local cx, cy = -9, 16.5
      for i = 0, 6 do local th = i * pi / 3.4 + 0.2; g:mark({ { cx, cy }, { cx + 12 * cos(th), cy + 10.5 * sin(th) } }, B.shade, B.base, B.hi) end
      g:mark({ { -19, 14 }, { -9, 24 }, { 1, 17 }, { -9, 7 }, { -19, 14 } }, B.deep, B.base, B.hi, B.shade)
      for k = 0, 2 do local th = 0.9 + k * 1.3; g:over(g:P({ { cx, cy }, { cx + 11 * cos(th), cy + 9.5 * sin(th) }, { cx + 11 * cos(th + 0.7), cy + 9.5 * sin(th + 0.7) } }), B.hi, B.base) end
      for _, p in ipairs({ { -14, 17 }, { -8, 19.6 }, { -4, 14 }, { -10, 11.4 } }) do   -- gem spots
        local m = g:E(p[1], p[2], 1.7, 1.7); m:clip(ab); g:fill(m, A.base) g:dots({ { p[1], p[2] - 0.4 } }, A.hi) g:dots({ { p[1] + 0.9, p[2] - 1 } }, A.deep)
      end
    else
      -- orb weaver: a leaf-shaped folium down the back, cream spots in a row, a pale stripe either side
      for k = 0, 3 do
        local x0 = -17 + k * 4.4
        local band = g:Ln({ { x0 + 1.6, 24 }, { x0 - 0.4, 17 }, { x0 + 1.6, 9.5 } }, 1.7); band:clip(ab)
        g:over(band, A.base, B.base, B.shade, B.hi)
        band:each(function(x, y) if not band:has(x + 1, y + 1) then L.inside(c, x, y, A.shade, A.base) end end)
      end
      for i, p in ipairs({ { -15.2, 22 }, { -11, 23.6 }, { -6.6, 23 }, { -2.6, 20.4 }, { -12.6, 13 }, { -7.6, 11.8 } }) do
        local m = g:E(p[1], p[2], 1.1, 1.1); m:clip(ab); g:fill(m, i <= 4 and P.cream or A.deep)
      end
    end
    if q.thread then   -- a silk thread from the spinnerets down to the ground
      g:stroke({ { -21.5, 9 }, { -22.4, 6 }, { -21.6, 3 }, { -22, 0.8 } }, P.cream)
      g:dots({ { -22, 0.6 } }, P.sky.base)
    end
    g:T("leg3") legs(3, D, B)
    g:T("leg4") legs(4, D, B)
    -- head: small, with fangs, palps and a face; in front of the near legs so the face stays clear
    g:T("head")
    local hd = g:E(8.6, 16.6, 6.8, 5.8); hd:add(g:E(14.2, 14, 2.8, 2.6))
    g:form(hd, B, { frac = 0.3, offu = 2.5, pop = { { 5, 20.5 }, { 6.5, 21.4 } } })
    g:under(hd, B.deep) g:toplight(hd, B, 1)
    g:fill(g:R(14.4, 9.6, 15.6, 12.4), P.cream) g:dots({ { 14.4, 9.6 }, { 15.6, 10 } }, "#f0b98d")        -- a pair of tiny fangs
    g:dots({ { 12.4, 11.6 }, { 13.2, 11.2 } }, B.deep)                                              -- a palp
    g:dots({ { 11.6, 12.8 }, { 12.4, 12.8 } }, P.petal.base)
    g:T("eyes") g:eye(10.4, 17.8)
    g:dots({ { 6.8, 20.4 }, { 8.6, 21.2 } }, P.ink) g:dots({ { 6.8, 20.9 }, { 8.6, 21.7 } }, P.cream)
    g:T("head")
    g:dots({ { 8.8, 20.8 }, { 10, 21.2 }, { 11.2, 21.2 }, { 12.4, 20.6 } }, B.deep)                      -- a brow
    if q.scarf then
      local sc = g:E(2.6, 15.2, 2.3, 4.8)
      g:form(sc, A, { frac = 0.34, off = 1 })
      local tl = g:P({ { 1.2, 11.4 }, { 3.4, 11.4 }, { 2.4, 6.6 }, { -0.2, 7.4 } })
      g:form(tl, A, { frac = 0.34, off = 1 }) g:under(tl, A.deep)
      for k = 0, 2 do g:inside(2.6, 19 - k * 2.6, A.deep, A.base, A.shade) g:inside(1.4 + k * 0.4, 10.2 - k * 1.2, A.hi, A.base) end
    end
    return { { "body", false, -6, 14 }, { "leg1", "body", -0.5, 14, true }, { "leg2", "body", 1, 14, true }, { "head", "body", 3, 16 }, { "eyes", "head", 10.4, 17.8 },
      { "leg3", "body", 4.5, 14 }, { "leg4", "body", 6, 14 } }
  end
end
