# juce-vmpc-patches

Some patches for JUCE that are used for https://github.com/izzyreal/vmpc-juce.

I've applied them to my fork of JUCE 7.0.9 here: https://github.com/izzyreal/JUCE/tree/patched-for-ios-7.0.9

## `auv3_inst_and_effect.patch` / `auv2_inst_and_effect.patch`

To publish VMPC2000XL AUv2 and AUv3 as instrument as well as effect. JUCE allows only one AU subtype, but we need two.

**This patch is particularly dirty. With some effort the code could be made nice and organized, the subtypes parameterized, etc.**

## `ios_bluetooth_sample_rate_and_keep_playing_when_closing_smart_folio.patch`

Two fixes for iOS in a single patch:

1. By commenting out `AVAudioSessionCategoryOptionAllowBluetooth` we only disable bluetooth input, which is desirable, because the audio output stream of a bidirectional bluetooth stream is 16KHz sample rate. By not passing `AVAudioSessionCategoryOptionAllowBluetooth`, we get good sample rates with bluetooth devices.

2. The `AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption` patch is related to a privacy feature introduced in iOS 14.5, where the microphone is muted when closing the iPad's Smart Folio (magnetic) cover. If we don't pass `AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption`, the audio stream will be interrupted when closing the cover. In JUCE this is not handled correctly, and the stream is bidirectionally interrupted, and it never recovers during the lifetime of the app. An app restart is needed to get `processBlock` calls again.

## `ableton_live_editor_reopen.patch`

See https://forum.juce.com/t/blank-white-screen-after-plugin-was-closed-and-opened-again/59281/20

The fix is taken from a later JUCE (I think JUCE 8, but not sure) AUv3 wrapper.
