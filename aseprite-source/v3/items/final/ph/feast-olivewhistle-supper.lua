-- feast-olivewhistle-supper (Opus single pass, aB30_4). A figured olive-wood paddle board with a hanging hole; on it a
-- golden dimpled focaccia with rosemary and salt, a cluster of kalamata and green olives on a silver-green leaf, and a
-- slim glass bottle of green-gold olive oil with a cork and a paper label standing at the back right.
-- Material: swirled olive-wood grain + darker front edge, pillow-lit bread with dimples (dark pit, lit lip), glossy
-- olives with one specular each, glass with a bright rim, pale core and an oil meniscus; contact shadows on the board.
-- quirk: a little olive-wood whistle lies on the board, string loop trailing.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, max, min = math.floor, math.sin, math.max, math.min
local NAME = "feast-olivewhistle-supper"
local c = A.new2(NAME)
local OW   = { "#4a2e22", "#6e4630", "#946240", "#b88552", "#d6a86c", "#efcf96" }
local BOX  = { "#5a3a24", "#8a5e36", "#b8884e", "#d8ac68", "#ecca8c", "#fae6b8" }
local BREAD = { "#6a3a1c", "#985a28", "#c4843a", "#e0a650", "#f2c674", "#fbe4a4" }
local KAL  = { "#2a1428", "#46203e", "#64305a", "#844678", "#a86a98", "#d8a8c8" }
local GOL  = { "#2e4a18", "#4a6e20", "#6a922a", "#8eb23c", "#b6d066", "#e2ef9e" }
local OLF  = { "#2e4436", "#46604a", "#62805c", "#86a274", "#aec496", "#d6e4bc" }
local OIL  = { "#4a4614", "#6e6a18", "#98901e", "#c2b62a", "#e0d45a", "#f6eea8" }
local GL   = { "#4e6c6a", "#729896", "#9cc0ba", "#c2ded6", "#e0f0ea", "#f6fbf6" }
local CORK = { "#5a3a26", "#7e5434", "#a47446", "#c4965e", "#dcb880", "#f0d8a8" }

-- masks
local top = HP.rrect(10, 41, 53, 50, 4):add(HP.rrect(5, 43, 12, 48, 2))
local hole = A.ell(7.5, 45.5, 1.2, 1)
top:cut(hole)
local bread = HP.rrect(13, 34, 35, 46, 5)
local bottle = HP.rrect(41, 20, 49, 45, 2)
local olives = {
  { 37, 47.5, KAL }, { 41, 48.5, GOL }, { 34, 49, GOL }, { 38.5, 50.5, KAL }, { 44.5, 48, KAL },
}
local omasks = HP.mask()
for _, o in ipairs(olives) do omasks:add(A.ell(o[1], o[2], 2.3, 1.7)) end

c:groundShadow(30, 53, 23, 2)
-- board front edge (thickness) with end-grain ticks
local front = top:shift(0, 2):cut(top):cut(hole)
front:each(function(x, y)
  local below = not top:shift(0, 2):has(x, y + 1)
  c:put(x, y, below and OW[1] or OW[3])
  if not below and x % 4 == 1 then c:put(x, y, OW[4]) end
end)
-- board top, contact shadows from what stands on it
local bb = {}
A.cast(bb, top, bread, 1, 2, -2)
A.cast(bb, top, bottle, 2, 1, -2)
A.cast(bb, top, omasks, 1, 1, -1)
local tidx = A.shadeN(c, top, X.pillow(top, 2), OW, { bias = bb, wrap = 0.35, amb = 0.15 })
-- swirled grain on the lit top
top:each(function(x, y)
  local i = tidx[K(x, y)] or 1
  if i >= 3 then
    local g = y + 1.6 * sin(x * 0.21) + 0.9 * sin(x * 0.53 + 1.3)
    if floor(g) % 3 == 0 and A.hash(x, y, 11) > 0.25 then c:put(x, y, OW[i - 1]) end
  end
end)
A.dots(c, { { 7, 45 }, { 7, 46 } }, OW[1])
-- quirk: olive-wood whistle with a string loop
local wm, wn = A.tube({ { 15, 49 }, { 18, 49 }, { 22, 48.7 }, { 25, 48.5 } }, function(t) return t < 0.2 and 0.9 + t * 2 or 1.35 end)
A.shadeN(c, wm, wn, BOX)
c:put(19, 48, BOX[1]) c:put(20, 48, BOX[2]) c:put(19, 47, BOX[6])
c:put(24, 48, BOX[2]) c:put(24, 49, BOX[2])
A.dots(c, { { 26, 49 }, { 27, 50 }, { 28, 50 }, { 29, 49 } }, "#c94f84")
c:put(28, 51, "#7d2c5e")
-- focaccia
local brb = {}
bread:each(function(x, y) if y >= 45 then brb[K(x, y)] = -1 end end)
local bidx = A.shadeN(c, bread, X.pillow(bread, 3.2), BREAD, { bias = brb })
for row = 0, 2 do for col = 0, 4 do
  local x, y = 15 + col * 4 + (row % 2) * 2, 36 + row * 3
  if bread:has(x + 1, y + 1) and y < 44 then
    c:put(x, y, BREAD[2]) c:put(x + 1, y + 1, BREAD[min(6, (bidx[K(x + 1, y + 1)] or 4) + 1)])
  end
