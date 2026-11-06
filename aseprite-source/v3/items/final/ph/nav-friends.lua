-- nav-friends (final pass, Opus aC2r1_1). Two gnome friends shoulder to shoulder: tall slim felt hats (green, and
-- violet with a floppy tip), round lit noses, small pill eyes, droopy moustaches, long beards with hair strands.
-- Material: sphere-lit skin, cylinder-lit felt with fold creases and AO under the brim, beard strands, moustache
-- contact shadow on the beard.
-- quirk: their beard tips are braided together into one plait tied with a little pink bow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("nav-friends")
local SKIN  = { "#7a3e36", "#a85e4a", "#d08664", "#eaa880", "#f8c8a0", "#ffe2c4" }
local NOSE  = { "#8a3438", "#c05a4c", "#e47e62", "#ffa882" }
local BEARD = { "#5e5a7a", "#8a86a2", "#b6b2c6", "#d8d4e2", "#eeeaf2", "#fffaf2" }
local HATS = {
  { "#183e34", "#245c3c", "#357e48", "#50a052", "#7ac262", "#b0de82" },
  { "#281c50", "#3c2c78", "#5844a2", "#7a64c4", "#a28ade", "#cebcf4" },
}
local gnomes = {
  { cx = 22, hat = { { 22, 30 }, { 22, 21 }, { 21, 14 }, { 18, 8 } }, beardTip = { 30, 50 }, dir = 1 },
  { cx = 42, hat = { { 42, 30 }, { 42, 21 }, { 44, 13 }, { 49, 12 } }, beardTip = { 34, 50 }, dir = -1 },
}
local below = c:rect(0, 37, 63, 63)
local above = c:rect(0, 0, 63, 29)
for gi, g in ipairs(gnomes) do
  local cx = g.cx
  -- head
  local hm, hn = A.oval(cx, 34, 6.5, 6, 0)
  local hatM, hatN, HT, HS = A.tube(g.hat, function(t) return 8.0 * (1 - t) ^ 0.95 + 0.5 end)
  hatM:clip(above)
  local hb = A.bias()
  A.ao(hb, hm, hatM, 1, -1)
  A.shade(c, hm, hn, SKIN, { bias = hb })
  -- beard (tube toward the shared plait), clipped below the moustache line
  local bp = { { cx, 36 }, { cx, 42 }, { (cx + g.beardTip[1]) / 2, 47 }, g.beardTip }
  local bm, bn, BT, BS = A.tube(bp, function(t) return 7.2 * (1 - t) ^ 0.8 + 0.7 end)
  bm:clip(below)
  -- moustache
  local mL, nL = A.oval(cx - 2.6, 37, 2.8, 1.5, 0.35)
  local mR, nR = A.oval(cx + 2.6, 37, 2.8, 1.5, -0.35)
  local mm = mL:copy():add(mR)
  local bb = A.bias()
  A.cast(bb, bm, mm, 0, 1, -1)
  local bi = A.shade(c, bm, bn, BEARD, { bias = bb })
  -- hair strands: wavy lines down the beard
  bm:each(function(x, y) local k = K(x, y) local t, s = BT[k], BS[k]
    for _, so in ipairs{ -0.5, 0.05, 0.55 } do
      if abs(s - so - 0.07 * sin(t * 14 + gi)) < 0.09 and t > 0.12 then A.step(c, bi, BEARD, x, y, -1) end
    end end)
  A.shade(c, mL, nL, BEARD, { amb = 0.12 })
  A.shade(c, mR, nR, BEARD, { amb = 0.12 })
  c:put(cx, 37, BEARD[2])   -- parting under the nose
  -- hat (felt): cylinder light, darker brim roll, fold creases
  local hab = A.bias()
  hatM:each(function(x, y) if y >= 28 then hab[K(x, y)] = -1 end end)
  local hi = A.shade(c, hatM, hatN, HATS[gi], { bias = hab })
  hatM:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
    if y == 27 then A.step(c, hi, HATS[gi], x, y, 1) end            -- lit lip of the brim roll
    if t > 0.2 and t < 0.7 and abs(s - 0.25 - (t - 0.2) * 0.3) < 0.07 then A.step(c, hi, HATS[gi], x, y, -1) end
    if gi == 2 and t > 0.72 and t < 0.78 then A.step(c, hi, HATS[gi], x, y, -1) end   -- floppy bend crease
  end)
  c:put(cx - 5, 22, HATS[gi][6]) c:put(cx - 5, 23, HATS[gi][6])
  -- face
  c:eyeSmall(cx - 4, 30) c:eyeSmall(cx + 2, 30)
  c:cheek(cx - 6, 34) c:cheek(cx + 4, 34)
  A.map(c, {
    ".bc.",
    "bccb",
    "abba",
    ".aa.",
  }, cx - 2, 32, { a = NOSE[1], b = NOSE[2], c = NOSE[3] })
  c:put(cx - 1, 32, NOSE[4])
end
-- quirk: the plait (two strands twisting) and a pink bow
for y = 49, 55 do
  local ph = y % 2
  c:put(31, y, ph == 0 and BEARD[5] or BEARD[3])
  c:put(32, y, BEARD[4])
  c:put(33, y, ph == 0 and BEARD[2] or BEARD[5])
end
A.map(c, {
  "pP.Pp",
  ".PdP.",
}, 30, 54, { p = "#f89ab6", P = "#e05c8c", d = "#8a2c62" })
c:put(31, 56, BEARD[4]) c:put(32, 56, BEARD[5]) c:put(33, 56, BEARD[3])
c:put(32, 57, BEARD[3])
A.save(c, "nav-friends")
