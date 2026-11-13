-- cats.lua: Cat Fish grey template cats (idleA, pounce, catch, nap), hand-authored spans/polygons + offset-band shading,
-- hand-placed face, tufts, toes. quirk: nicked left ear (cat's left = viewer's right), a V notch in the outer edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local OUT = app.params["out"] or (DIR .. "/out/")
local K = L.K
local CATS = {}

-- HEAD (cols relative to x=8, rows absolute for idleA; shifted by ox,oy) ----------------------------
local FACE = { [10] = { 2, 32 } }
for y = 11, 19 do FACE[y] = { 1, 33 } end
local CHEEK = { [20] = { 1, 33 }, [21] = { 0, 34 }, [22] = { -1, 35 }, [23] = { 1, 33 }, [24] = { 0, 34 }, [25] = { 2, 32 },
  [26] = { 3, 31 }, [27] = { 4, 30 }, [28] = { 6, 28 }, [29] = { 8, 26 }, [30] = { 11, 23 } }
for y, r in pairs(CHEEK) do FACE[y] = r end
local CROWN_A = { [7] = { 14, 20 }, [8] = { 12, 22 }, [9] = { 11, 23 } }
local CROWN_F = { [5] = { 12, 22 }, [6] = { 9, 25 }, [7] = { 6, 28 }, [8] = { 4, 30 }, [9] = { 3, 31 } }
local FLAP_L = { [4] = { 7, 10 }, [5] = { 6, 11 }, [6] = { 5, 11 }, [7] = { 4, 11 }, [8] = { 4, 10 }, [9] = { 5, 8 }, [10] = { 6, 6 } }
local FLAP_R = { [4] = { 24, 27 }, [5] = { 23, 28 }, [6] = { 23, 29 }, [7] = { 23, 30 }, [8] = { 24, 30 }, [9] = { 26, 29 }, [10] = { 28, 28 } }
local EAR_L = { [2] = { 2, 3 }, [3] = { 2, 4 }, [4] = { 2, 5 }, [5] = { 2, 6 }, [6] = { 2, 7 }, [7] = { 2, 8 }, [8] = { 2, 9 }, [9] = { 2, 10 } }
local EAR_R = { [2] = { 31, 32 }, [3] = { 30, 32 }, [4] = { 29, 31 }, [5] = { 28, 30 }, [6] = { 27, 31 }, [7] = { 26, 32 }, [8] = { 25, 32 }, [9] = { 24, 32 } }
local PINK_L = { [4] = { 3, 3 }, [5] = { 3, 4 }, [6] = { 3, 5 }, [7] = { 4, 6 }, [8] = { 4, 6 } }
local PINK_R = { [4] = { 31, 31 }, [5] = { 30, 30 }, [6] = { 29, 30 }, [7] = { 28, 30 }, [8] = { 28, 30 } }
local EYE_OPEN = { "..uuu..", ".ucccu.", "uccuucu", "ucuuucu", "ucuuucu", ".ucccu.", "..uuu.." }

