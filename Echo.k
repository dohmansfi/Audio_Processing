
#include <klang.h>
using namespace klang::optimised;

struct Echo : Effect {

	// DATA MEMBERS	
	Delay<192000> delay;
	int BPM = 120;

	// Initialise plugin (called once at startup)
	Echo() {
		controls = {
			{ "ECHO",
				Dial("Time", 0.0, 1.0, 0.0),
				Dial("Feedback", 0.0, 0.99, 0.1),
			},                          	   // X -- Y -- width - height
			Dial("Output Gain", 0.0, 1.0, 1.00, { 320, 50,  60,     60 }),
		};
		debug.print("Sample Rate: %f", fs.f);
	}
	
	// Prepare for processing (called once per buffer)
	void prepare() {
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS 
		param time = controls[0].smooth();
		param feedback = controls[1];
		param gain = controls[2];
			
		in >> debug; // analyse dry signal
		
		// PROCESSING
		in + delay(time * fs) * feedback >> out;
		delay << out;
		
		out *= gain; // apply output gain
	}
};