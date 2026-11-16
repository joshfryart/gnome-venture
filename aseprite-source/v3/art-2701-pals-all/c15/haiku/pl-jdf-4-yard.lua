-- Jadewing Quartet (pl-jdf-4), yard 64x64. Uncommon, thornblade. A small green head with four wing bits.
-- quirk: the bottom-right wing lags a little behind the other three.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-4-yard", 64), H.P
local wings = {
  { {26,28},{10,8},{4,18},{22,34} },
  { {38,28},{54,8},{60,18},{42,34} },
  { {26,40},{12,58},{22,59},{31,44} },
  { {38,40},{52,54},{43,57},{33,44} },
}
for _, w in ipairs(wings) do c:part(c:poly(w), "sky") end
c:fillMask(c:line({{26,30},{12,12}}, 1), P.sky.deep)
c:fillMask(c:line({{38,30},{52,12}}, 1), P.sky.deep)
c:fillMask(c:line({{26,42},{14,55}}, 1), P.sky.deep)
c:fillMask(c:line({{38,42},{49,52}}, 1), P.sky.deep)
c:part(c:line({{32,38},{32,54}}, 4), "moss")
c:part(c:ellipse(32, 28, 9, 9), "moss", { sep = true })
c:eyeLocked(26, 24)
c:eyeLocked(34, 24)
c:cheek(23, 30)
c:cheek(39, 30)
c:px(31, 33, P.ink)
c:px(32, 33, P.ink)
H.done(c, "pl-jdf-4-yard")