local function head(c, info, ox, oy, eyes, ears, fluff)
  local X0 = 8 + ox
  local hm = L.spans(FACE, X0, oy)
  local earsM
  if ears == "folded" then
    hm:add(L.spans(CROWN_F, X0, oy))
  else
    hm:add(L.spans(CROWN_A, X0, oy))
    earsM = L.spans(EAR_L, X0, oy):add(L.spans(EAR_R, X0, oy))
    hm:add(earsM)
  end
  -- chin fluff: three short spikes hanging over the chest
  local FL = { { 20, 31 }, { 21, 31 }, { 21, 32 }, { 24, 31 }, { 25, 31 }, { 25, 32 }, { 29, 31 }, { 30, 31 }, { 29, 32 } }
  if fluff then for _, p in ipairs(FL) do hm:set(p[1] + ox, p[2] + oy) end end
  c:part(hm, { ws = 2, wl = 5, cast = false })
  -- crown light: a soft lit dome on the upper-left of the head
  L.ellipse(19 + ox, 12.5 + oy, 8.5, 3.2):each(function(x, y) local t = c:get(x, y) if t == 'm' then c:put(x, y, 'l', "light") end end)
  if fluff then for _, p in ipairs({ { 20, 31, 'b' }, { 21, 31, 'l' }, { 21, 32, 'L' }, { 24, 31, 'b' }, { 25, 31, 'l' }, { 25, 32, 'L' }, { 29, 31, 'b' }, { 30, 31, 's' }, { 29, 32, 'l' } }) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") end end
  info.head = hm
  -- muzzle puff: two lit lobes under the nose
  local mz = L.ellipse(25 + ox, 26.5 + oy, 5.6, 2.4)
  mz:each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) then c:put(x, y, (t == 's' or t == 'b') and 'l' or 'L', "light") end end)
  L.ellipse(22 + ox, 27 + oy, 1.6, 1):add(L.ellipse(28 + ox, 27 + oy, 1.6, 1)):each(function(x, y) c:put(x, y, 'g', "light") end)
  info.muzzle = mz
  if ears ~= "folded" then
    -- inner ears: pink with a darker inner side, fur tuft at the base
    for _, P in ipairs({ { PINK_L, 1 }, { PINK_R, -1 } }) do
      local pm = L.spans(P[1], X0, oy):clip(earsM:filter(function(x, y) return earsM:has(x + 1, y) and earsM:has(x - 1, y) end))
      pm:each(function(x, y)
        local inner = P[2] == 1 and not pm:has(x + 1, y) or P[2] == -1 and not pm:has(x - 1, y)
        c:put(x, y, inner and 'P' or 'p', "detail")
      end)
    end
    c:stamp({ { X0 + 4, 8 + oy, 'L' }, { X0 + 5, 9 + oy, 'L' }, { X0 + 3, 9 + oy, 'l' },
              { X0 + 30, 8 + oy, 'L' }, { X0 + 29, 9 + oy, 'L' }, { X0 + 31, 9 + oy, 'l' } })
    -- quirk: the nick shows the pale edge of the cut
    c:put(X0 + 30, 5 + oy, 'L', "detail")
    info.ears = earsM
  else
    -- folded ears: small flat caps folded forward over the crown, tips down toward the cheeks
    local fl, fr = L.spans(FLAP_L, X0, oy), L.spans(FLAP_R, X0, oy)
    for i, f in ipairs({ fl, fr }) do
      c:part(f, { ws = 1, wl = 1 })
      -- the opening: a dark-pink line under the fold, inner ear just peeking out
      f:each(function(x, y) if not f:has(x, y + 1) and f:has(x, y - 1) and f:has(x - 1, y) and f:has(x + 1, y) then c:put(x, y, 'P', "detail") end end)
      -- fold crease: a lit ridge one row under the top
      f:each(function(x, y) if not f:has(x, y - 1) and f:has(x, y + 1) then c:put(x, y + 1, 'L', "light") end end)
    end
    info.flaps = fl:copy():add(fr)
  end
  -- forehead gloss
  c:stamp({ { 13 + ox, 12 + oy, 'g' }, { 14 + ox, 11 + oy, 'g' }, { 15 + ox, 11 + oy, 'g' }, { 16 + ox, 11 + oy, 'L' }, { 13 + ox, 13 + oy, 'L' } })
  -- cheek tufts: a lit strand into each spike, a shade notch under it
  c:stamp({ { 7 + ox, 22 + oy, 'L' }, { 8 + ox, 22 + oy, 'L' }, { 9 + ox, 22 + oy, 'l' }, { 8 + ox, 23 + oy, 'b' }, { 9 + ox, 23 + oy, 'l' },
            { 8 + ox, 24 + oy, 'l' }, { 9 + ox, 24 + oy, 'l' }, { 10 + ox, 25 + oy, 'b' },
            { 43 + ox, 22 + oy, 'r' }, { 42 + ox, 22 + oy, 'b' }, { 42 + ox, 23 + oy, 'D' }, { 42 + ox, 24 + oy, 'r' }, { 41 + ox, 24 + oy, 'b' }, { 40 + ox, 25 + oy, 'D' } })
  -- eyes (locked boxes)
  local prot = L.mask()
  for _, ex in ipairs({ 16, 34 }) do
    local cx, cy = ex + ox, 21 + oy
    for dy = -3, 3 do for dx = -3, 3 do prot:set(cx + dx, cy + dy) end end
    if eyes == "open" then
      c:stamp(L.stamp(EYE_OPEN, cx - 3, cy - 3))
    elseif eyes == "happy" then
      c:stamp({ { cx - 1, cy - 1, '#' }, { cx, cy - 1, '#' }, { cx + 1, cy - 1, '#' }, { cx - 2, cy, '#' }, { cx + 2, cy, '#' } })
    else -- sleep
      c:stamp({ { cx - 2, cy, '#' }, { cx + 2, cy, '#' }, { cx - 1, cy + 1, '#' }, { cx, cy + 1, '#' }, { cx + 1, cy + 1, '#' }, { cx - 3, cy - 1, '#' } })
    end
  end
  -- nose (cream glint, pink, ink tip) + mouth
  local face = { { 24, 24, 'c' }, { 25, 24, 'p' }, { 26, 24, 'P' }, { 25, 25, '#' }, { 25, 26, '#' }, { 23, 26, '#' }, { 27, 26, '#' }, { 24, 27, '#' }, { 26, 27, '#' },
                 { 12, 25, 'p' }, { 13, 25, 'p' }, { 37, 25, 'p' }, { 38, 25, 'p' } }
  for _, p in ipairs(face) do c:put(p[1] + ox, p[2] + oy, p[3], "detail") prot:set(p[1] + ox, p[2] + oy) end
  info.protect = prot
