-- bird: birds (and the bat), side view, facing RIGHT. Parts: tail, legB, body, legF, thighs, wing, [neck], head, [crest], eyes.
-- Spec features: longlegs (heron, cassowary: a neck part), crest, ears (owl tufts, bat ears), bigbeak (pelican).
-- Colours: a pale accent on a dark bird is its chest (hawk); otherwise the accent is the wing and tail.
-- quirks/bird.lua, per slug:
--   look = { base = "raptor|perch|owl|long|bat" (posture and proportions; default from the features), ...any field of that base...,
--            beak = "hook|cone|gull|spear|pouch|casque|none", tail = "fan|wedge|short|none", cap = true (dark crown), bald = true (bare head and a ruff), disc = true (owl face) }
--   quirk = "ring" (a red ring on one leg), "kink" (the middle crest feather is kinked over: its own part `crest`), "button" (something shiny in the beak),
--           "chip", "fish" (in the beak), "monocle", "crown", "scarf", "snow", "bone", "notch" (a notch out of one ear), "plaster"
return function(L)
  local P, HP = L.P, L.HP
  local CREAM, G, W, PT = L.R.cream, P.gold, P.wood, P.petal
  local sin, cos, rad, max, min, floor = math.sin, math.cos, math.rad, math.max, math.min, math.floor
  local BASE = {
    raptor = { bx = 0, by = 17, brx = 9.5, bry = 10.5, sx = 3, sy = 22, srx = 6.5, sry = 7, hx = 7, hy = 30, hrx = 5.8, hry = 5.3, legB = -3, legF = 3, legt = 9, beak = "hook", tail = "fan", cap = true, thighs = true },
    perch  = { bx = 0, by = 13.5, brx = 10, bry = 7.6, sx = 4.5, sy = 16, srx = 6.4, sry = 6.4, hx = 8.5, hy = 22.5, hrx = 5.6, hry = 5.2, legB = -2, legF = 3.5, legt = 7.5, beak = "cone", tail = "wedge" },
    owl    = { bx = 0, by = 15.5, brx = 9, bry = 10.5, sx = 1.5, sy = 20, srx = 7.6, sry = 7, hx = 3.5, hy = 28.5, hrx = 7.8, hry = 6.8, legB = -2.5, legF = 3.5, legt = 7, beak = "hook", tail = "short", disc = true, thighs = true },
    long   = { bx = -1, by = 25, brx = 9.6, bry = 6.6, sx = 4, sy = 27, srx = 5.6, sry = 5.6, hx = 11, hy = 42, hrx = 4.6, hry = 4.0, legB = -2, legF = 3, legt = 19.5, beak = "spear", tail = "wedge", neck = true },
    bat    = { bx = 0, by = 13.5, brx = 7, bry = 7.8, sx = 1.5, sy = 17, srx = 5.6, sry = 5.4, hx = 4.5, hy = 23, hrx = 6.4, hry = 5.6, legB = -2, legF = 2.5, legt = 5, beak = "none", tail = "none" },
  }
  return function(g)
    local c, f, q, B, A = g.c, g.f, g.q, g.B, g.A
    local lk = q.look or {}
    local base = lk.base or (f.longlegs and "long" or (f.ears and "owl" or ((f.crest and g.u >= 1.4) and "raptor" or "perch")))
    local k = setmetatable({}, { __index = BASE[base] }); for key, v in pairs(lk) do k[key] = v end
    local big = g.u >= 1.4
    local function lum(r) local h = r.base; return tonumber(h:sub(2, 3), 16) * 0.3 + tonumber(h:sub(4, 5), 16) * 0.59 + tonumber(h:sub(6, 7), 16) * 0.11 end
    local paleA = lum(A) > 190 and lum(B) < 170
    local CH = paleA and A or L.lighter(B)                -- chest
    local WG = paleA and L.darker(B) or A                 -- wing and tail
    local LEG = L.ramp(lk.leg or "gold")
    local BK = L.ramp(lk.beakcol or (f.bigbeak and A or "gold"))
    local c_put = function(x, y, h) c:put(x, y, h) end
    -- a long feather from (a0, b0) at `ang` degrees (0 = right, 90 = up): tapering to a neat round tip, a dark band, a pale tip
    local function feather(a0, b0, ang, len, wid, r, tipc, band)
      local t = rad(ang); local dx, dy = cos(t), sin(t); local nx, ny = -dy, dx
      local function pt(along, side) return { a0 + dx * len * along + nx * wid * side, b0 + dy * len * along + ny * wid * side } end
      local m = g:P({ pt(0, 0.34), pt(0.66, 0.5), pt(0.88, 0.4), pt(0.98, 0.16), pt(1.0, 0), pt(0.98, -0.16), pt(0.88, -0.4), pt(0.66, -0.5), pt(0, -0.34) })
      g:form(m, r, { frac = 0.3, off = 1 }) g:under(m, r.deep)
      local function along(x, y) return (((x - g.ox) / g.u - a0) * dx + ((g.gy - y) / g.u - b0) * dy) / len end
      m:each(function(x, y)
        local tt = along(x, y)
        if tt > 0.88 then c:put(x, y, tipc or CREAM.base) elseif band ~= false and tt > 0.62 and tt < 0.8 then c:put(x, y, r.shade) end
      end)
      g:mark({ pt(0.12, 0), pt(0.86, 0) }, r.shade, r.base, r.hi)                                  -- the shaft
      m:edge():each(function(x, y) if along(x, y) > 0.18 then c:put(x, y, r.deep) end end)         -- a clean edge: each feather stands apart
      return m
    end
    g:shadow(k.bx, k.brx + 3.5)

    ------------------------------------------------------------------ tail
    g:T("tail")
    local ta, tb = k.bx - k.brx * 0.82, k.by - k.bry * 0.25
    if k.tail == "fan" then for i, an in ipairs({ 156, 171, 186, 201, 216 }) do feather(ta + 1, tb + 3.2 - i * 1.1, an, 12 + (i == 3 and 1 or 0), 3.0, WG) end
    elseif k.tail == "wedge" then for i, an in ipairs({ 168, 183, 198 }) do feather(ta + 1, tb + 2 - i * 0.8, an, 9 + (i == 2 and 1 or 0), 2.8, WG, WG.hi) end
    elseif k.tail == "short" then for i, an in ipairs({ 200, 218, 236 }) do feather(ta + 3, tb - 1.5 - i * 0.4, an, 6, 3.0, WG, WG.hi) end
    elseif k.tail == "plume" then   -- a cassowary's drooping skirt of hair-feathers
      local m = g:Limb({ { ta + 4, tb + 2 }, { ta - 2, tb + 1 }, { ta - 5, tb - 5 } }, 6, 4); g:form(m, B, { frac = 0.3 }) g:under(m, B.deep) g:fur(m, B, 1.6)
    end

    ------------------------------------------------------------------ legs
    local function leg(id, la, far)
      g:T(id)
      local r = far and L.darker(LEG) or LEG
      local w = k.legw or (big and 1.5 or 1.3)
      local m
      if k.feathered then m = g:Limb({ { la, k.legt + 1.5 }, { la + 0.3, 1.6 } }, 3.2, 2.8)
      elseif k.neck then m = g:Limb({ { la, k.legt + 1 }, { la - 1.2, k.legt * 0.52 }, { la + 0.2, 1.2 } }, w, w)   -- a long leg with a backward knee
      else m = g:R(la - w / 2, k.legt + 1, la + w / 2, 1.2) end
      g:form(m, k.feathered and CH or r, { frac = 0.34, off = 1 })
      if k.feathered then for b = 2, k.legt, 1.6 do g:inside(la - 1.2, b, CH.shade, CH.base) g:inside(la + 1, b - 0.8, CH.shade, CH.base) end end   -- leg feathers
      if not k.feathered then for b = 2.6, k.legt - 1, 1.5 do g:mark({ { la - w / 2 - (k.neck and 0.6 or 0), b }, { la + w / 2, b } }, r.shade, r.base) end end                 -- scaly shins
      if k.neck then g:fill(g:E(la - 1.2, k.legt * 0.52, w * 0.75, w * 0.75), r.base) g:put(la - 1.2, k.legt * 0.52, r.shade) end                  -- knee knob
      if base == "bat" then g:stroke({ { la - 0.8, 0.6 }, { la + 1.8, 0.6 } }, r.deep) g:dots({ { la + 2.2, 1 }, { la + 2.6, 1.8 } }, P.cream)
      else
        local ft = g:Ln({ { la - 1.4, 0.75 }, { la + 4.0, 0.75 } }, 1.0); g:form(ft, r, { noshade = true })
        local y = g.gy
        for _, d in ipairs({ { 4.6, 0 }, { 2.2, 0 }, { -2.0, 0 } }) do c:put(g:x(la + d[1]), y, P.ink) c:put(g:x(la + d[1]) - 1, y - 1, P.ink) end   -- talons
      end
      if q.quirk == "ring" and not far then local rm = g:R(la - w / 2 - 0.2, k.legt * 0.5 + 0.8, la + w / 2 + 0.2, k.legt * 0.5 - 0.4); g:fill(rm, P.ember.base) g:put(la - w / 2, k.legt * 0.5 + 0.8, P.ember.hi) end   -- a red ring on one leg
    end
    leg("legB", k.legB, true)

    ------------------------------------------------------------------ body
    g:T("body")
    local body = g:E(k.bx, k.by, k.brx, k.bry)
    body:add(g:E(k.sx, k.sy, k.srx, k.sry))
    g:form(body, B, { frac = 0.3, offu = 2.4, pop = { { k.bx - k.brx * 0.62, k.by + k.bry * 0.66 } } }) g:under(body, B.deep)
    local chest = g:E(k.bx + k.brx * 0.48, k.by - k.bry * 0.08, k.brx * 0.58, k.bry * 0.78); chest:clip(body)
    g:form(chest, CH, { frac = 0.25, off = 2, inner = false })
    local rowh = big and 2.0 or 1.8
    for row = 0, 6 do for i = 0, 3 do   -- chest flecks, row on row, thinning toward the throat
      local a, b = k.bx + k.brx * 0.1 + i * 2.5 + (row % 2) * 1.2, k.by + k.bry * 0.55 - row * rowh
      local x, y = g:x(a), g:y(b)
      if chest:has(x, y) and chest:has(x + 2, y + 1) and chest:has(x - 1, y) and (row > 0 or i == 1) then L.inside(c, x, y, CH.shade, CH.base) L.inside(c, x + 1, y + 1, CH.deep, CH.base, CH.shade) L.inside(c, x + 2, y, CH.shade, CH.base) end
    end end
    g:fur(body, B, k.shaggy or 0.8)
    if k.shaggy then for i = 0, 7 do local a = k.bx - k.brx * 0.9 + i * 1.7; g:dots({ { a, k.by - k.bry * 0.85 - (i % 2) * 0.9 }, { a + 0.6, k.by - k.bry * 0.85 - 1.8 - (i % 2) } }, B.deep) end end   -- hair-like feathers
    if k.flecks then for i = 1, 14 do local a, b = k.bx - k.brx * 0.8 + g:rnd(i, 3) * k.brx * 1.2, k.by - k.bry * 0.5 + g:rnd(i, 4) * k.bry * 1.3; g:inside(a, b, P.stone.base, B.base, B.shade, CH.base) g:inside(a + 0.9, b - 0.9, P.stone.base, B.base, B.shade, CH.base) end end   -- a few dark winter flecks
    if q.quirk == "snow" then for a = k.bx - k.brx * 0.6, k.sx + k.srx * 0.2, 0.5 do local x = g:x(a); for yy = g:y(k.sy + k.sry + 2), g:y(k.by) do if body:has(x, yy) then if g:rnd(x, 2) > 0.3 then c:put(x, yy, P.cream) end break end end end end
    leg("legF", k.legF, false)
    if k.thighs then   -- feathered thighs with a ragged hem
      g:T("thighs")
      for i, a in ipairs({ k.legB + 1, k.legF + 1 }) do
        local r = i == 1 and B or CH
        local m = g:E(a, k.legt, 2.6, 2.3)
        for j = -1, 1 do m:add(g:P({ { a + j * 1.5 - 1, k.legt - 1.4 }, { a + j * 1.5 + 1, k.legt - 1.4 }, { a + j * 1.5, k.legt - 3.6 } })) end
        g:form(m, r, { frac = 0.3, off = 1, inner = false }) g:under(m, r.deep)
      end
    end

    ------------------------------------------------------------------ wing
    g:T("wing")
    local wa, wb = k.bx - k.brx * 0.45, k.by + k.bry * 0.02
    local wrx, wry = k.brx * 0.6, k.bry * 0.78
    if base == "bat" then   -- a raised leathery wing: an arm up to the wrist, four finger bones, a scalloped membrane, a thumb claw
      local S, Wr = { -1.2, 18.4 }, { -5, 33.5 }
      local T = { { -17.5, 30.5 }, { -22.5, 21.5 }, { -20.5, 11 }, { -13, 6 } }
      local pts = { S, Wr, T[1], { -14.2, 25.2 }, T[2], { -17.6, 16 }, T[3], { -14, 9 }, T[4], { -7, 8.6 }, { -2.2, 11 } }
      local m = g:P(pts)
      g:form(m, WG, { frac = 0.25, off = 2, pop = { { -9, 30 }, { -13, 27 } } }) g:under(m, WG.deep)
      for i, t in ipairs(T) do g:mark({ Wr, t }, WG.deep, WG.base, WG.shade, WG.hi) g:mark({ { Wr[1] + 0.6, Wr[2] - 0.8 }, { t[1] + 0.6, t[2] - 0.8 } }, WG.hi, WG.base) end
      g:mark({ { -2, 13 }, { -9, 12 }, { -13.5, 9 } }, WG.shade, WG.base, WG.hi)
      local arm = g:Limb({ S, Wr }, 2.8, 2.0); g:form(arm, B, { frac = 0.34, off = 1 }) g:under(arm, B.deep)
      g:fill(g:E(Wr[1], Wr[2], 1.6, 1.6), B.base) g:dots({ { Wr[1] + 1.4, Wr[2] + 1.6 }, { Wr[1] + 2, Wr[2] + 2.6 } }, P.cream)     -- wrist knuckle and thumb claw
      for _, t in ipairs(T) do g:dots({ t }, WG.deep) end
    else
      local n = k.prim or ((base == "perch" or base == "long") and 2 or 3)
      local PR = k.wingtip and L.R.ink or WG
      for i = n, 1, -1 do feather(wa + 0.5 - i * 1.2, wb - wry * 0.45 + i * 0.6, 262 - i * (n > 3 and 7 or 9) - (base == "perch" and 55 or (base == "long" and 60 or 0)), wry * (base == "raptor" and 1.25 or 1.05), 2.8, PR, k.wingtip and P.cream or WG.hi) end   -- primaries, the first one in front
      local wing = g:E(wa, wb, wrx, wry)
      if base == "perch" or base == "long" then wing = g:E(wa + 0.5, wb + 0.5, k.brx * 0.72, k.bry * 0.62) end
      g:form(wing, WG, { frac = 0.22, off = 2, pop = { { wa - wrx * 0.6, wb + wry * 0.62 } } }) g:under(wing, WG.deep)
      local x0, y0, x1, y1 = wing:bbox()
      if k.gloss then for x = x0 + 2, x1 - 2, 3 do for y = y0, y1 do if wing:has(x, y) then L.inside(c, x, y + 1, k.gloss, WG.base, WG.shade, WG.hi) L.inside(c, x + 1, y + 1, k.gloss, WG.base, WG.shade, WG.hi) break end end end end   -- a glossy sheen
      local sx, sy = g:px(2.5), g:px(2.4)
      for row = 0, 8 do for i = 0, 8 do   -- covert rows: a dark scallop with a lit edge under it
        local x, y = x0 + 1 + i * sx + (row % 2) * (sx // 2), y0 + 3 + row * sy
        if wing:has(x, y) and wing:has(x + 3, y + 2) and wing:has(x - 1, y - 1) then
          for _, d in ipairs({ { 0, 0 }, { 1, 1 }, { 2, 1 }, { 3, 0 } }) do L.inside(c, x + d[1], y + d[2], WG.deep, WG.base, WG.shade) end
          L.inside(c, x + 1, y + 2, WG.hi, WG.base) L.inside(c, x + 2, y + 2, WG.hi, WG.base)
        end
      end end
    end

    ------------------------------------------------------------------ neck (long-legged birds): an S from the shoulder up to the head
    local hx, hy, hrx, hry = k.hx, k.hy, k.hrx, k.hry
    if k.neck then
      g:T("neck")
      local NK = L.ramp(lk.neckcol or B)
      local m = g:Limb({ { k.sx + 1.5, k.sy + 1 }, { k.sx + 5.5, k.sy + 6 }, { hx - 3.5, hy - 8 }, { hx - 1.5, hy - 2 } }, 5.2, 3.4)
      g:form(m, NK, { frac = 0.34, off = 1 }) g:under(m, NK.deep)
      if lk.wattle then local wt = g:Limb({ { hx + 0.5, hy - 4.5 }, { hx + 1.5, hy - 9 } }, 2.0, 1.4); g:form(wt, P.ember, { frac = 0.4, off = 1 }) end   -- a red wattle
      if f.crest and base == "long" and k.beak ~= "casque" then for i = 0, 2 do g:mark({ { k.sx + 5.5 + i * 0.6, k.sy + 3 - i * 1.6 }, { k.sx + 7.5 + i * 0.4, k.sy + 0.5 - i * 1.6 } }, NK.deep, NK.base, NK.shade) end end   -- breast plumes
    end

    ------------------------------------------------------------------ head
    g:T("head")
    local HD = L.ramp(lk.headcol or B)
    if f.ears and base == "owl" then   -- ear tufts
      for i, d in ipairs({ { -hrx * 0.62, -1.6 }, { hrx * 0.5, 1.6 } }) do
        local m = g:P({ { hx + d[1] - 1.8, hy + hry * 0.55 }, { hx + d[1] + 1.8, hy + hry * 0.62 }, { hx + d[1] + d[2], hy + hry + 4.6 } })
        if q.quirk == "notch" and i == 1 then m:cut(g:P({ { hx + d[1] - 2.4, hy + hry + 1.4 }, { hx + d[1] - 0.4, hy + hry + 2 }, { hx + d[1] - 2.4, hy + hry + 3 } })) end
        g:form(m, i == 1 and L.darker(HD) or HD, { frac = 0.3, off = 1 }) g:put(hx + d[1] + d[2] * 0.7, hy + hry + 3, WG.deep)
      end
    elseif f.ears then                  -- a bat's ears: broad, pointed, with a pink inside and veins
      for i, d in ipairs({ { 2.2, 1.2 }, { -3.2, -1 } }) do
        local m = g:P({ { hx + d[1] - 2.8, hy + hry * 0.5 }, { hx + d[1] + 3.0, hy + hry * 0.55 }, { hx + d[1] + d[2] + 1.6, hy + hry + 6.4 }, { hx + d[1] + d[2] - 0.2, hy + hry + 3.2 } })
        if q.quirk == "notch" and i == 2 then m:cut(g:P({ { hx + d[1] - 3.4, hy + hry + 2.4 }, { hx + d[1] - 0.6, hy + hry + 3 }, { hx + d[1] - 3, hy + hry + 4.6 } })) end
        g:form(m, i == 1 and L.darker(HD) or HD, { frac = 0.3, off = 1 }) g:under(m, HD.deep)
        local inn = m:shrink(big and 2 or 1); inn:each(function(x, y) L.inside(c, x, y, i == 1 and PT.shade or PT.base, HD.base, HD.shade, L.darker(HD).base, L.darker(HD).shade) end)
        g:mark({ { hx + d[1], hy + hry * 0.8 }, { hx + d[1] + d[2] * 0.8 + 0.8, hy + hry + 4.4 } }, PT.shade, PT.base)
      end
    end
    if f.crest and base ~= "long" and not k.bald then   -- a crest of three swept-back feathers behind the crown (the hawk's middle one is its own kinked part)
      local cl = big and 1 or 0.8
      for i, t in ipairs({ { -0.85, 0.2, 148, 6.2 }, { -0.55, 0.62, 128, 7.4 }, { -0.12, 0.88, 108, 6.8 } }) do
        feather(hx + hrx * t[1], hy + hry * t[2], t[3], t[4] * cl, 2.7, i == 1 and L.darker(HD) or HD, CH.base, false)
      end
    end
    if k.bald then   -- a vulture's ruff of pale down round the base of the bare neck
      local m = g:E(hx - 2.2, hy - hry - 1.2, hrx * 0.95, 3.0); for i = -2, 2 do m:add(g:P({ { hx - 2.2 + i * 2 - 1, hy - hry - 3 }, { hx - 2.2 + i * 2 + 1, hy - hry - 3 }, { hx - 2.2 + i * 2, hy - hry - 5.4 } })) end
      g:form(m, L.R.cream, { frac = 0.3, off = 1 }) g:under(m, L.R.cream.deep)
      local nk = g:Limb({ { hx - 2, hy - hry - 1 }, { hx - 0.6, hy - 1 } }, 4.4, 4.0); g:form(nk, HD, { frac = 0.34, off = 1 })
    end
    local head = g:E(hx, hy, hrx, hry)
    g:form(head, HD, { frac = 0.3, offu = 2.4, pop = { { hx - hrx * 0.56, hy + hry * 0.62 } } }) g:under(head, HD.deep)
    if k.cap then local yc = g:y(hy + hry * 0.5); head:each(function(x, y) if y < yc then L.inside(c, x, y, L.darker(HD).base, HD.base) end end) end   -- a dark cap
    if k.disc then   -- an owl's face: a big pale disc with a dark rim, set to the front of the head
      local d = g:E(hx + hrx * 0.3, hy - hry * 0.1, hrx * 0.78, hry * 0.9); d:clip(head)
      local DC = CH
      d:each(function(x, y) c:put(x, y, DC.base) end)
      d:each(function(x, y) if not d:has(x + 1, y + 1) or not d:has(x + 1, y) then L.inside(c, x, y, DC.shade, DC.base) end end)
      local ring = d:copy(); ring:cut(d:shrink(1))
      ring:each(function(x, y) if not (x > g:x(hx + hrx * 0.75)) or true then c:put(x, y, (not d:has(x + 1, y + 1)) and HD.deep or HD.shade) end end)
      g:mark({ { hx + hrx * 0.3, hy + hry * 0.7 }, { hx + hrx * 0.3, hy + hry * 0.1 } }, DC.shade, DC.base)                        -- the groove between the eyes
    end
    if not k.bald then for _, d in ipairs({ { -0.75, -0.2 }, { -0.35, -0.62 }, { -0.8, -0.6 } }) do g:tuft(hx + hrx * d[1], hy + hry * d[2], HD) end end
    if k.bald then g:dots({ { hx - hrx * 0.5, hy + hry * 0.6 }, { hx - hrx * 0.1, hy + hry * 0.85 }, { hx - hrx * 0.7, hy + hry * 0.1 } }, HD.shade) end   -- a few bristles on the bare skin
    -- eye (and its iris), stripe and brow
    local ea, eb = hx + hrx * (base == "owl" and 0.42 or 0.28), hy + hry * (base == "owl" and 0.2 or 0.24)
    if base == "raptor" and not k.bald then g:mark({ { hx - hrx * 0.9, hy - 0.2 }, { hx - hrx * 0.3, hy + 0.9 }, { ea - 1.6, eb + 0.2 } }, HD.deep, HD.base, HD.shade, L.darker(HD).base) end   -- eye stripe
    -- beak
    local ba, bb = hx + hrx * (base == "owl" and 0.78 or 0.78), hy - hry * (base == "owl" and 0.3 or 0.1)      -- where the beak leaves the face
    if k.beak == "hook" then
      local s = base == "owl" and 0.62 or 1
      local m = g:P({ { ba - 1, bb + 2.4 * s }, { ba + 4.6 * s, bb + 0.6 * s }, { ba + 5.4 * s, bb - 1.6 * s }, { ba + 3.8 * s, bb - 4.2 * s }, { ba + 2.8 * s, bb - 2.2 * s }, { ba - 1, bb - 2.2 * s } })
      if base == "owl" then m = g:P({ { ba - 2, bb + 1.8 }, { ba + 2.2, bb + 0.6 }, { ba + 3.4, bb - 1.6 }, { ba + 2, bb - 3.8 }, { ba + 0.2, bb - 3.2 }, { ba - 2, bb - 1.8 } }) end
      g:form(m, BK, { frac = 0.3, off = 1, pop = { { ba + 0.6 * s, bb + 1.2 * s } } }) g:under(m, BK.shade)
      if base ~= "owl" then
        g:over(g:R(ba - 1, bb + 2.4, ba + 0.2, bb - 2.2), BK.hi, BK.base, BK.shade)                                     -- cere: the pale base of the beak
        g:mark({ { ba + 0.4, bb - 0.6 }, { ba + 2.6, bb - 1.2 } }, BK.deep, BK.base, BK.shade, BK.hi) g:put(ba + 0.6, bb + 0.9, BK.deep)   -- gape, nostril
        g:dots({ { ba + 4.0, bb - 3.4 }, { ba + 4.4, bb - 2.6 } }, W.deep)                                              -- dark hook
      end
    elseif k.beak == "crow" then   -- a heavy beak with bristles at the base
      local m = g:P({ { ba - 1.6, bb + 2.6 }, { ba + 5.4, bb + 0.6 }, { ba + 7.2, bb - 1.4 }, { ba + 5.4, bb - 2.2 }, { ba - 1.6, bb - 2.8 } })
      g:form(m, BK, { frac = 0.3, off = 1, pop = { { ba + 1, bb + 1.4 } } }) g:under(m, BK.shade) g:mark({ { ba, bb - 0.4 }, { ba + 5, bb - 0.6 } }, BK.deep, BK.base, BK.shade)
      g:dots({ { ba - 0.6, bb + 1.8 }, { ba - 0.4, bb + 0.6 }, { ba - 1.2, bb - 0.8 } }, P.ink)
    elseif k.beak == "cone" then
      local m = g:P({ { ba - 1, bb + 2.0 }, { ba + 5.2, bb - 0.2 }, { ba + 5.0, bb - 1.0 }, { ba - 1, bb - 2.0 } })
      g:form(m, BK, { frac = 0.3, off = 1 }) g:under(m, BK.shade) g:mark({ { ba, bb - 0.6 }, { ba + 4, bb - 0.7 } }, BK.deep, BK.base, BK.shade)
    elseif k.beak == "gull" then
      local m = g:P({ { ba - 1, bb + 1.8 }, { ba + 6.2, bb + 0.8 }, { ba + 7.2, bb - 1.2 }, { ba + 6.0, bb - 2.2 }, { ba - 1, bb - 1.8 } })
      g:form(m, BK, { frac = 0.3, off = 1 }) g:under(m, BK.shade) g:mark({ { ba, bb - 0.4 }, { ba + 5.4, bb - 0.6 } }, BK.deep, BK.base, BK.shade) g:put(ba + 5.2, bb - 1.6, P.ember.base)   -- the red spot
    elseif k.beak == "spear" then
      local m = g:P({ { ba - 1, bb + 1.6 }, { ba + 10.5, bb - 0.6 }, { ba - 1, bb - 1.9 } })
      g:form(m, BK, { frac = 0.3, off = 1 }) g:under(m, BK.shade) g:mark({ { ba, bb - 0.3 }, { ba + 8, bb - 0.6 } }, BK.deep, BK.base, BK.shade)
    elseif k.beak == "pouch" then   -- a pelican: a long bill over a sagging throat pouch
      local pch = g:P({ { ba - 2, bb - 0.6 }, { ba + 11, bb - 0.8 }, { ba + 8, bb - 5.2 }, { ba + 2, bb - 6.4 }, { ba - 2.4, bb - 3.4 } })
      g:form(pch, BK, { frac = 0.3, off = 2 }) g:under(pch, BK.deep)
      for i = 0, 3 do g:mark({ { ba + 1 + i * 2.4, bb - 1.4 }, { ba + 0.4 + i * 2.2, bb - 5 } }, BK.shade, BK.base) end
      local m = g:P({ { ba - 1, bb + 1.8 }, { ba + 11.6, bb + 0.4 }, { ba + 12.4, bb - 1.2 }, { ba + 11.2, bb - 1.9 }, { ba - 1, bb - 0.9 } })
      g:form(m, G, { frac = 0.3, off = 1 }) g:under(m, G.shade) g:put(ba + 12, bb - 1.6, G.deep)
    elseif k.beak == "casque" then  -- a cassowary: a short beak and a tall horn casque on the crown
      local cq = g:P({ { hx - 2.6, hy + hry * 0.5 }, { hx + 2.6, hy + hry * 0.5 }, { hx + 2.0, hy + hry + 3.6 }, { hx - 0.6, hy + hry + 5.2 }, { hx - 2.4, hy + hry + 3 } })
      g:form(cq, L.R.sand, { frac = 0.34, off = 1 }) g:mark({ { hx - 1.4, hy + hry + 0.6 }, { hx - 0.6, hy + hry + 4 } }, L.R.sand.hi, L.R.sand.base)
      head:each(function(x, y) L.inside(c, x, y, HD.base, L.R.sand.base, L.R.sand.shade) end)
      local m = g:P({ { ba - 1, bb + 1.6 }, { ba + 4.6, bb - 0.4 }, { ba - 1, bb - 1.8 } }); g:form(m, L.R.slate, { frac = 0.3, off = 1 })
    else                            -- the bat: a short snout, a pink nose, two fangs
      local m = g:E(hx + hrx * 0.72, hy - hry * 0.36, 2.6, 2.2); g:form(m, L.lighter(HD), { frac = 0.25, off = 1, inner = false })
      g:fill(g:E(hx + hrx * 0.72 + 2.2, hy - hry * 0.2, 0.9, 0.9), PT.base)
      g:mark({ { hx + hrx * 0.4, hy - hry * 0.62 }, { hx + hrx * 0.72 + 1.6, hy - hry * 0.66 } }, HD.deep, HD.base, HD.shade, L.lighter(HD).base, L.lighter(HD).shade)
      g:put(hx + hrx * 0.62, hy - hry * 0.8, P.cream) g:put(hx + hrx * 0.62 + 1.7, hy - hry * 0.8, P.cream)
      g:dots({ { hx + hrx * 0.1, hy - hry * 0.4 }, { hx + hrx * 0.1 + 0.9, hy - hry * 0.4 } }, PT.base)
    end
    if q.quirk == "button" then g:fill(g:E(ba + 5.6, bb - 0.8, 1.1, 1.1), G.base) g:put(ba + 5.2, bb - 0.4, G.hi)                                  -- a shiny button in its beak
    elseif q.quirk == "chip" then g:fill(g:Ln({ { ba + 6.4, bb + 0.6 }, { ba + 8.4, bb - 3.2 } }, 1.0), G.hi) g:put(ba + 8.4, bb - 3.2, G.shade)   -- a stolen chip
    elseif q.quirk == "fish" then local fm = g:E(ba + 9.8, bb - 2.2, 2.6, 1.3); g:form(fm, P.sea, { frac = 0.3, off = 1 }) g:fill(g:P({ { ba + 11.6, bb - 2.2 }, { ba + 13.6, bb - 0.6 }, { ba + 13.6, bb - 3.8 } }), P.sea.shade) g:put(ba + 8.6, bb - 1.8, P.ink)
    elseif q.quirk == "bone" then g:fill(g:Ln({ { ba + 3, bb - 4.6 }, { ba + 7.6, bb - 4.2 } }, 1.0), P.cream) g:fill(g:E(ba + 8, bb - 4.2, 1.0, 1.0), P.cream) g:fill(g:E(ba + 2.6, bb - 4.6, 1.0, 1.0), P.cream)
    elseif q.quirk == "scarf" then local m = g:Limb({ { hx - hrx * 0.6, hy - hry - 0.2 }, { hx + hrx * 0.5, hy - hry - 0.8 } }, 2.4, 2.4); m:add(g:P({ { hx - hrx * 0.4, hy - hry - 0.6 }, { hx - hrx * 0.4 + 2, hy - hry - 0.6 }, { hx - hrx * 0.4 - 0.6, hy - hry - 5.6 } })); g:form(m, P.ember, { frac = 0.3, off = 1 }) g:mark({ { hx - hrx * 0.2, hy - hry + 0.4 }, { hx + hrx * 0.4, hy - hry - 0.2 } }, P.gold.base, P.ember.base, P.ember.shade)
    elseif q.quirk == "crown" then local m = g:R(hx - 2.6, hy + hry + 0.8, hx + 2.6, hy + hry - 0.6); for i = -1, 1 do m:add(g:P({ { hx + i * 2.2 - 1, hy + hry + 0.6 }, { hx + i * 2.2 + 1, hy + hry + 0.6 }, { hx + i * 2.2, hy + hry + 3.2 } })) end g:form(m, G, { frac = 0.3, off = 1 }) g:put(hx, hy + hry + 0.4, P.ember.base)
    elseif q.quirk == "plaster" then g:over(g:Ln({ { hx - hrx * 0.7, hy + hry * 0.5 }, { hx - hrx * 0.2, hy + hry * 0.1 } }, 1.3), CREAM.hi, HD.base, HD.shade, HD.hi, L.darker(HD).base) g:over(g:Ln({ { hx - hrx * 0.7, hy + hry * 0.1 }, { hx - hrx * 0.2, hy + hry * 0.5 } }, 1.3), CREAM.base, HD.base, HD.shade, HD.hi, L.darker(HD).base, CREAM.hi) end
    if q.quirk == "kink" then   -- the middle crest feather is kinked: a stem straight up, then it flops over backwards in a sharp bend, pale tip
      g:T("crest")
      local ka, kb = hx - hrx * 0.45, hy + hry * 0.7
      local m = g:Limb({ { ka, kb }, { ka + 0.2, kb + 5.4 } }, 2.6, 2.2)
      local seg = g:P({ { ka + 1.4, kb + 6.4 }, { ka - 1.6, kb + 6.8 }, { ka - 5.4, kb + 6 }, { ka - 8.4, kb + 3.4 }, { ka - 8.6, kb + 2.4 }, { ka - 5.6, kb + 3.6 }, { ka - 1.8, kb + 3.8 }, { ka + 1.2, kb + 3.8 } })
      m:add(seg)
      g:form(m, HD, { frac = 0.3, off = 1 }) g:under(m, HD.deep)
      local xt = g:x(ka - 5.2); m:each(function(x, y) if x <= xt and y > g:y(kb + 5) then c:put(x, y, CH.base) end end)                -- pale tip
      g:mark({ { ka + 0.2, kb + 0.6 }, { ka + 0.2, kb + 5.4 }, { ka - 2, kb + 5.2 }, { ka - 6, kb + 4 } }, HD.shade, HD.base, HD.hi, CH.base)   -- the shaft follows the bend
      g:dots({ { ka + 1.2, kb + 2.2 }, { ka + 1.2, kb + 4 }, { ka - 3, kb + 6.4 } }, HD.deep)                                             -- barbs
      g:dots({ { ka + 1.4, kb + 5.4 } }, HD.deep)
    end

    ------------------------------------------------------------------ eyes
    g:T("eyes") g:eye(ea, eb)
    local ex, ey = g:x(ea) - 2, g:y(eb) - 2
    if base == "raptor" or base == "owl" or lk.iris then local ir = L.ramp(lk.iris or "gold").base; c:put(ex, ey + 1, ir) c:put(ex + 3, ey + 2, ir) c:put(ex, ey + 2, ir) end   -- a yellow iris
    if q.quirk == "monocle" then   -- a round gold-rimmed lens over the eye
      local cx, cy = ex + 1.5, ey + 1.5
      for dy = -5, 5 do for dx = -5, 5 do
        local d = math.sqrt(dx * dx + dy * dy)
        if d >= 3.3 and d <= 4.3 then c:put(floor(cx + dx + 0.5), floor(cy + dy + 0.5), (dx + dy > 2) and G.shade or ((dx + dy < -3) and G.hi or G.base)) end
      end end
    end
    g:T("head")
    if q.quirk == "monocle" then   -- its chain, hanging down over the chest
      for i = 0, 8 do g:dots({ { ea - 1.5 - i * 0.55, eb - 3.6 - i * 1.3 } }, i % 2 == 0 and G.base or G.shade) end
    end
    if k.eyering then local ex0, ey0 = g:x(ea) - 2, g:y(eb) - 2; for _, d in ipairs({ { -1, 1 }, { -1, 2 }, { 4, 1 }, { 4, 2 }, { 1, 4 }, { 2, 4 } }) do L.inside(c, ex0 + d[1], ey0 + d[2], L.ramp(k.eyering).base, HD.base, HD.shade, HD.hi, CH.base) end end
    if k.plumes then   -- long plumes trailing from the back of the head
      for i, p in ipairs({ { 0.3, 0.1, -12, -2.6 }, { 0.1, 0.5, -11, 0.6 } }) do
        local m = g:Limb({ { hx - hrx * (0.6 + p[1]), hy + hry * p[2] }, { hx - hrx * 0.9 + p[3] * 0.5, hy + hry * p[2] + p[4] * 0.2 }, { hx - hrx * 0.9 + p[3], hy + hry * p[2] + p[4] } }, 2.0, 0.6)
        g:form(m, i == 1 and L.R.ink or L.darker(HD), { frac = 0.3, off = 1 })
      end
    end
    if k.comb then   -- a red comb over the eye
      g:fill(g:E(ea + 0.4, eb + 3.6, 2.8, 1.1), P.ember.base) g:dots({ { ea - 1.2, eb + 3.4 }, { ea + 0.6, eb + 4.5 } }, P.ember.hi) g:dots({ { ea + 1.8, eb + 2.8 } }, P.ember.shade)
    end
    if k.nape then   -- a little tuft of feathers on the nape
      feather(hx - hrx * 0.7, hy + hry * 0.5, 148, 5.4, 2.4, HD, CH.base, false) feather(hx - hrx * 0.45, hy + hry * 0.8, 128, 5.2, 2.4, HD, CH.base, false)
    end
    if k.wrinkle then g:dots({ { hx - hrx * 0.8, hy - hry * 0.9 }, { hx - hrx * 0.2, hy - hry * 1.05 }, { hx - hrx * 0.6, hy - hry * 1.2 }, { hx - hrx * 0.2, hy - hry * 1.5 } }, HD.deep) end   -- wrinkled bare skin
    if base == "raptor" then g:stroke({ { ea - 3.2, eb + 2.6 }, { ea - 0.6, eb + 2.2 }, { ea + 2.6, eb + 0.6 } }, HD.deep) end   -- the raptor's glare
    return {
      { "body", false, k.bx, k.by }, { "tail", "body", ta + 1.5, tb + 0.5, true }, { "legB", "body", k.legB, k.legt, true }, { "legF", "body", k.legF, k.legt }, { "thighs", "body", (k.legB + k.legF) / 2 + 1, k.legt },
      { "wing", "body", wa + wrx * 0.3, wb + wry * 0.75 }, { "neck", "body", k.sx + 2, k.sy + 1 }, { "head", k.neck and "neck" or "body", hx - hrx * 0.5, hy - hry * 0.75 },
      { "crest", "head", hx - hrx * 0.45, hy + hry * 0.7 }, { "eyes", "head", ea, eb },
    }
  end
end
