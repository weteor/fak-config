let { tap, hold, td, combo, macro, ..} = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

let kc = tap.reg.kc in
let ks = tap.reg.ks in
let md = hold.reg.mod in
let tm = tap.reg.mod in
let tl = tap.layer in
let lt = hold.reg.layer in
let fak = tap.custom.fak in
let media = tap.custom.media in
let me = tap.custom.media in
let XXXX = tap.none & hold.none in

let ki = {
  hp = { decision = 'hold, trigger_on = 'press },
  tp = { decision = 'tap, trigger_on = 'press },
  hr = { decision = 'hold, trigger_on = 'release },
  tr = { decision = 'tap, trigger_on = 'release },
  xx = { decision = 'none },
} in

let cto = 50 in
let virtual_keys' = [
	# LEFT
	combo.make cto [ 1,  2], # TAB,
	combo.make cto [ 0,  1], # ESC,
	combo.make cto [ 1, 11], # LCBR
	combo.make cto [ 2, 12], # LBRC
	combo.make cto [ 3, 13], # LPRN
	combo.make cto [22, 23], # V   
	combo.make cto [ 2,  3], # Q   
    #  RIGHT
	combo.make cto [ 7,  8], # BSPC
	combo.make cto [ 6, 16], # RPRN
	combo.make cto [ 7, 17], # RBRC
	combo.make cto [ 8, 18], # RCBR
  combo.make cto [27, 28]  # ENT
	] in
	
let virtual_key_count = std.array.length virtual_keys' in
let key_count = 38 + virtual_key_count in
	
let layouts = {
  COLEMAK = "QWFPGJLUY'ARSTDHNEIOZXCVBKM,.;",
  APTMAK  = "QWFP  LUY'RSTHBJNAIOZCGDKXM,.;",  
} in