end

-- helpers ------------------------------------------------------------------------------------------
local function shadow(c, cx, cy, rx, ry, rx2)
  L.ellipse(cx, cy, rx, ry):each(function(x, y) c:put(x, y, 'W', "shade", true) end)
  L.ellipse(cx, cy, rx2 or rx * 0.7, math.max(0.6, ry - 0.8)):each(function(x, y) c:put(x, y, 'U', "shade", true) end)
end
local function toes(c, xs, y0, y1) for _, x in ipairs(xs) do for y = y0, y1 do c:put(x, y, 's', "detail") end end end
-- tail radius: full at the root, slim mid, a fuller brush near the tip, pointed end
local function BRUSH(t)
  if t < 0.6 then return 2.6 - 1.2 * t end
  if t < 0.86 then return 1.88 + (t - 0.6) * 1.6 end
  return 2.3 - (t - 0.86) * 9
end
local function tailTip(c, list) for _, p in ipairs(list) do c:put(p[1], p[2], p[3], "detail") end end

local function finish(c, info, gy)
  if gy then c:contact(gy) end
  c:rim(gy)
  if info.after then info.after(c) end
  c:outline()
end

-- FRAMES -------------------------------------------------------------------------------------------
local function tailIdle(c, info, bob)
  if bob then
    local m = L.ellipse(39.5, 52.5, 3, 2.6)
    c:part(m, { ws = 1, wl = 1 })
    info.tail = m info.tailT = {}
    c:stamp({ { 38, 51, 'g' }, { 39, 50, 'L' }, { 42, 52, 'r' } })
    return
  end
  local m, T = L.tube({ { 36, 54 }, { 44, 55 }, { 50, 53 }, { 54, 48 }, { 55, 42 }, { 53, 36 }, { 52, 33 } }, BRUSH)
  c:part(m, { ws = 1, wl = 2 })
  info.tail, info.tailT = m, T
  tailTip(c, { { 52, 34, 'g' }, { 51, 35, 'L' }, { 52, 36, 'L' }, { 54, 37, 's' } })
end

CATS.idleA = function(o)
  local c, info = L.canvas(64, 64), { frame = "idleA", ox = 0, oy = 0 }
  shadow(c, 28, 57.5, 20, 2, 13)
  tailIdle(c, info, o.tail == "bobtail")
  local haunch = L.ellipse(25, 47, 15, 9.6)
  c:part(haunch, { ws = 3, wl = 4 })
  local feet = L.ellipse(13, 54.6, 3.6, 1.8):add(L.ellipse(37, 54.6, 3.6, 1.8))
  c:part(feet, { ws = 1, wl = 1 })
  local chest = L.ellipse(25, 37, 10.6, 8.6)
  local legL = L.poly({ { 16.4, 40 }, { 22.4, 38 }, { 22.4, 53 }, { 17.4, 53 } })
  local legR = L.poly({ { 27.6, 38 }, { 33.6, 40 }, { 32.6, 53 }, { 27.6, 53 } })
  local front = chest:copy():add(legL):add(legR)
  c:part(front, { ws = 2, wl = 4 })
  -- belly light: a pale bib down the chest
  L.ellipse(25, 38, 4.2, 6):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and front:has(x, y) then c:put(x, y, L.step(t, 1), "light") end end)
  -- leg creases: one shade line where each leg turns under the chest
  for y = 47, 52 do c:put(22, y, 's', "shade") end
  local paws = L.ellipse(19.5, 54.4, 3.6, 2.1):add(L.ellipse(30.5, 54.4, 3.6, 2.1))
  c:part(paws, { ws = 1, wl = 1, noao = true })
  toes(c, { 18, 21, 29, 32 }, 55, 56)
  toes(c, { 12, 14, 36, 38 }, 55, 56)
  info.legs = legL:copy():add(legR) info.paws = paws:copy():add(feet) info.chest = chest info.haunch = haunch
  info.hcx, info.hcy, info.hrx, info.hry = 25, 47, 15, 9.6
  head(c, info, 0, 0, "open", o.ears, true)
  -- chest fluff: three lit spikes hanging under the chin
  info.after = function(c)
    c:stamp({ { 18, 33, 'g' }, { 17, 34, 'L' } })
  end
  finish(c, info, 56)
  return c, info
