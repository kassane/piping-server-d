module server;

public import vibe.core.log;
import vibe.core.file;
import vibe.core.path;
import vibe.http.server;
import vibe.http.fileserver;
import vibe.http.router;

enum ServerVersion = "0.1.0";

class PipingServer
{
	this() @safe
	{
		settings = new HTTPServerSettings;
		settings.maxRequestSize = 1024 * 1024 * 50;

		router = new URLRouter;
		router.get("/", staticTemplate!"upload_form.dt");
		router.post("/uploaded", &uploadFile);
		router.get("*", serveStaticFiles("downloads/",));
	}

	void connection(immutable ushort port) @safe nothrow @nogc
	{
		settings.port = port;
	}

	void connection(inout string host, immutable ushort port) @safe @nogc nothrow
	{
		settings.port = port;
		settings.hostName = host;
	}

	void connection(inout string host, immutable ushort port, inout string crt, inout string key) @safe
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
	private void uploadFile(scope HTTPServerRequest req, scope HTTPServerResponse res)
	{
		import std.exception;

		auto pf = "file" in req.files;
		enforce(pf !is null, "No file uploaded!");
		if (!existsFile(NativePath("downloads")))
		{
			createDirectory(NativePath("downloads"));
		}
		try
			moveFile(pf.tempPath, NativePath("downloads") ~ pf.filename);
		catch (Exception e)
		{
			logWarn("Failed to move file to destination folder: %s", e.msg);
			logInfo("Performing copy+delete instead.");
			copyFile(pf.tempPath, NativePath("downloads") ~ pf.filename);
		}

		res.writeBody("File uploaded!", "text/plain");
	}

private:
	HTTPServerSettings settings;
	HTTPListener listener;
	URLRouter router;
}
