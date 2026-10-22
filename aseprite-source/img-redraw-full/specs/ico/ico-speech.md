# ico/ico-speech
- canvas: 64x64, mode icon, 1x.
- subject: A rounded speech-bubble icon for sending feedback, with three dots inside and a tail at the lower left; friendly.
- must-read-at-16px: a wide blue rounded bubble with a tail pointing down-left and three light dots.
- distinct: three-dot ellipsis bubble with a thick bottom-left tail; a plain pillow bubble, not a rectangular panel.
- parts:
  1. bubble body: rrect x 8..56, y 8..44 (r 7), base #3f8fb0 (water)
  2. tail: poly (16,42)->(30,42)->(16,56), same #3f8fb0, merged with body (no seam)
  3. top sheen band: rrect x 8..56, y 8..20, lighter #8fcbd8 (rim family), min 3px
  4. three dots: circles r3 at (22,26),(32,26),(42,26), #f4f0e0 (pale)
- joins: none.
- face: none.
- notes: water ramp, umber outline. Parts min 3 px, dots 6 px wide. Gloss on upper-left of bubble above the left dot. Tail clearly longer than a notch.
