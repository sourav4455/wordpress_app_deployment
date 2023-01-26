# Interview Assignment - Deployment Automation

Hello, dear candidate! Thanks for taking the time to try this out.

The goal of this assignment is to assert (to some degree) your skills as a software engineer. You should focus on showcasing your skill at coding and problem solving. The solution is intentionally open-ended, to give you space for personal interpretation, but for all intents and purposes you can pretend that you're building a production-ready application!

You can develop the assignment in any common language you can demonstrate being comfortable coding with.

You're **allowed and encouraged** to use third party libraries and tools, as long as they are free and open source. An effective developer knows what to build and what to reuse, but also how his/her tools work. Be prepared to answer some questions about these, like why you chose them and what other alternatives you considered.

As this is a code review process, please minimize generated code, as this might make our jobs as reviewers more difficult.

_Note: While we love open source at SUSE, please do not create a public repo with your assignment in! This test is only shared with people interviewing, and for obvious reasons we'd like it to remain this way._

## Instructions

1. Clone this repository.
2. Create a pull request targeting the master branch of this repository.
   This PR should contain setup instructions for your application and a breakdown of the technologies & packages you chose to use, why you chose to use them, and the design decisions you made.
3. Reply to the email thread you're having with your recruitment contact, telling them your assignment was submitted.
4. We'll then schedule a live peer-review meeting where we'll have a chat together with some of your potential future colleagues, to discuss the details of your execution.

## Requirements

Given an inventory of cloud servers (how many it's up to you), create an Infrastructure-as-Code automation project that can produce a highly available deployment of the [Wordpress](https://wordpress.org) web application.
Wordpress is a classic example of a multi-layer web application consiting of a web server front-end, an application server and a relational database.  
For trivial loads it's very common to run all the components in a single server, but for the intents of the exercise we want a production-grade deployment instead.

Here are the main features of the project:
- The application must have no single point of failures, i.e. if any of the cloud servers fails, the application will still keep working.
- The deployment must be repeatable, i.e. given a different inventory of servers, one can perform the exact same deployment on it. This is, for example, to produce multiple environments of the same application.

Stretch goal:
- The Deployment must be horizontally scalable, i.e. one can easily increase the load capacity of at least one of the layers of the application by adding additional cloud instances to the existing inventory.

### Constraints and details

- Managing the state of the deployment (e.g. backups) is out of the scope of the exercise.
- The achitectural patterns, standards and platforms used to implement The Deployment are left as free design decisions.
- Additional features you might want to autonomously define and implement are welcome!

## Good luck

In case you need any sort of clarification, feel free to open an issue in the repo, and we'll help you as we can.

Now code something awesome!
