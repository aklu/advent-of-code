require "spec_helper"

RSpec.describe "Day 13: Challenge Title" do
  let(:runner) { Runner.new("2022/13") }
  let(:input) do
    <<~TXT
    TXT
  end

  describe "Part One" do
    let(:solution) { runner.execute!(input, part: 1) }
  end

  describe "Part Two" do
    let(:solution) { runner.execute!(input, part: 2) }
  end
end
