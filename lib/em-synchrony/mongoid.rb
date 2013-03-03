if Mongoid::VERSION.split('.').map(&:to_i)[0] >= 3
  # Mongoid v3+
  require "em-synchrony/moped"

else
  # Mongoid v1-2
  require "em-synchrony/mongo"
  # disable mongoid connection initializer
  if defined? Rails
    module Rails
      module Mongoid
        class Railtie < Rails::Railtie
          initializers.delete_if { |i| i.name == 'verify that mongoid is configured' }
        end
      end
    end
  end
end
