<cfcomponent extends="taffy.core.resource" taffy_uri="/upload_new">

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
		<cfargument name="filename" type="string" required="true">
		<cfargument name="filesize" type="numeric" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>
				<cfset var objectId = createUUID()>

				<cfquery>
					INSERT INTO session_upload (object_id, client_session_id, participant_id, upload_id, file_name, file_size, create_date, deleted)
					VALUES (
						<cfqueryparam value="#objectId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.participantId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.uploadId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.filename#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.filesize#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						0
					)
				</cfquery>

				<cfset var response["location"] = "https://secure.datasport.com/emm/api/upload_new?id=#objectId#">

				<cfreturn noData()
					.withStatus(201, "Created")
					.withHeaders(response)>
			<cfelse>
				<cfreturn noData().withStatus(403)>
			</cfif>
			<cfcatch>
				<cfset application.common.informAdmin(message=cfcatch.message, data=cfcatch, subject="[Error] EMM API")>
				<cfreturn noData().withStatus(500)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="put">
		<cfargument name="id" type="string" required="true">

		<cftry>
			<cfif structKeyExists(arguments, "sessionId")>

				<cfquery name="local.qUpload">
					SELECT *
					FROM session_upload
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND object_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qUpload.recordcount EQ 0>
					<cfreturn rep({error: "Invalid file ID"}).withStatus(404)>
				</cfif>

				<cfset var filePath = "c:\inetpub\wwwroot\emm\api\upload\#arguments.id#">

				<!--- Check the uploaded file's size per the content-length header against the recorded metadata --->
				<cfset var headers = GetHTTPRequestData().headers>
				<cfif headers["content-length"] NEQ qUpload.file_size>
					<cfreturn rep({error: "The file size doesn't match your metadata"}).withStatus(400)>
				</cfif>

				<!--- Get the binary from the request, bypassing Taffy --->
				<cfset var binary = GetHTTPRequestData().content>
				<!--- Check it's actually a binary --->
				<cfif !IsBinary(binary)>
					<cfreturn rep({error: "No binary found in the request body"}).withStatus(400)>
				</cfif>

				<!--- Write the binary to the file system --->
				<cffile action="write" file="#filePath#" output="#binary#">

				<!--- Double check the actual file size against the recorded metadata --->
				<cfif GetFileInfo(filepath).size NEQ qUpload.file_size>
					<cftry>
						<cffile action="delete" file="#filepath#">
						<cfcatch></cfcatch>
					</cftry>
					<cfreturn rep({error: "The file size doesn't match your metadata"}).withStatus(400)>
				</cfif>

				<!--- Check the mime type matches the header value --->
				<cfset var actualMimeType = FileGetMimeType(filePath, true)>
				<cfif actualMimeType NEQ headers["content-type"]>
					<cftry>
						<cffile action="delete" file="#filepath#">
						<cfcatch></cfcatch>
					</cftry>
					<cfreturn rep({error: "The binary file mime type does not match the content-type in the request header"}).withStatus( 400 )>
				</cfif>

				<cfquery>
					UPDATE session_upload
					SET content_type = <cfqueryparam value="#headers["content-type"]#" cfsqltype="cf_sql_varchar">,
						update_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					WHERE client_session_id = <cfqueryparam value="#arguments.sessionId#" cfsqltype="cf_sql_varchar">
					AND object_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfreturn rep({message: "File successfully uploaded", fileID: arguments.id})>
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