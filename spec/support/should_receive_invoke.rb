shared_context 'should receive invoke' do
  module RSpec
    module Mocks
      module Methods
        def should_receive_invoke(message, opts={})
          original_method = self.method(message.to_sym)
          should_receive(message, opts) do |*args|
            original_method.call(*args)
          end
        end
      end
    end
  end
end
