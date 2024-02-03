import vibe.vibe;
import std.stdio;

class PipingServer
{
	this(string host, ushort port)
	{
		settings = new HTTPServerSettings;
		settings.port = port;
		settings.hostName = host;
		listenHTTP(settings, &handleRequest);
		logInfo("Server is listening on port %s", port);
	}

	void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
	{
		res.writeBody("Hello from the piping server!\n");
	}

private:
	HTTPServerSettings settings;
}

int main(string[] args)
{
	ushort port;
	string host, crtpath, keypath;

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
			writeln("piping-server version 0.1.0");
		}
		else if (flag.startsWith("--") || flag.startsWith("-"))
		{
			if (flag != "--host" || flag != "--http-port" || flag != "--https-port" || flag != "--crt-path" || flag != "--key-path")
			{
				stderr.writeln("Unknown option: ", flag);
				return -1;
			}
		}
	}
	// Create an instance of the PipingServer class
	auto pipingServer = new PipingServer(host, port);
	return runApplication(&args);
}

void printHelp()
{
	writeln("Piping Server in D");
	writeln("Usage: piping-server [options]");
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
