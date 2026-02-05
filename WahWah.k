
#include <klang.h>
using namespace klang::optimised;

param cubed(param x) {
	return x * x * x;
}

param map(param x, float min, float max) {
	return x * (max - min) + min;
}

struct WahWah : Effect {
	// DATA MEMBERS
	LPF lpf;
	Sine lfo;

	// Initialise plugin (called once at startup)
	WahWah() {
		controls = {
			{ "FILTER",
				Dial("F", 0.0, 1.0, 1.0),
				Dial("Q", 0.1, 10.0, 1.0)	 
			},
			{ "LFO",
				Dial("Rate", 0.1, 5.0, 1.0),
				Dial("Depth", 0.0, 0.5, 0.5),	 
			},              
			Dial("Dry / Wet", 0.0, 1.0, 1.0),
		};
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS
		param cutoff = map(cubed(controls[0].smooth()), 20, 20000);
		param q = controls[1];
		param rate = controls[2];
		param depth = controls[3];
		param gain = controls[4];
		
		// SIGNALS
		signal wet = in;
		signal mod = lfo(rate) * depth + (1 - depth);
		mod >> debug; // analyse mod signal
		
		// PROCESSING
		in >> lpf(cutoff * mod, q) >> wet;
		
		in * (1 - gain) + wet * gain >> out;
	}
};