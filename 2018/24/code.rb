MATCHER = /(?<unit_count>\d+) units each with (?<health>\d+) hit points(?<specialties>( \(.+\))?) with an attack that does (?<damage>\d+) (?<damage_type>.+) damage at initiative (?<initiative>\d+)/
WEAKNESS_MATCHER = /weak to (?<damage_types>[^;)]+)+/
IMMUNITY_MATCHER = /immune to (?<damage_types>[^;)]+)+/

class Group
  TEAMS = { immune: "Immune System", infection: "Infection" }.freeze

  attr_accessor :size, :damage
  attr_reader :team, :multipliers, :health, :initiative

  def initialize(team, size, health, damage, damage_type, initiative, specialties)
    @team, @size, @health, @damage, @type, @initiative = team, size, health, damage, damage_type, initiative
    @multipliers = Hash.new(1).merge(specialties)
  end

  def effective_power
    size * damage
  end

  def target(groups)
    enemies = groups.reject { |g| g.team == team }
    return nil if enemies.empty?

    enemy = enemies.max_by { |enemy| [damage_to(enemy), enemy.effective_power, enemy.initiative] }
    damage_to(enemy) == 0 ? nil : enemy
  end

  def damage_to(enemy)
    effective_power * enemy.multipliers[@type]
  end

  def dead?
    size <= 0
  end

  def infection?
    team == TEAMS[:infection]
  end

  def immune?
    team == TEAMS[:immune]
  end
end

groups = []
team = Group::TEAMS[:immune]

INPUT.split("\n").each do |line|
  case line
  when MATCHER
    data = $~

    multipliers = [[WEAKNESS_MATCHER, 2], [IMMUNITY_MATCHER, 0]].flat_map do |matcher, m|
      specialty = data[:specialties].match(matcher)
      next unless specialty

      specialty[:damage_types].split(", ").map { |type| [type.to_sym, m] }
    end.compact

    groups << Group.new(
      team,
      data[:unit_count].to_i,
      data[:health].to_i,
      data[:damage].to_i,
      data[:damage_type].to_sym,
      data[:initiative].to_i,
      Hash[multipliers],
    )
  when "Infection:"
    team = Group::TEAMS[:infection]
  end
end

def targets_for(groups)
  target_order = groups.sort_by { |g| [-g.effective_power, -g.initiative] }
  target_order.each_with_object({}) do |group, targets|
    targets[group] = group.target(groups - targets.values)
  end
end

def fight(groups, immune_boost = 0)
  groups = groups.map(&:dup)
  groups.select(&:immune?).each { |group| group.damage += immune_boost }

  loop do
    targets = targets_for(groups)
    kill_count = 0
    groups.sort_by { |group| -group.initiative }.each do |group|
      next if group.dead?
      next unless target = targets[group]

      kill_count += kills = group.damage_to(target) / target.health
      target.size = [0, target.size - kills].max
    end

    break if kill_count == 0

    groups.reject!(&:dead?)
    break if groups.all?(&:immune?) || groups.all?(&:infection?)
  end

  winner =
    if groups.all?(&:infection?)
      :infections
    elsif groups.all?(&:immune?)
      :immune_system
    else
      :neither
    end

  return [winner, groups.map(&:size).sum]
end

_, score = fight(groups)
puts "The number of units remaining for the winning army is:", score, nil

final = 1.step do |boost|
  winner, score = fight(groups, boost)
  break score if winner == :immune_system
end

puts "The number of immune system units remaining after a minimal boost is:", final
