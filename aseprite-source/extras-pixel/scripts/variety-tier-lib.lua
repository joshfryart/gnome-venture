-- variety-tier-lib.lua : helpers for the variety-tier-<kind>.lua scripts (stoptiers 96x96 icons).
-- T.canvas(GV) returns a proxy of an icon-mode 96x96 canvas whose shape calls are shifted by
-- (9, 9), so art is drawn in a 76x76 box (0..75) and keeps room for the 3 px outline and black border.
local T = {}
local OX, OY = 9, 9
local function sh(pts) local r = {} for i, p in ipairs(pts) do r[i] = { p[1] + OX, p[2] + OY } end return r end

function T.canvas(GV)
  local c = GV.canvas{ w = 96, h = 96, mode = "icon" }
  local P = { raw = c, GV = GV }
  function P:rect(a, b, d, e) return c:rect(a + OX, b + OY, d + OX, e + OY) end
  function P:rrect(a, b, d, e, r) return c:rrect(a + OX, b + OY, d + OX, e + OY, r) end
  function P:ellipse(x, y, rx, ry) return c:ellipse(x + OX, y + OY, rx, ry) end
  function P:poly(pts) return c:poly(sh(pts)) end
  function P:line(pts, w) return c:line(sh(pts), w) end
  function P:px(x, y, h) return c:px(x + OX, y + OY, h) end
  function P:button(x, y) return c:button(x + OX, y + OY) end
  function P:eye(x, y, s) return c:eye(x + OX, y + OY, s) end
  function P:seam(pts, o) return c:seam(sh(pts), o) end
  function P:paint(rows, x, y, lg) return c:paint(rows, x + OX, y + OY, lg) end
  function P:ground(x, y, rx, ry, h) return c:ground(x + OX, y + OY, rx, ry, h) end
  function P:part(m, r, o) return c:part(m, r, o) end
  function P:build(l) return c:build(l) end
  function P:fill(m, h) return c:fill(m, h) end
  function P:spot(m, h, g) return c:spot(m, h, g) end
  function P:stitch(m, o) return c:stitch(m, o) end
  function P:save(a, b) return c:save(a, b) end
  function P:get(x, y) return c:get(x + OX, y + OY) end
  function P:mask() return c:mask() end
  return P
end

-- gold gear (flat gold part, 4 side teeth + 4 diagonal teeth, brown hole)
function T.gear(c, cx, cy, r, hole)
  local m = c:ellipse(cx, cy, r, r)
  m:add(c:rect(cx - 1, cy - r - 2, cx + 1, cy + r + 2))
  m:add(c:rect(cx - r - 2, cy - 1, cx + r + 2, cy + 1))
  local d = math.floor(r * 0.72)
  for _, sx in ipairs({ -1, 1 }) do for _, sy in ipairs({ -1, 1 }) do
    m:add(c:rect(cx + sx * d - 1, cy + sy * d - 1, cx + sx * d + 1, cy + sy * d + 1))
  end end
  c:part(m, "gold", { flat = true })
  c:fill(c:ellipse(cx, cy, 1.5, 1.5), hole or "#8a4a1c")
end

function T.save(c, GV, ROOT, OUT, kind, n)
  local t = c:save(ROOT .. "extras-pixel/aseprite/variety-tier-" .. kind .. "-" .. n .. ".aseprite", OUT .. kind .. "-" .. n .. ".png")
  print(kind, n, GV.report(t))
  assert(t.semi == 0)
end

return T
