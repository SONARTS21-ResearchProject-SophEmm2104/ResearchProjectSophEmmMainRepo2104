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

// Function to locate the pads of the midi keyboard

MIDIFunc.trace(true);
MIDIFunc.trace(false);
MIDIFunc.noteOn({"hello".postln}, 36, 9);
MIDIFunc.noteOff(func, noteNum, chan, srcID, argTemplate, dispatcher);
)


//////////////////////////////Synths/////////////////////////////////////////

(
SynthDef.new(\Drone1, {
		arg envt1=3, envt2=87, envt3=5, out, off=1;
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
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [envt1, envt2, envt3]), doneAction:2);
	sum = sum*0.05*env*off;
	Out.ar(out, sum);

	}).add;
)

x = Synth(\Drone1, [\amp, 0.1]);
x.set(\amp, 0.5);
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
	sum = sum * 0.1 * env*off;

	Out.ar(out, sum);
		},[5!3]
	).add;
)

y = Synth(\Drone2);
y.set(\amp, 0.001);
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

a = Synth(\Ambient);
a.free;

(
SynthDef(\MIDIsynth1, {
	arg freq=220, amp = 0.2;
	var sig, env;

	sig = Pulse.ar(ExpRand, 30, 500);
	env = SinOsc.kr( 1, 0.01, 1 ,doneAction: 2);
	env = EnvGen.kr(env, doneAction: 2);

	sig = sig * amp *env;
	sig = Splay.ar(sig);
	Out.ar(0, sig);

}).add;
)

b = Synth(\Ambient);
b.free;

(
SynthDef(\MIDIsynth2, {
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


Synth(\MIDIsynth2, [\freq, 440, \atc, 0.2, \rls, 5, \harmonic, rrand(1,10)]);

// Method for playing a new note

(
~noteOn = { | vel = 64, nn = 60 |
	        nn.postln;

~notes[nn] =	Synth(\MIDIsynth2, [
		\freq, 400,
		\atc, 0.2,
		\rls, 5,
		\harmonic, rrand(1,10),
		\gate, 1
	])

};
)

~noteOn.value;




~notes = Array.newClear(128);

(
MIDIdef.noteOn(\noteOn, { | vel = 64, nn = 60 |
	//nn.postln;
	~noteOn.(vel, nn);
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









