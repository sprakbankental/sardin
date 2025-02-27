#!/usr/bin/perl -w

use warnings;
use strict;
use utf8;

#**********************************************************************************************************************************************************#
# Name		Letters			Phones MTM		Phones Acapela		Phones Cereproc
#**********************************************************************************************************************************************************#
SWEINI		a			a2: a an ä3 e-j		a aa A: a~ { E-j		aa a an ae e-j
SWEINI		o			o2: o o3 å on		u: U O o~			uu u o on
SWEINI		u			u2: u u3 o		}: u U			uux ux u
SWEINI		å			å2: å o3			o: O			oo o u
SWEINI		e			e2: e ä ë e3 i2:		e: e E {: { @		ee e e eh ii
SWEINI		i			i2: i i3 en		i: I e~			ii i in
SWEINI		y ü			y2: y			y: Y			yy y
SWEINI		ä			e2: e ä2: ä ä3: ä3		E: E {: { e		ee e eex aae ae
SWEINI		ö			ö2: ö ö3: ö3		2: 2 9: 9			oox ox ooe oe
SWEINI		stj sj			sj			S			x
SWEINI		sch			rs sj s-k			rs S s-k			rs x s-k
SWEINI		sh			rs sj			rs S			rs x
SWEINI		sk			sj s-k			S s-k			x s-k
SWEINI		tj			tj tj3			C tS			c ch
SWEINI		ch			tj tj3 rs sj k		C tS rs S k_h k		c ch rs x k
SWEINI		b			b			b			b
SWEINI		c			s k tj			s k_h k C			s k c
SWEINI		cs cz			tj3			tS			ch
SWEINI		d			d rd			d rd			d rd
SWEINI		f			f			f			f
SWEINI		g			g j			g j			g j
SWEINI		h			h			h			h
SWEINI		j			j j3 sj d-j		j S dZ d-j		j jh x d-j
SWEINI		lj hj gj			j			j			j
SWEINI		dj			j d-i2: d-j		j d-i: d-j		j d-ii d-j
SWEINI		k			k tj			k_h k C			k c
SWEINI		l			l rl			l rl			l rl
SWEINI		m			m			m			m
SWEINI		n			n			n			n
SWEINI		p			p			p_h p			p
SWEINI		ph			f p			f p_h p			f p
SWEINI		q			k			k			k
SWEINI		r			r			r			r
SWEINI		s			s rs			s rs			s rs
SWEINI		t			t rt			t_h t rt			t rt
SWEINI		v			v f			v f			v f
SWEINI		x			k-s s			k-s s			k-s s
SWEINI		z			s z t-s			s z t-s			s z t-s

SWEINI		aa			a2: a å2:			A: a o:			aa a oo
SWEINI		ae			ä3: ä3 ä e2: e		}: } E e: e		aae ae e ee
SWEINI		ai			a-j ä-j ä3: e		a-j E-j }: E		a-j e-j aae e
SWEINI		au			au å2: å o3		a-U o: O			au oo o u
SWEINI		aug			au å2: a2:		a-U o: A:			au oo aa
SWEINI		action			ä3-k			{-k-			ae-k
SWEINI		ambient			e-j-m			e-j-m			e-j-m
SWEINI		amy			e-j-m a-m-i a-m-y		e-j-m a-m-I a-m-Y		e-j-m a-m-i a-m-y
SWEINI		age			e-j a2: a			e-j A: a			e-j aa a
SWEINI		all			a-l å2:-l			a-l			a-l oo-l
SWEINI		ea			ö3: i2:			9: i:			ooe ii
SWEINI		ei			a-j ä-j e-j		a-j e-j			a-j e-j
SWEINI		en			e2:-n ä-n e-n e-ng e3-n a-ng	e:-n E-n a-N		ee-n e-n e-ng a-ng
SWEINI		ent			e-n-t a-ng-t e2:-n-t	e-n-t a-ng-t e:-n-t		e-n-t a-ng-t ee-n-t
SWEINI		er			e2:-r ä-r e-r ä3-r ä3:-r	e:-r E-r }-r }:-r		ee-r e-r ae-r aae-r
SWEINI		eu			eu e-v e2:-u2:		E-v e:-}:			eu e-v ee-uux
SWEINI		eye			a-j			a-j			a-j
SWEINI		eng			e-ng a-ng e2:-n-g e2:-n-j	e-ng a-ng e:-n-g e:-n-j	e-ng a-ng ee-n-g ee-n-j
SWEINI		ia			i2:-a j-a i-a		i:-a j-a I-a		ii-a j-a i-a
SWEINI		ic			a-j			a-j			a-j
SWEINI		ich ict			i			I			i
SWEINI		ick			i-k			I-k			i-k
SWEINI		ing			i-ng ä-ng i-n-g i-n-sj i-n-j	I-N e-N I-n-g I-n-S I-n-j	i-ng e-ng i-n-g i-n-x i-n-j
SWEINI		iu			j			j			j
SWEINI		io			i2: j			i: j			ii j

