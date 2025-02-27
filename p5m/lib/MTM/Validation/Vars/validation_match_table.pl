package MTM::Validation::Vars::validation_match_table;

# SBTal boilerplate
use strict;
use utf8;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?
use charnames   qw< :full :short >;    # autoenables in v5.16 and above
use feature     qw< unicode_strings >;
no feature      qw< indirect >;      
use feature     qw< signatures >;
no warnings     qw< experimental::signatures >;
# END SBTal boilerplate

package MTM::Validation::Vars::validation_match_table;													
													
# SBTal boilerplate													
use strict;													
use utf8;													
use autodie;													
use warnings;													
use warnings    qw< FATAL  utf8 >;													
use open        qw< :std  :utf8 >;     # Should perhaps be :encoding(utf-8)?													
use charnames   qw< :full :short >;    # autoenables in v5.16 and above													
use feature     qw< unicode_strings >;													
no feature      qw< indirect >;      													
use feature     qw< signatures >;													
no warnings     qw< experimental::signatures >;													
# END SBTal boilerplate													
													
#**********************************************************************************************************************************************************#													
# Name		Letters		Phones MTM			Phones TPA		Phones Acapela		Phones Cereproc		
#**********************************************************************************************************************************************************#													
SWEINI		a		a: a an ae e-j			a2: a an ä3 e-j		a aa A: a~ { E-j		aa a an ae e-j		
SWEINI		o		u: u oh o on			o2: o o3 å on		u: U O o~			uu u o on	
SWEINI		u		uu: uu uuh u			u2: u u3 o		}: u U			uux ux u	
SWEINI		å		o: o oh			å2: å o3			o: O			oo o u
SWEINI		e		e: e ä ex eh i:			e2: e ä ë e3 i2:		e: e E {: { @		ee e e eh ii		
SWEINI		i		i: i en			i2: i i3 en		i: I e~			ii i in	
SWEINI		y ü		y: y			y2: y			y: Y			yy y
SWEINI		ä		e: e ä: ä ae: ae			e2: e ä2: ä ä3: ä3		E: E {: { e		ee e eex aae ae		
SWEINI		ö		ö: ö oe: oe			ö2: ö ö3: ö3		2: 2 9: 9			oox ox ooe oe	
SWEINI		stj sj		x			sj			S			x
SWEINI		sch		rs x s-k			rs sj s-k			rs S s-k			rs x s-k
SWEINI		sh		rs x			rs sj			rs S			rs x
SWEINI		sk		x s-k			sj s-k			S s-k			x s-k
SWEINI		tj		c tc			tj tj3			C tS			c ch
SWEINI		ch		c tc rs x k			tj tj3 rs sj k		C tS rs S k_h k		c ch rs x k		
SWEINI		b		b			b			b			b
SWEINI		c		s k c			s k tj			s k_h k C			s k c
SWEINI		cs cz		tc			tj3			tS			ch
SWEINI		d		d rd			d rd			d rd			d rd
SWEINI		f		f			f			f			f
SWEINI		g		g j			g j			g j			g j
SWEINI		h		h			h			h			h
SWEINI		j		j dj x d-j			j j3 sj d-j		j S dZ d-j		j jh x d-j		
SWEINI		lj hj gj		j			j			j			j
SWEINI		dj		j d-i: d-j			j d-i2: d-j		j d-i: d-j		j d-ii d-j		
SWEINI		k		k c			k tj			k_h k C			k c
SWEINI		l		l rl			l rl			l rl			l rl
SWEINI		m		m			m			m			m
SWEINI		n		n			n			n			n
SWEINI		p		p			p			p_h p			p
SWEINI		ph		f p			f p			f p_h p			f p
SWEINI		q		k			k			k			k
SWEINI		r		r			r			r			r
SWEINI		s		s rs			s rs			s rs			s rs
SWEINI		t		t rt			t rt			t_h t rt			t rt
SWEINI		v		v f			v f			v f			v f
SWEINI		x		k-s s			k-s s			k-s s			k-s s
SWEINI		z		s z t-s			s z t-s			s z t-s			s z t-s
													
SWEINI		aa		a: a o:			a2: a å2:			A: a o:			aa a oo
SWEINI		ae		ae: ae ä e: e			ä3: ä3 ä e2: e		}: } E e: e		aae ae e ee		
SWEINI		ai		a-j ä-j ae: e			a-j ä-j ä3: e		a-j E-j }: E		a-j e-j aae e		
SWEINI		au		au o: o oh			au å2: å o3		a-U o: O			au oo o u	
SWEINI		aug		au o: a:			au å2: a2:		a-U o: A:			au oo aa	
SWEINI		action		ae-k			ä3-k			{-k-			ae-k
SWEINI		ambient		e-j-m			e-j-m			e-j-m			e-j-m
SWEINI		amy		e-j-m a-m-i a-m-y			e-j-m a-m-i a-m-y		e-j-m a-m-I a-m-Y		e-j-m a-m-i a-m-y		
SWEINI		age		e-j a: a			e-j a2: a			e-j A: a			e-j aa a
SWEINI		all		a-l o:-l			a-l å2:-l			a-l			a-l oo-l
SWEINI		ea		oe: i:			ö3: i2:			9: i:			ooe ii
SWEINI		ei		a-j ä-j e-j			a-j ä-j e-j		a-j e-j			a-j e-j	
SWEINI		en		e:-n ä-n e-n e-ng eh-n a-ng			e2:-n ä-n e-n e-ng e3-n a-ng	e:-n E-n a-N		ee-n e-n e-ng a-ng			
SWEINI		ent		e-n-t a-ng-t e:-n-t			e-n-t a-ng-t e2:-n-t	e-n-t a-ng-t e:-n-t		e-n-t a-ng-t ee-n-t			
SWEINI		er		e:-r ä-r e-r ae-r ae:-r			e2:-r ä-r e-r ä3-r ä3:-r	e:-r E-r }-r }:-r		ee-r e-r ae-r aae-r			
SWEINI		eu		eu e-v e:-uu:			eu e-v e2:-u2:		E-v e:-}:			eu e-v ee-uux	
SWEINI		eye		a-j			a-j			a-j			a-j
SWEINI		eng		e-ng a-ng e:-n-g e:-n-j			e-ng a-ng e2:-n-g e2:-n-j	e-ng a-ng e:-n-g e:-n-j	e-ng a-ng ee-n-g ee-n-j				
SWEINI		ia		i:-a j-a i-a			i2:-a j-a i-a		i:-a j-a I-a		ii-a j-a i-a		
SWEINI		ic		a-j			a-j			a-j			a-j
SWEINI		ich ict		i			i			I			i
SWEINI		ick		i-k			i-k			I-k			i-k
SWEINI		ing		i-ng ä-ng i-n-g i-n-x i-n-j			i-ng ä-ng i-n-g i-n-sj i-n-j	I-N e-N I-n-g I-n-S I-n-j	i-ng e-ng i-n-g i-n-x i-n-j				
SWEINI		iu		j			j			j			j
SWEINI		io		i: j			i2: j			i: j			ii j
													
