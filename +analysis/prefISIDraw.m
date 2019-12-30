function prefISI = prefISIDraw(DATA)
	assert(nargin == 1,'just input DATA struct!');
	assert(DATA.segData.seekForISI == 1,'the DATA struct: segData.seekForISI must be 1');
	assert(DATA.intData.seekForISI == 1, 'the DATA struct: intData.seekForISI must be 1');
	assert(DATA.segData.isSeg == 1 && DATA.segData.isLearn == 0, 'segData check failed!');
	assert(DATA.initData.isSeg == 0 && DATA.intData.isLearn == 0, 'intData check failed!');

	
	segData = DATA.segData;
	intData = DATA.intData;




	prefISI = 10;
end