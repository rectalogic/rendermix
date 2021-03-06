require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Sequence do 
      let(:tracks) do
        Array.new(5).fill do
          @mixer.new_blank(duration: 10)
        end
      end

      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          @mixer.new_sequence(@mixer.new_blank(duration: 10))
        end

        let!(:seq) do
          @mixer.new_sequence(tracks)
        end

        it 'should have a single track' do
          seq.tracks.length.should be 1
          seq.tracks.should eq [seq]
        end

        it 'should have the duration of all its children' do
          seq.duration.should eq 5*10
        end


        it 'should render only one child' do
          #XXX add to shared examples - need audio/visual CM and render
        end
      end

      it_should_behave_like 'a container element' do
        let(:mix_element) do
          @mixer.new_sequence(tracks)
        end
      end
    end
  end
end
