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

## `ios_buffer_sizes.patch`

There's an issue with JUCE 7.0.9 and certain iOS versions where, in a standalone build, only a single buffer size is available to the user. This patch updates `juce_Audio_ios.cpp` in its totality to the one found in a later version of JUCE (I forgot which one), where this issue is fixed.

## `ableton_live_editor_reopen.patch`

See https://forum.juce.com/t/blank-white-screen-after-plugin-was-closed-and-opened-again/59281/20

The fix is taken from a later JUCE (I think JUCE 8, but not sure) AUv3 wrapper.

## `auv2_aumu_default_bus_layout_in_order_to_support_mixed_mono_and_stereo_outputs.patch`

Use default (non-explicit) AUv2 bus layout if the AUv2 is an aumu (music device).

This allows VMPC2000XL to be used in Logic with:
1. 1x stereo in, 1x stereo out.
2. 1x stereo in, 5x stereo out, 8x mono out.

Also see https://github.com/juce-framework/JUCE/issues/1508