end

CATS.catch = function(o)
  local c, info = L.canvas(64, 64), { frame = "catch", ox = 0, oy = 0 }
  shadow(c, 28, 57.5, 20, 2, 13)
  if o.tail == "bobtail" then tailIdle(c, info, true) else
    local m, T = L.tube({ { 36, 54 }, { 45, 54 }, { 50, 50 }, { 52, 44 }, { 50, 39 }, { 46, 36 }, { 43, 36 } }, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT = m, T
    tailTip(c, { { 45, 35, 'g' }, { 46, 35, 'L' }, { 44, 35, 'L' } })
  end
  local haunch = L.ellipse(25, 47, 15, 9.6)
  c:part(haunch, { ws = 3, wl = 4 })
  local feet = L.ellipse(13, 54.6, 3.6, 1.8):add(L.ellipse(37, 54.6, 3.6, 1.8)):add(L.ellipse(20, 55, 3.2, 1.6)):add(L.ellipse(30, 55, 3.2, 1.6))
  c:part(feet, { ws = 1, wl = 1 })
  toes(c, { 12, 14, 36, 38, 19, 21, 29, 31 }, 55, 56)
  local chest = L.ellipse(25, 37, 10.6, 8.6)
  c:part(chest, { ws = 2, wl = 4 })
  L.ellipse(25, 47, 4, 4):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and y < 53 then c:put(x, y, L.step(t, 1), "light") end end)
  local armL = L.tube({ { 16, 33 }, { 15.5, 36 }, { 18.5, 38 } }, function() return 2.3 end)
  local armR = L.tube({ { 34, 33 }, { 34.5, 36 }, { 32, 38 } }, function() return 2.3 end)
  c:part(armL, { ws = 1, wl = 2, ao = false }) c:part(armR, { ws = 1, wl = 1, ao = false })
  -- the fish (fixed accent colours, never recoloured): hand-placed stamp, facing left
  local FISH = {
    "........dffd..........",
    "......dddffddd.....ddd",
    "....ddyYYYyyyodd..dffd",
    "...dyYw#YYyyooOOddfffd",
    "..dyyw##yyyooooOOdfffd",
    "..dyyYyyyyooooOOOddffd",
    "...dooOooooooOOOdd.dfd",
    "....ddOOOOOOOOdd....dd",
    "......dddddddd........",
  }
  local FC = { d = "#ac3b1d", O = "#dc6f2c", o = "#e38111", y = "#f2a860", Y = "#ffc27a", w = "#fff1c8", f = "#f2c14e", ['#'] = '#' }
  local fm = L.mask()
  for j, row in ipairs(FISH) do for i = 1, #row do local ch = row:sub(i, i)
    if ch ~= '.' then c:put(14 + i, 36 + j, FC[ch], "detail") fm:set(14 + i, 36 + j) end end end
  local fb, ft = fm, L.mask()
  local paws = L.ellipse(19.5, 38.5, 2.6, 2.1):add(L.ellipse(31, 38.5, 2.6, 2.1))
  c:part(paws, { ws = 1, wl = 1, noao = true })
  toes(c, { 19, 31 }, 39, 40)
  info.legs = armL:copy():add(armR) info.paws = paws:copy():add(feet) info.chest = chest info.haunch = haunch
  info.fish = fb:copy():add(ft)
  info.hcx, info.hcy, info.hrx, info.hry = 25, 47, 15, 9.6
  head(c, info, 0, 0, "happy", o.ears, true)
  info.after = function(c)
    c:stamp({ { 18, 33, 'g' }, { 17, 34, 'L' } })
  end
  finish(c, info, 56)
  return c, info
end

