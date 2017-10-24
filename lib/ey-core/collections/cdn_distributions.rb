class Ey::Core::Client::CdnDistributions < Ey::Core::Collection

  model Ey::Core::Client::CdnDistribution

  self.model_root         = "cdn_distribution"
  self.model_request      = :get_cdn_distribution
  self.collection_root    = "cdn_distributions"
  self.collection_request = :get_cdn_distributions
end
