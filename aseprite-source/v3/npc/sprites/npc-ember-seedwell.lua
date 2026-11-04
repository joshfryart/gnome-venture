-- npc-ember-seedwell sprite (npc2 P1_9) species: snail
-- Ember Seedwell: patient snail seed-keeper. Red pillbox hat, grey-violet coat, brown spiral shell; prop: clay pot with a sprout.
-- No legs: one wide snail foot (static). 64x96 cell, feet baseline y=90, idle 4 frames (breath, sprout droop, eyestalk twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-ember-seedwell"
local SLUG  = { hi = "#fff0c8", base = "#ecc995", shade = "#c4936f", deep = "#85564b" }
local SHELL = { hi = "#e8a86a", base = "#b8693e", shade = "#7f4034", deep = "#4e2a3f" }
local COAT  = { hi = "#d8d3dc", base = "#a39cad", shade = "#706984", deep = "#463f5e" }
local CLAY  = { hi = "#f7b27a", base = "#e07a48", shade = "#a84a3c", deep = "#68283a" }
local HATTOP = { hi = "#ffb08a", base = P.ember.hi, shade = P.ember.base, deep = P.ember.shade }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, lf, tw = p.b or 0, p.lf or 0, p.tw or 0
  c:groundShadow(32, 88.5, 17, 3)
  -- spiral shell on the back
  local sh = c:ellipse(46, 63 + b, 11, 11)
  c:part(sh, SHELL, { band = 2, pop = { 39, 56 + b } })
  local pts = {}
  for i = 0, 100 do local t = i / 100 local a = math.rad(160) + t * 2.3 * 2 * math.pi local r = 9.5 * (1 - t)
    pts[#pts + 1] = { math.floor(46 + math.cos(a) * r + .5), math.floor(63 + b + math.sin(a) * r + .5) } end
  c:fillMask(c:line(pts, 1):clip(sh:shrink(1)), SHELL.deep)
  for _, q in ipairs{ { 39, 57 }, { 40, 56 }, { 41, 55 } } do c:put(q[1], q[2] + b, SHELL.hi) end
  -- wide snail foot (static) with a slime glint
  c:part(c:ellipse(32, 87, 15, 3.5), SLUG, { band = 1, pop = { 20, 86 } })
  -- body column + coat
  local body = c:ellipse(32, 74 + b, 11, 12)
  c:part(body, SLUG, { band = 2 })
  local coat = body:copy():clip(c:rect(0, 67 + b, 63, 95)):cut(c:poly{ { 29, 66 + b }, { 35, 66 + b }, { 32, 71 + b } })
  c:part(coat, COAT, { band = 2, pop = { 23, 70 + b } })
  for y = 71, 84 do c:put(32, y + b, COAT.deep) end
  c:fillMask(c:rect(33, 80 + b, 34, 81 + b), P.gold.base) c:fillMask(c:rect(33, 84 + b, 34, 85 + b), P.gold.base)
  c:part(c:ellipse(21, 72 + b, 3, 4.5), COAT, { band = 1, nopop = true }) c:part(c:ellipse(43, 72 + b, 3, 4.5), COAT, { band = 1, nopop = true })
  -- clay pot + sprout, held in both hands
  c:part(c:poly{ { 27, 75 + b }, { 37, 75 + b }, { 36, 81 + b }, { 28, 81 + b } }, CLAY, { band = 1, nopop = true })
  c:part(c:rect(26, 73 + b, 37, 74 + b), CLAY, { band = 1, pop = { 27, 73 + b } })
  c:part(c:ellipse(25, 76 + b, 2, 2), SLUG, { band = 1, nopop = true }) c:part(c:ellipse(38, 76 + b, 2, 2), SLUG, { band = 1, nopop = true })
  for y = 68 + b + lf, 72 + b do c:put(32, y, P.moss.shade) end
  c:part(c:ellipse(29.5, 68 + b + lf, 2.5, 1.5), "moss", { band = 1, nopop = true })
  c:part(c:ellipse(34.5, 67 + b + lf, 2.5, 1.5), "moss", { band = 1, nopop = true })
  c:put(29, 67 + b + lf, P.moss.hi)
  -- eyestalks (behind head and hat)
  c:part(c:line({ { 27, 43 + b }, { 25, 34 + b }, { 24, 28 + b } }, 2), SLUG, { band = 1, nopop = true })
  c:part(c:line({ { 37, 43 + b }, { 39, 34 + b }, { 40 + tw, 28 + b } }, 2), SLUG, { band = 1, nopop = true })
  c:part(c:ellipse(24, 26 + b, 3.5, 3), SLUG, { band = 1, nopop = true })
  c:part(c:ellipse(40 + tw, 26 + b, 3.5, 3), SLUG, { band = 1, nopop = true })
  local function eye(x, y)
    c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
    for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do c:put(x + q[1], y + q[2], P.cream) end
    c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
  end
  eye(22, 23 + b) eye(38 + tw, 23 + b)
  -- head
  c:part(c:ellipse(32, 51 + b, 14, 12), SLUG, { band = 3, pop = { 23, 45 + b } })
  c:part(c:ellipse(32, 56 + b, 4, 2.5), SLUG, { band = 1, pop = { 30, 55 + b } })   -- snout nub
  c:paint({ "i..i", ".ii." }, 30, 59 + b, { i = "ink" })
  c:cheek(22, 55 + b) c:cheek(40, 55 + b)
  -- red pillbox hat with gold band and button
  c:part(c:rect(25, 36 + b, 38, 42 + b), P.ember, { band = 2, nopop = true })
  c:part(c:ellipse(32, 36 + b, 6.5, 2), HATTOP, { band = 1, pop = { 28, 35 + b } })
  c:stitch{ { 25, 41 + b }, { 38, 41 + b } }
  c:part(c:rect(31, 33 + b + (p.hs or 0), 32, 34 + b), "gold", { band = 1, nopop = true })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1, lf = 1 }, {}, { tw = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
