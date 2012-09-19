require 'spec_helper'

shared_examples 'a context manager' do |render_av_method, has_initial_context|
  include_context 'requires render thread'
  include_context 'should receive invoke'

  let(:mix_element) { double('mix element') }

  it 'should raise on double render' do
    on_render_thread do
      mix_element.should_receive(render_av_method) do |mgr|
        mgr.context = context
        expect { mgr.context = double('NewContext') }.to raise_error(RenderMix::InvalidMixError)
      end.with(manager).once
      manager.render(mix_element)
    end
  end

  it 'should have a context if rendered' do
    on_render_thread do
      mix_element.should_receive(render_av_method) do |mgr|
        mgr.context = context
      end.with(manager).once
      manager.render(mix_element)
      manager.context.should be context
    end
  end
end

module RenderMix
  describe AudioContextManager do
    it_should_behave_like 'a context manager', :audio_render, false do
      let(:manager) { AudioContextManager.new }
      let(:context) { double('AudioContext') }
    end
  end

  describe VisualContextManager do
    it_should_behave_like 'a context manager', :visual_render, false do
      let(:manager) { VisualContextManager.new }
      let(:context) { double('VisualContext') }
    end
  end
end
