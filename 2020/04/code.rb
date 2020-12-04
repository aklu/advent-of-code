FIELD_MATCHER = /(?<name>.{3})\:(?<value>.*)/
PASSPORTS = INPUT.split("\n\n").map do |data|
  data.split(/\n| /).each_with_object({}) do |field, passport|
    field_data = field.match(FIELD_MATCHER)
    passport[field_data[:name]] = field_data[:value]
  end
end

def between?(min, max)
  ->(value) { value.to_i >= min && value.to_i <= max }
end

REQUIRED_FIELDS = %w[byr iyr eyr hgt hcl ecl pid]
VALIDITY_RULES = {
  "byr" => between?(1920, 2002),
  "iyr" => between?(2010, 2020),
  "eyr" => between?(2020, 2030),
  "hgt" => ->(value) do
    data = value.match(/^(?<value>\d+)(?<unit>cm|in)$/)

    case data&.[](:unit)
    when "in" then between?(59, 76)
    when "cm" then between?(150, 193)
    else return false
    end.call(data[:value])
  end,
  "hcl" => /^\#\h{6}$/,
  "ecl" => /^(amb|blu|brn|gry|grn|hzl|oth)$/,
  "pid" => /^\d{9}$/,
  "cid" => ->(_) { true },
}

def required_fields?(passport)
  REQUIRED_FIELDS.all? { |field| passport.key?(field) }
end

def valid?(passport)
  return false unless required_fields?(passport)
  passport.all? { |field, value| VALIDITY_RULES[field] === value }
end

puts "The count of passports with all required fields is:",
  PASSPORTS.count { |passport| required_fields?(passport) },
  "\n"
puts "The count of validated passports is:",
  PASSPORTS.count { |passport| valid?(passport) }
