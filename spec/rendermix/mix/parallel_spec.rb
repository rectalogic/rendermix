require 'spec_helper'
require 'rendermix/mix/shared_examples_for_mix_elements'

module RenderMix
  module Mix
    describe Parallel do 
      include_context 'requires render thread'
      include_context 'should receive invoke'

      let(:tracks) do
        Array.new(5).fill do
          @app.mixer.new_blank(duration: 10)
        end
      end

      it 'should stop rendering the shortest track' do
        duration = 10
        media = @app.mixer.new_media(FIXTURE_MEDIA, duration: 5)
        par = @app.mixer.new_parallel(@app.mixer.new_blank(duration: duration),
                                      media)
        par.duration.should eq duration
        media.should_receive_invoke(:on_audio_render).exactly(media.duration).times
        media.should_receive_invoke(:on_visual_render).exactly(media.duration).times
        (duration + 1).times do
          on_render_thread do
            @app.audio_context_manager.render(par)
            @app.visual_context_manager.render(par)
          end
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
