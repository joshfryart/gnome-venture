-- snake: snakes, lizards, a gharial, fish, eels and wyrms (side view, faces RIGHT). Parts: s1 (tail tip, on the ground) .. s6 (neck), hood (behind the head), head, eyes.
-- Each s_k is ONE tube piece: a tapered capsule from the joint behind it to the joint in front of it, with round caps of the body's own radius at both joints, so the body
-- is a closed tube however the springs swing it. Fins, legs, rattles are painted into those parts.
-- Spec features: band (cross bars / saddles / diamonds / plates, by kind), hood (cobra hood for snakes, dorsal fan for fish, spiked frill for wyrms), snout (longer muzzle), spots.
-- Kinds (from the slug, see KIND): snake (belly scutes, saddles or diamonds, a forked tongue), lizard (a lower body with small legs on s3 + s5, a tapering tail), gharial (a long thin
--   toothy snout), fish (tail fin on s1, dorsal fin, gill cover, pectoral fin), eel (a frill along the whole back), loach (barbels, bars), wyrm (armour plates, a spiked frill, big jaws).
-- Quirks (quirks/snake.lua): flower = a daisy behind the eye; ring = a gold ring round the body; rattle = a rattle on the tail tip; pearls = a pearl necklace; shades = sunglasses pushed
--   up on the forehead; pepper = a chili in its mouth; scar = a stitched scar over the snout; moss = a tuft of moss on its back; bird = a little bird on its snout;
--   hook = a fishing hook and line in its lip; worm = a pink worm snack hanging from its mouth; crown = a coral crown; monocle = a gold monocle; barnacles = barnacles on its back; bone = a bone in its jaws.
-- Extra parts: none.
return function(L)
  local P = L.P
  local HP = L.HP
  local max, min, sqrt, rd = math.max, math.min, math.sqrt, L.rd
  local KIND = {
    ["grass-snake"] = "snake", ["emerald-python"] = "snake", ["dust-sidewinder"] = "snake", ["sand-viper-matriarch"] = "snake",
    ["sun-lizard"] = "lizard", ["spice-monitor"] = "lizard", ["desert-gila-dragon"] = "lizard", ["cistern-newt"] = "lizard",
    ["delta-gharial"] = "gharial", ["bog-pike"] = "fish", ["silverfin"] = "fish", ["stone-loach"] = "loach", ["reef-eel-lord"] = "eel", ["reef-leviathan"] = "eel", ["dune-wyrm"] = "wyrm",
  }
  -- the spine: centre of the tube at the joints C0 (tail tip) .. C6 (neck top), and the radius there
  local RISE = { { -26, 1.5 }, { -18, 3.4 }, { -10, 6.2 }, { -3, 5 }, { 4, 8.6 }, { 10, 14 }, { 13.5, 20.5 } }
  local LOW  = { { -27, 1.4 }, { -19, 2.8 }, { -11, 4.4 }, { -3, 7.2 }, { 5, 8.8 }, { 10.5, 11 }, { 14, 14.5 } }
  local SPEC = {
    snake   = { C = RISE, r = { 1.0, 3.2, 4.2, 4.8, 5.0, 4.8, 4.2 }, hx = 2.6, hb = 4.2 },
    lizard  = { C = LOW,  r = { 0.9, 2.0, 3.2, 4.6, 5.0, 4.6, 3.6 }, hx = 3.2, hb = 2.6, legs = true },
    gharial = { C = LOW,  r = { 0.9, 2.2, 3.6, 4.8, 5.2, 4.4, 3.2 }, hx = 2.6, hb = 1.2, legs = true },
    fish    = { C = RISE, r = { 1.4, 3.2, 4.4, 5.4, 5.8, 5.6, 4.8 }, hx = 2.6, hb = 3.6 },
    loach   = { C = RISE, r = { 1.4, 3.0, 4.0, 4.6, 4.8, 4.6, 4.0 }, hx = 2.4, hb = 3.4 },
    eel     = { C = RISE, r = { 1.0, 2.6, 3.6, 4.0, 4.2, 4.2, 3.8 }, hx = 2.8, hb = 3.8 },
    wyrm    = { C = RISE, r = { 2.0, 4.6, 6.0, 6.6, 7.0, 7.0, 6.2 }, hx = 2.8, hb = 5.0 },
  }
  return function(g)
    local c, f, q, B, A = g.c, g.f, g.q, g.B, g.A
    local slug = g.s.slug
    local kind = KIND[slug] or "snake"
    local S = SPEC[kind]
    local C, Rr = S.C, S.r
    if slug == "silverfin" then Rr = { 1.6, 3.8, 5.4, 6.6, 7.2, 7.0, 6.0 } end
    if slug == "reef-leviathan" then Rr = { 1.4, 3.6, 5.0, 5.8, 6.2, 6.0, 5.2 } end
    do local C2 = {}; for i, p in ipairs(C) do C2[i] = { p[1], max(p[2], Rr[i] + 0.6) } end C = C2 end   -- nothing dips below the ground
    local HI, DK = L.lighter(B), L.darker(B)
    local fishy = kind == "fish" or kind == "loach" or kind == "eel"
    local hx, hb = C[7][1] + S.hx, C[7][2] + S.hb
    local belly = (kind == "snake" or kind == "lizard" or kind == "gharial") and (slug == "grass-snake" and L.R.butter or L.lighter(B)) or HI
    if slug == "cistern-newt" or slug == "desert-gila-dragon" then belly = A end

    g:shadow(-4, 31)

    ---------------------------------------------------------------- helpers
    local function leg(a0, b0, r, far)   -- a small bent leg with a foot, from the belly at (a0, b0) to the ground
      local fa = a0 + (far and 3.8 or 0)
      local lg = g:Limb({ { fa + 0.5, b0 }, { fa - 2.6, b0 * 0.5 }, { fa + 0.4, 1.0 } }, 3.4, 2.5)
      g:form(lg, r, { frac = 0.45, off = 1, inner = false }); g:under(lg, r.deep)
      local ft = g:E(fa + 1.8, 0.9, 2.8, 1.0); g:form(ft, r, { frac = 0.4, off = 1, inner = false }); g:under(ft, r.deep)
      for _, d in ipairs({ 0.8, 2.4, 3.9 }) do g:put(fa + d, 1.4, r.deep) end
    end
    local function fin(pts, r, rays)   -- a fin: lit membrane with darker rays and a deep rim
      local m = g:P(pts); g:form(m, r, { frac = 0.35, off = 1, inner = false })
      if rays then for _, rr in ipairs(rays) do g:mark(rr, r.shade, r.base, r.hi) end end
      return m
    end

    ---------------------------------------------------------------- the body: tail fin / rattle first (they live in s1), then s1 .. s6
    for k = 1, 6 do
      local p0, p1 = C[k], C[k + 1]
      local r0, r1 = Rr[k], Rr[k + 1]
      g:T("s" .. k)
      local ramp = B
      local alt = f.band and (k % 2 == 0)
      if k == 1 then
        if fishy and kind ~= "eel" or slug == "reef-leviathan" then   -- tail fin: a tall upper lobe, a low lower lobe
          local fr = (slug == "silverfin" or slug == "reef-leviathan") and A or (kind == "loach" and DK or A)
          local a0, b0 = p0[1], p0[2]
          fin({ { a0 + 3.5, b0 + 1.6 }, { a0 - 1, b0 + 8 }, { a0 - 6.5, b0 + 12 }, { a0 - 4.5, b0 + 5 }, { a0 - 7, b0 + 0.9 }, { a0 + 3.5, b0 - 0.6 } }, fr,
            { { { a0 + 2, b0 + 1 }, { a0 - 5, b0 + 9 } }, { { a0 + 2, b0 + 0.9 }, { a0 - 4.4, b0 + 5 } } })
        elseif kind == "eel" then   -- a pointed tail with a thin fin
          local a0, b0 = p0[1], p0[2]
          fin({ { a0 + 6, b0 + 2 }, { a0 - 2, b0 + 4.6 }, { a0 - 5, b0 + 0.6 }, { a0 + 6, b0 + 0.4 } }, A, { { { a0 + 4, b0 + 1 }, { a0 - 2, b0 + 3.4 } } })
        elseif q.rattle then   -- a rattle: three dry beads on the tip
          local a0, b0 = p0[1], p0[2]
          for i = 0, 2 do local bm = g:E(a0 - 1.5 - i * 2.7, b0 + 0.6 + i * 0.1, 2.0 - i * 0.2, 1.7 - i * 0.2); g:form(bm, L.R.tan, { frac = 0.35, off = 1, inner = false }); g:under(bm, L.R.tan.deep) end
        end
      end
      local m = g:Limb({ p0, p1 }, r0 * 2, r1 * 2)
      if slug == "dune-wyrm" and k % 2 == 0 then ramp = A end
      g:form(m, ramp, { frac = 0.12, offu = 3 })
      -- the pale belly strip with scutes
      m:each(function(x, y)
        if not m:has(x, y + 2) and m:has(x, y - 2) then L.inside(c, x, y, belly.base, ramp.base, ramp.shade) end
        if not m:has(x, y + 3) and m:has(x, y - 2) and not m:has(x, y + 2) then end
      end)
      m:each(function(x, y) if not m:has(x, y + 3) and m:has(x, y + 2) then L.inside(c, x, y, ramp.shade, ramp.base) end end)
      g:under(m, belly.deep or ramp.deep)
      g:toplight(m, ramp)
      -- the rim of this piece's front cap over the piece behind it: reads as the scale ring
      if k >= 2 then
        local jx, jy, rj = g:x(p0[1]), g:y(p0[2]), r0 * g.u
        local tx, ty = C[k - 1][1] - p0[1], -(C[k - 1][2] - p0[2])
        local tl = sqrt(tx * tx + ty * ty); tx, ty = tx / tl, ty / tl
        m:each(function(x, y)
          local dx, dy = x - jx, y - jy; local d = sqrt(dx * dx + dy * dy)
          if d > rj - 1.0 and d < rj + 0.2 and (dx * tx + dy * ty) > 0.25 * d and y < g.gy then c:put(x, y, ramp.shade) end
        end)
      end
      -- scale texture
      if kind ~= "eel" then g:fur(m, ramp, kind == "wyrm" and 0.7 or 1.0) end
      -- markings
      local mid = { (p0[1] + p1[1]) / 2, (p0[2] + p1[2]) / 2 }
      local rm = (r0 + r1) / 2
      if f.band and k >= 2 and not (slug == "dune-wyrm") then
        if kind == "snake" then
          if slug == "grass-snake" then   -- dark cross bars on the flank
            for i = -1, 1, 2 do g:inside(mid[1] + i * 1.2, mid[2] + rm * 0.1, A.deep, ramp.base, ramp.shade, ramp.hi)
              for j = 0, 3 do g:inside(mid[1] + i * 1.2 + (j % 2) * 0.1, mid[2] + rm * 0.55 - j * 1.0, A.base, ramp.base, ramp.shade, ramp.hi) end end
          elseif slug == "emerald-python" then   -- white-rimmed saddles
            local sm = g:E(mid[1], mid[2] + rm * 0.35, rm * 0.55, rm * 0.4); sm:clip(m)
            g:over(sm, A.hi, ramp.base, ramp.shade, ramp.hi); local si = sm:shrink(1); g:over(si, A.base, A.hi)
          else   -- diamonds down the back
            local dm = g:P({ { mid[1] - rm * 0.7, mid[2] + rm * 0.35 }, { mid[1], mid[2] + rm * 0.9 }, { mid[1] + rm * 0.7, mid[2] + rm * 0.35 }, { mid[1], mid[2] - rm * 0.2 } }); dm:clip(m)
            g:over(dm, A.base, ramp.base, ramp.shade, ramp.hi); dm:each(function(x, y) if not dm:has(x, y - 1) then L.inside(c, x, y, A.hi, A.base) elseif not dm:has(x, y + 1) then L.inside(c, x, y, A.deep, A.base) end end)
          end
        elseif fishy then   -- cross bars from the back down the flank
          for i = -1, 1 do local bx = mid[1] + i * 3.2; for j = 0, 3 do
            g:inside(bx + (i == 0 and 0 or 0.4), mid[2] + rm * 0.7 - j * 1.0, A.base, ramp.base, ramp.shade, ramp.hi)
            g:inside(bx + 0.5, mid[2] + rm * 0.7 - j * 1.0, A.base, ramp.base, ramp.shade, ramp.hi) end end
        end
      end
      if f.spots and kind ~= "snake" then
        if slug == "desert-gila-dragon" then g:spots(m, { hex = A.base, ring = A.shade, r = 1, step = 4, inset = 2 })
        elseif slug == "cistern-newt" then g:spots(m, { hex = A.base, r = 1.5, step = 5, inset = 2 })
        else g:spots(m, { hex = A.shade, ring = A.base, r = 1.5, step = 6, inset = 2 }) end
      end
      -- armour plates for the wyrm: a row of ridge spikes along the back and ring seams
      if kind == "wyrm" then
        local tx, ty = g:x(mid[1] - 1), g:y(mid[2] + rm - 0.5)
        local sp = HP.poly({ { tx - 2, ty + 2 }, { tx + 3, ty + 2 }, { tx + 0.5, ty - 3 } }); g:form(sp, A, { frac = 0.4, off = 1, inner = false })
      end
      -- fins along the back
      if (kind == "eel" and k >= 2) or (kind == "fish" and ((slug == "bog-pike" and (k == 2 or k == 3)) or (slug == "silverfin" and (k == 4 or k == 5)))) or (kind == "loach" and (k == 3 or k == 4)) then
        local h = kind == "eel" and (slug == "reef-leviathan" and 4.2 or 3) or (slug == "silverfin" and 7.5 or (kind == "loach" and 2.8 or 5))
        local a0, b0, a1, b1 = p0[1], p0[2] + r0 * 0.7, p1[1], p1[2] + r1 * 0.7
        fin({ { a0, b0 }, { a0 + 0.6, b0 + h * 0.8 }, { (a0 + a1) / 2, b0 + h + (b1 - b0) * 0.5 }, { a1 - 0.8, b1 + h * 0.8 }, { a1 + 0.5, b1 } }, A,
          { { { a0 + 0.8, b0 + 1 }, { a0 + 0.8, b0 + h * 0.7 } }, { { (a0 + a1) / 2, b0 + 1 }, { (a0 + a1) / 2, b0 + h * 0.9 + (b1 - b0) * 0.5 } }, { { a1 - 0.8, b1 + 1 }, { a1 - 0.8, b1 + h * 0.7 } } })
      end
      if q.barnacles and k == 3 then   -- little cones of barnacles
        for i, o in ipairs({ { -2, 1 }, { 1, 1.6 }, { 3.4, 0.8 } }) do
          local bx, by = g:x(mid[1] + o[1]), g:y(mid[2] + rm * 0.6 + o[2] * 0.2)
          c:fillMask(HP.poly({ { bx - 2, by + 2 }, { bx + 2, by + 2 }, { bx + 1, by - 1 }, { bx - 1, by - 1 } }), P.cream); c:put(bx, by - 1, P.ink); c:put(bx + 1, by + 1, P.stone.shade); c:put(bx - 1, by + 1, P.stone.hi)
        end
      end
      if q.ring and k == 4 then   -- a gold ring around the body
        local jx = g:x(mid[1])
        m:each(function(x, y) if x == jx or x == jx + 1 then c:put(x, y, x == jx and P.gold.hi or P.gold.base) end end)
        m:each(function(x, y) if x == jx + 2 and not m:has(x, y + 1) then c:put(x, y, P.gold.shade) end end)
      end
      if q.moss and k == 4 then   -- a tuft of moss on its back
        local px, py = g:x(mid[1]), g:y(mid[2] + rm)
        for _, d in ipairs({ { -3, 0 }, { -1, -1 }, { 1, 0 }, { 3, 1 } }) do local mm = HP.ellipse(px + d[1], py + d[2], 1.6, 1.6); g:form(mm, L.R.moss, { frac = 0.3, off = 1, inner = false }) end
      end
      if kind == "lizard" or kind == "gharial" then
        if k == 3 then g:T("s3") end
      end
      if S.legs and (k == 3 or k == 5) then   -- hind leg on s3, front leg on s5: the far one peeks out in front of the near one
        local a0, b0 = mid[1] - 0.5, max(3.2, mid[2] - rm * 0.5)
        local far = L.darker(ramp)
        -- legs go on top of the body but under nothing else
        leg(a0, b0, far, true); leg(a0, b0, ramp, false)
      end
    end

    ---------------------------------------------------------------- the hood / frill / dorsal fan (behind the head)
    if f.hood then
      g:T("hood")
      if kind == "snake" then   -- a cobra hood with a spectacle mark
        local hm = g:E(hx - 4.6, hb - 3.4, 7.8, 11.4)
        g:form(hm, A, { frac = 0.3, offu = 3 }); g:under(hm, A.deep); g:toplight(hm, A)
        for i = 0, 4 do g:inside(hx - 9 + i * 0.1 + (i % 2) * 0.1, hb - 9 + i * 3.2, A.shade, A.base, A.hi) end
        g:fur(hm, A, 1.0)
        local sx, sy = g:x(hx - 5.2), g:y(hb - 4)
        for _, d in ipairs({ { -3, -1 }, { -3, 0 }, { -2, -2 }, { -1, -2 }, { 0, -1 }, { 0, 0 }, { -2, 1 }, { -1, 1 } }) do c:put(sx + d[1], sy + d[2], P.cream) end
        c:put(sx - 2, sy - 1, P.ink); c:put(sx - 1, sy - 1, P.ink); c:put(sx - 2, sy, P.ink); c:put(sx - 1, sy, P.ink)
      elseif kind == "wyrm" then   -- a spiked frill
        local pts = {}
        for i = 0, 6 do
          local ang = math.pi * (0.55 + i * 0.13); local r = (i % 2 == 0) and 15 or 10.5
          pts[#pts + 1] = { hx - 3 + math.cos(ang) * r * 0.85, hb - 1 + math.sin(ang) * r }
        end
        pts[#pts + 1] = { hx + 1, hb - 5 }; pts[#pts + 1] = { hx + 1, hb + 4 }
        local fm = g:P(pts); fm:add(g:E(hx - 3, hb - 1, 6, 8)); g:form(fm, A, { frac = 0.3, offu = 2.5 }); g:under(fm, A.deep)
        for i = 0, 3 do g:mark({ { hx - 2, hb - 1 }, { hx - 2 + math.cos(math.pi * (0.62 + i * 0.26)) * 11, hb - 1 + math.sin(math.pi * (0.62 + i * 0.26)) * 11 } }, A.shade, A.base, A.hi) end
      else   -- a fan fin behind the head (fish and eel boss)
        local big = slug == "reef-leviathan" or slug == "silverfin"
        local h = big and 12 or 8
        local fm = g:P({ { hx - 1, hb + 3 }, { hx - 3, hb + h * 0.8 }, { hx - 7, hb + h }, { hx - 8.5, hb + h * 0.45 }, { hx - 11, hb + h * 0.7 }, { hx - 11.5, hb - 1 }, { hx - 8, hb - 6 }, { hx - 2, hb - 3 } })
        g:form(fm, A, { frac = 0.3, offu = 2.5 }); g:under(fm, A.deep)
        for i = 0, 3 do g:mark({ { hx - 3, hb + 1 }, { hx - 4 - i * 2.4, hb + h * (0.95 - i * 0.12) } }, A.shade, A.base, A.hi) end
        g:mark({ { hx - 3, hb }, { hx - 11, hb - 1 } }, A.shade, A.base, A.hi)
      end
      if q.pearls and kind == "snake" then   -- a necklace of pearls across the hood
        for i = 0, 5 do local a = hx - 11 + i * 2.4; local b = hb - 12 + 1.3 * ((i - 2.5) ^ 2) * 0.18 + 2.4
          local px, py = g:x(a), g:y(b + 3.4); c:put(px, py, P.cream); c:put(px + 1, py, P.cream); c:put(px, py + 1, P.stone.base); c:put(px + 1, py + 1, P.stone.base) end
      end
    end

    ---------------------------------------------------------------- the head
    g:T("head")
    local hrx, hry = 7.4, 5.4
    local head, snoutM
    local mouthY = hb - hry * 0.35
    local snoutLen = 0
    if kind == "snake" then hrx, hry = 7.6, 5.2
    elseif kind == "lizard" then hrx, hry = 6.6, 4.8; snoutLen = (slug == "spice-monitor") and 7 or (slug == "sun-lizard" and 5 or (slug == "desert-gila-dragon" and 3.5 or 3)); if slug == "cistern-newt" then hrx, hry = 6.4, 5.2 end
    elseif kind == "gharial" then hrx, hry = 5.0, 4.3; snoutLen = 16
    elseif kind == "fish" then hrx, hry = slug == "silverfin" and 8.6 or 7.2, slug == "silverfin" and 7 or 5.2; snoutLen = slug == "bog-pike" and 8 or 2
    elseif kind == "loach" then hrx, hry = 6.4, 4.6
    elseif kind == "eel" then hrx, hry = slug == "reef-leviathan" and 8.4 or 7, slug == "reef-leviathan" and 6.4 or 5; snoutLen = 2
    elseif kind == "wyrm" then hrx, hry = 8.2, 7.2; snoutLen = 2 end
    head = g:E(hx, hb, hrx, hry)
    if snoutLen > 0 then
      local sh = (kind == "gharial") and 1.8 or hry * 0.72
      local sm = g:Limb({ { hx + hrx * 0.4, hb - hry * 0.12 }, { hx + hrx * 0.4 + snoutLen, hb - hry * 0.2 } }, sh * 2, sh * (kind == "gharial" and 1.5 or 1.7))
      head:add(sm)
      if kind == "gharial" then head:add(g:E(hx + hrx * 0.4 + snoutLen + 0.2, hb + 0.4, 2.1, 1.9)) end   -- the knob on the snout tip
    end
    if kind == "gharial" then   -- eyes sit on bumps on top of the skull
      head:add(g:E(hx + 1, hb + hry - 0.6, 2.8, 2.4))
    end
    if kind == "snake" and slug == "dust-sidewinder" then   -- a little horn over the eye
      local hm = g:P({ { hx + 0.5, hb + hry - 0.5 }, { hx + 3, hb + hry + 3.4 }, { hx + 3.8, hb + hry - 1 } }); head:add(hm)
    end
    local hr = B
    g:form(head, hr, { frac = 0.14, offu = 3 })
    head:each(function(x, y) if not head:has(x, y + 2) and head:has(x, y - 2) then L.inside(c, x, y, belly.base, hr.base, hr.shade) end end)   -- pale chin
    head:each(function(x, y) if not head:has(x, y + 3) and head:has(x, y + 2) then L.inside(c, x, y, hr.shade, hr.base) end end)
    g:under(head, belly.deep or hr.deep); g:toplight(head, hr)
    g:fur(head, hr, 0.8)
    if kind == "wyrm" then   -- a heavy brow plate and jaw plates
      for i = 0, 3 do g:mark({ { hx - 5 + i * 3, hb + hry - 0.5 }, { hx - 4 + i * 3, hb + hry - 3.5 } }, hr.deep, hr.base, hr.hi, hr.shade) end
      local pl = g:RR(hx - 3, hb + hry * 0.2, hx + 5.5, hb + hry * 0.9, 1.4); g:over(pl, A.base, hr.base, hr.hi, hr.shade)
    end
    if kind == "lizard" and slug == "desert-gila-dragon" then g:spots(head, { hex = A.base, ring = A.shade, r = 1, step = 4, inset = 2 }) end
    if kind == "lizard" and slug == "cistern-newt" then for i = 0, 2 do g:inside(hx - 3 + i * 2.5, hb + hry * 0.6, A.base, hr.base, hr.hi) end end
    -- nostril
    local nx = hx + hrx * 0.4 + snoutLen + (kind == "gharial" and 1.6 or hrx * 0.45)
    local ny = (kind == "gharial") and hb + 0.7 or hb + hry * 0.1
    g:put(nx - 0.5, ny, hr.deep)

    -- the mouth line and the teeth
    local mx0, mx1 = hx - hrx * 0.1, hx + hrx * 0.4 + snoutLen + hrx * 0.55
    if kind == "gharial" then mx1 = hx + hrx * 0.4 + snoutLen + 2.4 end
    local my = hb - hry * 0.38
    if kind == "gharial" then my = hb - 1.0 end
    local mouth = { { mx0 - 1, my + 1.4 }, { mx0 + 2, my + 0.1 }, { (mx0 + mx1) / 2, my - 0.3 }, { mx1 - 1, my - 0.1 } }
    if fishy and kind ~= "loach" then mouth = { { mx0 - 1, my + 0.2 }, { (mx0 + mx1) / 2, my - 0.5 }, { mx1 - 0.4, my + 0.4 } } end
    if kind == "wyrm" then mouth = { { mx0 - 3, my + 1.2 }, { mx0, my - 0.6 }, { mx1 - 0.5, my - 0.2 } } end
    g:stroke(mouth, hr.deep)
    local function teeth(a0, a1, bm, n)
      for i = 0, n do
        local a = a0 + (a1 - a0) * i / n; local tx, ty = g:x(a), g:y(bm)
        if i % 2 == 0 or kind == "gharial" then c:put(tx, ty + 1, P.cream); if kind == "wyrm" or kind == "eel" then c:put(tx, ty + 2, P.cream) end end
      end
    end
    if kind == "gharial" then teeth(hx + hrx * 0.4 + 1, mx1 - 1, my, 11)
    elseif slug == "bog-pike" or kind == "eel" then teeth(mx0 + 2, mx1 - 1.4, my, 5)
    elseif kind == "wyrm" then teeth(mx0 - 1, mx1 - 1, my - 0.3, 5)
    elseif kind == "snake" then   -- a fang
      local tx, ty = g:x(mx1 - 3.2), g:y(my); c:put(tx, ty + 1, P.cream); c:put(tx, ty + 2, P.cream) end
    -- tongue
    if kind == "snake" or slug == "spice-monitor" then
      local tx, ty = g:x(mx1), g:y(my)
      for i = 1, 5 do c:put(tx + i, ty - (i > 3 and 0 or 0), P.petal.base) end
      c:put(tx + 6, ty - 1, P.petal.base); c:put(tx + 6, ty + 1, P.petal.base); c:put(tx + 5, ty, P.petal.shade)
      if q.pepper then for i = 1, 5 do c:put(tx + i, ty, nil or P.petal.base) end end
    end
    -- gill cover and pectoral fin on fish
    if fishy then
      g:stroke({ { hx - 1.2, hb + hry * 0.72 }, { hx - 3.3, hb + hry * 0.2 }, { hx - 3.3, hb - hry * 0.4 }, { hx - 1.6, hb - hry * 0.8 } }, hr.deep)
      for i = 0, 2 do g:put(hx - 4.2 + i * 0.1, hb + hry * 0.3 - i * 1.3, hr.shade) end
      local pf = g:P({ { hx - 2.2, hb - hry * 0.35 }, { hx - 8, hb - hry * 0.9 - 2.6 }, { hx - 5, hb - hry * 0.2 - 1 } })
      pf:cut(g:E(hx - 1, hb, hrx, hry):shrink(0)); g:form(pf, A, { frac = 0.3, off = 1, inner = false })
    end
    if kind == "loach" then   -- barbels
      for i = 0, 2 do local bm = g:Limb({ { hx + hrx * 0.7, hb - hry * 0.3 - i * 0.4 }, { hx + hrx * 0.7 + 2.8, hb - hry * 0.7 - i * 1.5 }, { hx + hrx * 0.7 + 4.6, hb - hry * 0.4 - i * 2.6 } }, 1.0, 0.8); g:form(bm, i == 1 and hr or DK, { frac = 0.5, off = 1, inner = false }) end
    end
    -- lizard / gharial brow ridge and cheek
    if kind == "lizard" or kind == "gharial" then g:dots({ { hx + 2, hb + hry * 0.6 } }, hr.shade) end

    -- quirks on the head
    if q.flower then   -- a daisy behind the eye
      local px, py = g:x(hx - 3.6), g:y(hb + hry - 0.8)
      for _, d in ipairs({ { 0, -2 }, { 0, 2 }, { -2, 0 }, { 2, 0 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do c:put(px + d[1], py + d[2], P.cream) end
      c:put(px, py, P.gold.base); c:put(px + 1, py + 1, P.gold.shade); c:put(px + 3, py + 1, P.cream)
      c:fillMask(HP.rect(px + 2, py - 1, px + 3, py), P.cream); c:put(px + 3, py, P.gold.base) c:put(px + 2, py, P.gold.base)
    end
    if q.shades then   -- sunglasses pushed up on the forehead
      local px, py = g:x(hx - 0.5), g:y(hb + hry - 1.4)
      c:fillMask(HP.rect(px - 4, py - 2, px - 1, py), P.ink); c:fillMask(HP.rect(px + 1, py - 2, px + 4, py), P.ink); c:put(px, py - 1, P.ink)
      c:put(px - 4, py - 2, P.sky.base); c:put(px + 1, py - 2, P.sky.base); c:put(px - 4, py - 3, P.ink)
    end
    if q.pepper then   -- a chili pepper clenched in its teeth
      local tx, ty = g:x(mx1 - 3), g:y(my)
      c:fillMask(HP.poly({ { tx - 3, ty }, { tx + 9, ty - 2 }, { tx + 9, ty + 1 }, { tx - 3, ty + 3 } }), P.ember.base)
      c:fillMask(HP.rect(tx + 4, ty + 1, tx + 8, ty + 1), P.ember.shade); c:put(tx - 2, ty, P.ember.hi); c:put(tx + 9, ty - 1, P.moss.base); c:put(tx + 10, ty - 2, P.moss.base); c:put(tx + 10, ty - 1, P.moss.shade)
    end
    if q.scar then   -- a stitched scar across the snout
      local sx, sy = g:x(hx + hrx * 0.4 + snoutLen * 0.5 + 1), g:y(hb + hry * 0.1)
      for i = -3, 3 do c:put(sx + i // 2, sy + i, P.cream) end
      for i = -2, 2, 2 do c:put(sx - 1 + i // 2, sy + i, P.stone.shade); c:put(sx + 1 + i // 2, sy + i, P.stone.shade) end
    end
    if q.bird then   -- a little yellow bird perched on the snout
      local bx, by = g:x(hx + hrx * 0.4 + snoutLen - 0.5), g:y(hb + 1.8)
      c:fillMask(HP.ellipse(bx, by - 3, 3, 2.6), P.gold.base); c:put(bx - 2, by - 5, P.gold.hi); c:put(bx - 1, by - 5, P.gold.hi); c:put(bx + 2, by - 3, P.ember.base); c:put(bx + 3, by - 3, P.ember.base)
      c:put(bx + 1, by - 4, P.ink); c:put(bx - 2, by - 2, P.gold.shade); c:put(bx - 1, by - 1, P.gold.shade); c:put(bx - 3, by - 3, P.gold.shade); c:put(bx - 1, by, P.ember.shade); c:put(bx + 1, by, P.ember.shade)
    end
    if q.hook then   -- a fishing hook and a line caught in the lip
      local tx, ty = g:x(mx1 - 1), g:y(my)
      for i = 1, 16 do c:put(tx + (i // 5), ty - i, P.stone.hi) end
      c:fillMask(HP.rect(tx - 1, ty, tx - 1, ty + 3), P.gold.base); c:put(tx - 2, ty + 3, P.gold.base); c:put(tx - 3, ty + 2, P.gold.base)
    end
    if q.worm then   -- a pink worm snack hanging from its mouth
      local tx, ty = g:x(mx1 - 2), g:y(my)
      for i = 0, 6 do c:put(tx + (i % 3 == 1 and 1 or 0), ty + i, i % 2 == 0 and P.petal.base or P.petal.hi) end
      c:put(tx + 1, ty + 7, P.petal.shade)
    end
    if q.crown then   -- a coral crown
      local px, py = g:x(hx - 1), g:y(hb + hry - 0.8)
      c:fillMask(HP.rect(px - 4, py - 3, px + 4, py), P.ember.base); c:fillMask(HP.rect(px - 4, py - 1, px + 4, py), P.ember.shade)
      for _, d in ipairs({ -4, -1, 2, 4 }) do c:fillMask(HP.rect(px + d - 1, py - 6, px + d, py - 3), P.ember.base); c:put(px + d, py - 7, P.gold.hi) end
      c:put(px - 2, py - 2, P.gold.hi); c:put(px + 2, py - 2, P.gold.hi); c:put(px, py - 2, P.sky.hi)
    end
    if q.monocle then   -- a gold monocle on a chain around the eye
      local ex, ey = g:x(hx + 3), g:y(hb + 1.5)
      for _, d in ipairs({ { -3, -1 }, { -3, 0 }, { -3, 1 }, { 3, -1 }, { 3, 0 }, { 3, 1 }, { -2, -2 }, { -1, -3 }, { 0, -3 }, { 1, -3 }, { 2, -2 }, { -2, 2 }, { -1, 3 }, { 0, 3 }, { 1, 3 }, { 2, 2 } }) do c:put(ex + d[1] + 1, ey + d[2], P.gold.base) end
      for i = 1, 5 do c:put(ex + 1 + i % 2, ey + 3 + i, P.gold.hi) end
    end
    if q.bone then   -- a bone caught between the teeth
      local tx, ty = g:x(mx1 - 4), g:y(my)
      c:fillMask(HP.rect(tx - 2, ty + 1, tx + 9, ty + 2), P.cream); c:fillMask(HP.rect(tx - 3, ty, tx - 2, ty + 3), P.cream); c:fillMask(HP.rect(tx + 9, ty, tx + 10, ty + 3), P.cream); c:put(tx + 2, ty + 2, P.stone.base); c:put(tx + 6, ty + 2, P.stone.base)
    end

    ---------------------------------------------------------------- the face
    g:T("eyes")
    local ex, ey = hx + hrx * 0.35, hb + hry * 0.3
    if kind == "gharial" then ex, ey = hx + 1.8, hb + hry + 0.6 end
    if kind == "fish" and slug == "silverfin" then ex, ey = hx + 3.4, hb + hry * 0.3 end
    g:eye(ex, ey)
    g:T("head")
    -- brow
    if kind == "lizard" or kind == "wyrm" then g:stroke({ { ex - 2.5, ey + 2.8 }, { ex + 2.6, ey + 3.6 } }, hr.deep) end
    if slug ~= "stone-loach" and kind ~= "gharial" then g:dots({ { ex - 2.6, ey - 3 } }, P.petal.base) end   -- cheek

    ---------------------------------------------------------------- bones
    local bones = {}
    bones[1] = { "s1", false, C[2][1], C[2][2] }
    for k = 2, 6 do bones[#bones + 1] = { "s" .. k, "s" .. (k - 1), C[k][1], C[k][2] } end
    bones[#bones + 1] = { "head", "s6", C[7][1], C[7][2] - 1 }
    if f.hood then bones[#bones + 1] = { "hood", "head", hx - 4, hb - 3, true } end
    bones[#bones + 1] = { "eyes", "head", ex + 0.5, ey }
    return bones
  end
end
