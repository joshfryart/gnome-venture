-- bug: insects and their kin, SIDE view, facing right. Five kinds (spec feat.kind, the same rule as the old art): ant, beetle, plain, moth, wasp.
-- Parts (ids as the old art / fightarch.js expect them):
--   ant     leg1-3, abdo, body (thorax), head, eyes, antL, antR              (+ leaf)
--   beetle  leg1-3, body (shell + pronotum), head, eyes, antL, antR          (+ ball)
--   plain   leg1-3, [wingB, wingF], body, head, eyes, antL, antR
--   moth    leg1-2, wingB, wingF, wingH, body, head, eyes, antL, antR        (+ cloud)
--   wasp    leg1-3, wingB, wingF, abdo, body, head, eyes, antL, antR
-- Every leg part holds a near leg and a darker far leg a few units forward; every antenna part is one feeler (antL = far, darker).
-- Spec features: pincers (ant jaws, earwig forceps, mole cricket cerci), wings, stripes, spots, shell (spines, armour plates, domed back),
--   horns (rhino horn, stag jaws, weevil thorns, moth/hornet antlers), snout (weevil rostrum).
-- Sub-animals picked by slug: gnat-cloud, sand-fleas, earwig, mole-cricket, withered-aphid, page-silverfish, drumming-cricket, dung-beetle, ember-beetle,
--   pill-bug-brute, shale-slater, root-weevil, grub-beetle, stag-beetle-patrol, bellcap-beetle, dusk-moth, dimwing-moth, blight-mother,
--   paper-wasp, giant-bumblebee, old-thrum, ant-scouts, ashen-ant, leafcutter-column.
-- Quirks (quirks/bug.lua), one per creature:
--   ant-scouts bent=true (one feeler folds back)        ashen-ant soot=true (soot streaks on the face)     leafcutter-column leaf=true (carries a leaf piece, extra part "leaf")
--   gnat-cloud swarm=n (n little gnats, extra part "cloud")     sand-fleas shellhat=true (a seashell scrap on its head)
--   dusk-moth moon=true (crescent on the wing)          dimwing-moth torn=true (a bite out of the hindwing)    blight-mother tear=true (a tear under the eye)
--   dung-beetle ball=true (a dung ball, extra part "ball")   earwig ring=true (a gold ring on a forceps)     paper-wasp bow=true (a bow on a feeler)
--   ember-beetle flame=true (a flame licks from a shell crack)   giant-bumblebee flower=true (a flower on its head)   pill-bug-brute heart=true (a heart on a plate)
--   root-weevil rootlet=true (a root hangs from the snout)   mole-cricket dirt=true (a soil clod on its brow)   grub-beetle grub=true (a grub rides its back)
--   withered-aphid drop=true (a honeydew drop)           stag-beetle-patrol chipped=true (a broken jaw tooth)   page-silverfish scrap=true (a scrap of page stuck on)
--   drumming-cricket note=true (a music note on the wing)    old-thrum scar=true (a scar across the face)   shale-slater moss=true (moss on its back)
--   bellcap-beetle sprout=true (a toadstool sprouts on the shell)
return function(L)
  local P, HP = L.P, L.HP
  local floor, ceil, sqrt, max, min, sin, cos, rad = math.floor, math.ceil, math.sqrt, math.max, math.min, math.sin, math.cos, math.rad
  local STR = { base = P.dusk.deep, shade = P.ink }                -- dark stripe / band colours

  ---------------------------------------------------------------- local helpers
  -- an ellipse turned `deg` degrees (counter-clockwise, 0 = long axis pointing right), figure units
  local function tilted(g, a, b, ra, rb, deg)
    local m, th = HP.mask(), rad(deg)
    local co, si = cos(th), sin(th)
    local R = max(ra, rb) * g.u + 2
    local cx, cy = g.ox + a * g.u, g.gy - b * g.u
    for y = floor(cy - R), ceil(cy + R) do for x = floor(cx - R), ceil(cx + R) do
      local dx, dy = x + .5 - cx, cy - (y + .5)
      local p, q = dx * co + dy * si, -dx * si + dy * co
      if (p / (ra * g.u)) ^ 2 + (q / (rb * g.u)) ^ 2 <= 1 then m:set(x, y) end
    end end
    return m
  end
  local function solid(g, m, r, o)           -- form + deep underside + broken top light
    o = o or {}
    g:form(m, r, o); g:under(m, r.deep)
    if o.light ~= false then g:toplight(m, r) end
    return m
  end
  local function cheek(g, a, b) local x, y = g:x(a), g:y(b); g.c:put(x, y, P.petal.base); g.c:put(x + 1, y, P.petal.base) end
  local function band(g, m, r, br)           -- re-colour the pixels of ramp r inside m with the band ramp br (stripes that keep the shading)
    local c = g.c
    local map = { [r.hi:lower()] = br.base, [r.base:lower()] = br.base, [r.shade:lower()] = br.shade, [r.deep:lower()] = br.shade }
    m:each(function(x, y) local v = c:get(x, y); if v and map[v] then c:put(x, y, map[v]) end end)
  end
  local function eyes(g, a, b) g:T("eyes"); g:eye(a, b) end
  local function topOf(a, ca, cb, ra, rb) local t = 1 - ((a - ca) / ra) ^ 2; return cb + rb * sqrt(max(t, 0)) end   -- height of an ellipse at a
  local function arcPts(ca, cb, ra, rb, k, t0, t1, n)   -- points along an ellipse scaled by k, angles in degrees
    local t = {}
    for i = 0, n do local d = rad(t0 + (t1 - t0) * i / n); t[#t + 1] = { ca + k * ra * cos(d), cb + k * rb * sin(d) } end
    return t
  end

  -- one leg part: a near leg and a darker far leg. h/k/f = hip, knee, foot (a only; the foot stands on the ground).
  local function leg(g, id, h, k, f, o)
    o = o or {}
    g:T(id)
    local near, far = o.near or g.D, o.far or L.darker(g.D)
    local w0, w1 = o.w0 or 2.2, o.w1 or 1.5
    local wpx = max(1, floor(w1 * g.u + .5)); local up = wpx - 1 - floor((wpx - 1) / 2)
    local fb = (1 + up) / g.u                                  -- foot height so the last pixel row is g.gy - 1
    for pass = 1, 2 do
      local r = pass == 1 and far or near
      for _, rep in ipairs(o.reps or { 0 }) do
        local dx = (pass == 1 and (o.fo or 3) or 0) + rep
        local m = g:Ln({ { h[1] + dx, h[2] }, { k[1] + dx, k[2] } }, w0)
        m:add(g:Ln({ { k[1] + dx, k[2] }, { f + dx, fb } }, w1))
        g:form(m, r, { frac = .5, off = 1 })
        g:inside(k[1] + dx, k[2] + .5, r.hi, r.base)
        if o.extra then o.extra(m, pass == 2, dx, r, fb) end
      end
    end
  end
  -- one feeler part: a thin line with an optional tip ("ball", "club", "fan")
  local function feeler(g, id, pts, r, tip)
    g:T(id)
    local wpx = g.u >= 1.5 and 2 or 1
    g:fill(g:Ln1(pts, wpx), r.base)
    local e, p = pts[#pts], pts[#pts - 1]
    if tip == "ball" then g:form(g:E(e[1], e[2], 1.3, 1.3), r, { frac = .4, off = 1, inner = false })
    elseif tip == "club" then g:form(g:E(e[1], e[2], 1.8, 1.4), r, { frac = .4, off = 1, inner = false })
    elseif tip == "fan" then for i = -1, 1 do g:stroke({ e, { e[1] + 2 * (e[1] - p[1]) / 3 + i * 1.8, e[2] + 2 * (e[2] - p[2]) / 3 + (i == 0 and 0 or -i * 1.2) } }, r.base) end end
    g:inside(pts[1][1], pts[1][2], r.hi, r.base)
  end
  local function feathered(g, id, pts, r)    -- moth feeler: a shaft with little barbs
    g:T(id)
    g:fill(g:Ln1(pts, 1), r.base)
    for i = 1, #pts - 1 do
      local a0, b0, a1, b1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
      local steps = max(2, floor(sqrt((a1 - a0) ^ 2 + (b1 - b0) ^ 2) / 1.6))
      for s = 1, steps do local t = s / steps; local a, b = a0 + (a1 - a0) * t, b0 + (b1 - b0) * t
        g:stroke({ { a, b }, { a - 1.7, b + .6 } }, r.shade) g:stroke({ { a, b }, { a + 1.7, b + .6 } }, r.shade) end
    end
  end

  ---------------------------------------------------------------- ANT
  local function ant(g)
    local c, q, B, A, D = g.c, g.q, g.B, g.A, g.D
    local slug = g.s.slug
    local leafy, ashen = slug == "leafcutter-column", slug == "ashen-ant"
    local jaw = leafy and L.R.bark or A
    g:shadow(-1, 21)
    leg(g, "leg1", { -4.5, 10.5 }, { -11, 9 }, -13.5, { w0 = 2, w1 = 1.4 })
    leg(g, "leg2", { 0.5, 10.5 }, { 3.5, 7 }, 5, { w0 = 2, w1 = 1.4 })
    leg(g, "leg3", { 5, 10.5 }, { 11.5, 9 }, 14, { w0 = 2, w1 = 1.4 })
    -- gaster: a glossy egg with ring joints
    g:T("abdo")
    local ab = g:E(-14.5, 13.5, 9.5, 7.3); ab:add(g:E(-21, 12.8, 4, 4.6)); ab:add(g:E(-9, 12.8, 4, 5))
    solid(g, ab, B, { frac = .3, offu = 3, pop = { { -18, 18.5 } } })
    for _, a in ipairs({ -11.5, -15.5, -19.5 }) do
      g:mark({ { a, 19.8 }, { a - 1, 14 }, { a - .5, 8.2 } }, B.deep, B.base, B.shade)
      g:mark({ { a + 1.1, 19 }, { a + .3, 15 } }, B.hi, B.base)
    end
    g:put(-22.5, 15, B.hi)
    -- thorax with the thin waist node; leafcutters carry thorn spines
    g:T("body")
    local th = g:E(-0.5, 14.5, 5.8, 5.2); th:add(g:E(0.5, 16.7, 4, 4)); th:add(g:E(-7.2, 13.2, 2.4, 2.6))
    if g.f.shell then
      th:add(g:P({ { -4.5, 18 }, { -6.5, 24 }, { -1.5, 19.5 } })); th:add(g:P({ { 0, 20 }, { 1.5, 25.5 }, { 3.8, 19 } }))
    end
    solid(g, th, B, { frac = .3, offu = 2.5, pop = { { -3, 19 } } })
    g:mark({ { -3.5, 12 }, { -2.5, 16.5 } }, B.shade, B.base)                                 -- a seam in the thorax
    g:mark({ { 2.5, 11.5 }, { 3.2, 15 } }, B.shade, B.base)
    g:dots({ { -1.5, 18.8 }, { 2.2, 17.8 }, { 0.5, 14.8 } }, B.shade)                         -- hair pits
    if leafy then g:T("leaf")                                                                  -- the leaf piece, held up in the jaws (extra part, behind the head)
      local lf = tilted(g, 24, 22, 9.6, 5.6, 84)
      lf:cut(g:E(25.5, 30.5, 2.6, 2.2))                                                         -- a bite out of the rim
      solid(g, lf, A, { frac = .3, off = 1, pop = { { 22.5, 26 } } })
      g:mark({ { 22.8, 13.5 }, { 23.8, 20 }, { 24.3, 28 } }, A.deep, A.base, A.shade, A.hi)    -- midrib
      for i = 0, 3 do local b = 16 + i * 3.2
        g:mark({ { 23.6, b }, { 26.8, b + 1.9 } }, A.shade, A.base, A.hi) g:mark({ { 23.6, b + .6 }, { 20.5, b + 2.4 } }, A.shade, A.base, A.hi) end
    end
    -- head: round-topped with big jaws
    g:T("head")
    local hd = g:E(11.5, 17.5, 8, 7)
    solid(g, hd, B, { frac = .3, offu = 3, pop = { { 7, 22 } } })
    g:mark({ { 6, 15 }, { 8.5, 13 } }, B.shade, B.base)
    cheek(g, 15.6, 14.4)
    local function mand(sg, r)                                                                  -- one jaw: a curved horn, the two meet at the tips
      local y0 = 14.5 + sg * 1.2
      local m = g:Ln({ { 17, y0 }, { 21, 14.5 + sg * 3.2 }, { 24.3, 14.6 + sg * .6 } }, 1.9)
      g:form(m, r, { frac = .4, off = 1, inner = false })
    end
    mand(1, jaw); mand(-1, L.darker(jaw))
    g:dots({ { 22, 13.8 }, { 23.4, 14 } }, jaw.hi)
    if ashen then   -- soot streaks over the cheek and brow
      g:mark({ { 7, 20.5 }, { 10, 22 } }, STR.base, B.base, B.shade, B.hi) g:mark({ { 14, 13 }, { 17.5, 12 } }, STR.base, B.base, B.shade)
      g:mark({ { 5.5, 17.5 }, { 8.5, 18.5 } }, STR.base, B.base, B.shade) g:mark({ { 15.5, 21.5 }, { 18, 20 } }, STR.base, B.base, B.shade, B.hi)
    end
    eyes(g, 13.5, 19.6)
    local rf = ashen and L.R.slate or D
    feeler(g, "antL", { { 8.5, 23.5 }, { 7, 28.5 }, { 10.5, 31.5 }, { 14, 31.5 } }, L.darker(D), "ball")
    local tipR = q.bent and { { 12.5, 23.5 }, { 14.5, 28.5 }, { 19, 30.5 }, { 19.5, 33.5 }, { 17, 35 } } or { { 12.5, 23.5 }, { 14.5, 28.5 }, { 19, 30.5 }, { 22, 29 } }
    feeler(g, "antR", tipR, D, "ball")
    local bones = { { "body", false, -1, 14 }, { "leg1", "body", -4.5, 10.5, true }, { "leg2", "body", 0.5, 10.5, true }, { "leg3", "body", 5, 10.5, true },
      { "abdo", "body", -5, 14, true }, { "head", "body", 5, 15 }, { "eyes", "head", 13.5, 19.6 }, { "antL", "head", 8.5, 23.5 }, { "antR", "head", 12.5, 23.5 } }
    if leafy then bones[#bones + 1] = { "leaf", "head", 22.5, 14, true } end
    return bones
  end

  ---------------------------------------------------------------- BEETLE (also the isopods and the weevil)
  local function beetle(g)
    local c, f, q, B, A, D = g.c, g.f, g.q, g.B, g.A, g.D
    local slug = g.s.slug
    local dung, ember, weevil, stag, grub, bell = slug == "dung-beetle", slug == "ember-beetle", slug == "root-weevil", slug:find("stag") ~= nil, slug == "grub-beetle", slug == "bellcap-beetle"
    local pill, slater = slug == "pill-bug-brute", slug == "shale-slater"
    local iso = pill or slater
    -- the shell: ellipse centre / radii
    local ca, cb, ra, rb = -5, 15.5, 14.5, 11
    if pill then ca, cb, ra, rb = -3, 14, 15, 10.5 elseif slater then ca, cb, ra, rb = -3.5, 11.8, 16.5, 8 elseif bell then ca, cb, ra, rb = -4, 16, 14.5, 11.5
    elseif weevil then ca, cb, ra, rb = -5, 14.5, 13, 10.5 elseif dung then cb, rb = 15, 10.5 end
    local DY = slater and 0.8 or (pill and 1.6 or 2.5)                                   -- the shell rides this high above the ground (legs show below)
    local G = g
    g = setmetatable({ gy = G.gy - floor(DY * G.u + .5) }, { __index = G })               -- g draws the raised body, G stays on the ground
    DY = floor(DY * G.u + .5) / G.u
    local hb = (slater and 8 or 9.5) + DY                                                 -- hip height above the ground
    G:shadow(ca + 1, ra + 5)
    if iso then   -- many tiny legs: each leg part holds a pair per side
      local o = { w0 = 1.8, w1 = 1.3, fo = 2, reps = { -1.8, 1.8 } }
      leg(G, "leg1", { -9, hb }, { -11.5, hb - 3 }, -12.5, o); leg(G, "leg2", { -1, hb }, { -1.5, hb - 3 }, -1.5, o); leg(G, "leg3", { 7, hb }, { 8.5, hb - 3 }, 9.5, o)
    else
      local o1 = dung and { w0 = 2.8, w1 = 1.8 } or { w0 = 2.4, w1 = 1.6 }
      leg(G, "leg1", { -9, hb }, { -14.5, 8 }, -16.5, o1)
      leg(G, "leg2", { -1, hb }, { 3, 7 }, 4.5, { w0 = 2.2, w1 = 1.5 })
      leg(G, "leg3", { 7, hb }, { 13.5, 8 }, 16, { w0 = 2.2, w1 = 1.5 })
    end
    if dung and q.ball then   -- a ball of dung it is pushing (extra part, behind the head)
      local g = G; g:T("ball")
      local bl = g:E(27, 7.3, 6.3, 6.3)
      g:form(bl, A, { frac = .32, off = 2, pop = { { 24, 11.5 } } }); g:under(bl, A.deep)
      for i = 1, 9 do local a, b = 27 + (g:rnd(i, 6) - .5) * 9, 7.3 + (g:rnd(i, 7) - .5) * 9; g:inside(a, b, A.deep, A.base, A.shade); g:inside(a + .8, b, A.shade, A.base) g:inside(a, b + 1, A.hi, A.base) end
      g:mark({ { 22.6, 4.5 }, { 25, 8 }, { 24.5, 11 } }, A.shade, A.base, A.hi) g:mark({ { 27.5, 2.5 }, { 29, 5.5 }, { 32, 6.5 } }, A.shade, A.base)
      g:fill(g:R(28.5, 12, 29.5, 15), L.R.moss.base); g:put(29, 15.8, L.R.moss.hi)                       -- a straw stuck in it
    end
    -- shell
    g:T("body")
    local shell = g:E(ca, cb, ra, rb)
    if slater then shell:add(g:E(ca - 12.5, cb - 1.5, 5, 5.5)) end                       -- the tail plate
    solid(g, shell, B, { frac = .3, offu = 3.5, pop = { { ca - 8, cb + rb * .75 }, { ca - 9.5, cb + rb * .62 } } })
    if iso then
      -- armour plates: overlapping bands, each with a dark seam and a lit lip
      local n = pill and 7 or 8
      for i = 1, n do
        local a = ca - ra * .86 + (i - 1) * (ra * 1.72 / n) * 1.0 + 0.5
        local tb = topOf(a, ca, cb, ra, rb) - .3
        g:mark({ { a, tb }, { a - 1.4, cb - rb * .3 }, { a - 1.8, cb - rb * .72 } }, (pill and A or L.darker(B)).base, B.base, B.hi, B.shade)
        g:mark({ { a + 1.1, tb - .3 }, { a - .3, cb - rb * .3 } }, B.hi, B.base)
      end
      if pill then
        local tint = g:E(ca - 2, cb, ra - 2, rb - 2); tint:cut(g:R(-40, -5, 40, cb + rb * .5))
        g:over(g:R(ca - ra - 1, 0, ca + ra + 1, cb - rb * .72), B.shade, B.base)              -- a darker lower skirt
      else
        for i = 1, 9 do local a, b = ca - 14 + g:rnd(i, 1) * 28, cb - 3 + g:rnd(i, 2) * 8; g:mark({ { a, b }, { a + 2, b - .8 } }, B.shade, B.base, B.hi) end   -- flaking shale
        g:mark({ { ca - 5, cb + 4 }, { ca + 6, cb + 3 } }, L.lighter(B).base, B.base, B.shade)
      end
    else
      -- wing-case grooves, a seam, glossy streaks
      for _, k in ipairs({ .55, .8 }) do g:mark(arcPts(ca, cb, ra, rb, k, 168, 40, 12), B.shade, B.base, B.hi) end
      g:mark({ { ca - 14.2, cb - .5 }, { ca - 7, cb + 2 }, { ca, cb + 2 }, { ca + 4, cb + 3 } }, B.deep, B.base, B.shade)
      g:mark({ { ca - 9, cb + 8.2 }, { ca - 5, cb + 9.4 } }, B.hi, B.base) g:mark({ { ca - 12.5, cb + 5.4 }, { ca - 10.5, cb + 6.8 } }, B.hi, B.base)
      g:dots({ { ca - 3, cb + 6.5 } }, B.hi)
      if f.spots or bell then
        local sp = { { -12, 20 }, { -8.5, 12.5 }, { -5, 22.5 }, { -1.5, 15 }, { -15, 12 }, { 1.5, 21 }, { -9, 17 } }
        for i, s in ipairs(sp) do if shell:has(g:x(s[1]), g:y(s[2])) then
          local m = g:E(s[1], s[2], i % 2 == 0 and 1.9 or 1.5, i % 2 == 0 and 1.9 or 1.5); m:clip(shell); g:fill(m, bell and A.hi or STR.base); if bell then g:over(m:edge(), A.base, A.hi) end end end
      end
      if ember then   -- glowing cracks across the shell
        local ck = { { { ca - 11, cb + 3 }, { ca - 8.5, cb + 1 }, { ca - 7, cb - 2 }, { ca - 9, cb - 5 } }, { { ca - 3, cb + 9 }, { ca - 1, cb + 6 }, { ca - 3.5, cb + 3 }, { ca - 2.5, cb - .5 } } }
        for _, p in ipairs(ck) do g:mark(p, A.base, B.base, B.shade, B.hi) end
        g:mark({ { ca - 8.2, cb + 1 }, { ca - 5.5, cb + 1.6 } }, A.hi, A.base, B.base, B.shade) g:put(ca - 3.5, cb + 3, A.hi)
      end
      if grub then for i = 1, 12 do local a, b = ca - 12 + g:rnd(i, 4) * 22, cb - 6 + g:rnd(i, 5) * 15; g:inside(a, b, B.shade, B.base) g:inside(a, b + 1, B.hi, B.base) end end   -- rough grit
    end
    -- pronotum (the shield behind the head)
    if not iso then
      local pr = weevil and g:E(6.5, 14.8, 5, 7.6) or g:E(7, 14.6, 5, 7.8)
      if stag or ember then pr = g:E(7.2, 14.2, 5.2, 7) end
      local pr_r = B
      if weevil then   -- two thorns
        pr:add(g:P({ { 3, 21 }, { 2.5, 26 }, { 6.5, 21.5 } })); pr:add(g:P({ { 6.5, 21 }, { 8, 25.5 }, { 10, 20 } }))
      end
      if ember then pr:add(g:P({ { 5.5, 20 }, { 8, 28 }, { 11.2, 19 } })) end              -- a second, smaller horn on the shield
      solid(g, pr, pr_r, { frac = .3, off = 2, pop = { { 4.5, 19.5 } }, inner = true })
      if pr_r == B then g:over(pr:copy():cut(g:E(14, 10, 8, 7)):edge(), B.deep, B.base, B.shade, B.hi) end
      g:mark({ { 5.5, 10.5 }, { 6, 18.5 } }, pr_r.shade, pr_r.base)                         -- a centre groove
      g:dots({ { 9.5, 11 }, { 3.5, 13.5 }, { 8.5, 17.5 } }, pr_r.shade)
    else
      g:dots({ { ca + 7, cb + 4.5 }, { ca + 10, cb + 2 } }, B.hi)
    end
    -- quirks painted into the body
    if q.heart then local x, y = g:x(ca - 6), g:y(cb + 5)   -- a little heart on a plate
      for _, p in ipairs({ { 0, 0 }, { 1, 0 }, { 3, 0 }, { 4, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 }, { 4, 1 }, { 1, 2 }, { 2, 2 }, { 3, 2 }, { 2, 3 } }) do c:put(x + p[1], y + p[2], P.petal.base) end
      c:put(x, y, P.petal.hi) c:put(x + 1, y, P.petal.hi) c:put(x + 3, y + 1, P.petal.shade) c:put(x + 4, y + 1, P.petal.shade) c:put(x + 2, y + 3, P.petal.shade) c:put(x + 3, y + 2, P.petal.shade) end
    if q.flame then   -- a flame licks out of the biggest crack
      local x, y = g:x(ca - 3), g:y(cb + 9.5)
      local fl = g:P({ { ca - 5, cb + 8.2 }, { ca - 4.6, cb + 12 }, { ca - 3.6, cb + 14.5 }, { ca - 2.6, cb + 12.5 }, { ca - 1.4, cb + 13.5 }, { ca - 1.2, cb + 9 } })
      g:fill(fl, P.ember.base); g:over(fl:shrink(1), P.gold.base, P.ember.base); g:put(ca - 3, cb + 10.5, P.cream); g:put(ca - 4.2, cb + 8.5, P.ember.shade) g:put(ca - 1.6, cb + 8.5, P.ember.shade) end
    if q.moss then   -- a tuft of moss on the back: a few round lumps
      local M = L.R.moss
      for i, d in ipairs({ { -1, 1.9 }, { 2, 2.4 }, { 5, 1.8 }, { 0.8, 3.3 } }) do
        local a = ca + d[1]; local t = topOf(a, ca, cb, ra, rb)
        local m = g:E(a, t + (i == 4 and 2.8 or 1.2), d[2], d[2] * .8); g:form(m, M, { frac = .35, off = 1, inner = false, pop = { { a - .8, t + 2 } } }) end
    end
    if q.grub then   -- a plump pale grub curled on its back
      local gx = ca - 4
      local gr = g:E(gx, cb + rb + .5, 4.8, 2.6); gr:add(g:E(gx - 4.5, cb + rb - .4, 2.4, 2.2)); gr:add(g:E(gx + 4, cb + rb - .8, 2.2, 2))
      g:form(gr, L.R.cream, { frac = .3, off = 1, inner = false }); g:over(gr:copy():cut(gr:shift(0, 1)), L.R.cream.deep, L.R.cream.base)
      g:mark({ { gx - 1.5, cb + rb + 3 }, { gx - 1.5, cb + rb - .4 } }, L.R.cream.shade, L.R.cream.base, L.R.cream.hi)
      g:mark({ { gx + 1.5, cb + rb + 3 }, { gx + 1.5, cb + rb - .4 } }, L.R.cream.shade, L.R.cream.base, L.R.cream.hi)
      g:dots({ { gx + 5, cb + rb - .2 } }, STR.shade)
      g:dots({ { gx - 4.8, cb + rb + .2 } }, STR.shade) end
    if q.sprout then   -- a toadstool sprouting from the shell
      local sx, st = ca + 2, topOf(ca + 2, ca, cb, ra, rb)
      local stem = g:R(sx - .7, st - 1, sx + .7, st + 4.5); g:form(stem, L.R.cream, { noshade = true }); g:over(stem, L.R.cream.shade, L.R.cream.base)
      local cap = g:E(sx, st + 5, 3.6, 2.2); cap:cut(g:R(sx - 5, st - 2, sx + 5, st + 4.8)); g:form(cap, P.petal, { frac = .35, off = 1, inner = false })
      g:dots({ { sx - 1.2, st + 5.8 }, { sx + 1.5, st + 5.2 } }, P.cream) end
    -- head
    g:T("head")
    local hx, hy, hr, hh = 14.8, 10.8, 6, 5.4
    if dung then hx, hy, hr, hh = 15, 9.8, 6.5, 5 elseif stag then hx, hy, hr, hh = 14.5, 11, 6.8, 6 elseif weevil then hx, hy, hr, hh = 14, 11.5, 6, 5.6
    elseif pill then hx, hy, hr, hh = 15.5, 8.2, 4.8, 4.4 elseif slater then hx, hy, hr, hh = 15.5, 8.2, 4.6, 4 elseif bell then hx, hy, hr, hh = 14.5, 11, 6.5, 6 end
    local hd = g:E(hx, hy, hr, hh)
    if dung then   -- a broad clypeus with a toothed rake
      hd:add(g:E(hx + 3, hy - 1.5, 4.5, 3.3))
      for i = 0, 3 do hd:add(g:P({ { hx + 5.4 + i * 0.1, hy + 1.2 - i * 1.9 }, { hx + 9.2, hy + .7 - i * 1.9 }, { hx + 5.4, hy - .8 - i * 1.9 } })) end
    end
    if weevil then   -- the long snout (rostrum) curving down
      hd:add(g:Ln({ { 18, 10.4 }, { 24, 10 }, { 28.5, 7.2 }, { 30, 4 } }, 3.4)); hd:add(g:E(29.8, 4.4, 1.7, 1.8))
    end
    solid(g, hd, B, { frac = .3, offu = 3, pop = { { hx - 4, hy + hh - 2 } } })
    if weevil then g:mark({ { 22, 9 }, { 27, 7 } }, B.shade, B.base) g:mark({ { 19, 11.8 }, { 24.5, 11.6 } }, B.hi, B.base)
      g:dots({ { 29.5, 4 }, { 28.8, 5.4 } }, B.deep); g:dots({ { 27.5, 8.8 } }, B.hi) end
    if q.rootlet then   -- a pale rootlet snagged on the snout tip
      g:stroke({ { 31, 4.5 }, { 33, 5.5 }, { 34.5, 4 }, { 36.5, 4.8 } }, L.R.cream.base); g:stroke({ { 33, 5.5 }, { 34, 7.5 } }, L.R.cream.shade)
    end
    if dung then for i = 0, 3 do g:put(hx + 6, hy - .5 - i * 1.9, B.deep) end end
    if ember then   -- a big curved rhino horn
      local hm = g:Ln({ { 17.2, 13.8 }, { 20.6, 17.6 } }, 3.4); hm:add(g:Ln({ { 20.6, 17.6 }, { 22.8, 22 } }, 2.6)); hm:add(g:Ln({ { 22.8, 22 }, { 22.6, 26.4 } }, 1.6))
      g:form(hm, A, { frac = .35, off = 1, pop = { { 19.5, 16.2 } }, inner = false }); g:over(hm:edge(), A.shade, A.base)
    end
    if stag then   -- antler jaws: near jaw bright, far jaw darker, each with teeth
      local function jawm(dy, r)
        local m = g:Ln({ { 19.5, 13 + dy }, { 25.5, 12.6 + dy }, { 29.5, 16.2 + dy } }, 2.7); m:add(g:Ln({ { 29.5, 16.2 + dy }, { 31, 21 + dy } }, 1.8)); m:add(g:Ln({ { 31, 21 + dy }, { 30.2, 24 + dy } }, 1.1))
        m:add(g:P({ { 24, 14 + dy }, { 25, 17 + dy }, { 27, 15 + dy } }))
        if q.chipped and dy > 0 then m:cut(g:P({ { 27, 21.5 }, { 33, 21.5 }, { 33, 27 }, { 27, 27 } })) end
        g:form(m, r, { frac = .35, off = 1, inner = false }); return m
      end
      local far = jawm(-4.5, L.darker(A)); local near = jawm(0.8, A)
      g:over(near:edge(), A.shade, A.base) g:dots({ { 22.5, 14.2 }, { 28.4, 17.6 } }, A.hi)
    end
    if bell then g:dots({ { 11, 15.5 }, { 14, 16.6 } }, B.hi) end
    if not (weevil or dung) then g:dots({ { hx + 4, hy - 3.6 }, { hx + 5, hy - 3.6 } }, B.deep) end    -- mouth corner
    if not weevil then cheek(g, hx + 2.5, hy - 2.2) end
    -- eyes and feelers
    local ex, ey = hx - .2, hy + 2
    if pill or slater then ex, ey = hx - .6, hy + 1.6 end
    eyes(g, ex, ey)
    local tipk = grub and "fan" or "club"
    local ar = { { hx - 2, hy + hh - .5 }, { hx - 4, hy + hh + 4 }, { hx - 1, hy + hh + 8 } }
    local br = { { hx + 1, hy + hh - .5 }, { hx + 4.5, hy + hh + 3.5 }, { hx + 8.5, hy + hh + 5 } }
    if iso then ar = { { hx - 1, hy + hh - 1 }, { hx - 3, hy + hh + 3 }, { hx - 1.5, hy + hh + 6.5 } }; br = { { hx + 1.5, hy + hh - 1 }, { hx + 5, hy + hh + 2 }, { hx + 8, hy + hh + 2 } }; tipk = "ball" end
    if weevil then ar = { { 23.5, 11 }, { 21.5, 16.5 }, { 23.5, 20.5 } }; br = { { 24.5, 10.5 }, { 28, 14.5 }, { 30.5, 15.5 } } end
    if ember then br = { { hx + 1.5, hy + hh - .5 }, { hx + 3, hy + hh + 3.5 }, { hx + 6, hy + hh + 5 } } end
    if stag then br = { { hx + 1, hy + hh - .5 }, { hx + 3.5, hy + hh + 3.5 }, { hx + 6, hy + hh + 4.5 } } end
    feeler(g, "antL", ar, L.darker(D), tipk); feeler(g, "antR", br, D, tipk)
    local bones = { { "body", false, ca, cb + DY }, { "leg1", "body", -9, hb, true }, { "leg2", "body", -1, hb, true }, { "leg3", "body", 7, hb, true },
      { "head", "body", 8, hy + 1 + DY }, { "eyes", "head", ex, ey + DY }, { "antL", "head", ar[1][1], ar[1][2] + DY }, { "antR", "head", br[1][1], br[1][2] + DY } }
    if dung and q.ball then bones[#bones + 1] = { "ball", "body", 21, 7, true } end
    return bones
  end

  ---------------------------------------------------------------- PLAIN bugs (flea, earwig, mole cricket, aphid, silverfish, cricket)
  local function plain(g)
    local c, f, q, B, A, D = g.c, g.f, g.q, g.B, g.A, g.D
    local slug = g.s.slug
    local flea, ear, mole, aph, fish, cric = slug == "sand-fleas", slug == "earwig", slug == "mole-cricket", slug == "withered-aphid", slug == "page-silverfish", slug == "drumming-cricket"
    local Ab = { base = A.base, shade = A.shade }
    local function head(hx, hy, rx, ry)
      g:T("head")
      local hd = g:E(hx, hy, rx, ry)
      return hd
    end
    local body, hd, ex, ey, ar, br, pivH
    local bones
    if flea then
      g:shadow(-4, 24)
      leg(g, "leg1", { -9, 11 }, { -17.5, 15.5 }, -13, { w0 = 4.2, w1 = 1.9, fo = 2.5 })
      leg(g, "leg2", { -1, 9.5 }, { 3, 6.5 }, 5, { w0 = 2, w1 = 1.4 })
      leg(g, "leg3", { 6, 9.5 }, { 11, 7 }, 13, { w0 = 2, w1 = 1.4 })
      g:T("body")
      local ch = { { 2, 16.5, 7, 6.5 }, { -4.5, 18.5, 7, 6.5 }, { -11, 16.5, 6.5, 6 }, { -16, 12, 5.2, 5.2 }, { -18.5, 6.8, 3.6, 4.2 } }
      body = HP.mask(); for _, e in ipairs(ch) do body:add(g:E(e[1], e[2], e[3], e[4])) end
      body:add(g:P({ { -17, 3.4 }, { -23.5, 2.6 }, { -20, 7.5 } }))
      solid(g, body, B, { frac = .3, offu = 3, pop = { { -8, 23 }, { -9, 22.4 } } })
      for i = 2, 4, 2 do   -- stripes across two segments
        local e, p, n = ch[i], ch[i - 1], ch[i + 1]
        local tx, ty = p[1] - n[1], p[2] - n[2]; local l = sqrt(tx * tx + ty * ty); local nx, ny = -ty / l, tx / l
        local m = g:Ln({ { e[1] - nx * 9, e[2] - ny * 9 }, { e[1] + nx * 9, e[2] + ny * 9 } }, 2.2); m:clip(body); band(g, m, B, Ab)
      end
      for i = 1, 4 do local e, n = ch[i], ch[i + 1]; local a, b = (e[1] + n[1]) / 2 - 0.5, (e[2] + n[2]) / 2
        local tx, ty = e[1] - n[1], e[2] - n[2]; local l = sqrt(tx * tx + ty * ty); local nx, ny = -ty / l, tx / l
        g:mark({ { a - nx * 6.5, b - ny * 6.5 }, { a + nx * 6.5, b + ny * 6.5 } }, B.deep, B.base, B.shade, Ab.base, Ab.shade) end
      g:dots({ { -13, 22.8 }, { -7, 25 }, { 0, 23.3 } }, B.hi)
      hd = head(10.2, 14, 6.8, 6.2); ex, ey = 11, 15.6
      solid(g, hd, B, { frac = .3, offu = 3, pop = { { 6, 18 } } }); cheek(g, 13.5, 11.8)
      g:mark({ { 15, 12 }, { 16.8, 11.5 } }, B.deep, B.base, B.shade)
      if q.shellhat then   -- a little seashell worn like a hat
        local sh = g:E(9.2, 19.4, 3.8, 3.1); sh:cut(g:R(0, 0, 20, 19.2)); sh:add(g:R(6.2, 19, 12.2, 19.6))
        g:form(sh, L.R.cream, { frac = .35, off = 1, inner = false })
        for i = -1, 1 do g:mark({ { 9.2, 19.6 }, { 9.2 + i * 2.9, 22 } }, L.R.cream.deep, L.R.cream.base, L.R.cream.shade, L.R.cream.hi) end
        g:put(6.5, 19.5, P.petal.base)
      end
      ar = { { 8.5, 19.5 }, { 7, 25 }, { 9.5, 29 } }; br = { { 12, 19.5 }, { 15.5, 24 }, { 20, 25 } }; pivH = { 5, 14 }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "ball"); feeler(g, "antR", br, D, "ball")
      return { { "body", false, -4, 14 }, { "leg1", "body", -9, 11, true }, { "leg2", "body", -1, 9.5, true }, { "leg3", "body", 6, 9.5, true }, { "head", "body", pivH[1], pivH[2] },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    elseif ear then
      g:shadow(-8, 24)
      leg(g, "leg1", { -8, 9 }, { -13, 7 }, -14.5, { w0 = 2.2, w1 = 1.5 }); leg(g, "leg2", { 0, 9 }, { 2, 6.5 }, 3, { w0 = 2.2, w1 = 1.5 }); leg(g, "leg3", { 7, 9 }, { 12, 7 }, 13.5, { w0 = 2.2, w1 = 1.5 })
      g:T("body")
      body = g:E(-9, 11.4, 13, 5.2); body:add(g:E(4.5, 12, 6.2, 5.4)); body:add(g:E(-20, 11, 4, 3.6))
      local Fk = A
      local fo = g:Ln({ { -22, 12 }, { -27, 14.6 }, { -31, 12.6 } }, 2); fo:add(g:Ln({ { -22, 10 }, { -27, 7.5 }, { -31, 9.6 } }, 2)); fo:add(g:P({ { -26, 13.5 }, { -28.5, 10.8 }, { -26, 11.4 } }))
      solid(g, body, B, { frac = .3, offu = 2.5, pop = { { -4, 15.8 }, { -3, 16.2 } } })
      for a = -6, -19, -3.4 do g:mark({ { a, 16.2 }, { a - .8, 11 }, { a - .4, 6.8 } }, B.deep, B.base, B.shade) g:mark({ { a + 1, 15.8 }, { a + .4, 12 } }, B.hi, B.base) end
      local el = g:E(-1.2, 14, 5.4, 3.2); g:form(el, A, { frac = .35, off = 1, inner = true }); g:mark({ { -6, 12.4 }, { 3, 12.4 } }, A.deep, A.base, A.shade)   -- short wing cases
      g:mark({ { 1, 9 }, { 1.4, 16 } }, B.deep, B.base, B.shade)
      g:form(fo, Fk, { frac = .4, off = 1, inner = false }); g:over(fo:edge(), Fk.shade, Fk.base)                         -- the rear forceps: the earwig's tell
      g:dots({ { -27.5, 12.8 }, { -27.5, 9.2 } }, Fk.hi)
      if q.ring then   -- a gold ring on the upper forceps
        local x, y = g:x(-26), g:y(14.8)
        for _, p in ipairs({ { 0, 1 }, { 1, 0 }, { 2, 0 }, { 3, 1 }, { 3, 2 }, { 2, 3 }, { 1, 3 }, { 0, 2 } }) do c:put(x + p[1], y + p[2] - 2, P.gold.base) end
        c:put(x + 1, y - 2, P.gold.hi) c:put(x + 3, y, P.gold.shade)
      end
      hd = head(12.8, 11.6, 5.7, 4.9); ex, ey = 13.4, 12.6
      solid(g, hd, B, { frac = .3, offu = 2.5, pop = { { 9.5, 14.8 } } }); cheek(g, 15.8, 10); g:mark({ { 15.5, 9.8 }, { 17.5, 10.6 } }, B.deep, B.base, B.shade)
      ar = { { 11, 15.5 }, { 8.5, 21 }, { 11, 25.5 } }; br = { { 14.5, 15.5 }, { 18, 20.5 }, { 23, 22.5 } }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "ball"); feeler(g, "antR", br, D, "ball")
      return { { "body", false, -3, 11 }, { "leg1", "body", -8, 9, true }, { "leg2", "body", 0, 9, true }, { "leg3", "body", 7, 9, true }, { "head", "body", 8, 11.5 },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    elseif mole then
      g:shadow(-3, 25)
      leg(g, "leg1", { -8, 10 }, { -13, 7.5 }, -14.5, { w0 = 2.4, w1 = 1.6 }); leg(g, "leg2", { 0, 10 }, { 1.5, 6.5 }, 2.5, { w0 = 2.4, w1 = 1.6 })
      g:T("leg3")   -- the shovel forelegs: a broad paddle with digging claws
      for pass = 1, 2 do
        local dx, r = pass == 1 and 3 or 0, pass == 1 and L.darker(D) or D
        local m = g:Ln({ { 7 + dx, 11 }, { 11 + dx, 7 } }, 3.2); m:add(tilted(g, 13.5 + dx, 6.2, 5.4, 3.7, -32))
        for i = 0, 2 do m:add(g:P({ { 15 + dx + i * 1.6, 5.4 - i * 1.7 }, { 19.5 + dx + i * .5, 3 - i * .4 }, { 16.5 + dx + i * 1.6, 3.4 - i * 1.7 } })) end
        g:form(m, r, { frac = .4, off = 1 })
        if pass == 2 then g:over(m:edge(), A.shade, r.base); g:dots({ { 12, 8.5 }, { 14, 6.8 } }, A.base) end
      end
      g:T("body")
      body = g:E(-9, 13.8, 14.5, 7.8); body:add(g:E(3.5, 14.5, 7.3, 8.3))
      local cer = g:Ln({ { -22.5, 15 }, { -27, 17.5 }, { -31, 16 } }, 1.6); cer:add(g:Ln({ { -22.5, 12.5 }, { -27, 10.5 }, { -31, 12 } }, 1.6))
      solid(g, body, B, { frac = .3, offu = 3, pop = { { 0, 21 } } })
      g:fur(g:E(3.5, 14.5, 7.3, 8.3), B, 1.6)   -- velvet on the shield
      for a = -8, -20, -3.8 do g:mark({ { a, 20.5 }, { a - 1, 14 }, { a - .5, 7 } }, B.shade, B.base, B.hi) end
      g:mark({ { 9.8, 10 }, { 10.2, 19 } }, B.deep, B.base, B.shade)
      g:form(cer, A, { frac = .4, off = 1, inner = false })
      if q.dirt then   -- a clod of soil stuck to the shield
        local cl = g:E(5.5, 23.4, 3.3, 2.3); cl:add(g:E(8, 22.5, 2, 1.6)); g:form(cl, L.R.worm, { frac = .35, off = 1, inner = false }); g:dots({ { 4.5, 24.6 }, { 7, 23.6 } }, L.R.worm.deep)
      end
      hd = head(14.5, 12.8, 6.3, 5.6); ex, ey = 14.4, 13.8
      solid(g, hd, B, { frac = .3, offu = 3, pop = { { 11, 16.8 } } })
      local mj = g:Ln({ { 19.5, 11.6 }, { 22.5, 11 } }, 1.6); mj:add(g:Ln({ { 19.5, 9.8 }, { 22.5, 10.4 } }, 1.4)); g:form(mj, A, { frac = .4, off = 1, inner = false })
      cheek(g, 16.6, 10.6)
      ar = { { 12.5, 17.8 }, { 10.5, 21.5 }, { 12.5, 24 } }; br = { { 16, 17.8 }, { 19, 21.5 }, { 22.5, 22.5 } }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "ball"); feeler(g, "antR", br, D, "ball")
      return { { "body", false, -3, 14 }, { "leg1", "body", -8, 10, true }, { "leg2", "body", 0, 10, true }, { "leg3", "body", 7, 11, true }, { "head", "body", 9, 13 },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    elseif aph then
      g:shadow(-4, 21)
      local lo = { w0 = 1.7, w1 = 1.2, fo = 2.5 }
      leg(g, "leg1", { -9, 9 }, { -15.5, 10 }, -17, lo); leg(g, "leg2", { -3, 8.5 }, { -1, 6.5 }, 0, lo); leg(g, "leg3", { 3, 9 }, { 9, 10 }, 12, lo)
      g:T("body")
      body = g:E(-6, 13, 10.8, 8.6); body:add(g:E(1, 12.5, 6.5, 6.5))
      local cn = g:Ln({ { -12, 19 }, { -14, 24 } }, 2.4); cn:add(g:Ln({ { -8.5, 20 }, { -9.5, 24.5 } }, 2.2))
      solid(g, body, B, { frac = .3, offu = 3, pop = { { -9, 18.8 } } })
      for _, a in ipairs({ -11.5, -6.5, -1.5 }) do   -- dull dark stripes over the back, and wrinkles
        local m = g:Ln({ { a, 22 }, { a - 1, 6 } }, 1.7); m:clip(body); band(g, m, B, Ab) end
      for i = 1, 8 do local a, b = -14 + g:rnd(i, 2) * 17, 8 + g:rnd(i, 3) * 9; g:inside(a, b, B.shade, B.base) g:inside(a + 1, b, B.shade, B.base) end
      g:form(cn, A, { frac = .4, off = 1, inner = false }); g:dots({ { -13.8, 24.2 }, { -9.4, 24.6 } }, A.hi)
      if q.drop then local d = g:E(-14, 21.2, 1.7, 2); g:form(d, P.gold, { frac = .4, off = 1, inner = false }); g:put(-14.5, 22.4, P.cream) end   -- a drop of honeydew hangs there
      hd = head(8.5, 12.6, 5.4, 5); ex, ey = 9.3, 13.4
      solid(g, hd, B, { frac = .3, offu = 2.5, pop = { { 5.5, 16 } } }); cheek(g, 11.8, 10.6); g:mark({ { 12.2, 10.4 }, { 13.4, 11 } }, B.deep, B.base, B.shade)
      ar = { { 6.5, 17 }, { 3, 22 }, { 3.5, 27 } }; br = { { 10.5, 17 }, { 15, 22 }, { 20, 23 }, { 22.5, 20.5 } }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "ball"); feeler(g, "antR", br, D, "ball")
      return { { "body", false, -4, 13 }, { "leg1", "body", -9, 9, true }, { "leg2", "body", -3, 8.5, true }, { "leg3", "body", 3, 9, true }, { "head", "body", 4, 13 },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    elseif fish then
      g:shadow(-10, 28)
      leg(g, "leg1", { -12, 8 }, { -15, 6 }, -16, { w0 = 1.8, w1 = 1.3 }); leg(g, "leg2", { -2, 8 }, { 0, 6 }, 1, { w0 = 1.8, w1 = 1.3 }); leg(g, "leg3", { 6, 8 }, { 10, 6 }, 11, { w0 = 1.8, w1 = 1.3 })
      g:T("body")
      local ch = { { 2, 10.5, 8.5, 5.2 }, { -7, 10.1, 8, 4.8 }, { -15, 9.5, 7, 4.1 }, { -22, 8.5, 6, 3.3 }, { -27.5, 7.7, 4, 2.5 } }
      body = HP.mask(); for _, e in ipairs(ch) do body:add(g:E(e[1], e[2], e[3], e[4])) end
      for _, fp in ipairs({ { { -30, 8 }, { -36, 12 }, { -39, 11 } }, { { -30, 7.6 }, { -37, 7.6 }, { -40, 6.4 } }, { { -30, 7.2 }, { -36, 3.8 }, { -39, 4 } } }) do body:add(g:Ln1(fp, 1)) end
      solid(g, body, B, { frac = .3, offu = 2.5, pop = { { -2, 14.6 }, { -3, 14.8 } } })
      for a = 5, -27, -2.6 do for k = 0, 2 do local b = 8.2 + k * 2.4 + ((a // 2.6) % 2) * 1.2   -- fish scales: a dark notch with a lit rim
        g:inside(a, b, B.shade, B.base) g:inside(a + .9, b + .9, B.hi, B.base) end end
      for a = 4, -26, -4.4 do g:mark({ { a, 15.5 }, { a - .6, 6.2 } }, Ab.base, B.base, B.shade, B.hi) end    -- banded rings
      g:mark({ { 7, 14.6 }, { -4, 15.1 }, { -14, 13.4 } }, A.hi, B.base, B.hi)
      if q.scrap then   -- a scrap of page, with a few lines of print, stuck to its back
        local pg = g:P({ { -10.5, 13.5 }, { -3, 14.5 }, { -2.2, 20.6 }, { -9.6, 19.8 } })
        g:form(pg, L.R.cream, { frac = .3, off = 1, inner = false }); g:over(pg:edge(), L.R.cream.deep, L.R.cream.base, L.R.cream.shade, L.R.cream.hi)
        for i = 0, 2 do g:mark({ { -8.8, 18.4 - i * 1.7 }, { -4.2 + (i == 2 and 1.6 or 0), 18.8 - i * 1.7 } }, STR.base, L.R.cream.base, L.R.cream.shade) end
      end
      hd = head(10.8, 10, 5.5, 4.7); ex, ey = 11.4, 11
      solid(g, hd, B, { frac = .3, offu = 2.5, pop = { { 7.5, 13.2 } } }); cheek(g, 13.8, 8.6)
      ar = { { 12, 13.6 }, { 8, 20.5 }, { 2, 26 } }; br = { { 14.5, 13 }, { 20, 18.5 }, { 28, 21.5 } }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "none"); feeler(g, "antR", br, D, "none")
      return { { "body", false, -4, 10 }, { "leg1", "body", -12, 8, true }, { "leg2", "body", -2, 8, true }, { "leg3", "body", 6, 8, true }, { "head", "body", 6, 10.5 },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    else   -- drumming cricket
      g:shadow(-6, 26)
      local hl = { w0 = 6, w1 = 2.1, fo = 2.5, extra = function(m, near, dx, r, fb)
        if near then for i = 1, 4 do g:put(-18.5 + dx, 4 + i * 4, P.ink) end end end }   -- spines up the shin
      leg(g, "leg1", { -9, 12 }, { -20.5, 25.5 }, -19, hl)
      leg(g, "leg2", { -0.5, 10 }, { 2.5, 6.5 }, 4, { w0 = 2.2, w1 = 1.5 }); leg(g, "leg3", { 7, 10 }, { 12, 7 }, 13.5, { w0 = 2.2, w1 = 1.5 })
      local WR = L.lighter(A)
      for _, w in ipairs({ { "wingB", -11, 28.5, 11, 3.9, 168, L.darker(A) }, { "wingF", -8, 27, 11.5, 4.4, 160, A } }) do
        g:T(w[1])
        local m = tilted(g, w[2], w[3], w[4], w[5], w[6])
        solid(g, m, w[7], { frac = .3, off = 1, pop = { { w[2] + 3, w[3] + 2 } } })
        local r = w[7]
        for i = -1, 1 do g:mark({ { w[2] + 8, w[3] - 1 + i }, { w[2] - 9, w[3] + 2 + i * 2 } }, r.deep, r.base, r.shade, r.hi) end
        if w[1] == "wingF" then
          g:mark({ { -12, 24.4 }, { -12, 29 } }, r.deep, r.base, r.shade) g:mark({ { -8, 24.4 }, { -8.5, 29.6 } }, r.deep, r.base, r.shade) g:mark({ { -4, 25 }, { -4.5, 29.2 } }, r.deep, r.base, r.shade)
          if q.note then local x, y = g:x(-14), g:y(31.4)   -- a music note it has just drummed
            for _, p in ipairs({ { 0, 3 }, { 1, 3 }, { 0, 4 }, { 1, 4 }, { 2, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 }, { 3, 0 }, { 4, 1 } }) do c:put(x + p[1], y + p[2] - 5, P.cream) end
            c:put(x, y - 1, P.gold.base) end
        end
      end
      g:T("body")
      body = g:E(-7, 15.5, 13.8, 8.3); body:add(g:E(-18, 14, 5, 5.5))
      solid(g, body, B, { frac = .3, offu = 3, pop = { { -11, 21.5 }, { -12, 21.2 } } })
      for a = -3, -22, -3.2 do g:mark({ { a, 22 }, { a - 1, 15 }, { a - .6, 8.6 } }, B.shade, B.base, B.hi) end
      g:mark({ { -22, 11 }, { -28, 12.5 } }, B.deep, B.base) g:mark({ { -22, 14 }, { -27.5, 17 } }, B.shade, B.base)
      g:fill(g:Ln({ { -22.5, 13 }, { -29, 10.8 } }, 1.2), B.shade); g:fill(g:Ln({ { -22.5, 15 }, { -29.5, 17 } }, 1.2), B.shade)   -- two tail feelers (cerci)
      g:over(g:R(-3, 9, 5, 20), B.hi, B.shade)
      hd = head(9.5, 16, 7, 6.8); ex, ey = 10.6, 17.2
      solid(g, hd, B, { frac = .3, offu = 3, pop = { { 5.5, 20.5 } } }); cheek(g, 13.5, 13.2); g:mark({ { 12.5, 12.2 }, { 15.2, 12.6 } }, B.deep, B.base, B.shade)
      g:mark({ { 5, 14 }, { 8, 12.5 } }, B.shade, B.base)
      ar = { { 8, 22 }, { 3, 32 }, { -3, 40 } }; br = { { 12, 22 }, { 19, 31 }, { 27, 36 } }
      eyes(g, ex, ey); feeler(g, "antL", ar, L.darker(D), "none"); feeler(g, "antR", br, D, "none")
      return { { "body", false, -7, 15 }, { "leg1", "body", -9, 12, true }, { "leg2", "body", -0.5, 10, true }, { "leg3", "body", 7, 10, true },
        { "wingB", "body", -3, 22, true }, { "wingF", "body", -2, 22, true }, { "head", "body", 4, 16 },
        { "eyes", "head", ex, ey }, { "antL", "head", ar[1][1], ar[1][2] }, { "antR", "head", br[1][1], br[1][2] } }
    end
  end
  local function moth(g) error("todo") end
  local function wasp(g) error("todo") end

  return function(g)
    local f = g.f
    local kind = f.kind or ((f.shell and "beetle") or ((f.stripes and f.wings) and "wasp") or (f.wings and "moth") or "plain")
    return ({ ant = ant, beetle = beetle, plain = plain, moth = moth, wasp = wasp })[kind](g)
  end
end