CATS.pounce = function(o)
  local c, info = L.canvas(64, 64), { frame = "pounce", ox = 16, oy = 0 }
  shadow(c, 31, 58.5, 14, 1.5, 9)
  -- tail streaming up-left
  if o.tail == "bobtail" then
    local m = L.ellipse(9.5, 31.5, 2.8, 2.8) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { 8, 30, 'g' }, { 9, 29, 'L' } })
  else
    local m, T = L.tube({ { 13, 33 }, { 8, 28 }, { 6, 21 }, { 7, 14 }, { 10, 9 }, { 13, 7 } }, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT = m, T
    tailTip(c, { { 10, 8, 'g' }, { 11, 7, 'L' }, { 9, 9, 'L' } })
  end
  -- far legs
  local farHind = L.tube({ { 17, 40 }, { 15, 45 }, { 14, 49 } }, function() return 1.9 end)
  local farFront = L.tube({ { 38, 35 }, { 46, 37 }, { 51, 38.5 } }, function(t) return 2.2 - 0.5 * t end)
  c:part(farHind, { ws = 1, wl = 1, lift = -1 }) c:part(farFront, { ws = 1, wl = 1, lift = -1 })
  local farPaws = L.ellipse(14.5, 50.5, 2.8, 1.8):add(L.ellipse(53.5, 38.5, 2.8, 2.2))
  c:part(farPaws, { ws = 1, wl = 1, lift = -1, noao = true })
  local torso = L.ellipse(24.5, 35.5, 14.5, 6.6)
  c:part(torso, { ws = 2, wl = 3 })
  local haunch = L.ellipse(13.5, 38, 6.8, 6.2)
  c:part(haunch, { ws = 2, wl = 2 })
  local hind = L.tube({ { 10, 41 }, { 6, 46 }, { 4, 50 } }, function() return 2.2 end)
  c:part(hind, { ws = 1, wl = 1 })
  local foot = L.ellipse(4.5, 51.2, 3.6, 1.9)
  c:part(foot, { ws = 1, wl = 1, noao = true })
  toes(c, { 3, 5 }, 52, 52)
  local front = L.tube({ { 33, 37 }, { 41, 41 }, { 47, 44 } }, function(t) return 3.0 - 0.9 * t end)
  c:part(front, { ws = 1, wl = 2 })
  local paw = L.ellipse(49.5, 44.5, 3.6, 2.5)
  c:part(paw, { ws = 1, wl = 1, noao = true })
  toes(c, { 50, 52 }, 45, 46)
  -- belly light on the stretched underside
  L.ellipse(28, 39, 6, 2):each(function(x, y) local t = c:get(x, y) if t and L.isCoat(t) and torso:has(x, y) then c:put(x, y, L.step(t, 1), "light") end end)
  info.legs = front:copy():add(hind):add(farHind):add(farFront) info.paws = paw:copy():add(foot):add(farPaws) info.chest = torso info.haunch = haunch
  info.hcx, info.hcy, info.hrx, info.hry = 24.5, 35.5, 14.5, 6.6
  head(c, info, 16, 0, "open", o.ears)
  info.after = function(c)
    c:stamp({ { 15, 30, 'g' }, { 16, 30, 'L' }, { 12, 31, 'L' }, { 19, 30, 'L' } })
  end
  finish(c, info, nil)
  return c, info
end

CATS.nap = function(o)
  local c, info = L.canvas(64, 64), { frame = "nap", ox = 0, oy = 18 }
  shadow(c, 37, 58, 25, 2, 18)
  local body = L.ellipse(43, 47.5, 18, 9.2)
  c:part(body, { ws = 3, wl = 4 })
  local hip = L.ellipse(51, 46, 9.5, 9.5)
  c:part(hip, { ws = 3, wl = 4 })
  if o.tail == "bobtail" then
    local m = L.ellipse(59.5, 52, 2.8, 2.6) c:part(m, { ws = 1, wl = 1 }) info.tail = m info.tailT = {}
    c:stamp({ { 58, 51, 'L' }, { 59, 50, 'L' } })
  else
    local m, T = L.tube({ { 58, 52 }, { 54, 55.5 }, { 44, 56.5 }, { 32, 56.5 }, { 22, 55.5 }, { 15, 53.5 }, { 11, 52 } }, BRUSH)
    c:part(m, { ws = 1, wl = 2 })
    info.tail, info.tailT = m, T
    tailTip(c, { { 13, 52, 'g' }, { 14, 52, 'L' }, { 12, 53, 'L' } })
  end
  local paws = L.ellipse(17, 49.5, 4.2, 2.2):add(L.ellipse(32.5, 49.5, 4.2, 2.2))
  c:part(paws, { ws = 1, wl = 1 })
  toes(c, { 15, 18, 31, 34 }, 50, 51)
  info.legs = L.mask() info.paws = paws info.chest = body info.haunch = hip
  info.hcx, info.hcy, info.hrx, info.hry = 51, 46, 9.5, 9.5
  head(c, info, 0, 18, "sleep", o.ears)
  info.after = function(c)
    -- back fur tuft on the hip, lit
    c:stamp({ { 47, 37, 'g' }, { 48, 37, 'L' }, { 46, 38, 'L' }, { 51, 37, 'L' } })
  end
  finish(c, info, 57)
  return c, info
end

local FR = { "idleA", "pounce", "catch", "nap" }
local MODE = app.params["only"] or "all"
if MODE ~= "overlays" then
  for _, f in ipairs(FR) do
    local c, info = CATS[f]({})
    c:save(OUT, "cf-cat-grey-" .. f)
    print(f, "colours", c:colours(), "spurs", table.concat(c:spurs(), " "))
  end
end
if MODE == "cats" then return end

-- OVERLAYS ------------------------------------------------------------------------------------------
local OV = OUT .. "overlays/"
local WH = { g = "#fbf6ec", L = "#fbf6ec", l = "#e6dfd2", m = "#e6dfd2", b = "#bab0c0", r = "#bab0c0", s = "#bab0c0", D = "#8d829a" }
local WEDGE = "#463e5e"
local floor, atan, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local function eyeBox(info, x, y)
  for _, ex in ipairs({ 16, 34 }) do if math.abs(x - ex - info.ox) <= 3 and math.abs(y - 21 - info.oy) <= 3 then return true end end
  return false
end
local function ok(c, info, x, y)
  local t = c:get(x, y)
  return t and L.isCoat(t) and c:isObj(x, y) and not info.protect:has(x, y) and not eyeBox(info, x, y)
end
local function newP() return L.canvas(64, 64) end
local function dark(P, c, info, x, y, n) if ok(c, info, x, y) then P:put(x, y, L.step(c:get(x, y), n)) end end
-- points/spots: absolute mapping so lit felt still goes clearly dark
local PT = { g = 'b', L = 'b', l = 's', m = 's', b = 'D', r = 'D', s = 'D', D = 'D' }
local function point(P, c, info, x, y) if ok(c, info, x, y) then P:put(x, y, PT[c:get(x, y)]) end end
local function lightTone(P, c, info, x, y, n) if ok(c, info, x, y) then P:put(x, y, L.step(c:get(x, y), n)) end end
local function white(P, c, info, m)
  m:each(function(x, y) if ok(c, info, x, y) then P:put(x, y, WH[c:get(x, y)]) end end)
  -- 1px coat-deep seam where the patch meets coat felt on its shade side (below / right), so white holds its shape on pale coats
  m:each(function(x, y)
    if P:get(x, y) and ((ok(c, info, x + 1, y) and not m:has(x + 1, y)) or (ok(c, info, x, y + 1) and not m:has(x, y + 1))) then P:put(x, y, WEDGE) end
  end)
end
-- visible pixels of the main body ellipse
local function bodyEll(info) return info.hcx, info.hcy, info.hrx, info.hry end
local function radialStripes(P, c, info, cx, cy, rx, ry, n, region, phase)
  region:each(function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    local rho = sqrt(u * u + v * v)
    if rho < 0.42 or rho > 1.15 then return end
    local a = (atan(v, u) / (2 * pi) * n + (phase or 0)) % 1
    local w = 0.10 + 0.24 * math.min(1, (rho - 0.42) / 0.5)
    if a < w then dark(P, c, info, x, y, -2) end
  end)
end
local function tailRings(P, c, info, n0)
  if not info.tailT then return end
  info.tail:each(function(x, y)
    local t = info.tailT[K(x, y)]
    if not t then return end
    if t > 0.93 then dark(P, c, info, x, y, -2) return end
    local a = (t * (n0 or 6)) % 1
    if t > 0.12 and a > 0.55 and a < 0.78 then dark(P, c, info, x, y, -2) end
  end)
end
local function visible(c, m) return m:filter(function(x, y) return c:isObj(x, y) end) end
local function points(list, ox, oy) local m = L.mask() for _, p in ipairs(list) do m:set(p[1] + ox, p[2] + oy) end return m end

-- per-frame body regions that carry body markings (excluding head)
local function bodyRegion(c, info)
  local m = info.chest:copy():add(info.haunch)
  m:cut(info.head)
  return visible(c, m)
end

local PAT = {}
PAT.tabby = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  -- forehead M and crown lines
  points({ { 25, 12 }, { 25, 13 }, { 25, 14 }, { 25, 15 }, { 21, 12 }, { 22, 13 }, { 22, 14 }, { 29, 12 }, { 28, 13 }, { 28, 14 },
           { 23, 9 }, { 23, 10 }, { 27, 9 }, { 27, 10 }, { 25, 8 }, { 25, 9 }, { 25, 10 },
           { 9, 18 }, { 10, 18 }, { 11, 19 }, { 9, 20 }, { 10, 20 }, { 11, 20 }, { 41, 18 }, { 40, 18 }, { 39, 19 }, { 41, 20 }, { 40, 20 }, { 39, 20 } }, ox, oy)
    :each(function(x, y) dark(P, c, info, x, y, -2) end)
  local cx, cy, rx, ry = bodyEll(info)
  local reg = bodyRegion(c, info)
  if info.frame == "idleA" or info.frame == "catch" then
    -- haunch sides: stripes wrap the hips; chest: two necklace arcs
    radialStripes(P, c, info, cx, cy, rx, ry, 13, reg:filter(function(x, y) return math.abs(x - cx) > 7 end), 0.1)
    reg:each(function(x, y)
      local u, v = (x - 25) / 10, (y - 27) / 6.5
      local r = sqrt(u * u + v * v)
      if (r > 1.12 and r < 1.24) or (r > 1.45 and r < 1.57) then if math.abs(x - 25) > 1 then dark(P, c, info, x, y, -2) end end
    end)
    if info.frame == "idleA" then
      for _, y in ipairs({ 44, 48 }) do for x = 18, 21 do dark(P, c, info, x, y, -2) end for x = 29, 32 do dark(P, c, info, x, y, -2) end end
    end
  elseif info.frame == "pounce" then
    radialStripes(P, c, info, cx, cy + 3, rx, ry + 3, 16, reg:filter(function(x, y) return y < cy + 3 end), 0.0)
    radialStripes(P, c, info, 13.5, 38, 6.8, 6.2, 7, visible(c, info.haunch), 0.3)
    info.legs:each(function(x, y) if x == 39 or x == 40 or x == 44 or y == 45 or y == 47 then if not info.head:has(x, y) and x > 8 then dark(P, c, info, x, y, -2) end end end)
  else
    radialStripes(P, c, info, 43, 47.5, 18, 9.2, 15, reg:filter(function(x, y) return y < 52 end), 0.05)
    radialStripes(P, c, info, cx, cy, rx, ry, 9, visible(c, info.haunch), 0.2)
  end
  tailRings(P, c, info, 6)
  return P
end

local SPOTS = {
  idleA = { { 11, 43 }, { 13, 48 }, { 37, 43 }, { 38, 48 }, { 12, 52 }, { 39, 52 }, { 22, 34 }, { 28, 34 }, { 25, 37 } },
  catch = { { 11, 43 }, { 13, 48 }, { 37, 43 }, { 38, 48 }, { 12, 52 }, { 39, 52 }, { 21, 34 }, { 28, 34 } },
  pounce = { { 13, 32 }, { 19, 31 }, { 25, 30 }, { 31, 31 }, { 17, 36 }, { 23, 35 }, { 10, 37 }, { 14, 41 }, { 28, 35 } },
  nap = { { 38, 40 }, { 44, 39 }, { 50, 39 }, { 55, 42 }, { 41, 45 }, { 47, 44 }, { 53, 47 }, { 57, 48 }, { 36, 46 } },
}
PAT.spotted = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  for i, s in ipairs(SPOTS[info.frame]) do
    local big = (i % 3 ~= 0)
    local m = big and points({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } }, s[1], s[2]):unset(s[1] + 2, s[2] + 1) or points({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }, s[1], s[2])
    m:each(function(x, y) point(P, c, info, x, y) end)
  end
  points({ { 22, 11 }, { 23, 11 }, { 27, 11 }, { 28, 11 }, { 25, 9 }, { 25, 10 }, { 10, 19 }, { 11, 19 }, { 39, 19 }, { 40, 19 } }, ox, oy):each(function(x, y) dark(P, c, info, x, y, -2) end)
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)]
    if t and ((t > 0.3 and t < 0.37) or (t > 0.55 and t < 0.62) or t > 0.92) then dark(P, c, info, x, y, -2) end end) end
  return P
