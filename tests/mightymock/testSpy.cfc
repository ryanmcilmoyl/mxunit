<cfcomponent extends="mxunit.framework.TestCase">
	<cffunction name="testCreation" output="false" access="public">
		<cfscript>
			var spyFixturePath = "mxunit.tests.mightymock.fixture.ParentSpyObject";
			var spy = createObject("mxunit.framework.mightymock.Spy").init(spyFixturePath).init("Hello");
			
			assertEquals('This is a parent method', spy.parentSpy());
			debug(spy._mightySpy_getVariablesScope());
		</cfscript>
	</cffunction>
</cfcomponent>
