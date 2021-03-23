<cfswitch expression="#thisTag.executionMode#">

	<cfcase value="start">
		<cfif !isDefined("application.strings")>
			<cfthrow type="InvalidI18nConfiguration" message="Invalid i18n Strings Configuration"
				detail="An instance of LocalizedStrings does not exist in the application scope under a key
				named 'strings'.  This configuration is required in order to utilize the tag library." />
		</cfif>
	</cfcase>
	
	<cfcase value="end">
		<cfoutput>#application.strings.getString(argumentCollection=attributes)#</cfoutput>
	</cfcase>

</cfswitch>