end

local BIB = {
  idleA = function() return L.ellipse(25, 39, 5.2, 7.5):add(L.rect(17, 51, 23, 57)):add(L.rect(27, 51, 34, 57)) end,
  catch = function() return L.ellipse(25, 46, 5.5, 5.5):add(L.ellipse(25, 34, 3.5, 3)) end,
  pounce = function() return L.ellipse(35, 37, 4.5, 4) end,
  nap = function() return L.mask() end,
}
local function chinMuzzle(info)
  return info.muzzle:copy():add(L.ellipse(25 + info.ox, 29 + info.oy, 4.5, 2.2)):clip(info.head)
end
PAT.tuxedo = function(c, info)
  local P = newP()
  local m = BIB[info.frame]():add(chinMuzzle(info)):add(info.paws)
  white(P, c, info, m)
  return P
end
local PATCH = {
  idleA = function() return { L.ellipse(13, 11, 6, 5), L.ellipse(37, 46, 6.5, 7), L.ellipse(51, 46, 4, 7) } end,
  catch = function() return { L.ellipse(13, 11, 6, 5), L.ellipse(37, 47, 6.5, 6.5), L.ellipse(51, 46, 4, 7) } end,
  pounce = function() return { L.ellipse(29, 11, 6, 5), L.ellipse(16, 34, 7, 5.5), L.ellipse(6, 20, 4, 6) } end,
  nap = function() return { L.ellipse(13, 29, 6, 5), L.ellipse(49, 42, 8, 6), L.ellipse(34, 57, 6, 3) } end,
}
PAT.calico = function(c, info)
  local P = newP()
  for _, m in ipairs(PATCH[info.frame]()) do m:each(function(x, y) dark(P, c, info, x, y, -2) end) end
  local wm = BIB[info.frame]():add(chinMuzzle(info)):add(info.paws)
  if info.frame == "idleA" or info.frame == "catch" then wm:add(L.ellipse(25, 48, 7, 6)) end
  if info.frame == "nap" then wm:add(L.ellipse(30, 55, 6, 3)) end
  white(P, c, info, wm)
  return P
