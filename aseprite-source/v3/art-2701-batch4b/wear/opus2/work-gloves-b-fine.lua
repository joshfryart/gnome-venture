-- work-gloves-b-fine: Fine rank of the Work Gloves cut b (sewn ticking patch). Opus second pass, batch4b. 64x64.
-- Start: the finished cut-a Fine (art-2701-batch3/wear/opus3/work-gloves-fine.png: gold cuff bands, gold snap,
-- gold ring on the thumb, leather pores, rim and bounce) with the cut-b patch grafted in from
-- art-2701-opus/wear/work-gloves-b.png.
-- Fix: the cut-a gold oak leaf sat on the palm where the patch is sewn; its tips poked out above the patch as stray
-- gold specks. The leaf is unpicked (rows 21-31 only, back to the shared leather of the cut-a Lined, which has the
-- same pores); the Fine reads by its gold cuff bands, snap and thumb ring.
-- quirk kept: loose red thread on the front cuff, gold ring on the thumb.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local G = O.GOLD6
local img, M = O.graft(O.OP3 .. "work-gloves-fine.png", O.V3 .. "/art-2701-opus/wear/work-gloves-b.png", O.PH .. "work-gloves.png")
local L = O.load(O.OP3 .. "work-gloves-lined.png")
-- 1. unpick the oak leaf (palm rows 21-31; the Lined's fingertip hole above stays out of the Fine)
for y = 21, 31 do for x = 19, 31 do
  if not O.inMask(M, x, y) and O.isBody(img, x, y) then img:putPixel(x, y, L:getPixel(x, y)) end
end end
O.save4(img, "work-gloves-b-fine")
