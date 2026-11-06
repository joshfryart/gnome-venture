-- npc-didi-marigold sprite (npc2 P1_9) species: red panda
-- Didi Marigold: cheerful red panda knitter. Teal overalls, marigold behind her ear, ringed tail; prop: pink yarn ball.
-- 64x96 cell, 3/4 top-down, feet baseline y=90, idle 4 frames (breath, tail settle, blink + tail flick).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-didi-marigold"
local RUST = { hi = "#f59a52", base = "#d8642f", shade = "#a53f3a", deep = "#6a2540" }
local TAN  = { hi = "#ffe0b0", base = "#e9b57e", shade = "#b97d6a", deep = "#7a4a50" }
local DARK = { hi = "#8a4f4c", base = "#64323f", shade = "#47263f", deep = "#341c33" }
local CR   = { hi = P.cream, base = P.cream, shade = "#dcc6cf", deep = "#a99aae" }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tt = p.b or 0, p.tt or 0
  local function recol(m, map) m:each(function(x, y) local v = map[c:get(x, y) or ""] if v then c:put(x, y, v, c.own[y * c.w + x]) end end) end
  c:groundShadow(32, 88.5, 14, 3)
  -- ringed tail behind, rising up the right side
  local tail = c:line({ { 38, 80 + b }, { 46, 76 + b }, { 50, 68 + b }, { 50 + tt, 61 + b } }, 7)
  tail:add(c:ellipse(50 + tt, 58.5 + b, 3.5, 3.5))
  c:part(tail, RUST, { band = 2 })
  local ring = HP.mask()
  tail:each(function(x, y) if math.floor((y - b - 0.5 * x) / 3) % 2 == 0 then ring:set(x, y) end end)
  recol(ring, { [RUST.hi] = TAN.hi, [RUST.base] = TAN.base, [RUST.shade] = TAN.shade, [RUST.deep] = TAN.deep })
  recol(tail:copy():clip(c:rect(0, 0, 63, 56 + b)), { [RUST.base] = RUST.shade, [TAN.base] = RUST.shade, [TAN.hi] = RUST.base, [RUST.hi] = RUST.base })
  -- dark stubby feet (static)
  c:part(c:ellipse(27, 88, 3.5, 2), DARK, { band = 1 }) c:part(c:ellipse(37, 88, 3.5, 2), DARK, { band = 1 })
  -- body + overalls
  local body = c:ellipse(32, 74 + b, 11, 11)
  c:part(body, RUST, { band = 2 })
  local ov = c:rrect(21, 75 + b, 43, 86 + b, 2):clip(body)
  ov:add(c:rrect(26, 68 + b, 38, 76 + b, 1))
  ov:add(c:line({ { 26, 68 + b }, { 24, 65 + b } }, 2)) ov:add(c:line({ { 38, 68 + b }, { 40, 65 + b } }, 2))
  c:part(ov, "sea", { band = 2, pop = { 27, 69 + b } })
  c:part(c:rect(26, 68 + b, 27, 69 + b), "gold", { band = 1, nopop = true }) c:part(c:rect(37, 68 + b, 38, 69 + b), "gold", { band = 1, nopop = true })
  c:stitch{ { 29, 72 + b }, { 35, 72 + b } }
  -- yarn ball held in front, loose end
  local ball = c:ellipse(32, 77 + b, 5, 4.5)
  c:part(ball, "petal", { band = 2, pop = { 29, 74 + b } })
  c:fillMask(c:line({ { 29, 75 + b }, { 33, 81 + b } }, 1):clip(ball:shrink(1)), P.petal.shade)
  c:fillMask(c:line({ { 32, 73 + b }, { 36, 78 + b } }, 1):clip(ball:shrink(1)), P.petal.shade)
  c:fillMask(c:line({ { 36, 80 + b }, { 39, 82 + b }, { 40 + (p.yf or 0), 84 } }, 1), P.petal.base)
  -- arms + paws
  c:part(c:line({ { 22, 67 + b }, { 26, 75 + b } }, 3), DARK, { band = 1, nopop = true })
  c:part(c:line({ { 42, 67 + b }, { 38, 75 + b } }, 3), DARK, { band = 1, nopop = true })
  c:part(c:ellipse(26.5, 76 + b, 2.5, 2), DARK, { band = 1 }) c:part(c:ellipse(37.5, 76 + b, 2.5, 2), DARK, { band = 1 })
  -- ears (white rims, dark inner), behind head
  local e = p.ear or 0
  c:part(c:poly{ { 18, 46 + b }, { 17, 34 + b }, { 20, 32 + b }, { 28, 39 + b } }, CR, { band = 1, nopop = true })
  c:part(c:poly{ { 20, 42 + b }, { 20, 36 + b }, { 25, 40 + b } }, DARK, { noshade = true, nopop = true })
  c:part(c:poly{ { 46, 46 + b }, { 47 + e, 34 + b + e }, { 44 + e, 32 + b + e }, { 36, 39 + b } }, CR, { band = 1, nopop = true })
  c:part(c:poly{ { 44, 42 + b }, { 44, 36 + b }, { 39, 40 + b } }, DARK, { noshade = true, nopop = true })
  -- head
  c:part(c:ellipse(32, 51 + b, 15.5, 12.5), RUST, { band = 3, pop = { 22, 43 + b } })
  -- marigold tucked by the right ear
  local fl = c:ellipse(45, 39 + b, 2.5, 2.5)
  for _, d in ipairs{ { -2, -1 }, { 2, -1 }, { 0, -3 }, { -2, 2 }, { 2, 2 } } do fl:add(c:ellipse(45 + d[1], 39 + b + d[2], 1.5, 1.5)) end
  c:part(fl, "gold", { band = 1, pop = { 43, 37 + b } })
  c:put(45, 39 + b, P.ember.base) c:put(44, 39 + b, P.ember.shade)
  -- cream mask: cheek ruffs + muzzle + brow spots
  local ck = c:ellipse(19, 56 + b, 4.5, 3.5):add(c:ellipse(45, 56 + b, 4.5, 3.5))
  ck:add(c:ellipse(15, 58 + b, 2, 1.5)):add(c:ellipse(49, 58 + b, 2, 1.5))
  c:part(ck, CR, { band = 1, nopop = true })
  c:part(c:ellipse(32, 57.5 + b, 5.5, 3.5), CR, { band = 1, nopop = true })
  c:fillMask(c:rect(24, 45 + b, 26, 45 + b), P.cream) c:fillMask(c:rect(37, 45 + b, 39, 45 + b), P.cream)
  -- eyes
  local function eye(x, y)
    c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
    for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do c:put(x + q[1], y + q[2], P.cream) end
    c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
  end
  if p.blink then for _, x in ipairs{ 24, 36 } do for i = 0, 3 do c:put(x + i, 49 + b, P.ink) end end
  else eye(24, 47 + b) eye(36, 47 + b) end
  -- tear marks, nose, mouth, blush
  c:put(25, 51 + b, RUST.shade) c:put(25, 52 + b, RUST.shade) c:put(38, 51 + b, RUST.shade) c:put(38, 52 + b, RUST.shade)
  c:paint({ "NNNN", ".NN." }, 30, 55 + b, { N = DARK.base }) c:put(30, 55 + b, DARK.hi)
  c:paint({ "i..i", ".ii." }, 30, 58 + b, { i = "ink" })
  c:cheek(20, 55 + b) c:cheek(42, 55 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1, tt = -1, ear = 1, yf = -1 }, {}, { blink = true, tt = 1, yf = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
