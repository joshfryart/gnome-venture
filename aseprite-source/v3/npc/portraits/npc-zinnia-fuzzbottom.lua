-- npc-zinnia-fuzzbottom portrait (npc2 P1_40) species: bumblebee (gardener)
-- 80x100 head+shoulders. Same design as the sprite: straw sunhat with pink ribbon, antennae through the crown,
-- plum fuzz band, glassy wings, plum body stripe. Prop: orange zinnia bloom held in the right paw.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/npc/portraits/"
local NAME = "npc-zinnia-fuzzbottom"
local GOLDF = { hi = "#ffdc6a", base = "#f2b232", shade = "#c47838", deep = "#86483e" }
local PLUM  = { hi = "#6a5288", base = "#463462", shade = "#35274c", deep = "#30223f" }
local STRAW = { hi = "#fbe7b0", base = "#e8c47a", shade = "#b88a5c", deep = "#7e5a54" }
local RIB   = { hi = "#ff9ec4", base = "#e8628e", shade = "#b03e72", deep = "#762a5a" }
local WING  = { hi = "#eef6f2", base = "#c6e2ec", shade = "#90b2d4", deep = "#687cb0" }
local ZIN   = { hi = "#ffa868", base = "#f0663e", shade = "#b8404a", deep = "#7c2c46" }
local LEAF  = { hi = "#a6d070", base = "#5e9c48", shade = "#3a6a4c", deep = "#2a4842" }
local BG    = { base = "#f29ac0", shade = "#cc6c9a", deep = "#a04c7c" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- wings
for _, s in ipairs{ -1, 1 } do
  local wm = oval(39.5 + s * 25, 68, 11, 5.5, s * -40)
  c:part(wm, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + s * 18, 74 }, { 39.5 + s * 31, 62 } }, 1):clip(wm:shrink(1)), WING.shade)
  wm:edge():each(function(x, y) if not wm:has(x, y - 1) then c:put(x, y, WING.hi) end end)
end
-- fuzzy body + plum stripe
local body = c:ellipse(39.5, 108, 33, 34):clip(c:rect(0, 75, 79, 99))
for _, q in ipairs{ { 10, 90 }, { 13, 84 }, { 18, 79 }, { 61, 79 }, { 66, 84 }, { 69, 90 } } do body:add(HP.ellipse(q[1], q[2], 2, 2)) end
c:part(body, GOLDF, { band = 3, pop = { x = 15, y = 86 } })
for x = 0, 79 do local z = x % 2
  for y = 88 + z, 94 - z do if body:has(x, y) then local v = c:get(x, y)
    c:put(x, y, (v == GOLDF.shade or v == GOLDF.deep) and PLUM.shade or PLUM.base) end end end
for y = 78, 98, 4 do for x = (y % 8 == 2) and 14 or 16, 66, 6 do
  if body:has(x, y) and body:has(x, y + 1) then local v = c:get(x, y)
    local m = { [GOLDF.base] = GOLDF.shade, [GOLDF.hi] = GOLDF.base, [PLUM.base] = PLUM.hi }
    if m[v] then c:put(x, y, m[v]) end end end end
