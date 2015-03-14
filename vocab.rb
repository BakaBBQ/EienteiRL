

VOCABS = {
  wall:   ["You bumped into the wall", "Silly me.", "Oh that kind of hurts"],
  very_light_dmg:   ["%s looks unscathed"],
  light_dmg:   ["%s looks unscathed"],
  moderate_to_upper:   ["%s is moderately wounded"],
  moderate:   ["%s is moderately wounded"],
  moderate_to_lower:   ["%s is heavily wounded"],
  dead: ["%s is slain"],
  dying:   ["%s is dying"],
  failed_borrow: ["Oops, maybe next time.","Stealing failed..."],

  six_realms:   ["Phantom Shot"],
  mysterious_jack:   ["Mysterious Jack"],
  stardust_missle:   ["Stardust Missile"],
  flower_slash:   ["Lotus Cut"],
  changeling_magic:   ["Changeling Magic"],
  close_up_magic:   ["Close-up Magic"],
  vanish_everything:   ["Vanish Everything"],
  magic_star_sword:   ["Magic Star Sword"],
  doll_placement:    ["Doll Placement"],
  edo:  ["Edo Pawn"],
  ambush:   ["Doll Ambush"],
  servant:   ["Doll Servant"],
  bullet_absorb: ["Bullet Absorber"],
  phosphorus_slash: ["Phosphorus Slash"],
  magic_dust: ["Grand Stardust"],
  summer_flame: ["Summer Flame"],
  doll_recycling: ["Doll Recycle"],
  time_stop: ["Sakuya's World"],
  borrow: ["Borrow"],
}
def get_vocab(key, *args)
  sprintf(VOCABS[key].sample, *args)
end
