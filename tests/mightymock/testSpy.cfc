<cfcomponent extends="mxunit.framework.TestCase">
	<cffunction name="testCreation" output="false" access="public">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('This is a parent method', spy.parentSpy());
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"));
			assertEquals(1, spy._mightySpy_getMethodCallCount("parentSpy"));
		</cfscript>
	</cffunction>

	<cffunction name="testInherited" output="false" access="public">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.MySpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('This is a parent method', spy.parentSpy());
			assertEquals(1, spy._mightySpy_getMethodCallCount("init"));
			assertEquals(1, spy._mightySpy_getMethodCallCount("parentSpy"));
		</cfscript>
	</cffunction>
</cfcomponent>
