-- yarn-scarf-fine: Fine rank of the Yarn Scarf. Opus second pass, batch4b. 64x64.
-- Base: game/assets/img/ph/yarn-scarf.png (read only). The yarn scarf has only cut a in game/includes/wearables.php,
-- so there is no stitched patch to keep: this is the cut-a scarf with the Fine treatment.
-- Fine = gold only:
--  * a 2-row band of gold-thread knitting across each tail, laid on a teal stripe so the gold pops (on the red-orange
--    stripes gold shade turns muddy); lit left, shaded right, a knit V texture from alternating tones;
--  * gold beads on the tip of every fringe strand;
--  * a round gold pin on the knot, inked so it stays crisp on the red knit, with a cream glint (the gleam);
--  * a pale-gold glint on the left band.
-- quirk kept: the loose yarn curl hanging beside the left tail. No fleece.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local G = O.GOLD6
local img = O.load(O.PH .. "yarn-scarf.png")

-- 1. gold bands: left tail rows 45-46 (x 15-23), right tail rows 49-50 (x 41-49)
local function band(x0, x1, y)
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local top = (t < 0.3) and G.hi or (t < 0.75 and G.base or G.shade)
    local bot = (t < 0.3) and G.base or (t < 0.75 and G.shade or G.deep)
    if x % 2 == 1 then top = (top == G.hi) and G.base or top; bot = (bot == G.base) and G.shade or bot end
    O.body(img, x, y, top); O.body(img, x, y + 1, bot)
  end
end
band(15, 23, 45)
band(41, 49, 49)
O.body(img, 15, 45, G.pale)

-- 2. gold bead on the tip of each fringe strand (skip the loose curl at x 25-33)
for x = 10, 52 do
  if x < 25 or x > 33 then
    local yb
    for y = 63, 53, -1 do if O.isBody(img, x, y) then yb = y break end end
    if yb then O.px(img, x, yb, ((x % 4) == 0) and G.hi or G.base) end
  end
end

-- 3. gold pin on the knot
O.paint(img, 29, 17, {
  ".###.",
  "#hWb#",
  "#bbs#",
  "#sdd#",
  ".###.",
}, { h = G.hi, b = G.base, s = G.shade, d = G.deep, W = "#fff4d6" })
O.save4(img, "yarn-scarf-fine")
