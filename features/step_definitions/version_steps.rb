Then %(I see the current ey-core version) do
  expect(output_text).to include(Ey::Core::VERSION)
end
