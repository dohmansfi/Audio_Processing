
#include <klang.h>
using namespace klang::optimised;

struct Gain : Effect {

	// Initialise plugin (called once at startup)
	Gain() {
		controls = { 
			Dial("Gain", 0, 1, 0) 
		};
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS
		param gain = controls[0];
		
		// PROCESSING
		in * gain >> out;
	}
};