end
PAT.pointed = function(c, info)
  local P, ox, oy = newP(), info.ox, info.oy
  local core = L.mask()
  core:add(L.ellipse(25 + ox, 26 + oy, 6.5, 4.2):clip(info.head))
  if info.ears then core:add(info.ears:filter(function(x, y) return y <= 7 + oy end)) end
  core:add(info.paws)
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)] if t and t > 0.45 then core:set(x, y) end end) end
  local halo = core:grow(1):cut(core)
  local halo2 = core:grow(2):cut(core):cut(halo)
  -- pale body (one step up), then points step down, with pixel-step halos
  c.obj:each(function(x, y) if not core:has(x, y) and not halo:has(x, y) and not halo2:has(x, y) then lightTone(P, c, info, x, y, 1) end end)
  halo2:each(function(x, y) if (x + y) % 2 == 0 then dark(P, c, info, x, y, -1) end end)
  halo:each(function(x, y) dark(P, c, info, x, y, -2) end)
  core:each(function(x, y) point(P, c, info, x, y) end)
  -- core of the core: deepest at the very tips
  if info.tailT then info.tail:each(function(x, y) local t = info.tailT[K(x, y)] if t and t > 0.8 then dark(P, c, info, x, y, -3) end end) end
  if info.ears then info.ears:each(function(x, y) if y <= 4 + oy then dark(P, c, info, x, y, -3) end end) end
  return P
