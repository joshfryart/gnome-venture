-- npc-zinnia-fuzzbottom sprite (npc2 P1_40) species: bumblebee (gardener)
-- 64x96 2.5D idle(4). Round fuzzy bee in a straw sunhat with a pink ribbon, antennae poking through the crown,
-- glassy wings. Prop: a single orange zinnia bloom held up like a prize.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/npc/sprites/"
local NAME = "npc-zinnia-fuzzbottom"
local GOLDF = { hi = "#ffdc6a", base = "#f2b232", shade = "#c47838", deep = "#86483e" }
local PLUM  = { hi = "#6a5288", base = "#463462", shade = "#35274c", deep = "#30223f" }
local STRAW = { hi = "#fbe7b0", base = "#e8c47a", shade = "#b88a5c", deep = "#7e5a54" }
local RIB   = { hi = "#ff9ec4", base = "#e8628e", shade = "#b03e72", deep = "#762a5a" }
local WING  = { hi = "#eef6f2", base = "#c6e2ec", shade = "#90b2d4", deep = "#687cb0" }
local ZIN   = { hi = "#ffa868", base = "#f0663e", shade = "#b8404a", deep = "#7c2c46" }
local LEAF  = { hi = "#a6d070", base = "#5e9c48", shade = "#3a6a4c", deep = "#2a4842" }

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
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, h, f, w, a = p.b or 0, p.h or 0, p.f or 0, p.w or 0, p.a or 0
  c:groundShadow(32, 89, 13, 2.5)
  -- wings behind the shoulders
  for _, s in ipairs{ -1, 1 } do
    local wm = oval(32 + s * 14, 58 + b, 8, 4.5, s * -(35 + w))
    c:part(wm, WING, { band = 1, nopop = true })
    c:fillMask(c:line({ { 32 + s * 9, 61 + b }, { 32 + s * 18, 56 + b } }, 1):clip(wm:shrink(1)), WING.shade)
    wm:edge():each(function(x, y) if not wm:has(x, y - 1) then c:put(x, y, WING.hi) end end)
  end
  -- feet (fixed)
  for _, fx in ipairs{ 27, 37 } do c:part(c:ellipse(fx, 88, 3, 2), PLUM, { band = 1, nopop = true }) end
  -- fuzzy round body with two plum stripes
  local body = c:ellipse(32, 72 + b, 12, 13)
  for _, q in ipairs{ { 20, 66 }, { 19, 72 }, { 20, 78 }, { 44, 66 }, { 45, 72 }, { 44, 78 }, { 26, 84 }, { 38, 84 } } do body:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(body, GOLDF, { band = 3, pop = { x = 25, y = 63 + b } })
  for x = 0, 63 do
    local z = x % 2
    for _, r in ipairs{ { 70, 73 }, { 78, 81 } } do
      for y = r[1] + z + b, r[2] - z + b do
        if body:has(x, y) then
          local v = c:get(x, y)
          c:put(x, y, (v == GOLDF.shade or v == GOLDF.deep) and PLUM.shade or (v == GOLDF.hi and PLUM.hi or PLUM.base))
        end
      end
    end
  end
  -- arms; right one holds the zinnia
  c:part(c:ellipse(20, 70 + b, 2.5, 3.5), PLUM, { band = 1, nopop = true })
  local fy = 47 + b + f
  c:fillMask(c:line({ { 45, 72 + b }, { 47, 61 + b }, { 48, fy + 2 } }, 1), LEAF.shade)
  c:part(oval(50.5, 62 + b, 3, 1.5, -30), LEAF, { band = 1, nopop = true })
  local pet = HP.mask()
  for k = 0, 9 do local r = k / 10 * 2 * math.pi pet:add(HP.ellipse(48 + math.cos(r) * 3.5, fy + math.sin(r) * 3, 1.8, 1.8)) end
  c:part(pet, ZIN, { band = 2, pop = { x = 45, y = fy - 3 } })
  c:part(c:ellipse(48, fy, 2, 1.5), GOLDF, { band = 1, nopop = true })
  c:put(48, fy, GOLDF.deep) c:put(47, fy - 1, GOLDF.hi)
  c:part(c:ellipse(44, 70 + b, 2.5, 3), PLUM, { band = 1, nopop = true })
  -- head
  local head = c:ellipse(32, 44 + b, 14, 12)
  for _, q in ipairs{ { 18.5, 46 }, { 19.5, 50 }, { 45.5, 46 }, { 44.5, 50 } } do head:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(head, GOLDF, { band = 3, pop = { x = 24, y = 40 + b } })
  -- plum fuzz band under the brim (zigzag edge)
  local band = HP.mask()
  for x = 0, 63 do for y = 30 + b, 39 + b + (x % 2) do if head:has(x, y) then band:set(x, y) end end end
  c:part(band, PLUM, { band = 1, nopop = true })
  -- face
  if p.blink then
    for _, x in ipairs{ 24, 36 } do for i = 0, 3 do c:put(x + i, 44 + b, P.ink) end end
  else eye(c, 24, 41 + b) eye(c, 36, 41 + b) end
  c:put(31, 47 + b, GOLDF.shade) c:put(32, 47 + b, GOLDF.shade) c:put(31, 46 + b, GOLDF.hi)
  for _, d in ipairs{ { 29, 49 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } } do c:put(d[1], d[2] + b, P.ink) end
  for _, x in ipairs{ 22, 23, 41, 42 } do c:put(x, 47 + b, RIB.hi) end
  -- antenna knobs (stalks after outline)
  local ka = { { 25 + a, 15 + b + h }, { 40, 14 + b + h } }
  for _, k in ipairs(ka) do c:part(c:ellipse(k[1], k[2], 2, 2), PLUM, { band = 1, pop = { x = k[1] - 1, y = k[2] - 1 } }) end
  -- straw sunhat: wide brim, round crown, pink ribbon
  local hb = b + h
  local brim = c:ellipse(32, 34 + hb, 17, 4.5)
  c:part(brim, STRAW, { band = 2, pop = { x = 19, y = 33 + hb } })
  for x = 16, 48, 3 do if brim:has(x, 36 + hb) then c:put(x, 36 + hb, STRAW.shade) end end
  local crown = c:rrect(25, 23 + hb, 39, 33 + hb, 4)
  c:part(crown, STRAW, { band = 2, pop = { x = 27, y = 25 + hb } })
  for x = 25, 39 do for y = 29 + hb, 31 + hb do if crown:has(x, y) then c:put(x, y, y == 31 + hb and RIB.shade or (x > 35 and RIB.shade or RIB.base)) end end end
  c:put(27, 29 + hb, RIB.hi) c:put(28, 29 + hb, RIB.hi)
  c:finish{ outline = true }
  c:fillMask(c:line({ { 29, 24 + hb }, { 27 + a, 18 + hb } }, 1), P.ink)
  c:fillMask(c:line({ { 35, 24 + hb }, { 39, 17 + hb } }, 1), P.ink)
  HP.assertClean(c)
  return c
end

local function build(frames, base)
  local pc = app.pixelColor
  local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
  local imgs = {}
  for f, c in ipairs(frames) do
    local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
    for y = 0, 95 do for x = 0, 63 do local h = c:get(x, y) if h then im:putPixel(x, y, rgba(h)) end end end
    imgs[f] = im
  end
  local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * 64, 0)) end
  local s = Sprite(256, 96, ColorMode.RGB) s.cels[1].image = strip s:saveCopyAs(base .. ".png") s:close()
  local spr = Sprite(64, 96, ColorMode.RGB)
  for _ = 2, 4 do spr:newEmptyFrame() end
  for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
  local tg = spr:newTag(1, 4) tg.name = "idle"
  spr:saveAs(base .. ".aseprite") spr:close()
end

local F = {}
for _, p in ipairs{ { b = 0 }, { b = 1, h = 1, f = 1 }, { b = 0 }, { b = 0, blink = true, w = 12, a = -1 } } do F[#F + 1] = frame(p) end
build(F, out .. NAME)
print(NAME .. " ok")