SWEINI		iTunes itunes iOS		a-j		a-j			a-j			a-j	
SWEINI		iPhone iphone		a-j		a-j			a-j			a-j	
SWEINI		iPad iPod ipad ipod		a-j		a-j			a-j			a-j	
SWEINI		oa		u: o w ou			o2: o w öw		u: U w 2-U		uu u w ou		
SWEINI		oe		u: ö: oe: o: ä			o2: ö2: ö3: å2: ä		u: 2: 9: o: E		uu oox ooe oo e		
SWEINI		oeso		ä			ä			E			e
SWEINI		old		ou u: o			öw o2: å			2-U u: O			ou uu o
SWEINI		one		u: oh u o: o w-a-n			o2: o3 o å2: å w-a-n	u: U o: O w-a-n		uu u oo o w-a-n			
SWEINI		ou		u: u oh au			o2: o o3 au		u: U a-U			uu u au	
SWEINI		over		ou u: o oh			öw o2: å o3		2-U u: O			ou uu o u	
SWEINI		open		ou u:			öw o2:			2-u u:			ou uu
SWEINI		th		th dh t d			th dh t d			T D t d			th dh t d
SWEINI		under		uu-n-d a-n-d			u-n-d a-n-d		u-n-d a-n-d		ux-n-d a-n-d		
SWEINI		upper		uu-p a-p			u-p a-p			u-p a-p			ux-p a-p
SWEINI		unit		uu: uuh u j-uu:			u2: u3 u j-u2:		}: u j-}:			uux ux j-uux	
SWEINI		ya ye yi yo yu		j		j			j			j	
													
