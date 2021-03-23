<cfcomponent extends="taffy.core.resource" taffy_uri="/passwordReset/">

	<cffunction name="post">
		<cfargument name="email" type="string" required="true">
		<cfargument name="lang" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfif isValid("email", arguments.email)>
					<cfquery name="local.qAccount" datasource="webapps_myds">
						SELECT account_id, accountName,  language, creationDate
						FROM userAccount u
						WHERE accountName = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
						AND (
							SELECT COUNT(*)
							FROM UserAccount_Person up
							LEFT JOIN Person p ON p.Person_id = up.Person_id
							WHERE (p.ServiceState = 'VISIBLE' OR p.ServiceState = 'NOT_VISIBLE')
							AND up.Account_id = u.Account_Id
						) >= 1
						ORDER BY LastEditedDate DESC
					</cfquery>
					<cfdump var="#qAccount#">
					<cfif qAccount.recordcount>
						<cfset var aPassword = []>
						<cfloop query="qAccount">
							<cfset var password = newPassword()>
							<cfset arrayAppend(aPassword, password)>
							<cfquery datasource="webapps_myds">
								UPDATE UserAccount
								SET password = <cfqueryparam value="#password#" cfsqltype="cf_sql_varchar">,
									PwdHash = NULL,
									Salt = NULL,
									LastLostPwdDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
									LoginAttempt = 0
								WHERE Account_id = <cfqueryparam value="#Account_Id#" cfsqltype="cf_sql_integer">
							</cfquery>
						</cfloop>
						<cfmail from="myds@datasport.com" to="#arguments.email#" subject="#application.strings.getString("passwordResetSubject", arguments.lang)#" type="html">
							<p>#application.strings.getString("passwordResetText1", arguments.lang)#</p>
							<p>#application.strings.getString("passwordResetText2", arguments.lang)#</p>
							<cfloop query="qAccount">
								<p>
									#application.strings.getString("username", arguments.lang)#: #accountName#<br>
									#application.strings.getString("password", arguments.lang)#: #aPassword[currentrow]#<br>
									#application.strings.getString("createdAt", arguments.lang)#: #LSDateFormat(creationDate, "dd.mm.yyyy")#
								</p>
							</cfloop>
							<p>#application.strings.getString("passwordResetText3", arguments.lang)#</p>
							<p>#application.strings.getString("salutation", arguments.lang)#<br>#application.strings.getString("yourDatasportTeam", arguments.lang)#</p>
						</cfmail>
					<cfelse>
						<cfmail from="myds@datasport.com" to="#arguments.email#" subject="#application.strings.getString("passwordResetErrorSubject", arguments.lang)#" type="html">
							<p>#application.strings.getString("passwordResetErrorText1", arguments.lang)#</p>
							<p>#application.strings.getString("passwordResetErrorText2", arguments.lang)#</p>
							<p>#application.strings.getString("passwordResetErrorText3", arguments.lang)# #arguments.email#</p>
							<p>#application.strings.getString("salutation", arguments.lang)#<br>#application.strings.getString("yourDatasportTeam", arguments.lang)#</p>
						</cfmail>
					</cfif>
					<cfreturn noData().withStatus(200)>
				<cfelse>
					<cfreturn noData().withStatus(400)>
				</cfif>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="newPassword" access="private" output="false" returntype="string">

		<cfset var newPassword = "">
		<cfset var strLowerCaseAlpha = "abcdefghijklmnopqrstuvwxyz">
		<cfset var strUpperCaseAlpha = UCase(strLowerCaseAlpha)>
		<cfset var strNumbers = "0123456789">
		<cfset var strOtherChars = "!@$%&*">

		<cfset var strAllValidChars = strLowerCaseAlpha & strUpperCaseAlpha & strNumbers & strOtherChars>

		<cfset var arrPassword = []>
		<cfset arrPassword[1] = Mid(strNumbers, RandRange(1, Len(strNumbers)), 1)>
		<cfset arrPassword[2] = Mid(strLowerCaseAlpha, RandRange(1, Len(strLowerCaseAlpha)), 1)>
		<cfset arrPassword[3] = Mid(strUpperCaseAlpha, RandRange(1, Len(strUpperCaseAlpha)), 1)>

		<cfloop index="local.intChar" from="#ArrayLen(arrPassword) + 1#" to="#6 + RandRange(1, 6)#" step="1">
			<cfset arrPassword[intChar] = Mid(strAllValidChars, RandRange(1, Len(strAllValidChars)), 1)>
		</cfloop>

		<cfset CreateObject("java", "java.util.Collections").Shuffle(arrPassword)>
		<cfset newPassword = ArrayToList(arrPassword, "")>

		<cfreturn newPassword>
	</cffunction>

</cfcomponent>