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

        let(:tracks) do
          Array.new(5).fill do
            Blank.new(mixer, 10)
          end
        end
        let!(:seq) do
          seq = Sequence.new(mixer)
          tracks.each do |track|
            seq.append(track)
          end
          seq
        end

        it 'should have a single track' do
          seq.tracks.length.should be 1
          seq.tracks.should eq [seq]
        end

        it 'should have the duration of all its children' do
          seq.duration.should eq 5*10
        end
      end
    end
  end
end
