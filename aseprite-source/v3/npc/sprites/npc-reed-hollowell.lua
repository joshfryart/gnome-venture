-- npc-reed-hollowell sprite (npc2 P1_32) species: frog
-- Reed Hollowell: cheerful pond frog in an amber hood and red smock, eye domes poking over the hood.
-- prop: a cattail reed staff. 64x96 cell, feet baseline y=90, idle 4f (base, breath+leaf droop, base, blink+cattail sway).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-reed-hollowell"
local SKIN, HOOD, TUN = P.moss, P.gold, P.ember
local STALK = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1d3a36" }
local CAT = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2420" }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, sw, lf = p.b or 0, p.sw or 0, p.lf or 0
  c:groundShadow(32, 89.5, 15, 3)
  -- cattail staff, planted right of the frog
  local sx = 48
  c:part(c:rect(sx, 40, sx + 1, 89), STALK, { band = 1, nopop = true })
  c:part(c:line({ { sx + 1, 64 }, { 53, 58 }, { 55, 53 + lf } }, 1), STALK, { band = 1, nopop = true })
  c:part(c:rrect(sx - 1 + sw, 28, sx + 2 + sw, 41, 1), CAT, { band = 1, pop = { x = sx - 1 + sw, y = 30, horizontal = false } })
  c:part(c:rect(sx + sw, 24, sx + sw, 27), STALK, { noshade = true, nopop = true })
  -- webbed feet (fixed)
  for _, fx in ipairs{ 26, 38 } do
    c:part(c:ellipse(fx, 88, 4.5, 2), SKIN, { band = 1, nopop = true })
    c:put(fx - 2, 89, SKIN.deep) c:put(fx + 1, 89, SKIN.deep)
  end
  -- squat haunches
  for i, hx in ipairs{ 24, 40 } do c:part(c:ellipse(hx, 82 + b, 5, 4), SKIN, { band = 2, nopop = i == 2 }) end
  -- red smock
  local tun = c:ellipse(32, 73 + b, 11, 10):clip(c:rect(0, 0, 63, 84 + b))
  tun:add(c:poly{ { 22, 76 + b }, { 42, 76 + b }, { 44, 84 + b }, { 20, 84 + b } })
  c:part(tun, TUN, { band = 2 })
  c:paint({ "d...d", ".d.d.", "..d.." }, 30, 64 + b, { d = "ember.deep" })
  c:put(32, 70 + b, P.gold.base) c:put(32, 75 + b, P.gold.base)
  -- arms: left hangs, right grips the reed
  c:part(c:ellipse(20.5, 71 + b, 2.5, 4), TUN, { band = 1, nopop = true })
  c:part(c:ellipse(20.5, 76 + b, 2, 2), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(44, 69 + b, 3, 3), TUN, { band = 1, nopop = true })
  c:part(c:ellipse(sx + 0.5, 70 + b, 2.5, 2), SKIN, { band = 1, nopop = true })
  -- amber hood with seam
  local hood = c:ellipse(32, 48 + b, 17, 14)
  hood:add(c:ellipse(32, 62 + b, 15, 4))
  c:part(hood, HOOD, { band = 2, pop = { x = 20, y = 42 + b } })
  for y = 35, 40 do c:put(32, y + b, HOOD.shade) end
  -- wide frog face
  c:part(c:ellipse(32, 53 + b, 13, 8.5), SKIN, { band = 2, pop = { x = 24, y = 48 + b } })
  -- eye domes over the hood
  for _, ex in ipairs{ 25, 39 } do
    c:part(c:ellipse(ex, 39 + b, 5.5, 5), SKIN, { band = 1, pop = { x = ex - 4, y = 36 + b } })
    if p.blink then
      c:fillMask(c:rect(ex - 2, 37 + b, ex + 2, 38 + b), SKIN.shade)
      for x = ex - 2, ex + 2 do c:put(x, 39 + b, P.ink) end
    else
      c:eyeLocked(ex - 2, 37 + b)
      c:put(ex - 1, 42 + b, P.gold.base) c:put(ex, 42 + b, P.gold.base) c:put(ex + 1, 42 + b, P.gold.shade)
    end
  end
  -- nostrils, big smile, spots, cheeks
  c:put(30, 50 + b, P.ink) c:put(34, 50 + b, P.ink) c:put(29, 49 + b, SKIN.hi) c:put(33, 49 + b, SKIN.hi)
  for x = 24, 40 do local d = math.abs(x - 32)
    c:put(x, ((d <= 4 and 56) or (d <= 7 and 55) or 54) + b, P.ink) end
  for _, q in ipairs{ { 22, 49 }, { 23, 49 }, { 42, 48 }, { 41, 58 }, { 24, 58 } } do c:put(q[1], q[2] + b, SKIN.shade) end
  c:cheek(21, 53 + b) c:cheek(42, 53 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, lf = 1 }, { b = 0 }, { b = 0, blink = true, sw = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
