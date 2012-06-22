require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Media do 
      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          Media.new(mixer, File.join(FIXTURES, '320x240-30fps.mov'))
        end
      end
    end
  end
end
