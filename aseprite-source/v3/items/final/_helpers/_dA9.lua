-- _dA9: helper for chunk dA9 first drafts (ico-roadworks .. ico-soup-bowl). Layer over _dA0 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA0.lua")
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- 6-tone ramps, dark -> light
D.TAN   = { "#5a3a28", "#8a5a38", "#b58650", "#d4a468", "#e8c488", "#f8e2b4" }
D.CRM   = { "#a88a6a", "#d4b48a", "#ecd4a8", "#f8e8c0", "#fff2d4", "#fffbec" }
D.GRY   = { "#3a3d56", "#5a5e7c", "#7e829e", "#a4a8c0", "#cdd0e2", "#eef0fa" }
D.GRN   = { "#14382f", "#1f5a44", "#2f8450", "#3fa862", "#6cc880", "#aeeaa0" }
D.RED   = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.ORG   = { "#6e2a18", "#a8441c", "#d9661f", "#f58a2c", "#ffaa50", "#ffd080" }
D.YEL   = { "#8f4a1f", "#c98a1c", "#eeb52a", "#fcd04a", "#ffe57a", "#fff5b8" }
D.PINK  = { "#6e2150", "#a33468", "#d4527e", "#f27a9a", "#ffa4bc", "#ffd0dc" }
D.BLU   = { "#1c2e5a", "#2a4a7a", "#3a6aa6", "#4a8acc", "#78b4ea", "#b6dcf6" }
D.ICE   = { "#2a4a7a", "#3a6aa6", "#4a9ad0", "#78c8e8", "#b6ecf6", "#f0fdff" }
D.TEAL  = { "#1d3a4e", "#2a5a6c", "#2f8a86", "#3fb0a0", "#6fd6b8", "#b6f0e0" }
D.BRN   = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
D.GOLD  = { "#8f4a1f", "#c26a24", "#d98322", "#f5b82e", "#ffd45a", "#fff0a0" }
function D.mk(x0, y0, x1, y1, f)
  local m = D.HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end
function D.R(c, x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
function D.pts(c, list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
-- lit thick polyline
function D.tube(c, pts, w, ramp, R) local m = c:line(pts, w) D.lit(c, m, ramp, R or 2.5) return m end
-- bezier sample points
function D.bez(p, n)
  local o = {}
  for i = 0, n do local t = i / n local u = 1 - t
    o[#o + 1] = { u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
                  u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2], t }
  end
  return o
end
-- disc-swept mask along sample points with radius fn(t)
function D.swept(c, pts, rf)
  local m = D.HP.mask()
  for _, q in ipairs(pts) do
    local r = rf(q[3]) local ri = math.ceil(r)
    for dy = -ri, ri do for dx = -ri, ri do
      if dx*dx + dy*dy <= r*r + 0.3 then m:set(floor(q[1] + dx + .5), floor(q[2] + dy + .5)) end
    end end
  end
  return m
end
return D
