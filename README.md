# Orientdb Protobufs Experiment

This is an experiment to see how the orientdb binary protocol could look if it used [protocol buffers](https://developers.google.com/protocol-buffers).

Check out [definitions.proto](./definitions.proto) for the data structures.

> Note: most but not all of the orientdb commands are currently implemented.


## Generating the definitions.

First, install protoc after downloading it from [the repo](https://code.google.com/p/protobuf/downloads/list).

Then run `make all` and have a look at the `out` directory.

----------------------------------------------------------

# Why Protobufs

> TLDR: Protobufs not only makes it easy to change the protocol without breaking things, they make implementation and maintenance of clients much easier and cheaper. Something orientdb desperately needs.

### Background

As is natural with any large project that has been in development for several years, the existing orientdb binary protocol has evolved over time. It has become quite difficult for maintainers of client libraries to keep pace with the changes and it's extremely difficult for people new to the project to implement a client from scratch. This is due to an accumulation of edge cases and 'minimalist' documentation. While the documentation can be fixed, the edge cases will remain until the protocol itself has been refactored with future flexibility in mind.

Having spoken to a couple of other client maintainers, the typical development flow looks like this:

1. Developer thinks orientdb looks awesome and it's an ideal fit for their or their employer's use case, but:
      - libraries for their language are not available, *or*
      - libraries are available but they are unmaintained or unmaintainable

      > At this point, 99% of people will walk away saying, 'damn, I wish I could have used orientdb', and that will be that, but some brave souls will decide that orient looks **so awesome** that it's worth the pain of continuing.
2. Developer looks at the [protocol](https://github.com/orientechnologies/orientdb/wiki/Network-Binary-Protocol) and thinks 'hey, how hard can this be?'

3. Developer loses 3 weeks of their life implementing a client, fighting edge cases and documentation shortcomings.

4. Client library is finished or is at least usable, so the author publishes it and breathes a sigh of relief. It's not pretty, but it works.

5. Everything is great for a while, but then the developer switches jobs or begins working on something else.

6. **The orientdb protocol changes.** The client is now incompatible with the latest version. The developer does not or cannot continue developing it.

7. The employer cannot upgrade to the latest version of orient, they are stuck until they hire a new developer to improve the existing client.

8. New developer takes a look at the now unmaintained library code and thinks 'WTF was this person thinking? What a mess, I cannot work with this!', GOTO 1.


**The lack of good quality client libraries is provably hurting orient's chances of widespread adoption.**

The number of unmaintained or incompatible libraries listed on the [programming language bindings page](https://github.com/orientechnologies/orientdb/wiki/Programming-Language-Bindings) strongly indicate that it has been too expensive (in terms of time and / or money) for individuals and companies to continue maintaining them.


### The Problem(s)

The core problem is that it's difficult to implement a binary protocol that gets everything right from day one. Protocols like this will always be subject to some kind of changes unless the technology itself stands still, which is obviously not the case with orient. If the protocol itself is not designed to be extensible from the start, implementations will always get more complicated and buggy over time, as edge cases and technical debt accumulates. If the protocol is designed to allow changes, but can maintain backwards compatibility, with older clients simply ignoring new fields, it should lead to far simpler implementations with fewer bugs.

Another major problem that client implementors face is that the protocol documentation can often not reflect the reality of the implementation, or it reflects the current official version of the protocol but not the bleeding edge code. This is because the documentation and the protocol are defined separately, bringing them together would ensure that they never get out of sync.

The worst part though, or at least, the issue with the deepest ramifications, is that every single client implementor is forced to write their own protocol parser and serializer from scratch. This duplication of effort, in what is the most difficult part of the implementation, is basically guaranteed to lead to bugs.
Bugs that **orientdb** will get blamed for, and not necessarily the client.


### Introducing Protobufs

[Protocol Buffers](https://code.google.com/p/protobuf/) is an extensible, data efficient binary format developed by google. It has native support for Java, C++ and python, with mature implementations available for many other languages.

The core benefits of protocol buffers for orientdb are:

- Structured declarative syntax that allows comments for better documentation.
- Extremely efficient and benefits from huge investments of effort from Google.
- Supports changes at the protocol layer without breaking backwards compatibility.
- Easy to work with and widely supported.
- Eliminates duplication of effort.
- Extremely easy to keep up to date with protocol changes.

The biggest plus point is that with protobufs, there would be a single canonical representation of the protocol which all client authors can use both as a reference, and to generate an exactly compliant, 'bug free' serializer / parser code for their language of choice.

Not only does this make authoring these client libraries orders of magnitude easier and cheaper, it also makes them orders of magnitude easier and cheaper to maintain over the long term. Protobufs also makes it much less likely that new releases of orient will actually break these older libraries, **this means that orientdb users are far less likely to get 'locked in' to an out of date version.**

By offering a canonical definition of the protocol that others can consume programatically, entire classes of bugs can be avoided, and orient's reputation for stability and reliability will be improved.


### The Business Case for Protobufs

Although seemingly tangentially related to the question of which binary format to use, there is a real business case for making this switch.

Given its wide range of features and excellent performance, orientdb usage should be growing much faster than it is doing. A comparison of mongodb and orientdb on [Google Trends](http://www.google.co.uk/trends/explore#q=orientdb%2C%20mongodb&cmpt=q) shows that whilst orient is growing, it is being completely dominated by the technically inferior mongodb.

Why is this happening?

There seems to be a prevalent myth amongst the people that I've spoken to that mongo is winning because of 'marketing'. The fact that they have $230m+ in investment capital is definitely an advantage here, but mongodb gained investment because they already had traction, not traction because of their investment. How did they get it? And let's take another example of a rapidly growing data store - redis. Redis has had no such big investment, yet it's growing rapidly. Whilst redis is complementary and not comparable with orientdb, it's a good example of a technology that has had almost no marketing yet has [risen to prominence](http://www.google.co.uk/trends/explore#q=redis%2C%20memcached&cmpt=q) within its niche (and arguably created its own) within just a few short years.

What drove the adoption of these two technologies? **The web.**

Both of these systems are ideally suited for the kinds of problems that web developers face every day. Not only that, they are *easy* for web developers to pick up and start using.

Orientdb is undoubtedly a fantastic platform if you're a Java developer, but the vast majority of web developers are not. They come from dynamic language backgrounds. Because there are no official drivers for these platforms, and because of the problems outlined above with the drivers that do exist, choosing orientdb becomes **much** harder than it should be.

But wait, neither mongo nor redis use protobufs, how is this related?

Mongo uses an [extremely simple](http://docs.mongodb.org/meta-driver/latest/legacy/mongodb-wire-protocol/) binary protocol and redis uses a [text based format](http://redis.io/topics/protocol). This makes them *much* easier to implement than orient's relatively complicated custom protocol, and means that they have been able to improve their protocols without making life very difficult for their client library authors. Both are designed so that old clients can simply ignore messages they don't understand, without breaking in most cases. Because orient does more stuff than either of those systems, it requires a more complicated protocol, but it does not mean that the protocol should be hard to use or implement. Mongo and Redis's protocols are easy, orient's is hard - this matters for early adopters.

For orientdb to grow rapidly, it needs to embrace mobile / web platforms as first class consumers and not second or third class. This means official support for JavaScript, PHP, Python, Ruby and probably others, e.g. .NET and Objective C.

With the current binary protocol, implementing and maintaining these client libraries is simply too expensive for orient to fund themselves. But without the official libraries, orientdb becomes less appealing for web developers and so orient's growth is stunted. It's a catch 22 situation.

Choosing a database is a serious decision for most companies, it's not the kind of thing you want to get wrong because if you do, you lose data and bad things happen. Here's a rough list of things to consider when making such a decision:

- Is it durable?
- Is it fast?
- Does it suit my use case?
- Are programming language bindings available for my language of choice?
- Is it easy to get started with?
- Does my team know it / is it easy to hire for?

Currently orientdb wins at the first 3 but if you're not using Java it fails pretty badly at the last 3.
If we can solve the client library problem, and therefore make it *fun* and *productive* to use orientdb for the web, we can probably solve the growth problem.

All that is required is some momentum. To increase momentum we need to make it both *easier* and *less risky* for web developers to try out orient, and the brilliance of the product will do the rest.

- Make it **easier** by documenting extensively and providing good client libraries.
- Make it **less risky** by keeping those libraries up to date and sending strong signals that the project is active and that the user is *not* taking a gamble by choosing orient.

**Protobufs is all about giving the orient team a path to official client libraries that are not cripplingly expensive to produce and maintain.** These official client libraries will spur growth as orientdb becomes accessible to more and more people who can see just how truly amazing the product itself is.

Without embracing the web, orientdb is doomed to relative obscurity. This would be a catastrophe, as I cannot think of another data store more ideally suited for the common problems we face daily as web developers. Orient is this amazing technology that is *just slightly* out of reach for the people that need it the most! By making this fundamental change, by making orient more accessible and thereby making its technical merits even more obvious, it can be a true competitor to the current giants.


### Possible Objections

I'd imagine that some people will object to making this switch, here I hope to rebuff the most common objections people will have.

1. **Performance will suffer.**
  Maybe, and we intend to produce a proof of concept implementation to assess the performance impact.
  However, we do not believe that making this change will affect the performance of *real world* applications. It is even possible that a protobufs implementation will be faster, not only because of the extensive work Google et al have put into it, but also because it allows for expressing things at the protocol layer that have to be hacked on with the current implementation (e.g. lists of base64 encoded binary record ids embedded in documents in orientdb 1.7).

2. **Protobuf uses code generation and code generation sucks.**
  Do you also feel the same way about [lex](http://en.wikipedia.org/wiki/Lex_\(software\)), or [bison](http://www.gnu.org/software/bison/)? This is roughly the same thing, but with the advantage that `.proto` files can be used to generate a wide variety of different programming languages. Also, just like an optimising compiler can often produce better machine code than a human, the protobuf compiler can probably produce as good as or better protocol parser / serialization code.

3. **It's a huge change for orient.**
  From our initial research it appears that only [two](https://github.com/orientechnologies/orientdb/blob/bbca8263aae0141599abceefe12258be33f27bd3/server/src/main/java/com/orientechnologies/orient/server/network/protocol/binary/ONetworkProtocolBinary.java) [classes](https://github.com/orientechnologies/orientdb/blob/bbca8263aae0141599abceefe12258be33f27bd3/client/src/main/java/com/orientechnologies/orient/client/remote/OStorageRemote.java) in orient would need to be duplicated, and we propose at first implementing this using a new URI scheme, e.g. `premote` or serving on an entirely separate port.

4. **It's a huge change for client authors.**
  It's a huge change, but huge in the sense "someone just gave you a load of fast, exactly correct parser / serialization code for free". For most authors the path to adoption will be very straightforward. They'll generate their code from the `.proto` definitions and plug it in in place of their existing parser / serialization code.


5. **Why don't we use X instead?**
  X probably doesn't have the momentum and widespread adoption of protobufs, but if it does and it solves all the problems listed above, we'd love to hear about it!





