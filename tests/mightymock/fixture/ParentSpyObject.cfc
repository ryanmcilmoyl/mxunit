<cfcomponent output="false">
<!---
  fixture for Spy or partial mock implementation.

  NOTE: Mock should also invoke or mock parent methods, too.
        also should be able to accept any init params.
 --->

  <cffunction name="init">
    <cfreturn this />
  </cffunction>

	<cffunction name="parentSpy" access="public" output="false" returntype="Any">
		<cfreturn 'This is a parent method' />
	</cffunction>

	<cffunction name="callsPrivate" access="public" output="false" returntype="any">
		<cfreturn privateReturn() />
	</cffunction>

	<cffunction name="callWithArgs" access="public" output="false" returntype="any">
		<cfargument name="name" type="string" />
		<cfargument name="role" type="string" />

		<cfreturn name & role />
	</cffunction>

	<cffunction name="privateReturn" access="private" output="false" returntype="any">
		<cfreturn "Hello" />
	</cffunction>


</cfcomponent>
