<cfcomponent extends="taffy.core.resource" taffy_uri="/upload">

	<cffunction name="get">
		<cfargument name="participantId" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qUpload">
					SELECT *
					FROM session_upload
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND participant_id = <cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">
					AND deleted = 0
				</cfquery>

				<cfset var aUpload = []>

				<cfloop query="qUpload">
					<cfset var item = [:]>
					<cfset item["id"] = object_id>
					<cfset item["uploadId"] = upload_id>
					<cfset item["filename"] = file_name>
					<cfset item["filesize"] = file_size>
					<cfset arrayAppend(aUpload, item)>
				</cfloop>

				<cfreturn rep(aUpload)>
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
		<cfargument name="participantId" type="string" required="true">
		<cfargument name="uploadId" type="string" required="true">
		<cfargument name="fileUpload" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cffile action="upload" destination="c:\inetpub\wwwroot\emm\api\upload" filefield="fileUpload" nameconflict="makeunique" result="local.uploadResult">

				<cfset var objectId = createUUID()>

				<cfquery>
					INSERT INTO session_upload (object_id, client_session_id, participant_id, upload_id, file_name, file_name_server, file_size, file_ext, content_type, create_date, deleted)
					VALUES (
						<cfqueryparam value="#objectId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.uploadId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#uploadResult.clientfile#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#uploadResult.serverfile#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#uploadResult.filesize#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#uploadResult.clientfileext#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#uploadResult.contenttype#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						0
					)
				</cfquery>

				<cfset var result = {}>
				<cfset result["id"] = objectId>
				<cfset result["file"] = uploadResult.clientfile>
				<cfset result["size"] = uploadResult.filesize>

				<cfreturn representationOf(result)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="delete">
		<cfargument name="id" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfquery name="local.qUpload">
					SELECT *
					FROM session_upload
					WHERE object_id = <cfqueryparam value="#arguments.id#" cfsqltype="varchar">
					AND deleted = 0
				</cfquery>

				<cfloop query="qUpload">
					<cftry>
						<cffile action="delete" file="c:\inetpub\wwwroot\emm\api\upload\#serverfile#">
						<cfcatch></cfcatch>
					</cftry>

					<cfquery>
						UPDATE session_upload
						SET deleted = 1,
							delete_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
						WHERE object_id = <cfqueryparam value="#arguments.id#" cfsqltype="varchar">
					</cfquery>
				</cfloop>
				<cfreturn noData().withStatus(200)>
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