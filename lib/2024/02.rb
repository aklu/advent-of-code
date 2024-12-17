# Helper function to check if a report is safe
def is_safe?(levels)
  increasing = levels.each_cons(2).all? { |a, b| b > a && (1..3).include?(b - a) }
  decreasing = levels.each_cons(2).all? { |a, b| b < a && (1..3).include?(a - b) }
  increasing || decreasing
end

# Helper function to check if removing one level makes the report safe
def can_be_made_safe?(levels)
  levels.each_with_index do |_, index|
    reduced_levels = levels[0...index] + levels[index + 1..]
    return true if is_safe?(reduced_levels)
  end
  false
end

levels = INPUT.split("\n").map { |line| line.split.map(&:to_i) }

# Part 1: Counting safe reports
safe_count = levels.count { |report| is_safe?(report) }

puts "The number of safe reports is #{safe_count}"

# Part 2: Counting safe reports with Problem Dampener
safe_with_dampener_count = levels.count do |report|
  is_safe?(report) || can_be_made_safe?(report)
end

puts "The number of safe reports with the Problem Dampener is #{safe_with_dampener_count}"
