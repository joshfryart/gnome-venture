-- npc-rowan-burrowman sprite (npc2 P1_32) species: ant
-- Rowan Burrowman: gentle digger ant in a teal hooded cloak and cream bib, elbowed antennae out of the hood,
-- second pair of little arms folded on the bib. prop: a spade planted blade-down. idle 4f (base, breath+antenna droop, base, antenna twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-rowan-burrowman"
local ANT, DARK, HANDLE, HOOD = P.wood, P.skinC, P.skinB, P.sea
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local PLATE = { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ta, tr = p.b or 0, p.ta or 0, p.tr or 0
  c:groundShadow(32, 89.5, 14, 3)
  -- spade, blade-down on the ground (fixed)
  c:part(c:rect(13, 58, 14, 82), HANDLE, { band = 1, nopop = true })
  c:part(c:rect(11, 56, 16, 57), HANDLE, { band = 1, nopop = true })
  local bl = c:rrect(10, 82, 17, 89, 2) bl:add(c:rect(10, 82, 17, 84))
  c:part(bl, P.stone, { band = 1, pop = { x = 11, y = 83 } })
  -- thin legs + round feet (fixed)
  for _, lx in ipairs{ 28, 36 } do
    c:part(c:rect(lx, 84, lx + 1, 88), DARK, { band = 1, nopop = true })
    c:part(c:ellipse(lx + 0.5, 89, 2.5, 1.5), DARK, { band = 1, nopop = true })
  end
  -- bell cloak
  local cloak = c:poly{ { 22, 58 + b }, { 42, 58 + b }, { 47, 84 }, { 17, 84 } }
  cloak:add(c:ellipse(32, 84, 15, 2))
  c:part(cloak, HOOD, { band = 2 })
  -- cream bib + collar points + button
  c:part(c:poly{ { 27, 59 + b }, { 37, 59 + b }, { 36, 74 + b }, { 32, 77 + b }, { 28, 74 + b } }, CR, { band = 1, nopop = true })
  c:paint({ "ss.....ss", ".s.....s." }, 28, 59 + b, { s = "stone.base" })
  c:put(32, 63 + b, P.gold.base) c:put(32, 64 + b, P.gold.shade)
  -- second pair of arms folded on the bib (quirk)
  c:part(c:ellipse(29.5, 70 + b, 2, 1.5), ANT, { band = 1, nopop = true })
  c:part(c:ellipse(34.5, 70 + b, 2, 1.5), ANT, { band = 1, nopop = true })
  -- upper arms: left grips the spade
  c:part(c:ellipse(19, 64 + b, 3, 4.5), HOOD, { band = 1, nopop = true })
  c:part(c:ellipse(15.5, 68 + b, 2, 2), ANT, { band = 1, nopop = true })
  c:part(c:ellipse(45, 64 + b, 3, 4.5), HOOD, { band = 1, nopop = true })
  c:part(c:ellipse(46, 69 + b, 2, 2), ANT, { band = 1, nopop = true })
  -- hood + stitched face opening
  local hood = c:ellipse(32, 43 + b, 16, 16)
  hood:add(c:ellipse(32, 58 + b, 14, 4))
  c:part(hood, HOOD, { band = 2, pop = { x = 21, y = 36 + b } })
  local pts = {}
  for a = 200, 340, 20 do local r = math.rad(a) pts[#pts + 1] = { math.floor(32 + 13.5 * math.cos(r) + .5), math.floor(47 + b + 12.5 * math.sin(r) + .5) } end
  c:stitch(pts)
  -- round brown head
  c:part(c:ellipse(32, 47 + b, 11, 10), ANT, { band = 2, pop = { x = 24, y = 40 + b } })
  if p.blink then
    for _, ex in ipairs{ 25, 35 } do for x = ex, ex + 4 do c:put(x, 46 + b, P.ink) end end
  else c:eyeLocked(25, 44 + b) c:eyeLocked(35, 44 + b) end
  c:part(c:rrect(30, 49 + b, 34, 52 + b, 1), PLATE, { band = 1, nopop = true })
  c:paint({ "d...d", ".d.d." }, 30, 53 + b, { d = "wood.deep" })
  c:cheek(23, 50 + b) c:cheek(39, 50 + b)
  -- antenna knobs
  c:part(c:ellipse(22.5, 22 + b + ta, 1.5, 1.5), DARK, { band = 1, nopop = true })
  c:part(c:ellipse(41.5, 22 + b + tr, 1.5, 1.5), DARK, { band = 1, nopop = true })
  c:finish{ outline = true }
  c:fillMask(c:line({ { 29, 31 + b }, { 27, 26 + b }, { 23, 23 + b + ta } }, 1), P.ink)
  c:fillMask(c:line({ { 35, 31 + b }, { 37, 26 + b }, { 41, 23 + b + tr } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, ta = 1, tr = 1 }, { b = 0 }, { b = 0, ta = -2 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
