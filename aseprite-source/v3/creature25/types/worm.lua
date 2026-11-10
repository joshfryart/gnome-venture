-- worm: worms, slugs, leeches, grubs, centipedes (side view, faces RIGHT). Parts: l1..lN (a leg set under each segment, only when feat.legs), sN (tail) .. s1 (behind the head),
-- head, eyes, and the quirk bits drawn into existing parts. Every segment is its own whole overlapping oval/plate, so the chain stays closed when the springs swing it.
-- Spec features: segs (4..7), band, spots, legs, glow, horns.
-- Kinds (chosen from the slug, see KIND): slug (eye stalks, spotted, pale sole), glow (glowing tail), leech (flat, dorsal stripe, tail sucker), earth (rings + a pale saddle band),
--   clay (thumb dents, cracks, dabs of lighter clay), grub (fat, butter fold rings, spiracles, wax shine), olm (slim, tiny legs on l2 + l4, pink gills, tail fin),
--   centi (flat plates, feelers, fangs, two legs per plate, tail prongs), milli (domed rings, a dense fringe of legs, club feelers), borer (hard plates, crystal ridge, a drill of horns).
-- Quirks (quirks/worm.lua): crumb = a mushroom snack on its back; bow = a bow tie at the neck; sprig = a duckweed sprig stuck in its back; dewdrop = a drop hangs from its mouth;
--   bent = one feeler is kinked; scar = a stitched scar and a grumpy brow; pebble = a pebble stuck in its side; sock = one leg wears a striped sock; bubble = a bubble at its snout;
--   chip = a notch bitten out of a plate; wick = a lit wick on its back; crack = a glowing lava crack across its back.
-- Extra parts: none (all quirks live inside existing parts).
return function(L)
  local P = L.P
  local max, min, sin, pi = math.max, math.min, math.sin, math.pi
  local KIND = {
    ["leopard-slug"] = "slug", ["cave-glowworm"] = "glow", ["bog-leech"] = "leech", ["dew-leech"] = "leech", ["giant-centipede"] = "centi", ["gravel-centipede"] = "centi",
    ["claybound-millipede"] = "milli", ["earthworm-bully"] = "earth", ["clay-crawler"] = "clay", ["pale-olm"] = "olm", ["tallow-grub"] = "grub", ["basalt-borer"] = "borer",
  }
  -- layout per kind: ry = half height of a segment, rxmin = least half width, tail = size of the last segment, bulge = fatter middle, base/hump/rise = how far the belly is lifted,
  -- hrx/hry = head size, plate = flat plates, legh = lift for legs
  local LAY = {
    slug  = { ry = 5.6, rxmin = 7.8, tail = .5, bulge = .06, base = 0, hump = 2.2, rise = 1.5, hrx = 6.6, hry = 5.2 },
    glow  = { ry = 5.6, rxmin = 6.6, tail = .85, bulge = .08, base = 0, hump = 2.8, rise = 2.5, hrx = 6.8, hry = 6.2 },
    leech = { ry = 3.7, rxmin = 6.8, tail = .7,  bulge = 0,   base = 0, hump = 6, rise = 1.5, hrx = 5.4, hry = 4.2 },
    earth = { ry = 4.6, rxmin = 5.4, tail = .8,  bulge = .08, base = 0, hump = 3.2, rise = 2.5, hrx = 6.6, hry = 5.8 },
    clay  = { ry = 6.6, rxmin = 7.6, tail = .8,  bulge = .08, base = 0, hump = 2.2, rise = 2,   hrx = 7.2, hry = 6.4 },
    grub  = { ry = 6.6, rxmin = 7.8, tail = .62, bulge = .2,  base = 0, hump = 1.5, rise = 1.5, hrx = 5.6, hry = 5.2 },
    olm   = { ry = 4.0, rxmin = 5.2, tail = .6,  bulge = 0,   base = 2.4, hump = 1.2, rise = 2, hrx = 8.6, hry = 4.2 },
    centi = { ry = 4.4, rxmin = 5.2, tail = .75, bulge = 0,   base = 3.6, hump = 1,   rise = 2.4, hrx = 7.2, hry = 4.8, plate = true },
    milli = { ry = 5.2, rxmin = 5.4, tail = .8,  bulge = .05, base = 2.8, hump = 1,   rise = 2.4, hrx = 6.2, hry = 5.4 },
    borer = { ry = 6.4, rxmin = 6.4, tail = .6, bulge = .05, base = 0, hump = 2.6, rise = 2.4, hrx = 8.8, hry = 7.4, plate = true },
  }
  local function lerp(a, b, t) return a + (b - a) * t end
  return function(g)
    local c, f, q, B, A = g.c, g.f, g.q, g.B, g.A
    local kind = KIND[g.s.slug] or "earth"
    local Y = LAY[kind]
    local n = f.segs or 5
    local R = L.R
    local HI = L.lighter(B)
    local hornR = A
    if kind == "earth" then A = L.lighter(B) end                      -- the saddle is paler than the skin
    if kind == "centi" or kind == "milli" or kind == "grub" or kind == "borer" or kind == "leech" then if A.base == B.base then A = L.darker(B) end end

    ---------------------------------------------------------------- geometry: the chain of segments, s1 (head end) .. sN (tail)
    local SG = {}
    local sp = 29 / (n - 1)
    for k = 1, n do
      local t = (n - k) / (n - 1)
      local sm = min(1, t * 1.5 + 0.15)
      local ry = Y.ry * lerp(Y.tail, 1, sm) * (1 + Y.bulge * sin(t * pi) * 4)
      local rx = max(Y.rxmin, sp * 0.95) * lerp(Y.tail, 1, sm * 0.7 + 0.3)
      if kind == "earth" and (k == 2 or k == 3) then ry = ry + 0.8 end   -- the swollen saddle
      SG[k] = { a = -17 + t * 29, b = ry + Y.base + Y.hump * sin(t * pi) + Y.rise * t, rx = rx, ry = ry }
    end
    local s1 = SG[1]
    local hx, hb = s1.a + 3.6, s1.b + 1.2
    local hrx, hry = Y.hrx, Y.hry

    g:shadow(-2, 24)

    ---------------------------------------------------------------- legs (behind the body), one set per segment
    local function limb(pts, w, r)
      local m = g:Limb(pts, w, w * 0.85); g:form(m, r, { frac = 0.5, off = 1, inner = false }); return m
    end
    local legR = (kind == "centi" or kind == "milli") and A or B
    if kind == "centi" and A.base == B.base then legR = L.darker(B) end
    if f.legs then
      for k = 1, n do
        local s = SG[k]; local hip = max(2, s.b - s.ry * 0.6)
        g:T("l" .. k)
        if kind == "centi" then
          limb({ { s.a + 3, hip }, { s.a + 0.4, hip * .55 }, { s.a + 3.8, 0.9 } }, 1.3, L.darker(legR))   -- far leg
          limb({ { s.a + 0.5, hip }, { s.a - 2.4, hip * .55 }, { s.a + 1.2, 0.9 } }, 1.4, legR)
          g:put(s.a + 1.2, 0.9, legR.deep); g:put(s.a + 3.8, 0.9, L.darker(legR).deep)
        elseif kind == "milli" then
          for _, o in ipairs({ 3.6, 1.9, 0.2 }) do limb({ { s.a + o + 1.4, hip }, { s.a + o + 0.8, 0.9 } }, 1.1, L.darker(legR)) end
          for _, o in ipairs({ 2.4, 0.7, -1 }) do limb({ { s.a + o, hip }, { s.a + o - 1, 0.9 } }, 1.2, legR) end
          if q.sock and k == 3 then   -- one leg wears a striped sock
            for i, o in ipairs({ 2.4, 0.7, -1 }) do if i == 2 then
              for _, yy in ipairs({ 3.2, 2.2, 1.2 }) do local xx = g:x(s.a + o - (yy < 3 and .5 or 0)); local y = g:y(yy); c:fillMask(L.HP.rect(xx - 1, y, xx + 1, y), (yy == 2.2) and P.cream or P.petal.base) end
            end end
          end
        elseif kind == "olm" then
          if k == 2 or k == 4 then   -- a stubby front leg and hind leg with three toes
            local lg = g:Limb({ { s.a + 1, hip }, { s.a - 0.6, hip * .5 }, { s.a + 1.4, 1.2 } }, 3.0, 2.4)
            g:form(lg, B, { frac = 0.4, off = 1, inner = false }); g:under(lg, B.deep)
            for _, o in ipairs({ -0.4, 1.4, 3.2 }) do g:put(s.a + o, 0.8, B.shade) end
            g:put(s.a - 0.4, 0.4, B.base); g:put(s.a + 1.4, 0.4, B.base); g:put(s.a + 3.2, 0.4, B.base)
          end
        end
      end
    end

    ---------------------------------------------------------------- the segments, tail first so the front one overlaps the one behind it
    local function bandRamp(k)
      if not f.band then return B end
      if kind == "earth" then return (k == 2 or k == 3) and A or B end
      if kind == "leech" or kind == "grub" then return B end
      return (k % 2 == 0) and A or B
    end
    for k = n, 1, -1 do
      local s = SG[k]
      g:T("s" .. k)
      local r = bandRamp(k)
      if kind == "glow" and k == n then r = R.butter end
      local m
      if Y.plate then m = g:RR(s.a - s.rx, s.b - s.ry, s.a + s.rx, s.b + s.ry, kind == "borer" and 2.6 or 3.4) else m = g:E(s.a, s.b, s.rx, s.ry) end
      if q.chip and k == 4 then   -- a notch bitten out of the plate
        local cx, cy = g:x(s.a - 2), g:y(s.b + s.ry); m:cut(L.HP.poly({ { cx - 3, cy - 1 }, { cx + 2, cy - 1 }, { cx - 1, cy + 3 } }))
      end
      g:form(m, r, { frac = kind == "leech" and 0.25 or 0.3, offu = 2.4 })
      g:under(m, r.deep)
      g:toplight(m, r)
      local x0, y0, x1, y1 = m:bbox(); local cx = (x0 + x1) / 2
      local seam = (Y.plate or kind == "glow" or kind == "grub" or kind == "milli") and r.deep or r.shade
      m:edge():each(function(x, y) if x < cx - 1 and y > y0 and y < y1 then c:put(x, y, seam) end end)   -- the seam where the next segment overlaps this one
      local top = function(x) for y = y0, y1 do if m:has(x, y) then return y end end end

      if kind == "slug" then
        local ramp = r
        m:each(function(x, y) if not m:has(x, y + 3) and y < y1 then L.inside(c, x, y, B.hi, B.base, B.shade) end end)    -- the pale sole
        g:under(m, B.deep)
        if f.spots then g:spots(m, { hex = A.deep, r = 1.5, step = 5, inset = 2 }) end
        for i = 1, 3 do local a, b = s.a + (g:rnd(k, i) - .5) * s.rx * 1.2, s.b + (g:rnd(i, k) - .2) * s.ry * 0.8; g:inside(a, b, B.shade, B.base, B.hi) end
        if k == 2 then   -- the mantle: a darker saddle behind the head
          local mt = g:E(s.a + 1, s.b + s.ry * 0.5, s.rx * 0.6, s.ry * 0.45); mt:clip(m)
          g:over(mt, ramp.shade, ramp.base, ramp.hi)
          mt:each(function(x, y) if not mt:has(x, y + 1) then L.inside(c, x, y, ramp.deep, ramp.shade) end end)
        end
      elseif kind == "glow" then
        if k == n then
          local core = g:E(s.a - 0.5, s.b, s.rx * 0.62, s.ry * 0.62); core:clip(m)
          local ring = g:E(s.a - 0.5, s.b, s.rx * 0.8, s.ry * 0.8); ring:clip(m)
          ring:each(function(x, y) if (x + y) % 2 == 0 then L.inside(c, x, y, P.cream, r.base) end end)
          g:fill(core, P.cream)
          g:put(s.a - s.rx * 0.5, s.b + s.ry * 0.4, P.cream); g:put(s.a + s.rx * 0.2, s.b - s.ry * 0.5, r.hi)
        else
          if k == n - 1 then m:each(function(x, y) if x < cx - 2 and (x + y) % 2 == 0 then L.inside(c, x, y, P.gold.hi, r.base, r.hi, r.shade) end end) end   -- the glow bleeds forward
          for i = -1, 1 do g:inside(s.a + i * s.rx * 0.45, s.b - s.ry * 0.55, P.gold.hi, r.base, r.shade, r.deep) end                                          -- a row of light spots on the belly
          g:inside(s.a - s.rx * 0.2, s.b + s.ry * 0.35, r.shade, r.base)
        end
      elseif kind == "leech" then
        local dark = A
        if f.band then   -- a dorsal stripe with a dotted line below it
          for x = x0 + 2, x1 - 2 do local y = top(x); if y then
            L.inside(c, x, y + 1, dark.base, r.base, r.hi); L.inside(c, x, y + 2, dark.base, r.base, r.hi)
            if (x + k) % 3 == 0 then L.inside(c, x, y + 4, dark.shade, r.base, r.shade) end
          end end
        end
        for i = 1, 2 do g:inside(s.a - s.rx * 0.2 + (i - 1) * 2.5, s.b + s.ry * 0.2, r.hi, r.base) end   -- wet shine
        if k == n then   -- the tail sucker: a disc on the end
          local d = g:E(s.a - s.rx * 0.78, s.b - s.ry * 0.1, 2.3, s.ry * 0.95)
          g:form(d, HI, { frac = 0.3, off = 1 }); g:under(d, HI.deep)
          d:each(function(x, y) if (x + y) % 2 == 0 and d:shrink(1):has(x, y) then c:put(x, y, HI.shade) end end)
        end
      elseif kind == "earth" then
        for xx = x0 + 3, x1 - 3, 3 do local y = top(xx); if y then   -- fine ring lines down the back
          for j = 2, 4 do L.inside(c, xx, y + j, r.shade, r.base, r.hi) end
        end end
        if k == 2 or k == 3 then m:each(function(x, y) if not m:has(x, y - 1) then L.inside(c, x, y + 1, P.cream, r.base, r.hi) end end) end
        if q.scar and k == 3 then
          local px, py = g:x(s.a), g:y(s.b + 1)
          for i = -3, 3 do c:put(px + i, py + i // 2, P.petal.deep) end
          for i = -2, 2, 2 do c:put(px + i, py - 1 + i // 2, P.cream); c:put(px + i, py + 2 + i // 2, P.cream) end
        end
      elseif kind == "clay" then
        local dab = A
        for i = 1, 2 do   -- dabs of lighter clay
          local a, b = s.a + (g:rnd(k, i + 3) - .5) * s.rx * 1.1, s.b + (g:rnd(i, k + 9) - .5) * s.ry * 1.0
          local dm = g:E(a, b, 1.7, 1.2); dm:clip(m); g:over(dm, dab.base, r.base, r.shade, r.hi)
          dm:each(function(x, y) if not dm:has(x, y + 1) then L.inside(c, x, y, dab.shade, dab.base) end end)
        end
        do   -- a thumb dent: shade top-left, lit lower-right
          local a, b = s.a + s.rx * 0.15, s.b + s.ry * 0.05
          local dm = g:E(a, b, 1.6, 1.4); dm:clip(m); g:over(dm, r.shade, r.base, r.hi)
          dm:each(function(x, y) if not dm:has(x - 1, y - 1) then L.inside(c, x, y, r.hi, r.shade, r.base) end end)
        end
        local px, py = g:x(s.a - s.rx * 0.45), g:y(s.b + s.ry * 0.6)   -- a drying crack
        for i = 0, 4 do L.inside(c, px + i // 2 * (i % 2 == 0 and 1 or -1) + i, py + i, r.deep, r.base, r.shade, r.hi) end
      elseif kind == "grub" then
        local fold = A                                                    -- a butter fold ring around the front of each segment
        m:each(function(x, y) if x >= cx - 1 and x <= cx + 1 and y > y0 + 1 and y < y1 - 1 then L.inside(c, x, y, fold.base, r.base, r.hi, r.shade) end end)
        for _, y in ipairs({ y0 + 1, y0 + 2 }) do for x = x0 + 4, x1 - 4 do if x % 3 == 0 then L.inside(c, x, y + 1, fold.hi, r.base, r.hi) end end end
        g:inside(s.a + s.rx * 0.35, s.b + s.ry * 0.1, r.deep, r.base, r.shade); g:inside(s.a + s.rx * 0.35, s.b - s.ry * 0.15, r.deep, r.base, r.shade)   -- spiracles
        g:inside(s.a - s.rx * 0.35, s.b + s.ry * 0.5, P.cream, r.base, r.hi); g:inside(s.a - s.rx * 0.3, s.b + s.ry * 0.4, P.cream, r.base, r.hi)               -- waxy shine
        if k == 2 and q.wick then
          local px, py = g:x(s.a - 1), g:y(s.b + s.ry)
          for i = 1, 3 do c:put(px, py - i, P.wood.deep) end
          c:put(px, py - 4, P.ember.base); c:put(px, py - 5, P.gold.base); c:put(px - 1, py - 5, P.ember.base); c:put(px + 1, py - 5, P.ember.base); c:put(px, py - 6, P.gold.hi)
          c:put(px, py - 7, P.cream)
        end
      elseif kind == "centi" then
        local mid = g:R(s.a - s.rx * 0.55, s.b + s.ry * 0.2, s.a + s.rx * 0.55, s.b + s.ry * 0.2)   -- a ridge line down the plate
        for x = x0 + 3, x1 - 3 do local y = top(x); if y then L.inside(c, x, y + 1, r.hi, r.base) end end
        for i = -1, 1, 2 do g:inside(s.a + i * s.rx * 0.4, s.b - s.ry * 0.1, r.deep, r.base, r.shade) end   -- spiracles
        m:each(function(x, y) if x > cx + s.rx * 0.5 * g.u and not m:has(x, y - 1) then L.inside(c, x, y, r.hi, r.base) end end)
        if k == n then   -- two long prongs at the tail
          local p1 = g:Limb({ { s.a - s.rx * 0.8, s.b + 0.5 }, { s.a - s.rx - 5, s.b + 3 }, { s.a - s.rx - 9, s.b + 1.5 } }, 1.8, 0.8)
          local p2 = g:Limb({ { s.a - s.rx * 0.8, s.b - 1.5 }, { s.a - s.rx - 5, s.b - 1.5 }, { s.a - s.rx - 9, s.b - 4 } }, 1.8, 0.8)
          g:form(p2, L.darker(legR), { frac = 0.5, off = 1, inner = false }); g:form(p1, legR, { frac = 0.5, off = 1, inner = false })
        end
      elseif kind == "milli" then
        local ring = A
        m:each(function(x, y) if x >= x0 + 2 and x <= x0 + 4 and y > y0 + 1 and y < y1 - 1 then L.inside(c, x, y, ring.base, r.base, r.hi, r.shade) end end)   -- a band round the rear of every ring
        for x = x0 + 5, x1 - 3 do local y = top(x); if y and x % 3 ~= 0 then L.inside(c, x, y + 1, r.hi, r.base) end end
        if g.s.slug:find("clay") then
          local px, py = g:x(s.a + s.rx * 0.2), g:y(s.b + s.ry * 0.5)
          for i = 0, 3 do L.inside(c, px + i % 2, py + i, r.deep, r.base, r.shade, r.hi) end   -- clay cracks
        end
        g:inside(s.a + s.rx * 0.2, s.b - s.ry * 0.2, r.deep, r.base, r.shade)
      elseif kind == "olm" then
        if k >= n - 1 then   -- the tail flattens into a fin, top and bottom
          local fin = g:P({ { s.a + s.rx * 0.6, s.b + s.ry * 0.6 }, { s.a - s.rx * 0.4, s.b + s.ry * (k == n and 1.7 or 1.35) }, { s.a - s.rx * 1.5, s.b + s.ry * 0.6 } })
          if k == n then fin:add(g:P({ { s.a + s.rx * 0.4, s.b - s.ry * 0.6 }, { s.a - s.rx * 0.5, s.b - s.ry * 1.3 }, { s.a - s.rx * 1.5, s.b - s.ry * 0.2 } })) end
          fin:cut(m); g:form(fin, B, { frac = 0.3, off = 1, inner = false })
          fin:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, A.base) end end)   -- pink fin rays
        end
        for i = 0, 3 do g:inside(s.a + 2 - i * 1.3, s.b - s.ry * 0.1, A.shade, B.base, B.shade) end   -- a faint pink flush along the flank
        for i = -1, 1 do g:inside(s.a + i * s.rx * 0.5, s.b + s.ry * 0.5, A.base, B.base, B.hi) end
      elseif kind == "borer" then
        local pl = A
        if f.band and k % 2 == 0 then
          for x = x0 + 2, x1 - 2 do local y = top(x); if y then L.inside(c, x, y + 1, pl.hi, r.base, r.hi) end end
        end
        -- hex-column facets: two vertical creases and a crystal ridge on the back
        for _, xx in ipairs({ cx - s.rx * 0.5 * g.u, cx + s.rx * 0.3 * g.u }) do
          for y = y0 + 3, y1 - 3 do L.inside(c, math.floor(xx), y, r.shade, r.base, r.hi) end
        end
        local tx, ty = g:x(s.a - 1), g:y(s.b + s.ry)
        local sp = L.HP.poly({ { tx - 2, ty + 1 }, { tx + 3, ty + 1 }, { tx + 0.5, ty - 3 } }); g:form(sp, A, { frac = 0.4, off = 1, inner = false, noshade = false })
        if q.crack and k == 3 then
          local pts = { { s.a - s.rx * 0.5, s.b + s.ry * 0.9 }, { s.a - 0.5, s.b + s.ry * 0.2 }, { s.a - s.rx * 0.2, s.b - s.ry * 0.2 }, { s.a + s.rx * 0.5, s.b - s.ry * 0.8 } }
          g:mark(pts, P.ember.base, r.base, r.shade, r.hi, r.deep); g:mark({ { s.a - 0.5, s.b + s.ry * 0.2 }, { s.a - s.rx * 0.2, s.b - s.ry * 0.2 } }, P.gold.hi, P.ember.base)
        end
      end
      if q.pebble and k == 2 and kind == "clay" then
        local pb = g:E(s.a + s.rx * 0.35, s.b - s.ry * 0.3, 2.4, 1.9); g:form(pb, R.stone, { frac = 0.35, off = 1 }); g:under(pb, R.stone.deep); g:put(s.a + s.rx * 0.35 - 1, s.b - s.ry * 0.3 + 0.8, R.stone.hi)
      end
      if q.crumb and k == 3 then   -- a mushroom snack riding on its back
        local px, py = g:x(s.a), g:y(s.b + s.ry)
        c:fillMask(L.HP.rect(px - 1, py - 3, px, py), P.cream); c:put(px, py - 2, P.stone.hi); c:put(px, py - 1, P.stone.hi)
        local cap = L.HP.ellipse(px - 0.5, py - 4, 3.5, 2.2); g:form(cap, R.ember, { frac = 0.3, off = 1, inner = false })
        c:put(px - 2, py - 5, P.cream); c:put(px, py - 6, P.cream); c:put(px + 2, py - 4, P.cream)
      end
      if q.sprig and k == 3 then   -- a duckweed sprig: stalk and two leaves
        local px, py = g:x(s.a + 1), g:y(s.b + s.ry)
        for i = 1, 3 do c:put(px, py - i, R.lime.shade) end
        local l1 = L.HP.ellipse(px - 3, py - 5, 2.4, 1.4); local l2 = L.HP.ellipse(px + 3, py - 6, 2.4, 1.4)
        g:form(l1, R.lime, { frac = 0.3, off = 1, inner = false }); g:form(l2, R.lime, { frac = 0.3, off = 1, inner = false })
      end
    end

    ---------------------------------------------------------------- the head
    g:T("head")
    local hm = g:E(hx, hb, hrx, hry)
    if kind == "slug" then   -- eye stalks first (the head covers their roots), the lower feelers
      local function stalk(tx, tb, r)
        local sm = g:Limb({ { tx - 2.6, hb + hry * 0.5 }, { tx - 1.2, (hb + tb) / 2 }, { tx, tb } }, 2.4, 2.0)
        g:form(sm, r, { frac = 0.4, off = 1, inner = false }); g:under(sm, r.deep)
        return sm
      end
      stalk(hx - 2.4, hb + hry + 6.6, L.darker(B))
      stalk(hx + 3.2, hb + hry + 7.4, B)
      for _, tb in ipairs({ { hx + hrx - 1, hb - 1 } }) do local fm = g:Limb({ { hx + hrx - 2, hb - 0.8 }, { tb[1] + 3, tb[2] - 1.4 } }, 1.8, 1.2); g:form(fm, B, { frac = 0.4, off = 1, inner = false }) end
    elseif kind == "olm" then   -- the far set of gills first
      for j = 0, 2 do local d = ({ { -5, 2.4 }, { -4.6, 4.8 }, { -2.6, 6.4 } })[j + 1]; local gm = g:Limb({ { hx - hrx * 0.5 + 1.5, hb + 2 }, { hx - hrx * 0.5 + 1.5 + d[1] * .5 - 0.5, hb + 2.4 + d[2] * .5 }, { hx - hrx * 0.5 + 1.5 + d[1] + 1, hb + 2 + d[2] } }, 1.5, 0.9); g:form(gm, L.darker(A), { frac = 0.5, off = 1, inner = false }) end
    elseif kind == "centi" then   -- the far feeler behind the head
      local fm = g:Limb({ { hx + 3.5, hb + hry * 0.6 }, { hx + 7, hb + hry + 3 }, { hx + 12, hb + hry + 3.8 }, { hx + 15, hb + hry + 1.8 } }, 1.1, 0.7)
      g:form(fm, L.darker(A), { frac = 0.5, off = 1, inner = false })
    end
    if kind == "centi" then hm = g:RR(hx - hrx, hb - hry, hx + hrx, hb + hry, 3.4) end
    if kind == "borer" then hm = g:RR(hx - hrx, hb - hry, hx + hrx, hb + hry, 3.4) end
    local hr = (kind == "centi") and A or (kind == "grub" and R.tan or B)
    if kind == "centi" and A.base == B.base then hr = L.darker(B) end
    g:form(hm, hr, { frac = 0.3, offu = 3 })
    g:under(hm, hr.deep); g:toplight(hm, hr)
    local hx0, hy0 = hm:bbox()
    if kind == "slug" then
      for i = 1, 3 do g:inside(hx + (g:rnd(i, 4) - .3) * hrx, hb - hry * 0.2 + (g:rnd(4, i) - .5) * hry, B.shade, B.base) end
    elseif kind == "grub" then   -- a tough little capsule head with two jaws
      for i = 1, 2 do local jm = g:P({ { hx + hrx - 1, hb - hry * 0.2 - i * 1.2 }, { hx + hrx + 2.4, hb - hry * 0.9 - i * 0.5 }, { hx + hrx - 1, hb - hry * 0.9 - i * 1.4 } }); g:form(jm, R.wood, { frac = 0.4, off = 1, inner = false }) end
    elseif kind == "leech" then   -- the oral sucker at the front
      local d = g:E(hx + hrx - 0.8, hb, 1.7, hry * 0.8); g:form(d, A, { frac = 0.3, off = 1 }); g:under(d, A.deep); g:put(hx + hrx - 0.4, hb, P.ink)
    elseif kind == "centi" then
      for _, o in ipairs({ 0, -2.6 }) do   -- curved fangs under the chin
        local fm = g:Limb({ { hx + hrx - 2.5 - o, hb - hry + 1 }, { hx + hrx - 1.2 - o, hb - hry - 1 }, { hx + hrx - 2.6 - o, hb - hry - 2.4 } }, 1.2, 0.6)
        g:form(fm, o == 0 and R.ember or L.darker(R.ember), { frac = 0.5, off = 1, inner = false })
      end
      local nm = g:Limb({ { hx + 3.8, hb + hry * 0.6 }, { hx + 8, hb + hry + 3.2 }, q.bent and { hx + 13, hb + hry + 4 } or { hx + 13, hb + hry + 4.6 }, q.bent and { hx + 13, hb + hry - 2 } or { hx + 17, hb + hry + 3.4 } }, 1.2, 0.8)
      g:form(nm, A, { frac = 0.5, off = 1, inner = false })
      if q.bent then g:put(hx + 13, hb + hry + 4, A.deep) end
    elseif kind == "milli" then   -- club feelers
      for i = 0, 1 do
        local x0f = hx + 2 + i * 3
        local sm = g:Limb({ { x0f, hb + hry * 0.7 }, { x0f + 2.4 + i, hb + hry + 4.2 } }, 1.2, 1.0); g:form(sm, i == 0 and A or L.darker(A), { frac = 0.5, off = 1, inner = false })
        local cb = g:E(x0f + 2.6 + i, hb + hry + 5, 1.6, 1.6); g:form(cb, i == 0 and A or L.darker(A), { frac = 0.4, off = 1, inner = false })
      end
    elseif kind == "olm" then   -- the near gills, three feathery stalks with pink tips
      for j = 0, 2 do
        local d = ({ { -5.4, 2.0 }, { -5, 4.6 }, { -3, 6.4 } })[j + 1]
        local bx, by = hx - hrx * 0.5 + 0.5, hb + 0.8
        local gm = g:Limb({ { bx, by }, { bx + d[1] * .5, by + d[2] * .5 + 0.4 }, { bx + d[1], by + d[2] } }, 1.9, 1.1)
        g:form(gm, A, { frac = 0.45, off = 1, inner = false }); g:put(bx + d[1], by + d[2] + 0.5, A.hi)
      end
      for i = 0, 2 do g:inside(hx + 2 + i * 1.4, hb - hry * 0.45, A.base, B.base, B.hi) end
    elseif kind == "borer" then   -- a drill of horns: a big curved one and a small far one, a jaw plate
      local function horn(a0, b0, tipa, tipb, w, r)
        local hm2 = g:Limb({ { a0, b0 }, { (a0 + tipa) / 2 - 1.5, (b0 + tipb) / 2 + 1 }, { tipa, tipb } }, w, 1.0)
        g:form(hm2, r, { frac = 0.4, off = 1, inner = false }); g:under(hm2, r.deep)
        hm2:each(function(x, y) if (x + y) % 5 == 0 and hm2:shrink(1):has(x, y) then c:put(x, y, r.shade) end end)
      end
      if f.horns then
        horn(hx - 3.5, hb + hry - 1, hx - 1.5, hb + hry + 10, 3.6, L.darker(A))
        horn(hx + 2, hb + hry - 1, hx + 9.5, hb + hry + 9, 4.6, A)
      end
      local jw = g:RR(hx + hrx - 5, hb - hry - 0.5, hx + hrx + 1, hb - hry + 3.5, 1.6); g:form(jw, A, { frac = 0.35, off = 1, inner = false })
      for x = g:x(hx - hrx + 1), g:x(hx + hrx - 3), 4 do local y = g:y(hb + hry); for yy = y + 2, y + 6 do L.inside(c, x, yy, hr.shade, hr.base, hr.hi) end end
    end
    if q.bow then   -- a bow tie where the neck meets the first segment
      local bx, by = g:x(hx - hrx * 0.62), g:y(hb - hry + 0.2)
      c:fillMask(L.HP.poly({ { bx - 5, by - 3 }, { bx, by }, { bx - 5, by + 3 } }), P.petal.base); c:fillMask(L.HP.poly({ { bx + 5, by - 3 }, { bx, by }, { bx + 5, by + 3 } }), P.petal.base)
      c:fillMask(L.HP.rect(bx - 1, by - 1, bx, by + 1), P.petal.shade); c:put(bx - 3, by - 1, P.petal.hi); c:put(bx + 3, by - 1, P.petal.hi)
    end
    if q.dewdrop then   -- a drop hangs from the mouth
      local px, py = g:x(hx + hrx - 1), g:y(hb - hry * 0.5)
      c:fillMask(L.HP.ellipse(px, py + 3, 1.5, 1.8), P.sky.base); c:put(px, py + 1, P.sky.shade); c:put(px - 1, py + 3, P.cream); c:put(px, py + 5, P.sky.shade)
    end
    if q.bubble then   -- an air bubble at the snout
      local px, py = g:x(hx + hrx + 2), g:y(hb + 0.5)
      for _, d in ipairs({ { 0, -2 }, { 1, -2 }, { -1, -1 }, { 2, -1 }, { -1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 } }) do c:put(px + d[1], py + d[2], P.sky.hi) end
      c:put(px, py - 1, P.cream)
    end
    if q.scar then   -- grumpy brow
      local bx, by = g:x(hx), g:y(hb + hry * 0.55)
      for i = 0, 8 do c:put(bx - 3 + i, by - 1 - (i < 4 and i // 2 or (8 - i) // 2) * -1 + 1, hr.deep) end
    end

    ---------------------------------------------------------------- the face
    g:T("eyes")
    local ex, ey = hx + 0.8, hb + hry * 0.3
    if kind == "slug" then
      g:eye(hx - 2.4, hb + hry + 6.6); g:eye(hx + 3.2, hb + hry + 7.4)
      ex, ey = hx + 0.4, hb + hry + 7
    elseif hrx >= 6.4 and kind ~= "olm" then
      g:eye(hx - 0.9, ey); g:eye(hx + 4.3, ey)
    elseif kind == "olm" then
      g:eye(hx + 3.2, ey + 0.3)
    else
      g:eye(hx + 1.6, ey)
    end
    g:T("head")
    if kind ~= "leech" then
      local mx, my = hx + 1, hb - hry * 0.5
      if kind == "olm" then mx = hx + 2.4; my = hb - hry * 0.4 end
      g:stroke({ { mx, my }, { mx + 1.6, my - 0.7 }, { mx + 3.4, my - 0.7 }, { mx + 5, my + 0.2 } }, hr.deep)
    end
    if kind ~= "leech" and kind ~= "centi" and kind ~= "borer" and kind ~= "slug" then g:dots({ { hx + 5.6, hb - 0.2 } }, P.petal.base) end   -- cheek

    ---------------------------------------------------------------- bones
    local bones = {}
    for k = 1, n do
      local s = SG[k]
      if k == 1 then bones[#bones + 1] = { "s1", false, s.a, s.b }
      else local p = SG[k - 1]; bones[#bones + 1] = { "s" .. k, "s" .. (k - 1), (s.a + p.a) / 2, (s.b + p.b) / 2 } end
      if f.legs then bones[#bones + 1] = { "l" .. k, "s" .. k, s.a, max(2, s.b - s.ry * 0.6), true } end
    end
    bones[#bones + 1] = { "head", "s1", hx - 3, hb - 1.5 }
    bones[#bones + 1] = { "eyes", "head", ex + 2.2, ey }
    return bones
  end
end
