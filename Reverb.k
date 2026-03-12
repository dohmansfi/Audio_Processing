
#include <klang.h>
using namespace klang::optimised;

struct Reverb : Effect {

	// DATA MEMBERS
	Delay<192000> feedforward, feedback;
	LPF filter;

	param times[8] = { 2.078,  5.154,  5.947,  7.544,
		               8.878,  10.422, 13.938, 17.140 }; // in ms!
	param gains[8] = { .609,   .262,   -.3600, -.470, 
		               .290,   -.423,  .100,   .200 };
	
	// Initialise plugin (called once at startup)
	Reverb() {
		controls = {
			{ "Feedback", 
				Dial("Time", 0, 0.5, 0.4),
		        Dial("Gain", 0, 0.4, 0.1),
		        Dial("Cutoff", 500, 5000, 1500) 
			},
		};
		presets = { { "Bathroom",    { 0.276, 0.057, 3835.062 } },
	            	{ "Lively Room", { 0.309, 0.060,  806.557 } },
	            	{ "Air Vent",    { 0.496, 0.089, 2807.678 } },
	            	{ "Parking Lot", { 0.216, 0.220, 1367.304 } },
		};
	}

	// (called once per buffer)
	void prepare() {
		filter.set(controls[2]);
	}

	signal early() {
		signal mix = in;
		
		// feed input to delay
		in >> feedforward;
		
		// add early reflections
		for(int t = 0; t < 8; ++t)     // ms conversion
			mix += feedforward(times[t] * fs * 0.001) * gains[t];
		
		return mix;
	}

	signal late() {
		param times[3] = { 0.2, 0.324, 0.777 };
		param gains[3] = { 1.0, 0.6, 0.2 };
		signal mix = 0;
		// add multiple taps from the feedback delay
		for(int t = 0; t < 3; ++t)
			mix += feedback(controls[0] * times[t] * fs * 0.001) * controls[1] * gains[t];
		return mix >> filter;
	}

	// Apply processing (called once per sample)
	void process() {
		early() + late() >> out >> feedback;
	}
};