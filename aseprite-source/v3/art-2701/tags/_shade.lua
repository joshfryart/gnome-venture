-- shared mini-helper for the 2701 tag icons: canvas, ramp shading by light gradient + edge depth, save.
local base = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(base .. "/../../lib/hp.lua")
local S = { HP = HP }
S.out = app.params.out or "./"
S.R = {
  wood  = { "#3e2423", "#51302b", "#864c33", "#b97a4a", "#d9a066", "#f0cc92" },
  steel = { "#34374f", "#444663", "#74758c", "#9d9cb0", "#c8c7d4", "#eeedf2" },
  gold  = { "#6b3a1c", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff0b8" },
  moss  = { "#1e3f42", "#24544a", "#3f9150", "#7cc35a", "#a9d66b", "#d6efa0" },
  ember = { "#4e1a30", "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c", "#ffc09a" },
  skin  = { "#6e3a3a", "#9b4f45", "#cf7a5c", "#eaa07a", "#f6c39a", "#ffe0bc" },
  sea   = { "#1f3558", "#2a4a7a", "#3a86b0", "#5fc4c8", "#9fe0d8", "#d4f6ec" },
  dusk  = { "#241a47", "#35295f", "#5a459e", "#8a6fd0", "#b49be6", "#dccdf6" },
  stone = { "#2f3150", "#444663", "#74758c", "#aaa9b8", "#cfced8", "#e8e6ec" },
  amber = { "#3a1f1c", "#5c2c1c", "#8f4a1f", "#c27a2a", "#e8a640", "#ffd47a" },
}
function S.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- fill mask m with 6-tone ramp R. light gradient along (lx,ly) (default upper-left), edge depth lifts the interior.
function S.fill(c, m, R, o)
  o = o or {}
  local lx, ly = o.lx or 1, o.ly or 1
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return end
  local w, h = math.max(1, x1 - x0), math.max(1, y1 - y0)
  local d1, d2 = m:shrink(1), m:shrink(2)
  local lo, hi = 0, math.abs(lx) * w + math.abs(ly) * h
  m:each(function(x, y)
    local t = ((x - x0) * lx + (y - y0) * ly)
    if lx < 0 then t = t + (-lx) * w end
    if ly < 0 then t = t + (-ly) * h end
    local g = 1 - t / hi
    local v = 0.68 * g + (d1:has(x, y) and 0.14 or 0) + (d2:has(x, y) and 0.12 or 0)
    local i = math.floor(v * 6.3) + 1 + (o.bias and o.bias(x, y) or 0)
    i = math.max(1, math.min(6, i))
    c:put(x, y, R[i])
  end)
end
function S.save(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = S.out .. name .. ".aseprite", png = S.out .. name .. ".png", scale = 1 }
end
return S
