
#include <klang.h>
using namespace klang::optimised;

struct OnePoleLPF : Effect {
	signal last = 0;
	param cutoff = 0;
	
	void set(param c) {
		cutoff = c * c * c;
	}
	
	void process() {
		in * cutoff + last * (1 - cutoff) >> out;
		last = out;
	}
};

signal clip(signal x) {
	if(x > 1)
		x = 1;
	else if(x < -1)
		x = -1;
		
	return x;
}

struct IIR : Effect {
	OnePoleLPF p1, p2, p3, p4;
	signal fb = 0; // feedback memory (previous output)

	// Initialise plugin (called once at startup)
	IIR() {
		controls = {
			Dial("Cutoff", 0.0, 1.0, 1.0),
			Dial("Resonance", 0.0, 1.0, 0.0),
		};
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS
		param cutoff = controls[0].smooth();
		param res = controls[1].smooth();
		
		// SETTERS
		p1.set(cutoff);
		p2.set(cutoff);
		p3.set(cutoff);
		p4.set(cutoff);

		// map resonance to a usable feedback gain
        param k = (res * res) * 5.0; // (square gives finer control at low resonance)
		
		// PROCESS
		(in - clip(fb) * k) >> p1 >> p2 >> p3 >> p4 >> out;
		
		// update feedback state (1-sample delay in the loop)
        fb = out;
	}
};