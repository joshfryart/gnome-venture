-- yarn-scarf-fine: Fine rank, Yarn Scarf (cut a only, so no patch). Opus richness pass.
-- Base: ../opus2/yarn-scarf-fine.png (read only). Added:
--  * knit texture: a stocking-stitch "v" rib (lit crown, shaded tail) on both the red and the teal yarn ramps;
--  * a lit rim on the scarf's upper-left edges and a cool plum bounce on its lower-right edges;
--  * the knot pin is now a 7x7 cast gold ring brooch with a teal enamel boss, a cream glint and a pale-gold sparkle
--    (the gleam; opus2's 3x3 pin was small at 32 px);
-- Kept: the gold-thread knit bands, gold fringe beads, and the loose curl of yarn (quirk).
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local G = O.GOLD6
local img = O.load(O.OP2 .. "yarn-scarf-fine.png")
local RED = O.ramp({ "#f8b07a", "#f08e62", "#dc6a4a", "#c64e40", "#a8383a", "#842a36", "#5c1f2e" })
local TEAL = O.ramp({ "#c8f0d8", "#a2dcc0", "#68b8a2", "#46998c", "#357c78", "#285e62", "#1d4048" })
local function nopin(x, y) return not (x >= 26 and x <= 34 and y >= 16 and y <= 24) end
for _, R in ipairs({ RED, TEAL }) do
  O.texture(img, R, 0, 0, 63, 63, function(x, y, i)
    local u, v = x % 3, y % 2
    if i <= 1 or i >= 7 then return 0 end
    if v == 0 and u == 1 then return -1 elseif v == 1 and u == 0 and i <= 5 then return 1 end
  end, nopin)
  O.rimbounce(img, R, 0, 0, 63, 63, { ok = nopin, rim = -1, bounce = "#5a3a5e" })
end
-- ring brooch on the knot
O.paint(img, 27, 17, {
  ".#####.",
  "#phhbs#",
  "#hTtTd#",
  "#htWsd#",
  "#bTssd#",
  "#sdddU#",
  ".#####.",
}, { p = G.pale, h = G.hi, b = G.base, s = G.shade, d = G.deep, U = G.umber,
     T = "#46998c", t = "#68b8a2", W = "#fff4d6" })
O.px(img, 30, 20, "#a2dcc0"); O.px(img, 31, 21, "#285e62"); O.px(img, 30, 21, "#357c78"); O.px(img, 29, 20, "#fff4d6")
O.sparkle(img, 27, 17, G.pale)
O.reink(img)
O.save4(img, "yarn-scarf-fine")
