<cfcomponent extends="taffy.core.resource" taffy_uri="/events/{eventID}">

	<cffunction name="get" access="public" output="false">

		<cfset var event = [:]>
		<cfset var eventClass = ["A","B","C","D"]>

		<cftry>
			<cfquery name="local.qEvents" datasource="reg2">
				SELECT *
				FROM eventHaupttabelle
				WHERE uid = <cfqueryparam value="#arguments.eventID#" cfsqltype="cf_sql_integer">
				AND killer IS NULL
			</cfquery>

			<cfif qEvents.recordcount>
				<cfloop query="qEvents">
					<cfset event["id"] = uid>
					<cfset event["name"] = eventBezLang>
					<cfset event["class"] = eventClass[randRange(1, arrayLen(eventClass))]>
					<cfset event["execution"] = [:]>
					<cfset event["execution"]["id"] = eventRacenr>
					<cfset event["execution"]["rr_racenr"] = 1234>
					<cfset event["execution"]["year"] = year(eventDatumVon)>
					<cfset event["execution"]["dateFrom"] = lsDateFormat(eventDatumVon, "yyyy-mm-dd")>
					<cfset event["execution"]["dateTo"] = lsDateFormat(eventDatumBis, "yyyy-mm-dd")>
					<cfset event["region"] = [:]>
					<cfset event["region"]["name"] = "Some region">
					<cfset event["region"]["description"] = "Some region description">
					<cfset event["region"]["country"] = eventLand>
					<cfset event["organizer"] = [:]>
					<cfset event["organizer"]["name"] = listFirst(eventOrganisator)>
					<cfset event["organizer"]["description"] = "Some organizer description">
					<cfset event["organizer"]["website"] = "https://www.datasport.com">
					<cfset event["organizer"]["street1"] = "Musterstrasse">
					<cfset event["organizer"]["street2"] = "">
					<cfset event["organizer"]["zip"] = "4563">
					<cfset event["organizer"]["location"] = "Gerlafingen">
					<cfset event["organizer"]["country"] = "SUI">
					<cfset event["organizer"]["phone"] = "+41 32 321 44 11">
					<cfset event["organizer"]["email"] = "info@datasport.com">
					<cfset event["organizer"]["vat"] = eventOrganisatorMwst>
				</cfloop>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>

		<cfreturn rep(event)>
	</cffunction>

</cfcomponent>