end

local function diff(a, b, region)   -- -> mask (base pixels to clear), overlay canvas (variant pixels)
  local mask, ov = L.canvas(64, 64), L.canvas(64, 64)
  local n = 0
  for y = 0, 63 do for x = 0, 63 do
    if region(x, y) then
      local ta, tb = a:get(x, y), b:get(x, y)
      local ha, hb = ta and a:hex(ta), tb and b:hex(tb)
      if ha ~= hb then
        if ha then mask:put(x, y, "#ffffff") n = n + 1 end
        if hb then ov:put(x, y, tb, b.ly[K(x, y)]) end
      end
    end
  end end
  return mask, ov, n
end
local function clash(maskC, info)
  local bad = 0
  for k in pairs(maskC.t) do local x, y = L.XY(k) if info.protect:has(x, y) or eyeBox(info, x, y) then bad = bad + 1 end end
  return bad
end

for _, f in ipairs(FR) do
  local c, info = CATS[f]({})
  for _, pn in ipairs({ "tabby", "tuxedo", "calico", "pointed", "spotted" }) do
    local P = PAT[pn](c, info)
    P:save(OV, "cf-pat-" .. pn .. "-grey-" .. f, true)
  end
  local cf = CATS[f]({ ears = "folded" })
  local em, eo = diff(c, cf, function(x, y) return y < info.oy + 17 end)
  em:save(OV, "cf-ears-mask-" .. f, true) eo:save(OV, "cf-ears-folded-" .. f, true)
  local cb = CATS[f]({ tail = "bobtail" })
  local tm, to = diff(c, cb, function(x, y) return not (info.head:has(x, y)) end)
  tm:save(OV, "cf-tail-mask-" .. f, true) to:save(OV, "cf-tail-bobtail-" .. f, true)
  print(f, "ears mask clash", clash(em, info), "tail mask clash", clash(tm, info))
end
