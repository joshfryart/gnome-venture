-- fish.lua: Cat Fish rod fish 1-5 (48x48), hand-placed scale/fin/ribbon structure, bead eyes, one quirk each.
-- 1 plain: orange perch, scallop scale rows, forked tail with rays.        quirk: a bubble leaving its mouth
-- 2 silk:  pink betta, sail dorsal, two flowing silk ribbons for a tail.    quirk: a little red bow tied at the tail root
-- 3 catnip: green plush leaf-fish, midrib + veins for scales, leaf tail.    quirk: a catnip sprout growing from its back
-- 4 glitter: slim blue fish, diamond scales, violet spiky crest, lunate tail. quirk: a sparkle trail drifting off the tail
-- 5 golden: round gold fish, big scallops, fan tail.                       quirk: a crown, tipped askew, with one ruby
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local OUT = app.params["out"] or (DIR .. "/out/")
local K = L.K

local function R(D, s, b, m, l, Lh, g) return { D = D, s = s, b = b, m = m, l = l, L = Lh, g = g } end
local ORANGE = R("#8f3a1f", "#c4532a", "#d96a2c", "#ee8a34", "#f6a94e", "#ffd27a", "#fff1c8")
local PINK = R("#7d2c5e", "#c94f84", "#dc6a96", "#f08aac", "#f7a9c2", "#ffc4d8", "#fff0f4")
local GREEN = R("#24544a", "#3f9150", "#5aa955", "#7cc35a", "#a0d468", "#c4e07a", "#effac8")
local BLUE = R("#2a3a7a", "#3a5ab0", "#4a70c8", "#5f8ade", "#86aaf0", "#b6d0ff", "#eef4ff")
local VIOLET = R("#35295f", "#5a459e", "#6f58b8", "#8a6fd0", "#a98ee0", "#c9b2f0", "#eee4ff")
local GOLD = R("#8f4a1f", "#d98322", "#e89e28", "#f5b82e", "#ffd257", "#ffe38a", "#fff6cf")
local CREAM = "#fff4d6"

local function part(c, m, ramp, ws, wl, o) o = o or {} o.ws, o.wl, o.ramp = ws or 1, wl or 1, ramp o.layer = o.layer c:part(m, o) end
local function tone(c, x, y, h, layer) c:put(x, y, h, layer or "detail") end
local function eye(c, x, y, ring)   -- bead eye, 4x4: pale ring, 2x2 ink, cream glint upper-left
  local rows = { ".rr.", "rc#r", "r##r", ".rr." }
  for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i)
    if ch == 'r' then tone(c, x + i - 1, y + j - 1, ring) elseif ch == 'c' then tone(c, x + i - 1, y + j - 1, CREAM) elseif ch == '#' then tone(c, x + i - 1, y + j - 1, '#') end
  end end
end
local function rays(c, fin, from, tos, col)
  local inner = fin:copy():cut(fin:edge())
  for _, t in ipairs(tos) do L.line({ from, t }):each(function(x, y) if inner:has(x, y) then tone(c, x, y, col) end end) end
