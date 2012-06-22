require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Parallel do 
      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          par = Parallel.new(mixer)
          par.append(Blank.new(mixer, 10))
          par
        end
      end
    end
  end
end
