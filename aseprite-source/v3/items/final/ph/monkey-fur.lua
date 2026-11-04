-- monkey-fur: a fan of orange-brown fur strands tied with gold thread. quirk: one strand curls into a spiral.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B = D.H, D.HP, D.B
local c = D.new("monkey-fur")
local FUR = D.R("#ffc46a", "#e8842a", "#b4521f", "#6a2c1e")
local FUR2 = D.R("#f4a84e", "#c4641f", "#8e3c22", "#52241e")
local tips = { {9,24}, {14,12}, {24,7}, {34,5}, {44,9}, {52,17}, {56,28} }
local function strand(tip, ramp, w)
  local bx, by = 32, 50
  local m = H.sweep({ {bx, by}, {bx + (tip[1]-bx)*.2, by - 14}, {bx + (tip[1]-bx)*.75, tip[2] + 14}, tip }, function(t) return w * (1 - t) ^ .7 + .5 end)
  B.lit(c, m, ramp, 2.2)
  return m
end
for i = 1, #tips do strand(tips[i], (i % 2 == 0) and FUR or FUR2, 3.6) end
local cm = H.sweep({ {34,50}, {64,40}, {60,6}, {47,18} }, function(t) return 3.2 * (1 - t) ^ .6 + .5 end)
B.lit(c, cm, FUR, 2.2)
for _, p in ipairs{ {47,19}, {48,17}, {50,18} } do c:px(p[1], p[2], "#6a2c1e") end
for i = 1, #tips do strand({ tips[i][1] * .5 + 16, tips[i][2] * .6 + 20 }, i % 2 == 0 and FUR2 or FUR, 3) end
local band = c:rrect(26, 46, 38, 53, 2)
B.lit(c, band, "gold", 2)
for i = 0, 3 do B.ln(c, 27 + i * 3, 53, 29 + i * 3, 46, "#8f4a1f", band) end
c:px(30, 47, "#fff4d6") c:px(31, 47, "#fff4d6")
c:fillMask(c:line({ {37,52}, {41,56}, {39,58} }, 1), "#f5b82e")
D.fin()
