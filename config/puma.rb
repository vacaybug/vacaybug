rails_env = ENV['RAILS_ENV'] || 'development'

threads 4,4

bind  "unix:///data/apps/vacaybug/shared/tmp/puma/vacaybug-puma.sock"
pidfile "/data/apps/vacaybug/current/tmp/puma/pid"
state_path "/data/apps/vacaybug/current/tmp/puma/state"

activate_control_app
