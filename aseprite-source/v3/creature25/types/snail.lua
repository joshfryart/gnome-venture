-- snail: snails, turtles and a clam, SIDE view, faces right. Parts: body (the foot; for turtles the legs, flippers and tail), shell, head (+eyes), antL, antR (eye stalks; none on turtles and the clam).
-- Sub-kinds, picked from the slug: snail (garden, rot, quartz: a real spiral shell with growth lines), turtle (reef turtle with flippers, desert tortoise with pillar legs,
-- ancient snapper with a spiked shell and a saw tail: domed scuted shell, beaked head), clam (clam lurker: two ribbed valves with a toothy gap, the soft body and the eye in the gap).
-- Spec features: spots (dark spots on the skin; the snapper also gets lichen on its shell).
-- Quirks (quirks/snail.lua):
--   daisy  = a daisy grows from the shell        shroom = a red toadstool on the shell        chip = one crystal spike is broken off
--   barnacles = barnacles crust the shell edge   crack = a mended crack across the shell     weed = a strand of seaweed hangs from the shell
--   pearl = a pearl sits in the clam's mouth
return function(L)
  local P = L.P
  local sin, cos, pi, max, min, sqrt, floor = math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.floor

  -- points along an arc of an ellipse (figure units), degrees
  local function arc(cx, cy, rx, ry, d0, d1, n)
    local t = {}
    for i = 0, n do local d = math.rad(d0 + (d1 - d0) * i / n); t[#t + 1] = { cx + rx * cos(d), cy + ry * sin(d) } end
    return t
  end
  -- an Archimedean spiral from the middle (cx, cy) out to radius r: the whorls of a snail shell
  local function spiral(cx, cy, r, turns, th0)
    local t, n = {}, floor(turns * 40)
    for i = 0, n do
      local k = i / n; local th = th0 + k * turns * 2 * pi; local rr = r * (0.05 + 0.95 * k)
      t[#t + 1] = { cx + rr * cos(th), cy + rr * sin(th) }
    end
    return t
  end

  ---------------------------------------------------------------- true snails
  local function snail(g)
    local c, f, q, B, A, slug = g.c, g.f, g.q, g.B, g.A, g.s.slug
    local quartz, rot = slug:find("quartz") ~= nil, slug:find("rot") ~= nil
    g:shadow(-1, 22)
    -- the foot: a long soft body with a tapering tail, wrinkles and a lighter sole
    g:T("body")
    local foot = g:RR(-16, 0, 19, 6.8, 3)
    foot:add(g:P({ { -25, 0.2 }, { -14, 0 }, { -12, 6.2 }, { -20, 2.6 } }))
    foot:add(g:Limb({ { 8, 4 }, { 12, 10.5 } }, 8, 7.5))                       -- the neck rises out of the foot
    g:form(foot, B, { frac = 0.3, offu = 2.5, pop = { { -9, 6 }, { 5, 6.3 } } })
    g:under(foot, B.deep) g:belly(foot, B, 2) g:toplight(foot, B, 1)
    g:fur(foot, B, 1.1)                                                          -- skin tubercles
    for i = 0, 5 do local a = -14 + i * 4.6 + g:rnd(i, 2) * 1.5; g:inside(a, 5.4, B.shade, B.base) g:inside(a + 0.9, 4.6, B.shade, B.base) end   -- wrinkles behind the neck
    if f.spots then
      for i = 1, 9 do
        local a, b = -17 + g:rnd(i, 1) * 28, 2 + g:rnd(i, 2) * 3.4
        local m = g:E(a, b, 1.3, 1.0); m:clip(foot); g:over(m, rot and B.deep or B.deep, B.base, B.shade, B.hi)
      end
    end
    -- the shell: a spiral with growth lines. The aperture bulges at the front, a mantle collar joins it to the body
    g:T("shell")
    local cx, cy = -6.2, 16
    local sh = g:E(cx, cy, 11.2, 10.6)
    sh:add(g:E(-1.5, 12.2, 8.2, 7.4))
    if quartz then
      sh:add(g:P({ { -13, 22 }, { -14.5, 29.5 }, { -9.5, 25 } }))               -- crystal spikes on the back
      if not q.chip then sh:add(g:P({ { -8, 25.5 }, { -5.5, 33.5 }, { -3, 26 } })) else sh:add(g:P({ { -8, 25.5 }, { -6.5, 28.5 }, { -3.5, 26 } })) end
      sh:add(g:P({ { -2.4, 25 }, { 0.2, 29.6 }, { 2.4, 23.4 } }))
    end
    g:form(sh, A, { frac = 0.3, offu = 3.5, pop = { { -12, 22 }, { -10.5, 24 } } })
    g:under(sh, A.deep) g:belly(sh, A, 3) g:toplight(sh, A, 1)
    if quartz then
      -- cut crystal: a six sided spiral, ridge lines out from the heart, a few lit facets
      local pts = {}
      for i = 0, 17 do local th = i * pi / 3 + 0.3; local r = 1 + i * 0.62; pts[#pts + 1] = { cx + r * cos(th), cy + r * sin(th) } end
      for i = 0, 5 do
        local th = i * pi / 3 + 0.3
        g:mark({ { cx, cy }, { cx + 11.5 * cos(th), cy + 11 * sin(th) } }, A.shade, A.base, A.hi)
      end
      for i = 1, #pts - 1 do g:mark({ pts[i], pts[i + 1] }, A.deep, A.base, A.hi, A.shade) end
      for k = 0, 5 do
        local th0 = k * pi / 3 + 0.3; local th1 = th0 + pi / 3
        if k % 2 == 0 then g:over(g:P({ { cx, cy }, { cx + 11 * cos(th0), cy + 10.5 * sin(th0) }, { cx + 11 * cos(th1), cy + 10.5 * sin(th1) } }), A.hi, A.base) end
      end
      g:dots({ { -10, 21.5 }, { -4.4, 23.3 }, { 6, 17.5 } }, P.cream) g:dots({ { -10.8, 21.5 }, { -9.2, 21.5 } }, P.cream)
    else
      local sp = spiral(cx, cy, 11.4, 2.4, 0.9)
      g:mark(sp, A.deep, A.base, A.hi, A.shade)
      for _, p in ipairs(sp) do L.inside(c, g:x(p[1]), g:y(p[2]) - 1, A.hi, A.base) end                  -- the ridge catches the light above each groove
      local sp2 = spiral(cx, cy, 11.4, 2.4, 0.9 + pi * 0.5)                                        -- growth lines: short radial ticks across the whorls
      for i = 2, #sp2 - 3, 2 do local p = sp2[i]; if i % 4 == 2 then g:inside(p[1], p[2], A.shade, A.base, A.hi) g:inside(p[1] + 0.9, p[2] - 0.5, A.shade, A.base, A.hi) end end
      g:dots({ { cx, cy }, { cx + 1, cy } }, A.deep)                                              -- the tip of the spiral
      if rot then   -- mould: patches of green rot creeping over the shell
        for i = 1, 6 do
          local a, b = cx + (g:rnd(i, 4) - .5) * 17, cy + (g:rnd(i, 5) - .5) * 15
          local m = g:E(a, b, 1.8, 1.2); m:clip(sh); g:over(m, P.moss.base, A.base, A.shade, A.hi)
          g:inside(a - 0.8, b + 0.9, P.moss.deep, P.moss.base) g:inside(a, b - 0.9, P.moss.hi, P.moss.base)
        end
      end
    end
    -- mantle collar: the body's colour wraps the shell lip at the front
    local collar = g:E(1.5, 9.5, 5.2, 4.4); collar:cut(g:R(-30, -5, 30, 5.5)); collar:clip(sh)
    g:over(collar, B.base, A.base, A.hi, A.shade, A.deep)
    collar:each(function(x, y) if not collar:has(x + 1, y + 1) then L.inside(c, x, y, B.shade, B.base) end end)
    if q.daisy then   -- a daisy: stem, two leaves, white petals around a gold heart
      g:stroke({ { -9, 25 }, { -9.4, 29 }, { -8.8, 33 } }, P.moss.base)
      g:dots({ { -10.2, 28.4 }, { -11, 29 }, { -7.8, 30 }, { -7, 30.6 } }, P.moss.hi)
      local x, y = g:x(-8.8), g:y(34.6)
      for _, d in ipairs({ { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do c:put(x + d[1], y + d[2], P.cream) end
      c:put(x, y, P.gold.base) c:put(x + 2, y + 1, "#ffe0bd") c:put(x + 1, y + 2, "#ffe0bd")
    end
    if q.shroom then  -- a little red toadstool growing on the rot
      g:stroke({ { -2, 24.5 }, { -2, 27.2 } }, P.cream)
      local cap = g:E(-2, 28.4, 3.4, 2.1); cap:cut(g:R(-8, 20, 3, 27.3))
      g:fill(cap, P.ember.base) cap:each(function(x, y) if not cap:has(x + 1, y + 1) then c:put(x, y, P.ember.shade) end end)
      g:dots({ { -3, 29.2 }, { -0.8, 28.6 } }, P.cream)
    end
    -- the head: round, small snout, little lower feelers, a cheek and a mouth
    g:T("head")
    local head = g:E(14.8, 12.4, 6.6, 5.9)
    head:add(g:E(19.6, 11, 3.3, 3.3)) head:add(g:E(22.6, 9.2, 1.5, 1.5))
    g:form(head, B, { frac = 0.3, offu = 3, pop = { { 12, 16.5 }, { 13.3, 17.2 } } })
    g:under(head, B.deep) g:toplight(head, B, 1)
    g:dots({ { 20, 7.9 }, { 21, 7.4 }, { 22, 7.5 }, { 23, 7.9 } }, B.deep)                           -- a small smile
    g:dots({ { 17.4, 9.6 }, { 18.2, 9.6 } }, P.petal.base)                                          -- cheek
    g:dots({ { 10.5, 12.5 }, { 11.5, 10.5 }, { 12.5, 14.5 } }, B.shade)                              -- neck folds
    g:T("eyes") g:eye(16.8, 13.4) g:T("head")
    g:dots({ { 15.6, 16.2 }, { 16.6, 16.5 }, { 17.6, 16.4 }, { 18.4, 16 } }, B.deep)                    -- a brow
    -- eye stalks (springs): thin, with a dark bulb and a glint on the tip
    for i, s in ipairs({ "antL", "antR" }) do
      g:T(s)
      local pts = i == 1 and { { 11.8, 16.5 }, { 10, 21 }, { 8.9, 25.6 } } or { { 17, 16.5 }, { 19, 21 }, { 20, 25.6 } }
      local st = g:Limb(pts, 2.6, 1.9)
      g:form(st, B, { frac = 0.4, off = 1 })
      local tip = pts[3]
      local bulb = g:E(tip[1], tip[2] + 0.9, 2.2, 2.2)
      g:form(bulb, B, { frac = 0.3, off = 1 })
      g:put(tip[1] + 0.5, tip[2] + 0.6, P.ink) g:put(tip[1] + 0.5, tip[2] + 1.4, P.ink) g:put(tip[1] - 0.6, tip[2] + 1.9, B.hi)
    end
    return { { "body", false, 4, 4 }, { "shell", "body", -7, 8 }, { "head", "body", 10, 8 }, { "eyes", "head", 16.8, 13.4 }, { "antL", "head", 11.8, 16 }, { "antR", "head", 17, 16 } }
  end

  ---------------------------------------------------------------- turtles and tortoises
  -- scutes: plates on a dome. Rows of wedges between the rim and the top, offset like bricks; `rx, ry` the dome radii around (cx, 8)
  local function scutes(g, m, cx, rx, ry, A, o)
    local cy = 8
    local function at(s, d) local r = math.rad(d); return { cx + rx * s * cos(r), cy + ry * s * sin(r) } end
    for _, s in ipairs(o.rings) do g:mark(arc(cx, cy, rx * s, ry * s, 4, 176, 28), A.deep, A.base, A.hi, A.shade) end
    for row, rg in ipairs(o.rows) do   -- rg = { s0, s1, { degrees } }
      for _, d in ipairs(rg[3]) do g:mark({ at(rg[1], d), at(rg[2], d) }, A.deep, A.base, A.hi, A.shade) end
    end
    -- the lit corner of each plate: a hi pixel just inside the top left of its seam
    for row, rg in ipairs(o.rows) do for _, d in ipairs(rg[3]) do
      local p = at((rg[1] + rg[2]) / 2, d + 6); L.inside(g.c, g:x(p[1]), g:y(p[2]), A.hi, A.base)
      L.inside(g.c, g:x(p[1]) + 1, g:y(p[2]), A.hi, A.base)
    end end
    if o.rings2 then for _, p in ipairs(o.rings2) do   -- growth rings: a dot at each plate's heart
      local q = at(p[1], p[2]); g:inside(q[1], q[2], A.shade, A.base, A.hi) g:inside(q[1], q[2] + 0.9, A.hi, A.base)
    end end
  end

  local function turtle(g)
    local c, f, q, B, A, D, slug = g.c, g.f, g.q, g.B, g.A, g.D, g.s.slug
    local reef, snap = slug:find("reef") ~= nil, slug:find("snapper") ~= nil
    local tort = not reef and not snap
    g:shadow(-1, 22)
    g:T("body")
    -- far legs (darker), then the belly strip, tail and the near legs
    local belly = g:RR(-13, 3.5, 13.5, 10, 2)
    if reef then
      local far = g:P({ { 9, 8 }, { 14, 6 }, { 21, 1.5 }, { 19.5, 0.2 }, { 12, 2.4 }, { 8, 4.5 } })
      g:form(far, D, { frac = 0.3, off = 1 }) g:under(far, D.deep)
      local farb = g:P({ { -13, 7 }, { -9, 5 }, { -8, 0.2 }, { -14, 1.8 } })
      g:form(farb, D, { frac = 0.3, off = 1 })
      local tail = g:P({ { -13, 8 }, { -21, 4.6 }, { -13, 4 } })
      g:form(tail, B, { frac = 0.3, off = 1 }) g:under(tail, B.deep)
      g:form(belly, B, { frac = 0.3, offu = 2 }) g:under(belly, B.deep)
      -- big paddle flipper at the front with three fingers' worth of ribs, small rear flipper
      local fl = g:P({ { 5.5, 9.5 }, { 11, 8.5 }, { 18, 3 }, { 17.2, 0.6 }, { 9, 2.4 }, { 4.5, 5.5 } })
      g:form(fl, B, { frac = 0.34, off = 1 }) g:under(fl, B.deep) g:toplight(fl, B, 1)
      g:mark({ { 8, 7 }, { 14.5, 2.4 } }, B.shade, B.base, B.hi) g:mark({ { 6.5, 5.5 }, { 12, 1.6 } }, B.shade, B.base, B.hi)
      g:fur(fl, B, 0.7)
      local rb = g:P({ { -15, 8 }, { -9, 6.5 }, { -6, 0.4 }, { -13, 0.4 }, { -16.5, 4 } })
      g:form(rb, B, { frac = 0.34, off = 1 }) g:under(rb, B.deep)
      g:mark({ { -10.5, 5.4 }, { -9.5, 1.4 } }, B.shade, B.base, B.hi)
    else
      -- pillar legs, scaly, with claws; the far pair is darker and peeks out between
      local lw = snap and 6.6 or 6
      local function leg(a0, dk, h)
        local m = g:Limb({ { a0 + lw / 2, h }, { a0 + lw / 2 + 0.4, 2.4 } }, lw, lw - 0.6)
        m:add(g:E(a0 + lw / 2 + 0.9, 1.7, lw / 2 + 1.1, 1.8)); m:clip(g:R(-40, 0, 40, 60))
        local r = dk and D or B
        g:form(m, r, { frac = 0.34, off = 1 }) g:under(m, r.deep)
        for k = 0, 2 do   -- scale rows
          local b = h - 2.2 - k * 2.4
          for d = 0, lw - 2, 2 do g:inside(a0 + 0.8 + d, b, r.shade, r.base) g:inside(a0 + 1.6 + d, b - 0.8, r.deep, r.base, r.shade) end
        end
        for k = 0, 2 do local x = g:x(a0 + lw - 0.6 - k * 2.4); c:put(x, g.gy - 1, P.cream) c:put(x, g.gy, "#f0b98d") end   -- claws
        return m
      end
      leg(-13.5, true, 9) leg(9.5, true, 9)
      local tl = snap and g:P({ { -13, 9.5 }, { -27, 2.5 }, { -25.5, 1 }, { -13, 4.5 } }) or g:P({ { -13, 8 }, { -19.5, 4 }, { -13, 4.5 } })
      g:form(tl, B, { frac = 0.3, off = 1 }) g:under(tl, B.deep)
      if snap then for k = 0, 4 do   -- a saw of little plates along the tail
        local a = -15 - k * 2.5; g:over(g:P({ { a, 6.4 - k * 0.8 }, { a - 1.2, 8.6 - k * 0.8 }, { a - 2.2, 6.4 - k * 0.8 } }), B.deep, B.base, B.shade, B.hi) end end
      g:form(belly, B, { frac = 0.3, offu = 2 }) g:under(belly, B.deep)
      leg(-10.5, false, 10) leg(6.5, false, 10)
    end
    if f.spots then
      for i = 1, 8 do
        local a, b = -12 + g:rnd(i, 1) * 24, 1.5 + g:rnd(i, 2) * 6
        local m = g:E(a, b, 1.1, 0.9); g:over(m, snap and P.moss.hi or B.deep, B.base, B.shade, B.hi)
      end
    end
    -- the shell: a dome. reef = flatter and smooth, tortoise = high and ringed, snapper = ridged with spikes
    g:T("shell")
    local rx, ry = reef and 17.5 or 16.5, reef and 11.5 or (snap and 12.5 or 14.8)
    local cx = -1.5
    local dome = g:E(cx, 8, rx, ry); dome:clip(g:R(-40, 7.2, 40, 60))
    if snap then   -- spikes along the back and rim
      for k = 0, 4 do
        local d = 150 - k * 28; local r = math.rad(d)
        local px, py = cx + rx * cos(r), 8 + ry * sin(r)
        local nx, ny = cos(r), sin(r)
        dome:add(g:P({ { px - ny * 1.8 - nx * 1.2, py + nx * 1.8 - ny * 1.2 }, { px + nx * 3.8, py + ny * 3.8 }, { px + ny * 1.8 - nx * 1.2, py - nx * 1.8 - ny * 1.2 } }))
      end
    end
    g:form(dome, A, { frac = 0.3, offu = 3.5, pop = { { -13, 17 }, { -11, 19 }, { -8, 20.5 } } })
    g:under(dome, A.deep) g:belly(dome, A, 2) g:toplight(dome, A, 1)
    -- the rim: a marginal row of small plates along the bottom edge
    local rim = g:E(cx, 8, rx - 1, ry - 1.2); rim:cut(g:E(cx, 8, rx - 3.2, ry - 3.6)); rim:cut(g:R(-40, -5, 40, 7.2)); rim:clip(dome)
    g:over(rim, A.shade, A.base, A.hi)
    for k = 0, 14 do local d = 8 + k * 11.8; local r = math.rad(d); local x, y = cx + (rx - 1) * cos(r), 8 + (ry - 1.2) * sin(r)
      g:mark({ { x, y }, { cx + (rx - 3.4) * cos(r), 8 + (ry - 3.8) * sin(r) } }, A.deep, A.shade) end
    if snap then
      scutes(g, dome, cx, rx, ry, A, { rings = { 0.62 }, rows = { { 0.62, 0.95, { 35, 62, 90, 118, 145 } }, { 0.05, 0.62, { 48, 76, 104, 132 } } } })
      g:mark(arc(cx, 8, rx * 0.2, ry * 0.9, 40, 140, 8), A.deep, A.base, A.hi)
      for i = 1, 7 do   -- lichen
        local a, b = cx + (g:rnd(i, 7) - .5) * 24, 10 + g:rnd(i, 8) * 10
        local m = g:E(a, b, 1.6, 1.1); m:clip(dome); g:over(m, f.spots and P.moss.hi or P.moss.base, A.base, A.shade, A.hi)
      end
    elseif reef then
      scutes(g, dome, cx, rx, ry, A, { rings = { 0.64 }, rows = { { 0.64, 0.95, { 30, 60, 90, 120, 150 } }, { 0.06, 0.64, { 45, 80, 115, 145 } } } })
      g:dots({ { -11, 17 }, { -4, 19.4 }, { 6, 15.4 } }, P.sky.hi)
    else
      scutes(g, dome, cx, rx, ry, A, { rings = { 0.6 }, rows = { { 0.6, 0.95, { 28, 54, 80, 106, 132, 158 } }, { 0.05, 0.6, { 42, 76, 110, 144 } } },
        rings2 = { { 0.8, 45 }, { 0.8, 72 }, { 0.8, 99 }, { 0.8, 126 }, { 0.8, 153 }, { 0.3, 60 }, { 0.3, 110 }, { 0.3, 160 } } })
    end
    if q.barnacles then   -- crusty barnacles on the rim
      for _, p in ipairs({ { -15, 12.5 }, { -14, 10.4 }, { 11, 11.5 }, { 12.5, 9.8 } }) do
        local m = g:E(p[1], p[2], 1.5, 1.4); g:over(m, P.cream, A.base, A.shade, A.hi, A.deep)
        g:put(p[1], p[2], P.stone.shade) g:put(p[1] + 1.2, p[2] - 0.8, "#ffe0bd")
      end
    end
    if q.crack then   -- a crack across the shell, mended with a gold seam
      local pts = { { -9, 21 }, { -6.5, 18 }, { -8, 15 }, { -5, 12.5 } }
      g:stroke(pts, A.deep)
      for i = 1, #pts do g:inside(pts[i][1] + 1, pts[i][2], P.gold.base, A.base, A.hi, A.shade) end
    end
    if q.weed then    -- a ribbon of seaweed draped over the rim
      local w = g:Ln1({ { -13, 19 }, { -15.5, 14 }, { -14, 9.5 }, { -16, 6 } }, 2)
      g:fill(w, P.moss.base) w:each(function(x, y) if not w:has(x + 1, y) then c:put(x, y, P.moss.shade) end end)
      g:dots({ { -13.6, 18 }, { -15.3, 13 } }, P.moss.hi)
    end
    -- the head and a thick neck, with a horny beak
    g:T("head")
    local bw = snap and 1.15 or 1
    local head = g:Limb({ { 8, 10 }, { 14, 12.4 } }, 7.5, 6.8)
    head:add(g:E(16.8, 12.6, snap and 6.6 or 5.8, snap and 5.6 or 4.8))
    local beak = snap and g:P({ { 19, 16.5 }, { 25, 14.6 }, { 26.4, 9.4 }, { 23.8, 10.4 }, { 20, 8 } }) or g:P({ { 19.5, 15.4 }, { 24.4, 13.2 }, { 24.6, 10.6 }, { 19.5, 9.2 } })
    head:add(beak)
    g:form(head, B, { frac = 0.3, offu = 2.5, pop = { { 13.5, 15.5 }, { 15, 16.5 } } })
    g:under(head, B.deep) g:toplight(head, B, 1)
    local bk = L.R.tan; if snap then bk = L.R.slate end
    local bm = beak:copy(); bm:cut(g:E(16, 12.5, 4.8, 5)); g:form(bm, bk, { frac = 0.3, off = 1 }) g:under(bm, bk.deep)
    g:dots(snap and { { 25.5, 10.4 }, { 25.2, 11.3 } } or { { 24, 12 } }, bk.deep)
    local my = snap and 9.8 or 9.6                                                                   -- mouth line
    g:stroke({ { 18, my + 1 }, { 21.5, my - 0.4 }, { 24, my } }, B.deep)
    g:dots({ { 22.4, 13.2 }, { 22.9, 12.5 } }, bk.shade)                                            -- nostril
    g:dots({ { 17.2, 9.8 }, { 18.2, 9.8 } }, P.petal.base)
    g:dots({ { 10, 11 }, { 11, 9.5 }, { 11.4, 12.4 } }, B.shade)                                     -- neck folds
    if reef then g:dots({ { 14.6, 8.8 }, { 12.4, 8.4 } }, B.shade) end
    g:T("eyes") g:eye(17.3, 14.2) g:T("head")
    local by = snap and 17.8 or 16.6
    g:dots(snap and { { 15.2, 16.6 }, { 16.4, 17.2 }, { 17.6, 17.4 }, { 18.8, 17.2 }, { 19.8, 16.6 } } or { { 15.6, 16.4 }, { 16.7, 16.7 }, { 17.9, 16.7 }, { 18.8, 16.3 } }, B.deep)  -- a brow
    return { { "body", false, 4, 4 }, { "shell", "body", -7, 8 }, { "head", "body", 10, 8 }, { "eyes", "head", 17.3, 14.2 } }
  end

  ---------------------------------------------------------------- the clam
  local function clam(g)
    local c, f, q, B, A, D, slug = g.c, g.f, g.q, g.B, g.A, g.D, g.s.slug
    g:shadow(0, 20)
    local hx, hy = -9.5, 10.5                                   -- the hinge; the gap opens to the right
    local up, lo = 0.55, -0.16                                  -- slopes of the upper and lower lip
    local gap = g:P({ { hx, hy }, { 32, hy + up * 41.5 }, { 32, hy + lo * 41.5 } })
    -- body: the soft flesh that fills the gap (in shadow), a lip of mantle frill and a small muscular foot
    g:T("body")
    local flesh = gap:copy(); flesh:clip(g:R(-12, 0, 15.5, 40))
    local PK = L.darker(L.R.petal)
    g:form(flesh, PK, { frac = 0.3, offu = 2 }) g:under(flesh, PK.deep)
    for i = 0, 6 do g:inside(-3 + i * 2.7, 8.8 + i * 0.3, PK.shade, PK.base) g:inside(-2 + i * 2.7, 9.6 + i * 0.3, PK.deep, PK.base, PK.shade) end   -- frills
    -- shell: two ribbed valves, the upper one lifted, with a row of little teeth along both lips
    g:T("shell")
    local sh = g:E(1.2, 12.8, 16.6, 12.9); sh:clip(g:R(-40, 0, 40, 60))
    sh:cut(gap)
    g:form(sh, A, { frac = 0.3, offu = 3, pop = { { -9, 22 }, { -6, 24 }, { -12, 16 } } })
    g:under(sh, A.deep) g:toplight(sh, A, 1)
    for k = -6, 6 do   -- ribs fanning out from the hinge: a dark groove and the lit ridge beside it
      local th = math.rad(k * 12 + 8)
      local a0, b0 = hx + 3.5 * cos(th), hy + 3.5 * sin(th); local a1, b1 = hx + 28 * cos(th), hy + 28 * sin(th)
      g:mark({ { a0, b0 }, { a1, b1 } }, A.shade, A.base, A.hi)
      g:mark({ { a0 - 0.7, b0 + 0.8 }, { a1 - 0.7, b1 + 0.8 } }, A.hi, A.base)
    end
    sh:each(function(x, y) if gap:has(x + 1, y) or gap:has(x, y + 1) or gap:has(x, y - 1) then L.inside(c, x, y, A.hi, A.base, A.shade) end end)   -- a pale lip along the gap
    for _, r in ipairs({ 11, 17, 23 }) do g:mark(arc(hx, hy, r, r, -50, 75, 22), A.shade, A.base, A.hi) end   -- growth rings
    g:fill(g:R(-13, 8.6, -10.2, 12.4), A.deep) g:dots({ { -12.4, 12 }, { -11.4, 12 } }, A.hi)                 -- the hinge
    for i = 1, 7 do   -- teeth
      local a = hx + 2.5 + i * 2.1
      if a < 14.5 then
        local ub, lb = hy + up * (a - hx), hy + lo * (a - hx)
        g:dots({ { a, ub - 1.2 }, { a + 1, ub - 2 } }, P.cream) g:dots({ { a, lb + 1.2 }, { a + 1, lb + 2 } }, P.cream)
      end
    end
    if q.pearl then   -- a pearl rests on the lower lip
      g:fill(g:E(11.6, 8.2, 1.6, 1.6), P.cream); g:dots({ { 12.4, 7.4 } }, "#f0b98d") g:put(10.8, 9.2, P.sky.hi)
    end
    -- the head peeks out of the gap, one eye wide open
    g:T("head")
    local head = g:E(10.5, 13.4, 6, 5.3); head:add(g:E(15.2, 11.6, 3.6, 3.2))
    g:form(head, B, { frac = 0.32, offu = 2.5, pop = { { 7.6, 16.4 }, { 8.8, 17.2 } } })
    g:under(head, B.deep) g:toplight(head, B, 1)
    g:dots({ { 15.2, 9.4 }, { 16.2, 9.2 }, { 17, 9.6 } }, B.deep)                                          -- a sly mouth
    g:dots({ { 11.8, 10 }, { 12.6, 10 } }, P.petal.base)
    g:T("eyes") g:eye(12.4, 14.4) g:T("head")
    g:dots({ { 10.2, 17 }, { 11.4, 17.5 }, { 12.6, 17.6 }, { 13.8, 17.2 } }, B.deep)                       -- heavy brow: lurking
    return { { "body", false, 4, 4 }, { "shell", "body", -9, 11 }, { "head", "body", 8, 10 }, { "eyes", "head", 12.4, 14.4 } }
  end

  return function(g)
    local slug = g.s.slug
    if slug:find("clam") then return clam(g) end
    if slug:find("turtle") or slug:find("tortoise") or slug:find("snapper") then return turtle(g) end
    return snail(g)
  end
end
