-- ico-path first draft (Sonnet). quirk: a tiny snail crosses the winding path
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-path")
local tile = c:rrect(6, 8, 57, 56, 6)
-- sky
D.fill(tile, "#b9e2f5") D.fill(tile:copy():clip(c:rect(0, 0, 63, 17)), "#e4f6ff")
D.fill(D.ell(48, 17, 4, 4), "#ffe38a")
-- far hill
D.fill(tile:copy():clip(D.ell(20, 34, 30, 14)), "#8bc4ea")
D.fill(tile:copy():clip(D.ell(18, 34, 30, 14)), "#7cc3a8")
-- green hill
local gr = tile:copy():clip(c:poly{ {0, 28}, {20, 24}, {40, 26}, {63, 30}, {63, 63}, {0, 63} })
D.lit(gr, "moss", 4)
D.fill(gr:copy():clip(c:rect(0, 46, 63, 63)), "#3f9150")
-- winding path
local path = HP.mask()
for y = 25, 56 do
  local t = (y - 25) / 31
  local cx = 34 + 13 * sin(t * 4.2 - 0.5) * t * 0.9 - 4 * (1 - t)
  local hw = 1.5 + 8 * t
  for x = floor(cx - hw), floor(cx + hw) do if gr:has(x, y) or tile:has(x, y) then path:set(x, y) end end
end
path:clip(tile)
D.fill(path, "#e8b982")
path:each(function(x, y) if not path:has(x + 1, y) then c:px(x, y, "#b97a4a") end if not path:has(x - 1, y) then c:px(x, y, "#fff0cc") end end)
for _, p in ipairs{ {32,31},{37,38},{27,45},{36,50},{30,53},{41,45} } do if path:has(p[1], p[2]) then D.fill(c:rect(p[1], p[2], p[1] + 1, p[2]), "#b97a4a") end end
-- signpost
D.fill(c:rect(15, 30, 16, 42), "#51302b") D.fill(c:poly{ {10, 28}, {21, 28}, {23, 31}, {21, 34}, {10, 34} }, "#e8b982")
D.fill(c:rect(10, 34, 21, 34), "#864c33") D.fill(c:rect(12, 30, 18, 30), "#864c33")
-- snail
D.lit(D.ell(37, 51, 3, 3), "ember", 1.5)
D.fill(c:rect(33, 53, 41, 54), "#e8b982") c:px(32, 51, "#e8b982") c:px(32, 50, "#e8b982") c:px(31, 49, "#2b1c26")
D.fin()
