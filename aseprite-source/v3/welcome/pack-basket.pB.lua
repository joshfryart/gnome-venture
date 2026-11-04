-- pack-basket PASS B (polish over A). 32x32 pack header icon (step 3 "<Village> basket"): small wicker basket,
-- 3 px twisted handle arch with a see-through gap, heaped with a plum, a pear and an apple (with leaf).
-- B: thicker arch with its own lit outer strand, fruit dropped 1 px so the arch opens; deep separation lines and
-- AO where fruits overlap and where they sink into the rim; rope-twist rim; weave with stakes, right-side shade
-- and a dark belly row; bigger worm head with eye; leaves on apple and pear.
-- quirk: a little worm pokes its head out of the apple.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-basket.pB"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
local ink = "#2b1c26"

local WICK  = { "#4a2a22", "#6b3c26", "#9a5f2f", "#c4843f", "#e0a95a", "#f6d38a" }   -- dark .. light
local APPLE = { "#6e2038", "#9c2640", "#c9353f", "#e8493b", "#ff6f4f", "#ffa27a" }
local PEAR  = { "#2f5230", "#4f8435", "#7fb23c", "#acd24a", "#d6ea78" }
local PLUM  = { "#2c2152", "#4a3684", "#6a4fb2", "#8c70d4", "#b39cf0" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- handle arch: 3 px elliptical ring, twisted cane (outer strand lit, inner strand shaded)
local outer, inner = c:ellipse(15.5, 16, 11.5, 14), c:ellipse(15.5, 16, 8.5, 11)
local arch = outer:copy():cut(inner):cut(c:rect(0, 17, 31, 31))
local mid = c:ellipse(15.5, 16, 10, 12.5)
arch:each(function(x, y)
  local lit = (x <= 15) and 1 or 0
  local tw = (x + y) % 3 == 0
  local t
  if not mid:has(x, y) then t = 4 + lit                          -- outer strand
  elseif not inner:grow(1):has(x, y) then t = 3 + lit            -- middle
  else t = 2 + lit end                                           -- inner strand (faces away)
  if tw then t = t - 1 end
  c:put(x, y, WICK[t])
end)

-- fruit (painted back to front), each with deep separation where it meets an earlier fruit
local placed = HP.mask()
local function fruit(cx, cy, r, ramp, ry)
  local m = c:ellipse(cx, cy, r, ry or r)
  local bias = {}
  X.tone(c, m, X.light(X.sphere(cx, cy, r, m), { amb = 0.18 }), ramp, { bias = bias })
  -- earlier fruit touching this one gets a deep rim + 1 step AO (contact shadow)
  local ring = m:grow(1):cut(m)
  ring:each(function(x, y) if placed:has(x, y) then c:put(x, y, ramp == APPLE and PEAR[1] or PLUM[1]) end end)
  placed:add(m)
  return m
end
local plum = fruit(16, 10.5, 3.5, PLUM)
local pear = fruit(21.5, 12.5, 4.5, PEAR, 5)
-- pear vs plum: deep line on plum
c:ellipse(21.5, 12.5, 5.5, 6):cut(c:ellipse(21.5, 12.5, 4.5, 5)):clip(plum):each(function(x, y) c:put(x, y, PLUM[1]) end)
local apple = fruit(10.5, 13, 5.5, APPLE)
c:ellipse(10.5, 13, 6.5, 6.5):cut(apple):each(function(x, y)
  if pear:has(x, y) then c:put(x, y, PEAR[1]) elseif plum:has(x, y) then c:put(x, y, PLUM[1]) end end)
-- speculars + cool reflected light
c:px(12, 10, "#fff4d6") c:px(13, 10, "#ffd0b0") c:px(19, 9, "#f6ffd0") c:px(14, 8, "#e8dcff")
c:px(15, 16, "#b05a8a") c:px(14, 17, "#b05a8a") c:px(25, 14, "#5f9a7a") c:px(25, 15, "#5f9a7a")
-- stems + leaves
c:px(11, 7, WICK[2]) c:px(11, 6, WICK[2]) c:px(12, 5, WICK[2])
c:paint({ ".ab", "abc", "cc." }, 12, 4, { a = LEAF[4], b = LEAF[3], c = LEAF[2] })
c:px(22, 7, WICK[2]) c:px(23, 6, WICK[2]) c:px(24, 6, LEAF[3]) c:px(25, 6, LEAF[2]) c:px(24, 5, LEAF[4])
-- worm (quirk): pale 3x3 head with an ink eye, peeking out of a dark hole on the apple's lit face
c:paint({
  ".PP.",
  "PPep",
  "oPps",
  ".oo.",
}, 6, 8, { P = "petal.hi", p = "petal.base", s = "petal.shade", e = ink, o = APPLE[1] })

-- rim: rolled rope twist, 3 rows
local rim = c:rect(2, 16, 29, 18)
rim:each(function(x, y)
  local t = ({ [16] = 5, [17] = 4, [18] = 3 })[y]
  if (x - y) % 3 == 0 then t = t - 2 elseif (x - y) % 3 == 1 then t = t + 1 end
  if x >= 25 then t = t - 1 end
  if x <= 4 and y == 16 then t = t + 1 end
  c:put(x, y, WICK[math.max(1, math.min(6, t))])
end)
-- body: tapered, over-under weave with vertical stakes
local body = c:poly{ {3, 19}, {28, 19}, {25, 29}, {6, 29} }
body:each(function(x, y)
  local band = (y - 19) // 2
  local col = (x - 1) // 3
  local over = (band + col) % 2 == 0
  local t = over and 5 or 3
  if (y - 19) % 2 == 1 then t = t - 1 end
  if x >= 23 then t = t - 1 end
  if x <= 6 and over then t = t + 1 end
  if y >= 27 then t = t - 1 end
  if y == 29 then t = 1 end
  if y == 19 then t = 2 end                                     -- AO under the rim
  c:put(x, y, WICK[math.max(1, math.min(6, t))])
end)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
