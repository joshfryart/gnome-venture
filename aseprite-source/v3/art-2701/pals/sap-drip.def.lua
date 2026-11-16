-- Sap Drip (brewroot): a glossy amber drop of maple sap, slow and always late. Quirk: a tiny fly is stuck in its middle.
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 59, 15, 2)
  c:part(H.E(25, 56, 4, 2.5), "gold", { band = 1, nopop = true })
  c:part(H.E(39, 56, 4, 2.5), "gold", { band = 1, nopop = true })
  -- tapering drop: pointed top, round belly
  c:part(H.Pg({ {32,4},{26,18},{20,30},{19,40},{22,50},{32,56},{42,50},{45,40},{44,30},{38,18} }), "gold", { band = 3 })
  c:part(H.E(32, 42, 11, 11), "gold", { noshade = true, nopop = true })
  c:part(H.E(34, 46, 8, 7), "gold", { noshade = true, nopop = true })
  c:fillMask(H.E(35, 49, 6, 4), P.gold.shade)
  c:fillMask(H.R(24, 26, 26, 31), P.gold.hi)
  c:fillMask(H.R(22, 34, 23, 38), P.cream)
  c:fillMask(H.R(30, 12, 31, 15), P.gold.hi)
  H.eye(27, 41) H.eye(37, 41)
  H.cheek(22, 47) H.cheek(41, 47)
  c:px(H.S(32), H.S(48), P.wood.deep) c:px(H.S(31), H.S(47), P.wood.deep) c:px(H.S(33), H.S(47), P.wood.deep)
  -- trapped fly (quirk)
  c:fillMask(H.R(34, 31, 35, 32), P.ink)
  c:fillMask(H.R(32, 29, 33, 30), P.sky.hi)
  c:fillMask(H.R(36, 29, 37, 30), P.sky.hi)
  -- slow drip below the chin
  c:part(H.E(50, 54, 2.5, 3), "gold", { band = 1, nopop = true })
end
