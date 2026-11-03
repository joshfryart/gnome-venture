local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- ico-world-map: folded sea chart with chunky continents, dotted route and a red X. quirk: tiny sea serpent hump.
local c = D.new("ico-world-map")
local paper = c:poly{{8,16},{22,12},{36,16},{55,12},{55,50},{36,54},{22,50},{8,54}}
D.lit(paper, D.SEA, 3, {nospec=true})
local conts = {
  c:poly{{12,22},{20,18},{26,22},{24,30},{28,36},{22,44},{16,38},{14,30}},
  c:poly{{34,20},{44,17},{51,21},{49,28},{42,29},{39,35},{35,30}},
  c:poly{{38,40},{46,37},{52,42},{47,48},{40,47}},
}
for _, m in ipairs(conts) do D.lit(m, D.LEAF2, 2) c:fillMask(m:copy():shrink(1):shrink(1), "#86c868") end
for i, m in ipairs(conts) do D.lit(m, D.LEAF2, 2.2) end
-- folds
for y = 13, 53 do
  local x1 = 22 + ((y%8<4) and 0 or 0)
  if paper:has(22, y) then c:px(22, y, "#2a4a7a") c:px(23, y, "#78b4ea") end
  if paper:has(36, y) then c:px(36, y, "#1c2e5a") c:px(37, y, "#b6dcf6") end
end
-- route and X
local pts = {{15,40},{20,36},{27,40},{32,34},{37,28}}
for i = 1, #pts - 1 do if i%1==0 then D.ln(pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], "#fff4d6") end end
for _, p in ipairs{{38,24},{39,25},{40,26},{41,27},{41,24},{40,25},{38,27}} do c:px(p[1], p[2], "#e8493b") end
c:px(39,25,"#ff8a5c")
c:rect(1,1,1,1)
-- sea serpent hump (quirk)
for _, p in ipairs{{24,46},{25,45},{26,45},{27,46},{28,47},{29,46},{30,45},{31,46}} do c:px(p[1], p[2], "#3a9c5f") end
c:px(26,44,"#b6f0e0") c:px(30,44,"#b6f0e0")
D.fin()
