VOCABS = {
  :wall => [
    'You bumped into the wall.',
    'Silly me.',
    'Oh that kind of hurts...'
  ]
}
def get_vocab(key)
  VOCABS[key].sample
end
