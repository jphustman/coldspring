﻿<!---
   Copyright 2010 Mark Mandel
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 --->

<cfcomponent hint="Utility for interacting with CFC Meta data. Singleton." output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor - Always returns a singleton" access="public" returntype="CFCMetaUtil" output="false">
	<cfscript>
		var singleton = createObject("component", "Singleton").init();

		return singleton.createInstance(getMetaData(this).name);
	</cfscript>
</cffunction>

<cffunction name="configure" hint="Configure method for static configuration" access="public" returntype="void" output="false">
	<cfscript>
		variables.instance = {};
		setAssignableCache(StructNew());
	</cfscript>
</cffunction>

<cffunction name="eachClassInTypeHierarchy" hint="Calls the closure for each class type in inheritence, and also for each interface it implements
				with 'className' as the argument.<br/>
				If the closure returns 'false', processing is stopped" access="public" returntype="void" output="false">
	<cfargument name="className" hint="the name of the class" type="string" required="Yes">
	<cfargument name="closure" hint="the closure to fire for each class type found a" type="coldspring.util.Closure" required="Yes">
	<cfargument name="args" hint="optional arguments to also pass through to the closure" type="struct" required="No" default="#structNew()#">
	<cfscript>
		var local = {};
		var meta = 0;
		var queue = 0;

		//break out if the class doesn't exist, which is may not, due to dynamic properties
		if(!classExists(arguments.className))
		{
			return;
		}

		meta = getComponentMetadata(arguments.className);

		while(structKeyExists(meta, "extends"))
		{
			arguments.args.className = meta.name;
			local.result = arguments.closure.call(argumentCollection=arguments.args);

			if(structKeyExists(local, "result") && !local.result)
			{
				return;
			}

			if(structKeyExists(meta, "implements"))
			{
				local.implements = meta.implements;
				queue = createObject("java", "java.util.ArrayDeque").init();

				//set up initial queue
				for(local.key in local.implements)
				{
					local.imeta = local.implements[local.key];
					queue.add(local.imeta);
				}

				//go breadth first
				while(NOT queue.isEmpty())
				{
					local.imeta = queue.remove();

					arguments.args.className = local.imeta.name;
					local.result = arguments.closure.call(argumentCollection=arguments.args);

					if(structKeyExists(local, "result") && !local.result)
					{
						return;
					}

					//if we have an extends, add it to the queue
					if(structKeyExists(local.imeta, "extends"))
					{
						for(local.key in local.imeta.extends)
						{
							local.imeta = local.imeta.extends[local.key];
							queue.add(local.imeta);
						}
					}
				}
			}

			meta = meta.extends;
		}
    </cfscript>
</cffunction>

<cffunction name="eachMetaFunction" hint="calls a Closure for each function that is found in meta data, with 'func' as the argument name" access="public" returntype="void" output="false">
	<cfargument name="meta" hint="the meta data to loop through for functions" type="struct" required="Yes">
	<cfargument name="closure" hint="the Closure to call for each function that is found" type="Closure" required="Yes">
	<cfargument name="args" hint="optional arguments to also pass through to the closure" type="struct" required="No" default="#structNew()#">
	<cfscript>
		var local = {};

		while(StructKeyExists(arguments.meta, "extends"))
		{
			if(StructKeyExists(arguments.meta, "functions"))
			{
				local.len = ArrayLen(arguments.meta.functions);
		        for(local.counter = 1; local.counter lte local.len; local.counter++)
		        {
					arguments.args.func = meta.functions[local.counter];
					local.continue = arguments.closure.call(argumentCollection=arguments.args);

					if(StructKeyExists(local, "continue") && !local.continue)
					{
						return;
					}
		        }
			}

			meta = meta.extends;
		}
    </cfscript>
</cffunction>

