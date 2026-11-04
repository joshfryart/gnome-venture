-- _b2g3.lua: private helpers for corn / corn-seed (batch2, Opus single pass). Read-only use of batch1/_g1.lua + _h.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G1 = dofile(DIR .. "/../batch1/_g1.lua")
local HP, X, K = G1.HP, G1.X, G1.K
local G = setmetatable({ DIR = DIR }, { __index = G1 })
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
G.out = app.params.out or (DIR .. "/")

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- corn-leaf strap veins: parallel lines along the blade (s bands), painted one step off the lit tone
function G.parallelVeins(c, m, idx, S, T, ramp, tok, bands, t0, t1, skip)
  m:each(function(x, y) local k = K(x, y)
    if skip and skip[k] then return end
    local s, t = S[k], T[k]
    if t < (t0 or 0.04) or t > (t1 or 0.92) then return end
    for _, b in ipairs(bands) do
      if abs(s - b) < 0.09 then
        local i = idx[k]
        local j = (s < 0) and min(#ramp, i + 1) or max(1, i - 1)
        c:put(x, y, ramp[j], tok) return
      end
    end
  end)
end

-- 1px polyline (hard pixels), optional colour per point index
function G.strand(c, pts, cols, tok)
  local out = {}
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n - 1 do
      local t = n == 0 and 0 or j / n
      out[#out + 1] = { floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5) }
    end
  end
  out[#out + 1] = pts[#pts]
  for i, p in ipairs(out) do
    local col = type(cols) == "table" and cols[min(#cols, 1 + floor((i - 1) / #out * #cols))] or cols
    c:put(p[1], p[2], col, tok)
  end
  return out
end

function G.save(c, name, dx)
  if dx and dx ~= 0 then   -- recentre: shift every pixel horizontally
    local pix, own = {}, {}
    for i, v in pairs(c.pix) do local x, y = i % c.w, i // c.w pix[y * c.w + x + dx] = v own[y * c.w + x + dx] = c.own[i] end
    c.pix, c.own = pix, own
  end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.out .. name .. ".aseprite", png = G.out .. name .. ".png", scale = 1 }
end
return G