SWEINI		cier		s-i-e: ex-r			s-i-e2: ë-r		s-I-e: @-r		s-i-ee eh-r		
SWEINI		cemb		c-ä-m s-ä-m			tj-ä-m s-ä-m		C-e-m s-e-m		c-e-m s-e-m		
SWEINI		emb		e-m-b a-m-b			e-m-b a-m-b		e-m-b a-m-b		e-m-b a-m-b		
SWEINI		dz		dj			j3			dZ			jh
SWEINI		ge		x j g rs			sj j g rs			S j g rs			x j g rs
SWEINI		gi		x g j			sj g j			sj g j			x g j
SWEINI		fm		ä-f			ä-f			E-f			e-f
SWEINI		hm hl		x			sj			S			x
SWEINI		mp mr ms mt mT		ä-m		ä-m			E-m			e-m	
SWEINI		haut		h-o:			h-å2:			h-o:			h-oo
SWEINI		tarte		r-t			r-t			r-t			r-t
SWEINI		hie		h j			h j			h j			h j
SWEINI		hv hw		v			v			v			v
SWEINI		kn		k-n n k			k-n n k			k_h-n n			k-n n k
SWEINI		liu lif-		j uu:			j u2:			j }:			j-uux
SWEINI		mc		m-a-k m-ae-k ä-m-s-e:			m-a-k m-ä3-k ä-m-s-e2:	m-A-k E-m-s-e:		m-a-k m-ae-k e-m			
SWEINI		qi		k c			k tj			k C			k-c
SWEINI		ps		p-s s p-e:-ä-s			p-s s p-e2:-ä-s		p-s s p_h-e:-E-s		p-s s p-ee-e-s		
SWEINI		tion		t x			t sj			t S			t x
SWEINI		xh		k			k			k			k
SWEINI		xi		c k-s-i			tj k-s-i			C k-s-i			c k-s-i
SWEINI		zj		rs			rs			rs			rs
SWEINI		rn rN rAA- raa-		ae-r		ä3-r			{-r			ae-r	
SWEINI		rS- rs-		ae-r			ä3-r			{-r			ae-r
SWEINI		iia		a			a			a			a
													
SWEINI		a- adl- ards- auf- aik-		a:	a2:			A:			aa		
SWEINI		b- bmi-		b-e:			b-e2:			b-e:			b-ee
SWEINI		c- cf- csun- cul- cv- csn		s-e:	s-e2:			s-e:			s-ee		
SWEINI		d- dna-		d-e:			d-e2:			d-e:			d-ee
SWEINI		e-mail		i:-m			i2:-m			i:-m			ii-m
SWEINI		e- eu- eu15- ees- eg-		e:	e2:			e:			ee		
SWEINI		ep- ean- emu- enp erk-		e:	e2:			e:			ee		
SWEINI		f- f: fn- fln- fou-		ä-f		ä-f			E-f			e-f	
SWEINI		fbi fxa- fv fud- f1		ä-f		ä-f			E-f			e-f	
SWEINI		ft- fev1 fft- fra- fec-		ä-f	ä-f			E-f			e-f		
SWEINI		fvi fc- fta- ff- fgp-		ä-f	ä-f			E-f			e-f		
SWEINI		h- hm- hls- hv- hla-		h-o:	h-å2:			h-o:			h-oo		
SWEINI		hmg-		h-o:			h-å2:			h-o:			h-oo
SWEINI		hbo-		e-j-dj-b-ii-ou			e-j-j3-b-ii-öw		E-j			e-j-jh-b-ii-ou	
SWEINI		i-		i: e-t			i2: e-t			i: E-t			ii e-t
SWEINI		iu- icd- icf- icp- ica-		i:	i2:			i:			ii		
SWEINI		ii-		t-v-o:			t-v-å2:			t-v-o:			t-v-oo
SWEINI		ii		i: t-v-o: j			i2: t-v-å2: j		i: t-v-o: j		ii t-v-oo		
SWEINI		iii		t-r-e:			t-r-e2:			t-r-e:			t-r-ee
SWEINI		iv-		f-y:-r-a			f-y2:-r-a			f-y:-r-a			f-yy-r-a
SWEINI		xii-		t-o-l-f-t-ex			t-å-l-f-t-ë		t-O-l-f-t-@		t-o-l-f-t-eh		
SWEINI		j- j:		j-i:			j-i2:			j-i:			j-ii
SWEINI		k- k:		k-o:			k-å2:			k-o:			k-oo
SWEINI		l- l: lp lr lt lo- lvm-		ä-l	ä-l			E-l			e-l		
SWEINI		lbu- lca- LO- lvu- lss-		ä-l	ä-l			E-l			e-l		
SWEINI		lip- la- lchf- ll- ldl-		ä-l	ä-l			E-l			e-l		
SWEINI		lhpa- lkg- lf		ä-l		ä-l			E-l			e-l	
SWEINI		m- m: mms mhk- mfr-		ä-m		ä-m			E-m			e-m	
SWEINI		mi- mr- mit- mvc-		ä-m		ä-m			E-m			e-m	
SWEINI		mai- mrt mic- mns-		ä-m		ä-m			E-m			e-m	
SWEINI		mls- mct-		mf mmi mma-	mf mmi mma-	ä-m			E-m			e-m	
SWEINI		mao- mu- ml-		ä-m m		ä-m m			E-m m			e-m m	
SWEINI		n- n: ngo nih- nk- no-		ä-n	ä-n			E-n			e-n		
SWEINI		nrk- nu- nv- nvq- nds-		ä-n	ä-n			E-n			e-n		
SWEINI		na- nph- nrg nbk- nmr-		ä-n	ä-n			E-n			e-n		
SWEINI		nsaid- nace- nhl- nt ncis		ä-n	ä-n			E-n			e-n		
SWEINI		nbc ncc		ä-n			ä-n			E-n			e-n
SWEINI		ng-		ä-ng			ä-ng			E-ng			e-ng
SWEINI		o-		u:			o2:			u:			uu
SWEINI		p- ph- psa- psi-		p-e:		p-e2:			p_h-e:			p-ee	
SWEINI		r: r- rf rh- rem- rm-		ae-r	ä3-r			{-r			ae-r		
SWEINI		rps- rhd- rpe- rct-		ae-r		ä3-r			{-r			ae-r	
SWEINI		s- s: sms sos- ss-		ä-s		ä-s			E-s			e-s	
SWEINI		sp- sr- sfi- sm- se-		ä-s	ä-s			E-s			e-s		
SWEINI		sbic- sli- slu- sg-		ä-s		ä-s			E-s			e-s	
SWEINI		sme- so- si- sns- shl-		ä-s	ä-s			E-s			e-s		
SWEINI		sou- svr- sce- snri-		ä-s	ä-s			E-s			e-s		
SWEINI		scd- ssu- svt- st-		ä-s		ä-s			E-s			e-s	
SWEINI		sbk- sbu- scid- scl-		ä-s	ä-s			E-s			e-s		
SWEINI		sd snr- ssri- su-		ä-s		ä-s			E-s			e-s	
SWEINI		svr sry- sf- stm sga-		ä-s	ä-s			E-s			e-s		
SWEINI		sfs- sia- slc srebp		ä-s		ä-s			E-s			e-s	
SWEINI		spd sru ssab		ä-s		ä-s			E-s			e-s	
SWEINI		t-		t-e: t-i:			t-e2: t-i2:		t-e: t-i:			t-ee t-ii	
SWEINI		u-		uu:			u2:			}:			uux
SWEINI		up-		a-p			a-p			a-p			a-p
SWEINI		v-		v-e:			v-e2:			v-e:			v-ee
SWEINI		w-		d-u-b-ex-l-v-e:			d-u-b-ë-l-v-e2: v-e2:	d-u-b-@-l-v-e: v-e:		d-ux-b-eh-l-v-ee			
SWEINI		x: xg- xo- xy- xt xb xk		ä-k-s	ä-k-s			E-k-s			e-k-s		
SWEINI		xxx- xxy- xyy-		ä-k-s		ä-k-s			E-k-s			e-k-s	
SWEINI		x- xm		ä-k-s			ä-k-s			E-k-s			e-k-s
SWEINI		y- ya- yif-		y:		y2:			y:			yy	
SWEINI		z-		s-ä:-t-a			s-ä2:-t-a			s-E:-t-a			s-eex-t-a
SWEINI		å-		o:			å2:			o:			oo
SWEINI		ä-		ä:			ä2:			E:			eex
SWEINI		ö-		ö:			ö2:			2:			oox
													
#**********************************************************************************************************************************************************#													
# Name		Letters		Phones MTM			Phones MTM		Phones Acapela		Phones Cereproc		
#**********************************************************************************************************************************************************#													
SWEFIN		a		a a: aa:			a a2: a3:			a A: aa			a aa aah
SWEFIN		o		u: u o o:			o2: o å å2:		u: U O o:			uu u oo o	
SWEFIN		u		uu: uu uuh u u:			u2: u u3 o o2:		}: u u:			uux ux uu u	
SWEFIN		å		o: o			å2: å			o: O			oo o
SWEFIN		e		e: ex			e2: ë			e: @			ee eh
SWEFIN		i		i: i			i2: i			i: I			ii i
SWEFIN		y		y: y i			y2: y i			y: Y			yy y i
SWEFIN		ä		e: e ä: ä			e2: e ä2: ä		E: E e			ee e eex	
SWEFIN		ö		ö:			ö2:			2:			oox
													
SWEFIN		b		b			b			b			b
SWEFIN		c		k s			k s			k s			k s
SWEFIN		d		d t			d t			d t			d t
SWEFIN		f		f v			f v			f v			f v
SWEFIN		g		g k			g k			g k			g k
SWEFIN		h		rs			rs			rs			rs
SWEFIN		j		j			j			j			j
SWEFIN		k		k			k			k			k
SWEFIN		l		l			l			l			l
SWEFIN		m		m			m			m			m
SWEFIN		n		n			n			n			n
SWEFIN		p		p p-e:			p p-e2:			p p-e:			p p-ee
SWEFIN		q		k			k			k			k
SWEFIN		r		r			r			r			r
SWEFIN		s		s			s			s			s
SWEFIN		t		t			t			t			t
SWEFIN		v		v			v			v			v
SWEFIN		x		k-s			k-s			k-s			k-s
SWEFIN		z		s z			s z			s z			s z
													
SWEFIN		ha aa aaa		a a: aa:			a a2: a3:			a A: aa			a aa aah
SWEFIN		jf jjf		j-f v			j-f v			j-f v			j-f v
SWEFIN		ch		tc rs k x c			tj3 rs k sj tj		tS rs k			ch rs k x c	
SWEFIN		tj		tc			tj3			tS			ch
SWEFIN		dt		d t			d t			d t			d t
SWEFIN		sch		rs			rs			rs			rs
SWEFIN		tch		rt-rs tc			rt-rs tj3			rt-rs tS			rt-rs ch
SWEFIN		age		a:-rs a:-g-ex a-j-e: a-g-ex			a2:-rs a2:-g-ë a-j-e2: a-g-ë	A:-rs A:-g-@ a-j-e: a-g-@	aa-rs aa-g-eh a-j-ee a-g-eh				
SWEFIN		oge		u:-g-ex o:-rs o:-g-ex o-g-ex j-e:			o2:-g-ë å2:-rs å2:-g-ë o-g-ë j-e2:	u:-g-@ o:-rs o:-g-@ U-g-@ j-e:	uu-g-eh oo-rs oo-g-eh u-g-eh j-ee				
SWEFIN		ege		j-e: ex e:-rs i-dj			j-e2: ë e2:-rs i-j3		j-e: @ e:-rs I-dZ		j-ee eh ee-rs i-jh		
SWEFIN		dge		dj j-e:			j3 j-e2:			dZ j-e:			jh j-ee
SWEFIN		ei		i: i e-j			i2: i e-j			i: I e-j			ii i e-j
SWEFIN		eh		e e: ex			e e2: ë			e e: @			ee e eh
SWEFIN		crème créme creme		k-r-ä:-m		k-r-ä2:-m			k-r-E:-m			k-r-eex-m	
SWEFIN		äh ä3		ä:			ä2:			E:			eex
SWEFIN		ee		i: e: ex i			i2: e2: ë i		i: e: @ I			ii ee eh i	
SWEFIN		th		t th			t th			t T			t th
SWEFIN		nh		n			n			n			n
SWEFIN		ng		ng			ng			N			ng
SWEFIN		dh		d			d			d			d
SWEFIN		ão		au			au			a-U			au
SWEFIN		gh		g			g			g			g
SWEFIN		igh		i i-g i: g			i i-g i2: g		I I-g i:-g		i i-g ii-g		
SWEFIN		tjstj		rs-rt-rs			rs-rt-rs			rs-rt-rs			rs-rt-rs
SWEFIN		ph		f			f			f			f
SWEFIN		ice		a-j-s i-s i-k-ex i:-s-ex			a-j-s i-s i-k-ë i2:-s-ë	a-j-s I-s I-k-@ i:-s-@	a-j-s i-s i-k-eh ii-s-eh				
SWEFIN		cte		k-t-ex k-t			k-t-ë k-t			k-t-@ k-t			k-t-eh k-t
SWEFIN		ance		a-n-s a-n-s-ex			a-n-s a-n-s-ë		a-n-s a-n-s-@		a-n-s a-n-s-eh		
SWEFIN		ig		i-g i i:-g ä-j			i-g i i2:-g ä-j		I-g i:-g E-j		i-g ii-g e-j		
SWEFIN		igt		i-t i:-k-t			i-t i2:-k-t		I-g-t i:-k-t		i-t ii-k-t		
SWEFIN		iga		i-a i-g-a i:-g-a			i-a i-g-a i2:-g-a		I-g-a i:-g-a		i-g-a ii-g-a		
SWEFIN		ij		i-j i:			i-j i2:			I-j i:			i-j ii
SWEFIN		eij		e-j			e-j			e-j			e-j
SWEFIN		aiga		a-j-g-a a:-i-a			a-j-g-a a2:-i-a		a-j-g-a A:-I-g-a		a-j-g-a		
SWEFIN		aigas		a-j-g-a-s			a-j-g-a-s			a-j-g-a-s			a-j-g-a-s
SWEFIN		ige		i-ex i:-j-e: i:-g-ex i:-rs			i-ë i2:-j-e2: i2:-g-ë i2:-rs	I-g-@ i:-j-e: i:-g-@ i:-rs	i-g-eh ii-j-ee ii-g-eh ii-rs				
SWEFIN		igs		i-s i:-g-s i-g-s			i-s i2:-g-s i-g-s		I-g-s i:-g-s		i-g-s ii-g-s		
SWEFIN		igts		i-t-s i:-k-t-s			i-t-s i2:-k-t-s		I-g-t-s i:-k-t-s		i-t-s ii-k-t-s		
SWEFIN		igas		i-a-s i-g-a-s i:-g-a-s			i-a-s i-g-a-s i2:-g-a-s	I-g-a-s i:-g-a-s		i-g-a-s ii-g-a-s			
SWEFIN		iges		i-ex-s i:-j-e:-s i:-g-ex-s i:-rs-s			i-ë-s i2:-j-e2:-s i2:-g-ë-s i2:-rs-s	I-g-@-s i:-j-e:-s i:-g-@-s i:-rs-s	i-g-eh-s ii-j-ee-s ii-g-eh-s ii-rs-s				
SWEFIN		oy		j			j			j			j
SWEFIN		ere ère		ex ae:-r			ë ä3:-r			ë {:-r			eh ae-r
SWEFIN		ache		rs a-k-ex			rs a-k-ë			rs a-k-@			rs a-k-eh
SWEFIN		aue		au-ex			au-ë			a-U-@			au-eh
SWEFIN		aise aisse ousse		s		s			s			s	
SWEFIN		gourmet		e:			e2:			e:			ee
SWEFIN		rg		r-j r-g			r-j r-g			r-j r-g			r-j r-g
SWEFIN		åh		o:			å2:			o:			oo
SWEFIN		uh		uu:			u2:			}:			uux
SWEFIN		lg		l-j			l-j			l-j			l-j
SWEFIN		onge		ng-rs ng-ex			ng-rs ng-ë		N-rs N-@			ng-rs ng-eh	
SWEFIN		uice		u:-s			o2:-s			u:-s			uu-s
SWEFIN		ent		ex-n-t a-ng ä-n-t e:-n-t			ë-n-t a-ng ä-n-t e2:-n-t	@-n-t a-N E-n-t e:-n-t	eh-n-t a-ng e-n-t ee-n-t				
SWEFIN		ot		o-t u-t u:-t o:-t o:			å-t o-t o2:-t å2:-t å2:	O-t U-t u:-t o:-t o:	o-t u-t uu-t oo-t oo				
SWEFIN		euse		ö:-s			ö2:-s			2:-s			oox-s
SWEFIN		che		ex rs			ë rs			@ rs			eh rs
SWEFIN		ette otte		ex t			ë t			@ t			eh t
SWEFIN		eige		rs e:-i-ex			rs e2:-i-ë		rs e:-I-g-@		rs ee-i-g-eh		
SWEFIN		eiges		rs-s e:-i-ex-s			rs-s e2:-i-ë-s		rs-s e:-I-g-@-s		rs-s ee-i-g-eh-s		
SWEFIN		eiga		rs-a e:-i-a			rs-a e2:-i-a		rs-a e:-I-g-a		rs-a ee-i-g-a		
SWEFIN		lais		l-ä:			l-ä2:			l-E:			l-eex
SWEFIN		ene		e:-n-ex e:-n ex-n-ex			e2:-n-ë e2:-n ë-n-ë		e:-n-@ e:-n @-n-@		ee-n-eh ee-n eh-n-eh		
SWEFIN		karl		k-a:-r k-a:-rl			k-a2:-r k-a2:-rl		k-A:-r k-A:-rl		k-aa-r k-aa-rl		
SWEFIN		ai oj		j			j			j			j
SWEFIN		ay		ä-j e-j a-j ä:			ä-j e-j a-j ä2:		e-j E-j a-j E:		e-j a-j eex		
SWEFIN		use		ex y-s			ë y-s			@ Y-s			eh y-s
SWEFIN		aubade		a:-d			a2:-d			A:-d			aa-d
SWEFIN		ine		n-ex i:-n i-n a-j-n			n-ë i2:-n i-n a-j-n		n-@ i:-n I-n a-j-n		n-eh ii-n i-n a-j-n		
SWEFIN		verkstad		v-ae-r-k-s-t-a			v-ä3-r-k-s-t-a		v-{-r-k-s-t-a		v-ae-r-k-s-t-a		
SWEFIN		garde		g-a-r-d g-a:-rd-ex			g-a-r-d g-a2:-rd-ë		g-a-r-d g-A:-rd-@		g-a-r-d g-aa-rd-eh		
SWEFIN		gle		ex g-ex-l			ë g-ë-l			@ g-@-l			eh g-eh-l
SWEFIN		ble		b-ex-l b-l-ex			b-ë-l b-l-ë		b-@-l b-l-@		b-eh-l b-l-eh		
SWEFIN		uine		i-n i:-n-ex			i-n i2:-n-ë		I-n i:-n-@		i-n ii-n-eh		
SWEFIN		uide		a-j-d i:-d-ex			a-j-d i2:-d-ë		a-j-d i:-d-@		a-j-d ii-d-eh		
SWEFIN		tide		d-ex d			d-ë d			d-@ d			d-eh d
SWEFIN		genre		x-a-ng-ex-r			sj-a-ng-ë-r		S-a-N-@-r			x-a-ng-eh r	
SWEFIN		ier		ex-r j-e: i:-r			ë-r j-e2: i2:-r		@-r j-e: i:-r		eh-r j-ee ii-r		
SWEFIN		ouson		å-ng			å-ng			O-N			o-ng
SWEFIN		ou		u:			o2:			u:			uu
SWEFIN		gne		n-j ng-n-ex g-n-ex j-n-ex			n-j ng-n-ë g-n-ë j-n-ë	n-j N-n-@ g-n-@ j-n-@	n-j ng-n-eh g-n-eh j-n-eh				
SWEFIN		onne		ex o-n			ë å-n			@ O-n			eh o-n
SWEFIN		que		k			k			k			k
SWEFIN		quet		k-e:			k-e2:			k-e:			k-ee
SWEFIN		ie		i-ex i: i i3-ex i:-ex			i-ë i2: i i3-ë i2:-ë	I-@ i: I I-@ i:-@ j-@	i-eh ii i ii-eh j-eh				
SWEFIN		gue		g g-ex			g g-ë			g g-@			g g-eh
SWEFIN		ozo		o: o			å2: o			o: O U			oo o u
SWEFIN		oisie		i:			i2:			i:			ii
SWEFIN		ois		o:-i-s oh-aa:			o:-i-s o3-a3:		u:-I-s u-aa		uu-i-s u-aah		
SWEFIN		lait		l-ä:			l-ä2:			l-E:			l-eex
SWEFIN		fait		f-ä:			f-ä2:			f-E:			f-eex
SWEFIN		bert		b-ae:-r b-ex-rt			b-ä3:-r b-ë-rt		b-{:-r b-{-rt		b-aae-r b-ae-rt		
SWEFIN		centime		m			m			m			m
SWEFIN		choke		k			k			k			k
SWEFIN		oi		å-j			å-j			O-j			o-j
SWEFIN		on		n ng			n ng			n N			n ng
SWEFIN		oh		u: o:			o2: å2:			u: o:			uu oo
SWEFIN		eau aux		o:			å2:			o:			oo
SWEFIN		ore		o:-r r-eh			å2:-r r-eh		o:-r r-@			oo-r r-eh	
SWEFIN		eigh		e-j			e-j			e-j			e-j
SWEFIN		sjtj		tc			tj3			tS			ch
SWEFIN		ive		ex a-j-v			ë a-j-v			@ a-j-v			eh a-j-v
SWEFIN		sin		n ng			n ng			n N			n ng
SWEFIN		byte		b-y:-t-ex b-a-j-t			b-y2:-t-ë b-a-j-t		b-a-j-t b-y:-t-@		b-yy-t-eh b-a-j-t		
SWEFIN		ose		ex e: o:-s			ë e2: å2:-s		@ e: o:-s			eh ee oo-s	
SWEFIN		tv		t-e:-v-e:			t-e2:-v-e2:		t-e:-v-e:			t-ee-v-ee	
SWEFIN		sverige		r-j-ex			r-j-ë			r-j-@			r-j-eh
SWEFIN		feature		f-i:-tc-ex-r			f-i2:-tj3-ë-r		f-i:-tj3-@-r		f-ii-ch-e-r		
SWEFIN		konsert koncert		s-ae:-r		s-ä3:-r			s-{:-r			s-aae-r	
SWEFIN		dessert		s-ae:-r			s-ä3:-r			s-{:-r			s-aae-r
SWEFIN		lore		r			r			r			r
SWEFIN		ue		y:			y2:			y:			yy
SWEFIN		dag		d-a:-g d-a			d-a2:-g d-a		d-A:-g d-a		d-aa-g d-a		
SWEFIN		rh		r			r			r			r
SWEFIN		kh		k			k			k			k
SWEFIN		kuvert		k-uuh-v-ae:-r			k-u3-v-ä3:-r		k-u-v-{:-r		k-ux-v-aae-r		
SWEFIN		serve		s-oe-r-v			s-ö3-r-v			s-9-r-v			s-oe-r-v
SWEFIN		säg		s-ä-j			s-ä-j			s-E-j			s-e-j
SWEFIN		orange		rn-rs			rn-rs			rn-rs			rn-rs
SWEFIN		sj		rs			rs			rs			rs
SWEFIN		ey		e-j y i ex-j			e-j y i ë-j		E-j Y I @-j		e-j y i eh-j		
SWEFIN		enne		ä-n ex			ä-n ë			E-n @			e-n eh
SWEFIN		elle		ä-l ex			ä-l ë			E-l @			e-l eh
SWEFIN		ecu		k-y:			k-y2:			k-y:			k-yy
SWEFIN		oule		u-l u:-l			o-l o2:-l			U-l u:-l			u-l uu-l
SWEFIN		ant		a-n-t a-ng a:-n-t			a-n-t a-ng a2:-n-t		a-n-t a-N A:-n-t		a-n-t a-ng aa-n-t		
SWEFIN		franc		f-r-a-ng			f-r-a-ng			f-r-a-N			f-r-a-ng
SWEFIN		ele		e:-l-ex e-l l-e: e-l-ex ex-l-ex			e2:-l-ë e-l l-e2: e-l-ë ë-l-ë	e:-l-@ E-l l-e: e-l-@ @-l-@	ee-l-eh e-l l-ee e-l-eh eh-l-eh				
SWEFIN		ille		i-l-ex i-l			i-l-ë i-l			I-l-@ I-l			i-l-eh i-l
SWEFIN		anne		a-n-ex a-n			a-n-ë a-n			a-n-@ a-n			a-n-eh a-n
SWEFIN		ence		e-n-s ex-n-s a:-n-s			e-n-s ë-n-s a2:-n-s		E-n-s @-n-s A:-n-s		e-n-s eh-n-s aa-n-s		
SWEFIN		aire		ae:-r			ä3:-r			{:-r			aae-r
SWEFIN		phe		f-ex f			f-ë f			f-@ f			f-eh f
SWEFIN		le		l-ex ex-l l-e:			l-ë ë-l l-e2:		l-@ @-l l-e:		l-eh eh-l l-ee		
SWEFIN		ao		au a-u: a:-u			au a-o2: a2:-o		a-U a-u: A:-u		au a-uu aa-u		
SWEFIN		krigs		k-r-i:-g-s k-r-i-k-s k-r-i-s			k-r-i2:-g-s k-r-i-k-s k-r-i-s	k-r-i:-g-s k-r-I-k-s k-r-I-s	k-r-ii-g-s k-r-i-k-s k-r-i-s				
SWEFIN		mande		m-a-n-d-ex m-a-n-d			m-a-n-d-ë m-a-n-d		m-a-n-d-@ m-a-n-d		m-a-n-d-eh m-a-n-d		
SWEFIN		de		d-ex d-å-m			d-ë d-å-m			d-@ d-O-m			d-eh d-o-m
SWEFIN		ide		d-e: d-ex			d-e2: d-ë			d-e: d-@			d-ee d-eh
SWEFIN		det		d-e: ex-t d-e:-t			d-e2: ë-t d-e2:-t		d-e:-t @-t		d-ee-t d-ee eh-t		
SWEFIN		jag		j-a:-g j-a:			j-a2:-g j-a2:		j-A:-g			j-aa j-aa-g	
SWEFIN		dig		i ä-j d-i			i ä-j d-i			I E-j d-I-g		i e-j d-i-g	
SWEFIN		med		m-e: m-e:-d m-ex-d			m-e2: m-e2:-d m-ë-d		m-e:-d m-@-d		m-ee m-ee-d m-eh-d		
SWEFIN		mycket		ex ex-t			ë ë-t			@ @-t			eh eh-t
SWEFIN		och		o: å-k			å2: å-k			O-k			o-k
SWEFIN		lade		d-ex l-a:			d-ë l-a2:			d-@			d-eh l-aa
SWEFIN		sade		d-ex s-a:			d-ë s-a2:			d-@			d-eh s-aa
SWEFIN		skall		s-k-a: l			s-k-a2: l			l			s-k-aa l
SWEFIN		vad		v-a-d v-a:-d v-a:			v-a-d v-a2:-d v-a2:		v-a-d v-A:-d		v-a-d v-aa-d v-aa		
SWEFIN		var		v-a-r v-a:-r v-a:			v-a-r v-a2:-r v-a2:		v-a-r v-A:-r		v-a-r v-aa-r v-aa		
SWEFIN		är		e: ae:-r			e2: ä3:-r			{:-r			ee aae-r
SWEFIN		yea		ä:			ä2:			E:			eex
SWEFIN		cape		k-ä:-p ex			k-ä2:-p ë			k-E:-p @			k-eex-p eh
SWEFIN		tape		t-e-j-p			t-e-j-p			t-E-j-p			t-e-j-p
SWEFIN		tse		t-s-e ex t-s-e:			t-s-e ë t-s-e2:		t-s-e @ t-s-e:		t-s-e eh t-s-ee		
SWEFIN		rsg tg -peg		g-e:		g-e2:			g-e:			g-ee	
SWEFIN		deltay		y:			y2:			y:			yy
SWEFIN		sb		s-b-e:			s-b-e2:			s-b-e:			s-b-ee
SWEFIN		cz		tc			tj3			t-C			ch
													
SWEFIN		-b -hib iib 1b apob 2b		b-e:	b-e2:			b-e:			b-ee		
SWEFIN		-hb -fosb		b-e:			b-e2:			b-e:			b-ee
SWEFIN		-c 1c deltac hempc -wc		s-e:	s-e2:			s-e:			s-ee		
SWEFIN		abc tbc		s-e:			s-e2:			s-e:			s-ee
SWEFIN		-d -cd -bd -id -vd 5d		d-e:	d-e2:			d-e:			d-ee		
SWEFIN		-dvd		d-e:			d-e2:			d-e:			d-ee
SWEFIN		hfatwaid		d-e:			d-e2:			d-e:			d-ee
SWEFIN		-g -ekg -eeg		g-e:		g-e2:			g-e:			g-ee	
SWEFIN		-h -msh -acth		h-o:		h-å2:			h-o:			h-oo	
SWEFIN		-i		i: e-t			i2: e-t			i: e-t			ii e-t
SWEFIN		-ii ii		t-v-o: i:			t-v-å2: i2:		t-v-o: i:			t-v-oo ii	
SWEFIN		-iii		t-r-e:			t-r-e2:			t-r-e:			t-r-ee
SWEFIN		iii		t-r-e:-d-j-ex t-r-e:			t-r-e2:-d-j-ë t-r-e2:	t-r-e:-d-j-@ t-r-e:		t-r-ee-d-j-eh t-r-ee			
SWEFIN		iiia		r-e:-a:			r-e2:-a2:			r-e:-A:			r-ee-aa
SWEFIN		-iv dsmiv		f-y:-r-a			f-y2:-r-a			f-y:-r-a			f-yy-r-a
SWEFIN		dsmv		f-e-m			f-e-m			f-e-m			f-e-m
SWEFIN		-ifk -aik		k-o:			k-å2:			k-o:			k-oo
SWEFIN		-p -cpap folp deltap		p-e:	p-e2:			p-e:			p-ee		
SWEFIN		gp -cp -alp		p-e:		p-e2:			p-e:			p-ee	
SWEFIN		-q		k-uu:			k-u2:			k-}:			k-oo
SWEFIN		-t -rmt -dht -gt		t-e:		t-e2:			t-e:			t-ee	
SWEFIN		-v		v-e: f-e-m			v-e2: f-e-m		v-e: f-e-m		v-ee f-e-m		
SWEFIN		wc		s-e:			s-e2:			s-e:			s-ee
SWEFIN		-htlv -kv -mcv		v-e:		v-e2:			v-e:			v-ee	
													
#**********************************************************************************************************************************************************#													
# Name		Letters		Phones MTM			Phones MTM		Phones Acapela		Phones Cereproc		
#**********************************************************************************************************************************************************#													
SWEACR		a A		a:			a2:			A:			aa
SWEACR		o O		u:			o2:			u:			uu
SWEACR		u U		uu:			u2:			}:			uux
SWEACR		å Å		o:			å2:			o:			oo
SWEACR		e E		e:			e2:			e:			ee
SWEACR		i I		i:			i2:			i:			ii
SWEACR		y Y		y:			y2:			y:			yy
SWEACR		ä Ä		ä:			ä2:			E:			eex
SWEACR		ö Ö		ö:			ö2:			2:			oox
SWEACR		b B		b-e:			b-e2:			b-e:			b-ee
SWEACR		c C		s-e:			s-e2:			s-e:			s-ee
SWEACR		d D		d-e:			d-e2:			d-e:			d-ee
SWEACR		f F		ä-f			ä-f			E-f			e-f
SWEACR		g G		g-e:			g-e2:			g-e:			g-ee
SWEACR		h H		h-o:			h-å2:			h-o:			h-oo
SWEACR		j J		j-i:			j-i2:			j-i:			j-ii
SWEACR		k K		k-o:			k-å2:			k-o:			k-oo
SWEACR		l L		ä-l			ä-l			E-l			e-l
SWEACR		m M		ä-m			ä-m			E-m			e-m
SWEACR		n N		ä-n			ä-n			E-n			e-n
SWEACR		p P		p-e:			p-e2:			p-e:			p-ee
SWEACR		q Q		k-uu:			k-u2:			k-}:			k-oo
SWEACR		r R		ae-r			ä3-r			{-r			ae-r
SWEACR		s S		ä-s			ä-s			E-s			e-s
SWEACR		t T		t-e:			t-e2:			t-e:			t-ee
SWEACR		v V		v-e:			v-e2:			v-e:			v-ee
SWEACR		w W		v-e: d-u-b-ex-l-v-e:			v-e2: d-u-b-ë-l-v-e2:	v-e: d-u-b-@-l-v-e:		v-ee d-ux-b-eh-l-v-ee			
SWEACR		x X		ä-k-s			ä-k-s			E-k-s			e-k-s
SWEACR		z Z		s-ä:-t-a			s-ä2:-t-a			s-E:-t-a			s-eex-t-a
SWEACREND		s		s			s			s			s
SWEACREND		n		n			n			n			n
SWEACREND		t		t			t			t			t
													
#**********************************************************************************************************************************************************#													
# Name		Letters		Phones MTM			Phones MTM		Phones Acapela		Phones Cereproc		
#**********************************************************************************************************************************************************#													
ENGINI		a		ei ae a a: o:			ei ä3 a a2: å2:		e-j { a A: o:		e-j ae a aa oo		
ENGINI		o		ou o o:			öw å å2:			2-U O o:			ou oo o
ENGINI		u		j-uw: a			j-u4: a			j-u: a			j-uu a
ENGINI		e		i: i e ex			i2: i e ë			i: I e @			ii i e eh
ENGINI		i		ai i			ai i			a-j I			a-j i
ENGINI		y		i j			i j			I j			i j
ENGINI		ch		tc k c			tj3 k tj			tS k_h k			ch k c
ENGINI		b		b			b			b			b
ENGINI		c		s k			s k			s k_h k			s k
ENGINI		d		d			d			d			d
ENGINI		f ph		f			f			f			f
ENGINI		g		g dj			g j3			g dZ			g jh
ENGINI		h		h			h			h			h
ENGINI		j		dj			j3			dZ			jh
ENGINI		k		k c			k tj			k_h k C			k
ENGINI		l		l rl			l rl			l rl			l
ENGINI		m		m			m			m			m
ENGINI		n kn		n			n			n			n
ENGINI		p		p			p			p_h p			p
ENGINI		q		k			k			k			k
ENGINI		r		r			r			r			rh
ENGINI		s		s rs			s rs			s rs			s rs
ENGINI		t		t rt			t rt			t_h t rt			t
ENGINI		v		v			v			v			v
ENGINI		x		k-s s			k-s s			k-s s			k-s s
ENGINI		z		s z			s z			s z			s z
ENGINI		ea		i: oe:			i2: ö3:			i: 9:			ii ooe
ENGINI		th		th dh			th dh			T D			th dh
ENGINI		un		a-n j-uw j-uw:			a-n j-u4 j-u4:		a-n j-U j-}: j-u:		a-n j-ux j-uu		
ENGINI		ei		ei			ei			e j			e-j
ENGINI		eu		j uw:			j u4:			j u:			j uu
ENGINI		ai		ei			ei			e-j			e-j
ENGINI		air		eex			eë			}:-r			ae-r
ENGINI		ou		ou			öw			a-U			ou
ENGINI		ey		ai			ai			a-j			a-j
ENGINI		any		e-n-i			e-n-i			e-n-I			e-n-i
ENGINI		up		a-p			a-p			a-p			a-p
ENGINI		hour		au-ex			au-ë			a-U-@			au-eh
ENGINI		au		o:			å2:			o:			oo
#**********************************************************************************************************************************************************#													
1;													
