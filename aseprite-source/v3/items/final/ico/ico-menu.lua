-- ico-menu first draft (Sonnet). quirk: the three menu bars are a tiny hamburger: bun, patty, bun, with a dripping cheese corner
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-menu")
local BUN = D.rp("gold")
local PAT = { "#2e1a1a", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#b97a4a" }
c:groundShadow(32, 57, 20, 2)
-- bottom bun
local bot = c:rrect(12, 43, 51, 53, 4)
D.lit(bot, { "#8f4a1f", "#b8702f", "#d6903f", "#eeae58", "#f5c26a", "#ffe08a" }, 4)
-- patty
local pat = c:rrect(10, 33, 53, 42, 4)
D.lit(pat, PAT, 4)
-- lettuce wave
local lw = HP.mask()
for x = 9, 54 do local y = 29 + ((x // 3) % 2 == 0 and 0 or 1) lw:add(c:rect(x, y, x, y + 3)) end
D.lit(lw, D.GREEN, 2, { wrap = .4 })
-- cheese slab with drip
local ch = c:rect(14, 30, 48, 32):add(c:rect(44, 33, 47, 38)):add(c:rect(45, 39, 46, 40))
D.lit(ch, D.ORG, 1.5)
c:fillMask(c:rect(45, 41, 46, 41), "#ffe08a")
-- top bun dome
local top = c:ellipse(32, 24, 21, 11):cut(c:rect(0, 26, 63, 40))
top:add(c:rect(12, 24, 52, 26))
D.lit(top, BUN, 7)
for _, p in ipairs{ {20,17},{27,14},{34,16},{41,14},{47,19},{24,21},{37,21},{30,19} } do
  c:fillMask(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), CR) c:px(p[1], p[2] + 1, "#f6e6bf")
end
D.fin()
