-- folk: the little folk of the Trek crew (and, later, every villager mini), FRONT view, chibi: a big head, a small tunic body, real hands and boots.
-- Parts (back to front): [back, wingL, wingR], footL, footR, body, armL, armR, head, eyes, hat. About 36 units tall (43 px at party size u = 1.2): the gnome's height, a bit more with a hat or ears.
-- Spec feat (opus-test-run/scripts/minis/villagers.lua): species, face (skin / fur colour, = spec col), hat ("none" | cap | point | straw | hood), hatc, cloth, plus shell (snail, tortoise),
--   spike (hedgehog), wing (butterfly, dragonfly), apron.
-- Species drawn and checked (the crew): mole, bee, beetle, snail (shell = `back`), hare, hedgehog, wren (beak, tail = `back`, tucked wings).
-- Species drawn but not tested (the other villagers): mouse, bat, ladybird, butterfly, frog, grasshopper, tortoise, dragonfly, moth.
-- Quirks (quirks/folk.lua), one per crew member:
--   trowel  = a garden trowel in the right hand (burdock)    flower  = a red flower held in the left hand (zinnia)
--   patch   = a stitched patch on the tunic (bracken)        feather = a headband with a feather (sorrel)
--   scarf   = a green scarf, one end hanging (tumble)        teapot  = a little teapot in the left hand (juniper)
--   needle  = a needle with a loop of thread stuck in the cap (wren)
return function(L)
  local P = L.P
  local HP = L.HP
  local rect = HP.rect
  local function rp(h, fb) local ok, r = pcall(L.ramp, h or fb); if ok then return r end return L.ramp(fb) end
  return function(g)
    local c, f, q, B = g.c, g.f, g.q, g.B
    local sp, hat = f.species or "mouse", f.hat or "none"
    local C = rp(f.cloth, "#e8a317")                 -- the tunic
    local H = rp(f.hatc, "#dd3a2a")                  -- the hat
    local BK = L.R.bark                              -- boots and belts
    local GOLD = P.gold
    local insect = ({ bee = 1, beetle = 1, ladybird = 1, butterfly = 1, grasshopper = 1, dragonfly = 1, moth = 1 })[sp]
    g:shadow(0, 11)
    local v = math.floor(g:rnd(5, 5) * 3)            -- a per-villager variant 0..2 (face markings, ears, wing pattern), so villagers of one species differ
    local WGC = rp(f.wing or "#a9d6ea", "#a9d6ea")
    local function lum(r) local h = r.base; return tonumber(h:sub(2, 3), 16) * 0.3 + tonumber(h:sub(4, 5), 16) * 0.59 + tonumber(h:sub(6, 7), 16) * 0.11 end
    local crew = g.s.slug:find("^crew%-") ~= nil                  -- the crew keep their approved look exactly
    local LINE = (not crew and lum(B) > 190) and L.R.ink.shade or B.deep          -- the colour of mouths and creases (dark enough on pale faces)

    ---------------------------------------------------------------- behind the body: wings, shell, tail
    local hasBack, hasWings = false, false
    local function wingPair(mk)
      hasWings = true
      for _, s in ipairs({ -1, 1 }) do g:T(s < 0 and "wingL" or "wingR") mk(s) end
    end
    if sp == "snail" or sp == "tortoise" then   -- the shell on its back, sticking out at the left and over the shoulder
      hasBack = true; g:T("back")
      local S = rp(f.shell, "#9a6b3f")
      local sh = (sp == "snail") and g:E(-7.5, 20, 9, 9) or g:E(-1.2, 20.5, 12.4, 10)
      g:form(sh, S, { frac = 0.3, offu = 2.5, pop = { { -10, 25 } } }) g:under(sh, S.deep) g:toplight(sh, S, 1)
      if sp == "snail" then   -- the spiral: two rings and a curl in the middle
        local cx, cy = -7.5, 20
        for _, r in ipairs({ 6.2, 3.4 }) do
          local ring = g:E(cx + 0.4, cy - 0.3, r, r); ring:cut(g:E(cx + 0.4, cy - 0.3, r - 0.9, r - 0.9)); ring:clip(sh)
          g:over(ring, S.deep, S.base, S.shade, S.hi)
        end
        g:dots({ { cx + 0.4, cy - 0.3 }, { cx + 1.4, cy - 0.3 }, { cx + 1.4, cy + 0.7 } }, S.deep)
        g:dots({ { cx - 5, cy + 3 }, { cx - 3.5, cy + 5.4 } }, S.hi)
      else                    -- tortoise: a dome of hexagonal scutes and a darker rim
        for _, a in ipairs({ -8, -4.4, -1.2, 2, 5.6 }) do g:mark({ { a, 12 }, { a + 0.4, 29 } }, S.deep, S.base, S.shade, S.hi) end
        g:mark({ { -12, 18 }, { -6, 20 }, { 0, 19 }, { 6, 20.4 }, { 11, 18.4 } }, S.deep, S.base, S.shade, S.hi)
        g:mark({ { -11, 24.4 }, { -5, 25.6 }, { 1, 25 }, { 7, 25.8 } }, S.deep, S.base, S.shade, S.hi)
        g:fill(g:R(-12.2, 11.2, 10.2, 12.4), S.deep) g:dots({ { -9, 21.5 }, { 2.5, 27 }, { 8.2, 22 } }, S.hi)
      end
    elseif sp == "wren" then   -- a small cocked tail behind the back
      hasBack = true; g:T("back")
      for i, t in ipairs({ { -12, 20 }, { -9.5, 24 }, { -13.5, 15.5 } }) do
        local m = g:Limb({ { -4, 9 }, { t[1] * 0.6 - 1, t[2] * 0.6 }, t }, 3.8, 2)
        g:form(m, B, { frac = 0.35, off = 1 }) g:under(m, B.deep) g:mark({ { -4.5, 10 }, { t[1] * 0.8, t[2] * 0.8 } }, B.shade, B.base)
      end
    end
    if sp == "bee" or sp == "dragonfly" or sp == "butterfly" or sp == "moth" then
      local WG = rp(f.wing or "#a9d6ea", "#a9d6ea")
      wingPair(function(s)
        local big = (sp == "butterfly" or sp == "moth")
        local m = big and g:E(s * 11, 22.5, 7.2, 9.2) or g:Limb({ { s * 6, 14 }, { s * 11.5, 21 }, { s * 13, 27 } }, 5.8, 4.6)
        g:form(m, WG, { frac = 0.25, off = 1 }) g:toplight(m, WG, 1)
        local x0, y0, x1, y1 = m:bbox()
        if v == 2 then g:mark({ { s * 7, 15 }, { s * 13.4, 20 }, { s * 14, 27 } }, WG.deep, WG.base, WG.shade, WG.hi) end
        g:mark(big and { { s * 6, 20 }, { s * 13, 26 } } or { { s * 7, 15.5 }, { s * 12.4, 24 } }, WG.shade, WG.base, WG.hi)
        if big then g:mark({ { s * 6.5, 26 }, { s * 11.5, 29 } }, WG.shade, WG.base, WG.hi) g:dots({ { s * 11, 20 }, { s * 12, 24 } }, P.cream) end
      end)
    elseif sp == "beetle" or sp == "ladybird" then   -- wing cases peeking out at the sides
      wingPair(function(s)
        local R = (sp == "ladybird") and L.R.ember or B
        local m = g:E(s * 8.2, 12.2, 4.6, 8.4)
        g:form(m, R, { frac = s > 0 and 0.4 or 0.22, off = 1 }) g:under(m, R.deep) g:toplight(m, R, 1)
        g:mark({ { s * 8, 19.5 }, { s * 7.6, 5 } }, R.deep, R.base, R.shade, R.hi)
        if sp == "ladybird" then g:dots({ { s * 9, 14 }, { s * 8.4, 9 } }, P.ink) end
      end)
    elseif sp == "bat" then
      wingPair(function(s)
        local m = g:P({ { s * 6, 15 }, { s * 9, 25 }, { s * 14.5, 23 }, { s * 13, 16 }, { s * 14, 9 }, { s * 9.5, 12 } })
        g:form(m, L.R.night, { frac = 0.3, off = 1 }) g:mark({ { s * 6.5, 15 }, { s * 14, 23 } }, P.ink, L.R.night.base, L.R.night.shade)
      end)
    end

    ---------------------------------------------------------------- boots (real boots: a leather shaft with a cuff, a toe cap, a sole)
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "footL" or "footR")
      local m = g:RR(s * 4.5 - 3.1, 0, s * 4.5 + 3.1, 5.6, 1.6)
      m:add(g:E(s * 4.9, 1.9, 4.2, 1.9))
      g:form(m, BK, { frac = s > 0 and 0.4 or 0.25, off = 1, inner = false })
      g:under(m, BK.deep)
      g:fill(g:R(s * 4.5 - 3, 4.2, s * 4.5 + 3, 5.4), BK.hi) g:mark({ { s * 4.5 - 3, 4.2 }, { s * 4.5 + 3, 4.2 } }, BK.base, BK.hi)   -- the cuff
      g:dots({ { s * 4.9 - 1.5, 2.3 }, { s * 4.9 + 0.5, 2.3 } }, P.cream)                                                          -- a toe cap shine
      g:fill(g:R(s * 4.9 - 3.8, 0, s * 4.9 + 3.8, 0.4), BK.deep)
    end

    ---------------------------------------------------------------- body: a tunic with a hem, a belt, buttons, a collar
    g:T("body")
    local body = g:P({ { -7.4, 4 }, { -8.4, 9.5 }, { -7.4, 15.8 }, { 7.4, 15.8 }, { 8.4, 9.5 }, { 7.4, 4 } })
    g:form(body, C, { frac = 0.3, offu = 2.5, pop = { { -5.5, 13.5 } } })
    g:under(body, C.deep) g:toplight(body, C, 1)
    g:mark({ { -4.5, 6.2 }, { -4.3, 8 } }, C.shade, C.base, C.hi) g:mark({ { 4.5, 6 }, { 4.7, 7.8 } }, C.shade, C.base, C.hi)   -- folds
    g:fill(g:R(-7.4, 4, 7.4, 4.9), C.shade) g:mark({ { -7, 5.5 }, { 7, 5.5 } }, GOLD.base, C.base, C.shade, C.hi)                   -- the hem
    do local y = g:y(5.5); for x = g:x(-6.5), g:x(6.5) do if (x - g:x(-6.5)) % 3 == 2 then L.inside(c, x, y, C.base, GOLD.base) end end end
    if sp == "bee" then   -- the stripes of a bee suit
      for _, b in ipairs({ { 5.6, 7.2 }, { 8.6, 10.2 }, { 11.6, 13.2 } }) do
        local m = g:R(-8.4, b[1], 8.4, b[2]); m:clip(body); g:over(m, P.ink, C.base, C.shade, C.hi, C.deep)
      end
    else
      local belt = g:R(-8.4, 8.4, 8.4, 10); belt:clip(body)
      g:fill(belt, BK.base) g:mark({ { -8.4, 9.9 }, { 8.4, 9.9 } }, BK.shade, BK.base) g:mark({ { -8, 9.6 }, { -3, 9.6 } }, BK.hi, BK.base)
      local bx, by = g:x(0), g:y(9.2)
      c:fillMask(rect(bx - 2, by - 2, bx + 1, by + 1), GOLD.base) c:fillMask(rect(bx - 1, by - 1, bx, by), BK.deep)   -- the buckle
      c:put(bx - 2, by - 2, GOLD.hi) c:put(bx + 1, by + 1, GOLD.shade)
      if not f.apron then g:dots({ { 0, 12.2 }, { 0, 14.4 } }, GOLD.base) g:dots({ { 0, 11.6 }, { 0, 13.8 } }, GOLD.shade) end   -- buttons
    end
    local neck = g:P({ { -3, 15.8 }, { 3, 15.8 }, { 0, 12.6 } })                                                                    -- a V of skin at the neck
    g:fill(neck, B.shade) neck:each(function(x, y) if not neck:has(x, y + 1) or not neck:has(x - 1, y) then L.inside(c, x, y, C.deep, B.shade) end end)
    if f.apron then   -- a cream bib apron with a pocket and straps
      local ap = g:P({ { -5.6, 4.3 }, { -6, 9 }, { -4.6, 13.8 }, { 4.6, 13.8 }, { 6, 9 }, { 5.6, 4.3 } })
      g:form(ap, L.R.cream, { frac = 0.3, off = 1, inner = false }) g:under(ap, L.R.cream.deep)
      local pk = g:R(-3.4, 5.8, 3.4, 8.6); g:fill(pk, L.R.cream.shade) g:mark({ { -3.4, 8.6 }, { 3.4, 8.6 } }, L.R.cream.deep, L.R.cream.shade)
      g:mark({ { -3, 8 }, { 3, 8 } }, L.R.cream.base, L.R.cream.shade)
      g:mark({ { -4, 13.8 }, { -5.5, 15.8 } }, L.R.cream.deep, L.R.cream.base, L.R.cream.hi) g:mark({ { 4, 13.8 }, { 5.5, 15.8 } }, L.R.cream.deep, L.R.cream.base, L.R.cream.hi)
    end
    if q.patch then   -- a stitched patch of another cloth on the tunic's side
      local pm = g:R(2.2, 5.6, 6, 9); g:fill(pm, L.R.moss.base) g:mark({ { 2.2, 8.9 }, { 6, 8.9 } }, L.R.moss.shade, L.R.moss.base)
      local x0, y0, x1, y1 = pm:bbox()
      for x = x0, x1, 2 do c:put(x, y0, P.cream) c:put(x, y1, P.cream) end
      for y = y0 + 1, y1 - 1, 2 do c:put(x0, y, P.cream) c:put(x1, y, P.cream) end
      c:put(x0 + 2, y0 + 2, L.R.moss.hi)
    end
    if q.scarf then   -- a green scarf around the neck, one end hanging down the front
      local sc = L.R.moss
      local band = g:E(0, 15.6, 6.4, 1.9); g:form(band, sc, { frac = 0.3, off = 1 }) g:under(band, sc.deep)
      local tail = g:P({ { 2, 15.4 }, { 5.2, 14.8 }, { 5.6, 8 }, { 2.6, 8.4 } }); g:form(tail, sc, { frac = 0.4, off = 1 }) g:under(tail, sc.deep)
      g:mark({ { 3, 11 }, { 5, 11 } }, sc.hi, sc.base) g:mark({ { 3, 9.4 }, { 5.2, 9.4 } }, sc.shade, sc.base)
      for x = g:x(2.6), g:x(5.4), 2 do c:put(x, g:y(8.4) + 1, sc.deep) end
    end

    ---------------------------------------------------------------- arms: a sleeve with a cuff, then a hand
    local pawlike = (sp == "mole")
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "armL" or "armR")
      local hx, hy = s * 10.9, 7.4
      local m = g:Limb({ { s * 7.2, 14.4 }, { s * 10.2, 9.4 } }, 4.6, 4.2)
      g:form(m, C, { frac = s > 0 and 0.42 or 0.28, off = 1, inner = false }) g:under(m, C.deep) g:toplight(m, C, 1)
      g:mark({ { s * 8.6, 11.5 }, { s * 11.6, 11.7 } }, C.hi, C.base)
      g:mark({ { s * 8.6, 9.8 }, { s * 12, 10.4 } }, C.deep, C.base, C.shade, C.hi)          -- the cuff
      local hand = pawlike and g:E(hx, hy, 3.1, 2.8) or g:E(hx, hy, 2.4, 2.4)
      local HC = insect and L.R.bark or B
      if sp == "beetle" or sp == "ladybird" then HC = (sp == "beetle") and B or L.R.ink end
      g:form(hand, HC, { frac = 0.35, off = 1 }) g:under(hand, HC.deep)
      if pawlike then for i = -1, 1 do local x, y = g:x(hx) + i * 2, g:y(hy) + 2; c:put(x, y, P.cream) c:put(x, y + 1, L.R.cream.shade) end end   -- digging claws
      if sp == "hare" or sp == "hedgehog" or sp == "wren" or sp == "mouse" then g:dots({ { hx - s * 1.8, hy + 0.5 } }, HC.shade) end
      c:put(g:x(hx) - s * 2, g:y(hy) - 1, HC.hi)                                        -- thumb light
      if q.trowel and s > 0 then   -- a garden trowel held upright: wooden grip through the fist, a steel blade above
        local gr = g:R(hx - 0.6, hy - 1.5, hx + 0.8, hy + 4.8); g:form(gr, L.R.wood, { noshade = true })
        local bl = g:P({ { hx - 2, hy + 4.8 }, { hx + 2.2, hy + 4.8 }, { hx + 1.4, hy + 10.5 }, { hx + 0.1, hy + 12 }, { hx - 1.2, hy + 10.5 } })
        g:form(bl, L.R.stone, { frac = 0.4, off = 1 }) g:under(bl, L.R.stone.deep) g:mark({ { hx - 0.8, hy + 5.5 }, { hx - 0.5, hy + 10 } }, P.cream, L.R.stone.base, L.R.stone.hi)
        g:fill(g:R(hx - 1, hy + 4.5, hx + 1.4, hy + 5.1), L.R.stone.deep)
      end
      if q.flower and s < 0 then   -- a flower: green stem, two leaves, a red bloom with a gold heart
        local sx, sy = g:x(hx), g:y(hy)
        for y = sy - 12, sy do c:put(sx, y, L.R.moss.base) end
        c:put(sx - 1, sy - 8, L.R.moss.base) c:put(sx - 2, sy - 9, L.R.moss.hi) c:put(sx + 1, sy - 6, L.R.moss.shade) c:put(sx + 2, sy - 7, L.R.moss.base)
        local bm = HP.ellipse(sx, sy - 14, 3.3, 3.3); c:fillMask(bm, P.ember.base)
        bm:each(function(x, y) if not bm:has(x + 1, y + 1) then c:put(x, y, P.ember.shade) end end)
        c:put(sx - 2, sy - 16, P.ember.hi) c:put(sx - 1, sy - 16, P.ember.hi) c:put(sx, sy - 14, GOLD.base) c:put(sx - 1, sy - 14, GOLD.hi) c:put(sx + 1, sy - 14, GOLD.base)
      end
      if q.teapot and s < 0 then   -- a little teapot hanging from the hand: round belly, spout, lid knob
        local tx, ty = hx - 1, hy - 4.6
        local tp = g:E(tx, ty, 3.6, 2.9); g:form(tp, L.R.orange, { frac = 0.35, off = 1 }) g:under(tp, L.R.orange.deep)
        local sp2 = g:P({ { tx - 3, ty + 0.4 }, { tx - 5.6, ty + 2.4 }, { tx - 5.2, ty + 3 }, { tx - 2.6, ty + 1.4 } }); g:form(sp2, L.R.orange, { noshade = true })
        g:fill(g:R(tx - 1.6, ty + 2.6, tx + 1.6, ty + 3.4), L.R.orange.shade)
        g:dots({ { tx, ty + 3.6 } }, GOLD.base) g:dots({ { tx - 1.5, ty + 1.2 } }, P.cream)
        g:mark({ { tx + 3, ty + 1.4 }, { tx + 5, ty - 0.4 }, { tx + 3.6, ty - 2 } }, L.R.orange.deep, L.R.orange.base, L.R.orange.shade)
      end
    end

    ---------------------------------------------------------------- head
    g:T("head")
    local hy = 23.5
    -- behind the head: hedgehog spikes, ears, bat ears
    local function ear(s, a, b, rx, ry, inner, tilt)
      local m = g:Limb({ { s * a, b - ry + 1 }, { s * (a + (tilt or 0)), b + ry - 1 } }, rx * 2, rx * 1.7)
      g:form(m, B, { frac = 0.3, off = 1 }) g:under(m, B.deep)
      if inner then
        local im = g:Limb({ { s * a, b - ry * 0.55 }, { s * (a + (tilt or 0) * 0.9), b + ry * 0.7 } }, rx * 1.05, rx * 0.8)
        g:fill(im, inner.base) im:each(function(x, y) if not im:has(x + 1, y + 1) then c:put(x, y, inner.shade) end end)
      end
    end
    if sp == "hedgehog" then
      local S = rp(f.spike, "#7a4a1f")
      for i = 0, 12 do
        local th = math.rad(-8 + i * 16.3)
        local long = (i % 2 == 0)
        local r0, r1 = 9.6, long and 16.4 or 14.2
        local tip = { 11.6 * 0 + r1 * 1.0 * math.cos(th), hy + r1 * 0.9 * math.sin(th) }
        local m = g:P({ { (r0 * math.cos(th)) - 1.9 * math.sin(th), hy + r0 * 0.9 * math.sin(th) + 1.9 * math.cos(th) }, { (r0 * math.cos(th)) + 1.9 * math.sin(th), hy + r0 * 0.9 * math.sin(th) - 1.9 * math.cos(th) }, tip })
        g:form(m, S, { frac = 0.4, off = 1, inner = false })
        g:mark({ { r0 * math.cos(th), hy + r0 * 0.9 * math.sin(th) }, { tip[1], tip[2] } }, S.hi, S.base)
      end
    elseif sp == "hare" then
      for _, s in ipairs({ -1, 1 }) do ear(s, 4.2, 38.5, 2.5, 8, L.R.blush, 2.2) end
    elseif sp == "mouse" then
      for _, s in ipairs({ -1, 1 }) do local er = (v == 1) and 5.0 or 4.4; local m = g:E(s * 9, 30.4, er, er); g:form(m, B, { frac = 0.3, off = 1 }); g:under(m, B.deep); local im = g:E(s * 9, 30.4, er - 1.7, er - 1.7); g:fill(im, L.R.blush.base) end
    elseif sp == "mole" then
      for _, s in ipairs({ -1, 1 }) do local m = g:E(s * 9.8, 29.5, 2.6, 2.6); g:form(m, B, { frac = 0.3, off = 1 }); g:under(m, B.deep) end
    elseif sp == "bat" then
      for _, s in ipairs({ -1, 1 }) do ear(s, 7, 35, 2.8, 6, L.R.blush, 2.4) end
    end
    -- antennae (insects): a thin curved stalk and a ball at the tip
    local function antenna(s, tipx, tipy, col)
      g:stroke({ { s * 7.6, 29.5 }, { s * (7.6 + tipx * 0.7), 29.5 + tipy * 0.55 }, { s * (7.6 + tipx), 29.5 + tipy } }, col)
      g:fill(g:E(s * (7.6 + tipx), 29.5 + tipy + 0.6, 1.5, 1.5), col)
    end
    if sp == "bee" or sp == "dragonfly" then for _, s in ipairs({ -1, 1 }) do antenna(s, 3, 7.5, P.ink) end
    elseif sp == "beetle" or sp == "grasshopper" then for _, s in ipairs({ -1, 1 }) do antenna(s, 3.4, 9, L.R.bark.deep) end
    elseif sp == "ladybird" or sp == "butterfly" or sp == "moth" then for _, s in ipairs({ -1, 1 }) do antenna(s, 2.4, 8, P.ink) end end

    local head = g:E(0, hy, 10.8, 9.3)
    if sp == "wren" or sp == "hare" then head:add(g:E(0, hy - 1, 10.4, 8.8)) end
    g:form(head, B, { frac = 0.28, offu = 2.5, pop = { { -6.5, 29.5 } } })
    g:under(head, B.deep) g:toplight(head, B, 1)
    if sp == "hedgehog" or sp == "hare" or sp == "mole" or sp == "mouse" or sp == "wren" or sp == "bat" or sp == "butterfly" or sp == "moth" then g:fur(head, B, 0.5) end
    if sp == "beetle" or sp == "ladybird" then   -- the glossy shield of an insect's head
      g:mark({ { -7.5, 29 }, { -3.5, 31.2 } }, B.hi, B.base, B.shade) g:dots({ { -8.4, 27.6 }, { -6, 30.2 } }, P.cream)
    end
    if sp == "ladybird" then g:dots({ { -6, 28.5 }, { 5, 29 }, { 7.4, 26.4 } }, P.ink) g:dots({ { -5.2, 28.5 }, { 5.8, 29 }, { 8.2, 26.4 } }, P.ink) end
    if sp == "bee" then   -- two dark stripes across the crown
      for _, a in ipairs({ -3.2, 3.2 }) do local m = g:R(a - 0.7, 27.5, a + 0.7, 33); m:clip(head); g:over(m, P.ink, B.base, B.shade, B.hi, B.deep) end
    end
    if sp == "wren" or sp == "hare" or sp == "hedgehog" or sp == "mouse" then   -- a paler muzzle / cheeks
      local mz = g:E(0, 19.6, 5.6, 3.6); mz:clip(head); g:form(mz, L.lighter(B), { frac = 0.25, off = 1, inner = false })
    end
    if sp == "mouse" and v == 2 then for i, a in ipairs({ -1.6, 0, 1.6 }) do g:mark({ { a, 32 }, { a + (i - 2) * 1.2, 35 } }, B.base, B.shade) g:put(a + (i - 2) * 1.2, 35, B.hi) end end
    if sp == "wren" then
      for _, s in ipairs({ -1, 1 }) do g:dots({ { s * 4.6, 27.4 }, { s * 4.6 - s * 1.2, 27.4 } }, P.cream) end   -- pale eyebrow stripes
      for i, a in ipairs({ -2, 0, 2 }) do g:mark({ { a, 31.2 }, { a + (i - 2) * 0.8, 33.8 } }, B.hi, B.base, B.shade) end   -- the crest
    end
    -- eye patches: a paler socket round each eye so the eyes never vanish on a dark or green face; frogs get big bulging eye bumps
    local ex, ey = 4.6, 24
    if sp == "frog" then ex, ey = 5.2, 29 end
    local pr
    if (sp == "beetle" and not crew) or sp == "dragonfly" or sp == "grasshopper" or sp == "frog" then pr = L.lighter(B) elseif sp == "ladybird" then pr = L.R.cream end
    if pr then
      local rx, ry = 3.7, 3.6
      if sp == "dragonfly" then rx, ry = 4.6, 4.6 elseif sp == "frog" then rx, ry = 4.5, 4.3 end
      for _, s in ipairs({ -1, 1 }) do
        local pm = g:E(s * ex, ey, rx, ry); g:form(pm, pr, { frac = 0.28, off = 1, inner = false }) g:under(pm, pr.deep)
        if sp == "frog" then g:mark({ { s * ex - 3, ey + 4 }, { s * ex + 3, ey + 4 } }, B.shade, pr.base, pr.shade) end
      end
    end
    -- the carved features per species: nose, mouth, whiskers, cheeks
    local mx = g:x(0)
    if sp == "frog" then   -- a very wide mouth, a pale throat, nostrils, and a variant marking
      local th = g:E(0, 17.4, 6.4, 2.8); th:clip(head); g:over(th, L.lighter(B).base, B.base, B.shade, B.hi) g:over(th, L.lighter(B).shade, B.shade)
      g:stroke({ { -8.6, 20.6 }, { -6, 18.6 }, { -2, 17.6 }, { 2, 17.6 }, { 6, 18.6 }, { 8.6, 20.6 } }, LINE)
      g:dots({ { -1.5, 23.2 }, { 1.5, 23.2 } }, LINE)
      if v == 1 then g:dots({ { -3, 31.5 }, { 1.5, 32.4 }, { 3.4, 30.6 }, { -0.6, 30.2 } }, B.shade) g:dots({ { -3, 30.9 }, { 1.5, 31.8 } }, B.hi)
      elseif v == 2 then g:mark({ { 0, 33 }, { 0, 25.5 } }, L.lighter(B).base, B.base, B.shade, B.hi) end
    elseif sp == "grasshopper" then   -- a ridged forehead, cheek grooves
      g:mark({ { -2.4, 31.8 }, { 0, 28.6 }, { 2.4, 31.8 } }, B.shade, B.base, B.hi)
      if v == 1 then g:mark({ { 0, 33 }, { 0, 29.4 } }, B.deep, B.base, B.shade, B.hi) elseif v == 2 then for _, s in ipairs({ -1, 1 }) do g:mark({ { s * 8, 25 }, { s * 6.4, 17.6 } }, B.deep, B.base, B.shade) end end
      g:mark({ { -4, 19 }, { -4.6, 16.4 } }, B.shade, B.base) g:mark({ { 4, 19 }, { 4.6, 16.4 } }, B.shade, B.base)
    elseif sp == "dragonfly" then g:dots({ { -5.6, 27.6 }, { 3.6, 27.6 } }, P.cream)
    elseif sp == "butterfly" or sp == "moth" then   -- fluffy cheeks and a fur collar
      for _, s in ipairs({ -1, 1 }) do g:dots({ { s * 6, 19.4 }, { s * 7, 20.6 }, { s * 8, 22 } }, B.shade) g:dots({ { s * 3.4, 29 }, { s * 5.6, 30 } }, WGC.base) end
    elseif sp == "ladybird" then g:dots({ { -1, 31 }, { 0, 31 }, { 1, 31 }, { 0, 30 } }, P.ink)
    elseif sp == "tortoise" then   -- heavy brow ridges and wrinkles
      for _, s in ipairs({ -1, 1 }) do g:stroke({ { s * 2, 27.6 }, { s * 4.6, 27.4 }, { s * 7.4, 26.2 } }, B.deep) end
      g:mark({ { -8, 15.8 }, { -5, 15 } }, B.shade, B.base) g:mark({ { 8, 15.8 }, { 5, 15 } }, B.shade, B.base)
      g:dots({ { -8, 22 }, { 8, 23 } }, B.shade)
    end
    if sp == "mole" then   -- a big pink star nose
      local nz = g:E(0, 20, 3.4, 2.5); g:form(nz, P.petal, { frac = 0.3, off = 1 }); g:under(nz, P.petal.deep)
      for i = -3, 3 do c:put(mx + i, g:y(20) - 3 - (math.abs(i) == 3 and 0 or 1), P.petal.hi) end
      c:put(mx - 1, g:y(20), P.petal.deep) c:put(mx + 1, g:y(20), P.petal.deep) c:put(mx - 2, g:y(20) - 1, P.cream)
    elseif sp == "hare" or sp == "mouse" then
      local nz = g:E(0, 21.1, (sp == "mouse") and 1.9 or 1.5, 1.3); g:fill(nz, P.petal.base) g:dots({ { 0, 21.1 } }, P.petal.deep) c:put(mx - 1, g:y(21.1) - 1, P.cream)
      for _, s in ipairs({ -1, 1 }) do g:stroke({ { s * 3, 19.8 }, { s * 9.8, 20.6 } }, B.deep) g:stroke({ { s * 3, 18.8 }, { s * 9.2, 18.2 } }, B.deep) end   -- whiskers
      if sp == "hare" then c:put(mx, g:y(17.6), P.cream) c:put(mx + 1, g:y(17.6), P.cream) c:put(mx, g:y(17.6) + 1, L.R.white.shade) end          -- a buck tooth
    elseif sp == "hedgehog" then
      local nz = g:E(0, 21.2, 1.6, 1.3); g:fill(nz, P.ink) c:put(mx - 1, g:y(21.2) - 1, P.cream)
      local S = rp(f.spike, "#7a4a1f")
      for i, a in ipairs({ -7, -3.5, 0, 3.5, 7 }) do   -- a fringe of short spikes over the forehead
        local m = g:P({ { a - 1.7, 31 }, { a + 1.7, 31 }, { a + 0.4 * (i - 3), 28.4 - (i % 2) * 0.8 } }); m:clip(head); g:over(m, S.base, B.base, B.shade, B.hi) end
    elseif sp == "wren" then   -- a small gold beak
      local bk = g:P({ { -2, 21.8 }, { 2, 21.8 }, { 0, 17.8 } }); g:form(bk, GOLD, { frac = 0.4, off = 1, inner = false }); g:under(bk, GOLD.deep)
    elseif sp == "beetle" or sp == "grasshopper" then   -- two little mandibles
      for _, s in ipairs({ -1, 1 }) do g:stroke({ { s * 1.4, 17.8 }, { s * 3.6, 16.4 }, { s * 4.2, 18.4 } }, L.R.cream.base) g:put(s * 4.2, 18.8, L.R.cream.shade) end
    elseif sp == "frog" then g:stroke({ { -6, 18.6 }, { 0, 17.2 }, { 6, 18.6 } }, B.deep)
    elseif sp == "tortoise" then
      local bk = g:P({ { -3.4, 20.6 }, { 3.4, 20.6 }, { 0, 16.8 } }); g:form(bk, L.R.sand, { frac = 0.4, off = 1, inner = false }) g:under(bk, L.R.sand.deep) g:dots({ { -1, 19.6 }, { 1, 19.6 } }, L.R.sand.deep)
    end
    if sp ~= "beetle" and sp ~= "frog" and sp ~= "wren" and sp ~= "tortoise" and sp ~= "grasshopper" then   -- a small smile under the nose
      local sy = g:y((sp == "hedgehog" or sp == "hare" or sp == "mole" or sp == "mouse") and 17.8 or 18.4)
      for _, p in ipairs({ { -2, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 0 } }) do c:put(mx + p[1], sy + p[2], LINE) end
    end
    if sp == "snail" then   -- eye stalks with a dot on each tip, sprouting between hat and ear
      for _, s in ipairs({ -1, 1 }) do
        g:stroke({ { s * 4, 31.4 }, { s * 4.8, 35 }, { s * 5.2, 38.4 } }, B.base, 2)
        g:fill(g:E(s * 5.2, 39, 1.9, 1.9), B.base) g:over(g:E(s * 5.2, 39, 1.9, 1.9), B.hi, B.base) g:dots({ { s * 5.6, 39 } }, P.ink)
      end
    end
    g:dots({ { -7.6, 20.4 }, { 8.3, 20.4 } }, P.petal.base) g:dots({ { -6.8, 20.4 }, { 7.5, 20.4 } }, P.petal.base)   -- cheeks
    if q.feather then   -- a headband across the brow with a feather tucked in
      local bd = g:R(-10.4, 28.2, 10.4, 29.8); bd:clip(head); g:over(bd, P.sky.base, B.base, B.shade, B.hi, B.deep) g:mark({ { -10, 28.4 }, { 10, 28.4 } }, P.sky.shade, P.sky.base)
      local fe = g:Limb({ { -8, 29.4 }, { -11, 34 }, { -12.4, 40 } }, 3.2, 1.2)
      g:form(fe, L.R.white, { frac = 0.35, off = 1 }) g:under(fe, L.R.white.shade) g:mark({ { -8.4, 30 }, { -12, 39 } }, L.R.white.shade, L.R.white.base, L.R.white.hi)
    end
    g:T("eyes")
    g:eye(-ex, ey) g:eye(ex, ey)
    g:T("head")

    ---------------------------------------------------------------- hat (pivot at the crown)
    g:T("hat")
    if hat == "cap" then   -- a round cap with a seam, a button and a stitched band
      local dome = g:E(0, 31, 9.8, 5.4); dome:cut(g:R(-14, 20, 14, 29.2))
      g:form(dome, H, { frac = 0.3, off = 2, pop = { { -5.5, 34.5 } } }) g:under(dome, H.deep) g:toplight(dome, H, 1)
      g:mark({ { 0, 36.2 }, { 0, 30 } }, H.shade, H.base, H.hi)
      g:fill(g:R(-10, 29.2, 10, 30.6), H.shade) g:mark({ { -9.5, 30.2 }, { 9.5, 30.2 } }, H.hi, H.shade)
      g:fill(g:E(0, 36.4, 1.1, 1.1), GOLD.base)
      local vis = g:E(0, 29.4, 6.8, 1.5); g:form(vis, H, { frac = 0.3, off = 1 }); g:under(vis, H.deep)   -- a short peak
    elseif hat == "point" then   -- a pointed hat with a brim, a band and a star, tip bent over
      local cone = g:P({ { -9, 30 }, { -6.6, 36 }, { -2.6, 42 }, { 2.4, 44.6 }, { 5.6, 43.4 }, { 3.4, 41 }, { 4, 36 }, { 9, 30 } })
      g:form(cone, H, { frac = 0.32, off = 2, pop = { { -5, 35 } } }) g:under(cone, H.deep) g:toplight(cone, H, 1)
      local brim = g:E(0, 30.2, 12.8, 2.3); g:form(brim, H, { frac = 0.3, off = 1 }); g:under(brim, H.deep)
      g:mark({ { -12, 31.2 }, { 12, 31.2 } }, H.hi, H.base)
      do local y = g:y(32.2); for x = g:x(-8.4), g:x(8.4) do if (x - g:x(-8.4)) % 3 ~= 2 then L.inside(c, x, y, GOLD.base, H.base, H.shade, H.hi) end end end
      local sx, sy = g:x(-1.5), g:y(36.4)
      c:put(sx, sy, GOLD.hi) c:put(sx - 1, sy, GOLD.base) c:put(sx + 1, sy, GOLD.base) c:put(sx, sy - 1, GOLD.base) c:put(sx, sy + 1, GOLD.base)
      g:fill(g:E(5.8, 43.2, 1.4, 1.4), GOLD.base)
    elseif hat == "straw" then   -- a wide straw hat: flat brim, domed crown, a red band, woven dashes
      local S = L.R.butter
      local brim = g:E(0, 30.6, 14.4, 3.1); g:form(brim, S, { frac = 0.28, off = 1 }); g:under(brim, S.deep)
      local crown = g:E(0, 33, 7.4, 4.6); g:form(crown, S, { frac = 0.3, off = 2, pop = { { -3.5, 36.5 } } }); g:under(crown, S.shade)
      g:fill(g:R(-7.4, 31.6, 7.4, 33), P.ember.base) g:mark({ { -7.4, 31.7 }, { 7.4, 31.7 } }, P.ember.shade, P.ember.base) g:mark({ { -7, 32.8 }, { -1, 32.8 } }, P.ember.hi, P.ember.base)
      for i = 0, 11 do local x = g:x(-13 + i * 2.4); L.inside(c, x, g:y(30.2) + (i % 2), S.shade, S.base) L.inside(c, x + 1, g:y(30.2) + (i % 2), S.hi, S.base) end
      for i = 0, 5 do local x = g:x(-5.5 + i * 2.1); L.inside(c, x, g:y(35.4), S.shade, S.base) end
    elseif hat == "hood" then   -- a hood: a thick ring around the face, a point on top, a fold of cloth at the neck
      local ring = g:E(0, 24.6, 12.8, 11.6); ring:add(g:E(0, 33, 5, 3.6))
      ring:cut(g:E(0, 23.2, 9.9, 8.7)); ring:cut(g:R(-16, 10, 16, 14))
      g:form(ring, H, { frac = 0.3, off = 2, pop = { { -8, 31 } } }) g:under(ring, H.deep) g:toplight(ring, H, 1)
      g:mark({ { -11.5, 21 }, { -10.4, 28 } }, H.shade, H.base, H.hi)
    end
    if q.needle then   -- a needle through the cap, a loop of pink thread
      local nx, ny = g:x(3.5), g:y(33)
      for k = 0, 8 do c:put(nx + k // 2, ny - k, L.R.stone.hi) end
      c:put(nx + 4, ny - 9, L.R.stone.base) c:put(nx + 5, ny - 9, L.R.stone.shade) c:put(nx + 5, ny - 10, L.R.stone.base)
      for _, p in ipairs({ { 5, -8 }, { 7, -7 }, { 8, -5 }, { 7, -3 }, { 5, -3 } }) do c:put(nx + p[1], ny + p[2], P.petal.base) end
      c:put(nx + 6, ny - 3, P.petal.shade) c:put(nx + 4, ny - 2, P.petal.shade)
    end

    local bones = { { "footL", false, -4.5, 4 }, { "footR", false, 4.5, 4 }, { "body", false, 0, 4 }, { "armL", "body", -7.2, 14.4 }, { "armR", "body", 7.2, 14.4 },
      { "head", "body", 0, 14.8 }, { "eyes", "head", 0, 24 }, { "hat", "head", 0, 31 } }
    if hasWings then bones[#bones + 1] = { "wingL", "body", -5, 14, true } bones[#bones + 1] = { "wingR", "body", 5, 14, true } end
    if hasBack then bones[#bones + 1] = { "back", "body", -5, 12, true } end
    return bones
  end
end
