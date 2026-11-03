-- _dA16: helper for chunk dA16 (black-pepper-seed .. borer-plate). Layer over _dA13 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA13.lua")
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos
D.BLK   = { "#120d16", "#1d1523", "#2c2030", "#3e2f44", "#58475e", "#7c6a82" }
D.INDIGO = { "#14102e", "#231d52", "#342d78", "#4a42a0", "#6a64c4", "#9a96e0" }
D.BLUE   = { "#101a3c", "#1c2e5e", "#2c4a8a", "#4068b4", "#6490d2", "#9cbcea" }
D.MUSS   = { "#0e1230", "#1a2252", "#2a3a7c", "#3e56a4", "#6a82c8", "#a4b8e8" }
D.BOG    = { "#1c1814", "#2e2820", "#463c30", "#665644", "#8a7458", "#b09a76" }
D.RUST   = { "#2e1410", "#552014", "#823220", "#b04a28", "#d27038", "#ee9c58" }
D.JAM    = { "#1a0a2a", "#34123e", "#561a58", "#7a2870", "#a04898", "#cc7cc0" }
D.KELP   = { "#2a2a10", "#444a1a", "#66701e", "#8a9628", "#b0b83c", "#d6d870" }
-- vertical cylinder body (jar/bottle): rounded rect lit left to right
function D.vbody(x0, y0, x1, y1, r, ramp)
  local m = D.c:rrect(x0, y0, x1, y1, r)
  D.H.vcyl(D.c, m, ramp, x0 - 2, x1 + 3)
  return m
end
-- sprout on a scrap: stem then two leaves of given ramp
function D.sprout(x, y0, y1, ramp, lw, lh)
  D.stem2(x, y0, x, y1)
  D.lf(x - lw, y1 + 1, lw, lh, -0.5, ramp) D.lf(x + lw + 2, y1 - 1, lw, lh, 0.5, ramp)
end
return D
