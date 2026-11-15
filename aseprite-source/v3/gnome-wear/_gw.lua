-- _gw.lua: shared helpers for the gnome-wear icons and the Tailor building (Hearth Pop v3).
-- Read-only reuse of v3/items/batch1/_h.lua (pillow lighting) and batch2/_bbg.lua (tube, centre).
-- Run: AppRun -b --script-param png=<ph dir>/ --script <file>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../items/batch2/_bbg.lua")
local HP, X, K, P = G.HP, G.X, G.K, G.P
local W = { HP = HP, X = X, K = K, P = P, G = G, DIR = DIR }
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
W.png = app.params.png or (DIR .. "/out/")
W.CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }

-- 6-tone ramps, dark -> light (index 1..6)
W.R = {
  welly  = { "#1b3533", "#22503f", "#2e6b45", "#3f8a4c", "#5eab55", "#9cd27a" }, -- waxed green rubber
  lining = { "#5a3a2a", "#8a5a36", "#b07a46", "#cf9b5c", "#e6bd7e", "#f6dca6" }, -- tan cuff lining
  sole   = { "#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c" },
  water  = { "#2a4a7a", "#3a86b0", "#4fa8c4", "#5fc4c8", "#8fdcd8", "#c8f4ea" },
  felt   = { "#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a" },
  ember  = { "#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c" },
  jay    = { "#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6" },
  leather= { "#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a" },
  cuffL  = { "#4a2a22", "#6b3d2c", "#88523a", "#a26846", "#b98257", "#d0a070" },
  cloak  = { "#1c3530", "#264a3c", "#335f43", "#45784b", "#5e9452", "#86b464" },
  wood   = { "#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266" },
  canvas = { "#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0" },
  blanket= { "#5a1e30", "#86283a", "#ad3a3c", "#cc5544", "#e2744e", "#f39a62" },
  strap  = { "#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60" },
  brass  = { "#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0" },
  steel  = { "#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2" },
  yarnA  = { "#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62" }, -- rust red
  yarnB  = { "#1d4048", "#285e62", "#357c78", "#46998c", "#68b8a2", "#a2dcc0" }, -- pine teal
  lav    = { "#35295f", "#5a459e", "#8a6fd0", "#b69ae8", "#d6c4f6", "#efe4ff" },
  autumn = { "#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a" },
}
W.ink, W.cream = P.ink, P.cream

-- pillow-lit part; returns idx map and normals
function W.lit(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 3, o.hs)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or W.CUTS, bias = o.bias })
  return idx, n, v
end
-- normals given: tone them
function W.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or W.CUTS, bias = o.bias }), v
end
-- vertical cylinder between x0..x1
function W.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t * 0.95, o.tilt or -0.15, sqrt(1 - t * t) }
  end)
  local idx = W.toneN(c, m, n, ramp, o)
  return idx, n
end
-- re-tone pixels by f(x,y,i) -> delta (texture: grain, weave, knit)
function W.retone(c, m, idx, ramp, f)
  m:each(function(x, y)
    local k = K(x, y)
    local i = idx[k]
    if i then
      local d = f(x, y, i) or 0
      if d ~= 0 then
        local j = max(1, min(#ramp, i + d))
        idx[k] = j
        c:put(x, y, ramp[j])
      end
    end
  end)
end
function W.speckle(c, m, idx, ramp, p, seed)
  W.retone(c, m, idx, ramp, function(x, y, i)
    local h = X.hash(x, y, seed or 1)
    if h < p then return -1 elseif h > 1 - p * 0.6 and i < #ramp - 1 then return 1 end
  end)
end
-- colour pixels of `back` that touch `front` (4-neighbour), drawn BEFORE front is painted
function W.sep(c, front, back, col)
  front:grow(1):cut(front):clip(back):each(function(x, y) c:put(x, y, col) end)
end
function W.put(c, pts, col) for _, p in ipairs(pts) do c:put(p[1], p[2], col) end end
function W.hline(c, x0, x1, y, col) for x = x0, x1 do c:put(x, y, col) end end
function W.vline(c, x, y0, y1, col) for y = y0, y1 do c:put(x, y, col) end end

function W.save(c, name, o)
  o = o or {}
  c:finish{ outline = true }
  if o.centre ~= false then G.centre(c) end
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = W.png .. name .. ".png", scale = 1 }
end
return W
