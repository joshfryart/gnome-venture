-- dC31 helper: thin layer over batch2/_b2.lua (not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P }
D.R = {
  leaf   = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" },
  silver = { "#2a4640", "#3f6659", "#5e8a76", "#86ae96", "#b3cdb2", "#dce6cc" },
  orange = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" },
  gold   = { "#6a3a20", "#a05a22", "#cf8a2a", "#eab33e", "#f8d26a", "#fff0a8" },
  cream  = { "#8a7a68", "#b8a68a", "#d9c8a6", "#ecdfc0", "#f6ecd6", "#fffaf0" },
  wood   = { "#2f1c1c", "#4a2c26", "#6b4332", "#8e6040", "#b88458", "#dcb27a" },
  seed   = { "#22141a", "#371d1f", "#512a24", "#6f3c2b", "#925636", "#b97c4c" },
  stem   = { "#2c3a3e", "#3f5450", "#5a745c", "#7c966c", "#a6bc88", "#c8d8a0" },
  ink    = { "#14101a", "#241c2c", "#383048", "#504868", "#706890", "#9a94b8" },
  amber  = { "#6a2a10", "#9c4414", "#c8661c", "#e68a2a", "#f6b04a", "#ffd88a" },
  glass  = { "#3a6a86", "#5a9cb8", "#86c8d8", "#b2e4ea", "#d6f4f2", "#f4fffa" },
}
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
D.lit, D.ell, D.ln, D.polyline, D.blade, D.seam, D.seed = B.lit, B.ell, B.ln, B.polyline, B.blade, B.seam, B.seed
D.cyl, D.sweep, D.mix, D.ramp = H.cyl, H.sweep, H.mix, H.ramp
function D.sprout(c, S)
  local stem = S.stem or "#7c966c"
  B.ln(c, S.x0, S.y0, S.x1, S.y1, stem) B.ln(c, S.x0 + 1, S.y0, S.x1 + 1, S.y1, D.mix(stem, "#2b1c26", .25))
  for _, l in ipairs(S.leaves) do B.blade(c, l[1], l[2], l[3], l[4], l[5], l[6] or D.R.leaf, { veins = l.veins, prof = l.prof, norib = l.norib }) end
end
function D.seedScrap(c, o)
  local L = o.leaf
  B.blade(c, L[1], L[2], L[3], L[4], L[5], L[6] or D.R.leaf, { veins = L.veins or { 8, 14, 20, 26 }, slant = L.slant, prof = L.prof, norib = L.norib })
  if o.extra then o.extra(c, 1) end
  for _, s in ipairs(o.seeds) do B.seed(c, s[1], s[2], s[3], s[4], s[5], s.ramp or o.seedRamp, o.shadow or "#143a2e", o.glint) end
  if o.sprout then D.sprout(c, o.sprout) end
  if o.extra then o.extra(c, 2) end
end
return D
