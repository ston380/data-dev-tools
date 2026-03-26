# ============================================================
# data-dev-tools Brewfile (aggregate)
# Includes all group Brewfiles from brewfiles/
# Run: brew bundle --file=Brewfile
# ============================================================

Dir.glob("#{__dir__}/brewfiles/Brewfile.*").sort.each do |f|
  instance_eval File.read(f), f
end
