-- Ledge Feather (pl-cnd-2), yard sprite 64x64. Drifts off every ledge and always finds its way back.
-- quirk: a dotted route trails behind it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-cnd-2-yard", 64)

local vane = c:poly{ { 46, 6 }, { 56, 22 }, { 48, 40 }, { 34, 54 }, { 26, 50 }, { 34, 36 }, { 40, 20 } }
c:part(vane, "wood")
c:fillMask(c:line({ { 47, 8 }, { 30, 50 } }, 1), P.wood.deep)
c:eyeLocked(44, 22)
c:px(20, 58, P.cream)
c:px(15, 60, P.cream)
c:px(10, 58, P.cream)
c:px(6, 61, P.cream)
H.save(c, "pl-cnd-2-yard")
