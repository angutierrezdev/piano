# Piano

A small iOS piano application with 2 octaves that can be played with touch controls.

## Features

- **2 Octaves**: 24 keys from C4 to B5 (middle C and above)
- **Real-time Playback**: Notes play when pressed and stop when released
- **4 Instruments**: Switch between Piano, Flute, Accordion, and Organ
- **MIDI-based Audio**: Uses AVFoundation's AVAudioUnitSampler for authentic instrument sounds
- **Touch-optimized**: Designed for iOS with landscape orientation

## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- iPhone or iPad

## Building and Running

1. Open `Piano.xcodeproj` in Xcode
2. Select your target device (iPhone or iPad simulator)
3. Press ⌘R to build and run

## How to Use

1. Launch the app (automatically opens in landscape mode)
2. Select your desired instrument using the segmented control at the top (Piano, Flute, Accordion, or Organ)
3. Tap and hold piano keys to play notes
4. Release keys to stop the notes
5. White keys represent natural notes (C, D, E, F, G, A, B)
6. Black keys represent sharps/flats (C#, D#, F#, G#, A#)

## Architecture

- **PianoApp.swift**: Main app entry point
- **ContentView.swift**: SwiftUI view with piano keyboard UI and instrument selector
- **AudioEngine.swift**: Audio playback engine using AVAudioUnitSampler for MIDI synthesis

## Technical Details

- Uses `AVAudioEngine` and `AVAudioUnitSampler` from AVFoundation
- MIDI note numbers 60-83 (C4 to B5)
- General MIDI program numbers for instrument selection:
  - Piano: 0 (Acoustic Grand Piano)
  - Flute: 73
  - Accordion: 21
  - Organ: 19 (Church Organ)
