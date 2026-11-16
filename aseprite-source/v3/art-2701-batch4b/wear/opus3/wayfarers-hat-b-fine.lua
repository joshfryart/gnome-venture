-- wayfarers-hat-b-fine: Fine rank, Wayfarer's Hat cut b (sewn crown patch). Opus richness pass.
-- Base: ../opus2/wayfarers-hat-b-fine.png (read only). Added:
--  * the gold brim edge is 3-4 px deep at the front (as on the cut-a Fine hat): the twisted cord plus a cast gold
--    band behind it, lit row on top, shade and umber rows on the underside, so the Fine reads at 16 px as a
--    gold-rimmed hat (Lined: cream rim);
--  * felt nap on crown and brim, a lit rim on the crown's left edge, a lilac bounce on the crown's right side;
--  * gleam: a cream sparkle on the buckle; quirk: a gold-thread star sewn on the brim front.
-- The crown patch and its gold stitches (x 20..35, y 18..31) are never painted. No fleece anywhere.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local G = O.GOLD6
local img = O.load(O.OP2 .. "wayfarers-hat-b-fine.png")
local function safe(x, y) return not (x >= 20 and x <= 35 and y >= 18 and y <= 31) end
local FELT = O.ramp({ "#d49a68", "#c48a5a", "#a66a45", "#8a5239", "#704033", "#552f2c", "#3a2026" })
local GR = O.ramp({ G.pale, G.hi, G.base, G.shade, G.deep, G.umber })
local LILAC = "#6e4a6a"

-- 1. widen the gold band: felt pixels touching gold at the front (y >= 43) become gold, one or two more rings
for pass = 1, 2 do
  local ch = {}
  for y = 43, 63 do for x = 0, 63 do
    local h = O.get(img, x, y)
    if h and FELT.idx[h] then
      local n = 0
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local g = O.get(img, x + d[1], y + d[2]); if g and GR.idx[g] then n = n + 1 end
      end
      if n > 0 and (pass == 1 or y >= 46) then ch[#ch + 1] = { x, y } end
    end
  end end
  for _, p in ipairs(ch) do
    local x, y = p[1], p[2]
    -- inner ring: the band's top face, lit on the left; umber where it meets the felt
    local c = (pass == 2) and G.umber or ((x < 30) and (((x + y) % 4 == 0) and G.pale or G.hi) or G.base)
    O.px(img, x, y, c)
  end
end

-- 2. felt nap, rim light, bounce
O.nap(img, FELT, 0, 17, 63, 63, safe, 7)
O.rimbounce(img, FELT, 0, 17, 63, 63, { ok = safe, rim = -1, bounce = LILAC })

-- 3. gleam on the buckle, gold-thread star on the brim front
O.sparkle(img, 19, 32, G.pale)
O.paint(img, 13, 40, {
  "..h..",
  ".hbs.",
  "hbbbs",
  ".bsd.",
  "..d..",
}, { h = G.hi, b = G.base, s = G.shade, d = G.deep })
O.reink(img)
O.save4(img, "wayfarers-hat-b-fine")
