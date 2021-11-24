//////////////////////////////////// USEFUL CONTROLS //////////////////////////////////

s.boot;
s.plotTree;
s.scope;
s.meter;
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

//////////////////////////////Synths/////////////////////////////////////////

(
SynthDef.new(\Drone1, {
		|envt1= 3, envt2= 5, envt3= 87, out = 0, off=1, amp= 0.2|
		var temp, sum, env, envgen;
		sum = 0;
		10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			0.05
		);
		sum = sum + temp * 0.5;
	};
	env = Env.new([0, 1, 1, 0], [envt1, envt2, envt3]);
	envgen = EnvGen.kr(env, Impulse.kr((envt1+envt2+envt3).reciprocal), doneAction:0);
	sum = sum * 0.3 * envgen * amp * off;
	Out.ar(out, sum);

	}).add;
)

x = Synth(\Drone1, [\amp, 0.3]);
x.set(\amp, 0.6);
x.free;

(
SynthDef.new(\Drone2,{
	|freq=100, dev=2.02, out=0, envt1=2, envt2=77, envt3=1, off=1, amp = 0.2|
	var temp, sum, env, envgen;
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
	env = Env.new([0, 1, 1, 0], [envt1, envt2, envt3]);
	envgen = EnvGen.kr(env, Impulse.kr((envt1+envt2+envt3).reciprocal), doneAction:0);
	sum = sum * 0.3 * envgen * amp *off;
	Out.ar(out, sum);
		},[5!3]
	).add;
)

y = Synth(\Drone2);
y.set(\amp, 0.1);
y.free;

(
SynthDef(\Ambient, {
	|amp = 0.2|
	var amp1, sig;

	amp1 = SinOsc.kr([0.5, 1, 2, 5, 0.7, 1.5]).range(0, 1)* 0.2;
	sig = SinOsc.ar([200, 400, 666, 777, 800, 1000]);
	sig = amp * amp1 * sig;
	sig = Splay.ar(sig);
	Out.ar(0, sig!2);

}).add;
)

a = Synth(\Ambient);
a.set(\amp,0.01);
a.free;

(
SynthDef(\MIDIsynth1, {
	|freq = 440, amp = 0.4, harmonic=15, atc = 0.1, rls = 0.2|
	var sig, env;

	env = Env.perc();
	env = EnvGen.kr(env, gate: \gate.kr(1), doneAction: 2);

	sig = SinOsc.ar(freq * harmonic);
	sig = sig * env * 0.4;
	sig = sig * LFNoise2.kr(0.5).exprange(0.1,1);
	Out.ar(0, sig);

}).add;
)

b = Synth(\MIDIsynth1);
//b = Synth(\MIDIsynth1, [\freq, 440, \atc, 0.2, \rls, 5, \harmonic, rrand(1,10)]);

(
SynthDef(\Emmion, {
	|freq, amp, harmonic, atk, rls|
	var sig, env;

	env = Env.perc(atk,rls);
	env = EnvGen.kr (env, doneAction: 2);
	sig= SinOsc.ar(freq*harmonic);
	sig = sig * env * 0.3;
	sig = sig * LFNoise1.kr(0.8).exprange(0.1,1);

	Out.ar(1,sig);

}).add;
)

(
Synth(\Emmion,[
	\freq,28.midicps,
	\harmonic, rrand (1,10),
	\atk, 7,
	\rls,5
])
)

(
SynthDef(\Emmion2, {
	|freq, amp, harmonic, atk, rls|
	var sig, env;

	env = Env.perc(atk,rls);
	env = EnvGen.kr(env, doneAction: 2);
	sig= SinOsc.ar(freq*harmonic);
	sig = sig * env * 0.3;
	sig = sig * LFNoise2.kr(0.8).exprange(0.1,1);

	Out.ar(0,sig);

}).add;
)

(
Synth(\Emmion2,[
	\freq,60.midicps,
	\harmonic, rrand (1,10),
	\atk, 7,
	\rls,5])
)

/////////////////////////////PERFORMANCE///////////////////////////////////////

//KNOBS

(
MIDIdef.cc(\knob2,{

	arg val, ctl;

	//[val, ctl].postln;
	x.set(\amp, val.linlin(0, 127, 0.0, 1.0)).postln;



},74)
)


(
MIDIdef.cc(\knob3,{

	arg val, ctl;

	//[val, ctl].postln;
	y.set(\amp, val.linlin(0, 127, 0.0, 1.0));



},71)
)

(
MIDIdef.cc(\knob4,{

	arg val, ctl;

	//[val, ctl].postln;
	a.set(\amp, val.linlin(0, 127, 0, 1));



},76)
)


//

~notes = Array.newClear(128);

(
MIDIdef.noteOn(\noteOn, {
	arg vel, nn;

	~notes[nn] = Synth(\MIDIsynth1, [
		\freq, nn.midicps,
		\atc, 0.2,
		\rls, 0.1,
		\amp, vel.linexp(1, 127, 0.1, 1),
		\gate, 1
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

//PADS

(
MIDIdef.cc(\pad1, {
	arg vel, nn;

	~notes[nn] = (
		Synth(\Emmion,[
			\freq,28.midicps,
			\harmonic, rrand (1,10),
			\atk, 7,
			\rls,5])
)
},22)
)

(
MIDIdef.cc(\pad2, {
	arg vel, nn;

	~notes[nn] = (
		Synth(\Emmion2,[
			\freq,60.midicps,
			\harmonic, rrand (1,10),
			\atk, 7,
			\rls,5])
)
},23)
)











