
#include <klang.h>
using namespace klang::optimised;

struct EQ3 : Effect {
	// DATA MEMBERS
	LPF lpf;
	HPF hpf;

	// Initialise plugin (called once at startup)
	EQ3() {
		controls = {
			{ "EQ",	
				Dial("Lows", 0.25, 1.75, 1.0),
				Dial("Mids", 0.25, 1.75, 1.0),
				Dial("Highs", 0.25, 1.75, 1.0)		 
			},                          	  // X -- Y -- width - height
			Dial("Output Gain", 0.0, 1.0, 1.0, { 320, 50,  60,     60 }),
		};
	}
	
	// Prepare for processing (called once per buffer)
	void prepare() {
		lpf.set(200);
		hpf.set(4000);
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS
		param gain = controls[3];
		
		in >> debug; // analyse dry signal
		
		// SIGNALS
		signal lows = in >> lpf;
		signal highs = in >> hpf;
		signal mids = in - (lows + highs);
		
		// PROCESSING
		lows * sqr(controls[0]) + mids * sqr(controls[1]) + highs * sqr(controls[2])>> out;	
		out *= gain; // apply output gain
	}
};

