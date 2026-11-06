-- npc-bramble-thornwick portrait (npc2 P1_4) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Prickly hedgehog, head-on: violet-brown spine arch, cream face mask, bead eyes, short snout + big wet nose,
-- tilted blue beret perched in the spines, both paws hugging a basket of blackberries in frame. Petal disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3b2640", shade = "#583a4c", base = "#7e5546", hi = "#b48466", tip = "#ecd2b0" }
local BER = { hi = P.dusk.hi, base = P.dusk.shade, shade = P.dusk.deep, deep = "#24183a" }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-bramble-thornwick", out = app.params.out or (DIR .. "/"), BG = P.petal, SP = SP, seed = 4,
  body = function(c, k)
    c:part(k.torso, k.FACE, { band = 2, inner = false, nopop = true })
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 3, k.crown.y + 2
    local bm = c:ellipse(x, y, 12, 4) bm:add(c:ellipse(x - 2, y - 3, 10, 4)) bm:add(c:ellipse(x - 12, y + 1, 3.5, 2.5))
    c:part(bm, P.sea, { band = 2, inner = false, pop = { x = x - 8, y = y - 5 } })
    HH.under(c, bm, P.sea.deep)
    c:stitch{ { x - 11, y + 2 }, { x + 10, y + 2 } }
    c:part(c:rect(x - 2, y - 10, x, y - 7), P.sea, NO) c:put(x - 2, y - 10, P.sea.hi)
  end,
  front = function(c, k)
    local bk = c:rrect(23, 81, 56, 99, 3)
    c:part(bk, P.wood, { band = 2, inner = false, pop = { x = 25, y = 83 } })
    bk:each(function(x, y) if y > 83 and (x + (y % 3 == 0 and 2 or 0)) % 4 == 0 and c:get(x, y) == P.wood.base then c:put(x, y, P.wood.shade) end end)
    for _, q in ipairs{ { 29, 79 }, { 35, 77 }, { 41, 78 }, { 47, 79 }, { 38, 80 } } do
      local m = c:ellipse(q[1], q[2], 3, 3) c:part(m, BER, { band = 1, inner = false, pop = { x = q[1] - 1, y = q[2] - 2 } })
      c:put(q[1] + 1, q[2] + 1, BER.deep)
    end
    local lf = c:poly{ { 44, 74 }, { 52, 72 }, { 50, 77 } } c:part(lf, P.moss, NO) c:put(47, 74, P.moss.hi)
    local rim = c:rrect(21, 80, 58, 83, 1) c:part(rim, P.wood, { band = 1, inner = false, pop = { x = 23, y = 80 } })
    for x = 23, 35 do c:put(x, 80, P.wood.hi) end
    HH.pawFront(c, k, 21, 84, 3.5, 3) HH.pawFront(c, k, 58, 84, 3.5, 3)
  end,
}