end end
for _, p in ipairs{ { 17, 38 }, { 25, 37 }, { 30, 41 }, { 21, 42 } } do
  c:put(p[1], p[2], "#2f6a3c") c:put(p[1] + 1, p[2] - 1, "#4e9050") c:put(p[1] + 2, p[2] - 2, "#86c06a")
end
for _, p in ipairs{ { 20, 36 }, { 28, 39 }, { 32, 37 }, { 24, 43 }, { 16, 41 } } do c:put(p[1], p[2], "#fff6e4") end
c:put(17, 35, "#fff1cf") c:put(18, 35, BREAD[6])
-- silver-green olive leaf under the olives
A.leaf(c, 30, 51, 46, 50.5, 1.8, OLF, { 4, 8 })
-- olives
for _, o in ipairs(olives) do
  local m, n = A.oval(o[1], o[2], 2.3, 1.7, 0.15, 0.9)
  A.shadeN(c, m, n, o[3], { wrap = 0.2 })
  c:put(floor(o[1] - 1), floor(o[2] - 1), o[3] == KAL and "#f4dcea" or "#f6fbd8")
end
-- bottle: oil below the meniscus, clear glass above
local bn = A.vn(bottle, 41, 49)
local oil = bottle:copy():clip(HP.rect(0, 25, 63, 63))
local air = bottle:copy():cut(oil)
local ob = {}
oil:each(function(x, y) if y >= 44 then ob[K(x, y)] = -1 end end)
A.shadeN(c, oil, bn, OIL, { bias = ob, wrap = 0.3 })
A.shadeN(c, air, bn, GL, { wrap = 0.3 })
for x = 42, 48 do c:put(x, 25, OIL[6]) end
-- shoulder + neck + lip
local sh = HP.poly({ { 41, 20 }, { 44, 15 }, { 46, 15 }, { 49, 20 } }):add(HP.rect(43, 9, 47, 16))
A.shadeN(c, sh, A.vn(sh, 41, 49), GL, { wrap = 0.3 })
local lip = HP.rect(42, 9, 48, 10)
A.shadeN(c, lip, A.vn(lip, 42, 48, -0.3), GL, { wrap = 0.3 })
local cork = HP.rrect(43, 4, 47, 8, 1)
A.shadeN(c, cork, A.vn(cork, 43, 47, -0.2), CORK)
c:put(44, 6, CORK[3]) c:put(46, 5, CORK[2])
-- glass rim light + pale core
for y = 12, 43 do if y ~= 25 then c:put(42, y, y < 25 and GL[6] or OIL[6]) end end
for y = 27, 41 do if y % 5 ~= 0 then c:put(44, y, OIL[5]) end end
c:put(42, 21, "#fffbea") c:put(43, 22, "#fffbea")
-- label with a tiny olive sprig
local label = HP.rect(42, 31, 48, 37)
A.shadeN(c, label, A.vn(label, 41, 49), { "#8a7a5a", "#b4a27a", "#d4c49c", "#ead8b0", "#f6e8c8", "#fff4d6" })
A.dots(c, { { 43, 35 }, { 44, 34 }, { 45, 33 }, { 46, 32 } }, "#4a6e20")
c:put(45, 35, "#64305a") c:put(46, 34, "#86a274")
A.save2(c, NAME)
