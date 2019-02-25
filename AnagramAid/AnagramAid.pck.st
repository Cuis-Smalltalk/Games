'From Cuis 4.2 of 25 July 2013 [latest update: #2690] on 22 February 2016 at 6:29:24.643073 pm'!
'Description An aid for solving anagrams with different behavior for short and long anagrams. With a long anagram, random re-arrangements are listed as clues. One may remove letters and study the remainder. Removed letters can be returned. Short anagrams produce a list of permutations.'!
!provides: 'AnagramAid' 1 27!
!classDefinition: #Anagram category: #AnagramAid!
TextModel subclass: #Anagram
	instanceVariableNames: 'board clues cluesFont count jmb omitted omit'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnagramAid'!
!classDefinition: 'Anagram class' category: #AnagramAid!
Anagram class
	instanceVariableNames: ''!

!classDefinition: #AnagramMorph category: #AnagramAid!
SystemWindow subclass: #AnagramMorph
	instanceVariableNames: 'buttonPane statusString cluesString'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnagramAid'!
!classDefinition: 'AnagramMorph class' category: #AnagramAid!
AnagramMorph class
	instanceVariableNames: ''!


!Anagram commentStamp: 'dhn 9/22/2015 19:27' prior: 0!
An aid for solving anagrams with different behavior for short and long anagrams. 

With a long anagram, random re-arrangements are listed as clues. One may remove letters and study the remainder. Removed letters can be returned. Short anagrams produce a list of permutations.

The setting which determines whether clues are random or permuted is in Anagram class>>permuteLimit.!

!AnagramMorph commentStamp: 'dhn 1/26/2015 18:39' prior: 0!
The window for Anagram Aid.!

!TextComposition methodsFor: '*AnagramAid' stamp: 'dhn 8/26/2015 18:32'!
editor

	^ editor! !

!Anagram methodsFor: 'operating' stamp: 'dhn 9/3/2015 11:48'!
atRandom
	"Display randomly selected clues"
	| set str |
	set _ Set new.
	self class cluesToDisplay timesRepeat: [set add: jmb shuffled].	"avoid duplicates"
	str _ String new writeStream.
	set do: [:ea |
		str
			nextPutAll: ea;
			nextPutAll: self separators].
	self board cluesString actualContents: (Text 
		initialFont: cluesFont stringOrText: str contents).
	count _ count + set size! !

!Anagram methodsFor: 'accessing'!
board
	^ board.! !

!Anagram methodsFor: 'accessing' stamp: 'dhn 1/26/2015 18:11'!
board: anObject
	"Set the value of board to anObject"
	board _ anObject! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/30/2015 13:26'!
configureButtons
	"Choose which buttons to show based on the sizes of #jmb and #omitted"
	jmb size > self class permuteLimit
		ifTrue: [
			omitted size isZero
				ifTrue: [ self putButtons: {self newButton. self moreButton. self withoutButton} ]
				ifFalse: [ self putButtons: {self newButton. self moreButton. self withoutButton. self revertButton} ]]
		ifFalse: [
			omitted size isZero
				ifTrue: [ self putButtons: {self newButton} ]
				ifFalse: [ self putButtons: {self newButton. self withoutButton. self revertButton} ]].! !

!Anagram methodsFor: 'operating' stamp: 'dhn 12/5/2015 07:54'!
entry
	"Acquire a new anagram"
	| ans |
	ans _ FillInTheBlankMorph
		request: 'Enter the Anagram'
		initialAnswer: ''.
	ans isEmpty ifFalse: [
		jmb _ (ans copyWithout: $ ) asUppercase.
		count _ 0.
		omitted _ String new.
		self 
			more;
			configureButtons]! !

!Anagram methodsFor: 'operating' stamp: 'dhn 9/2/2015 16:55'!
fontName
	"Answer the family name of a font for the clues"
	
	^ AbstractFont familyNames     
		detect: [:f | f = 'DejaVu Sans Mono'] ifNone: [^ AbstractFont default familyName]! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 9/3/2015 11:47'!
initialize
	super initialize.
	cluesFont _ AbstractFont familyName: self fontName aroundPointSize: 10
! !

!Anagram methodsFor: 'operating' stamp: 'dhn 1/31/2016 17:31'!
letterCount: aString
	"Answer a print string showing the number of times letters appear in aString"
	| col dix sorted str |

	col _ OrderedCollection new.
	aString asByteArray sort do: [:byte | col addLast: byte asCharacter].
	dix _ Dictionary new.
	col do: [ :ea | | sym |
		sym _ ea asSymbol.
		(dix includesKey: sym)
			ifTrue: [dix at: sym put: (dix at: sym) + 1]
			ifFalse: [dix at: sym	put: 1]].
	str _ String new writeStream newLine.
	sorted _ dix keys asSortedCollection.
	sorted do: [ :char |
		str nextPutAll: char printString;
			nextPutAll: '->';
			nextPutAll: (dix at: char) printString; space].
	^ str contents.! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/30/2015 13:25'!
