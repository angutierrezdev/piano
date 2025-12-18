import AVFoundation

enum SoundType: String, CaseIterable {
    case piano = "Piano"
    case flute = "Flute"
    case accordion = "Accordion"
    case organ = "Organ"
    
    var midiProgram: UInt8 {
        switch self {
        case .piano: return 0      // Acoustic Grand Piano
        case .flute: return 73     // Flute
        case .accordion: return 21 // Accordion
        case .organ: return 19     // Church Organ
        }
    }
}

class AudioEngine: ObservableObject {
    private var engine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    @Published var currentSound: SoundType = .piano
    
    init() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
            loadSoundFont()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    private func loadSoundFont() {
        do {
            // Load the default General MIDI sound bank
            if let soundFontURL = Bundle.main.url(forResource: "GeneralUser GS", withExtension: "sf2") {
                try sampler.loadSoundBankInstrument(at: soundFontURL,
                                                   program: currentSound.midiProgram,
                                                   bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                   bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            } else {
                // Use Apple's built-in instruments
                try sampler.loadInstrument(at: currentSound.midiProgram)
            }
        } catch {
            print("Error loading sound font: \(error.localizedDescription)")
        }
    }
    
    func changeSound(to sound: SoundType) {
        currentSound = sound
        loadSoundFont()
    }
    
    func playNote(_ note: UInt8, velocity: UInt8 = 100) {
        sampler.startNote(note, withVelocity: velocity, onChannel: 0)
    }
    
    func stopNote(_ note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
}

extension AVAudioUnitSampler {
    func loadInstrument(at program: UInt8) throws {
        // Use Apple's built-in General MIDI instruments
        // For iOS, we use the built-in sampler instruments
        let bankMSB = UInt8(kAUSampler_DefaultMelodicBankMSB)
        let bankLSB = UInt8(kAUSampler_DefaultBankLSB)
        
        // Program change to select the instrument
        sampler.sendProgramChange(program, onChannel: 0)
        
        // Note: On iOS, the built-in sampler automatically uses the system's General MIDI soundbank
        // No need to explicitly load a soundbank file
    }
}