end
local function scallops(c, region, sx, sy, col, lit)   -- staggered scale arcs: 3px 'u' with a lit pixel above
  region:each(function(x, y)
    local row = y // sy
    if y % sy == 0 and (x + (row % 2) * (sx // 2)) % sx == 0 then
      for _, p in ipairs({ { -1, 0, col }, { 0, 1, col }, { 1, 0, col }, { 0, -1, lit } }) do
        if region:has(x + p[1], y + p[2]) and p[3] then tone(c, x + p[1], y + p[2], p[3]) end
      end
    end
  end)
end
local function sparkle(c, x, y, core, arm, notobj)
  for _, p in ipairs({ { 0, 0, core }, { 1, 0, arm }, { -1, 0, arm }, { 0, 1, arm }, { 0, -1, arm } }) do c:put(x + p[1], y + p[2], p[3], "detail", notobj) end
end
local function done(c, name)
  c:outline()
  c:save(OUT, name)
  print(name, "colours", c:colours(), "spurs", table.concat(c:spurs(), " "))
end

-- 1 plain ------------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 48)
  local tail = L.poly({ { 31, 24 }, { 43, 14 }, { 39.5, 24 }, { 43, 34 } })
  local dors = L.poly({ { 13, 17 }, { 21, 10.5 }, { 27, 13 }, { 28, 18 } })
  local vent = L.poly({ { 17, 30 }, { 23, 36.5 }, { 26, 30 } })
  part(c, tail, ORANGE, 1, 1) part(c, dors, ORANGE, 1, 1) part(c, vent, ORANGE, 1, 1)
  rays(c, tail, { 32, 24 }, { { 42, 16 }, { 40, 20 }, { 40, 28 }, { 42, 32 } }, ORANGE.s)
  rays(c, dors, { 20, 18 }, { { 16, 15 }, { 20, 12 }, { 24, 12 } }, ORANGE.s)
  local body = L.ellipse(20, 24, 13, 8.4):add(L.poly({ { 5, 23 }, { 9, 18 }, { 9, 29 } }))
  part(c, body, ORANGE, 2, 2)
  -- gill arc + scale rows behind it
  local gill = L.line({ { 15, 18 }, { 14, 20 }, { 13, 23 }, { 13, 25 }, { 14, 28 }, { 15, 30 } })
  gill:each(function(x, y) if body:has(x, y) then tone(c, x, y, ORANGE.s) if body:has(x + 1, y) then tone(c, x + 1, y, ORANGE.L) end end end)
  local sc = body:copy():filter(function(x, y) return x >= 18 and x <= 30 and y >= 19 and y <= 29 end)
  scallops(c, sc, 4, 3, ORANGE.b, ORANGE.l)
  -- pectoral fan
  local pec = L.poly({ { 17, 25 }, { 22, 23 }, { 22, 28 } })
  part(c, pec, ORANGE, 1, 1, { ao = false }) rays(c, pec:grow(1), { 17, 25 }, { { 22, 24 }, { 22, 27 } }, ORANGE.s)
  eye(c, 9, 20, ORANGE.g)
  tone(c, 6, 25, ORANGE.D) tone(c, 7, 25, ORANGE.D)
  tone(c, 15, 18, ORANGE.g) tone(c, 16, 17, ORANGE.g) tone(c, 17, 17, ORANGE.g)   -- one lit glint on the brow
  -- quirk: a bubble rising from the mouth (no ink ring: it is air)
  for _, p in ipairs({ { 2, 18, "#3a86b0" }, { 3, 17, "#3a86b0" }, { 4, 18, "#3a86b0" }, { 3, 19, "#3a86b0" }, { 3, 18, "#b6f0e0" }, { 2, 17, CREAM },
                       { 4, 14, "#3a86b0" }, { 5, 15, "#b6f0e0" } }) do c:put(p[1], p[2], p[3], "detail", true) end
  done(c, "cf-fish-1")
end

-- 2 silk -------------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 48)
  local rib2, T2 = L.tube({ { 25, 23 }, { 30, 28 }, { 30, 34 }, { 26, 38 }, { 23, 39 } }, function(t) return 2.6 - 1.5 * t end)
  local rib1, T1 = L.tube({ { 25, 19 }, { 32, 18 }, { 37, 22 }, { 38, 29 }, { 35, 34 }, { 37, 39 }, { 41, 40 } }, function(t) return 3.4 - 2.2 * t end)
  part(c, rib2, PINK, 1, 1, { lift = -1 }) part(c, rib1, PINK, 1, 1)
  -- silk sheen: a lit streak running along each ribbon
  for _, R2 in ipairs({ { rib1, T1 }, { rib2, T2 } }) do
    R2[1]:each(function(x, y) local t = R2[2][K(x, y)] if t and t > 0.1 and t < 0.75 and not R2[1]:has(x - 2, y - 2) and R2[1]:has(x + 1, y + 1) and R2[1]:has(x - 1, y - 1) then tone(c, x, y, PINK.g) end end)
  end
  local sail = L.poly({ { 10, 14 }, { 17, 5 }, { 23, 6 }, { 25, 15 } })
  part(c, sail, PINK, 1, 1)
  rays(c, sail, { 17, 15 }, { { 15, 8 }, { 18, 6 }, { 21, 7 }, { 23, 10 } }, PINK.s)
  local belly = L.poly({ { 13, 26 }, { 20, 33 }, { 22, 26 } })
  part(c, belly, PINK, 1, 1)
  rays(c, belly, { 16, 26 }, { { 19, 31 }, { 21, 29 } }, PINK.s)
  local body = L.ellipse(17, 20, 10.5, 7):add(L.poly({ { 4, 19 }, { 8, 15 }, { 8, 24 } }))
  part(c, body, PINK, 2, 2)
  scallops(c, body:filter(function(x, y) return x >= 14 and x <= 25 and y >= 16 and y <= 24 end), 4, 3, PINK.b, PINK.L)
  L.line({ { 12, 15 }, { 11, 18 }, { 11, 21 }, { 12, 24 } }):each(function(x, y) tone(c, x, y, PINK.s) tone(c, x + 1, y, PINK.L) end)
  eye(c, 6, 17, PINK.g)
  tone(c, 5, 21, PINK.D)
  tone(c, 12, 14, PINK.g) tone(c, 13, 14, PINK.g)
  -- quirk: red bow at the tail root
  local BOW = { "ee.ee", "eEkEe", "eE.Ee" }
  local BC = { e = "#e8493b", E = "#b52e3f", k = "#6e2038" }
  for j, row in ipairs(BOW) do for i = 1, 5 do local ch = row:sub(i, i) if ch ~= '.' then tone(c, 24 + i, 18 + j, BC[ch]) end end end
  tone(c, 25, 19, "#ff8a5c")
  done(c, "cf-fish-2")
