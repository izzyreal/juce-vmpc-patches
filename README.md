# juce-vmpc-patches

Some patches for JUCE that are used for https://github.com/izzyreal/vmpc-juce.

I've applied them to my fork of JUCE 7.0.9 here: https://github.com/izzyreal/JUCE/tree/7.0.9-vmpc.

## `auv2_auv3_inst_and_effect.patch`

To publish VMPC2000XL AUv2 and AUv3 as instrument as well as effect. JUCE allows only one AU subtype, but we need two.
Some properties are hardcoded to make the code cleaner.

## `auv2_auv3_expose_component_type.patch`

A `std::string auComponentType` property is added to `juce::AudioProcessor`, which is immediately set in the AUv2 and AUv3 constructors to the component type, like `aumu`, `aumf`, etc.
We do this, because in VMPC2000XL, in the About screen we want to include whether the user is running the AudioUnit as an instrument or as an effect.

## `ios_audio.patch`

Three fixes for iOS in a single patch:

1. By removing `AVAudioSessionCategoryOptionAllowBluetooth` we only disable bluetooth input, which is desirable, because the audio output stream of a bidirectional bluetooth stream is 16KHz sample rate. By not passing `AVAudioSessionCategoryOptionAllowBluetooth`, we get good sample rates with bluetooth devices.

2. The `AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption` patch is related to a privacy feature introduced in iOS 14.5, where the microphone is muted when closing the iPad's Smart Folio (magnetic) cover. If we don't pass `AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption`, the audio stream will be interrupted when closing the cover. In JUCE 7.0.9 this is not handled correctly, and the stream is bidirectionally interrupted, and it never recovers during the lifetime of the app. An app restart is needed to get `processBlock` calls again.

3. The way available buffer sizes are derived, and the way the buffer size for an active session is set to a different value have changed in iOS 18. JUCE 8 addresses this. See `tryBufferSize`, `updateAvailableBufferSizes` and `class SubstituteAudioUnit`.

## `ableton_live_editor_reopen.patch`

See https://forum.juce.com/t/blank-white-screen-after-plugin-was-closed-and-opened-again/59281/20

The fix is taken from a later JUCE (I think JUCE 8, but not sure) AUv3 wrapper.

## `auv2_aumu_default_bus_layout_in_order_to_support_mixed_mono_and_stereo_outputs.patch`

Use default (non-explicit) AUv2 bus layout if the AUv2 is an aumu (music device).

This allows VMPC2000XL to be used in Logic with:
1. 1x stereo in, 1x stereo out.
2. 1x stereo in, 5x stereo out, 8x mono out.

Also see https://github.com/juce-framework/JUCE/issues/1508

## `macos_do_not_use_CGWindowListCreateImage.patch`

`CGWindowListCreateImage` doesn't build against the macOS 15 SDK. This function is used in JUCE 7 for creating screenshots, which is something we don't need in VMPC2000XL. This patch eliminates usage of `CGWindowListCreateImage` by returning an empty `juce::Image`.

See https://github.com/izzyreal/vmpc-juce/issues/125
