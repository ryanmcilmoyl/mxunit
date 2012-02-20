<component output="false">
	<cffunction access="public" name="init" output="false" hint="The public constructor">
		<cfargument name="objectToSpy" type="any" required="true" hint="The object whose methods should be spied">
		<cfargument 
			name="beginRecording" 
			type="boolean" 
			default="true" 
			hint="If true, the proxy is immediatly in record mode">
		
		<cfscript>
			var proxy = "";
			if (!isObject(arguments.objectToSpy)) {
				proxy = createObject(arguments.objectToSpy);
			}
			else {
				proxy = arguments.objectToSpy;
			}
			//Add mightySpy utility methods to the proxy object
			proxy._mightySpy_getVariablesScope = variables._mightySpy_getVariablesScope;
			proxy._mightySpy_removeMethod = removeMethod;

			//Add properties for spying
			setProxyProperties(proxy, {recording = arguments.beginRecording});
			setProxyMethods(proxy);

			return proxy;
		</cfscript>
	</cffunction>

	<cffunction 
		access="public" 
		name="_mightySpy_getVariablesScope" 
		output="false" 
		hint="Hooks into the private variables scope.  This method is added to the proxied object, allowing 
		the spy access.">
		<cfreturn variables />
	</cffunction>

	<cffunction 
		access="public" 
		name="getMethodCallCount" 
		output="false" 
		returntype="any"
		hint="For a given method, return the number of times its been called">

		<cfargument name="methodName" type="string" required="true">
		<cfscript>
			if (structKeyExists(variables._mightySpy_methodCalls, arguments.methodName)) {
				return arrayLen(variables._mightySpy_methodCalls[arguments.methodName]);
			}
			else {
				return 0;
			}
		</cfscript>
	</cffunction>

	<cffunction
		access="public"
		name="getMethodCalls"
		output="false"
		returntype="any"
		hint="For a given method, return the array of collected method calls">

		<cfargument name="methodName" type="string" required="true">

		<cfscript>
			if (structKeyExists(variables._mightySpy_methodCalls, arguments.methodName)) {
				return variables._mightySpy_methodCalls[arguments.methodName];
			}
			else {
				return [];
			}
		</cfscript>
	</cffunction>

	<cffunction 
		access="public" 
		name="onMissingMethod" 
		output="false" 
		returntype="any" 
		hint="This is where the magic happens">

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

	<cffunction 
		name="pause" 
		access="public" 
		output="false" 
		returntype="void"
		hint="Pauses recorded, any method calls will continue to succeed but will not be captured until
		the 'record' method is called.  This is added to the returned proxy object as
		_mightySpy_pause">
		
		<cfset variables._mightySpy_recording = false />
	</cffunction>

	<cffunction
		access="public"
		name="record"
		output="false"
		returntype="void"
		hint="Begins recording method calls.  This is added to the returned proxy object as
		_mightySpy_record">

		<cfset variables._mightySpy_recording = true />
	</cffunction>

	<!--- Private methods --->
	<cffunction 
		access="private" 
		name="setProxyProperties" 
		output="false" 
		hint="Sets the additional spy properties on the spy proxy.  Used to create the proxy, this
		method does not get added to the returned proxy object">

		<cfargument name="proxy" type="any" required="true">
		<cfargument 
			name="props" 
			type="struct" 
			required="false" 
			hint="Any additional properties to be set. Names will be prefixed with '_mightySpy_'">

		<cfscript>
			var proxyVariables = arguments.proxy._mightySpy_getVariablesScope();
			var propArray = "";
			var propCount = 1;
			var totalProps = 0;
			proxyVariables._mightySpy_methodCalls = {};
			proxyVariables._mightySpy_publicMethods = [];
			
			if (structKeyExists(arguments, "props")) {
				propArray = structKeyArray(arguments.props);	
				totalProps = arrayLen(propArray);
				for (propCount = 1; propCount <= totalProps; propCount += 1) {
					proxyVariables["_mightySpy_" & propArray[propCount]] = 
						arguments.props[propArray[propCount]];
				}
			}

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
			proxyVariables._mightySpy_getMethodCalls = getMethodCalls;
			arguments.proxy._mightySpy_getMethodCalls = getMethodCalls;
			//OnMissingMethod needs to be defined on the object itself
			arguments.proxy.onMissingMethod = onMissingMethod;
			arguments.proxy._mightySpy_pause = pause;
			arguments.proxy._mightySpy_record = record;

			return proxy;
		</cfscript>
	</cffunction>

	<cffunction 
		access="private" 
		name="recordMethodCall" 
		output="false" 
		hint="Records a method call. This gets added to the returned proxy object">

		<cfargument name="methodName" type="string" required="true">
		<cfargument name="methodArgs" type="any" required="true">
		<cfargument name="returnValue" type="any" required="true">

		<cfscript>
			if (variables._mightySpy_recording) {
				if (!structKeyExists(variables._mightySpy_methodCalls, arguments.methodName)) {
					variables._mightySpy_methodCalls[arguments.methodName] = [
						{
							args = arguments.methodArgs,
							returns = arguments.returnValue
						}
					];
				}
				else {
					arrayAppend(variables._mightySpy_methodCalls[arguments.methodName], {args = arguments.methodArgs, returns = arguments.returnValue});
				}
			}
		</cfscript>
	</cffunction>

	<cffunction 
		access="private" 
		name="throwMissingMethodException" 
		output="false"
		hint="Throws an exception when a method is call that does not exist, and the proxied object
		does not implement onMissingMethod.  This method gets added to the returned proxy object">

		<cfargument name="methodName" type="string" required="true" />

		<cfthrow type="Application" message="The method #arguments.methodName# does not exist" />
	</cffunction>

	<cffunction access="private" name="removeMethod" output="false" hint="Removes a public method">
		<cfargument name="methodName" type="string" required="true">
		<cfscript>
			structDelete(variables, arguments.methodName);
			structDelete(this, arguments.methodName);
		</cfscript>
	</cffunction>
</component>
