-- quirks.lua : one small odd tell per creature (style rule 6), by slug. The body type reads its entry as g.q and draws what it knows.
-- The entries live in quirks/<arch>.lua (one file per body type; the keys are explained in the header of types/<arch>.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local Q = {}
for _, a in ipairs({ "quad", "bird", "frog", "bug", "worm", "snake", "snail", "crab", "spider", "golem", "wisp", "octo", "folk" }) do
  local f = io.open(DIR .. "/quirks/" .. a .. ".lua")
  if f then f:close(); for k, v in pairs(dofile(DIR .. "/quirks/" .. a .. ".lua")) do assert(not Q[k], "quirk twice: " .. k); Q[k] = v end end
end
return setmetatable(Q, { __index = function() return {} end })
