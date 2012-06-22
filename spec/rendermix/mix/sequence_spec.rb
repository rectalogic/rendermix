require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Sequence do 
      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          seq = Sequence.new(mixer)
          seq.append(Blank.new(mixer, 10))
          seq
        end
      end
    end
  end
end
