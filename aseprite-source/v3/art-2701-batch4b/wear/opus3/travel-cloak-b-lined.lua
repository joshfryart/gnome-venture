-- travel-cloak-b-lined: Lined rank, Travel Cloak cut b (folded cloak, sewn tartan patch, clothes moth). Opus richness pass.
-- Base: ../opus2/travel-cloak-b-lined.png (read only). Added:
--  * fleece lining turned out at the bottom edge of the top layer and along the hem (the cut-a Lined shows the same
--    cream at its openings), lumpy, lit left and shaded right, so the Lined reads at 16 px as cream bands on green;
--  * a deeper fleece roll on top (third row, hanging lumps) with a teal-shadowed underside;
--  * wool twill on all three layers, a lit rim on the left/top edges and a teal bounce on the lower right;
--  * quirk: a wooden toggle on a loop of twine at the V, plus the moth, nibbled hole and leaf kept.
-- The tartan patch, its stitches and the moth (x >= 42 above row 32) are never painted.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local F = O.FLEECE
local img = O.load(O.OP2 .. "travel-cloak-b-lined.png")
local function safe(x, y) return not (x >= 42 and y <= 32) end
local G = O.ramp({ "#c4dc8e", "#a8cc7a", "#86b464", "#5e9452", "#45784b", "#335f43", "#264a3c", "#1c3530", "#16282a" })
local TEAL, TEAL2 = "#2f6a64", "#285a58"

-- 1. twill: a diagonal rib on the cloth (every 3rd diagonal one tone lighter, the next one darker) on the lower layers
O.texture(img, G, 7, 34, 52, 47, function(x, y, i)
  local k = (x + y) % 4
  if i >= 8 then return 0 end
  if k == 0 then return -1 elseif k == 2 and i <= 6 then return 1 end
end, safe)
O.texture(img, G, 8, 17, 41, 30, function(x, y, i)
  if (x + y) % 4 == 0 and i <= 7 then return -1 end
end, safe)

-- 2. rim light (upper-left edges) and teal bounce (lower-right edges)
O.rimbounce(img, G, 5, 13, 54, 49, { ok = safe, rim = -2, bounce = TEAL, bounceOk = function(x, y) return y >= 34 end })

-- 3. fleece lining lips (bottom of top layer, bottom of middle layer, hem)
local function lip(x0, x1, y, lumps)
  -- two full rows (lit top, base) plus a row of soft hanging lumps; shade side from x 34
  for x = x0, x1 do
    local sh = x >= 34
    if safe(x, y - 1) and O.isBody(img, x, y - 1) then O.px(img, x, y - 1, sh and F.base or F.hi) end
    if safe(x, y) and O.isBody(img, x, y) then O.px(img, x, y, (x % 5 == 2) and F.mid or (sh and F.mid or F.base)) end
  end
  for _, l in ipairs(lumps) do for x = l[1], l[2] do
    if safe(x, y + 1) and O.isBody(img, x, y + 1) then O.px(img, x, y + 1, (x == l[2]) and F.deep or F.shade) end
  end end
end
lip(8, 24, 31, { { 9, 11 }, { 15, 18 }, { 21, 23 } })
lip(36, 41, 31, { { 37, 40 } })
lip(8, 28, 39, { { 11, 14 }, { 19, 21 } })
lip(34, 52, 39, { { 41, 44 }, { 48, 50 } })
lip(7, 52, 47, { { 9, 11 }, { 16, 19 }, { 25, 27 }, { 33, 36 }, { 42, 44 } })
-- contact shadow under each lip
for _, r in ipairs({ { 8, 24, 33 }, { 8, 52, 41 } }) do
  for x = r[1], r[2] do if O.get(img, x, r[3]) and G.idx[O.get(img, x, r[3])] and G.idx[O.get(img, x, r[3])] < 7 then O.step(img, x, r[3], G, 2) end end
end

-- 4. fleece roll: the dark crease under the roll becomes a third, shaded fleece row (a thicker collar roll)
for x = 11, 45 do if safe(x, 16) and O.isBody(img, x, 16) then
  O.px(img, x, 16, (x >= 38) and F.deep or ((x % 4 == 1) and F.deep or F.shade))
end end
for x = 11, 45 do if safe(x, 15) and O.isBody(img, x, 15) and (x % 4 == 3) then O.px(img, x, 15, x >= 38 and F.shade or F.mid) end end

-- 5. quirk: wooden toggle on a twine loop at the V point
O.paint(img, 30, 39, {
  ".tt.",
  "#WBD#",
  "#BDE#",
  ".##.",
}, { t = "#b07a46", W = "#e6bd7e", B = "#b07a46", D = "#7e4a2f", E = "#5e3627" })

O.reink(img)
O.save4(img, "travel-cloak-b-lined")
