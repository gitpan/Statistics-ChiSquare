use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Statistics::ChiSquare",
	DISTNAME => "Statistics-ChiSquare",
	linkext => {LINKTYPE => ''}, # not needed for MakeMakers >= 5
	VERSION => "0.1",
        dist => {COMPRESS=>'gzip -9f'},
);
