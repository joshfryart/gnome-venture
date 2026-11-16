-- wayfarers-hat-b-lined: Lined rank, Wayfarer's Hat cut b (sewn crown patch). Opus richness pass.
-- Base: ../opus2/wayfarers-hat-b-lined.png (read only). Added:
--  * the fleece brim rim is now 3-4 px deep at the front (as on the cut-a Lined hat), lumpy curls, lit on the left
--    and shaded right, so the Lined reads at 16 px as a cream-rimmed hat;
--  * felt nap on crown and brim, a lit rim on the crown's left edge, a lilac bounce under the brim and on the
--    crown's right side, and a pinch crease on the crown top;
--  * quirk: an acorn tucked into the red band (plus the blue feather and the patch's sleeping mouse).
-- The crown patch and its gold stitches (x 20..35, y 18..31) are never painted.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local F = O.FLEECE
local img = O.load(O.OP2 .. "wayfarers-hat-b-lined.png")
local function safe(x, y) return not (x >= 20 and x <= 35 and y >= 18 and y <= 31) end
local FELT = O.ramp({ "#d49a68", "#c48a5a", "#a66a45", "#8a5239", "#704033", "#552f2c", "#3a2026" })
local FL = O.ramp({ F.hi, F.base, F.mid, F.shade, F.deep })
local LILAC = "#6e4a6a"

-- 1. deeper fleece rim
local set = {}
for y = 36, 63 do for x = 0, 63 do
  local h = O.get(img, x, y)
  if h and (FL.idx[h] or FELT.idx[h]) and y >= 38 then
    local m = (y >= 46) and 4 or ((y >= 42) and 3 or 2)
    if FL.idx[h] or O.dist(img, x, y, m) <= m then set[y * 64 + x] = true end
  end
end end
O.wool(img, set, { ramp = F, shadeFrom = 44, yDark = 52 })

-- 2. felt nap, rim light, bounce
O.nap(img, FELT, 0, 17, 63, 63, safe, 7)
O.rimbounce(img, FELT, 0, 17, 63, 63, { ok = safe, rim = -1, bounce = LILAC })
-- crown crease (pinch) on the lit top, kept clear of the patch
O.paint(img, 36, 19, { "s", "s", ".s" }, { s = "#552f2c" })

-- 3. quirk: an acorn tucked into the band at the left
O.paint(img, 19, 31, {
  ".####.",
  "#cCcC#",
  "#hnnN#",
  "#nnNN#",
  ".#NN#.",
  "..##..",
}, { c = "#8a5239", C = "#552f2c", h = "#ecc08a", n = "#d49a68", N = "#a66a45" })
O.reink(img)
O.save4(img, "wayfarers-hat-b-lined")