let make_hrm = fun key_idx =>
  let htb_hrm_base = fun eager => {
    timeout_ms = 180,
    # quick_tap_ms = 100,
    # quick_tap_interrupt_ms = 500,
    # global_quick_tap_ms = 80,
    eager_decision = eager,
    timeout_decision = 'hold,
  } in

  let virtual_interrupts = std.array.replicate virtual_key_count ki.hr in

  let htb_hrm_left = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tr, ki.tr, ki.tr, ki.tr, ki.tr,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.hr, ki.hr, ki.hr,        ki.hr,    ki.hr,        ki.hr, ki.hr, ki.hr
    ] @ virtual_interrupts
  } in

  let htb_hrm_right = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,       
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tr, ki.tr, ki.tr, ki.tr, ki.tr,
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
      ki.hr, ki.hr, ki.hr,        ki.hr,    ki.hr,        ki.hr, ki.hr, ki.hr
    ] @ virtual_interrupts
  } in

  let hrm_mods = [
    md.lsft, md.lgui, md.lalt, md.lctl, md.ralt,
    md.ralt, md.rctl, md.lalt, md.rgui, md.rsft,
  ] in

  let hrm_key_indices = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19] in

  if std.array.elem key_idx hrm_key_indices then
    let mod_idx = util.array.index_of key_idx hrm_key_indices in
    let side = if mod_idx < (std.array.length hrm_mods / 2) then 'left else 'right in
    let mod = std.array.at mod_idx hrm_mods in

    mod & hold.reg.behavior (
      (if side == 'left then htb_hrm_left else htb_hrm_right)
      (if mod == md.lgui || mod == md.lalt || mod == md.rgui || mod == md.ralt then 'none else 'hold)
    )
  else
    {}
in

let alphas = fun layout => layout
  |> std.string.characters
  |> util.array.enumerate
  |> std.array.map (
      fun { index, value } => kc."%{value}"
      & make_hrm index
    )
in

let thumb = fun thumb_idx =>
  let thumb_behavior = {
    timeout_ms = 180,
    timeout_decision = 'hold,
    key_interrupts = std.array.replicate key_count ki.hr,
  } in
  [
    kc.SPC  & lt 1 & hold.reg.behavior thumb_behavior,
    kc.ENT  & lt 2 & hold.reg.behavior thumb_behavior, 
    kc.E  & lt 2 & hold.reg.behavior thumb_behavior, 
  ]
  |> std.array.at thumb_idx
in

let cu = {
  # copy custom stuff from example
  COPY = md.lctl & kc.INS, # md.lctl & kc.C,
  PSTE = md.lsft & kc.INS, # md.lctl & kc.V,
  CUT  = md.lctl & kc.X,
} in

let combos_base = [
  kc.TAB, kc.ESC, ks.LCBR, kc.LBRC, ks.LPRN, kc.V, kc.Q,
  kc.BSPC, ks.RPRN, kc.RBRC, ks.RCBR, kc.ENT
] in

{
  virtual_keys = virtual_keys',
  layers = [
    let base = fun key_idx => (alphas layouts.COLEMAK) |> std.array.at key_idx in
    # ALPHAS
    [ 
      base 0,  base 1,  base 2,  base 3,  base 4,     base 5,  base 6,  base 7,  base 8,  base 9,
      base 10, base 11, base 12, base 13, base 14,    base 15, base 16, base 17, base 18, base 19,
      base 20, base 21, base 22, base 23, base 24,    base 25, base 26, base 27, base 28, base 29,
      media.VOLD, media.MUTE, media.VOLU, thumb 0,    thumb 1, media.PREV, media.PLAY, media.NEXT
    ] @ combos_base,
    # SYM NUM
    [
      kc.F9,   kc.F10,  kc.F11,  kc.F12,  tl.DF 3,        ks.PLUS, kc.N7,   kc.N8,  kc.N9,  XXXX,
      kc.F5,   kc.F6,   kc.F7,   kc.F8 ,  fak.BOOT,       kc.MINS, kc.N4,   kc.N5,  kc.N6,  kc.N0,
      kc.F1,   kc.F2,   kc.F3,   kc.F4,   XXXX,           XXXX,     kc.N1,   kc.N2,  kc.N3,  kc.DOT,
      XXXX,    XXXX,   XXXX,              XXXX,           XXXX,            XXXX,   XXXX,    XXXX
    ] @ combos_base,
    # NAV
    [
      XXXX,    kc.SLSH, kc.EQL,  kc.BSLS, XXXX,          XXXX,    kc.PGDN, kc.UP,   kc.PGUP,  XXXX,
      ks.AMPR, ks.EXLM, ks.PLUS, ks.UNDS, kc.GRV,        kc.HOME, kc.LEFT, kc.DOWN, kc.RGHT,  kc.END,
      ks.PIPE, ks.QUES, kc.MINS, ks.ASTR, ks.HASH,       XXXX,    XXXX,    XXXX,  XXXX, XXXX,
       XXXX,    XXXX,   XXXX,              XXXX,           XXXX,            XXXX,   XXXX,    XXXX
    ] @ combos_base,
    # ALPHAS APTMAK
    let base_a = fun key_idx => (alphas layouts.APTMAK) |> std.array.at key_idx in
    [ 
      base_a 0,  base_a 1,  base_a 2,  base_a 3,  base_a 4,     base_a 5,  base_a 6,  base_a 7,  base_a 8,  base_a 9,
      base_a 10, base_a 11, base_a 12, base_a 13, base_a 14,    base_a 15, base_a 16, base_a 17, base_a 18, base_a 19,
      base_a 20, base_a 21, base_a 22, base_a 23, base_a 24,    base_a 25, base_a 26, base_a 27, base_a 28, base_a 29,
      media.VOLD, media.MUTE, media.VOLU, thumb 0,    thumb 2, media.PREV, tap.layer.DF 0, media.NEXT
    ] @ combos_base,
  ]
}