require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Blank do 
      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          Blank.new(mixer, 10)
        end
      end
    end
  end
end
