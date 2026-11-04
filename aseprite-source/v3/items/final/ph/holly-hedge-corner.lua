-- holly-hedge-corner: 3/4 view L bend of clipped holly hedge. One slim arm runs in from a clean-cut end on the
-- left, turns on a rounded outer corner and drops toward the viewer, ending in a cut cross-section (dark packed
-- interior, pale cut stems with end grain). Inner corner filleted; AO where the near arm meets the far front face.
-- 6-tone glossy holly, stamped spiky leaves, berries, soil strip.
-- quirk: somebody's red knitted mitten is snagged on a holly spike.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_1.lua")
local HP = A.HP
local c = A.new("holly-hedge-corner")
local plan = A.union(HP.rect(8, 12, 46, 22), HP.rect(36, 12, 46, 44))
-- rounded outer corner (top right)
for y = 12, 17 do for x = 41, 46 do if (x - 40.5)^2 + (y - 17.5)^2 > 6.2^2 then plan.s[A.K(x, y)] = nil end end end
-- inner fillet
for y = 23, 27 do for x = 31, 35 do if (x + .5 - 31)^2 + (y + .5 - 28)^2 >= 4.6^2 then plan:set(x, y) end end end
A.spikes(plan, { { 0, -1 }, { 1, 0 }, { -1, 0 }, { 1, -1 } }, 7, 0.32, function(x, y) return x <= 9 or y >= 43 end)
A.hedge3q(plan, 8, { cutL = 8, cutB = { 35, 47, 44 }, seed = 9, stems = { { 38, 47 }, { 43, 46 }, { 40, 50 } },
  pebbles = { { 13, 32 }, { 26, 32 }, { 39, 54 } } })
A.berries({ { 13, 15 }, { 25, 18 }, { 40, 22 }, { 38, 33 }, { 42, 39, { { 0, 0 }, { 2, 2 } } } })
-- mitten hanging off the front face by its cuff
local tok = { r = { name = "mitten" } }
A.paint({
  ".WwWwW.",
  "wWwWwWw",
  ".RrRrR.",
  "RRhRRRt",
  "RhRRRRtT",
  "RRRRRSTT",
  "RRRRRS.",
  ".SSSS..",
}, 17, 22, { w = "#f4e6cc", W = "#cdb89a", R = "#e8493b", r = "#ff8a5c", h = "#ff8a5c", S = "#b52e3f",
  t = "#d63c3c", T = "#8e2638" }, tok)
c:put(19, 21, "#c98e52") -- the spike it hangs on
A.fin()
