local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bladderwrack")
-- bladderwrack: a slim forked olive-brown seaweed frond with a midrib and pairs of round air bladders, little holdfast on a pebble. quirk: a tiny crab hides behind a bladder.
D.shadow(32, 58, 12, 2)
D.E(32, 56, 8, 3.5, 0, D.BOG, 2.5)
D.ln(32, 53, 32, 38, "#444a1a") D.ln(31, 53, 31, 38, "#66701e")
local fr = {{32,38,22,20},{32,38,42,18},{22,20,14,8},{22,20,28,6},{42,18,36,6},{42,18,52,8}}
for _, f in ipairs(fr) do
  for k = -1, 1 do D.ln(f[1] + k, f[2], f[3] + k, f[4], k == -1 and "#b0b83c" or (k == 0 and "#8a9628" or "#66701e")) end
end
for _, b in ipairs{{26,31},{38,30},{19,22},{26,16},{44,22},{38,14},{16,12},{50,12}} do D.E(b[1], b[2], 2.6, 2.6, 0, D.KELP, 1.5) D.px(b[1] - 1, b[2] - 1, "#fff4d6") end
D.E(40, 48, 2.4, 1.6, 0, D.RUST, 1) D.px(38, 46, "#14100e") D.px(42, 46, "#14100e") D.px(37, 47, "#b04a28") D.px(43, 47, "#b04a28")
D.fin()
