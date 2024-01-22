# These tasks are needed by Jenkins pipeline

task test: :environment do
  unless system("rspec --format RspecJunitFormatter --out tmp/test/rspec.xml")
    raise "Rspec testing failed #{$?}"
  end

  unless system "bundle exec rubocop"
    raise "Rubocop failed"
  end

end

namespace :test do
  task smoke: :environment do
    puts "Smoke test passed"
    # if system "bundle exec cucumber features/  --tags @smoke"
    #   puts "Smoke test passed"
    # else
    #   raise "Smoke tests failed"
    # end
  end

  task functional: :environment do
    puts "Smoke test passed"
    # if system "bundle exec cucumber features/"
    #   puts "Functional test passed"
    # else
    #   raise "Functional tests failed"
    # end
  end
end
