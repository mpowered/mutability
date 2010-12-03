module ActiveRecord
  module Mutability
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def make_immutable_when(&block)
        define_method(:_immutable?) do
          block.call(self)
        end
        include InstanceMethods
      end
    end

    module InstanceMethods
      # Prevent objects from being updated
      def readonly?
        _immutable?
      end

      # Prevent objects from being destroyed
      def destroy
        if _immutable?
          raise ActiveRecord::ReadOnlyRecord 
        else
          super
        end
      end
    end
  end
end