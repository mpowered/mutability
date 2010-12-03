require 'activerecord/mutability'

ActiveRecord::Base.send(:include, ActiveRecord::Mutability)

module ActiveRecord
  module Mutability
    VERSION = '0.0.6'
  end
end