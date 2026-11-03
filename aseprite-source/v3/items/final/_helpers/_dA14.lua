-- _dA14: helper for chunk dA14 (bambara .. beehive-painted). Layer over _dA12 (which layers over batch2/_b2.lua); nothing shared is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA12.lua")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
D.GRAIN = { "#6a4a1c", "#9a6e26", "#c89a38", "#e6bc50", "#f4d676", "#fff0a8" }
D.BLK   = { "#120d16", "#1d1523", "#2c2030", "#3e2f44", "#58475e", "#7c6a82" }
D.GREY  = { "#2a2630", "#443f4c", "#625c6c", "#807a8a", "#a29cac", "#cac6d2" }
D.HUSK  = { "#6a5030", "#8e7242", "#b8985a", "#d8bd7c", "#ecd9a0", "#fbf0c8" }
D.TEAL  = { "#143a4a", "#1f5a66", "#2e7e80", "#46a29a", "#78c8b4", "#b4e8d0" }
-- small bee at x,y (centre), 5x3 body + wing
function D.bee(x, y)
  local c = D.c
  c:px(x - 1, y - 2, "#fff4d6") c:px(x, y - 2, "#d0e8f6")
  for i = -2, 2 do c:px(x + i, y, (i == 0 or i == 2) and "#2b1c26" or "#f8d048") c:px(x + i, y + 1, (i == 0 or i == 2) and "#2b1c26" or "#eab32e") end
end
-- skep: n stacked straw rings centred on cx, bottom at yb. returns top y
function D.skep(cx, yb, n, w0, rh, shrink)
  local y = yb
  for i = 1, n do
    local w = w0 - (i - 1) * shrink
    local m = D.ell(cx, y - rh / 2, w, rh * 0.78 + (i == n and 1.5 or 0), 0)
    D.lit(m, D.YEL, 3)
    if i > 1 then D.seam(D.c, m, D.ell(cx, y - rh - rh / 2, w - shrink, rh * 0.78, 0), "#8f5a1f") end
    for k = -floor(w) + 2, floor(w) - 2, 4 do D.px(cx + k, y - 1, "#c88a22") end
    y = y - rh + 1
  end
  return y
end
return D
