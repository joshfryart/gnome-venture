-- beehive-2 (final pass, Opus). Tier 2 straw skep: four slim coiled rings tapering to a round crown, on a plank stand.
-- Material: per-pixel lit coils (6-tone straw), diagonal rope-twist grooves, dark cane bindings across the seams,
-- ambient row under each ring, arched dark entrance with a lit lip, wood plank with grain + pale end grain, contact
-- shadow on the plank under the skep, 2-tone ground shadow.
-- quirk: a little red pennant on an iron pin flies off the crown.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor = math.floor
local c = A.new("beehive-2")
local CX = 31.5
c:groundShadow(32, 55, 17, 2)
A.stand(c, 16, 47, 47, { th = 4, lh = 3, legs = { 19, 41 } })
local all, idx, info = A.skep(c, CX, 46, { { w = 12.5, h = 8 }, { w = 10.5, h = 8 }, { w = 8.5, h = 7 }, { w = 5.5, h = 7 } }, { crown = 3 })
-- contact shadow on the plank top under the skep
for x = 16, 47 do if all:has(x, 46) then c:put(x, 47, A.WOOD[3]) end end
A.bind(c, idx, info, CX, { -6, 5 }, A.STRAW, { "#3e2429", "#5c372e", "#83503a" })
-- entrance + lit lip
local em = A.entrance(c, CX, 46, 3, 5)
for x = 28, 35 do local k = K(x, 40) if idx[k] and not em:has(x, 40) then A.step(c, idx, A.STRAW, x, 40, 1) end end
-- specular on the upper-left of the second ring + one glint on the crown
c:put(22, 34, A.STRAW[6]) c:put(23, 34, A.STRAW[6])
-- quirk: pennant on a pin
local top = info[#info].y0 - 3
for y = top - 9, top do c:put(32, y, y < top - 6 and "#aaa9b8" or "#74758c") end
c:put(32, top - 10, "#e2e0e6")
local flag = {
  "rrRR.....",
  "hrrRRRR..",
  "hhrrRRRRd",
  "hrrRRRd..",
  "rRRd.....",
}
local FC = { h = "#ff8a5c", r = "#e8493b", R = "#c93a3a", d = "#8a2a3c" }
for yy, row in ipairs(flag) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if FC[ch] then c:put(32 + xx, top - 9 + yy - 1, FC[ch]) end end end
A.bee(c, 47, 24)
A.save(c, "beehive-2")
