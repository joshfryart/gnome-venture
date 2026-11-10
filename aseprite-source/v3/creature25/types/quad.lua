-- quad: four-legged animals, side view, facing RIGHT. Parts: legBF, legFF (far legs), tail, body, legBN, legFN (near legs), [mane], head, eyes (+ leaf, puff: quirk parts).
-- Kinds (spec feat.kind): canid, feline, rodent, bear, ungulate, hare. Spec features: tail, stripes, spots, mane, spikes, horns (true | "curl"), antlers, tusks, snout, nohear.
-- The accent colour is the pale belly / chest / tail tip, unless a feature claims it (spots, spikes, mane, horns, antlers, tusks, and the pale stripes of the badger kind).
-- quirks/quad.lua, per slug:
--   look = { ...any K field..., tail = "plume|brush|long|thin|stub|ring|paddle|curl|bob|fluff|pom|none", ears = "point|cat|tuft|round|leaf|long|none",
--            nose = "pink|dark", mask = true (dark eye mask), blaze = true (pale stripe up the face), mantle = true (pale back), bristles = true, digger = true (big claws), quills = true }
--   quirk = "notch|plaster|leaf|scar|flower|ring|mud|tooth|scarf|sock|kink|burr|snack|snow|bell|bow|feather|patch|freckles|moss|sprig", puff = true (snorts)
return function(L)
  local P, HP = L.P, L.HP
  local CREAM, W, PT, INK = L.R.cream, P.wood, P.petal, P.ink
  local DARK = "#51302b"
  local floor, max, min, sin, cos, pi = math.floor, math.max, math.min, math.sin, math.cos, math.pi
  -- proportions per kind, in figure units: body centre and radii, leg height and width, head centre and radii, snout length and half-height
  local K = {
    canid    = { bx = -2, by = 16.0, brx = 12.5, bry = 6.4, legh = 11.5, legw = 4.0, hx = 14.0, hy = 23.0, hrx = 6.8, hry = 6.4, sn = 5.6, snh = 2.5, neck = true, tuck = true, tail = "brush", ears = "point", nose = "dark" },
    feline   = { bx = -2, by = 14.0, brx = 14.0, bry = 6.4, legh = 9.6, legw = 4.4, hx = 14.5, hy = 20.0, hrx = 7.6, hry = 7.0, sn = 2.2, snh = 2.3, neck = true, tuck = true, tail = "long", ears = "cat", nose = "pink" },
    rodent   = { bx = -2, by = 11.0, brx = 11.0, bry = 7.8, legh = 6.0, legw = 4.2, hx = 11.0, hy = 15.0, hrx = 7.4, hry = 6.8, sn = 2.6, snh = 2.4, tail = "thin", ears = "round", nose = "pink" },
    bear     = { bx = -2, by = 13.5, brx = 14.0, bry = 8.4, legh = 8.6, legw = 5.6, hx = 12.5, hy = 14.5, hrx = 7.2, hry = 6.8, sn = 5.0, snh = 3.2, tail = "stub", ears = "round", nose = "dark" },
    ungulate = { bx = -2, by = 17.5, brx = 13.5, bry = 7.8, legh = 12.5, legw = 4.0, hx = 14.5, hy = 24.0, hrx = 6.4, hry = 6.6, sn = 5.2, snh = 3.2, neck = true, tail = "stub", ears = "leaf", nose = "dark" },
    hare     = { bx = -3, by = 11.0, brx = 10.5, bry = 8.4, legh = 6.0, legw = 4.4, hx = 9.5, hy = 17.0, hrx = 6.4, hry = 6.2, sn = 2.4, snh = 2.5, tail = "pom", ears = "long", nose = "pink" },
  }
  return function(g)
    local c, f, q, B, A, D = g.c, g.f, g.q, g.B, g.A, g.D
    local kd = f.kind or "bear"
    local k = setmetatable({}, { __index = K[kd] }); for key, v in pairs(q.look or {}) do k[key] = v end
    if f.tail and kd == "canid" and not (q.look and q.look.tail) then k.tail = "plume" end
    if f.tail and kd == "bear" and not (q.look and q.look.tail) then k.tail = "fluff" end
    if f.snout then k.sn = k.sn + 3 end
    local claimed = f.spots or f.spikes or f.mane or f.horns or f.antlers or f.tusks or (f.stripes and kd == "bear")
    local function lum(r) local h = r.base; return tonumber(h:sub(2, 3), 16) * 0.3 + tonumber(h:sub(4, 5), 16) * 0.59 + tonumber(h:sub(6, 7), 16) * 0.11 end
    local isPale = A == L.R.cream or A == L.R.white or A == L.R.tan or A == L.R.mint or A == L.R.butter or A == L.R.sky or A == L.R.sand
    local PALE = (not claimed and isPale and lum(A) > lum(B) + 12) and A or L.lighter(B)       -- belly, chest, tail tip
    local big = g.u >= 1.4
    local hoof = kd == "ungulate" or k.hoof
    local QK = {}                                                  -- the quirks of this creature as a set (q.quirk is a name or a list of names)
    if type(q.quirk) == "table" then for _, n in ipairs(q.quirk) do QK[n] = true end elseif q.quirk then QK[q.quirk] = true end
    local furry = kd ~= "ungulate" and not k.smooth
    local SOCK = k.socks and (type(k.socks) == "string" and L.R[k.socks] or PALE) or nil
    -- fur points along the top (and belly) edge of a mask, so the silhouette is not a smooth egg
    local function furEdge(m, r, o)
      o = o or {}
      local x0, y0, x1, y1 = m:bbox(); if not x0 then return end
      local step = o.step or 3
      for x = x0 + 1, x1 - 1 do
        if (x + floor(g:rnd(x, 9) * 2)) % step == 0 then
          for y = y0, y1 do if m:has(x, y) then
            if o.top ~= false and not m:has(x, y - 1) and not c:get(x, y - 1) then
              c:put(x, y - 1, r.base) if big and g:rnd(x, 4) > 0.45 and not c:get(x, y - 2) then c:put(x, y - 2, r.hi) end
            end break end end
          if o.bottom then for y = y1, y0, -1 do if m:has(x, y) then if not m:has(x, y + 1) and not c:get(x, y + 1) and g:rnd(x, 5) > 0.35 then c:put(x, y + 1, r.shade) end break end end end
        end
      end
    end
    g:shadow(k.bx + 2, k.brx + 7)

    ------------------------------------------------------------------ legs
    local function leg(id, lx, r, back, near)
      g:T(id)
      local h, w = k.legh, k.legw
      local m
      if back and kd ~= "bear" and kd ~= "rodent" then   -- a bent back leg: thigh, hock, shank
        m = g:Limb({ { lx, h + 2 }, { lx - 1.6, h * 0.5 }, { lx + 0.2, 1.8 } }, w + 2.2, w * 0.62)
      else
        m = g:Limb({ { lx, h + 2 }, { lx + 0.3, 1.8 } }, w + (back and 1 or 0), w * 0.78)
      end
      local ft
      if hoof then ft = g:R(lx - w * 0.42, 2.2, lx + w * 0.42 + 0.6, 0) else ft = g:E(lx + 1.0, 1.25, w * 0.5 + 0.9, 1.35) end
      m:add(ft)
      g:form(m, r, { frac = 0.34, off = 1 })
      if hoof then
        g:fill(ft, DARK); g:put(lx - w * 0.3, 2.0, W.shade)                                        -- a cloven hoof with a dull shine
      else
        g:under(ft, r.deep)
        g:put(lx + 0.6, 0.6, r.deep) g:put(lx + 2.0, 0.6, r.deep)                                    -- toes
        if k.digger and not back then g:stroke({ { lx + 1.6, 1.4 }, { lx + 3.6, 0.4 } }, P.cream) g:stroke({ { lx + 0.4, 0.9 }, { lx + 2.6, 0.1 } }, P.cream) end   -- digging claws
      end
      g:mark({ { lx - w * 0.5, h * 0.52 }, { lx + w * 0.5, h * 0.52 } }, r.shade, r.base)             -- knee crease
      if f.stripes and kd == "feline" then for i = 0, 1 do g:mark({ { lx - w * 0.5, h * (0.75 - i * 0.35) }, { lx + w * 0.2, h * (0.75 - i * 0.35) - 0.7 } }, DARK, r.base, r.shade) end end
      if near and q.quirk == "mud" then for i = 1, 4 do g:inside(lx - 1 + g:rnd(i, lx) * 2.5, 2.4 + g:rnd(lx, i) * 2.6, W.deep, r.base, r.shade) end end
      if near and not back and q.quirk == "sock" then m:each(function(x, y) if y > g:y(h * 0.42) and c:get(x, y) ~= DARK then L.inside(c, x, y, CREAM.base, r.base) L.inside(c, x, y, CREAM.shade, r.shade) end end) end
    end
    local backA, frontA = k.bx - k.brx * 0.74, k.bx + k.brx * 0.62
    leg("legBF", backA + 3.6, D, true) leg("legFF", frontA + 3.4, D, false)

    ------------------------------------------------------------------ tail
    g:T("tail")
    local tx, ty = k.bx - k.brx - 0.5, k.by + 1.5
    local tk = k.tail
    if tk == "plume" or tk == "ring" or tk == "fluff" then        -- a bushy tail, carried up and back
      local m = g:Limb({ { tx + 2, ty }, { tx - 4, ty + 1.5 }, { tx - 8.5, ty + 5.5 }, { tx - 10, ty + 11 } }, 3.6, tk == "fluff" and 8 or 6.6)
      g:form(m, tk == "plume" and (claimed and B or B) or B, { frac = 0.3 }) g:under(m, B.deep) g:fur(m, B, 1.2)
      if tk == "ring" then for i = 0, 3 do g:over(g:Ln({ { tx - 2.5 - i * 2.2, ty - 3 + i * 2.6 }, { tx - 0.5 - i * 2.6, ty + 5 + i * 2.6 } }, 1.3), A.shade, B.base, B.shade, B.hi) end
      elseif tk == "plume" then local tip = g:E(tx - 10, ty + 11.5, 4.6, 4.2); tip:clip(m); g:over(tip, PALE.base, B.base, B.hi) g:over(tip, PALE.shade, B.shade, B.deep) end
    elseif tk == "brush" then                                     -- a shorter tail, hanging
      local m = g:Limb({ { tx + 2, ty }, { tx - 3, ty - 1 }, { tx - 6.5, ty - 5.5 } }, 3.4, 3.0)
      g:form(m, B, { frac = 0.3 }) g:under(m, B.deep) g:put(tx - 6.5, ty - 6.5, B.deep)
    elseif tk == "long" then                                      -- a long tail in an S, with a tip
      local m = g:Limb({ { tx + 2, ty - 1 }, { tx - 5, ty - 2 }, { tx - 9, ty + 3 }, { tx - 8, ty + 9 }, { tx - 11, ty + 12 } }, 3.0, 2.2)
      g:form(m, B, { frac = 0.3, off = 1 })
      if f.stripes or f.spots then for i = 0, 3 do g:over(g:E(tx - 6.5 - (i % 2) * 2, ty + 1 + i * 3, 2.4, 0.8), f.stripes and DARK or A.base, B.base, B.shade) end end
      local tip = g:E(tx - 11, ty + 12, 2.2, 2.2); tip:clip(m); g:over(tip, f.stripes and DARK or PALE.base, B.base, B.shade, B.hi)
    elseif tk == "thin" then                                      -- a bare rat tail
      local m = g:Limb({ { tx + 2, ty - 2 }, { tx - 5, ty - 4 }, { tx - 9, ty - 1 }, { tx - 11, ty + 4 } }, 1.9, 1.1)
      g:form(m, PT, { noshade = true }) m:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, PT.shade) end end)
    elseif tk == "paddle" then                                    -- a beaver's flat scaly paddle
      local m = g:E(tx - 5.5, ty - 5, 7, 3.2)
      g:form(m, L.R.bark, { frac = 0.3 }) g:under(m, P.ink)
      m:shrink(1):each(function(x, y) if (x + y) % 4 == 0 or (x - y) % 4 == 0 then L.inside(c, x, y, L.R.bark.shade, L.R.bark.base) end end)
    elseif tk == "curl" then                                      -- a thin curled tail with a dark tuft
      local m = g:Limb({ { tx + 2, ty + 1 }, { tx - 1.5, ty + 2.5 }, { tx - 3, ty + 5.5 }, { tx - 1.5, ty + 7.5 } }, 1.7, 1.4)
      g:form(m, B, { noshade = true }) local t = g:E(tx - 1, ty + 8.5, 1.6, 1.6); g:fill(t, B.deep) g:put(tx - 1.6, ty + 9, B.shade)
    elseif tk == "bob" then                                       -- a bobbed tail with a black tip
      local m = g:Limb({ { tx + 2, ty }, { tx - 2.5, ty + 1.5 } }, 3.4, 3.0)
      g:form(m, B, { frac = 0.3 }) local t = g:E(tx - 3, ty + 1.6, 1.7, 1.7); t:clip(m); g:fill(t, DARK)
    elseif tk == "otter" then                                     -- a thick tapering rudder, low
      local m = g:Limb({ { tx + 2, ty - 2 }, { tx - 5, ty - 5 }, { tx - 11, ty - 6.5 } }, 4.6, 1.8)
      g:form(m, B, { frac = 0.3, off = 1 }) g:under(m, B.deep)
    elseif tk == "pom" then                                       -- a cotton tail
      local m = g:E(tx - 0.5, ty - 1, 3.2, 3.0); g:form(m, L.R.white, { frac = 0.3, off = 1 }) g:under(m, L.R.white.shade)
    elseif tk ~= "none" then                                      -- a stub
      local m = g:P({ { tx + 3, ty + 2 }, { tx - 3.5, ty + 4.5 }, { tx - 1.5, ty - 1.5 }, { tx + 3, ty - 2 } })
      g:form(m, f.tail and A or B, { frac = 0.3, off = 1 })
    end

    ------------------------------------------------------------------ body
    g:T("body")
    local body = g:E(k.bx, k.by, k.brx, k.bry)
    body:add(g:E(k.bx - k.brx * 0.6, k.by - 0.4, k.brx * 0.47, k.bry * 0.92))                       -- haunch
    body:add(g:E(k.bx + k.brx * 0.56, k.by + 0.9, k.brx * 0.52, k.bry * (kd == "bear" and 1.02 or 0.96)))   -- shoulder
    if kd == "hare" or kd == "rodent" then body:add(g:E(k.bx - k.brx * 0.5, k.by + 1.2, k.brx * 0.6, k.bry * 0.95)) end   -- a round rump
    if k.tuck then body:cut(g:E(k.bx - k.brx * 0.08, k.by - k.bry - 1.6, k.brx * 0.42, 2.6)) end                           -- the belly tucks up toward the hips
    if k.neck then body:add(g:Limb({ { k.bx + k.brx * 0.62, k.by + k.bry * 0.2 }, { k.hx - k.hrx * 0.35, k.hy - k.hry * 0.3 } }, k.bry * 1.7, k.hry * 1.45)) end   -- neck
    g:form(body, B, { frac = 0.3, offu = 2.7, pop = { { k.bx - k.brx * 0.95, k.by + k.bry * 0.55 }, { k.bx + k.brx * 0.42, k.by + k.bry * 0.98 } } })
    do   -- pale underside, and a pale chest on the dog kind
      local bel, d = HP.mask(), g:px(k.bry * 0.5)
      local xl, xr = g:x(k.bx - k.brx * 1.0), g:x(k.bx + k.brx * (k.neck and 0.9 or 1.02))
      body:each(function(x, y) if x >= xl and x <= xr and not body:has(x, y + d) then bel:set(x, y) end end)   -- follows the belly line
      if kd == "canid" or kd == "hare" then local ch = g:E(k.bx + k.brx * 0.92, k.by - k.bry * 0.1, k.brx * 0.3, k.bry * 0.9); ch:clip(body); bel:add(ch) end
      g:over(bel, PALE.base, B.base, B.hi) g:over(bel, PALE.shade, B.shade)
    end
    g:under(body, B.deep) g:belly(body, B, 1.6) g:toplight(body, B)
    if k.mantle then   -- honey badger: a pale mantle over the whole back
      local mt = g:E(k.bx, k.by + k.bry * 0.75, k.brx * 1.2, k.bry * 0.62); mt:clip(body)
      g:over(mt, A.base, B.base, B.hi) g:over(mt, A.shade, B.shade) g:toplight(mt, A)
    elseif f.stripes and kd == "bear" and not k.mask then   -- badger kind: a pale stripe along the flank
      local sd = g:Ln({ { k.bx - k.brx * 0.9, k.by + 1 }, { k.bx, k.by + 2.4 }, { k.bx + k.brx * 0.8, k.by + 1.6 } }, 1.6); sd:clip(body)
      g:over(sd, A.base, B.base, B.hi) g:over(sd, A.shade, B.shade)
    end
    g:fur(body, B, big and 1.0 or 0.7)
    if f.stripes and kd == "feline" then g:stripes(body, DARK, { len = g:px(k.bry * 1.05), gap = g:px(3.6) }) end
    if f.stripes and k.mask then for i = 0, 2 do g:over(g:Ln({ { k.bx - 8 + i * 5, k.by + k.bry }, { k.bx - 7 + i * 5, k.by + k.bry * 0.3 } }, 1.2), A.base, B.base, B.hi) end end
    if f.spots then
      if kd == "feline" and big then g:spots(body, { r = 2, step = g:px(5.4), hex = B.hi, ring = A.shade == B.shade and DARK or A.shade })     -- rosettes
      else g:spots(body, { r = big and 1.5 or 1, step = g:px(4.6), hex = A.shade }) end
    end
    if k.bristles or f.spikes or k.quills then   -- a ridge along the spine: bristles (boar), thorns (spikes) or quills
      local r = f.spikes and A or D
      local step = f.spikes and 4.2 or 2.7
      for a = k.bx - k.brx * 0.95, k.bx + k.brx * 0.95, step do
        local x = g:x(a); local y; for yy = g:y(k.by + k.bry * 1.6), g:y(k.by) do if body:has(x, yy) then y = yy break end end
        if y then
          local i = floor((a - k.bx) / step)
          local hh = (f.spikes and 6.2 or 3.4) * (i % 2 == 0 and 1 or 0.72) * g.u
          local wd = (f.spikes and 2.1 or 1.4) * g.u
          local sp = HP.poly({ { x - wd + .5, y + 2.5 }, { x + wd + .5, y + 2.5 }, { x - wd * 0.4 + .5, y - hh + .5 } })
          L.form(c, sp, r, { noshade = not f.spikes, frac = 0.4, off = 1 }) if f.spikes then c:put(x - L.rd(wd * 0.4), y - L.rd(hh) + 1, r.hi) end
        end
      end
    end
    if kd == "bear" and big then for a = k.bx - 8, k.bx + 8, 3.4 do g:put(a, k.by - k.bry - 0.2, B.deep) g:put(a + 0.7, k.by - k.bry - 0.9, B.deep) end end   -- shaggy belly fringe
    -- quirks painted on the body
    local QC = { B.base, B.shade, B.hi, B.deep }
    if q.quirk == "plaster" then   -- a sticking plaster on the rump (two crossed strips)
      local pa, pb = k.bx - k.brx * 0.72, k.by + k.bry * 0.25
      g:over(g:Ln({ { pa - 2, pb + 2 }, { pa + 2, pb - 2 } }, 1.4), CREAM.hi, table.unpack(QC)) g:over(g:Ln({ { pa - 2, pb - 2 }, { pa + 2, pb + 2 } }, 1.4), CREAM.base, table.unpack(QC)) g:put(pa, pb, CREAM.deep)
    elseif q.quirk == "scar" then  -- an old scar on the flank
      local pa, pb = k.bx + 1, k.by + 1
      g:mark({ { pa - 2.5, pb + 2.5 }, { pa + 2.5, pb - 2 } }, PT.shade, table.unpack(QC)) for i = -1, 1 do g:mark({ { pa + i * 1.7 - 0.8, pb - i * 1.5 - 0.8 }, { pa + i * 1.7 + 0.8, pb - i * 1.5 + 0.8 } }, B.deep, table.unpack(QC)) end
    elseif q.quirk == "burr" then  -- burrs stuck in its coat
      for i, d in ipairs({ { -7, 3 }, { -1, -2 }, { 5, 2.5 } }) do local m = g:E(k.bx + d[1], k.by + d[2], 1.2, 1.2); g:over(m, L.R.lime.shade, table.unpack(QC)) g:inside(k.bx + d[1] - 0.5, k.by + d[2] + 0.5, L.R.lime.base, L.R.lime.shade) end
    elseif q.quirk == "snow" then  -- snow settled on its back
      for a = k.bx - k.brx * 0.8, k.bx + k.brx * 0.7, 0.6 do local x = g:x(a); for yy = g:y(k.by + k.bry * 1.6), g:y(k.by) do if body:has(x, yy) then if g:rnd(x, 3) > 0.25 then c:put(x, yy, P.cream) if g:rnd(x, 4) > 0.5 then L.inside(c, x, yy + 1, P.sky.hi, table.unpack(QC)) end end break end end end
    elseif q.quirk == "freckles" then
      for i = 1, 6 do g:inside(k.bx - 9 + g:rnd(i, 1) * 6, k.by + g:rnd(i, 2) * 4, B.deep, B.base) end
    elseif q.quirk == "patch" then -- one flank patch of another colour, heart-shaped
      local pa, pb = k.bx - 4, k.by + 1.5
      local m = g:E(pa - 1.1, pb + 0.8, 1.5, 1.4); m:add(g:E(pa + 1.1, pb + 0.8, 1.5, 1.4)) m:add(g:P({ { pa - 2.6, pb + 0.4 }, { pa + 2.6, pb + 0.4 }, { pa, pb - 2.8 } })) g:over(m, PALE.base, table.unpack(QC))
    end
    if q.quirk == "leaf" then   -- a leaf caught on its back: stalk down in the fur, midrib, lit upper edge
      g:T("leaf") local la, lb = k.bx - k.brx * 0.35, k.by + k.bry * 0.78
      local leaf = g:P({ { la, lb }, { la + 0.6, lb + 3.4 }, { la + 3.4, lb + 6 }, { la + 7.4, lb + 6.6 }, { la + 6.6, lb + 3.4 }, { la + 4, lb + 0.8 } })
      g:form(leaf, P.moss, { frac = 0.3 }) g:under(leaf, P.moss.deep)
      g:stroke({ { la + 1, lb + 1 }, { la + 6.6, lb + 6 } }, P.moss.deep) g:mark({ { la + 1.6, lb + 3.4 }, { la + 4.4, lb + 5.6 } }, P.moss.hi, P.moss.base)
      g:stroke({ { la, lb }, { la - 0.8, lb - 1.6 } }, P.moss.shade)
    end

    ------------------------------------------------------------------ near legs
    leg("legBN", backA, B, true, true) leg("legFN", frontA, B, false, true)

    ------------------------------------------------------------------ mane (yak: a shaggy ruff over neck and shoulders)
    local hx, hy, hrx, hry = k.hx, k.hy, k.hrx, k.hry
    if f.mane then
      g:T("mane")
      local m = g:E(hx - 4.5, hy - 2.5, 8.6, 9.2)
      for i = 0, 5 do local a = hx - 11.5 + i * 2.8; m:add(g:P({ { a - 1.6, hy - 9 }, { a + 1.6, hy - 9 }, { a + (i % 2) - 0.5, hy - 13.2 - (i % 3) } })) end   -- ragged hem
      g:form(m, A, { frac = 0.3, offu = 2.4 }) g:under(m, A.deep) g:fur(m, A, 1.4) g:toplight(m, A)
    end

    ------------------------------------------------------------------ head
    g:T("head")
    local sy = hy - hry * 0.32                                  -- the snout's centre line
    local tipx = hx + hrx + k.sn
    local earR = B
    local function earInner(m, r) local i = m:shrink(big and 2 or 1); i:each(function(x, y) L.inside(c, x, y, PT.shade, r.base, r.shade) end) end
    local function ear(dx, r, far)
      local ex, eb = hx - hrx * 0.42 + dx, hy + hry * 0.62
      local m
      if k.ears == "point" then m = g:P({ { ex - 2.6, eb }, { ex - 1.2, eb + 8.2 }, { ex + 3.4, eb + 0.6 } })
      elseif k.ears == "cat" or k.ears == "tuft" then m = g:P({ { ex - 2.8, eb }, { ex - 1.6, eb + 5.4 }, { ex + 3.0, eb + 0.8 } })
      elseif k.ears == "round" then m = g:E(ex - 0.6, eb + 2.2 + ((k.earr or 2.9) - 2.9), k.earr or 2.9, k.earr or 2.9)
      elseif k.ears == "leaf" then m = g:P({ { ex - 1, eb - 2.4 }, { ex - 7, eb + 1.2 }, { ex - 5.6, eb - 1.6 }, { ex - 1, eb - 4.6 } })
      elseif k.ears == "long" then m = g:Limb({ { ex + 0.6, eb }, { ex - 0.8, eb + 7 }, { ex - 2.2 - (far and -3.4 or 0), eb + 13.5 } }, 3.4, 2.4)
      else return end
      if q.quirk == "notch" and not far then m:cut(g:P({ { ex - 3.4, eb + 3.2 }, { ex - 0.4, eb + 3.8 }, { ex - 3.2, eb + 5.4 } })) end   -- a notch bitten out of its ear
      g:form(m, r, { frac = 0.3, off = 1 })
      if (not far and k.ears ~= "round") or k.ears == "long" then earInner(m, r) elseif not far then local ix, iy = g:x(ex - 0.6), g:y(eb + 2.0); L.inside(c, ix, iy, PT.shade, r.base, r.shade) L.inside(c, ix + 1, iy, PT.shade, r.base, r.shade) if big then L.inside(c, ix, iy + 1, PT.shade, r.base, r.shade) L.inside(c, ix + 1, iy + 1, PT.shade, r.base, r.shade) end end
      if k.ears == "tuft" then g:stroke({ { ex - 1.6, eb + 5.2 }, { ex - 2.6, eb + 8.4 } }, DARK) end                                     -- a lynx's ear tuft
      if k.ears == "long" and not far then g:mark({ { ex - 2.2, eb + 13.5 }, { ex - 1.4, eb + 11 } }, DARK, r.base, r.shade, PT.shade) end   -- black ear tip
    end
    if not f.nohear then ear(big and 4.6 or 4.2, D, true) end
    -- horns and antlers grow from behind the brow
    if f.horns == "curl" then        -- a ram's horn: a thick ridged curl beside the head
      local ca, cb = hx - 2.6, hy + 1.8
      local m = g:E(ca, cb, 7.6, 7.6); m:cut(g:E(ca + 0.4, cb - 0.4, 3.0, 3.0)); m:cut(g:P({ { ca + 1.5, cb - 0.5 }, { ca + 8, cb - 2.5 }, { ca + 8, cb - 9 }, { ca - 1, cb - 9 } }))
      g:form(m, A, { frac = 0.3 }) g:under(m, A.deep)
      for i = 0, 7 do local t = pi * (0.1 + i * 0.2); g:mark({ { ca + cos(t) * 3.6, cb + sin(t) * 3.6 }, { ca + cos(t) * 7.4, cb + sin(t) * 7.4 } }, A.shade, A.base, A.hi) end
    elseif f.horns then              -- a yak's sweep of horn, one each side
      for s = 0, 1 do
        local ax = hx - 2.5 + s * 5.2
        local m = g:Limb({ { ax, hy + hry * 0.7 }, { ax - 3.5 + s * 7.4, hy + hry + 2.2 }, { ax - 3.2 + s * 7.2, hy + hry + 7.6 } }, 3.0, 1.2)
        g:form(m, s == 0 and L.darker(A) or A, { frac = 0.3, off = 1 }) g:put(ax - 3.2 + s * 7.2, hy + hry + 8, P.cream)
      end
    elseif f.antlers then            -- branching antlers
      for s = 0, 1 do
        local ax, r = hx - 2.2 + s * 5, s == 0 and L.darker(A) or A
        local d = s == 0 and -1 or 1
        local m = g:Limb({ { ax, hy + hry * 0.6 }, { ax + d * 2.4, hy + hry + 5 }, { ax + d * 4.6, hy + hry + 11.5 } }, 2.4, 1.3)
        m:add(g:Limb({ { ax + d * 1.6, hy + hry + 3.4 }, { ax + d * 6.4, hy + hry + 5.6 } }, 1.8, 1.1)) m:add(g:Limb({ { ax + d * 3.2, hy + hry + 7.6 }, { ax - d * 0.6, hy + hry + 11 } }, 1.7, 1.0))
        g:form(m, r, { frac = 0.3, off = 1 })
        if q.quirk == "moss" and s == 1 then g:over(g:E(ax + d * 6, hy + hry + 6, 1.8, 1.2), P.moss.base, r.base, r.shade, r.hi) g:put(ax + d * 6, hy + hry + 5, P.moss.shade) end   -- moss hangs from one tine
      end
    end
    if kd == "bear" and k.jowl and big then   -- a beard of fur under the jaw
      local jowl = g:P({ { hx - 3.6, hy - hry * 0.72 }, { hx + 4.4, hy - hry * 0.86 }, { hx + 0.4, hy - hry - 2.6 } }); g:form(jowl, B, { frac = 0.4, off = 1 }) g:under(jowl, B.deep)
    end
    local head = g:E(hx, hy, hrx, hry)
    g:form(head, B, { frac = 0.3, offu = 2.7, pop = { { hx - hrx * 0.55, hy + hry * 0.62 } } }) g:under(head, B.deep)
    g:tuft(hx - hrx * 0.62, hy - hry * 0.1, B) g:tuft(hx - hrx * 0.2, hy - hry * 0.55, B)
    if not f.nohear then ear(0, B, false) end
    -- snout / muzzle
    local snout
    if kd == "canid" or k.wedge then
      snout = g:P({ { hx + hrx * 0.25, sy + k.snh + 0.9 }, { tipx - 1.2, sy + 1.0 }, { tipx + 0.2, sy - 0.4 }, { tipx - 0.8, sy - k.snh + 0.5 }, { hx + hrx * 0.25, sy - k.snh - 0.9 } })
    elseif k.sn >= 4.5 then
      snout = g:RR(hx + hrx * 0.3, sy + k.snh, tipx, sy - k.snh, 1.6)
      if f.snout and k.sn >= 8 then snout = g:P({ { hx + hrx * 0.3, sy + k.snh }, { tipx, sy + 0.2 }, { tipx + 0.4, sy - 1.5 }, { tipx - 1, sy - k.snh + 0.6 }, { hx + hrx * 0.3, sy - k.snh } }) end   -- a long tapering snout
    else
      snout = g:E(hx + hrx * 0.6, sy - 0.5, k.sn + 0.8, k.snh); tipx = hx + hrx * 0.6 + k.sn + 0.8
    end
    local SN = (kd == "feline" or kd == "rodent" or kd == "hare" or (kd == "canid" and not claimed)) and (claimed and L.lighter(B) or PALE) or B
    if k.blaze then SN = A end
    g:form(snout, SN, { frac = 0.22, off = 1, inner = false }) g:under(snout, SN.deep == B.deep and B.deep or SN.shade)
    if kd == "bear" and k.sn >= 4.5 then g:mark({ { hx + hrx * 0.55, sy + k.snh - 0.6 }, { hx + hrx * 0.55 + 0.8, sy + k.snh - 1.4 } }, B.shade, B.base) g:mark({ { hx + hrx * 0.55 + 2, sy + k.snh - 0.6 }, { hx + hrx * 0.55 + 2.8, sy + k.snh - 1.4 } }, B.shade, B.base) end   -- wrinkles over the snout
    local NOSE = (k.nose == "pink") and PT or L.R.ink
    local nose
    if kd == "bear" and k.nose == "pink" then nose = g:E(tipx, sy, 1.7, k.snh * 0.85)                 -- a boar's flat disc
    else nose = g:E(tipx - 0.5, sy + (kd == "canid" and 0.5 or 0.9), 1.5, 1.2) end
    g:form(nose, NOSE, { frac = 0.34, off = 1, inner = false }) g:put(tipx - 1.0, sy + 1.4, NOSE.hi)
    g:mark({ { tipx - 1.6, sy - k.snh + 0.9 }, { hx + hrx * 0.5, sy - k.snh + 0.3 } }, SN.deep, SN.base, SN.shade, B.base, B.shade)   -- mouth
    if kd == "feline" or kd == "rodent" then g:dots({ { hx + hrx * 0.7, sy - 0.6 }, { hx + hrx * 0.7 + 1.6, sy - 1.3 } }, SN.shade) end   -- whisker spots
    -- markings on the face
    if k.face then   -- a monkey's bare pale face
      local fc = g:E(hx + hrx * 0.3, hy - hry * 0.05, hrx * 0.7, hry * 0.72); fc:clip(head); g:over(fc, PALE.base, B.base, B.hi) g:over(fc, PALE.shade, B.shade)
    end
    if k.mask then   -- a bandit mask
      local mk = g:E(hx + hrx * 0.3, hy + hry * 0.22, hrx * 0.62, hry * 0.3); mk:clip(head); g:over(mk, A.shade, B.base, B.shade, B.hi)
    end
    if k.blaze or (f.stripes and kd == "bear" and not k.mask and not k.mantle) then   -- a pale blaze from the nose up over the crown
      local bz = g:Ln({ { hx + hrx * 0.9, hy - hry * 0.1 }, { hx + hrx * 0.1, hy + hry * 0.72 }, { hx - hrx * 0.7, hy + hry * 0.7 } }, 1.7); bz:clip(head)
      g:over(bz, A.base, B.base, B.hi) g:over(bz, A.shade, B.shade)
    end
    if k.mantle then local cap = g:E(hx - 1, hy + hry * 0.8, hrx * 1.0, hry * 0.5); cap:clip(head); g:over(cap, A.base, B.base, B.hi) g:over(cap, A.shade, B.shade) end
    if f.stripes and kd == "feline" then for i = 0, 2 do g:mark({ { hx - hrx * 0.5 + i * 2.2, hy + hry - 0.4 }, { hx - hrx * 0.4 + i * 2.2, hy + hry * 0.45 } }, DARK, B.base, B.shade, B.hi) end g:mark({ { hx - hrx + 0.6, hy - 0.5 }, { hx - hrx * 0.5, hy - 1.2 } }, DARK, B.base, B.shade) end
    if f.spots and kd == "feline" then g:dots({ { hx - hrx * 0.5, hy + hry * 0.6 }, { hx - hrx * 0.1, hy + hry * 0.8 }, { hx - hrx * 0.7, hy - 0.5 } }, A.shade == B.shade and DARK or A.shade) end
    if f.tusks then   -- a curved tusk up from the lower jaw; the far one is a broken stump (a bigger, clearer stub than before)
      local ta, tb = tipx - 3.6, sy - k.snh + 0.6
      local tk2 = g:Limb({ { ta, tb }, { ta + 1.6, tb + 1.8 }, { ta + 1.9, tb + 4.6 } }, 2.0, 0.9)
      local st = g:R(ta + 2.6, tb + 1.6, ta + 3.8, tb - 0.2)
      g:fill(st, CREAM.base) g:put(ta + 2.6, tb + 1.6, CREAM.hi) g:put(ta + 3.8, tb + 1.6, CREAM.shade) g:put(ta + 3.2, tb + 1.6, CREAM.deep)
      g:fill(tk2, P.cream) tk2:each(function(x, y) if not tk2:has(x + 1, y) then c:put(x, y, CREAM.shade) end end)
    end
    if q.quirk == "tooth" then g:fill(g:R(tipx - 3.4, sy - k.snh + 0.4, tipx - 2.8, sy - k.snh - 1.0), P.cream) end                         -- one snaggle tooth
    if q.quirk == "flower" then   -- a daisy tucked behind its ear
      local fa, fb = hx - hrx * 0.75, hy + hry * 0.78
      for _, d in ipairs({ { -1.2, 0 }, { 1.2, 0 }, { 0, 1.2 }, { 0, -1.2 } }) do g:put(fa + d[1], fb + d[2], P.cream) end g:put(fa, fb, P.gold.base)
    elseif q.quirk == "sprig" then   -- a sprig of grass in the corner of its mouth
      g:stroke({ { hx + hrx * 0.8, sy - k.snh + 0.4 }, { hx + hrx * 0.8 + 3.2, sy - k.snh - 2.6 } }, P.moss.shade) g:put(hx + hrx * 0.8 + 3.6, sy - k.snh - 2.2, P.moss.base)
    elseif q.quirk == "ring" then    -- a gold ring in its ear
      local ex, eb = hx - hrx * 0.42 - 2.2, hy + hry * 0.62 + 3
      g:stroke({ { ex - 0.8, eb }, { ex - 1.6, eb - 0.8 }, { ex - 0.8, eb - 1.6 } }, P.gold.base) g:put(ex - 1.6, eb - 0.8, P.gold.hi)
    elseif q.quirk == "scarf" then   -- a little neckerchief
      local na, nb = hx - hrx * 0.62, hy - hry * 0.78
      local m = g:P({ { na - 2.6, nb + 1.6 }, { na + 4.4, nb - 0.4 }, { na + 0.6, nb - 4.6 } }); g:form(m, P.ember, { frac = 0.3, off = 1 }) g:put(na + 0.4, nb - 0.4, P.gold.base)
    elseif q.quirk == "bell" then    -- a bell on a collar
      local na, nb = hx - hrx * 0.3, hy - hry * 0.95
      g:stroke({ { na - 3, nb + 1.6 }, { na + 2.6, nb } }, P.ember.shade, 1) local m = g:E(na, nb - 1.2, 1.5, 1.5); g:form(m, P.gold, { frac = 0.34, off = 1 }) g:put(na, nb - 2.2, P.gold.deep)
    elseif q.quirk == "bow" then     -- a bow on one ear
      local fa, fb = hx - hrx * 0.5, hy + hry * 0.95
      g:fill(g:P({ { fa - 2.4, fb + 1.6 }, { fa - 2.4, fb - 1.4 }, { fa, fb } }), PT.base) g:fill(g:P({ { fa + 2.6, fb + 1.6 }, { fa + 2.6, fb - 1.4 }, { fa, fb } }), PT.base) g:put(fa, fb, PT.deep)
    elseif q.quirk == "feather" then -- a feather stuck in its fur behind the ear
      local fa, fb = hx - hrx * 0.9, hy + hry * 0.5
      local m = g:Limb({ { fa, fb }, { fa - 2.2, fb + 5.6 } }, 1.2, 2.2); g:form(m, P.sky, { frac = 0.4, off = 1 }) g:stroke({ { fa, fb }, { fa - 2.0, fb + 5.2 } }, P.sky.deep)
    elseif q.quirk == "snack" then   -- it carries a snack in its mouth
      local sa, sb = tipx - 0.6, sy - k.snh - 0.4
      local m = g:E(sa, sb, 2.2, 1.6); g:form(m, P.ember, { frac = 0.34, off = 1 }) g:put(sa - 0.8, sb + 0.8, P.ember.hi) g:stroke({ { sa, sb + 1.6 }, { sa + 0.8, sb + 2.6 } }, P.moss.shade)
    end
    if kd ~= "bear" or not big then g:dots({ { hx + hrx * 0.42, hy - hry * 0.42 }, { hx + hrx * 0.42 + 0.9, hy - hry * 0.42 } }, PT.base) end   -- cheek

    ------------------------------------------------------------------ eyes
    local ea, eb = hx + hrx * 0.22, hy + hry * 0.2
    g:T("eyes") g:eye(ea, eb) g:T("head")
    if k.brow ~= false and (kd == "bear" or kd == "canid" or kd == "ungulate") and big then
      g:stroke({ { ea - 2.2, eb + 2.0 }, { ea - 0.6, eb + 2.9 }, { ea + 1.2, eb + 2.4 }, { ea + 2.6, eb + 1.2 } }, k.mask and A.deep or B.deep)   -- a grumpy brow
    end
    if q.quirk == "eyescar" then g:stroke({ { ea + 0.4, eb + 4.2 }, { ea - 0.6, eb - 3.2 } }, PT.shade) end
    if q.puff then   -- it snorts: two round puffs from the nostrils (hidden until a pose shows them)
      g:T("puff") local m = g:E(tipx + 5, sy + 0.8, 1.5, 1.5); g:fill(m, P.stone.hi) g:put(tipx + 5.6, sy + 0.2, P.stone.base) g:put(tipx + 4.4, sy + 1.4, P.cream)
      g:fill(g:E(tipx + 8.6, sy + 4, 0.8, 0.8), P.stone.hi)
    end
    return {
      { "body", false, k.bx, k.by }, { "legBF", "body", backA + 3.6, k.legh + 0.5, true }, { "legFF", "body", frontA + 3.4, k.legh + 0.5, true }, { "tail", "body", tx + 1.5, ty, true },
      { "legBN", "body", backA, k.legh + 0.5 }, { "legFN", "body", frontA, k.legh + 0.5 }, { "leaf", "body", k.bx - k.brx * 0.35, k.by + k.bry * 0.78 },
      { "head", "body", hx - hrx * 0.7, hy - hry * 0.45 }, { "mane", "head", hx - 4.5, hy - 2.5, true }, { "eyes", "head", ea, eb }, { "puff", "head", tipx + 2.5, sy },
    }
  end
end
