<cfcomponent extends="taffy.core.resource" taffy_uri="/login/">

	<cffunction name="post">
		<cfargument name="email" type="string" required="true">
		<cfargument name="password" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<!--- TODO: keycloak integration --->
				<cfset var userAccount = createObject("component", "ds.myds.UserAccount")>
				<cfset var isLoginValid = userAccount.login(arguments.email, trim(arguments.password), true)>

				<cfif isLoginValid>
					<cfquery name="local.qCheckAccount">
						SELECT COUNT(*) AS total
						FROM session_account
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qCheckAccount.total>
						<cfquery>
							UPDATE session_account
							SET account_id = <cfqueryparam value="#userAccount.account_id#" cfsqltype="cf_sql_integer">,
								account_name = <cfqueryparam value="#userAccount.accountname#" cfsqltype="cf_sql_varchar">,
								account_currency = <cfqueryparam value="#userAccount.currency#" cfsqltype="cf_sql_varchar">,
								account_language = <cfqueryparam value="#userAccount.language#" cfsqltype="cf_sql_varchar">,
								person_id = <cfqueryparam value="#userAccount.persons[1].person_id#" cfsqltype="cf_sql_integer">,
								dsid = <cfqueryparam value="#userAccount.persons[1].dsid#" cfsqltype="cf_sql_varchar">,
								firstname = <cfqueryparam value="#userAccount.persons[1].firstname#" cfsqltype="cf_sql_varchar">,
								lastname = <cfqueryparam value="#userAccount.persons[1].familyname#" cfsqltype="cf_sql_varchar">,
								gender = <cfqueryparam value="#userAccount.persons[1].gender#" cfsqltype="cf_sql_varchar">,
								yob = <cfqueryparam value="#year(userAccount.persons[1].birthday)#" cfsqltype="cf_sql_integer">,
								country = <cfqueryparam value="#userAccount.persons[1].address.country#" cfsqltype="cf_sql_varchar">,
								city = <cfqueryparam value="#userAccount.persons[1].address.place#" cfsqltype="cf_sql_varchar">,
								update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						</cfquery>
					<cfelse>
						<cfquery>
							INSERT INTO session_account (client_session_id, account_id, account_name, account_currency, account_language, person_id, dsid, firstname, lastname, gender, yob, country, city, create_date)
							VALUES (
								<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.account_id#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#userAccount.accountname#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.currency#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.language#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.persons[1].person_id#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#userAccount.persons[1].dsid#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.persons[1].firstname#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.persons[1].familyname#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.persons[1].gender#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#year(userAccount.persons[1].birthday)#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#userAccount.persons[1].address.country#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.persons[1].address.place#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>
					</cfif>
					<!--- set language --->
					<cfquery name="local.qCheck">
						SELECT COUNT(*) AS total
						FROM session_language
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qCheck.total>
						<cfquery>
							UPDATE session_language
							SET language = <cfqueryparam value="#userAccount.language#" cfsqltype="cf_sql_varchar">,
								update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
						</cfquery>
					<cfelse>
						<cfquery>
							INSERT INTO session_language (client_session_id, language, create_date)
							VALUES (
								<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#userAccount.language#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>
					</cfif>
					<!--- cleanup --->
					<cfquery>
						DELETE FROM session_participant
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfloop array="#userAccount.persons#" index="local.person">
						<cfquery>
							INSERT INTO session_participant (client_session_id, person_id, dsid, participant_id, firstname, lastname, nationality, birthday, gender, street1, country, city, zip, mobile, email, create_date)
							VALUES (
								<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.person_id#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#person.dsid#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.firstname#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.familyname#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.nationality#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#lsDateFormat(person.birthday, "yyyy-mm-dd")#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#person.gender#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.address.street1#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.address.country#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.address.place#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.address.zipcode#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.contactmobile.contactvalue#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#person.contactmail.contactvalue#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							)
						</cfquery>
					</cfloop>
					<cfreturn noData().withStatus(200)>
				<cfelse>
					<cfreturn noData().withStatus(401)>
				</cfif>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>