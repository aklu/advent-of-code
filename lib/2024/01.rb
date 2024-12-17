numbers = INPUT
first_list = []
second_list = []
differences = []

numbers.split("\n").each do |line|
  first_list << line.split("   ")[0].to_i
  second_list << line.split("   ")[1].to_i
end

first_list.sort!()
second_list.sort!()


first_list.each_with_index do |number, index|
  differences << (number - second_list[index]).abs
end

puts "The answer to part one is: #{differences.reduce(&:+)}"

total = []
first_list.each do |number|
  total << number * second_list.count(number)
end

puts "The answer to part two is: #{total.reduce(&:+)}"
