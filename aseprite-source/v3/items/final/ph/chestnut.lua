-- chestnut (v3 first draft, dB15). quirk: an autumn leaf has blown in beside the burr
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chestnut")
D.shadow(c, 32, 54, 24, 3)
local BUR = { "#3a4a1c", "#5a6a28", "#7c8a38", "#9ca848", "#bcc660", "#dce488" }
local burr = B.ell(30, 28, 16, 15, 0)
-- spikes
for a = 0, 31 do
  local ang = a * pi / 16
  local x0, y0 = 30 + cos(ang) * 15, 28 + sin(ang) * 14
  B.ln(c, floor(x0 + .5), floor(y0 + .5), floor(30 + cos(ang) * 19.5 + .5), floor(28 + sin(ang) * 18.5 + .5), a % 2 == 0 and "#b8b050" or "#8a9a3c")
end
H.lit(c, burr, BUR, { R = 6 })
-- open mouth showing the white lining
local mouth = B.ell(30, 38, 12, 7, 0)
H.lit(c, mouth, { "#c8b88a", "#e0d4a8", "#f0e6c4", "#f8f0d8", "#fffaea", "#fff8e8" }, { R = 2 })
-- two nuts
local NUT = { "#2a1410", "#4a2418", "#6e3a22", "#94562e", "#b87a42", "#e0a868" }
D.seed(c, 24, 42, 8, 6.4, -0.2, NUT)
D.seed(c, 38, 44, 8, 6.4, 0.25, NUT)
H.lit(c, B.ell(24, 46, 4, 1.6, 0), { "#a08a58", "#c8b480", "#e0cea0", "#f0e2b8", "#fff4d0", "#fffaee" }, { R = 1 })
H.lit(c, B.ell(38, 48, 4, 1.6, 0), { "#a08a58", "#c8b480", "#e0cea0", "#f0e2b8", "#fff4d0", "#fffaee" }, { R = 1 })
-- fallen leaf
H.leaf(c, 6, 54, 14, 46, 3.2, "ember", { 3 })
D.fin()
