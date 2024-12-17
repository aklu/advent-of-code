pattern = /mul\((\d+),(\d+)\)/ 
# mul\( matches the string mul(.
# (\d{1,3}) captures X, which is numbers.
# , matches comma.
# (\d{1,3}) captures Y, which is also numbers
# \) matches closing parenthesis.
corrupted_data = INPUT

# Part 1
matches = corrupted_data.scan(pattern)
total = matches.sum { |x, y| x.to_i * y.to_i }
puts "the answer to part 1 is: #{total}"

# Part 2
do_regex = /do\(\)/
dont_regex = /don't\(\)/
enabled = true
sum = 0

input.scan(/mul\(\d+,\d+\)|do\(\)|don't\(\)/).each do |instruction|
  case instruction
  when pattern
    # If a valid `mul` is found and enabled, get the sum
    if enabled
      x, y = instruction.match(pattern).captures.map(&:to_i)
      sum += x * y
    end
  when do_regex
    enabled = true
  when dont_regex
    enabled = false
  end
end

puts "the answer to part 2 is: #{sum}"
