//////////////////////////////////// USEFUL CONTROLS //////////////////////////////////

s.boot;
s.plotTree;
s.scope;
s.freqscope;
MIDIClient.init;
MIDIIn.connectAll;
MIDIdef.freeAll;
MIDIdef.noteOn(\notaOn, {"Hey guys".postln;});

// Function to locate the knobs of the midi Keyboard

(
MIDIdef.cc(\knobs, {

	arg val, ctl;
	[val, ctl].postln;
})
)


//////////////////////////////Synths/////////////////////////////////////////

(
SynthDef.new(\Drone1, {
		arg t1=3, t2=87, t3=5, out, off=1;
		var temp, sum, env;
		sum = 0;
		10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			0.05
		);
		sum = sum + temp * 0.5;
	};
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [t1, t2, t3]), doneAction:2);
	sum = sum*0.05*env*off;
	Out.ar(out, sum);

	}).add;
)

x = Synth(\Drone1, [\amp, 0.1]).play;
x.free;

(
SynthDef.new(\Drone2,
		{

	arg freq=100, dev=2.02, out, t1=2, t2=77, t3=1,off=1;
	var temp, sum, env;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [t1, t2, t3]), doneAction:2);
	sum = sum * 0.2 * env*off;

	Out.ar(out, sum);
		},[5!3]
	).add;
)

y = Synth(\Drone2).play;
y.free;

(
SynthDef(\Ambient, {
	var amp, sig;

	amp = SinOsc.kr([0.5, 1, 2, 5, 0.7, 1.5]).range(0, 1)* 0.2;
	sig = SinOsc.ar([200, 400, 666, 777, 800, 1000]);
	sig = sig * amp * 0.2;
	sig = Splay.ar(sig);
	Out.ar(0, sig);

}).add;
)

a = Synth(\Ambient).play;
a.free;

(
SynthDef(\MIDIsynth, {
	arg freq = 440, amp = 0.4, harmonic, atc = 0.1, rls = 0.2;
	var sig, env;

	env = Env.perc();
	env = EnvGen.kr(env, gate: \gate.kr(1), doneAction: 2);

	sig = SinOsc.ar(freq * harmonic);
	sig = sig * env * 0.1;
	sig = sig * LFNoise2.kr(0.5).exprange(0.1,1);
	Out.ar(0, sig);


}).add;
)


Synth(\MIDIsynth, [\freq, 440, \atc, 0.2, \rls, 5, \harmonic, rrand(1,10)]);

~notes = Array.newClear(128);

(
MIDIdef.noteOn(\noteOn, {
	arg vel, nn;
	nn.postln;

	~notes[nn] = Synth(\MIDIsynth, [
		\freq, nn.midicps, // midi to frequency conversion
		\atc, 0.2, // attack time
		\rls, 0.1,  // release time
		\amp, vel.linexp(20, 127, 0.1, 1.0), // velocity to amp conversion
		\gate, 1 // start the envelope
	]);
});
)


(
MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;

})
)

~noteOn1 = [];
~noteOff1 = [];

~noteOn1 = ~noteOn1 ++ [[1,10]];

(
MIDIdef.noteOn(\noteOnRecord, {
	arg vel, nn;
	//nn.postln;

	postf("I will record this note On: %, at time % \n", nn, Process.elapsedTime);
    ~noteOn1 = ~noteOn1 ++ [[nn, Process.elapsedTime]];
});
)

(
MIDIdef.noteOff(\noteOffRecord, {
	arg vel, nn;

	postf("I will record this note Off: %, at time % \n", nn, Process.elapsedTime);
    ~noteOff1 = ~noteOff1 ++ [[nn, Process.elapsedTime]];

})
)

~noteOn1
~noteOff1

~noteOn1.flop;
~noteOn1.flop[0];
~noteOn1.flop[1];
~noteOn1.flop[1].differentiate;

(
{
	var

}



)









