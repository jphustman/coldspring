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
<cfcomponent hint="Namespace handler for the 'http://www.coldspringframework.org/schema/aop' namespace" extends="coldspring.beans.xml.AbstractNamespaceHandler" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="AOPNameSpaceHandler" output="false">
	<cfscript>
		super.init();

		registerBeanDefinitionParser("config", createObject("component", "ConfigDefinitionParser").init());

		return this;
	</cfscript>
</cffunction>

<cffunction name="getSchemaLocations" hint="to give ColdSpring a map of remote Schemas to their local absolute paths"
			access="public" returntype="struct" output="false"
			colddoc:generic="string,string">
	<cfscript>
		var map = {};

		map["http://coldspringframework.org/schema/coldspring-aop-2.0.xsd"] = getDirectoryFromPath(getMetadata(this).path) & "/coldspring-aop-2.0.xsd";

		return map;
    </cfscript>
</cffunction>

<cffunction name="getNameSpaces" hint="a single, list or array of string values that are the namespaces this handler manages the parsing for" access="public" returntype="any" output="false">
	<cfreturn "http://www.coldspringframework.org/schema/aop" />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>