end

-- 3 catnip -----------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 48)
  local tailA = L.poly({ { 32, 25 }, { 38, 16 }, { 43, 15 }, { 40, 22 } })
  local tailB = L.poly({ { 32, 26 }, { 40, 29 }, { 43, 36 }, { 37, 35 } })
  part(c, tailA, GREEN, 1, 1) part(c, tailB, GREEN, 1, 1, { lift = -1 })
  L.line({ { 33, 24 }, { 41, 16 } }):each(function(x, y) if tailA:has(x, y) then tone(c, x, y, GREEN.L) end end)
  L.line({ { 33, 27 }, { 41, 34 } }):each(function(x, y) if tailB:has(x, y) then tone(c, x, y, GREEN.l) end end)
  -- sprout: stem + two round leaves
  local stem = L.line({ { 20, 17 }, { 20, 14 }, { 21, 11 } })
  stem:each(function(x, y) c:put(x, y, GREEN.s, "detail") c:put(x + 1, y, GREEN.l, "detail") end)
  local lf1, lf2 = L.ellipse(17, 9.5, 3.4, 2), L.ellipse(25, 8.5, 3.4, 2)
  part(c, lf1, GREEN, 1, 1) part(c, lf2, GREEN, 1, 1)
  L.line({ { 15, 10 }, { 19, 9 } }):each(function(x, y) tone(c, x, y, GREEN.s) end)
  L.line({ { 23, 9 }, { 27, 8 } }):each(function(x, y) tone(c, x, y, GREEN.s) end)
  -- leaf-shaped plush body (a lens, pointed nose and tail root)
  local body = L.mask()
  for y = 13, 36 do for x = 4, 34 do
    local u = (x - 19) / 15
    local hw = 10.2 * (1 - u * u) ^ 0.8
    if math.abs(u) <= 1 and math.abs(y - 24.5) <= hw then body:set(x, y) end
  end end
  part(c, body, GREEN, 2, 3)
  -- midrib + paired veins (the "scales")
  L.line({ { 9, 25 }, { 32, 25 } }):each(function(x, y) if body:has(x, y) then tone(c, x, y, GREEN.L) tone(c, x, y + 1, GREEN.s) end end)
  for _, vx in ipairs({ 15, 20, 25, 29 }) do
    L.line({ { vx, 24 }, { vx + 4, 19 } }):each(function(x, y) if body:has(x, y) and body:has(x, y - 1) then tone(c, x, y, GREEN.l) end end)
    L.line({ { vx, 26 }, { vx + 4, 31 } }):each(function(x, y) if body:has(x, y) and body:has(x, y + 1) then tone(c, x, y, GREEN.b) end end)
  end
  eye(c, 9, 20, GREEN.g)
  tone(c, 11, 25, "#e8909e") tone(c, 12, 25, "#e8909e")   -- plush blush
  tone(c, 6, 26, GREEN.D)
  -- one gold seam stitch along the belly (2 on, 1 off)
  local i = 0
  L.line({ { 12, 32 }, { 17, 34 }, { 25, 34 }, { 29, 32 } }):each(function(x, y) i = i + 1 if body:has(x, y) and i % 3 ~= 0 then tone(c, x, y, "#f5b82e") end end)
  tone(c, 13, 17, GREEN.g) tone(c, 14, 16, GREEN.g)
  done(c, "cf-fish-3")
end

