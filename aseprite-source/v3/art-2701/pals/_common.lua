-- shared helpers: draw in a 64-grid, output at any size (perch 36, yard 64). Perch drops fine detail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../lib/hp.lua")
local P = dofile(dir .. "/../../lib/palette.lua")
local M = {HP = HP, P = P}
function M.new(name, size)
  local c = HP.canvas{ w = size, h = size, scale = 1, name = name }
  local k = size / 64
  local big = size >= 48
  local function S(v) return math.floor(v * k + 0.5) end
  local H = { c = c, big = big, P = P, k = k, S = S }
  function H.R(x0, y0, x1, y1) local a, b = S(x0), S(y0); return c:rect(a, b, math.max(a, S(x1 + 1) - 1), math.max(b, S(y1 + 1) - 1)) end
  function H.E(cx, cy, rx, ry) return c:ellipse(math.floor(cx * k * 2 + 0.5) / 2, math.floor(cy * k * 2 + 0.5) / 2, math.max(1, rx * k), math.max(1, ry * k)) end
  function H.RR(x0, y0, x1, y1, r) local a, b = S(x0), S(y0); return c:rrect(a, b, math.max(a + 1, S(x1 + 1) - 1), math.max(b + 1, S(y1 + 1) - 1), math.max(1, math.floor(r * k))) end
  function H.Pg(pts) local o = {} for i, p in ipairs(pts) do o[i] = { S(p[1]), S(p[2]) } end return c:poly(o) end
  function H.px(x, y, col) c:px(S(x), S(y), col) end
  function H.dot(x, y, col) -- 1px at scaled pos
    c:px(S(x), S(y), col) end
  function H.eye(cx, cy) -- locked eye on yard, small pill on perch
    if big then c:eyeLocked(S(cx) - 2, S(cy) - 2) else c:eyeSmall(S(cx) - 1, S(cy) - 1) end
  end
  function H.cheek(x, y) if big then c:cheek(S(x), S(y)) else c:px(S(x), S(y), P.petal.base) end end
  function H.shadow(cx, cy, rx, ry) c:groundShadow(S(cx), S(cy), math.max(2, S(rx)), math.max(1, S(ry))) end
  function H.done(out, file)
    c:finish{ outline = true }
    HP.report(c) HP.assertClean(c)
    c:save{ aseprite = out .. file .. ".aseprite", png = out .. file .. ".png", scale = 1 }
  end
  return H
end
return M
