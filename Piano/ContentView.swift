import SwiftUI

struct ContentView: View {
    @StateObject private var audioEngine = AudioEngine()
    
    // MIDI note numbers for 2 octaves starting from C4 (middle C)
    let notes: [(name: String, midiNote: UInt8, isBlack: Bool)] = [
        ("C", 60, false), ("C#", 61, true), ("D", 62, false), ("D#", 63, true),
        ("E", 64, false), ("F", 65, false), ("F#", 66, true), ("G", 67, false),
        ("G#", 68, true), ("A", 69, false), ("A#", 70, true), ("B", 71, false),
        ("C", 72, false), ("C#", 73, true), ("D", 74, false), ("D#", 75, true),
        ("E", 76, false), ("F", 77, false), ("F#", 78, true), ("G", 79, false),
        ("G#", 80, true), ("A", 81, false), ("A#", 82, true), ("B", 83, false)
    ]
    
    var body: some View {
        VStack {
            // Instrument selector
            Picker("Instrument", selection: $audioEngine.currentSound) {
                ForEach(SoundType.allCases, id: \.self) { sound in
                    Text(sound.rawValue).tag(sound)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: audioEngine.currentSound) { newValue in
                audioEngine.changeSound(to: newValue)
            }
            
            Spacer()
            
            // Piano keyboard
            GeometryReader { geometry in
                let whiteKeyCount = notes.filter { !$0.isBlack }.count
                let keyWidth = geometry.size.width / CGFloat(whiteKeyCount)
                
                ZStack(alignment: .topLeading) {
                    // White keys
                    HStack(spacing: 0) {
                        ForEach(notes.filter { !$0.isBlack }, id: \.midiNote) { note in
                            PianoKey(
                                note: note.midiNote,
                                isBlack: false,
                                audioEngine: audioEngine
                            )
                            .frame(width: keyWidth)
                        }
                    }
                    
                    // Black keys
                    HStack(spacing: 0) {
                        ForEach(0..<notes.count, id: \.self) { index in
                            let note = notes[index]
                            if note.isBlack {
                                let whiteKeysBeforeCount = notes[0..<index].filter { !$0.isBlack }.count
                                let blackKeyWidth = keyWidth * 0.6
                                // Position black key centered at the right edge of the preceding white key
                                // The right edge is at whiteKeysBeforeCount * keyWidth
                                // Center the black key there by shifting left by half its width
                                let offset = CGFloat(whiteKeysBeforeCount) * keyWidth - (blackKeyWidth / 2)
                                
                                PianoKey(
                                    note: note.midiNote,
                                    isBlack: true,
                                    audioEngine: audioEngine
                                )
                                .frame(width: blackKeyWidth, height: geometry.size.height * 0.6)
                                .offset(x: offset)
                            }
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding()
        }
    }
}

struct PianoKey: View {
    let note: UInt8
    let isBlack: Bool
    let audioEngine: AudioEngine
    
    @State private var isPressed = false
    
    var body: some View {
        Rectangle()
            .fill(isBlack ? Color.black : Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.gray, lineWidth: 1)
            )
            .overlay(
                isPressed ? Color.gray.opacity(0.3) : Color.clear
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            audioEngine.playNote(note)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        audioEngine.stopNote(note)
                    }
            )
    }
}

#Preview {
    ContentView()
}
