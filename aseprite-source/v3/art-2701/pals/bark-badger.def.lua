-- Bark Badger (rootwarden): sturdy badger in a coat of bark plates. Quirk: a bracket mushroom grows on its back.
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 59, 22, 2)
  -- legs
  c:part(H.RR(15, 48, 24, 58, 3), "stone", { band = 1 })
  c:part(H.RR(40, 48, 49, 58, 3), "stone", { band = 1 })
  -- body (coat of bark)
  c:part(H.E(32, 42, 21, 13), "wood")
  -- bark plates
  local plate = { {14,34,24,42}, {26,30,38,38}, {40,34,50,43} }
  for _, p in ipairs(plate) do c:part(H.RR(p[1], p[2], p[3], p[4], 3), "wood", { band = 1, sep = true }) end
  -- head: stone-grey with the striped mask
  c:part(H.E(32, 27, 13, 11), "stone")
  c:part(H.Pg({ {23,16},{28,10},{36,10},{41,16},{41,19},{23,19} }), "stone", { noshade = true })
  -- face stripes (ink-dark bands, cream cheeks between)
  c:fillMask(H.R(28, 12, 36, 19), P.cream)
  c:fillMask(H.R(21, 21, 27, 33), P.stone.deep)
  c:fillMask(H.R(37, 21, 43, 33), P.stone.deep)
  -- snout
  c:part(H.E(32, 32, 6, 5), "stone", { noshade = true, nopop = true })
  c:fillMask(H.R(30, 30, 33, 31), P.ink)
  H.eye(27, 25) H.eye(37, 25)
  -- ears
  c:part(H.E(22, 15, 3.5, 3.5), "stone", { band = 1 })
  c:part(H.E(42, 15, 3.5, 3.5), "stone", { band = 1 })
  -- bracket mushroom on the back (quirk)
  c:part(H.Pg({ {30,30},{46,24},{54,30},{46,33} }), "ember", { band = 1 })
  if H.big then c:px(H.S(44), H.S(27), P.cream) c:px(H.S(48), H.S(29), P.cream) end
end
