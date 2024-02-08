module server;

public import vibe.core.log;
import vibe.http.server;
import vibe.http.fileserver;
import vibe.http.router;

enum ServerVersion = "0.1.0";

class PipingServer
{
	this() @safe
	{
		settings = new HTTPServerSettings;

		router = new URLRouter;
		router.get("/", &handleRequest);
		router.get("*", serveStaticFiles("./public/",));
	}

	void connection(ushort port) @safe
	{
		settings.port = port;
	}

	void connection(string host, ushort port) @safe
	{
		settings.port = port;
		settings.hostName = host;
	}

	void connection(string host, ushort port, string crt, string key) @safe
	{
		import vibe.stream.tls;

		settings.port = port == 443 || port == 8443 ? port : 443;
		settings.hostName = host;
		settings.tlsContext = createTLSContext(TLSContextKind.server, TLSVersion.any);
		settings.tlsContext.useCertificateChainFile(crt);
		settings.tlsContext.usePrivateKeyFile(key);
	}

	void listen() @trusted
	{
		listener = listenHTTP(settings, router);
		scope (failure)
			listener.stopListening();
		scope (success)
			logInfo("Server is listening on port %s", settings.port);
	}

	// private module (isn't C++ private class members)
private:
	void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe
	{
		res.redirect("/index.html");
	}

	HTTPServerSettings settings;
	HTTPListener listener;
	URLRouter router;
}
