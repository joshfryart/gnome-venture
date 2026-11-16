-- Gold Spike Tiara (pl-bjq-4), yard 64x64. Uncommon, thornblade. A crown of four gold spikes over a heap of bubbles.
-- quirk: the crown is mostly bubbles, and a face peeks out of the middle one.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-4-yard", 64), H.P
local bubbles = {
  { 16, 40, 6, "sea" }, { 48, 40, 6, "sea" }, { 26, 46, 7, "sky" },
  { 38, 46, 7, "sky" }, { 22, 30, 4, "sky" }, { 43, 29, 4, "sky" }, { 32, 38, 8, "sea" },
}
for _, b in ipairs(bubbles) do c:part(c:ellipse(b[1], b[2], b[3], b[3]), b[4], { sep = true }) end
local spikes = {
  { {8,36},{14,12},{20,36} }, { {20,32},{26,4},{32,30} },
  { {32,30},{38,4},{44,32} }, { {44,36},{50,12},{56,36} },
}
for _, s in ipairs(spikes) do c:part(c:poly(s), "gold", { sep = true }) end
c:eyeLocked(26, 36)
c:eyeLocked(35, 36)
for _, p in ipairs({ {30,44},{31,45},{32,45},{33,44} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(13, 37)
c:sparkle(50, 36)
H.done(c, "pl-bjq-4-yard")
