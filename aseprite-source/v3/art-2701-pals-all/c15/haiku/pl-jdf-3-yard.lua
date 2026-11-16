-- Jade Shimmer (pl-jdf-3), yard 64x64. Common, rootwarden. A jade gem-blob with facets.
-- quirk: sun sparkles flick off its corners.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-3-yard", 64), H.P
local body = c:poly{ {32,8},{48,16},{56,32},{48,50},{32,57},{16,50},{8,32},{16,16} }
c:groundShadow(32, 59, 15, 3)
c:part(body:copy():clip(c:rect(0, 0, 31, 63)), "sea")
c:part(body:copy():clip(c:rect(32, 0, 63, 63)), "moss")
c:eyeLocked(21, 28)
c:eyeLocked(38, 28)
c:cheek(17, 37)
c:cheek(44, 37)
for _, p in ipairs({ {29,39},{30,40},{31,40},{32,40},{33,40},{34,39} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(5, 12)
c:sparkle(58, 10)
c:sparkle(60, 52)
c:sparkle(4, 48)
H.done(c, "pl-jdf-3-yard")
