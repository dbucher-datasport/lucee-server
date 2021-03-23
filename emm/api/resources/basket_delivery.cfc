<cfcomponent extends="taffy.core.resource" taffy_uri="/basket/delivery/">

	<cffunction name="post">
		<cfargument name="type" type="string" required="true">
		<cfargument name="name" type="string" default="">
		<cfargument name="street" type="string" default="">
		<cfargument name="zip" type="string" default="">
		<cfargument name="city" type="string" default="">
		<cfargument name="country" type="string" default="">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfquery name="local.qDelivery">
					SELECT *
					FROM basket_delivery
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qDelivery.recordcount>
					<cfquery>
						UPDATE basket_delivery
						SET type = <cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar">,
							name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.name))#">,
							street = <cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.street))#">,
							zip = <cfqueryparam value="#arguments.zip#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.zip))#">,
							city = <cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.city))#">,
							country = <cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.country))#">,
							update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				<cfelse>
					<cfquery>
						INSERT INTO basket_delivery (client_session_id, type, name, street, zip, city, country, create_date)
						VALUES (
							<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.name))#">,
							<cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.street))#">,
							<cfqueryparam value="#arguments.zip#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.zip))#">,
							<cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.city))#">,
							<cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar" null="#not len(trim(arguments.country))#">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>
				</cfif>

				<!--- Get Basket Struct --->
				<cfset var basket = application.oBasket.getBasketStruct(arguments.sessionId)>

				<!--- Save Basket --->
				<cfset application.oBasket.saveBasket(arguments.sessionId, basket.currency, basket.totalAmount)>

				<cfreturn rep(basket)>
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