<cffunction name="isAssignableFrom" hint="Whether or not you can assign class1 as class2, i.e if class2 is an interface or super class of class 1" access="public" returntype="boolean" output="false">
	<cfargument name="class1" hint="the implementing class / interface" type="string" required="Yes">
	<cfargument name="class2" hint="the super class / interface" type="string" required="Yes">
	<cfscript>
		var args = 0;
		var key = arguments.class1 & ":" & arguments.class2;
		var cache = getAssignableCache();

		//do some caching. Not going to worry about locking.
		if(structKeyExists(cache, key))
		{
			return cache[key];
		}

		args =
		{
			compareClass = arguments.class2
			//you'll laugh, but passing this around in a struct means it gets passed by reference.
			,result = {value=false}
		};

		eachClassInTypeHierarchy(arguments.class1, getClassTypeCheckClosure(), args);

		cache[key] = args.result.value;

		return args.result.value;
    </cfscript>
</cffunction>

<cffunction name="resolveClassName" hint="resolves a class name that may not be full qualified" access="public" returntype="string" output="false">
	<cfargument name="className" hint="the name of the class" type="string" required="Yes">
	<cfargument name="package" hint="the package the class comes from" type="string" required="Yes">
	<cfscript>
		if(ListLen(arguments.className, ".") eq 1)
		{
			arguments.className = arguments.package & "." & arguments.className;
		}

		return arguments.className;
    </cfscript>
</cffunction>

<cffunction name="getPackage" hint="returns the package this class belongs to" access="public" returntype="string" output="false">
	<cfargument name="className" hint="the name of the class" type="string" required="Yes">
	<cfscript>
		//have to do this stupid juggling because CF8 'can't find 'setLength() on a Builder'
		var builder = createObject("java", "java.lang.StringBuilder").init(arguments.className);

		//builder.setLength(builder.lastIndexOf(".")); << CF8 fails on this because it can't resolve Java Methods. Grrr.
		builder.delete(javacast("int", builder.lastIndexOf(".")), len(arguments.className));

		return builder.toString();
    </cfscript>
</cffunction>

<cffunction name="classExists" hint="check to see if a given class exists" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="a dot notated class path" type="string" required="Yes">
	<cfscript>
		return fileExists(classToFile(argumentCollection=arguments));
    </cfscript>
</cffunction>

<cffunction name="classToFile" hint="converts a classpath to a filename" access="public" returntype="string" output="false">
	<cfargument name="class" hint="a dot notated class path" type="string" required="Yes">
	<cfscript>
		var path = "/" & replace(arguments.class, ".", "/", "all") & ".cfc";

		return expandPath(path);
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<!--- closureMethods --->
<cffunction name="classTypeCheck" hint="check to see if the given className is the same as the passed in one" access="private" returntype="boolean" output="false">
	<cfargument name="className" hint="the class to check" type="string" required="Yes">
	<cfargument name="compareClass" hint="the class to compare against" type="string" required="Yes">
	<cfscript>
		if(arguments.className eq arguments.compareClass)
		{
			arguments.result.value = true;
			return false;
		}

		return true;
    </cfscript>
</cffunction>
<!--- /closureMethods --->

<cffunction name="getClassTypeCheckClosure" access="private" returntype="coldspring.util.Closure" output="false">
	<cfscript>
		if(NOT hasClassTypeCheckClosure())
		{
			setClassTypeCheckClosure(createObject("component", "coldspring.util.Closure").init(classTypeCheck));
		}
    </cfscript>
	<cfreturn instance.classTypeCheckClosure />
</cffunction>

<cffunction name="setClassTypeCheckClosure" access="private" returntype="void" output="false">
	<cfargument name="classTypeCheckClosure" type="coldspring.util.Closure" required="true">
	<cfset instance.classTypeCheckClosure = arguments.classTypeCheckClosure />
</cffunction>

<cffunction name="hasClassTypeCheckClosure" hint="whether this object has a classTypeCheckClosure" access="private" returntype="boolean" output="false">
	<cfreturn StructKeyExists(instance, "classTypeCheckClosure") />
</cffunction>

<cffunction name="getAssignableCache" access="private" returntype="struct" output="false">
	<cfreturn instance.assignableCache />
</cffunction>

<cffunction name="setAssignableCache" access="private" returntype="void" output="false">
	<cfargument name="assignableCache" type="struct" required="true">
	<cfset instance.assignableCache = arguments.assignableCache />
</cffunction>


</cfcomponent>