lettersOmitted
	"Answer a print string showing the letters omitted from the anagram"
	| str |
	str _ String new writeStream.
	omitted isEmpty 
		ifTrue: [^ '']
		ifFalse: [
			str
				nextPutAll: 'Without: ';
				nextPutAll: omitted; newLine.
			^ str contents]! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/26/2015 18:02'!
more
	"Display the next set of clues, either at random or permuted"
	jmb size > self class permuteLimit
		ifTrue: [ self atRandom ]
		ifFalse: [ self permuted ].
	self board adjustExtentFor: jmb.
	self showStatistics! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 1/26/2015 18:16'!
moreButton
	"Answer the More button"
	^ PluggableButtonMorph new
		model: self;
		label: 'More';
		action: #more;
		color: Color white;
		setBalloonText: 'Displays additional
letter combinations.'.! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 1/30/2015 09:17'!
newButton
	"Answer the New button"
	^ PluggableButtonMorph new
		model: self;
		label: 'New';
		action: #entry;
		color: Color white;
		setBalloonText: 'Asks for letters of a new anagram,
then displays different combinations of those letters.'.! !

!Anagram methodsFor: 'operating' stamp: 'dhn 9/3/2015 11:48'!
permuted
	"Display a set of permuted clues"
	| set clue str |
	clue _ String new writeStream.
	set _ Set new.
	(1 to: jmb size) permutationsDo: [ :letter |
		clue reset.
		(1 to: jmb size) do: [ :ix |
			clue nextPut: (jmb at: (letter at: ix))].
		set add: clue contents].	"avoid duplicates"
	str _ String new writeStream.
	set do: [:ea |
		str
			nextPutAll: ea;
			nextPutAll: self separators].
	self board cluesString actualContents: (Text 
		initialFont: cluesFont stringOrText: str contents).
	count _ count + set size! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 1/26/2015 18:19'!
putButtons: aCollection
	"Remove all buttons then add all the buttons in aCollection"
	self board
		removeButtons;
		addAllButtons: aCollection.! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/30/2015 13:25'!
revert
	"Return the omitted characters to the anagram"
	jmb _ jmb , omitted.
	omitted _ String new.
	self configureButtons.
	self more! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 1/26/2015 18:15'!
revertButton
	"Answer the Revert button"
	^ PluggableButtonMorph new
		model: self;
		label: 'Revert';
		action: #revert;
		color: Color white;
		setBalloonText: 'Re-inserts removed characters,
then displays the original set.'.! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/26/2015 13:40'!
separators
	"Answer the string which separates the clues"
	^ '  '! !

!Anagram methodsFor: 'operating' stamp: 'dhn 8/30/2015 13:16'!
showStatistics
	"Update the status area"
	| str |
	str _ String new writeStream
		nextPutAll: self lettersOmitted;
		nextPutAll: 'Number of clues so far = ';
		nextPutAll: count asString;
		newLine;
		nextPutAll: 'characters = ';
		nextPutAll: jmb size asString;
		nextPutAll: (self letterCount: jmb);
		newLine.
	self board statusString actualContents: str contents.! !

!Anagram methodsFor: 'operating' stamp: 'dhn 9/1/2015 14:59'!
without
	"Remove letters, if specified, from the anagram and produce more clues"
	| col what str |
	what _ FillInTheBlankMorph
		request: 'Enter the letters to be omitted.'
		initialAnswer: ''.
	what isEmpty ifFalse: [
		col _ jmb asOrderedCollection.
		(what copyWithout: $ ) asUppercase asOrderedCollection do: [ :ea |
			(col includes: ea) ifTrue: [
				col remove: ea.
				omitted _ omitted, ea asString]].
		str _ String new writeStream.
		col do: [ :remainingLetter |
			str nextPut: remainingLetter].
		jmb _ str contents.
		self
			configureButtons;
			more]! !

!Anagram methodsFor: 'initialize-release' stamp: 'dhn 1/26/2015 18:14'!
withoutButton
	"Answer the Without button"
	^ PluggableButtonMorph new
		model: self;
		label: 'Without';
		action: #without;
		color: Color white;
		setBalloonText: 'Removes characters,
then re-displays what is left.'.! !

!Anagram class methodsFor: 'initialization' stamp: 'dhn 3/3/2015 14:37'!
cluesToDisplay
	"Answer the number of clues to display at one time for large anagrams"
	^ 100! !

!Anagram class methodsFor: 'initialization' stamp: 'dhn 1/26/2015 16:24'!
permuteLimit
	"Answer the maximum size of the anagram which will be permuted"
	^ 5! !

