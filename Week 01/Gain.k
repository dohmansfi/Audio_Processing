
#include <klang.h>
using namespace klang::optimised;

struct Gain : Effect {

	// Initialise plugin (called once at startup)
	Gain() {
		controls = {
			Dial("Gain", 0.0, 15.0, 0.5),
		};
	}

	// Apply processing (called once per sample)
	void process() {
		param gain = controls[0];
		
		signal mix = in * gain;
		
		if (mix > 1)
			mix = 1;
		else if (mix < -1)
			mix = -1;
		mix >> out;
	}
};