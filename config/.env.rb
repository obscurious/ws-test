ENV['RACK_ENV'] ||= 'development'

ENV['DATABASE_URL'] ||= case ENV['RACK_ENV']
when 'test'
  "postgres:///wassal_test?user=wassal"
when 'production'
  "postgres:///wassal_production?user=wassal"
else
  "postgres:///wassal_development?user=wassal"
end
