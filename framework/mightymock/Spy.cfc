<component output="false">
	<cffunction access="public" name="init" output="false" hint="The public constructor">
		<cfargument name="objectToSpy" type="any" required="true" hint="The object whose methods should be spied">
		
		<cfscript>
			var proxy = "";
			if (!isObject(arguments.objectToSpy)) {
				proxy = createObject(arguments.objectToSpy);
			}
			else {
				proxy = arguments.objectToSpy;
			}
			proxy._mightySpy_getVariablesScope = variables._mightySpy_getVariablesScope;
			proxy._mightySpy_removeMethod = removeMethod;

			setProxyProperties(proxy);
			setProxyMethods(proxy);

			return proxy;
		</cfscript>
	</cffunction>

	<cffunction access="public" name="_mightySpy_getVariablesScope" output="false" hint="Hooks into the private variables scope">
		<cfreturn variables />
	</cffunction>

	<cffunction access="private" name="setProxyProperties" output="false" hint="Sets the additional spy properties on the spy proxy">
		<cfargument name="proxy" type="any" required="true">

		<cfscript>
			var proxyVariables = arguments.proxy._mightySpy_getVariablesScope();
			proxyVariables._mightySpy_methodCalls = {};
			proxyVariables._mightySpy_publicMethods = [];

			return arguments.proxy;
		</cfscript>
	</cffunction>

	<cffunction access="private" name="setProxyMethods" output="false" hint="Sets the available proxy methods">
		<cfargument name="proxy" type="any" required="true">

		<cfscript>
			var proxyVariables = arguments.proxy._mightySpy_getVariablesScope();
			var proxyMethods = structKeyArray(arguments.proxy);
			var counter = 0;
			var current = "";
			var currentMethodName = "";
			var newMethodScope = structNew();
			for (counter = 1; counter <= arrayLen(proxyMethods); counter ++) {
				current = arguments.proxy[proxyMethods[counter]];	
				if (isCustomFunction(current)) {
					currentMethodName = proxyMethods[counter];
					//We don't want to lose the methods we've added for the spy functionality, so test for our namespace
					if (!findNoCase(currentMethodName, "_mightySpy_")) {
						newMethodScope[currentMethodName] = current;
						structDelete(arguments.proxy, currentMethodName);
						arrayAppend(proxyVariables._mightySpy_publicMethods, currentMethodName);
					}
				}
			}
			proxyVariables._mightySpy_variables = newMethodScope;
			proxyVariables._mightySpy_recordMethodCall = recordMethodCall;
			proxyVariables._mightySpy_getMethodCallCount = getMethodCallCount;
			arguments.proxy._mightySpy_getMethodCallCount = getMethodCallCount;
			proxyVariables._mightySpy_throwMissingMethodException = throwMissingMethodException;
			//OnMissingMethod needs to be defined on the object itself
			arguments.proxy.onMissingMethod = onMissingMethod;

			return proxy;
		</cfscript>
	</cffunction>

	<cffunction access="public" name="getMethodCallCount" output="false" returntype="any">
		<cfargument name="methodName" type="string" required="true">
		<cfscript>
			if (structKeyExists(variables._mightySpy_methodCalls, arguments.methodName)) {
				return arrayLen(variables._mightySpy_methodCalls[arguments.methodName].calls);
			}
			else {
				return 0;
			}
		</cfscript>
	</cffunction>

	<cffunction access="public" name="onMissingMethod" output="false" returntype="any">
		<cfargument name="missingMethodName" type="string" required="true">
		<cfargument name="missingMethodArguments" type="any" required="true">

		<cfscript>
			var returnValue = "";
			var returnFunction = "";
			if (arrayFindNoCase(variables._mightySpy_publicMethods, arguments.missingMethodName)) {
				returnFunction = variables._mightySpy_variables[arguments.missingMethodName];
				returnValue = returnFunction(argumentCollection=arguments.missingMethodArguments);
				_mightySpy_recordMethodCall(arguments.missingMethodName, arguments.missingMethodArguments, returnValue);
				
				return returnValue;
			}
			else if (arrayFindNoCase(variables._mightySpy_publicMethods, "onMissingMethod")) {
				returnValue = variables._mightySpy_variables.onMissingMethod(arguments.missingMethodName, arguments.missingMethodArguments);
				_mightySpy_recordMethodCall(arguments.missingMethodName, arguments.missingMethodArguments, returnValue);

				return returnValue;
			}
			else {
				_mightySpy_throwMissingMethodException(arguments.missingMethodName);	
			}
		</cfscript>
	</cffunction>

	<cffunction access="private" name="recordMethodCall" output="false">
		<cfargument name="methodName" type="string" required="true">
		<cfargument name="methodArgs" type="any" required="true">
		<cfargument name="returnValue" type="any" required="true">

		<cfscript>
			if (!structKeyExists(variables._mightySpy_methodCalls, arguments.methodName)) {
				variables._mightySpy_methodCalls[arguments.methodName] = {
					calls = [
						{
							args = arguments.methodArgs,
							returns = arguments.returnValue
						}
					]
				};
			}
			else {
				arrayAppend(variables._mightySpy_methodCalls[arguments.methodName].calls, {args = arguments.methodArgs, returns = arguments.returnValue});
			}
		</cfscript>
	</cffunction>

	<cffunction access="private" name="throwMissingMethodException" output="false">
		<cfargument name="methodName" type="string" required="true" />
		<cfthrow type="Application" message="The method #arguments.methodName# does not exist" />
	</cffunction>

	<cffunction access="private" name="removeMethod" output="false">
		<cfargument name="methodName" type="string" required="true">
		<cfscript>
			structDelete(variables, arguments.methodName);
			structDelete(this, arguments.methodName);
		</cfscript>
	</cffunction>
</component>
