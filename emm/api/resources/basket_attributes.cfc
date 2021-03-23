<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/attributes/">

	<cffunction name="post">
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="contestId" type="numeric" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfquery name="local.qAttribute">
					SELECT *
					FROM attribute
					<!--- todo: where contestId --->
				</cfquery>

				<!--- Delete options --->
				<cfquery>
					DELETE FROM basket_option
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					AND contest_id = <cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfloop query="qAttribute">
					<cfquery>
						INSERT INTO basket_option (client_session_id, participant_id, contest_id, option_key, option_value, currency, amount, create_date)
						VALUES (
							<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.contestId#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">,
							<cfif structKeyExists(arguments, key)>
								<cfqueryparam value="#arguments[key]#" cfsqltype="cf_sql_varchar">,
							<cfelse>
								<cfqueryparam value="#left(key, 4) EQ "flag" ? 0 : ""#" cfsqltype="cf_sql_varchar">,
							</cfif>
							'CHF',
							0,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>
				</cfloop>

				<!--- Get Basket Struct --->
				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

				<!--- Save Basket --->
				<cfset application.oBasket.saveBasket(arguments.sessionId, basket.currency, basket.totalAmount)>

				<cfreturn rep(basket)>
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