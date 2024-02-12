import std.stdio : println = writeln;
import std.string : startsWith;
import server;
import vibe.core.core : runApplication;

@safe:

int main(string[] args)
{
	ushort port;
	string host, crtpath, keypath;
	bool enabletls = false;
	auto server = new PipingServer;

	foreach (index, flag; args)
	{
		if (flag == "--help" || flag == "-h")
		{
			printHelp();
			return 0;
		}
		else if (flag == "--http-port" || flag == "--https-port")
		{
			import std.conv;

			port = to!ushort(args[index + 1]);
		}
		else if (flag == "--host")
		{
			host = args[index + 1];
		}
		else if (flag == "--crt-path")
		{
			crtpath = args[index + 1];
		}
		else if (flag == "--key-path")
		{
			keypath = args[index + 1];
		}
		else if (flag == "-V" || flag == "--version")
		{
			println("piping-server version ", ServerVersion);
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
			      // dfmt on
			{
				logError("Unknown option: %s", flag);
				return -1;
			}
		}
	}

	if (enabletls)
	{
		server.connection(host, port, crtpath, keypath);
	}
	else
	{
		if (host != null)
		{
			server.connection(host, port);
		}
		else
		{
			server.connection(port);
		}
	}
	server.listen;
	return (ref auto a) @trusted { return runApplication(&a); }(args); // lambda safe bypass
}

void printHelp()
{
	println("Piping Server in D");
	println("Usage: piping-server [OPTIONS]");
	println("Options:");
	println(
		"  --host <HOST>              Bind address, either IPv4 or IPv6 (e.g. 127.0.0.1, ::1) [default: 0.0.0.0]");
	println("  --http-port <HTTP_PORT>    HTTP port [default: 0]");
	println("  --enable-https             Enable HTTPS");
	println("  --https-port <HTTPS_PORT>  HTTPS port");
	println("  --crt-path <CRT_PATH>      Certification path");
	println("  --key-path <KEY_PATH>      Private key path");
	println("  -h, --help                 Print this help message");
	println("  -V, --version              Print version information");
}
