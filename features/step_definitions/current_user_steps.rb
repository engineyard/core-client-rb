Then %(I should see my user ID) do
  expect(output_text).to match(/#{Regexp.escape(current_user.id)}/)
end

Then %(I should see my email address) do
  expect(output_text).to match(/#{Regexp.escape(current_user.email)}/)
end

Then %(I should see my name) do
  expect(output_text).to match(/#{Regexp.escape(current_user.name)}/)
end