-- 4 glitter ----------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 48)
  local tail = L.poly({ { 33, 25 }, { 41, 15 }, { 43, 16 }, { 39, 25 }, { 43, 34 }, { 41, 35 } })
  part(c, tail, VIOLET, 1, 1)
  rays(c, tail:grow(1), { 34, 25 }, { { 41, 17 }, { 40, 21 }, { 40, 29 }, { 41, 33 } }, VIOLET.s)
  local crest = L.poly({ { 11, 20 }, { 12, 12 }, { 15, 17 }, { 18, 10 }, { 21, 16 }, { 24, 10 }, { 27, 17 }, { 30, 13 }, { 31, 20 } })
  part(c, crest, VIOLET, 1, 1)
  local vent = L.poly({ { 18, 30 }, { 22, 36 }, { 25, 30 } })
  part(c, vent, VIOLET, 1, 1)
  local body = L.ellipse(21, 25, 14, 6.6):add(L.poly({ { 4, 25 }, { 9, 20 }, { 9, 30 } }))
  part(c, body, BLUE, 2, 2)
  -- diamond scale lattice
  body:each(function(x, y) if x > 15 and x < 32 and y > 20 and y < 30 and (x + y) % 4 == 0 and (x - y) % 4 == 0 then tone(c, x, y, BLUE.b) end end)
  L.line({ { 14, 20 }, { 13, 23 }, { 13, 27 }, { 14, 30 } }):each(function(x, y) tone(c, x, y, BLUE.s) tone(c, x + 1, y, BLUE.L) end)
  eye(c, 8, 22, BLUE.g)
  tone(c, 5, 26, BLUE.D)
  -- glitter: three cream 4-point sparkles on the flank
  sparkle(c, 20, 23, CREAM, BLUE.L) sparkle(c, 27, 26, CREAM, BLUE.L) sparkle(c, 24, 29, BLUE.g, BLUE.l)
  -- quirk: sparkle trail drifting off the tail
  sparkle(c, 44, 9, CREAM, VIOLET.m, true) c:put(41, 5, VIOLET.L, "detail", true) c:put(46, 13, VIOLET.m, "detail", true)
  done(c, "cf-fish-4")
end

-- 5 golden -----------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 48)
  local tail = L.poly({ { 31, 28 }, { 41, 18 }, { 44, 22 }, { 45, 28 }, { 44, 34 }, { 41, 38 } })
  part(c, tail, GOLD, 1, 1)
  rays(c, tail, { 32, 28 }, { { 41, 20 }, { 43, 24 }, { 44, 28 }, { 43, 32 }, { 41, 36 } }, GOLD.s)
  local vent = L.poly({ { 17, 35 }, { 21, 41 }, { 25, 35 } })
  part(c, vent, GOLD, 1, 1)
  local body = L.ellipse(20, 28, 13, 9.6):add(L.poly({ { 5, 28 }, { 9, 22 }, { 9, 34 } }))
  part(c, body, GOLD, 2, 2)
  scallops(c, body:filter(function(x, y) return x >= 17 and x <= 31 and y >= 22 and y <= 35 end), 5, 4, GOLD.b, GOLD.L)
  L.line({ { 14, 21 }, { 13, 24 }, { 12, 28 }, { 13, 32 }, { 14, 35 } }):each(function(x, y) tone(c, x, y, GOLD.s) tone(c, x + 1, y, GOLD.L) end)
  eye(c, 8, 24, GOLD.g)
  tone(c, 6, 30, GOLD.D)
  -- polished: two speculars
  tone(c, 16, 21, GOLD.g) tone(c, 17, 21, GOLD.g) tone(c, 16, 22, GOLD.g) tone(c, 23, 20, GOLD.g)
  -- quirk: crown tipped askew, one ruby
  local crown = L.poly({ { 12, 19 }, { 11, 12 }, { 14, 15 }, { 17, 9 }, { 20, 14 }, { 24, 10 }, { 25, 18 } })
  part(c, crown, GOLD, 1, 1, { ao = true })
  L.line({ { 12, 18 }, { 24, 17 } }):each(function(x, y) if crown:has(x, y) then tone(c, x, y, GOLD.s) end end)
  L.line({ { 12, 17 }, { 24, 16 } }):each(function(x, y) if crown:has(x, y) then tone(c, x, y, GOLD.L) end end)
  tone(c, 17, 13, "#e8493b") tone(c, 18, 13, "#b52e3f") tone(c, 17, 14, "#b52e3f") tone(c, 18, 14, "#6e2038") tone(c, 17, 12, "#ff8a5c")
  for _, p in ipairs({ { 11, 12 }, { 17, 9 }, { 24, 10 } }) do tone(c, p[1], p[2], GOLD.g) end
  done(c, "cf-fish-5")
end
