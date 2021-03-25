import Foundation
import AudioKit

public class MyEngine {
    
    public static let shared = MyEngine()
    
    public typealias Lock = Int
    private let polyphony = 16

    private let oscs: [Oscillator]
    private let envelopes: [AmplitudeEnvelope]
    private let mixer: Mixer
    private var locks: [Bool]
    private let engine = AudioEngine()

    
    private init() {
        
        let amplitudes: [Float] = [0.9] //  [0.9, 0.3, 0.5, 0.01, 0.02]
        let table = Table(.harmonic(amplitudes))
        
        oscs = (0..<polyphony).map { _ in Oscillator(waveform: table) }
        envelopes = oscs.map { oscillator in
            let envelope = AmplitudeEnvelope(oscillator)
            envelope.attackDuration = 0.01
            envelope.decayDuration = 0.0
            envelope.sustainLevel = 1.0
            envelope.releaseDuration = 0.05
            return envelope
        }
        locks = (0..<polyphony).map { _ in false }
        
        mixer = Mixer(envelopes)
        mixer.start()
        engine.output = mixer
        try! engine.start()
    }
    
    public func play(frequency: Float) -> Lock {
        var i = 0
        while i < polyphony && locks[i] == true {
            i += 1
        }

        if i == polyphony {
            return -1
        }

        locks[i] = true
        let osc = oscs[i]
        osc.frequency = frequency

        let envelope = envelopes[i]
        
        
        if osc.isStopped {
            osc.start()
        }
        
        envelope.start()
        
        osc.play()
        
        return i
    }

    public func stop(lock: Lock) {
        let envelope = envelopes[lock]
        let osc = oscs[lock]

        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(envelope.releaseDuration) * 2.0)) {

            osc.stop()
            osc.reset()
            self.locks[lock] = false
        }
        envelope.stop()

    }
}

public class MyEngineDemo {

    public static let shared = MyEngineDemo()
    private init() {}

    private var lastLocks: [Int] = []

    public func playDemo() {
        let engine = MyEngine.shared
        lastLocks.append(engine.play(frequency: 440))
        lastLocks.append(engine.play(frequency: 548.5))
    }
    
    public func stopDemo() {
        let engine = MyEngine.shared
        for lock in lastLocks {
            engine.stop(lock: lock)
        }
    }
    
    public func toggleEndlessly() {
        playDemo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.stopDemo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.toggleEndlessly()
            }
        }
    }
}