!AnagramMorph methodsFor: 'initialization' stamp: 'dhn 11/6/2015 11:07'!
addAllButtons: aCollection
	"Add all the buttons in aCollection to the button pane"
	aCollection do: [ :ea |
		buttonPane
			addMorph: ea
			proportionalWidth: self class buttonWidth]! !

!AnagramMorph methodsFor: 'resizing' stamp: 'dhn 8/31/2015 13:16'!
adjustExtentFor: aString
	"Set width of extent  such that clues of aString appear in columns"
	| innerMorph charPixels oldExtent newWidth scrollPixels nl pad clue cols |
	
	innerMorph _ self findDeepSubmorphThat: [:s | s is: #InnerTextMorph] ifAbsent: [^ nil].
	charPixels _ innerMorph textComposition editor lastFont widthOf: $M.		"width per character"
	oldExtent _ self morphExtent.
	
	(innerMorph owner verticalScrollBar valueOfProperty: #visible)
		ifTrue: [scrollPixels _ ScrollBar scrollbarThickness]
		ifFalse: [scrollPixels _ 0].
		
	nl _ charPixels.			"new line width"
	pad _ charPixels * self model separators size.	"padding width"
	clue _ charPixels * aString size.		"clue width"
	
	cols _ ((oldExtent x) + pad - nl - scrollPixels) / (clue + pad).
	cols _ 3 max: cols floor.		"at least 3 columns"
	
	newWidth _ (cols * (clue + pad)) + nl + scrollPixels.
	
	self morphExtent: newWidth @ (oldExtent y).! !

!AnagramMorph methodsFor: 'initialization' stamp: 'dhn 2/22/2016 18:26'!
buildMorphicWindow
	"Specify the layout for the Anagram Assistant window"
	| status cluesMorph statusMorph clues |
	
	status _ LayoutMorph newRow
		name: 'status area';
		addMorph: (statusMorph _ TextModelMorph 
			withModel: (statusString _ TextModel withText: 'Status Area')).
	statusMorph 
		name: #status;
		layoutSpec: LayoutSpec useAll.
			
	buttonPane _ LayoutMorph newRow
		name: #buttons;
		padding: #center; "#center causes the buttons to be centered in the row"
		doAdoptWidgetsColor.
	
	clues _ LayoutMorph newRow
		name: 'clue area';
		addMorph: (cluesMorph _ TextModelMorph 
			withModel: (cluesString _ TextModel withText: 'Clues Area')).
	cluesMorph 
		name: #clues;
		layoutSpec: LayoutSpec useAll.

			
	statusMorph askBeforeDiscardingEdits: false;
		wrapFlag: true.
			
	cluesMorph askBeforeDiscardingEdits: false;
		wrapFlag: true.
		
	self layoutMorph
			addMorph: status proportionalHeight: 0.15; 	
			addMorph: buttonPane fixedHeight: 26;		
			addMorph: clues proportionalHeight: 1.0.
! !

!AnagramMorph methodsFor: 'accessing' stamp: 'dhn 1/26/2015 18:41'!
cluesString
	^ cluesString! !

!AnagramMorph methodsFor: 'initialization' stamp: 'dhn 8/25/2015 17:18'!
initialize
	super initialize! !

!AnagramMorph methodsFor: 'initialization' stamp: 'dhn 1/26/2015 18:44'!
removeButtons
	"Remove all buttons from the button pane"
	buttonPane removeAllMorphs.! !

!AnagramMorph methodsFor: 'accessing' stamp: 'dhn 1/26/2015 18:41'!
statusString
	^ statusString! !

!AnagramMorph class methodsFor: 'initialization' stamp: 'dhn 1/26/2015 18:38'!
buttonWidth
	"Answer button width as a proportion of the width of the containing morph"
	^ 0.2! !

!AnagramMorph class methodsFor: 'initialization' stamp: 'dhn 11/6/2015 13:32'!
how
"
	New morph... or
	AnagramMorph open.
"! !

!AnagramMorph class methodsFor: 'initialization' stamp: 'dhn 11/6/2015 19:03'!
includeInNewMorphMenu
	"Return true for all classes that can be instantiated from the menu"
	^ true! !

!AnagramMorph class methodsFor: 'initialization' stamp: 'dhn 11/6/2015 13:36'!
initializedInstance
	"Enable instantiation from the new morph menu"

	^ self open! !

!AnagramMorph class methodsFor: 'initialization' stamp: 'dhn 12/5/2015 07:50'!
open
"
	AnagramMorph open.
"
	| mod win |

	win _ self open: (mod _ Anagram new) label: 'Anagram Aid'	.
	mod board: win.
	win 
		setWindowColor: Color lightGreen;
		addAllButtons: {mod newButton}.
	^ win! !