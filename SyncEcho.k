
#include <klang.h>
using namespace klang::optimised;

float division(int time) {
	switch(time) {
		case 0: return 2.0;              // 1/2
		case 1: return 1.0;              // 1/4
		case 2: return 1.0 * 1.5;        // 1/4D
		case 3: return 1.0 * 0.5;        // 1/8
		case 4: return 1.0 * 0.5 * 1.5;  // 1/8D
		case 5: return 1.0 * 0.25;       // 1/16
		case 6: return 1.0 * 0.25 * 1.5; // 1/16D
		case 7: return 1.0 * 0.125;      // 1/32
		default: return 1.0;
	}
}

struct SyncEcho : Stereo::Effect {

	// DATA MEMBERS	
	Stereo::Delay<192000> delay;
	float bpm = 120.0;

	// Initialise plugin (called once at startup)
	SyncEcho() {
		controls = {
			{ "ECHO L",
				Menu("Time", {25, 50, 60, 20}, "1/2", "1/4", "1/4D", "1/8", "1/8D", "1/16", "1/16D", "1/32"),
				Dial("Feedback", 0.0, 0.99, 0.1),
			}, 
			{ "ECHO R",
				Menu("Time", {175, 50, 60, 20}, "1/2", "1/4", "1/4D", "1/8", "1/8D", "1/16", "1/16D", "1/32"),
				Dial("Feedback", 0.0, 0.99, 0.1),
			},                          	 // X -- Y -- width - height
			Dial("Dry / Wet", 0.0, 1.0, 1.00, { 320, 50,  60,     60 }),
		};
		// debug.print("Sample Rate: %f", fs.f);
	}

	// Apply processing (called once per sample)
	void process() {
	
		// PARAMETERS  
		int time[2] = { (int)controls[0], (int)controls[2] };
		float samples = (60.0 / bpm) * fs; // samples per quarter note
		param dryWet = controls[4];
			
		// PROCESSING
		stereo::signal echo = { in.l, in.r };
		
		delay.l(samples * division(time[0])) >> echo.l;
		delay.r(samples * division(time[1])) >> echo.r;
		
		delay.l << in.l + echo.r * controls[1];
		delay.r << in.r + echo.l * controls[3];
	
		in.l * (1 - dryWet) + echo.l * dryWet >> out.l;
		in.r * (1 - dryWet) + echo.r * dryWet >> out.r;
	}
}; 