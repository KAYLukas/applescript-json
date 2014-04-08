-- Empty the output
try
	tell application "AppleScript Editor"
		set textView to get document ("Test Results")
		set text of textView to ""
	end tell
end try

property parent : load script ((POSIX file (POSIX path of ((path to me as text) & "::") & "ASUnit/ASUnit.scpt") as text) as alias)

property suitename : "AppleScript JSON test suite"
property scriptName : "json"
global json

property TopLevel : me
property suite : makeTestSuite(suitename)

autorun(suite)

script |Load script|
	property parent : TestSet(me)
	script |Loading the script|
		property parent : UnitTest(me)
		tell application "Finder"
			set json_path to file "json.scpt" of folder of (path to me)
		end tell
		set json to load script (json_path as alias)
	end script
end script

script |Hex4 test set|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	
	script |test int 0|
		property parent : UnitTest(me)
		assertEqual(json's hex4(0), "0000")
	end script
	
	script |test int 1|
		property parent : UnitTest(me)
		assertEqual(json's hex4(1), "0001")
	end script
	
	script |test int 11|
		property parent : UnitTest(me)
		assertEqual(json's hex4(11), "000b")
	end script
	
	script |test int 2*16|
		property parent : UnitTest(me)
		assertEqual(json's hex4(2 * 16), "0020")
	end script
	
	
	script |test int 65534|
		property parent : UnitTest(me)
		assertEqual(json's hex4(65534), "fffe")
	end script
	
	script |test int 65536|
		property parent : UnitTest(me)
		assertEqual(json's hex4(65536), "0000")
	end script
	
	script |test int 655537|
		property parent : UnitTest(me)
		assertEqual(json's hex4(65537), "0001")
	end script
end script

script |Basic encoding test set|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test encoding integers|
		property parent : UnitTest(me)
		assertEqual(json's encode(1), "1")
		assertEqual(json's encode(0), "0")
		assertEqual(json's encode(0.1), "0.1")
	end script
	
	script |test encoding strings|
		property parent : UnitTest(me)
		assertEqual(json's encode("foo"), "\"foo\"")
		assertEqual(json's encode(""), "\"\"")
		assertEqual(json's encode("\"\""), "\"\\\"\\\"\"")
		assertEqual(json's encode("\\\"\\\""), "\"\\\\\\\"\\\\\\\"\"")
		assertEqual(json's encode("
"), "\"\\u000a\"")
		assertEqual(json's encode("ș"), "\"\\u0219\"")
	end script
	
	script |test encoding lists|
		property parent : UnitTest(me)
		assertEqual(json's encode({1, 2, 3}), "[1, 2, 3]")
	end script
	
	script |test encoding with createDict()|
		property parent : UnitTest(me)
		assertEqual(json's encode(json's createDict()), "{}")
	end script
	
	script |test encoding with native records|
		property parent : UnitTest(me)
		set dict to {test:null, foo:"bar"}
		assertEqual(json's encode(dict), "{\"test\": null, \"foo\": \"bar\"}")
	end script
end script

script |Simulated dictionary test|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test createDictWith|
		property parent : UnitTest(me)
		set dict to json's createDictWith({{"initial key", "initial value"}})
		assertEqual(dict's getValue("initial key"), "initial value")
	end script
	
	script |test setValue getValue|
		property parent : UnitTest(me)
		set dict to json's createDict()
		dict's setValue("TestStringWithoutSpaces", "Some value")
		assertEqual(dict's getValue("TestStringWithoutSpaces"), "Some value")
		
		dict's setValue("TestStringWithoutSpaces", null)
		assertEqual(dict's getValue("TestStringWithoutSpaces"), null)
		
		set dict2 to json's createDict
		dict's setValue("TestStringWithoutSpaces", dict2)
		assertEqual(dict's getValue("TestStringWithoutSpaces"), dict2)
		
		dict's setValue("TestStringWithoutSpaces", "Some value")
		assertEqual(dict's getValue("TestStringWithoutSpaces"), "Some value")
		
		
		dict's setValue("Test String With Spaces", "Some other value")
		assertEqual(dict's getValue("Test String With Spaces"), "Some other value")
		
		try
			dict's getValue("SomeUnexistantValue")
			set errorOccurred to false
		on error
			set errorOccurred to true
		end try
		assert(errorOccurred, "An error should occur when retrieving a non existant value")
	end script
	
	script |test toRecord|
		property parent : UnitTest(me)
		set dict to json's createDictWith({{"foo", "bar"}, {"test", null}})
		assertEqual(dict's toRecord(), {foo:"bar", test:null})
	end script
end script

script |Advanced encoding decoding tests|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test unNested dict encoding decoding|
		property parent : UnitTest(me)
		set dict to {foo:"bar", test:null}
		assertEqual(json's encode(dict), "{\"test\": null, \"foo\": \"bar\"}")
		assertEqual(json's decode(json's encode(dict)), dict)
	end script
	
	script |test list encoding decoding|
		property parent : UnitTest(me)
		set aList to {"bar", null}
		assertEqual(json's encode(aList), "[\"bar\", null]")
		assertEqual(json's decode(json's encode(aList)), aList)
	end script
	
	script |test integers encoding decoding|
		property parent : UnitTest(me)
		set int to 42
		assertEqual(json's encode(int), "42")
		assertEqual(json's decode(json's encode(int)), int)
		set pi to 3.14159265359
		assertEqual(json's encode(pi), "3.14159265359")
		assertEqual(json's decode(json's encode(pi)), pi)
	end script
	
	script |test string encoding decoding|
		property parent : UnitTest(me)
		assertEqual(json's decode(json's encode("foo")), "foo")
		assertEqual(json's decode(json's encode("")), "")
		assertEqual(json's decode(json's encode("ș")), "ș")
		assertEqual(json's decode(json's encode("
")), "
")
		assertEqual(json's decode(json's encode("你好世界")), "你好世界")
		assertEqual(json's decode(json's ¬
			encode({HelloWorldInChinese:"你好世界"})), ¬
			{HelloWorldInChinese:"你好世界"})
	end script
	
	script |test dict encoding decoding|
		property parent : UnitTest(me)
		set dict to {foo:"bar", test:null}
		assertEqual(json's encode(dict), "{\"test\": null, \"foo\": \"bar\"}")
		assertEqual(json's decode(json's encode(dict)), dict)
		
		set dict2 to {a:13, b:{2, "other", dict}}
		assertEqual(json's encode(dict2), "{\"a\": 13, \"b\": [2, \"other\", {\"test\": null, \"foo\": \"bar\"}]}")
		assertEqual(json's decode(json's encode(dict2)), dict2)
		
		
		set dict3 to ¬
			{glossary:¬
				{GlossDiv:¬
					{GlossList:¬
						{GlossEntry:¬
							{GlossDef:¬
								{GlossSeeAlso:¬
									["GML", "XML"], para:"A meta-markup language, used to create markup languages such as DocBook."} ¬
									, GlossSee:"markup", Acronym:"SGML", GlossTerm:"Standard Generalized Markup Language", Abbrev:"ISO 8879:1986", SortAs:"SGML", id:¬
								"SGML"} ¬
								}, title:"S"} ¬
						, title:"example glossary"} ¬
					}
		assertEqual(json's decode(json's encode(dict3)), dict3)
	end script
end script


(*

set dict to {foo:"bar", test:null}
assert_eq(json's encode(dict), "{\"test\": null, \"foo\": \"bar\"}")
assert_eq(json's decode(json's encode(dict)), dict)

set dict2 to {a:13, b:{2, "other", dict}}
assert_eq(json's encode(dict2), "{\"a\": 13, \"b\": [2, \"other\", {\"test\": null, \"foo\": \"bar\"}]}")
assert_eq(json's decode(json's encode(dict2)), dict2)


set dict3 to ¬
	{glossary:¬
		{GlossDiv:¬
			{GlossList:¬
				{GlossEntry:¬
					{GlossDef:¬
						{GlossSeeAlso:¬
							["GML", "XML"], para:"A meta-markup language, used to create markup languages such as DocBook."} ¬
							, GlossSee:"markup", Acronym:"SGML", GlossTerm:"Standard Generalized Markup Language", Abbrev:"ISO 8879:1986", SortAs:"SGML", id:¬
						"SGML"} ¬
						}, title:"S"} ¬
				, title:"example glossary"} ¬
			}
assert_eq(json's decode(json's encode(dict3), true, true), dict3)


return "ok"*)