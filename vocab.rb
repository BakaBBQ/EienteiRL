VOCABS = {
  :wall => [
    'You bumped into the wall.',
    'Silly me.',
    'Oh that kind of hurts...'
  ],
  
  :very_light_dmg => [
    '%s looks unscathed.',
  ],
  
  :light_dmg => [
    '%s looks unscathed.',
  ],
  
  :moderate_to_upper => [
    '%s is moderately wounded.',
  ],
  
  :moderate => [
    '%s is moderately wounded.',
  ],
  
  :moderate_to_lower => [
    '%s is heavily wounded.',
  ],
  
  :dying => [
    '%s is dying.',
  ],
}
def get_vocab(key, *args)
  sprintf(VOCABS[key].sample, *args)
end
