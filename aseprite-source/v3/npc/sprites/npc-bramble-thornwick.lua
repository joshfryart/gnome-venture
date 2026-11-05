-- npc-bramble-thornwick sprite (npc2 P1_4) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Prickly hedgehog, 3/4 view facing right: violet-brown spine mound, long snout, wet nose, tilted blue beret
-- perched in the spines, hugging a basket of blackberries. idle(4): base / breath + beret nub / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3b2640", shade = "#583a4c", base = "#7e5546", hi = "#b48466", tip = "#ecd2b0" }
local BER = { hi = P.dusk.hi, base = P.dusk.shade, shade = P.dusk.deep, deep = "#24183a" }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-bramble-thornwick", out = app.params.out or (DIR .. "/"), SP = SP, seed = 4,
  frames = { {}, { b = 1, nub = 1 }, {}, { blink = true } },
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 2
    local bm = c:ellipse(x, y, 8, 2.5) bm:add(c:ellipse(x - 1, y - 2, 6.5, 2.5)) bm:add(c:ellipse(x - 8, y + 1, 2, 1.5))
    c:part(bm, P.sea, { band = 1, inner = false, pop = { x = x - 5, y = y - 3 } })
    HH.under(c, bm, P.sea.deep)
    c:stitch{ { x - 7, y + 1 }, { x + 7, y + 1 } }
    local n = k.p.nub or 0
    c:part(c:rect(x - 1, y - 6 + n, x, y - 4), P.sea, NO) c:put(x - 1, y - 6 + n, P.sea.hi)
  end,
  front = function(c, k)
    local b = k.b
    local bk = c:rrect(29, 72 + b, 46, 80 + b, 2)
    c:part(bk, P.wood, { band = 1, inner = false, pop = { x = 30, y = 73 + b } })
    bk:each(function(x, y) if y > 73 + b and (x + (y % 2) * 2) % 4 == 0 and c:get(x, y) == P.wood.base then c:put(x, y, P.wood.shade) end end)
    HH.under(c, bk, P.wood.deep)
    for _, q in ipairs{ { 32, 70 }, { 36, 69 }, { 40, 70 } } do
      local m = c:ellipse(q[1], q[2] + b, 2, 2) c:part(m, BER, { band = 1, inner = false, pop = { x = q[1] - 1, y = q[2] - 1 + b } })
    end
    c:fillMask(c:poly{ { 41, 67 + b }, { 45, 66 + b }, { 44, 68 + b } }, P.moss.base) c:put(42, 67 + b, P.moss.hi)
    local rim = c:rrect(28, 71 + b, 47, 72 + b, 1) c:part(rim, P.wood, NO) for x = 29, 35 do c:put(x, 71 + b, P.wood.hi) end
  end,
}
