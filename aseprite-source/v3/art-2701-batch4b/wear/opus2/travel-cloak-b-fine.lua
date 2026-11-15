-- travel-cloak-b-fine: Fine rank of the Travel Cloak cut b (folded cloak, sewn tartan patch, clothes moth).
-- Opus second pass, batch4b. 64x64.
-- Base: art-2701-next8/opus3/travel-cloak-b.png (read only). The cut-a Fine (gold-edged V, gold brooch with a garnet,
-- gold filigree above the hem) is translated onto the folded cloak:
--  * the tan drawstring V becomes a twisted gold cord, doubled to a 2 px gold welt along the top edge (hi/base twist on the lit run, base/shade on the shaded run);
--  * the small wooden bead at the V point becomes a 7x7 cast gold brooch with a 3x3 garnet and a cream glint
--    (the gleam);
--  * gold piping runs along the hem; two gold filigree curls sit either side of the V on the bottom layer.
-- Nothing is painted at x >= 43 above row 31: the tartan patch, its stitches and the moth stay untouched.
-- quirk kept: moth on the patch corner, nibbled hole, orange leaf at the hem. No fleece anywhere.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local G = O.GOLD6
local img = O.load(O.V3 .. "/art-2701-next8/opus3/travel-cloak-b.png")
local function safe(x, y) return not (x >= 43 and y <= 31) end

-- 1. gold cord
for y = 17, 39 do for x = 13, 45 do
  local h = O.get(img, x, y)
  if safe(x, y) and h then
    if h == "#e6bd7e" then O.px(img, x, y, ((x + y) % 3 == 0) and G.hi or G.base)
    elseif h == "#b07a46" then O.px(img, x, y, ((x + y) % 3 == 0) and G.base or G.shade) end
  end
end end
-- 1b. the dark crease above the top cord (row 16) becomes a gold welt too: a 2 px gold top edge that answers the
--     Lined's cream roll at 16 px
for x = 18, 42 do if O.isBody(img, x, 16) then O.px(img, x, 16, (x % 3 == 0) and G.shade or G.base) end end
-- 2. brooch at the V point
O.paint(img, 28, 38, {
  ".#####.",
  "#hhbbs#",
  "#hWABs#",
  "#bABCd#",
  "#bBCCd#",
  "#sdddD#",
  ".#####.",
}, { h = G.hi, b = G.base, s = G.shade, d = G.deep, D = G.umber, W = "#fff4d6", A = "#f0705a", B = "#b52e3f", C = "#5e1c33" })
-- 3. gold piping along the hem (row 48), twisted
for x = 2, 47 do
  if O.isBody(img, x, 48) then O.px(img, x, 48, (x % 3 == 0) and G.shade or G.base) end
  if O.isBody(img, x, 49) then O.px(img, x, 49, G.umber) end
end
-- 4. filigree curls either side of the V (bottom layer)
local curl = { "bbb.", "b..b", "b.s.", ".bb." }
O.paint(img, 20, 43, curl, { b = G.base, s = G.shade })
O.paint(img, 39, 43, { ".bbb", "b..b", ".s.b", ".bb." }, { b = G.base, s = G.shade })
O.reink(img)
O.save4(img, "travel-cloak-b-fine")
