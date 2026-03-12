
#include <klang.h>
using namespace klang::optimised;

// map linear to nonlinear (0 to 1)
signal nonlinear(signal x){ 
	return pow(10, 2 * (x - 1)); 
}

// all harmonics at equal strength
struct Harmonic : Oscillator {
	Sine osc[32];
	
	void set(param frequency){
		for(int o = 0; o < 32; o++)
			osc[o].set(frequency * (o + 1));
	}

	void process() {
		out = 0;
		for(int o = 0; o < 32; o++)
			if(osc[o].frequency < fs.nyquist) // band limiting
				out += osc[o] * 0.1;
	}
};

struct Subtractive : Synth {

	struct SubtractiveNote : public Note {
		Saw osc;
		ADSR adsr;
		LPF lpf;
		Envelope env;
		
		event on(Pitch pitch, Amplitude velocity) {
			osc(pitch -> Frequency, 0);
			adsr(0.001, 0, 1, 0.25);
			env = { { 0.00, 1 }, 
					{ 0.25, 0 } };
			 
		}
		
		event off(Amplitude velocity) {
			adsr.release();
		}
		
		void process() {
			signal mod = nonlinear(env) * (10000 - 100) + 100; // filter mod signal
		
			osc * adsr >> lpf(mod) >> out;
		
			if (adsr.finished())
				stop();
		}
	};

	// Initialise plugin (called once at startup)
	Subtractive() {
		controls = {
			// UI controls and parameters
		};

		notes.add<SubtractiveNote>(32);
	}
};