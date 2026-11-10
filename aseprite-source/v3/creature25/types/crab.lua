-- crab: crabs, a hermit, a scorpion and a crayfish, FRONT view (they face the viewer). Parts, back to front: tail (scorpion sting / crayfish fan, behind the body), leg1..leg4 (1, 2 on the left),
-- [shell], body, [shell], eyeL, eyeR (stalks with the eye on top; springs), clawL, clawR (arm, palm and two fingers with a hinge).
-- Spec features: shell = a back plate whose look depends on the animal (the slug picks it): hermit = a borrowed whelk shell (drawn BEHIND the body), tide crab knight = riveted steel armour,
-- mangrove king = a lilac ruffled mantle, coconut titan = a lumpy ridged back, old pinch = a barnacled, scarred dome. tail = the dune scorpion's segmented sting, or the crayfish's curled-up fan.
-- Scorpion and crayfish have long slim pincers; the crayfish also has long feelers painted into the body.
-- Quirks (quirks/crab.lua):
--   chip = the tip of the left pincer is chipped      button = a gold button is stuck on the whelk shell   plume = a feather plume on the armour
--   crown = a little gold crown on top               nut = a coconut sits on its back                      patch = an eyepatch over the left eye
--   ring = a gold ring round a tail segment          mud = splashes and a drip of mud on its shell/body
return function(L)
  local P = L.P
  local sin, cos, pi, max, min, floor = math.sin, math.cos, math.pi, math.max, math.min, math.floor
  local GR = L.R.gold

  local function arc(cx, cy, rx, ry, d0, d1, n)
    local t = {}
    for i = 0, n do local d = math.rad(d0 + (d1 - d0) * i / n); t[#t + 1] = { cx + rx * cos(d), cy + ry * sin(d) } end
    return t
  end

  return function(g)
    local c, f, q, B, A, D, slug = g.c, g.f, g.q, g.B, g.A, g.D, g.s.slug
    local kind = slug:find("hermit") and "hermit" or slug:find("knight") and "knight" or slug:find("king") and "king" or slug:find("coconut") and "coconut"
      or slug:find("pinch") and "pinch" or slug:find("scorpion") and "scorpion" or slug:find("crayfish") and "crayfish" or "shore"
    local slim = kind == "scorpion" or kind == "crayfish"
    local clawR = f.shell and B or A                      -- the pincers wear the accent colour unless the accent is the shell's
    local bw, bh = 17.5, 9.2
    if kind == "scorpion" then bw, bh = 16, 8 elseif kind == "crayfish" then bw, bh = 13.5, 8.8 elseif kind == "coconut" or kind == "pinch" then bw, bh = 18, 9.6 end
    local by = 13
    g:shadow(0, 31)

    ---------------------------------------------------------------- the tail (behind everything)
    if f.tail then
      g:T("tail")
      local pts, rs
      if kind == "scorpion" then
        pts = { { -4, 16 }, { -11, 21 }, { -14.5, 29 }, { -11, 36 }, { -4, 39.5 }, { 2.5, 36.5 } }
        rs = { 3.6, 3.5, 3.3, 3.1, 2.9, 2.6 }
      else
        pts = { { -4, 15 }, { -11, 19.5 }, { -15, 27 }, { -12.5, 34 }, { -7, 37.5 } }
        rs = { 4.6, 4.4, 4.1, 3.8, 3.5 }
      end
      for i = 1, #pts do   -- segments, each one a little bead of armour overlapping the last
        local m = g:E(pts[i][1], pts[i][2], rs[i], rs[i] * (kind == "scorpion" and 1 or 0.95))
        g:form(m, B, { frac = 0.34, off = 1, pop = { { pts[i][1] - rs[i] * 0.5, pts[i][2] + rs[i] * 0.55 } } }) g:under(m, B.deep)
        g:inside(pts[i][1] - 0.5, pts[i][2] + 0.4, B.shade, B.base, B.hi)
        if q.ring and i == 3 then   -- a gold ring round this segment
          g:stroke({ { pts[i][1] - 3.4, pts[i][2] + 0.6 }, { pts[i][1] + 3.4, pts[i][2] - 0.2 } }, GR.base)
                    g:dots({ { pts[i][1] - 2, pts[i][2] + 0.2 }, { pts[i][1] + 2, pts[i][2] - 0.2 } }, GR.hi)
        end
      end
      if kind == "scorpion" then   -- the sting: a curved barb on a bulb
        local tip = pts[#pts]
        local bulb = g:E(tip[1], tip[2] - 0.6, 3, 2.8)
        g:form(bulb, A, { frac = 0.34, off = 1 }) g:under(bulb, A.deep)
        local barb = g:P({ { tip[1] - 1.8, tip[2] - 2 }, { tip[1] + 2.4, tip[2] - 1.4 }, { tip[1] + 3.4, tip[2] - 7 } })
        g:form(barb, A, { frac = 0.34, off = 1 }) g:under(barb, A.deep)
        g:dots({ { tip[1] + 3.2, tip[2] - 6.4 } }, P.ink)
      else   -- the fan: five lamellae opening from the last segment
        local tip = pts[#pts]
        for k = -2, 2 do
          local d = math.rad(20 + k * 24); local dx, dy = cos(d), sin(d)
          local m = g:Ln({ { tip[1] + dx * 2, tip[2] + dy * 2 }, { tip[1] + dx * 7.5, tip[2] + dy * 7.5 } }, 3.2)
          m:add(g:E(tip[1] + dx * 8, tip[2] + dy * 8, 2.3, 2.3))
          g:form(m, B, { frac = 0.34, off = 1 }) g:under(m, B.deep)
        end
      end
    end
    local tailBone = kind == "scorpion" and { "tail", "body", -9, 16, true } or { "tail", "body", -8, 15, true }

    ---------------------------------------------------------------- legs: out to a knee, then down to a pointed foot
    local legs = {}
    for i = 1, 4 do
      local s = i <= 2 and -1 or 1
      local outer = (i == 1 or i == 4)
      g:T("leg" .. i)
      local hip, knee, foot
      if outer then hip, knee, foot = { s * 12, 9.5 }, { s * 25, 12.5 }, { s * 30.5, 1.2 } else hip, knee, foot = { s * 7.5, 8.5 }, { s * 18.5, 10 }, { s * 22.5, 1.2 } end
      if slim then knee[2] = knee[2] + 1; foot[1] = foot[1] + s * 0.5 end
      local r = outer and B or D
      local m = g:Limb({ hip, knee, foot }, 3.6, 1.9)
      m:clip(g:R(-60, 0, 60, 60))
      g:form(m, r, { frac = 0.4, off = 1 }) g:under(m, r.deep)
      g:inside(knee[1] - s * 0.6, knee[2] + 1.2, r.hi, r.base)                                      -- the knee catches the light
      g:dots({ { knee[1] + s * 0.4, knee[2] - 0.2 } }, r.shade)                                      -- the joint
      g:dots({ { foot[1], foot[2] - 0.2 } }, r.deep) g:dots({ { (knee[1] + foot[1]) / 2 + s * 0.2, (knee[2] + foot[2]) / 2 } }, r.shade)
      legs[#legs + 1] = { "leg" .. i, "body", hip[1], hip[2], true }
    end

    ---------------------------------------------------------------- the hermit's borrowed whelk shell (behind the body)
    local function whelk()
      g:T("shell")
      local m = g:E(-3, 25, 11.5, 9.5)                                  -- the body whorl
      m:add(g:E(-6.5, 34, 7, 5.8)) m:add(g:E(-9, 40, 4.2, 3.6)) m:add(g:P({ { -11.5, 41 }, { -10, 47 }, { -7.2, 41 } }))
      g:form(m, A, { frac = 0.3, offu = 3.5, pop = { { -9, 30 }, { -10.5, 36 }, { -9.5, 41 } } })
      g:under(m, A.deep) g:toplight(m, A, 1)
      g:mark(arc(-3, 25, 11, 9, 60, 200, 16), A.deep, A.base, A.hi, A.shade)                           -- sutures between the whorls
      g:mark(arc(-6.5, 34, 6.6, 5.4, 70, 200, 12), A.deep, A.base, A.hi, A.shade)
      g:mark(arc(-3, 25, 7, 5.6, 20, 160, 12), A.shade, A.base, A.hi)
      for i = 0, 5 do local a = -12 + i * 3.7; g:inside(a, 22 + (i % 2) * 2, A.shade, A.base) g:inside(a + 0.9, 28 + (i % 2), A.hi, A.base) end   -- ribs
      for i = 0, 3 do g:inside(-10 + i * 1.8, 36.5 + i * 0.4, A.shade, A.base) end
      for i = 1, 5 do g:inside(-14 + g:rnd(i, 3) * 16, 20 + g:rnd(i, 4) * 10, A.hi, A.base) end
      if q.button then   -- a gold button stuck to the shell (the hoard)
        g:fill(g:E(2.6, 29.2, 2.4, 2.4), GR.base); g:dots({ { 1.6, 29.8 }, { 3.6, 29.8 }, { 2.6, 28.6 } }, GR.shade)
        g:dots({ { 1.8, 30.6 }, { 2.4, 31 } }, GR.hi) g:dots({ { 2.6, 29.2 } }, GR.deep)
      end
    end
    if kind == "hermit" then whelk() end

    ---------------------------------------------------------------- the body: carapace with a front lip, a mouth and cheeks
    g:T("body")
    local body = g:E(0, by, bw, bh)
    if kind ~= "crayfish" then   -- little spines at the sides
      for _, s in ipairs({ -1, 1 }) do body:add(g:P({ { s * (bw - 2), by + 4.5 }, { s * (bw + 3.4), by + 2.8 }, { s * (bw - 1), by - 1 } })) end
    else   -- a pointed rostrum between the eyes
      body:add(g:P({ { -2.2, by + 6 }, { 0, by + 12 }, { 2.2, by + 6 } }))
    end
    g:form(body, B, { frac = 0.28, offu = 3, pop = { { -bw * 0.62, by + bh * 0.55 }, { -bw * 0.5, by + bh * 0.72 } } })
    g:under(body, B.deep) g:belly(body, B, 2) g:toplight(body, B, 1)
    -- carapace grooves: the cervical groove and two lines running back
    g:mark(arc(0, by + 1, bw * 0.6, 4.4, 195, 345, 14), B.shade, B.base, B.hi)
    g:mark({ { -bw * 0.62, by + 1.2 }, { -bw * 0.74, by - 2.4 } }, B.shade, B.base, B.hi) g:mark({ { bw * 0.62, by + 1.2 }, { bw * 0.74, by - 2.4 } }, B.shade, B.base, B.hi)
    g:mark(arc(0, by - 0.5, bw * 0.92, bh * 0.92, 188, 352, 18), B.shade, B.base, B.hi)             -- front lip of the shell
    if kind == "scorpion" then   -- segmented back plates
      for k = -2, 2 do g:mark({ { k * 5.4, by + 6 }, { k * 6.2, by - 2 } }, B.deep, B.base, B.hi, B.shade) end
    end
    for i = 1, 14 do   -- tubercles
      local a, b = (g:rnd(i, 1) - .5) * 2 * (bw - 4), by + 1 + g:rnd(i, 2) * (bh - 3)
      g:inside(a, b, B.shade, B.base) g:inside(a, b + 0.9, B.hi, B.base)
    end
    -- the face: a mouth of little mouthparts under the front lip
    g:stroke({ { -3.2, by - 4 }, { -1.6, by - 5.2 }, { 1.6, by - 5.2 }, { 3.2, by - 4 } }, B.deep)
    g:dots({ { -2.4, by - 6.4 }, { 2.4, by - 6.4 }, { -0.6, by - 6.8 }, { 0.6, by - 6.8 } }, B.shade)
    g:dots({ { -6.4, by - 3 }, { -5.6, by - 3 }, { 5.6, by - 3 }, { 6.4, by - 3 } }, P.petal.base)    -- cheeks
    if kind == "crayfish" then   -- long feelers painted into the body: thin lines sweeping out and up
      for _, s in ipairs({ -1, 1 }) do
        g:stroke({ { s * 2.4, by + 7 }, { s * 8, by + 17 }, { s * 14, by + 25 }, { s * 21, by + 27 } }, B.deep)
        g:stroke({ { s * 3.8, by + 6.2 }, { s * 13, by + 13 }, { s * 22, by + 18.5 }, { s * 30, by + 20 } }, B.shade)
      end
    end
    if q.mud then
      for _, p in ipairs({ { 6, by + 2 }, { 9.4, by - 1 }, { 3, by - 2.4 }, { -8, by + 1.5 } }) do
        local m = g:E(p[1], p[2], 1.8, 1.2); m:clip(body); g:over(m, L.R.bark.base, B.base, B.shade, B.hi) g:inside(p[1] - 0.8, p[2] + 0.6, L.R.bark.shade, L.R.bark.base)
      end
      g:dots({ { 4, by - 2.6 }, { 4, by - 3.6 } }, L.R.bark.base)
    end

    ---------------------------------------------------------------- the back plate in front of the body
    if f.shell and kind ~= "hermit" then
      g:T("shell")
      if kind == "knight" then   -- steel armour: a visor plate with lames, a central ridge, rivets
        local pl = g:E(0, by + 3.5, bw - 2, 6.4)
        g:form(pl, A, { frac = 0.3, offu = 2.5, pop = { { -11, by + 7 }, { -9, by + 8.6 } } }) g:under(pl, A.deep) g:toplight(pl, A, 1)
        for k = 1, 2 do g:mark(arc(0, by + 3.5 - k * 0.2, (bw - 2) * (1 - k * 0.0), 6.4 - k * 2.1, 190, 350, 20), A.deep, A.base, A.hi, A.shade) end
        g:mark({ { 0, by + 9.4 }, { 0, by - 2 } }, A.deep, A.base, A.hi, A.shade) g:mark({ { -1, by + 9 }, { -1, by - 1.5 } }, A.hi, A.base)
        for _, p in ipairs({ { -11.5, by + 3 }, { -7, by + 0.6 }, { 7, by + 0.6 }, { 11.5, by + 3 }, { -6, by + 6.6 }, { 6, by + 6.6 } }) do g:dots({ p }, P.cream) g:dots({ { p[1] + 0.8, p[2] - 0.8 } }, A.deep) end
      elseif kind == "king" then   -- a ruffled mantle with a crest of points along the top
        local pl = g:E(0, by + 4.2, 13.5, 6.6)
        for k = -3, 3 do pl:add(g:P({ { k * 3.7 - 1.8, by + 9 }, { k * 3.7 + 0.2, by + 13.2 - math.abs(k) * 0.8 }, { k * 3.7 + 1.8, by + 9 } })) end
        g:form(pl, A, { frac = 0.3, offu = 2.5, pop = { { -9, by + 8.5 }, { -6, by + 11 } } }) g:under(pl, A.deep) g:toplight(pl, A, 1)
        for k = -4, 4 do g:mark({ { k * 2.9, by + 8.4 }, { k * 3.5, by - 1 } }, A.shade, A.base, A.hi) end
        g:mark(arc(0, by + 4.2, 11, 5, 200, 340, 14), A.deep, A.base, A.hi, A.shade)
        g:dots({ { -10, by + 6 }, { 10, by + 6 }, { -5, by + 2 }, { 5, by + 2 } }, A.hi)
      elseif kind == "coconut" then   -- a lumpy back in three ridged rows
        local pl = g:E(0, by + 3.8, 14.5, 7); pl:add(g:E(-8, by + 4, 5, 4.6)) pl:add(g:E(8, by + 4, 5, 4.6))
        g:form(pl, A, { frac = 0.3, offu = 3, pop = { { -10, by + 8 }, { -7, by + 9.6 } } }) g:under(pl, A.deep) g:toplight(pl, A, 1)
        for k = 0, 2 do g:mark(arc(0, by + 1.6 + k * 2.6, 13.4 - k * 1.2, 2.2, 190, 350, 16), A.deep, A.base, A.hi, A.shade) end
        for i = 1, 9 do local a, b = (g:rnd(i, 5) - .5) * 24, by + 1 + g:rnd(i, 6) * 7; g:inside(a, b, A.deep, A.base, A.shade) g:inside(a, b + 0.9, A.hi, A.base) end
        if q.nut then   -- a coconut balanced on top: hairy brown ball with three dark eyes
          local nm = g:E(8, by + 12.4, 4, 3.8)
          g:form(nm, L.R.bark, { frac = 0.34, off = 1, pop = { { 5.8, by + 14.2 } } }) g:under(nm, L.R.bark.deep)
          g:dots({ { 7.2, by + 13 }, { 9, by + 13 }, { 8.2, by + 11.6 } }, P.ink)
          for k = 0, 3 do g:inside(5.4 + k * 1.4, by + 10.6 + (k % 2) * 3, L.R.bark.hi, L.R.bark.base) end
        end
      else   -- old pinch: a worn dome, scratched, barnacles clinging to it
        local pl = g:E(0, by + 3.4, 14.5, 6.8)
        g:form(pl, A, { frac = 0.3, offu = 3, pop = { { -10, by + 7.4 }, { -8, by + 8.8 } } }) g:under(pl, A.deep) g:toplight(pl, A, 1)
        g:mark(arc(0, by + 3.4, 12, 4.8, 200, 340, 14), A.shade, A.base, A.hi)
        g:mark({ { -6, by + 8 }, { -3.4, by + 4 } }, A.deep, A.base, A.hi, A.shade) g:mark({ { 5, by + 8.4 }, { 8, by + 3.4 } }, A.deep, A.base, A.hi, A.shade)   -- scratches
        for _, p in ipairs({ { -11, by + 3 }, { -9.4, by + 5 }, { 10, by + 2.6 }, { 8.2, by + 5.4 }, { 2, by + 7.2 } }) do
          local m = g:E(p[1], p[2], 1.6, 1.4); g:over(m, P.cream, A.base, A.shade, A.hi, A.deep)
          g:dots({ { p[1], p[2] } }, P.stone.shade) g:dots({ { p[1] + 1, p[2] - 0.8 } }, "#ffe0bd")
        end
      end
    end
    if q.plume then   -- a plume of feathers on top of the armour
      g:stroke({ { 0, by + 8 }, { 0.4, by + 12 } }, P.stone.shade)
      for k = 0, 6 do
        local t = k / 6; local a, b = -0.5 + math.sin(t * 2.4) * 5, by + 11 + t * 9
        g:fill(g:Ln1({ { 0.4, by + 11.4 }, { a, b } }, 2), P.ember.base)
      end
      g:dots({ { -4, by + 18.2 }, { -3, by + 19.6 }, { -1, by + 20.4 } }, P.ember.hi) g:dots({ { 1.4, by + 12.6 }, { 2.4, by + 14.4 } }, P.ember.shade)
    end
    if q.crown then   -- a little gold crown, tilted, resting between the eyes
      local cr = g:P({ { -4, by + 8.6 }, { 4, by + 8.6 }, { 5, by + 14 }, { 2.4, by + 11.8 }, { 0, by + 15 }, { -2.4, by + 11.8 }, { -5, by + 14 } })
      g:form(cr, GR, { frac = 0.34, off = 1 }) g:under(cr, GR.deep)
      g:dots({ { -4.2, by + 14.3 }, { 0, by + 15.3 }, { 4.8, by + 14.3 } }, P.ember.base) g:dots({ { -1, by + 10.4 }, { 1.4, by + 10.4 } }, P.ember.base)
    end

    ---------------------------------------------------------------- eyes on stalks
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "eyeL" or "eyeR")
      local ea = s * (slim and 5.4 or 6.4)
      local top = slim and 27.4 or 28.4
      local st = g:Limb({ { ea * 0.85, by + 7 }, { ea, top - 3 } }, 3.4, 3.0)
      g:form(st, B, { frac = s > 0 and 0.4 or 0.15, off = 1 })
      local ball = g:E(ea, top, 3.9, 3.7)
      g:form(ball, B, { frac = s > 0 and 0.34 or 0.12, off = 1, pop = s < 0 and { { ea - 1.8, top + 2.2 } } or nil })
      g:under(ball, B.deep)
      g:eye(ea + 0.4, top - 0.2)
      if q.patch and s < 0 then   -- an eyepatch over the left eye, with a strap
        local ex, ey = g:x(ea + 0.4), g:y(top - 0.2)
        c:fillMask(L.HP.rect(ex - 2, ey - 2, ex + 1, ey + 1), P.ink)
        c:put(ex - 2, ey - 2, P.stone.deep) c:put(ex - 1, ey - 2, P.stone.deep)
        g:stroke({ { ea - 3, top + 0.5 }, { ea - 4.6, top + 3 } }, P.ink) g:stroke({ { ea + 3, top + 0.5 }, { ea + 4.4, top - 2 } }, P.ink)
      end
    end

    ---------------------------------------------------------------- pincers: arm, palm, two fingers and a hinge
    local px, py, prx, pry, FL, fw = 21.5, 19.5, 6.4, 5.6, 8.6, 4.6
    if slim then px, py, prx, pry, FL, fw = 22.5, 18.5, 4.6, 3.8, 13, 3.4 end
    if kind == "crayfish" then prx, pry, FL, fw = 5.4, 4.6, 11.5, 3.8 end
    for _, s in ipairs({ -1, 1 }) do
      g:T(s < 0 and "clawL" or "clawR")
      local r = clawR
      local arm = g:Limb({ { s * 13, 15.5 }, { s * (px - 4), py - 3 } }, 4.6, 4.2)
      g:form(arm, r, { frac = 0.4, off = 1 }) g:under(arm, r.deep)
      g:dots({ { s * (px - 8), 16.5 } }, r.shade)
      local palm = g:E(s * px, py, prx, pry)
      g:form(palm, r, { frac = s > 0 and 0.38 or 0.2, offu = 2, pop = { { s * px - 2.4, py + pry - 1.4 } } }) g:under(palm, r.deep) g:toplight(palm, r, 1)
      -- the two fingers: outer (fixed) and inner (moving), meeting at the tips, a gap between
      local top = py + pry
      local fo = g:Limb({ { s * (px + prx * 0.5), py + pry * 0.2 }, { s * (px + prx * 1.05), top + FL * 0.5 }, { s * (px + prx * 0.6), top + FL } }, fw - 0.8, 1.3)
      local fi = g:Limb({ { s * (px - prx * 0.55), py + pry * 0.3 }, { s * (px - prx * 0.95), top + FL * 0.5 }, { s * (px - prx * 0.4), top + FL - 0.6 } }, fw - 1.2, 1.3)
      if q.chip and s < 0 then   -- the tip of the left pincer is chipped
        fo:cut(g:E(s * (px + prx * 0.6), top + FL + 0.4, 1.7, 1.7)) fi:cut(g:E(s * (px - prx * 0.4), top + FL + 0.2, 1.2, 1.4))
      end
      g:form(fo, r, { frac = s > 0 and 0.42 or 0.2, off = 1 }) g:under(fo, r.deep)
      g:form(fi, r, { frac = s > 0 and 0.4 or 0.2, off = 1 }) g:under(fi, r.deep)
      g:inside(s * (px + prx * 0.85) - s * 0.8, top + FL * 0.5, r.hi, r.base)
      -- the hinge: a dark pin where the fingers meet the palm, and teeth along the cutting edges
      g:fill(g:E(s * (px + 0.4), top - 0.6, 1.3, 1.3), r.deep) g:dots({ { s * (px + 0.4) - 0.6, top } }, r.hi)
      for k = 1, 3 do
        local t = 0.3 + k * 0.16
        g:dots({ { s * (px - prx * (0.9 - 0.2 * t)) + s * 1.4, top + FL * t } }, P.cream)
      end
      
    end

    -- bones: parts in tag order; legs hang under the body
    local bones = { { "body", false, 0, 11 } }
    for _, l in ipairs(legs) do bones[#bones + 1] = l end
    if f.shell then bones[#bones + 1] = kind == "hermit" and { "shell", "body", -3, 17, true } or { "shell", "body", 0, 15 } end
    bones[#bones + 1] = { "eyeL", "body", -5.4, by + 7 } bones[#bones + 1] = { "eyeR", "body", 5.4, by + 7 }
    bones[#bones + 1] = { "clawL", "body", -13.5, 16 } bones[#bones + 1] = { "clawR", "body", 13.5, 16 }
    if f.tail then bones[#bones + 1] = tailBone end
    return bones
  end
end
