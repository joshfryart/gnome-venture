-- holly-hedge-cross: 3/4 view four-way crossing of clipped holly hedge, all four arms clean-cut connector ends
-- (south arm shows its packed cross-section with cut stems). A raised round topiary dome crowns the crossing and
-- casts a contact shadow on the flat top; AO where the near arm meets the far front faces. Glossy 6-tone holly,
-- stamped spiky leaves with midribs and glints, berry clusters, soil strip.
-- quirk: the tip of a red gnome hat pokes out of the top of the dome.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_1.lua")
local HP, K = A.HP, A.K
local c = A.new("holly-hedge-cross")
local plan = A.union(HP.rect(6, 20, 57, 30), HP.rect(27, 7, 37, 44))
for _, f in ipairs{ { 26, 19, -1, -1 }, { 38, 19, 1, -1 }, { 26, 31, -1, 1 }, { 38, 31, 1, 1 } } do
  for j = 0, 2 do for i = 0, 2 do
    local x, y = f[1] + f[3] * i, f[2] + f[4] * j
    if (i + 0.5)^2 + (j + 0.5)^2 <= 4.2 or i + j <= 1 then plan:set(x, y) end
  end end
end
A.spikes(plan, { { 0, -1 }, { 1, 0 }, { -1, 0 } }, 11, 0.32, function(x, y) return x <= 7 or x >= 56 or y <= 8 or y >= 43 end)
local dome = HP.ellipse(32, 22, 7.5, 6.5)
A.spikes(dome, { { 0, -1 }, { -1, 0 }, { 1, 0 }, { -1, -1 }, { 1, -1 } }, 13, 0.35)
local pb = {}
dome:shift(1, 2):each(function(x, y) if not dome:has(x, y) then pb[K(x, y)] = -2 end end)
dome:shift(2, 3):each(function(x, y) if not dome:has(x, y) and not pb[K(x, y)] then pb[K(x, y)] = -1 end end)
A.hedge3q(plan, 8, { cutL = 6, cutR = 57, cutB = { 26, 38, 44 }, seed = 21, planBias = pb,
  stems = { { 29, 47 }, { 34, 46 }, { 31, 50 } }, pebbles = { { 12, 40 }, { 20, 39 }, { 47, 40 }, { 53, 39 } } })
A.foliage(dome, { mode = "top", R = 5, seed = 33, step = 3 })
A.berries({ { 10, 24 }, { 19, 27 }, { 46, 23 }, { 52, 27 }, { 29, 10, { { 0, 0 }, { 3, 1 } } }, { 30, 36 }, { 34, 24 } })
-- gnome hat tip: little cone with a curled tip and a cream band of fur peeking from the leaves
local tok = { r = { name = "hat" } }
A.paint({
  ".....kk",
  "....hR.",
  "...hRR.",
  "...hRS.",
  "..hRRS.",
  "..hRRSD",
  ".hRRRSD",
  ".hRRSSD",
}, 28, 9, { k = "#ff8a5c", h = "#ff8a5c", R = "#e8493b", S = "#b52e3f", D = "#6e2038" }, tok)
for x = 29, 35 do c:put(x, 17, A.GR[1]) end
A.fin()
