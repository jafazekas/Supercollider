// Improvisatory Plucking Synth
// Author: Jackie Fazekas
// 6.20.16
(
// =================
// definitions
// =================
SynthDef("plucking", {arg amp = 0.1, freq = 440, decay = 5, dampen = 0.1;
	var env = Env.linen(0, decay, 0).kr(doneAction: 2);
	var snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: dampen);
	Out.ar(0, [snd, snd]);
}).add;

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(att, rel).kr(doneAction: 2);
	snd = HPF.ar(snd * env, ffreq);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

// scale and tempo values
~scale = Scale.indian;
~chords = [1, [1, 3, 5], 2, [2, 5, 7], 3, [3, 6], 4, [4, 6, 2]];
t = 120/60; // 120 bpm

// =================
// create Pbinds
// =================
a = Pbind( // scale and chords test
	\scale, ~scale,
	\degree, Pseq(~chords, inf),
	\dur, 1,
	\amp, 0.25,
	\tempo, t
);

b = Pbind( // improvisation
	\scale, ~scale,
	\instrument, "plucking",
	\degree, Pxrand((5..9), inf),
	\dur, Pwrand([Pseq([1/4], 5), Rest(1/2), 1/2, Rest(1), 2], [ 0.5, 0.2, 0.1, 0.1, 0.1], inf),
	\amp, 0.25,
	\tempo, t
);

c = Pbind( // bass pattern
	\scale, ~scale,
	\instrument, "plucking",
	\degree, Pxrand(~chords, inf),
	\dur, Pxrand([
		Pseq([1, Rest(1), 1, Rest(1), 1, 1, Rest(1/2), 1/2, 1/2, 1/2], inf),
		Pseq([1, Rest(1), 1, Rest(1), 1, 1, Rest(1/2), 1/2, Rest(1/2), 1/2], inf),
		Pseq([1, Rest(1), 1, Rest(1), 1, 1, 2/3, 2/3, 2/3], inf),
	], inf),
	\amp, 0.25,
	\tempo, t
);

d = Pbind( // last chord
	\scale, ~scale,
	\instrument, "plucking",
	\degree, [0, 3, 5, 8],
	\dur, 2,
	\amp, 0.25,
	\tempo, t
);

e = Pbind( // percussion
	\instrument, "hihat",
	\dur, Pseq([Rest(1/2), Pseq([1/8], 4)], inf),
	\ffreq, 10000,
	\rel, 0.7,
	\amp, 0.1
);

// =================
// run piece
// =================
{
	s.record;
	//~test = a.play(quant: 1);
	~perc = e.play(quant: 8);
	~bass = c.play(quant: 8);
	(t*4).wait; // 2 measures
	~improv = b.play(quant: 8);
	(t*85).wait; // 5 measures
	~bass.stop;
	~improv.stop;
	~perc.stop;
	//(t*0.2).wait;

	~end = d.play(quant:8); // end the piece
	(t).wait;
	~end.stop;
	(t*4).wait;
	s.stopRecording;
}.fork;
)