class Services::FormatGlossaryItems < ApplicationOperation
  def call
    current_buffer = ""
    output = ""
    File.readlines(file_path).each do |line|
      line = "#{line.chomp} "
      next if line.blank?

      if header?(line)
        output << current_buffer
        current_buffer = ""
        line = "\n\n#{line}\n\n"
      end

      if new_paragraph?(line)
        line = "\n#{line}"
      end

      current_buffer << line
    end
    output << current_buffer

    File.write(output_path, output)

    true
  end

  def initialize(file_path: "db/seeds/data/glossary_test.md", output_path: "db/seeds/data/glossary_output.md")
    @file_path = file_path
    @output_path = output_path
  end

  private

  attr_reader :file_path
  attr_reader :output_path

  def header?(line)
    line.start_with?("#")
  end

  def new_paragraph?(line)
    line.start_with?("**")
  end
end
