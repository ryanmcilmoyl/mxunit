<cfcomponent extends="mxunit.framework.TestCase">
	<cffunction name="testBasicMethodCall_objectPath" output="false" access="public" hint="Test creating a basic spy given a string for the object path">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('This is a parent method', spy.parentSpy());
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"), "Call to 'init' not recorded");
			assertEquals(1, spy._mightySpy_getMethodCallCount("parentSpy", "Call to 'parentSpy' not recorded"));
		</cfscript>
	</cffunction>
	
	<cffunction
		name="testArgumentMethodCall_positional_arguments" 
		output="false" 
		access="public" 
		hint="Tests calling a method, ensuring positional arguments are properly captured">

		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			var returnVal = spy.callWithArgs("ryan", "dev");
			var methodCall = spy._mightySpy_getMethodCalls("callWithArgs")[1];
			
			assertEquals('ryandev', returnVal);
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"), "Call to 'init' not recorded");
			assertEquals(methodCall.returns, returnVal);
			assertEquals(methodCall.args[1], "ryan");
			assertEquals(methodCall.args[2], "dev");
			assertEquals(1, spy._mightySpy_getMethodCallCount("callWithArgs", "Call to 'callWithArgs' not recorded"));
		</cfscript>
	</cffunction>

	<cffunction
		name="testArgumentMethodCall_named_arguments" 
		output="false" 
		access="public" 
		hint="Tests calling a method, ensuring named arguments are properly captured">

		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			var returnVal = spy.callWithArgs(name = "ryan", role = "dev");
			var methodCall = spy._mightySpy_getMethodCalls("callWithArgs")[1];
			
			assertEquals('ryandev', returnVal);
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"), "Call to 'init' not recorded");
			assertEquals(methodCall.returns, returnVal);
			assertEquals(methodCall.args.name, "ryan");
			assertEquals(methodCall.args.role, "dev");
			assertEquals(1, spy._mightySpy_getMethodCallCount("callWithArgs", "Call to 'callWithArgs' not recorded"));
		</cfscript>
	</cffunction>

	<cffunction 
		name="testCallPrivate" 
		output="false" 
		access="public" 
		hint="Test calling a method which calls a private method.  Ensure private methods still work">

		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('Hello', spy.callsPrivate());
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"), "Call to 'init' not recorded");
			assertEquals(1, spy._mightySpy_getMethodCallCount("callsPrivate", "Call to 'callsPrivate' not recorded"));
		</cfscript>
	</cffunction>

	<cffunction name="testBasicMethodCall_object" output="false" access="public" hint="Test creating a basic spy given an instantiated component">
		<cfscript>
			var spyFixture = createObject("mxunit.tests.mightymock.fixture.ParentSpyObject").init("Hello");
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixture);
			
			assertEquals('This is a parent method', spy.parentSpy());
			assertEquals(1, spy._mightySpy_getMethodCallCount("parentSpy", "Call to 'parentSpy' not recorded"));
		</cfscript>
	</cffunction>

	<cffunction name="testInherited" output="false" access="public">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.MySpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('This is a parent method', spy.parentSpy());
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"), "Call to 'init' not recorded");
			assertEquals(1, spy._mightySpy_getMethodCallCount("parentSpy"), "Call to 'parentSpy' not recorded");
		</cfscript>
	</cffunction>

	<cffunction name="testMissingMethodError" 
				output="false" 
				access="public" 
				hint="Test appropriate error is thrown if proxied object does not have it's own onMissingMethod handler defined" 
				mxunit:expectedException="Application">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			var myVal = spy.badMethod("val");
		</cfscript>
	</cffunction>

	<cffunction name="testOnMissingMethod" 
				output="false" 
				access="public" 
				hint="Test that we pass through to the actual object's onMissingMethod, if defined">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.MySpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			var myVal = spy.badMethod("val");

			assertEquals("You called badMethod", myVal, "OnMissingMethod not called");
			assertEquals(1, spy._mightySpy_getMethodCallCount("badMethod"), "Call to 'badMethod' not recorded");
		</cfscript>
	</cffunction>
</cfcomponent>