SWEINI		iTunes itunes iOS		a-j			a-j			a-j
SWEINI		iPhone iphone		a-j			a-j			a-j
SWEINI		iPad iPod ipad ipod		a-j			a-j			a-j
SWEINI		oa			o2: o w öw		u: U w 2-U		uu u w ou
SWEINI		oe			o2: ö2: ö3: å2: ä		u: 2: 9: o: E		uu oox ooe oo e
SWEINI		oeso			ä			E			e
SWEINI		old			öw o2: å			2-U u: O			ou uu o
SWEINI		one			o2: o3 o å2: å w-a-n	u: U o: O w-a-n		uu u oo o w-a-n
SWEINI		ou			o2: o o3 au		u: U a-U			uu u au
SWEINI		over			öw o2: å o3		2-U u: O			ou uu o u
SWEINI		open			öw o2:			2-u u:			ou uu
SWEINI		th			th dh t d			T D t d			th dh t d
SWEINI		under			u-n-d a-n-d		u-n-d a-n-d		ux-n-d a-n-d
SWEINI		upper			u-p a-p			u-p a-p			ux-p a-p
SWEINI		unit			u2: u3 u j-u2:		}: u j-}:			uux ux j-uux
SWEINI		ya ye yi yo yu		j			j			j

SWEINI		cier			s-i-e2: ë-r		s-I-e: @-r		s-i-ee eh-r
SWEINI		cemb			tj-ä-m s-ä-m		C-e-m s-e-m		c-e-m s-e-m
SWEINI		emb			e-m-b a-m-b		e-m-b a-m-b		e-m-b a-m-b
SWEINI		dz			j3			dZ			jh
SWEINI		ge			sj j g rs			S j g rs			x j g rs
SWEINI		gi			sj g j			sj g j			x g j
SWEINI		fm			ä-f			E-f			e-f
SWEINI		hm hl			sj			S			x
SWEINI		mp mr ms mt mT		ä-m			E-m			e-m
SWEINI		haut			h-å2:			h-o:			h-oo
SWEINI		tarte			r-t			r-t			r-t
SWEINI		hie			h j			h j			h j
SWEINI		hv hw			v			v			v
SWEINI		kn			k-n n k			k_h-n n			k-n n k
SWEINI		liu lif-			j u2:			j }:			j-uux
SWEINI		mc			m-a-k m-ä3-k ä-m-s-e2:	m-A-k E-m-s-e:		m-a-k m-ae-k e-m
SWEINI		qi			k tj			k C			k-c
SWEINI		ps			p-s s p-e2:-ä-s		p-s s p_h-e:-E-s		p-s s p-ee-e-s
SWEINI		tion			t sj			t S			t x
SWEINI		xh			k			k			k
SWEINI		xi			tj k-s-i			C k-s-i			c k-s-i
SWEINI		zj			rs			rs			rs
SWEINI		rn rN rAA- raa-		ä3-r			{-r			ae-r
SWEINI		rS- rs-			ä3-r			{-r			ae-r
SWEINI		iia			a			a			a

SWEINI		a- adl- ards- auf- aik-	a2:			A:			aa
SWEINI		b- bmi-			b-e2:			b-e:			b-ee
SWEINI		c- cf- csun- cul- cv- csn	s-e2:			s-e:			s-ee
SWEINI		d- dna-			d-e2:			d-e:			d-ee
SWEINI		e-mail			i2:-m			i:-m			ii-m
SWEINI		e- eu- eu15- ees- eg-	e2:			e:			ee
SWEINI		ep- ean- emu- enp erk-	e2:			e:			ee
SWEINI		f- f: fn- fln- fou-		ä-f			E-f			e-f
SWEINI		fbi fxa- fv fud- f1		ä-f			E-f			e-f
SWEINI		ft- fev1 fft- fra- fec-	ä-f			E-f			e-f
SWEINI		fvi fc- fta- ff- fgp-	ä-f			E-f			e-f
SWEINI		h- hm- hls- hv- hla-	h-å2:			h-o:			h-oo
SWEINI		hmg-			h-å2:			h-o:			h-oo
SWEINI		hbo-			e-j-j3-b-ii-öw		E-j			e-j-jh-b-ii-ou
SWEINI		i-			i2: e-t			i: E-t			ii e-t
SWEINI		iu- icd- icf- icp- ica-	i2:			i:			ii
SWEINI		ii-			t-v-å2:			t-v-o:			t-v-oo
SWEINI		ii			i2: t-v-å2: j		i: t-v-o: j		ii t-v-oo
SWEINI		iii			t-r-e2:			t-r-e:			t-r-ee
SWEINI		iv-			f-y2:-r-a			f-y:-r-a			f-yy-r-a
SWEINI		xii-			t-å-l-f-t-ë		t-O-l-f-t-@		t-o-l-f-t-eh
SWEINI		j- j:			j-i2:			j-i:			j-ii
SWEINI		k- k:			k-å2:			k-o:			k-oo
SWEINI		l- l: lp lr lt lo- lvm-	ä-l			E-l			e-l
SWEINI		lbu- lca- LO- lvu- lss-	ä-l			E-l			e-l
SWEINI		lip- la- lchf- ll- ldl-	ä-l			E-l			e-l
SWEINI		lhpa- lkg- lf		ä-l			E-l			e-l
SWEINI		m- m: mms mhk- mfr-		ä-m			E-m			e-m
SWEINI		mi- mr- mit- mvc-		ä-m			E-m			e-m
SWEINI		mai- mrt mic- mns-		ä-m			E-m			e-m
SWEINI		mls- mct-	mf mmi mma-	ä-m			E-m			e-m
SWEINI		mao- mu- ml-		ä-m m			E-m m			e-m m
SWEINI		n- n: ngo nih- nk- no-	ä-n			E-n			e-n
SWEINI		nrk- nu- nv- nvq- nds-	ä-n			E-n			e-n
SWEINI		na- nph- nrg nbk- nmr-	ä-n			E-n			e-n
SWEINI		nsaid- nace- nhl- nt ncis	ä-n			E-n			e-n
SWEINI		nbc ncc			ä-n			E-n			e-n
SWEINI		ng-			ä-ng			E-ng			e-ng
SWEINI		o-			o2:			u:			uu
SWEINI		p- ph- psa- psi-		p-e2:			p_h-e:			p-ee
SWEINI		r: r- rf rh- rem- rm-	ä3-r			{-r			ae-r
SWEINI		rps- rhd- rpe- rct-		ä3-r			{-r			ae-r
SWEINI		s- s: sms sos- ss-		ä-s			E-s			e-s
SWEINI		sp- sr- sfi- sm- se-	ä-s			E-s			e-s
SWEINI		sbic- sli- slu- sg-		ä-s			E-s			e-s
SWEINI		sme- so- si- sns- shl-	ä-s			E-s			e-s
SWEINI		sou- svr- sce- snri-	ä-s			E-s			e-s
SWEINI		scd- ssu- svt- st-		ä-s			E-s			e-s
SWEINI		sbk- sbu- scid- scl-	ä-s			E-s			e-s
SWEINI		sd snr- ssri- su-		ä-s			E-s			e-s
SWEINI		svr sry- sf- stm sga-	ä-s			E-s			e-s
SWEINI		sfs- sia- slc srebp		ä-s			E-s			e-s
SWEINI		spd sru ssab		ä-s			E-s			e-s
SWEINI		t-			t-e2: t-i2:		t-e: t-i:			t-ee t-ii
SWEINI		u-			u2:			}:			uux
SWEINI		up-			a-p			a-p			a-p
SWEINI		v-			v-e2:			v-e:			v-ee
SWEINI		w-			d-u-b-ë-l-v-e2: v-e2:	d-u-b-@-l-v-e: v-e:		d-ux-b-eh-l-v-ee
SWEINI		x: xg- xo- xy- xt xb xk	ä-k-s			E-k-s			e-k-s
SWEINI		xxx- xxy- xyy-		ä-k-s			E-k-s			e-k-s
SWEINI		x- xm			ä-k-s			E-k-s			e-k-s
SWEINI		y- ya- yif-		y2:			y:			yy
SWEINI		z-			s-ä2:-t-a			s-E:-t-a			s-eex-t-a
SWEINI		å-			å2:			o:			oo
SWEINI		ä-			ä2:			E:			eex
SWEINI		ö-			ö2:			2:			oox

#**********************************************************************************************************************************************************#
# Name		Letters			Phones MTM		Phones Acapela		Phones Cereproc
#**********************************************************************************************************************************************************#
SWEFIN		a			a a2: a3:			a A: aa			a aa aah
SWEFIN		o			o2: o å å2:		u: U O o:			uu u oo o
SWEFIN		u			u2: u u3 o o2:		}: u u:			uux ux uu u
SWEFIN		å			å2: å			o: O			oo o
SWEFIN		e			e2: ë			e: @			ee eh
SWEFIN		i			i2: i			i: I			ii i
SWEFIN		y			y2: y i			y: Y			yy y i
SWEFIN		ä			e2: e ä2: ä		E: E e			ee e eex
SWEFIN		ö			ö2:			2:			oox

SWEFIN		b			b			b			b
SWEFIN		c			k s			k s			k s
SWEFIN		d			d t			d t			d t
SWEFIN		f			f v			f v			f v
SWEFIN		g			g k			g k			g k
SWEFIN		h			rs			rs			rs
SWEFIN		j			j			j			j
SWEFIN		k			k			k			k
SWEFIN		l			l			l			l
SWEFIN		m			m			m			m
SWEFIN		n			n			n			n
SWEFIN		p			p p-e2:			p p-e:			p p-ee
SWEFIN		q			k			k			k
SWEFIN		r			r			r			r
SWEFIN		s			s			s			s
SWEFIN		t			t			t			t
SWEFIN		v			v			v			v
SWEFIN		x			k-s			k-s			k-s
SWEFIN		z			s z			s z			s z

SWEFIN		ha aa aaa			a a2: a3:			a A: aa			a aa aah
SWEFIN		jf jjf			j-f v			j-f v			j-f v
SWEFIN		ch			tj3 rs k sj tj		tS rs k			ch rs k x c
SWEFIN		tj			tj3			tS			ch
SWEFIN		dt			d t			d t			d t
SWEFIN		sch			rs			rs			rs
SWEFIN		tch			rt-rs tj3			rt-rs tS			rt-rs ch
SWEFIN		age			a2:-rs a2:-g-ë a-j-e2: a-g-ë	A:-rs A:-g-@ a-j-e: a-g-@	aa-rs aa-g-eh a-j-ee a-g-eh
SWEFIN		oge			o2:-g-ë å2:-rs å2:-g-ë o-g-ë j-e2:	u:-g-@ o:-rs o:-g-@ U-g-@ j-e:	uu-g-eh oo-rs oo-g-eh u-g-eh j-ee
SWEFIN		ege			j-e2: ë e2:-rs i-j3		j-e: @ e:-rs I-dZ		j-ee eh ee-rs i-jh
SWEFIN		dge			j3 j-e2:			dZ j-e:			jh j-ee
SWEFIN		ei			i2: i e-j			i: I e-j			ii i e-j
SWEFIN		eh			e e2: ë			e e: @			ee e eh
SWEFIN		crème créme creme		k-r-ä2:-m			k-r-E:-m			k-r-eex-m
SWEFIN		äh ä3			ä2:			E:			eex
SWEFIN		ee			i2: e2: ë i		i: e: @ I			ii ee eh i
SWEFIN		th			t th			t T			t th
SWEFIN		nh			n			n			n
SWEFIN		dh			d			d			d
SWEFIN		ão			au			a-U			au
SWEFIN		gh			g			g			g
SWEFIN		igh			i i-g i2: g		I I-g i:-g		i i-g ii-g
SWEFIN		tjstj			rs-rt-rs			rs-rt-rs			rs-rt-rs
SWEFIN		ph			f			f			f
SWEFIN		ice			a-j-s i-s i-k-ë i2:-s-ë	a-j-s I-s I-k-@ i:-s-@	a-j-s i-s i-k-eh ii-s-eh
SWEFIN		cte			k-t-ë k-t			k-t-@ k-t			k-t-eh k-t
SWEFIN		ance			a-n-s a-n-s-ë		a-n-s a-n-s-@		a-n-s a-n-s-eh
SWEFIN		ig			i-g i i2:-g ä-j		I-g i:-g E-j		i-g ii-g e-j
SWEFIN		igt			i-t i2:-k-t		I-g-t i:-k-t		i-t ii-k-t
SWEFIN		iga			i-a i-g-a i2:-g-a		I-g-a i:-g-a		i-g-a ii-g-a
SWEFIN		ij			i-j i2:			I-j i:			i-j ii
SWEFIN		eij			e-j			e-j			e-j
SWEFIN		aiga			a-j-g-a a2:-i-a		a-j-g-a A:-I-g-a		a-j-g-a
SWEFIN		aigas			a-j-g-a-s			a-j-g-a-s			a-j-g-a-s
SWEFIN		ige			i-ë i2:-j-e2: i2:-g-ë i2:-rs	I-g-@ i:-j-e: i:-g-@ i:-rs	i-g-eh ii-j-ee ii-g-eh ii-rs
SWEFIN		igs			i-s i2:-g-s i-g-s		I-g-s i:-g-s		i-g-s ii-g-s
SWEFIN		igts			i-t-s i2:-k-t-s		I-g-t-s i:-k-t-s		i-t-s ii-k-t-s
SWEFIN		igas			i-a-s i-g-a-s i2:-g-a-s	I-g-a-s i:-g-a-s		i-g-a-s ii-g-a-s
SWEFIN		iges			i-ë-s i2:-j-e2:-s i2:-g-ë-s i2:-rs-s	I-g-@-s i:-j-e:-s i:-g-@-s i:-rs-s	i-g-eh-s ii-j-ee-s ii-g-eh-s ii-rs-s
SWEFIN		oy			j			j			j
SWEFIN		ere ère			ë ä3:-r			ë {:-r			eh ae-r
SWEFIN		ache			rs a-k-ë			rs a-k-@			rs a-k-eh
SWEFIN		aue			au-ë			a-U-@			au-eh
SWEFIN		aise aisse ousse		s			s			s
SWEFIN		gourmet			e2:			e:			ee
SWEFIN		rg			r-j r-g			r-j r-g			r-j r-g
SWEFIN		åh			å2:			o:			oo
SWEFIN		uh			u2:			}:			uux
SWEFIN		lg			l-j			l-j			l-j
SWEFIN		onge			ng-rs ng-ë		N-rs N-@			ng-rs ng-eh
SWEFIN		uice			o2:-s			u:-s			uu-s
SWEFIN		ent			ë-n-t a-ng ä-n-t e2:-n-t	@-n-t a-N E-n-t e:-n-t	eh-n-t a-ng e-n-t ee-n-t
SWEFIN		ot			å-t o-t o2:-t å2:-t å2:	O-t U-t u:-t o:-t o:	o-t u-t uu-t oo-t oo
SWEFIN		euse			ö2:-s			2:-s			oox-s
SWEFIN		che			ë rs			@ rs			eh rs
SWEFIN		ette otte			ë t			@ t			eh t
SWEFIN		eige			rs e2:-i-ë		rs e:-I-g-@		rs ee-i-g-eh
SWEFIN		eiges			rs-s e2:-i-ë-s		rs-s e:-I-g-@-s		rs-s ee-i-g-eh-s
SWEFIN		eiga			rs-a e2:-i-a		rs-a e:-I-g-a		rs-a ee-i-g-a
SWEFIN		lais			l-ä2:			l-E:			l-eex
SWEFIN		ene			e2:-n-ë e2:-n ë-n-ë		e:-n-@ e:-n @-n-@		ee-n-eh ee-n eh-n-eh
SWEFIN		karl			k-a2:-r k-a2:-rl		k-A:-r k-A:-rl		k-aa-r k-aa-rl
SWEFIN		ai oj			j			j			j
SWEFIN		ay			ä-j e-j a-j ä2:		e-j E-j a-j E:		e-j a-j eex
SWEFIN		use			ë y-s			@ Y-s			eh y-s
SWEFIN		aubade			a2:-d			A:-d			aa-d
SWEFIN		ine			n-ë i2:-n i-n a-j-n		n-@ i:-n I-n a-j-n		n-eh ii-n i-n a-j-n
SWEFIN		verkstad			v-ä3-r-k-s-t-a		v-{-r-k-s-t-a		v-ae-r-k-s-t-a
SWEFIN		garde			g-a-r-d g-a2:-rd-ë		g-a-r-d g-A:-rd-@		g-a-r-d g-aa-rd-eh
SWEFIN		gle			ë g-ë-l			@ g-@-l			eh g-eh-l
SWEFIN		ble			b-ë-l b-l-ë		b-@-l b-l-@		b-eh-l b-l-eh
SWEFIN		uine			i-n i2:-n-ë		I-n i:-n-@		i-n ii-n-eh
SWEFIN		uide			a-j-d i2:-d-ë		a-j-d i:-d-@		a-j-d ii-d-eh
SWEFIN		tide			d-ë d			d-@ d			d-eh d
SWEFIN		genre			sj-a-ng-ë-r		S-a-N-@-r			x-a-ng-eh r
SWEFIN		ier			ë-r j-e2: i2:-r		@-r j-e: i:-r		eh-r j-ee ii-r
SWEFIN		ouson			å-ng			O-N			o-ng
SWEFIN		ou			o2:			u:			uu
SWEFIN		gne			n-j ng-n-ë g-n-ë j-n-ë	n-j N-n-@ g-n-@ j-n-@	n-j ng-n-eh g-n-eh j-n-eh
SWEFIN		onne			ë å-n			@ O-n			eh o-n
SWEFIN		que			k			k			k
SWEFIN		quet			k-e2:			k-e:			k-ee
SWEFIN		ie			i-ë i2: i i3-ë i2:-ë	I-@ i: I I-@ i:-@ j-@	i-eh ii i ii-eh j-eh
SWEFIN		gue			g g-ë			g g-@			g g-eh
SWEFIN		ozo			å2: o			o: O U			oo o u
SWEFIN		oisie			i2:			i:			ii
SWEFIN		ois			o:-i-s o3-a3:		u:-I-s u-aa		uu-i-s u-aah
SWEFIN		lait			l-ä2:			l-E:			l-eex
SWEFIN		fait			f-ä2:			f-E:			f-eex
SWEFIN		bert			b-ä3:-r b-ë-rt		b-{:-r b-{-rt		b-aae-r b-ae-rt
SWEFIN		centime			m			m			m
SWEFIN		choke			k			k			k
SWEFIN		oi			å-j			O-j			o-j
SWEFIN		on			n ng			n N			n ng
SWEFIN		oh			o2: å2:			u: o:			uu oo
SWEFIN		eau aux			å2:			o:			oo
SWEFIN		ore			å2:-r r-eh		o:-r r-@			oo-r r-eh
SWEFIN		eigh			e-j			e-j			e-j
SWEFIN		sjtj			tj3			tS			ch
SWEFIN		ive			ë a-j-v			@ a-j-v			eh a-j-v
SWEFIN		sin			n ng			n N			n ng
SWEFIN		byte			b-y2:-t-ë b-a-j-t		b-a-j-t b-y:-t-@		b-yy-t-eh b-a-j-t
SWEFIN		ose			ë e2: å2:-s		@ e: o:-s			eh ee oo-s
SWEFIN		tv			t-e2:-v-e2:		t-e:-v-e:			t-ee-v-ee
SWEFIN		sverige			r-j-ë			r-j-@			r-j-eh
SWEFIN		feature			f-i2:-tj3-ë-r		f-i:-tj3-@-r		f-ii-ch-e-r
SWEFIN		konsert koncert		s-ä3:-r			s-{:-r			s-aae-r
SWEFIN		dessert			s-ä3:-r			s-{:-r			s-aae-r
SWEFIN		lore			r			r			r
SWEFIN		ue			y2:			y:			yy
SWEFIN		dag			d-a2:-g d-a		d-A:-g d-a		d-aa-g d-a
SWEFIN		rh			r			r			r
SWEFIN		kh			k			k			k
SWEFIN		kuvert			k-u3-v-ä3:-r		k-u-v-{:-r		k-ux-v-aae-r
SWEFIN		serve			s-ö3-r-v			s-9-r-v			s-oe-r-v
SWEFIN		säg			s-ä-j			s-E-j			s-e-j
SWEFIN		orange			rn-rs			rn-rs			rn-rs
SWEFIN		sj			rs			rs			rs
SWEFIN		ey			e-j y i ë-j		E-j Y I @-j		e-j y i eh-j
SWEFIN		enne			ä-n ë			E-n @			e-n eh
SWEFIN		elle			ä-l ë			E-l @			e-l eh
SWEFIN		ecu			k-y2:			k-y:			k-yy
SWEFIN		oule			o-l o2:-l			U-l u:-l			u-l uu-l
SWEFIN		ant			a-n-t a-ng a2:-n-t		a-n-t a-N A:-n-t		a-n-t a-ng aa-n-t
SWEFIN		franc			f-r-a-ng			f-r-a-N			f-r-a-ng
SWEFIN		ele			e2:-l-ë e-l l-e2: e-l-ë ë-l-ë	e:-l-@ E-l l-e: e-l-@ @-l-@	ee-l-eh e-l l-ee e-l-eh eh-l-eh
SWEFIN		ille			i-l-ë i-l			I-l-@ I-l			i-l-eh i-l
SWEFIN		anne			a-n-ë a-n			a-n-@ a-n			a-n-eh a-n
SWEFIN		ence			e-n-s ë-n-s a2:-n-s		E-n-s @-n-s A:-n-s		e-n-s eh-n-s aa-n-s
SWEFIN		aire			ä3:-r			{:-r			aae-r
SWEFIN		phe			f-ë f			f-@ f			f-eh f
SWEFIN		le			l-ë ë-l l-e2:		l-@ @-l l-e:		l-eh eh-l l-ee
SWEFIN		ao			au a-o2: a2:-o		a-U a-u: A:-u		au a-uu aa-u
SWEFIN		krigs			k-r-i2:-g-s k-r-i-k-s k-r-i-s	k-r-i:-g-s k-r-I-k-s k-r-I-s	k-r-ii-g-s k-r-i-k-s k-r-i-s
SWEFIN		mande			m-a-n-d-ë m-a-n-d		m-a-n-d-@ m-a-n-d		m-a-n-d-eh m-a-n-d
SWEFIN		de			d-ë d-å-m			d-@ d-O-m			d-eh d-o-m
SWEFIN		ide			d-e2: d-ë			d-e: d-@			d-ee d-eh
SWEFIN		det			d-e2: ë-t d-e2:-t		d-e:-t @-t		d-ee-t d-ee eh-t
SWEFIN		jag			j-a2:-g j-a2:		j-A:-g			j-aa j-aa-g
SWEFIN		dig			i ä-j d-i			I E-j d-I-g		i e-j d-i-g
SWEFIN		med			m-e2: m-e2:-d m-ë-d		m-e:-d m-@-d		m-ee m-ee-d m-eh-d
SWEFIN		mycket			ë ë-t			@ @-t			eh eh-t
SWEFIN		och			å2: å-k			O-k			o-k
SWEFIN		lade			d-ë l-a2:			d-@			d-eh l-aa
SWEFIN		sade			d-ë s-a2:			d-@			d-eh s-aa
SWEFIN		skall			s-k-a2: l			l			s-k-aa l
SWEFIN		vad			v-a-d v-a2:-d v-a2:		v-a-d v-A:-d		v-a-d v-aa-d v-aa
SWEFIN		var			v-a-r v-a2:-r v-a2:		v-a-r v-A:-r		v-a-r v-aa-r v-aa
SWEFIN		är			e2: ä3:-r			{:-r			ee aae-r
SWEFIN		yea			ä2:			E:			eex
SWEFIN		cape			k-ä2:-p ë			k-E:-p @			k-eex-p eh
SWEFIN		tape			t-e-j-p			t-E-j-p			t-e-j-p
SWEFIN		tse			t-s-e ë t-s-e2:		t-s-e @ t-s-e:		t-s-e eh t-s-ee
SWEFIN		rsg tg -peg		g-e2:			g-e:			g-ee
SWEFIN		deltay			y2:			y:			yy
SWEFIN		sb			s-b-e2:			s-b-e:			s-b-ee
SWEFIN		cz			tj3			t-C			ch

SWEFIN		-b -hib iib 1b apob 2b	b-e2:			b-e:			b-ee
SWEFIN		-hb -fosb			b-e2:			b-e:			b-ee
SWEFIN		-c 1c deltac hempc -wc	s-e2:			s-e:			s-ee
SWEFIN		abc tbc			s-e2:			s-e:			s-ee
SWEFIN		-d -cd -bd -id -vd 5d	d-e2:			d-e:			d-ee
SWEFIN		-dvd			d-e2:			d-e:			d-ee
SWEFIN		hfatwaid			d-e2:			d-e:			d-ee
SWEFIN		-g -ekg -eeg		g-e2:			g-e:			g-ee
SWEFIN		-h -msh -acth		h-å2:			h-o:			h-oo
SWEFIN		-i			i2: e-t			i: e-t			ii e-t
SWEFIN		-ii ii			t-v-å2: i2:		t-v-o: i:			t-v-oo ii
SWEFIN		-iii			t-r-e2:			t-r-e:			t-r-ee
SWEFIN		iii			t-r-e2:-d-j-ë t-r-e2:	t-r-e:-d-j-@ t-r-e:		t-r-ee-d-j-eh t-r-ee
SWEFIN		iiia			r-e2:-a2:			r-e:-A:			r-ee-aa
SWEFIN		-iv dsmiv			f-y2:-r-a			f-y:-r-a			f-yy-r-a
SWEFIN		dsmv			f-e-m			f-e-m			f-e-m
SWEFIN		-ifk -aik			k-å2:			k-o:			k-oo
SWEFIN		-p -cpap folp deltap	p-e2:			p-e:			p-ee
SWEFIN		gp -cp -alp		p-e2:			p-e:			p-ee
SWEFIN		-q			k-u2:			k-}:			k-oo
SWEFIN		-t -rmt -dht -gt		t-e2:			t-e:			t-ee
SWEFIN		-v			v-e2: f-e-m		v-e: f-e-m		v-ee f-e-m
SWEFIN		wc			s-e2:			s-e:			s-ee
SWEFIN		-htlv -kv -mcv		v-e2:			v-e:			v-ee

#**********************************************************************************************************************************************************#
# Name		Letters			Phones MTM		Phones Acapela		Phones Cereproc
#**********************************************************************************************************************************************************#
SWEACR		a A			a2:			A:			aa
SWEACR		o O			o2:			u:			uu
SWEACR		u U			u2:			}:			uux
SWEACR		å Å			å2:			o:			oo
SWEACR		e E			e2:			e:			ee
SWEACR		i I			i2:			i:			ii
SWEACR		y Y			y2:			y:			yy
SWEACR		ä Ä			ä2:			E:			eex
SWEACR		ö Ö			ö2:			2:			oox
SWEACR		b B			b-e2:			b-e:			b-ee
SWEACR		c C			s-e2:			s-e:			s-ee
SWEACR		d D			d-e2:			d-e:			d-ee
SWEACR		f F			ä-f			E-f			e-f
SWEACR		g G			g-e2:			g-e:			g-ee
SWEACR		h H			h-å2:			h-o:			h-oo
SWEACR		j J			j-i2:			j-i:			j-ii
SWEACR		k K			k-å2:			k-o:			k-oo
SWEACR		l L			ä-l			E-l			e-l
SWEACR		m M			ä-m			E-m			e-m
SWEACR		n N			ä-n			E-n			e-n
SWEACR		p P			p-e2:			p-e:			p-ee
SWEACR		q Q			k-u2:			k-}:			k-oo
SWEACR		r R			ä3-r			{-r			ae-r
SWEACR		s S			ä-s			E-s			e-s
SWEACR		t T			t-e2:			t-e:			t-ee
SWEACR		v V			v-e2:			v-e:			v-ee
SWEACR		w W			v-e2: d-u-b-ë-l-v-e2:	v-e: d-u-b-@-l-v-e:		v-ee d-ux-b-eh-l-v-ee
SWEACR		x X			ä-k-s			E-k-s			e-k-s
SWEACR		z Z			s-ä2:-t-a			s-E:-t-a			s-eex-t-a
SWEACREND		s			s			s			s
SWEACREND		n			n			n			n
SWEACREND		t			t			t			t

#**********************************************************************************************************************************************************#
# Name		Letters			Phones MTM		Phones Acapela		Phones Cereproc
#**********************************************************************************************************************************************************#
ENGINI		a			ei ä3 a a2: å2:		e-j { a A: o:		e-j ae a aa oo
ENGINI		o			öw å å2:			2-U O o:			ou oo o
ENGINI		u			j-u4: a			j-u: a			j-uu a
ENGINI		e			i2: i e ë			i: I e @			ii i e eh
ENGINI		i			ai i			a-j I			a-j i
ENGINI		y			i j			I j			i j
ENGINI		ch			tj3 k tj			tS k_h k			ch k c
ENGINI		b			b			b			b
ENGINI		c			s k			s k_h k			s k
ENGINI		d			d			d			d
ENGINI		f ph			f			f			f
ENGINI		g			g j3			g dZ			g jh
ENGINI		h			h			h			h
ENGINI		j			j3			dZ			jh
ENGINI		k			k tj			k_h k C			k
ENGINI		l			l rl			l rl			l	
ENGINI		m			m			m			m
ENGINI		n kn			n			n			n
ENGINI		p			p			p_h p			p
ENGINI		q			k			k			k
ENGINI		r			r			r			rh
ENGINI		s			s rs			s rs			s rs
ENGINI		t			t rt			t_h t rt			t
ENGINI		v			v			v			v
ENGINI		x			k-s s			k-s s			k-s s
ENGINI		z			s z			s z			s z
ENGINI		ea			i2: ö3:			i: 9:			ii ooe
ENGINI		th			th dh			T D			th dh
ENGINI		un			a-n j-u4 j-u4:		a-n j-U j-}: j-u:		a-n j-ux j-uu
ENGINI		ei			ei			e j			e-j
ENGINI		eu			j u4:			j u:			j uu
ENGINI		ai			ei			e-j			e-j
ENGINI		air			eë			}:-r			ae-r
ENGINI		ou			öw			a-U			ou
ENGINI		ey			ai			a-j			a-j
ENGINI		any			e-n-i			e-n-I			e-n-i
ENGINI		up			a-p			a-p			a-p
ENGINI		hour			au-ë			a-U-@			au-eh
ENGINI		au			å2:			o:			oo
#**********************************************************************************************************************************************************#
1;
