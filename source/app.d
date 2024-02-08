import std.stdio : writeln, stderr;
import vibe.core.core;
import vibe.core.log;
import vibe.http.server;
import std.string : startsWith;

enum ServerVersion = "0.1.0";

class PipingServer
{
	this(ushort port)
	{
		settings = new HTTPServerSettings;
		settings.port = port;
		listener = listenHTTP(settings, &handleRequest);
		scope (failure)
			listener.stopListening();
		logInfo("Server is listening on port %s", port);
	}

	this(string host, ushort port)
	{
		settings = new HTTPServerSettings;
		settings.port = port;
		settings.hostName = host;
		listener = listenHTTP(settings, &handleRequest);
		scope (failure)
			listener.stopListening();
		logInfo("Server is listening on port %s", port);
	}

	this(string host, ushort port, string crt, string key)
	{
		import vibe.stream.tls;

		settings = new HTTPServerSettings;
		settings.port = port == 443 || port == 8443 ? port : 443;
		settings.hostName = host;
		settings.tlsContext = createTLSContext(TLSContextKind.server, TLSVersion.any);
		settings.tlsContext.useCertificateChainFile(crt);
		settings.tlsContext.usePrivateKeyFile(key);
		listener = listenHTTP(settings, &handleRequest);
		scope (failure)
			listener.stopListening();
		logInfo("Server is listening on port %s", port);
	}

// private module (isn't C++ private class members)
private:
	void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res)
	{
		if (req.requestPath.toString == "/")
		{
			res.writeBody(cast(ubyte[]) "Hello from the piping server!\n", "text/plain");
		}
		if (req.requestPath.toString == "/foo")
		{
			res.writeBody(cast(ubyte[]) "Bar!\n", "text/plain");
		}
	}

	HTTPServerSettings settings;
	HTTPListener listener;
}

int main(string[] args)
{
	ushort port;
	string host, crtpath, keypath;
	bool enabletls = false;

	size_t args_index = 0;
	foreach (flag; args)
	{
		scope (exit)
			args_index += 1;
		if (flag == "--help" || flag == "-h" || args.length < 2)
		{
			printHelp();
			return 0;
		}
		else if (flag == "--http-port" || flag == "--https-port")
		{
			import std.conv;

			port = to!ushort(args[args_index + 1]);
		}
		else if (flag == "--host")
		{
			host = args[args_index + 1];
		}
		else if (flag == "--crt-path")
		{
			crtpath = args[args_index + 1];
		}
		else if (flag == "--key-path")
		{
			keypath = args[args_index + 1];
		}
		else if (flag == "-V" || flag == "--version")
		{
			writeln("piping-server version ", ServerVersion);
			return 0;
		}
		else if (flag == "--enable-https")
		{
			enabletls = true;
		}
		else if (flag.startsWith("--") || flag.startsWith("-"))
		{
			// dfmt off
			if (flag != "--host" || flag != "--http-port" || flag != "--https-port" ||
			flag != "--crt-path" || flag != "--key-path" || flag != "--enable-https")
			{
				stderr.writeln("Unknown option: ", flag);
				return -1;
			}
			// dfmt on
		}
	}

	if (enabletls)
	{
		new PipingServer(host, port, crtpath, keypath);
	}
	else
	{
		if (host != null)
		{
			new PipingServer(host, port);
		}
		else
		{
			new PipingServer(port);
		}
	}
	return runApplication(&args);
}

void printHelp()
{
	writeln("Piping Server in D");
	writeln("Usage: piping-server [OPTIONS]");
	writeln("Options:");
	writeln(
		"  --host <HOST>              Bind address, either IPv4 or IPv6 (e.g. 127.0.0.1, ::1) [default: 0.0.0.0]");
	writeln("  --http-port <HTTP_PORT>    HTTP port [default: 8080]");
	writeln("  --enable-https             Enable HTTPS");
	writeln("  --https-port <HTTPS_PORT>  HTTPS port");
	writeln("  --crt-path <CRT_PATH>      Certification path");
	writeln("  --key-path <KEY_PATH>      Private key path");
	writeln("  -h, --help                 Print this help message");
	writeln("  -V, --version              Print version information");
}
