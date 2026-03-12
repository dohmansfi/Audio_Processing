
#include <klang.h>

using namespace klang::optimised;

#define N 32

struct Harmonic : Oscillator {
	Sine osc[N];
	Envelope env[N]; // add envelopes
		
	void set(param frequency){
		for(int o = 0; o < N; o++) {
			osc[o].set(frequency * (o + 1));
			// set envelopes
			env[o] = { {0.0,           1.f / N }, 
					   {1.f / (o + 1), 0       } };
		}
	}
	
	void process() {
		out = 0;
		for(int o = 0; o < N; o++) {
			if(osc[o].frequency < fs.nyquist) // band limiting
				out += osc[o] * env[o];
		} 
	}
};

struct Spectral : Synth {

	struct SpectralNote : public Note {
		Harmonic osc;
		ADSR adsr;
		

		event on(Pitch pitch, Amplitude velocity) {
			const param f = pitch -> Frequency;
			osc(f, 0);
			adsr(0.001, 0, 1, 0.25);
		}

		event off(Amplitude velocity) {
			adsr.release();
		}

		void process() {
			osc * adsr * 0.5 >> out;
			if (adsr.finished())
				stop();
			
		}
	};

	// Initialise plugin (called once at startup)
	Spectral() {
		controls = {
			// UI controls and parameters
		};

		notes.add<SpectralNote>(32);
	}
};