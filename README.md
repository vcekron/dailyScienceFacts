# Daily Science Facts
This repository contains my iOS app for browsing the arXiv preprint server.

## Setup
To use this app, you'll need to set up your OpenAI API key:

1. Copy `Config.swift.template` to `Config.swift`
2. Open `Config.swift` and replace `"your-api-key-here"` with your actual OpenAI API key
3. Make sure `Config.swift` is added to your `.gitignore` file to prevent accidentally committing your API key

Note: `Config.swift` is used for development purposes. In a production environment, more secure methods of storing API keys should be implemented.

## FAQs
* **But... why?**
My goal is to get back into reading publications!
Since finishing my PhD, and consequently losing university library access, I've really been slacking on this front.
Of course, I could just open up arXiv.org in my browser or use the existing iOS apps, or subscribe to the email updates, or the RSS feed, or... you get my point.
I figured this would be a fun challenge, and I want to see if I can generate a super short summary of each preprint using ChatGPT.
I also thought it would be a useful exercise since I've never made an iOS app before!

* **How can I use this app too?** 
Building iOS apps for personal use is free! You can just install Xcode and plop my source code in there and build away. You will need to provide an OpenAI API key to generate the summaries (see Setup section above). The app is completely open source. **I only ask that you cite this repository if you use any of my work :)**

## Future Improvements (in no particular order)
- Implement more secure API key storage using Apple's Keychain Services for production use.
- Build out remaining sections of the app.
- Switch from static arXiv responses to actively polling the API.
- Cache ChatGPT responses to avoid unneccesary costs.
- Make it pretty and stuff (I want to be able to get a new color without having to refresh the data, for example; maybe by tapping it).
