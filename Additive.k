
#include <klang.h>
using namespace klang::optimised;
	
#define N 16 // number of harmonics

// Sawtooth wave harmonics
struct Harmonic : Oscillator {
	Sine osc[N];
	
	void set(param f) {
		for(int h = 0; h < N; h++) {
			osc[h].set(f * (h + 1));
		}
	}
	
	void process() {
		signal mix = 0;
		for(int o = 0; o < N; o++) {
			if(osc[o].frequency < fs.nyquist) // band limiting
				mix += osc[o] * 1 / (o + 1);
		}
		mix >> out;
	}
};

static bool isOdd(int x) {
	return (x % 2) == 1;
}

// Square wave harmonics
struct OddHarmonic : Harmonic {
	void process() {
		signal mix = 0;
		for(int o = 0; o < N; o++) {
			if(isOdd(o + 1) && osc[o].frequency < fs.nyquist)
				mix += osc[o] * 1 / (o + 1);
		}
		mix >> out;
	}
	
};

// Measurements from Korg M1 Organ sample (at C2):
// ====================================================
//    65Hz,   131Hz,   196Hz,   263Hz,   327Hz,   393Hz
// -14.5dB, -14.2dB, -14.3dB, -50.0dB, -47.2dB, -24.5dB

#define N2 6 // number of harmonics
	
const float FREQ[N2] = { 65/65.f, 131/65.f, 195/65.f, 263/65.f, 327/65.f, 393/65.f }; // (normalised to f0)
const dB GAIN[N2] = 	{ -14.5+12, -14.2+12, -14.3+12, -50.0+12, -47.2+12, -24.5+12 }; // (in dB)

struct KorgOrgan : Oscillator {
	Sine osc[6];
	
	void set(param f) {
		for(int h = 0; h < N2; h++) {
			osc[h].set(f * FREQ[h]);
		}
	}
	
	void process() {
		signal mix = 0;
		for(int o = 0; o < N2; o++) {
			if(osc[o].frequency < fs.nyquist)
				mix += osc[o] * (GAIN[o] -> Amplitude);
		}
		mix >> out;
	}
};

struct Additive : Synth {

	struct AdditiveNote : public Note {
		
		// DATA MEMBERS
		Harmonic saw;
		OddHarmonic square;
		KorgOrgan korg;
		ADSR adsr;
		param gain;

		event on(Pitch pitch, Amplitude velocity) {
			const param f = pitch -> Frequency;
			saw(f, 0);
			square(f, 0);
			korg(f, 0);
			adsr(0.001, 0, 1, 0.25);
			gain = velocity * velocity * velocity;
		}

		event off(Amplitude velocity) {
			adsr.release();
		}

		// Apply processing (called once per sample)
		void process() {
			switch((int)controls[0]) {
				case 0:
					saw * gain * adsr >> out;
					break;
				case 1:
					square * gain * adsr >> out;
					break;
				case 2:
					korg * gain * adsr >> out;
					break;
				default:
					break;
			}
			
			if (adsr.finished())
				stop();  
		}
	};

	// Initialise plugin (called once at startup)
	Additive() {
		controls = {
			// UI controls and parameters
			{ "OSC",
				Menu("", {25, 50, 80, 20}, "Saw", "Square", "KORG M1")
			},
		};

		notes.add<AdditiveNote>(32);
	}
};