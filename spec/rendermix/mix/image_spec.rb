require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Image do 
      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          Image.new(mixer, File.join(FIXTURES, '640x480.png'), 10)
        end
      end
    end
  end
end