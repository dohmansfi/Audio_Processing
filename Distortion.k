
#include <klang.h>
using namespace klang::optimised;

// hard clipping
signal clip(signal x) {
	if(x > 1)
		x = 1;
	else if(x < -1)
		x = -1;
		
	return x;
}

// soft clipping
float softclip(float x, float c) {
	return tanh(x * c) / tanh(c);
}

Function shape(softclip); // wrap softclip in a function object

// smooth tube-like saturation
signal sine_shaped(signal x) {
 	return sin(0.5 * M_PI * x);
}

struct Distortion : Effect {

	// Initialise plugin (called once at startup)
	Distortion() {
		controls = {
			{ "CLIPPING",	
				Dial("Overdrive", 1, 11, 1),
				Dial("Shape", 0.001, 9, 0.001),
				Menu("Function", { 170, 50, 100, 20 }, "Hard Clip", "Soft Clip", "Sine-Shaped")				 
			},                          // X -- Y -- width - height
			Dial("Output Gain", 0, 1, 1, { 320, 50,  60,     60 }),
		};
	}
	
	// Prepare for processing (called once per buffer)
	void prepare() {
		graph.clear();
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS
		param overdrive = controls[0];
		param c = controls[1];
		int function = controls[2];
		param gain = controls[3];
		
		in >> debug; // analyse dry signal
		
		// PROCESSING
		if(function == 0) { 
			clip(in * overdrive) >> out;
			clip >> graph(-2, 2, -2, 2);
		}
		else if(function == 1) {
			in >> shape(c) >> out;
			shape >> graph(-2, 2, -2, 2);
		}
		else if(function == 2) {
			sine_shaped(in * overdrive) >> out;
			sine_shaped >> graph(-2, 2, -2, 2);
		}
			
		out = out * gain; // apply output gain	 
	}
};