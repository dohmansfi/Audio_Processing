#include <klang.h>
using namespace klang::optimised;

struct Patterns : Effect {
	Delay<192000> delay;

	Patterns() {
		controls = { 
			{ "Delay 1", 
				Dial("Time"), 
				Dial("Gain") 
			},
			{ "Delay 2", 
				Dial("Time"),
				Dial("Gain") 
			},
			Dial("Feedback", 0, 0.99, 0, {245, 165, 60, 60}),
			{ "Delay 3", 
				Dial("Time"), 
				Dial("Gain") 
			},
		};
	}

	void process() {
		
		param time[] = { controls[0],controls[2],controls[5] };
		param gain[] = { controls[1],controls[3],controls[6] };
		param feedback = controls[4];
		
		signal taps = 0;
		
		// add the 3 echos to taps
		for(int t = 0; t < 3; ++t) {
			taps += delay(time[t] * fs) * gain[t];
		} 
		
		// output
		in + taps >> out;
		
		// feedbcack
		delay << in + taps * feedback;
		
	}
};