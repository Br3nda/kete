require 'spec_helper'

describe AudioRecording do
  let(:audio_recording) { AudioRecording.new }

  it "does not blow up when you initialize it" do
    audio_recording
  end

  it "can be validated" do
    expect( FactoryGirl.build(:validatable_audio_recording) ).to be_valid

    # ROB:  Not saveble because of basket (see note in factory).
    expect { FactoryGirl.create(:validateable_audio_recording) }.to raise_error
  end 

  it "can be saved to the database with minimal data filled in" do
    expect( FactoryGirl.create(:savable_audio_recording) ).to be_a(AudioRecording)
  end
end 
