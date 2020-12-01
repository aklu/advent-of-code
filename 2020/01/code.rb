NUMBERS = INPUT.split("\n").map(&:to_i)
TARGET = 2020

def entry_product(count)
  entries = NUMBERS.combination(count).detect { |combo| combo.sum == TARGET }
  entries.inject(:*)
end

puts "The product of the two entries is:", entry_product(2), "\n"
puts "The product of the three entries is:", entry_product(3)
