import AVFoundation
import AudioToolbox

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
    
    /// URL to the bundled General MIDI soundfont. Add a .sf2 file (e.g. FluidR3_GM.sf2) to the target and name it "GeneralMIDI.sf2".
    private var soundBankURL: URL? {
        Bundle.main.url(forResource: "GeneralMIDI", withExtension: "sf2")
    }
    
    init() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
            loadInstrument()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    /// Load the current instrument from the bundled GM soundfont. Without a soundfont, the sampler uses a default (often flute-like) and program changes have no effect.
    private func loadInstrument() {
        guard let url = soundBankURL else {
            print("General MIDI soundfont not found. Add a .sf2 file (e.g. FluidR3_GM.sf2) to the project and name it 'GeneralMIDI.sf2' so instrument changes work.")
            return
        }
        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: currentSound.midiProgram,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
        } catch {
            print("Error loading instrument \(currentSound.rawValue): \(error.localizedDescription)")
        }
    }
    
    func changeSound(to sound: SoundType) {
        currentSound = sound
        loadInstrument()
    }
    
    func playNote(_ note: UInt8, velocity: UInt8 = 100) {
        sampler.startNote(note, withVelocity: velocity, onChannel: 0)
    }
    
    func stopNote(_ note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
}
