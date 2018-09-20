Then %(I see the docker login command) do
  expect(output_text).to match("docker login -u foo -p bar https://012345678901.dkr.ecr.us-east-1.amazonaws.com")
end
