-- travel-cloak-b-lined: Lined rank of the Travel Cloak cut b (folded cloak, sewn tartan patch, clothes moth).
-- Opus second pass, batch4b. 64x64.
-- Base: art-2701-next8/opus3/travel-cloak-b.png (read only). The cut-b cloak is drawn folded, so the cut-a Lined
-- (hanging cloak with a fleece ruff and cream facings down the front V) is translated onto the fold:
--  * the top roll (the collar edge, rows 14-15) becomes a fleece roll with a lumpy top: tufts break the silhouette,
--    so the Lined reads at 16 px as "cream top on a green cloak";
--  * the tan drawstring V becomes 2 px cream fleece facings (the same V the cut-a Lined shows), lit on the left run,
--    shaded on the right run; the dark line beside each run stays as its contact shadow;
-- Nothing is painted at x >= 43 above row 31: the tartan patch, its whip stitches and the moth stay untouched.
-- quirk kept: moth on the patch corner, nibbled hole, orange leaf at the hem. No gold anywhere.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local F = O.FLEECE
local img = O.load(O.V3 .. "/art-2701-next8/opus3/travel-cloak-b.png")
local function safe(x, y) return not (x >= 43 and y <= 31) end

-- 1. fleece roll on the top edge, with tufts above the old outline
local roll = {}
for y = 14, 15 do for x = 14, 46 do if safe(x, y) and O.isBody(img, x, y) then roll[y * 64 + x] = true end end end
-- flat-topped lumps, 3-5 px wide (single-pixel spikes read as a saw edge, not wool)
for _, r in ipairs({ { 15, 18 }, { 22, 26 }, { 30, 33 }, { 37, 40 } }) do
  for x = r[1], r[2] do roll[13 * 64 + x] = true end
end
O.wool(img, roll, { ramp = F, shadeFrom = 39 })

-- 2. the drawstring V -> cream fleece facings, 2 px wide
local CORD = { ["#e6bd7e"] = true, ["#b07a46"] = true }
local left, right = {}, {}
for y = 17, 39 do for x = 13, 45 do
  if safe(x, y) and CORD[O.get(img, x, y) or ""] then
    if y == 17 then left[y * 64 + x] = true
    elseif x <= 31 then left[y * 64 + x] = true; if safe(x + 1, y) then left[y * 64 + x + 1] = true end
    else right[y * 64 + x] = true; right[y * 64 + x - 1] = true end
  end
end end
O.wool(img, left, { ramp = F, curl = false })
O.wool(img, right, { ramp = F, curl = false, shadeFrom = 0 })

O.reink(img)
O.save4(img, "travel-cloak-b-lined")
