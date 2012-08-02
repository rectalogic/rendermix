require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Parallel do 
      let(:tracks) do
        Array.new(5).fill do
          @app.mixer.new_blank(duration: 10)
        end
      end

      it_should_behave_like 'a mix element' do
        let!(:mix_element) do
          @app.mixer.new_parallel(@app.mixer.new_blank(duration: 10))
        end

        let!(:par) do
          @app.mixer.new_parallel(tracks)
        end

        it 'should have a track for each child' do
          par.tracks.length.should be 5
          par.tracks.should eq tracks
        end

        it 'should have the duration of the max of its children' do
          par.duration.should eq 10
        end
      end

      it_should_behave_like 'a container element' do
        let(:mix_element) do
          @app.mixer.new_parallel(tracks)
        end
      end
    end
  end
end
