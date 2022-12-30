### Bundle ey-core locally
1. Modify `lib/ey-core/version.rb` to next minor version
2. Run `gem build ey-core.gemspec`
3. Run `gem install ./ey-core-<version>.gem`
4. Run `ey-core` and your latest update would be reflected
5. To cross check ey-core version locally, run `gem list | grep ey-core`, and you would see your version listed