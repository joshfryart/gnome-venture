-- beetle-shell: a pair of iridescent teal-violet wing cases, ridged and split down the middle. quirk: the right case is lifted a little, showing a pale amber wing membrane underneath.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("beetle-shell")
local T = D.TEAL2
-- membrane peeking
local mem = D.ell(41, 36, 8, 14, -.1)
D.lit(mem, { "#7a4a1c", "#a8702a", "#d09a40", "#eac060", "#f8dc88", "#fff2c0" }, 2)
local L = D.ell(25, 35, 9, 15.5, .09)
local Rr = D.ell(38, 32, 8.5, 14, -.12)
D.lit(L, { T[1], T[2], "#3a5a9a", T[3], T[4], T[5] }, 5, { wrap = .3 })
D.lit(Rr, T, 5, { wrap = .3 })
-- ridges along each case
for _, s in ipairs{ {L, 25, .09, 35}, {Rr, 38, -.12, 32} } do
  for _, off in ipairs{ -5, -2, 2, 5 } do
    for y = -12, 12 do
      local x, yy = floor(s[2] + off + y * s[3] + .5), floor(s[4] + y + .5)
      if s[1]:has(x, yy) and y % 4 ~= 0 then c:px(x, yy, off < 0 and T[5] or T[2]) end
    end
  end
end
-- seam shadow between the cases
for y = 20, 48 do if Rr:has(30 + floor((y - 32) * -.12), y) then end end
-- violet iridescent sheen
for _, p in ipairs{ {20,24}, {21,25}, {22,26}, {33,22}, {34,23} } do if L:has(p[1], p[2]) or Rr:has(p[1], p[2]) then c:px(p[1], p[2], "#a890f0") end end
c:px(21, 22, "#fff4d6") c:px(22, 22, "#fff4d6")
c:px(34, 19, "#fff4d6")
D.fin()
