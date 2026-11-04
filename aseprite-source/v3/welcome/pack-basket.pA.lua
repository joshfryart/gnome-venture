-- pack-basket PASS A. 32x32 pack header icon (step 3 "<Village> basket"): small woven wicker basket with a tall
-- twisted handle arch, heaped with an apple, a pear and a plum. Wicker: over-under weave, rolled twisted rim,
-- right-side shade, dark row where fruit meets the rim. Fruit: sphere light snapped to 5-6 tones, one specular each.
-- quirk: a little worm pokes its head out of the apple.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local X = dofile(DIR .. "/../lib/hpx.lua").init(HP)
local K = X.K
local out = app.params.out or (DIR .. "/")
local NAME = app.params.name or "pack-basket.pA"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
local ink = "#2b1c26"

local WICK = { "#4a2a22", "#6b3c26", "#9a5f2f", "#c4843f", "#e0a95a", "#f6d38a" }   -- dark .. light
local APPLE = { "#6e2038", "#9c2640", "#c9353f", "#e8493b", "#ff6f4f", "#ffa27a" }
local PEAR = { "#3d5a2e", "#5f8a35", "#8db83e", "#b8d64e", "#dcec7a" }
local PLUM = { "#35295f", "#4f3a8a", "#6d52b4", "#8f73d6", "#b49cf0" }

-- handle arch (behind everything): 2 px elliptical ring, twisted cane
local outer, inner = c:ellipse(15.5, 16, 11.5, 14), c:ellipse(15.5, 16, 9.5, 12)
local arch = outer:copy():cut(inner):cut(c:rect(0, 16, 31, 31))
arch:each(function(x, y)
  local t = (x + y) % 3
  local lit = (x < 16) and 1 or 0
  local col = (t == 0) and WICK[3 + lit] or WICK[4 + lit]
  if not inner:grow(1):has(x, y) then col = (t == 0) and WICK[4 + lit] or WICK[5 + lit] end
  c:put(x, y, col)
end)

-- fruit
local function fruit(cx, cy, r, ramp, ry)
  local m = c:ellipse(cx, cy, r, ry or r)
  X.tone(c, m, X.light(X.sphere(cx, cy, r, m), { amb = 0.18 }), ramp)
  return m
end
local plum = fruit(16, 9.5, 3.5, PLUM)
local pear = fruit(21.5, 11.5, 4.5, PEAR, 5)
local apple = fruit(10.5, 12, 5.5, APPLE)
-- speculars
c:px(8, 8, "#fff0e0") c:px(19, 8, "#f6ffd0") c:px(14, 7, "#e8dcff")
-- apple stem, pear stem
c:px(11, 6, WICK[2]) c:px(11, 5, WICK[2]) c:px(22, 6, WICK[2]) c:px(23, 5, WICK[2])
-- worm (quirk) out of the apple's upper-left
c:paint({ "pP.", "pek", ".p." }, 5, 6, { p = "petal.base", P = "petal.hi", e = ink, k = "petal.shade" })

-- rim: rolled, twisted
local rim = c:rect(2, 16, 29, 18)
rim:each(function(x, y)
  local t = (x - y) % 4
  local base = (y == 16) and 5 or (y == 17 and 4 or 3)
  if t == 0 then base = base - 1 end
  if x >= 26 then base = base - 1 end
  c:put(x, y, WICK[math.max(1, base)])
end)
-- body: tapered, over-under weave
local body = c:poly{ {3, 19}, {28, 19}, {25, 29}, {6, 29} }
body:each(function(x, y)
  local band = (y - 19) // 2
  local col = x // 3
  local over = (band + col) % 2 == 0
  local tone = over and 5 or 3
  if (y - 19) % 2 == 1 then tone = tone - 1 end
  if x >= 22 then tone = tone - 1 end
  if y >= 27 then tone = tone - 1 end
  if y == 19 then tone = 2 end   -- dark row under the rim
  c:put(x, y, WICK[math.max(1, tone)])
end)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
