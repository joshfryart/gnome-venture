-- work-gloves-b-fine: Fine rank, Work Gloves cut b (ticking-stripe patch with a loose red thread). Opus richness pass.
-- Base: ../opus2/work-gloves-b-fine.png (= finished cut-a Fine + grafted cut-b patch; read only). Added:
--  * the cut-a Fine's gold-thread oak leaf (open line-work, each stitch casting a 1 px leather shadow) is re-sewn on
--    the back glove, where it clears the patch; so the Fine reads at 16 px by the leaf plus the gold cuff bands,
--    and is a clear sibling of the cut-a Fine;
--  * leather grain (creases and pale pores) shared with the Lined (_gloves.lua); a pale-gold leaf tip and a sparkle on the front glove's lit knuckle.
-- The ticking patch and its loose red thread are untouched. No fleece.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local G = O.GOLD6
local img = O.load(O.OP2 .. "work-gloves-b-fine.png")
loadfile(O.ME .. "_gloves.lua")(O)(img)
local LEAF = {
  "....a....",
  "...a.b...",
  "..aa.bb..",
  ".a..h..b.",
  "..a.h.b..",
  ".a.vhv.b.",
  "..a.h.b..",
  ".a..h..b.",
  "..a.h.b..",
  "...ahb...",
  "....s....",
}
local X0, Y0 = 34, 26
local function at(i, j) local r = LEAF[j]; return r and i >= 1 and i <= #r and r:sub(i, i) ~= "." end
for j = 1, #LEAF do for i = 1, #LEAF[j] do
  if at(i, j) and not at(i + 1, j + 1) then O.body(img, X0 + i, Y0 + j, "#80492c") end
end end
for j, row in ipairs(LEAF) do for i = 1, #row do
  local c = row:sub(i, i)
  if c ~= "." then O.body(img, X0 + i - 1, Y0 + j - 1, ({ a = G.base, b = G.shade, h = G.hi, v = G.base, s = G.deep })[c]) end
end end
O.body(img, X0 + 4, Y0, G.pale)
O.sparkle(img, 18, 24, G.pale)   -- gleam on the lit thumb-side knuckle of the front glove
O.reink(img)
O.save4(img, "work-gloves-b-fine")
