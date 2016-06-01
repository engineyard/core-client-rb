Then %(I am advised that this command has been deprecated) do
  expect(output_text).to match(/.*This command is deprecated.*/)
end
