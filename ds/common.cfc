<cfcomponent>

	<cffunction name="getRemoteIP" access="public" output="no" returntype="string">
		<cfset var remoteIP = "">
		<cfif IsDefined("cgi.x_forwarded_for") AND cgi.x_forwarded_for neq "">
			<cfif ListLen(cgi.x_forwarded_for, ",") GT 1>
				<cfset remoteIP = trim(ListLast(cgi.x_forwarded_for, ","))>
			<cfelse>
				<cfset remoteIP = cgi.x_forwarded_for>
			</cfif>
		<cfelseif IsDefined("http_ipremoteaddr") AND http_ipremoteaddr neq "">
			<cfset remoteIP = http_ipremoteaddr>
		<cfelse>
			<cfset remoteIP = remote_addr>
		</cfif>

		<cfreturn remoteIP>
	</cffunction>

	<cffunction name="addUTCOffset" access="public" output="no" returntype="date">
		<cfargument name="dt" type="date" required="yes">
		<cfreturn dateConvert('utc2local', arguments.dt)>
	</cffunction>

	<cffunction name="dslog" access="public" output="no" returntype="void">
		<cfargument name="log" type="string" required="yes">
		<cfargument name="text" type="string" required="no" default="">
		<cfset var logCookie = false>
		<cfif not isDefined("request.reqID")>
			<cfset request.reqID = getTickcount()>
		</cfif>
		<cfif arguments.log eq 'ds-cookie'>
			<cfif logCookie>
				<cflog file="#arguments.log#" text="#request.reqID# --- #getRemoteIp()# --- #arguments.text# (ua: #cgi.http_user_agent#)">
			</cfif>
		<cfelse>
			<cflog file="#arguments.log#" text="#request.reqID# --- #getRemoteIp()# --- #arguments.text# (ua: #cgi.http_user_agent#)">
		</cfif>
	</cffunction>

	<cffunction name="informAdmin" access="public" returntype="void">
		<cfargument name="message" type="string" required="yes">
		<cfargument name="data" type="any" required="no" default="">
		<cfargument name="cc" type="string" required="no" default="">
		<cfargument name="subject" type="string" required="no" default="#arguments.message#">
		<cfset remoteIP = getRemoteIP()>
		<cfif not listFind('216.126.201.143-', remoteIP)>
			<cfmail from="webapps@datasport.com" to="vesuvio_log@datasport.com" cc="#arguments.cc#" subject="#arguments.subject#" type="html">
Server: #createObject("java", "java.net.InetAddress").localhost.getCanonicalHostName()#:#iif(right(server.coldfusion.rootdir,1) eq "n", DE("1"), DE("#right(server.coldfusion.rootdir,1)#"))#<br>
Time: #TimeFormat(now(), "HH:mm.ss")#<br>
Message: #arguments.message#<br>
Remote IP: <a href="http://www.iptools.ch/?ip=#remoteIP#">#remoteIP#</a><br>
<br>
<cfdump label="Data" var="#arguments.data#">
<cfdump label="Form" var="#form#">
<cfdump label="Url" var="#url#">
<cfdump label="Session" var="#session#">
<cfdump label="Cgi" var="#cgi#">
<cfdump label="Server" var="#server#">
			</cfmail>
		</cfif>
	</cffunction>

</cfcomponent>