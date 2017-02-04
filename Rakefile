# Migrate

MIGRATE_DIR = 'migrate'

migrate = lambda do |env, version|
  ENV['RACK_ENV'] = env
  require_relative 'db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout)
  Sequel::Migrator.apply(DB, MIGRATE_DIR, version)
end

desc "Migrate test database to latest version"
task :test_up do
  migrate.call('test', nil)
end

desc "Migrate test database all the way down"
task :test_down do
  migrate.call('test', 0)
end

desc "Migrate test database all the way down and then back up"
task :test_bounce do
  migrate.call('test', 0)
  Sequel::Migrator.apply(DB, 'migrate')
end

desc "Migrate development database to latest version"
task :dev_up do
  migrate.call('development', nil)
end

desc "Migrate development database to all the way down"
task :dev_down do
  migrate.call('development', 0)
end

desc "Migrate development database all the way down and then back up"
task :dev_bounce do
  migrate.call('development', 0)
  Sequel::Migrator.apply(DB, 'migrate')
end

desc "Migrate production database to latest version"
task :prod_up do
  migrate.call('production', nil)
end

desc "Create migration file"
task :migration, [:name] do |t, args|
  create_migration(args[:name])
end

# Shell

irb = proc do |env|
  ENV['RACK_ENV'] = env
  trap('INT', "IGNORE")
  dir, base = File.split(FileUtils::RUBY)
  cmd = if base.sub!(/\Aruby/, 'irb')
    File.join(dir, base)
  else
    "#{FileUtils::RUBY} -S irb"
  end
  sh "#{cmd} -r ./models"
end

desc "Open irb shell in test mode"
task :test_irb do
  irb.call('test')
end

desc "Open irb shell in development mode"
task :dev_irb do
  irb.call('development')
end

desc "Open irb shell in production mode"
task :prod_irb do
  irb.call('production')
end

# Specs

spec = proc do |pattern|
  sh "#{FileUtils::RUBY} -e 'ARGV.each{|f| require f}' #{pattern}"
end

desc "Run all specs"
task :default => [:model_spec, :web_spec]

desc "Run model specs"
task :model_spec do
  spec.call('./spec/model/*_spec.rb')
end

desc "Run web specs"
task :web_spec do
  spec.call('./spec/web/*_spec.rb')
end

# Helper

def create_migration(name)
  unless name
    puts "Name a migration: rake create_migration[add_foo_to_bars]"
    return
  end
  timestamp = Time.now.utc.to_s.scan(/\d/).join
  file_name = "#{timestamp}_#{name}.rb"
  File.open([MIGRATE_DIR, file_name].join('/'), 'w') do |f|
    f.write <<~FILE
      #
      # Migration #{name}
      #

      Sequel.migration do
        up do
        end

        down do
        end
      end
    FILE
  end
  puts "Created #{file_name}."
end