-- head
local head = c:ellipse(39.5, 55, 20, 17)
for _, q in ipairs{ { 20, 60 }, { 22, 65 }, { 59, 60 }, { 57, 65 } } do head:add(HP.ellipse(q[1], q[2], 2, 2)) end
c:part(head, GOLDF, { band = 3, pop = { x = 27, y = 48 } })
for _, d in ipairs{ { 31, 68 }, { 36, 70 }, { 44, 70 }, { 48, 68 }, { 24, 64 } } do c:put(d[1], d[2], GOLDF.shade) c:put(d[1], d[2] + 1, GOLDF.shade) end
-- plum fuzz band (zigzag) under brim
local band = HP.mask()
for x = 0, 79 do for y = 36, 46 + (x % 2) do if head:has(x, y) then band:set(x, y) end end end
c:part(band, PLUM, { band = 1, nopop = true })
-- face
c:eyeLocked(29, 49) c:eyeLocked(46, 49)
c:put(28, 49, P.ink) c:put(27, 48, P.ink) c:put(51, 49, P.ink) c:put(52, 48, P.ink)
c:part(c:ellipse(39.5, 57.5, 2.5, 2), { hi = GOLDF.hi, base = GOLDF.shade, shade = GOLDF.deep, deep = GOLDF.deep }, { band = 1, pop = { x = 38, y = 56 } })
for _, d in ipairs{ { 35, 61 }, { 36, 62 }, { 37, 63 }, { 38, 63 }, { 39, 63 }, { 40, 63 }, { 41, 63 }, { 42, 63 }, { 43, 62 }, { 44, 61 } } do c:put(d[1], d[2], P.ink) end
for _, d in ipairs{ { 39, 64 }, { 40, 64 } } do c:put(d[1], d[2], RIB.base) end
for y = 57, 58 do for _, x in ipairs{ 24, 25, 26, 53, 54, 55 } do c:put(x, y, RIB.hi) end end
-- antenna knobs
c:part(c:ellipse(27, 10, 2.5, 2.5), PLUM, { band = 1, pop = { x = 26, y = 9 } })
c:part(c:ellipse(54, 11, 2.5, 2.5), PLUM, { band = 1, pop = { x = 53, y = 10 } })
-- straw sunhat
local brim = c:ellipse(39.5, 40, 27, 6)
c:part(brim, STRAW, { band = 2, pop = { x = 18, y = 38 } })
for x = 15, 64, 3 do if brim:has(x, 43) then c:put(x, 43, STRAW.shade) end if brim:has(x + 1, 38) and (x < 26 or x > 53) then c:put(x + 1, 38, STRAW.shade) end end
local crown = c:rrect(27, 22, 52, 39, 6)
c:part(crown, STRAW, { band = 2, pop = { x = 30, y = 25 } })
for x = 29, 50, 3 do for y = 25, 32, 3 do if crown:has(x, y) then c:put(x, y, STRAW.shade) end end end
for x = 27, 52 do for y = 33, 37 do if crown:has(x, y) then c:put(x, y, (y == 37 or x > 47) and RIB.shade or (y == 33 and RIB.hi or RIB.base)) end end end
c:put(34, 23, STRAW.deep) c:put(45, 23, STRAW.deep)
-- zinnia in the right paw
c:fillMask(c:line({ { 61, 99 }, { 63, 82 }, { 65, 72 } }, 2), LEAF.base)
c:part(oval(70, 86, 5, 2.5, -30), LEAF, { band = 1, pop = { x = 67, y = 85 } })
local pet = HP.mask()
for k = 0, 11 do local r = k / 12 * 2 * math.pi pet:add(HP.ellipse(65 + math.cos(r) * 6.5, 67 + math.sin(r) * 6, 2.3, 2.3)) end
c:part(pet, ZIN, { band = 2, pop = { x = 61, y = 61 } })
local inner = HP.mask()
for k = 0, 7 do local r = (k + 0.5) / 8 * 2 * math.pi inner:add(HP.ellipse(65 + math.cos(r) * 3.5, 67 + math.sin(r) * 3.2, 1.5, 1.5)) end
c:part(inner, { hi = ZIN.hi, base = ZIN.hi, shade = ZIN.base, deep = ZIN.shade }, { band = 1, nopop = true })
c:part(c:ellipse(65, 67, 2, 2), GOLDF, { band = 1, nopop = true })
c:put(65, 67, GOLDF.deep) c:put(64, 66, GOLDF.hi) c:put(66, 68, ZIN.deep)
c:part(c:ellipse(62, 86, 3.5, 3), PLUM, { band = 1, pop = { x = 61, y = 85 } })
c:finish{ outline = true }
c:fillMask(c:line({ { 34, 22 }, { 31, 16 }, { 28, 12 } }, 1), P.ink)
c:fillMask(c:line({ { 45, 22 }, { 49, 16 }, { 53, 13 } }, 1), P.ink)
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
