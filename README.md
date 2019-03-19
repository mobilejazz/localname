# Localname - Provide Secure Access to Your Local Development Server

No longer fiddle with router configurations, IP's or ports. Localname provides a single URL that just works.

Uses:

 * Live Preview: Show your work to anyone. Get instant feedback from your designer, client, tester or project manager. No source control (such as Git) or deployments required
 * Mobile App Testing: Test your mobile app backend from a real device without having to fiddle with local network configurations
 * Webhooks: Implement webhooks by providing a real callback URL to your development machine

Limitations:

 * The server has been tested on Linux and macOS, might or might not work on Windows
 * We only have a macOS client at the moment (but feel free to contribute!)

This project was part of the [Bugfender suite of developer tools](https://bugfender.com) to make developer's life a little bit easier every day.

Localname was built by [Mobile Jazz](https://mobilejazz.com/) and [Bugfender](https://bugfender.com) as a commercial product experiment.

This project is **usable**, although we do not intend to actively continue development.

## Installation
You will need to deploy a server and build a client in order to use Localname:

* You will need a Linux or macOS server, follow the instructions in `server`.
* To build the macOS client you will need Xcode, check the instructions on `client`.

## Contributing
Pull-requests are welcome, by making them you understand we will publish them under the current license.

Some top-requested features you can contribute on:

 * A system for reserving domain names to specific users
 * Inspection of the HTTP traffic being redirected
 * URL rewriting in server resposnes, for servers who are unaware of their public URL
 * Routing of pure TCP traffic (non-HTTP)
 * Store & forward of webhook messages if client is offline

## Support
You can download and run Localname on your own server for free.

Mobile Jazz can run a Localname server for you, implement enhancements, etc. for a fee. If you're interested, please contact us for a quote.
