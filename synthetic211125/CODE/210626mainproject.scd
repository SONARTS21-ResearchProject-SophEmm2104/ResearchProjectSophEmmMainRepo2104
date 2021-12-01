//////////////////////////////////// USEFUL CONTROLS //////////////////////////////////

s.reboot;
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
		arg envt1=3, envt2=5, envt3=87, envt4=100, out, off=1, amp;
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
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [envt1, envt2, envt3, envt4]), doneAction:2);
	sum = sum*0.3*env*off;
	Out.ar(out, sum);

	}).add;
)

x = Synth(\Drone1, [\amp, 0.3]);
x.set(\amp, 0.6);
x.free;

(
SynthDef.new(\Drone2,
		{

	arg freq=100, dev=2.02, out, envt1=2, envt2=77, envt3=1, off=1, amp;
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
	env = EnvGen.kr(Env.new([0, 1, 1, 0], [envt1, envt2, envt3]), doneAction:2);
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
	sig = sig * amp * 0.3;
	sig = Splay.ar(sig);
	Out.ar(0, sig!2);

}).add;
)

a = Synth(\Ambient);
a.free;

(
SynthDef(\MIDIsynth1, {
	arg freq = 440, amp = 0.4, harmonic=15, atc = 0.1, rls = 0.2;
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
	arg freq, amp, harmonic, atk, rls;
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
	arg freq, amp, harmonic, atk, rls;
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

/////////////////////////////////SOUNDS////////////////////////////////////////

~sound1 = Buffer.read(s,"C:/Users/user/Music/SCHAEFFER MATMOS IAM WAV FILES/TEXTURE 2 ASi 0_00.wav");

~sound2 = Buffer.read(s,"C:/Users/user/Music/SCHAEFFER MATMOS IAM WAV FILES/TEXTURE 3 ASi 2_59.wav");

~sound3 = Buffer.read(s,"C:/Users/user/Music/SCHAEFFER MATMOS IAM WAV FILES/TEXTURE 11 EM 10_09.wav");

(
SynthDef(\sampler, {
	arg amp=1, buf, rate=1, loop, pos;
	var sig;

	sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, startPos: pos, loop: loop, doneAction: 2);
	sig = sig * amp;

	Out.ar(0, sig!2);

}).add;
)

~impro = Group.new();

d = Synth(\sampler, [\amp, 0.6, \buf, ~sound1.bufnum, \rate, -1, \loop, 1]);

/* οταν βαλω -1 στο rate το παιζει αναποδα. Αν παίζει αναποδα και χωρις loop πρεπει να βαλω το pos να ξεκιναει στα -2 frames (περιπου), αλλιως απλα παιζει 2 frames οποτε στην ουσια δεν ακουγεται τιποτα. Ολα αυτα χρειαζονται αν βαλω doneAction. Αλλιως δεν χρειαζεται να ορισω startpos */

x.set(\loop, 0);

/////////////////////////////PERFORMANCE///////////////////////////////////////


/* something here goes terrible wrong

//ROUTINES - LOOPS
(
r = Routine({

	{1.do{arg note; Synth(\Drone1)};
	1.wait;

}.loop;

});
)

r.play;
r.stop;

(
r1 = Routine({

	{1.do{arg note; Synth(\Drone2)};
	1.wait;

}.loop;

});
)

r1.play;
r1.stop;

(
r2 = Routine({

	{1.do{arg note; Synth(\Ambient)};
	1.wait;

}.loop;

});
)

r2.play;
r2.stop;

*/

//KNOBS

(
MIDIdef.cc(\knob2,{

	arg val, ctl;

	[val, ctl].postln;
	x.set(\amp, val.linlin(0, 127, 0.0, 1.0)).postln;



},74)
)


(
MIDIdef.cc(\knobs3,{

	arg val, ctl;

	[val, ctl].postln;
	y.set(\amp, val.linlin(0, 127, 0.0, 1.0));



},71)
)

(
MIDIdef.cc(\knobs3,{

	arg val, ctl;

	[val, ctl].postln;
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











