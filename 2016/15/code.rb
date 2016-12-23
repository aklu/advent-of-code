DISC_MATCHER = /Disc #\d+ has (?<position_count>\d+) positions; at time=0, it is at position (?<starting_position>\d+)\./.freeze

class Disc

  def initialize(positions, starts_at)
    @positions = positions
    @starts_at = starts_at
  end

  def passable_at?(ticks)
    (@starts_at + ticks) % @positions == 0
  end

end

def valid_time(discs)
  valid = false
  time = 0

  begin
    valid = true
    time += 1

    discs.each.with_index(1) do |disc, delay|
      break valid = false unless disc.passable_at?(time + delay)
    end
  end while !valid

  time
end

discs = INPUT.split("\n").map do |line|
  matches = line.match(DISC_MATCHER)
  Disc.new(matches[:position_count].to_i, matches[:starting_position].to_i)
end

puts "The first valid drop time is:", valid_time(discs), nil

discs << Disc.new(11, 0)
puts "The first valid drop time (with the extra disc) is:", valid_time(discs)