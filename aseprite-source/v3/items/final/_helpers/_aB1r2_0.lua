-- _aB1r2_0.lua: private helpers for ph/chestnut (final pass, Opus). Read-only use of batch2/_b2g1.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
-- save into final/<folder>/ regardless of params
function A.saveTo(c, folder, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local o = DIR .. "/../" .. folder .. "/"
  c:save{ aseprite = o .. name .. ".aseprite", png = o .. name .. ".png", scale = 1 }
end
-- 1px line in hex (Bresenham), optional clip mask, optional owner token
function A.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local e = dx + dy
  while true do
    if not clip or clip:has(x0, y0) then c:put(x0, y0, hex, tok) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * e
    if e2 >= dy then e = e + dy x0 = x0 + sx end
    if e2 <= dx then e = e + dx y0 = y0 + sy end
  end
end
return A
