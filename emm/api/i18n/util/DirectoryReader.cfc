<cfcomponent>

	<cffunction name="init" access="public" returntype="i18n.util.DirectoryReader">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getContents" access="public" returntype="query">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="filter" type="string" required="false" default="*.*" />
		
		<cfset var contents = "" />
		
		<cfdirectory name="contents"
			directory="#arguments.path#"
			action="list"
			filter="#arguments.filter#"
			type="file" />
		 
		 <cfreturn contents />	 
	</cffunction>

</cfcomponent>