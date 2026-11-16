-- work-gloves-b-lined: Lined rank, Work Gloves cut b (ticking-stripe patch with a loose red thread). Opus richness pass.
-- Base: ../opus2/work-gloves-b-lined.png (= finished cut-a Lined + grafted cut-b patch; read only). Added:
--  * leather grain (creases and pale pores) shared with the Fine (_gloves.lua);
--  * a cream running stitch (2 on, 1 off) down the back glove where the Fine carries its gold leaf, so both ranks
--    dress the same spot; the worn fingertip with fleece showing stays as the quirk.
-- The ticking patch and its loose red thread are untouched. No gold.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local img = O.load(O.OP2 .. "work-gloves-b-lined.png")
loadfile(O.ME .. "_gloves.lua")(O)(img)
for y = 26, 38 do
  if (y - 26) % 3 ~= 2 then O.body(img, 38, y, "#f8e8c6"); O.body(img, 39, y + 1, "#80492c") end
end
O.reink(img)
O.save4(img, "work-gloves-b-lined")
