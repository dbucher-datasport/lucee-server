<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/step/">

	<cffunction name="get">
		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qStep">
					SELECT *
					FROM basket_step
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qStep.recordcount>
					<cfset var basketSteps = [:]>
					<cfloop query="qStep">
						<cfset basketSteps["editionId"] = edition_id>
						<cfset basketSteps["participant"] = participant ? true : false>
						<cfset basketSteps["registration"] = registration ? true : false>
						<cfset basketSteps["extra"] = extra ? true : false>
						<cfset basketSteps["shop"] = shop ? true : false>
						<cfset basketSteps["summary"] = summary ? true : false>
						<cfset basketSteps["checkout"] = checkout ? true : false>
						<cfset basketSteps["currentStep"] = current_step>
						<cfset basketSteps["maxStep"] = max_step>
					</cfloop>
					<cfreturn rep(basketSteps)>
				<cfelse>
					<cfreturn noData()>
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

	<cffunction name="post">
		<cfargument name="editionId" type="numeric" required="true">
		<cfargument name="step" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qCheckStep">
					SELECT *
					FROM basket_step
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qCheckStep.recordcount>
					<cfset var steps = "participant,registration,extra,shop,summary,checkout">
					<cfset var indexStep = listFind(steps, arguments.step)>
					<cfset var indexMaxStep = listFind(steps, qCheckStep.max_step)>
					<cfquery>
						UPDATE basket_step
						SET edition_id = <cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer">,
							#arguments.step# = 1,
							current_step = <cfqueryparam value="#arguments.step#" cfsqltype="cf_sql_varchar">,
							<cfif indexStep GT indexMaxStep>
								max_step = <cfqueryparam value="#arguments.step#" cfsqltype="cf_sql_varchar">,
							</cfif>
							update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				<cfelse>
					<cfquery>
						INSERT INTO basket_step (client_session_id, edition_id, #arguments.step#, current_step, max_step, create_date)
						VALUES (
							<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.editionId#" cfsqltype="cf_sql_integer">,
							1,
							<cfqueryparam value="#arguments.step#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.step#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>
				</cfif>

				<cfquery name="local.qStep">
					SELECT *
					FROM basket_step
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfset var basketSteps = [:]>
				<cfloop query="qStep">
					<cfset basketSteps["editionId"] = edition_id>
					<cfset basketSteps["participant"] = participant ? true : false>
					<cfset basketSteps["registration"] = registration ? true : false>
					<cfset basketSteps["extra"] = extra ? true : false>
					<cfset basketSteps["shop"] = shop ? true : false>
					<cfset basketSteps["summary"] = summary ? true : false>
					<cfset basketSteps["checkout"] = checkout ? true : false>
					<cfset basketSteps["currentStep"] = current_step>
					<cfset basketSteps["maxStep"] = max_step>
				</cfloop>
				<cfreturn rep(basketSteps)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#">
				<cfabort>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>