class Row
  TRAP_SETUPS = [
    [true, false, false],
    [true, true, false],
    [false, true, true],
    [false, false, true]
  ].freeze

  def initialize
    @traps = []
  end

  def <<(trap)
    @traps << trap
  end

  def next
    new_row = Row.new

    new_row << trapped?([false, @traps[0], @traps[1]])
    @traps.each_cons(3) { |tiles| new_row << trapped?(tiles) }
    new_row << trapped?([@traps[-2], @traps[-1], false])

    new_row
  end

  def trapped?(tiles)
    TRAP_SETUPS.include?(tiles)
  end

  def safe_tiles
    @traps.count(&:!)
  end

  def to_s
    @traps.map { |trap| trap ? "^" : "." }.join
  end
end

def grid_for(input, size)
  first_row = Row.new
  input.chars.each { |char| first_row << (char == "^") }

  current_row = first_row
  grid = (size - 1).times.map { current_row = current_row.next }
  grid.unshift(first_row)

  grid
end

ROW_COUNT ||= 40
grid = grid_for(INPUT, ROW_COUNT)
solve!("The number of safe tiles in 40 rows is:", grid.sum(&:safe_tiles))

grid = grid_for(INPUT, 400_000)
solve!("The number of safe tiles in 400,000 rows is:", grid.sum(&:safe_tiles))
