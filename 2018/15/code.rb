class Unit
  TEAMS = { elf: "E", goblin: "G" }.freeze

  attr_reader :team, :attack
  attr_accessor :hp, :position

  def initialize(team, position)
    @team, @position = team, position
    @hp = 200
    @attack = 3
  end

  def dead?
    @hp <= 0
  end
end

class Map
  def initialize(map)
    @map = map
  end

  def move(unit, destination)
    @map[unit.position] = false
    unit.position = destination
    @map[unit.position] = unit
  end

  def search(start, targets)
    queue =[[start, 0]]
    graph = { start => nil }
    destinations = []

    loop do
      break if queue.empty?
      spot, steps = queue.shift

      if targets.include?(spot)
        queue.reject! { |_, s| s > steps }
        destinations << spot
      end

      next unless destinations.empty?

      neighbors(spot).each do |neighbor|
        next if graph.key?(neighbor)
        next if @map[neighbor]

        graph[neighbor] = spot
        queue << [neighbor, steps + 1]
      end
    end

    return nil unless destinations.any?

    destination = destinations.min
    destination = graph[destination] while graph[destination] != start
    destination
  end

  def neighbors((y, x))
    [[y - 1, x], [y, x - 1], [y, x + 1], [y + 1, x]]
  end
end

def combat!(grid, bonuses = {})
  units = grid.values.select { |u| u.is_a?(Unit) }.compact.map(&:dup)

  map = Map.new(grid)
  deaths = Hash.new(0)
  rounds = 0

  loop do
    round = units.sort_by(&:position).each do |unit|
      break false if units.uniq(&:team).size == 1
      next if unit.dead?

      enemies = units.select { |u| u.team != unit.team }
      targets = enemies.flat_map { |enemy| map.neighbors(enemy.position) }

      unless targets.include?(unit.position)
        destination = map.search(unit.position, targets)
        map.move(unit, destination) if destination
      end

      nearby = enemies.select { |enemy| map.neighbors(enemy.position).include?(unit.position) }
      next unless target = nearby.min_by { |enemy| [enemy.hp, enemy.position] }

      target.hp -= unit.attack + bonuses[unit.team].to_i
      if target.dead?
        deaths[target.team] += 1
        grid[target.position] = false
        units.delete(target)
      end
    end

    break unless round
    rounds += 1
  end

  [rounds * units.sum(&:hp), deaths]
end

GRID = INPUT.split("\n").each_with_object({}).with_index do |(row, g), y|
  row.chars.each_with_index do |c, x|
    g[[y, x]] =
      case c
      when *Unit::TEAMS.values then Unit.new(c, [y, x])
      when "." then false
      else true
      end
  end
end

outcome, _ = combat!(GRID.dup)
puts "Outcome after standard combat:", outcome, nil

outcome = 1.step do |elf_bonus|
  score, deaths = combat!(GRID.dup, { Unit::TEAMS[:elf] => elf_bonus })
  break score unless deaths[Unit::TEAMS[:elf]] > 0
end

puts "Outcome after a decisive elf win:", outcome